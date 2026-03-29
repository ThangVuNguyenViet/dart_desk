# Image Reference Resolution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve `imageReference` nodes server-side so consumers receive self-contained image data (URL, dimensions, blurHash) without extra API calls, and consumer model image fields use `ImageUrl` instead of `String`.

**Architecture:** `PublicContentEndpoint` scans document JSON for `imageReference` nodes, batch-fetches their `MediaAsset` records, and inlines asset fields before returning. `ImageUrl` gains `fromJson`/`withTransform` so consumer models can decode and apply CDN transforms. `HomeScreenConfig` migrates from `String` to `ImageUrl?` as the reference example.

**Tech Stack:** Dart/Flutter, Serverpod (backend), `dart_mappable` (serialization), `source_gen`/`build_runner` (codegen)

---

## File Map

| File | Change |
|------|--------|
| `packages/dart_desk/lib/src/data/models/media_asset.dart` | Add `MediaAsset.fromInlineJson` factory |
| `packages/dart_desk/lib/src/media/image_url.dart` | Add `ImageUrl.fromJson` factory + `withTransform` method |
| `packages/dart_desk/lib/src/media/image_url_mapper.dart` | **Create** — `ImageUrlMapper` for `dart_mappable` |
| `packages/dart_desk/lib/dart_desk.dart` | Export `image_url.dart` and `image_url_mapper.dart` |
| `dart_desk_be/dart_desk_server/lib/src/endpoints/public_content_endpoint.dart` | `_toPublicDocument` → async; add `_resolveImageReferences`, `_collectAssetIds`, `_inlineAssets` |
| `examples/data_models/pubspec.yaml` | Add `dart_desk` dependency |
| `examples/data_models/lib/src/configs/home_screen_config.dart` | `String backgroundImageUrl` → `ImageUrl? backgroundImage`; `String? footerLogoUrl` → `ImageUrl? footerLogo`; add `ImageUrlMapper` |
| `examples/data_models/lib/src/configs/home_screen_config.cms.g.dart` | Regenerated |
| `examples/data_models/lib/src/configs/home_screen_config.mapper.dart` | Regenerated |
| `examples/example_app/lib/screens/homes_creen.dart` | Update image field usages |
| `packages/dart_desk/test/media/image_url_test.dart` | **Create** — unit tests for `fromJson`, `withTransform`, `url()` |
| `dart_desk_be/dart_desk_server/test/integration/public_content_endpoint_test.dart` | Add image resolution integration test |

---

## Task 1: `MediaAsset.fromInlineJson`

**Files:**
- Modify: `packages/dart_desk/lib/src/data/models/media_asset.dart`
- Test: `packages/dart_desk/test/data/models/media_asset_inline_json_test.dart` (**create**)

- [ ] **Step 1: Create the test file**

```dart
// packages/dart_desk/test/data/models/media_asset_inline_json_test.dart
import 'package:dart_desk/dart_desk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MediaAsset.fromInlineJson', () {
    test('decodes required fields', () {
      final json = {
        'assetId': 'image-abc-100x200-jpg',
        'publicUrl': 'https://cdn.example.com/image.jpg',
        'width': 100,
        'height': 200,
        'blurHash': 'LGF5?xYk^6#M',
      };

      final asset = MediaAsset.fromInlineJson(json);

      expect(asset.assetId, equals('image-abc-100x200-jpg'));
      expect(asset.publicUrl, equals('https://cdn.example.com/image.jpg'));
      expect(asset.width, equals(100));
      expect(asset.height, equals(200));
      expect(asset.blurHash, equals('LGF5?xYk^6#M'));
      expect(asset.lqip, isNull);
    });

    test('decodes optional lqip when present', () {
      final json = {
        'assetId': 'image-abc-100x200-jpg',
        'publicUrl': 'https://cdn.example.com/image.jpg',
        'width': 100,
        'height': 200,
        'blurHash': 'LGF5?xYk^6#M',
        'lqip': 'data:image/jpeg;base64,abc123',
      };

      final asset = MediaAsset.fromInlineJson(json);

      expect(asset.lqip, equals('data:image/jpeg;base64,abc123'));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk
flutter test test/data/models/media_asset_inline_json_test.dart
```

Expected: `Error: Method not found: 'MediaAsset.fromInlineJson'`

- [ ] **Step 3: Add `fromInlineJson` to `MediaAsset`**

In `packages/dart_desk/lib/src/data/models/media_asset.dart`, add after the `fromJson` factory (around line 52):

```dart
  /// Decodes the subset of fields present in a resolved imageReference node.
  /// Fields not present in the inline format use safe zero-value defaults.
  factory MediaAsset.fromInlineJson(Map<String, dynamic> json) {
    return MediaAsset(
      id: 0,
      assetId: json['assetId'] as String,
      fileName: '',
      mimeType: 'image/*',
      fileSize: 0,
      publicUrl: json['publicUrl'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      hasAlpha: false,
      blurHash: json['blurHash'] as String? ?? '',
      lqip: json['lqip'] as String?,
      createdAt: DateTime(0),
      metadataStatus: MediaAssetMetadataStatus.complete,
    );
  }
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk
flutter test test/data/models/media_asset_inline_json_test.dart
```

Expected: `All tests passed`

- [ ] **Step 5: Commit**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
git add packages/dart_desk/lib/src/data/models/media_asset.dart packages/dart_desk/test/data/models/media_asset_inline_json_test.dart
git commit -m "feat(dart_desk): add MediaAsset.fromInlineJson for resolved image nodes"
```

---

## Task 2: `ImageUrl.fromJson` + `withTransform`

**Files:**
- Modify: `packages/dart_desk/lib/src/media/image_url.dart`
- Create: `packages/dart_desk/test/media/image_url_test.dart`

- [ ] **Step 1: Create the test file**

```dart
// packages/dart_desk/test/media/image_url_test.dart
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/src/media/image_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final resolvedJson = {
    '_type': 'imageReference',
    'assetId': 'image-abc-1920x1080-jpg',
    'publicUrl': 'https://cdn.example.com/image.jpg',
    'width': 1920,
    'height': 1080,
    'blurHash': 'LGF5?xYk^6#M',
    'hotspot': {'x': 0.5, 'y': 0.3, 'width': 0.8, 'height': 0.6},
    'crop': null,
    'altText': 'A hero image',
  };

  group('ImageUrl.fromJson', () {
    test('decodes publicUrl correctly', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      expect(imageUrl.url(), equals('https://cdn.example.com/image.jpg'));
    });

    test('decodes blurHash', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      expect(imageUrl.blurHash, equals('LGF5?xYk^6#M'));
    });

    test('decodes hotspot', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      expect(imageUrl.imageRef.hotspot?.x, equals(0.5));
      expect(imageUrl.imageRef.hotspot?.y, equals(0.3));
    });

    test('decodes altText', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      expect(imageUrl.imageRef.altText, equals('A hero image'));
    });

    test('url() returns raw publicUrl when no transform builder', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      expect(
        imageUrl.url(width: 800, fit: FitMode.crop),
        equals('https://cdn.example.com/image.jpg'),
      );
    });
  });

  group('ImageUrl.withTransform', () {
    test('applies transform builder to url()', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      final withTransform = imageUrl.withTransform(
        (publicUrl, params) => '$publicUrl?w=${params.width}',
      );
      expect(withTransform.url(width: 800), equals('https://cdn.example.com/image.jpg?w=800'));
    });

    test('original imageUrl is unchanged after withTransform', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      imageUrl.withTransform((url, _) => '$url?modified');
      expect(imageUrl.url(), equals('https://cdn.example.com/image.jpg'));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk
flutter test test/media/image_url_test.dart
```

Expected: `Error: Method not found: 'ImageUrl.fromJson'`

- [ ] **Step 3: Add `fromJson` and `withTransform` to `ImageUrl`**

Replace the contents of `packages/dart_desk/lib/src/media/image_url.dart` with:

```dart
import '../data/models/image_reference.dart';
import '../data/models/image_types.dart';
import '../data/models/media_asset.dart';
import 'image_transform_params.dart';

typedef TransformUrlBuilder = String? Function(
    String publicUrl, ImageTransformParams params);

class ImageUrl {
  final ImageReference imageRef;
  final TransformUrlBuilder? _transformUrl;

  const ImageUrl({required this.imageRef, TransformUrlBuilder? transformUrl})
      : _transformUrl = transformUrl;

  /// Decodes a resolved imageReference JSON node into an [ImageUrl].
  ///
  /// The JSON must contain: assetId, publicUrl, width, height, blurHash.
  /// Optional: lqip, hotspot, crop, altText.
  /// [transformUrl] is null until the consumer calls [withTransform].
  factory ImageUrl.fromJson(Map<String, dynamic> json) {
    final asset = MediaAsset.fromInlineJson(json);
    final ref = ImageReference.fromDocumentJson(json, asset);
    return ImageUrl(imageRef: ref);
  }

  /// Returns a new [ImageUrl] with the given [builder] applied to [url].
  ///
  /// The original [ImageUrl] is not mutated.
  ImageUrl withTransform(TransformUrlBuilder builder) =>
      ImageUrl(imageRef: imageRef, transformUrl: builder);

  String url({
    int? width,
    int? height,
    FitMode? fit,
    String? format,
    int? quality,
  }) {
    final params = ImageTransformParams(
      width: width,
      height: height,
      fit: fit,
      format: format,
      quality: quality,
      fpX: imageRef.hotspot?.x,
      fpY: imageRef.hotspot?.y,
      crop: imageRef.crop,
    );
    return _transformUrl?.call(imageRef.asset.publicUrl, params) ??
        imageRef.asset.publicUrl;
  }

  String get blurHash => imageRef.asset.blurHash;
  String? get lqip => imageRef.asset.lqip;
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk
flutter test test/media/image_url_test.dart
```

Expected: `All tests passed`

- [ ] **Step 5: Commit**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
git add packages/dart_desk/lib/src/media/image_url.dart packages/dart_desk/test/media/image_url_test.dart
git commit -m "feat(dart_desk): add ImageUrl.fromJson and withTransform"
```

---

## Task 3: `ImageUrlMapper` + barrel exports

**Files:**
- Create: `packages/dart_desk/lib/src/media/image_url_mapper.dart`
- Modify: `packages/dart_desk/lib/dart_desk.dart`

- [ ] **Step 1: Create `image_url_mapper.dart`**

```dart
// packages/dart_desk/lib/src/media/image_url_mapper.dart
import 'package:dart_mappable/dart_mappable.dart';

import 'image_url.dart';

/// A [dart_mappable] custom mapper for [ImageUrl].
///
/// Decodes a resolved imageReference JSON map → [ImageUrl].
/// Encodes [ImageUrl] → assetId-only map (the stored document format).
///
/// Add to your @MappableClass annotation:
/// ```dart
/// @MappableClass(includeCustomMappers: [ImageUrlMapper()])
/// class MyConfig ...
/// ```
class ImageUrlMapper extends SimpleMapper<ImageUrl> {
  const ImageUrlMapper();

  @override
  ImageUrl decode(Object value) =>
      ImageUrl.fromJson(value as Map<String, dynamic>);

  @override
  Object encode(ImageUrl self) => self.imageRef.toDocumentJson();
}
```

- [ ] **Step 2: Export `image_url.dart` and `image_url_mapper.dart` from the barrel**

In `packages/dart_desk/lib/dart_desk.dart`, add after the `DATA LAYER` export section (after line 38):

```dart
// ============================================================================
// MEDIA
// ============================================================================
export 'src/media/image_url.dart';
export 'src/media/image_url_mapper.dart';
```

- [ ] **Step 3: Verify the package compiles**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk
flutter analyze lib/
```

Expected: `No issues found`

- [ ] **Step 4: Commit**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
git add packages/dart_desk/lib/src/media/image_url_mapper.dart packages/dart_desk/lib/dart_desk.dart
git commit -m "feat(dart_desk): add ImageUrlMapper and export media types"
```

---

## Task 4: Backend image reference resolver

**Files:**
- Modify: `dart_desk_be/dart_desk_server/lib/src/endpoints/public_content_endpoint.dart`
- Modify: `dart_desk_be/dart_desk_server/test/integration/public_content_endpoint_test.dart`

- [ ] **Step 1: Add the image resolution integration test**

In `dart_desk_be/dart_desk_server/test/integration/public_content_endpoint_test.dart`, add this group after the `getContentBySlug` group (before the closing `}`):

```dart
    group('image reference resolution', () {
      test('inlines asset fields into imageReference nodes', () async {
        final asset = await factory.uploadTestImage();

        await createPublishedDocument(
          documentType: 'blog',
          title: 'Image Post',
          slug: 'image-post',
          data: {
            'title': 'Hello',
            'heroImage': {
              '_type': 'imageReference',
              'assetId': asset.assetId,
            },
          },
        );

        final result = await endpoints.publicContent.getContentBySlug(
          sessionBuilder,
          'blog',
          'image-post',
        );

        final data = jsonDecode(result.data) as Map<String, dynamic>;
        final heroImage = data['heroImage'] as Map<String, dynamic>;

        expect(heroImage['_type'], equals('imageReference'));
        expect(heroImage['assetId'], equals(asset.assetId));
        expect(heroImage['publicUrl'], equals(asset.publicUrl));
        expect(heroImage['width'], equals(1));
        expect(heroImage['height'], equals(1));
        expect(heroImage['blurHash'], isNotEmpty);
      });

      test('resolves nested imageReference inside a list', () async {
        final asset = await factory.uploadTestImage();

        await createPublishedDocument(
          documentType: 'blog',
          title: 'Gallery Post',
          slug: 'gallery-post',
          data: {
            'gallery': [
              {
                '_type': 'imageReference',
                'assetId': asset.assetId,
              },
            ],
          },
        );

        final result = await endpoints.publicContent.getContentBySlug(
          sessionBuilder,
          'blog',
          'gallery-post',
        );

        final data = jsonDecode(result.data) as Map<String, dynamic>;
        final gallery = data['gallery'] as List<dynamic>;
        final firstImage = gallery.first as Map<String, dynamic>;

        expect(firstImage['publicUrl'], equals(asset.publicUrl));
      });

      test('document with no imageReference nodes is unchanged', () async {
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Text Post',
          slug: 'text-post',
          data: {'body': 'hello world'},
        );

        final result = await endpoints.publicContent.getContentBySlug(
          sessionBuilder,
          'blog',
          'text-post',
        );

        final data = jsonDecode(result.data) as Map<String, dynamic>;
        expect(data['body'], equals('hello world'));
      });
    });
```

Also add `import 'dart:convert';` at the top of the file if not already present.

- [ ] **Step 2: Run the new tests to verify they fail**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_server
dart test test/integration/public_content_endpoint_test.dart --name "image reference resolution"
```

Expected: Tests fail — `publicUrl` key missing from `heroImage`

- [ ] **Step 3: Implement the resolver in `public_content_endpoint.dart`**

Replace the file contents with:

```dart
import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../auth/dart_desk_session.dart';
import '../generated/protocol.dart';

/// Read-only public content API for external consumers.
/// Requires x-api-key with read permission.
/// ClientId is derived from the API key.
class PublicContentEndpoint extends Endpoint {
  /// Returns all published documents grouped by document type.
  Future<Map<String, List<PublicDocument>>> getAllContents(
    Session session,
  ) async {
    final clientId = _requireReadAccess(session);

    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.clientId.equals(clientId) & t.publishedAt.notEquals(null),
    );

    final grouped = <String, List<PublicDocument>>{};
    for (final doc in documents) {
      grouped.putIfAbsent(doc.documentType, () => []);
      grouped[doc.documentType]!.add(await _toPublicDocument(session, doc));
    }
    return grouped;
  }

  /// Returns the default published document for each document type.
  Future<Map<String, PublicDocument>> getDefaultContents(
    Session session,
  ) async {
    final clientId = _requireReadAccess(session);

    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.publishedAt.notEquals(null) &
          t.isDefault.equals(true),
    );

    final result = <String, PublicDocument>{};
    for (final doc in documents) {
      result[doc.documentType] = await _toPublicDocument(session, doc);
    }
    return result;
  }

  /// Returns all published documents of a specific type.
  Future<List<PublicDocument>> getContentsByType(
    Session session,
    String documentType,
  ) async {
    final clientId = _requireReadAccess(session);

    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.publishedAt.notEquals(null) &
          t.documentType.equals(documentType),
    );

    return Future.wait(documents.map((d) => _toPublicDocument(session, d)));
  }

  /// Returns the default published document for a specific type.
  Future<PublicDocument> getDefaultContent(
    Session session,
    String documentType,
  ) async {
    final clientId = _requireReadAccess(session);

    final document = await Document.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.publishedAt.notEquals(null) &
          t.documentType.equals(documentType) &
          t.isDefault.equals(true),
    );

    if (document == null) {
      throw Exception(
        'No default published document found for type "$documentType".',
      );
    }

    return _toPublicDocument(session, document);
  }

  /// Returns a single published document by type and slug.
  Future<PublicDocument> getContentBySlug(
    Session session,
    String documentType,
    String slug,
  ) async {
    final clientId = _requireReadAccess(session);

    final document = await Document.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.publishedAt.notEquals(null) &
          t.documentType.equals(documentType) &
          t.slug.equals(slug),
    );

    if (document == null) {
      throw Exception(
        'No published document found for type "$documentType" with slug "$slug".',
      );
    }

    return _toPublicDocument(session, document);
  }

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  /// Validates the API key has read access and returns the clientId.
  int? _requireReadAccess(Session session) {
    final apiKey = session.apiKey;
    if (apiKey == null) {
      throw Exception('Missing API key');
    }
    if (!apiKey.canRead) {
      throw Exception('API key does not have read permission.');
    }
    return apiKey.clientId;
  }

  Future<PublicDocument> _toPublicDocument(Session session, Document doc) async {
    final data = await _resolveImageReferences(session, doc.data ?? '{}');
    return PublicDocument(
      id: doc.id!,
      documentType: doc.documentType,
      title: doc.title,
      slug: doc.slug,
      isDefault: doc.isDefault,
      data: data,
      publishedAt: doc.publishedAt!,
      updatedAt: doc.updatedAt ?? DateTime.now(),
    );
  }

  /// Scans [dataJson] for imageReference nodes, batch-fetches their MediaAsset
  /// records, and inlines publicUrl/width/height/blurHash/lqip into each node.
  Future<String> _resolveImageReferences(
    Session session,
    String dataJson,
  ) async {
    final map = jsonDecode(dataJson) as Map<String, dynamic>;

    final assetIds = <String>{};
    _collectAssetIds(map, assetIds);
    if (assetIds.isEmpty) return dataJson;

    final assets = await MediaAsset.db.find(
      session,
      where: (t) => t.assetId.inSet(assetIds),
    );
    final assetMap = {for (final a in assets) a.assetId: a};

    _inlineAssets(map, assetMap);
    return jsonEncode(map);
  }

  /// Recursively collects assetId values from all imageReference nodes.
  void _collectAssetIds(dynamic node, Set<String> ids) {
    if (node is Map<String, dynamic>) {
      if (node['_type'] == 'imageReference') {
        final id = node['assetId'] as String?;
        if (id != null) ids.add(id);
      }
      for (final v in node.values) {
        _collectAssetIds(v, ids);
      }
    } else if (node is List) {
      for (final v in node) {
        _collectAssetIds(v, ids);
      }
    }
  }

  /// Recursively replaces imageReference nodes with inlined asset fields.
  void _inlineAssets(dynamic node, Map<String, MediaAsset> assetMap) {
    if (node is Map<String, dynamic>) {
      if (node['_type'] == 'imageReference') {
        final id = node['assetId'] as String?;
        final asset = id != null ? assetMap[id] : null;
        if (asset != null) {
          node['publicUrl'] = asset.publicUrl;
          node['width'] = asset.width;
          node['height'] = asset.height;
          node['blurHash'] = asset.blurHash;
          if (asset.lqip != null) node['lqip'] = asset.lqip;
        }
      }
      for (final v in node.values.toList()) {
        _inlineAssets(v, assetMap);
      }
    } else if (node is List) {
      for (final v in node) {
        _inlineAssets(v, assetMap);
      }
    }
  }
}
```

- [ ] **Step 4: Run the new tests to verify they pass**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_server
dart test test/integration/public_content_endpoint_test.dart --name "image reference resolution"
```

Expected: `All tests passed`

- [ ] **Step 5: Run the full integration test suite to catch regressions**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_server
dart test test/integration/public_content_endpoint_test.dart
```

Expected: All existing tests still pass

- [ ] **Step 6: Commit**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be
git add dart_desk_server/lib/src/endpoints/public_content_endpoint.dart dart_desk_server/test/integration/public_content_endpoint_test.dart
git commit -m "feat(dart_desk_be): resolve imageReference nodes in PublicContentEndpoint"
```

---

## Task 5: Migrate `HomeScreenConfig` to `ImageUrl`

**Files:**
- Modify: `examples/data_models/pubspec.yaml`
- Modify: `examples/data_models/lib/src/configs/home_screen_config.dart`
- Regenerate: `examples/data_models/lib/src/configs/home_screen_config.cms.g.dart`
- Regenerate: `examples/data_models/lib/src/configs/home_screen_config.mapper.dart`
- Modify: `examples/example_app/lib/screens/homes_creen.dart`

- [ ] **Step 1: Add `dart_desk` dependency to `data_models`**

In `examples/data_models/pubspec.yaml`, add `dart_desk` under `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  dart_desk_annotation:
    git:
      url: https://github.com/ThangVuNguyenViet/dart_desk.git
      path: packages/dart_desk_annotation
  dart_desk:
    path: ../../packages/dart_desk
  dart_mappable: ^4.6.1
  shadcn_ui: ^0.52.1
```

Run pub get:

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
flutter pub get
```

Expected: Resolves without errors

- [ ] **Step 2: Update `HomeScreenConfig` field types**

In `examples/data_models/lib/src/configs/home_screen_config.dart`:

1. Add import at the top (after existing imports):
```dart
import 'package:dart_desk/dart_desk.dart' show ImageUrl, ImageUrlMapper;
```

2. Change `@MappableClass` to include `ImageUrlMapper`:
```dart
@MappableClass(ignoreNull: false, includeCustomMappers: [ColorMapper(), ImageUrlMapper()])
```

3. Replace the `backgroundImageUrl` field:
```dart
  // Before:
  // final String backgroundImageUrl;

  // After:
  @CmsImageFieldConfig(
    description: 'Background image for the hero section',
    option: CmsImageOption(hotspot: false),
  )
  final ImageUrl? backgroundImage;
```

4. Replace the `footerLogoUrl` field:
```dart
  // Before:
  // final String? footerLogoUrl;

  // After:
  @CmsImageFieldConfig(
    description: 'Logo image shown in the footer',
    option: CmsImageOption(hotspot: false),
  )
  final ImageUrl? footerLogo;
```

5. Update the constructor — replace `required this.backgroundImageUrl` with `this.backgroundImage` and `this.footerLogoUrl` with `this.footerLogo`:
```dart
  const HomeScreenConfig({
    required this.heroTitle,
    required this.heroSubtitle,
    this.backgroundImage,
    required this.enableDarkOverlay,
    required this.primaryColor,
    required this.accentColor,
    required this.featuredItems,
    required this.maxFeaturedItems,
    required this.heroOverlayOpacity,
    required this.showPromotionalBanner,
    required this.bannerHeadline,
    required this.bannerBody,
    this.promoStartDate,
    this.promoEndDate,
    required this.lastUpdated,
    this.externalLink,
    this.downloadableResource,
    this.footerLogo,
    required this.primaryButtonLabel,
    this.primaryButtonUrl,
    required this.secondaryButtonLabel,
    required this.layoutStyle,
    required this.contentPadding,
    required this.gridColumns,
    required this.showFooter,
    this.metaTitle,
    this.metaDescription,
  });
```

6. Update `defaultValue` — replace image fields with `null`:
```dart
    backgroundImage: null,
    // ...
    footerLogo: null,
```

- [ ] **Step 3: Regenerate code**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/examples/data_models
dart run build_runner build --delete-conflicting-outputs
```

Expected: Generates updated `home_screen_config.cms.g.dart` and `home_screen_config.mapper.dart` with `CmsData<ImageUrl?>` for image fields

- [ ] **Step 4: Update `HomeScreen` widget to use new field names**

In `examples/example_app/lib/screens/homes_creen.dart`:

Replace the hero background image section in `_buildHeroSection` (around line 120):
```dart
    // Before:
    // if (config.backgroundImageUrl.isNotEmpty)
    //   Image.network(config.backgroundImageUrl, ...)

    // After:
    if (config.backgroundImage != null)
      Image.network(
        config.backgroundImage!.url(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildHeroFallbackBackground(),
      )
```

Replace the footer logo section in `_buildFooter` (around line 593):
```dart
    // Before:
    // if (config.footerLogoUrl != null && config.footerLogoUrl!.isNotEmpty) ...[
    //   Image.network(config.footerLogoUrl!, ...)

    // After:
    if (config.footerLogo != null) ...[
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          config.footerLogo!.url(),
          height: 40,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
      const SizedBox(height: 16),
    ],
```

- [ ] **Step 5: Verify both example packages compile**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
flutter analyze examples/data_models/lib/ examples/example_app/lib/
```

Expected: `No issues found`

- [ ] **Step 6: Commit**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
git add examples/data_models/pubspec.yaml \
  examples/data_models/lib/src/configs/home_screen_config.dart \
  examples/data_models/lib/src/configs/home_screen_config.cms.g.dart \
  examples/data_models/lib/src/configs/home_screen_config.mapper.dart \
  examples/example_app/lib/screens/homes_creen.dart
git commit -m "feat(examples): migrate HomeScreenConfig image fields to ImageUrl"
```

---

## Self-Review Notes

- **Spec section 1 (resolved JSON):** Covered in Task 4 (`_inlineAssets` adds `publicUrl`, `width`, `height`, `blurHash`, `lqip`)
- **Spec section 2 (`ImageUrl` type):** Covered in Tasks 2, 3, 5 (`fromJson`, `withTransform`, `ImageUrlMapper`, `HomeScreenConfig`)
- **Spec section 3 (backend resolver):** Covered in Task 4 (all 5 endpoint methods, batch query)
- **Spec section 4 (codegen):** `CmsConfigGenerator` auto-generates `CmsData<ImageUrl?>` from field type — no generator change needed. `ImageUrlMapper` created in Task 3.
- **`MediaAsset.fromInlineJson`:** Defined in Task 1; used in `ImageUrl.fromJson` (Task 2) — types match.
- **`ImageUrl.imageRef`:** Made accessible in tests — verify `imageRef` is not private. Current code uses `final ImageReference imageRef` (public) ✓
