# Unified ImageReference Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unify `ImageRef` and `ImageReference` into a single `ImageReference` class in `dart_desk_annotation`, update `ImageUrl` to wrap it, and demonstrate both usage patterns in the example app.

**Architecture:** Move `Hotspot`, `CropRect`, and the unified `ImageReference` to `dart_desk_annotation` (pure Dart, no Flutter). `ImageUrl` stays in `dart_desk` as a CDN transform wrapper. Both serialize to the same `{ "_type": "imageReference", ... }` wire format. The CMS editor (`image_input.dart`) switches from constructing `ImageReference(asset: mediaAsset)` to constructing `ImageReference(assetId: ..., publicUrl: ...)` and holding `MediaAsset` separately.

**Tech Stack:** Dart, dart_mappable, dart_desk_annotation, dart_desk, build_runner

**Spec:** `docs/superpowers/specs/2026-04-02-unified-image-reference-design.md`

---

### Task 1: Move `Hotspot` and `CropRect` to `dart_desk_annotation`

**Files:**
- Create: `packages/dart_desk_annotation/lib/src/models/image_types.dart`
- Modify: `packages/dart_desk/lib/src/data/models/image_types.dart`
- Modify: `packages/dart_desk_annotation/lib/dart_desk_annotation.dart`

- [ ] **Step 1: Create `image_types.dart` in annotation package**

```dart
// packages/dart_desk_annotation/lib/src/models/image_types.dart

class Hotspot {
  final double x, y, width, height;
  const Hotspot({required this.x, required this.y, required this.width, required this.height});
  factory Hotspot.fromJson(Map<String, dynamic> json) => Hotspot(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    width: (json['width'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
  );
  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'width': width, 'height': height};
  Hotspot copyWith({double? x, double? y, double? width, double? height}) =>
      Hotspot(x: x ?? this.x, y: y ?? this.y, width: width ?? this.width, height: height ?? this.height);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hotspot &&
          x == other.x && y == other.y && width == other.width && height == other.height;

  @override
  int get hashCode => Object.hash(x, y, width, height);
}

class CropRect {
  final double top, bottom, left, right;
  const CropRect({required this.top, required this.bottom, required this.left, required this.right});
  factory CropRect.fromJson(Map<String, dynamic> json) => CropRect(
    top: (json['top'] as num).toDouble(),
    bottom: (json['bottom'] as num).toDouble(),
    left: (json['left'] as num).toDouble(),
    right: (json['right'] as num).toDouble(),
  );
  Map<String, dynamic> toJson() => {'top': top, 'bottom': bottom, 'left': left, 'right': right};
}
```

- [ ] **Step 2: Export from annotation barrel**

In `packages/dart_desk_annotation/lib/dart_desk_annotation.dart`, add after line 21 (`export 'src/models/image_ref.dart'`):

```dart
export 'src/models/image_types.dart';
```

- [ ] **Step 3: Replace `Hotspot`/`CropRect` in dart_desk with re-exports**

In `packages/dart_desk/lib/src/data/models/image_types.dart`, remove the `Hotspot` and `CropRect` class definitions (lines 9–33) and add a re-export at the top:

```dart
export 'package:dart_desk_annotation/src/models/image_types.dart';
```

Keep all other types in this file (`FitMode`, `MediaAssetMetadataStatus`, `PaletteColor`, `MediaPalette`, etc.) unchanged.

- [ ] **Step 4: Verify compilation**

Run: `cd packages/dart_desk && dart analyze`
Expected: No errors related to Hotspot/CropRect (all imports resolve through the same barrel).

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk_annotation/lib/src/models/image_types.dart \
        packages/dart_desk_annotation/lib/dart_desk_annotation.dart \
        packages/dart_desk/lib/src/data/models/image_types.dart
git commit -m "refactor: move Hotspot and CropRect to dart_desk_annotation"
```

---

### Task 2: Create unified `ImageReference` in `dart_desk_annotation`

**Files:**
- Modify: `packages/dart_desk_annotation/lib/src/models/image_ref.dart` (rewrite → `ImageReference`)
- Modify: `packages/dart_desk_annotation/lib/dart_desk_annotation.dart`
- Modify: `packages/dart_desk_annotation/lib/src/fields/media/image_field.dart`

- [ ] **Step 1: Rewrite `image_ref.dart` as unified `ImageReference`**

Replace the entire contents of `packages/dart_desk_annotation/lib/src/models/image_ref.dart` with:

```dart
import 'image_types.dart';

/// Unified image reference for dart_desk.
///
/// Handles both stored format (assetId only) and server-resolved format
/// (assetId + publicUrl + dimensions + blurHash). Auto-detects which format
/// when deserializing via [fromMap].
///
/// Serialised as `{ '_type': 'imageReference', 'assetId': '...' }` (stored)
/// or with additional resolved fields (publicUrl, width, height, blurHash, lqip).
///
/// For CDN transform support, wrap in [ImageUrl] from `package:dart_desk`.
class ImageReference {
  final String? assetId;
  final String? externalUrl;
  final String? publicUrl;
  final int? width;
  final int? height;
  final String? blurHash;
  final String? lqip;
  final Hotspot? hotspot;
  final CropRect? crop;
  final String? altText;

  const ImageReference({
    this.assetId,
    this.externalUrl,
    this.publicUrl,
    this.width,
    this.height,
    this.blurHash,
    this.lqip,
    this.hotspot,
    this.crop,
    this.altText,
  });

  /// Auto-detects stored vs resolved format.
  ///
  /// Stored format: `{ _type, assetId, hotspot?, crop?, altText? }`
  /// Resolved format: stored + `publicUrl, width, height, blurHash, lqip?`
  /// External URL: `{ _type, externalUrl }`
  factory ImageReference.fromMap(Map<String, dynamic> map) => ImageReference(
    assetId: map['assetId'] as String?,
    externalUrl: map['externalUrl'] as String?,
    publicUrl: map['publicUrl'] as String?,
    width: map['width'] as int?,
    height: map['height'] as int?,
    blurHash: map['blurHash'] as String?,
    lqip: map['lqip'] as String?,
    hotspot: map['hotspot'] != null
        ? Hotspot.fromJson(map['hotspot'] as Map<String, dynamic>)
        : null,
    crop: map['crop'] != null
        ? CropRect.fromJson(map['crop'] as Map<String, dynamic>)
        : null,
    altText: map['altText'] as String?,
  );

  /// Always outputs stored format — no publicUrl/width/height/blurHash/lqip.
  /// These transient fields are added by the server at resolution time.
  Map<String, dynamic> toMap() => {
    '_type': 'imageReference',
    if (assetId != null) 'assetId': assetId,
    if (externalUrl != null) 'externalUrl': externalUrl,
    if (hotspot != null) 'hotspot': hotspot!.toJson(),
    if (crop != null) 'crop': crop!.toJson(),
    if (altText != null) 'altText': altText,
  };

  static bool isImageReference(Map<String, dynamic> map) =>
      map['_type'] == 'imageReference';

  /// Default resolver used by [url]. Set once at app startup so that
  /// asset-ID-based refs resolve without passing a resolver every time.
  ///
  /// Example:
  /// ```dart
  /// ImageReference.defaultAssetResolver = (id) => '${serverUrl}files/$id';
  /// ```
  static String Function(String assetId)? defaultAssetResolver;

  /// Returns the best available URL for this image.
  ///
  /// Priority: publicUrl (server-resolved) > externalUrl > defaultAssetResolver(assetId).
  String? get url {
    if (publicUrl != null) return publicUrl;
    if (externalUrl != null) return externalUrl;
    if (assetId != null) return defaultAssetResolver?.call(assetId!);
    return null;
  }

  /// Resolves URL using an explicit [assetResolver] instead of [defaultAssetResolver].
  String? resolveUrl(String Function(String assetId) assetResolver) {
    if (publicUrl != null) return publicUrl;
    if (externalUrl != null) return externalUrl;
    if (assetId != null) return assetResolver(assetId!);
    return null;
  }

  ImageReference copyWith({
    String? assetId,
    String? externalUrl,
    String? publicUrl,
    int? width,
    int? height,
    String? blurHash,
    String? lqip,
    Hotspot? hotspot,
    CropRect? crop,
    String? altText,
  }) => ImageReference(
    assetId: assetId ?? this.assetId,
    externalUrl: externalUrl ?? this.externalUrl,
    publicUrl: publicUrl ?? this.publicUrl,
    width: width ?? this.width,
    height: height ?? this.height,
    blurHash: blurHash ?? this.blurHash,
    lqip: lqip ?? this.lqip,
    hotspot: hotspot ?? this.hotspot,
    crop: crop ?? this.crop,
    altText: altText ?? this.altText,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageReference &&
          runtimeType == other.runtimeType &&
          assetId == other.assetId &&
          externalUrl == other.externalUrl &&
          publicUrl == other.publicUrl &&
          hotspot == other.hotspot &&
          crop == other.crop &&
          altText == other.altText;

  @override
  int get hashCode => Object.hash(assetId, externalUrl, publicUrl, hotspot, crop, altText);

  @override
  String toString() =>
      'ImageReference(assetId: $assetId, externalUrl: $externalUrl, publicUrl: $publicUrl)';
}

/// Deprecated. Use [ImageReference] instead.
@Deprecated('Use ImageReference instead')
typedef ImageRef = ImageReference;
```

- [ ] **Step 2: Update `DeskImage.supportedFieldTypes`**

In `packages/dart_desk_annotation/lib/src/fields/media/image_field.dart`, change the import and supported types:

Replace:
```dart
import '../../models/image_ref.dart';
```
With:
```dart
import '../../models/image_ref.dart';
```
(Import stays the same since the file is the same path.)

Replace line 38:
```dart
  List<Type> get supportedFieldTypes => [Object, ImageRef]; // Map (ImageReference), ImageRef, or Object
```
With:
```dart
  List<Type> get supportedFieldTypes => [Object, ImageReference];
```

- [ ] **Step 3: Verify annotation package compiles**

Run: `cd packages/dart_desk_annotation && dart analyze`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk_annotation/lib/src/models/image_ref.dart \
        packages/dart_desk_annotation/lib/src/fields/media/image_field.dart
git commit -m "refactor: unify ImageRef and ImageReference into single ImageReference in annotation package"
```

---

### Task 3: Create `ImageReferenceMapper` in `dart_desk_annotation`

**Files:**
- Create: `packages/dart_desk_annotation/lib/src/models/image_reference_mapper.dart`
- Modify: `packages/dart_desk_annotation/lib/dart_desk_annotation.dart`

- [ ] **Step 1: Create the mapper**

```dart
// packages/dart_desk_annotation/lib/src/models/image_reference_mapper.dart
import 'package:dart_mappable/dart_mappable.dart';

import 'image_ref.dart';

/// A [dart_mappable] custom mapper for [ImageReference].
///
/// Decodes both stored and resolved imageReference JSON → [ImageReference].
/// Encodes [ImageReference] → stored format (assetId + framing, no publicUrl).
///
/// Usage:
/// ```dart
/// @MappableClass(includeCustomMappers: [ImageReferenceMapper()])
/// class MyConfig with MyConfigMappable { ... }
/// ```
class ImageReferenceMapper extends SimpleMapper<ImageReference> {
  const ImageReferenceMapper();

  @override
  ImageReference decode(Object value) =>
      ImageReference.fromMap(value as Map<String, dynamic>);

  @override
  Object encode(ImageReference self) => self.toMap();
}
```

- [ ] **Step 2: Export from annotation barrel**

In `packages/dart_desk_annotation/lib/dart_desk_annotation.dart`, add after the `image_ref.dart` export:

```dart
export 'src/models/image_reference_mapper.dart';
```

- [ ] **Step 3: Verify**

Run: `cd packages/dart_desk_annotation && dart analyze`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk_annotation/lib/src/models/image_reference_mapper.dart \
        packages/dart_desk_annotation/lib/dart_desk_annotation.dart
git commit -m "feat: add ImageReferenceMapper for dart_mappable"
```

---

### Task 4: Update `ImageUrl` and `ImageUrlMapper` in `dart_desk`

**Files:**
- Modify: `packages/dart_desk/lib/src/media/image_url.dart`
- Modify: `packages/dart_desk/lib/src/media/image_url_mapper.dart`
- Modify: `packages/dart_desk/lib/src/media/image_transform_params.dart`

The key change: `ImageUrl` no longer wraps `ImageReference` from `dart_desk` (which held `MediaAsset`). It now wraps `ImageReference` from `dart_desk_annotation` (which holds fields directly). The `url()` method reads `imageRef.url` as base URL instead of `imageRef.asset.publicUrl`.

- [ ] **Step 1: Update `image_url.dart`**

Replace entire file:

```dart
// packages/dart_desk/lib/src/media/image_url.dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

import 'image_transform_params.dart';

typedef TransformUrlBuilder = String Function(
    String publicUrl, ImageTransformParams params);

/// CDN transform wrapper around [ImageReference].
///
/// Adds `url()` method with width/height/format/quality params that delegates
/// to a pluggable [TransformUrlBuilder]. Without a transform, returns the
/// raw URL from the underlying [ImageReference].
///
/// Both [ImageUrl] and [ImageReference] serialize to the same wire format.
/// You can switch between them without data migration.
class ImageUrl {
  final ImageReference imageRef;
  final TransformUrlBuilder? _transformUrl;

  const ImageUrl({required this.imageRef, TransformUrlBuilder? transformUrl})
      : _transformUrl = transformUrl;

  /// Decodes a stored or resolved imageReference JSON node into an [ImageUrl].
  factory ImageUrl.fromMap(Map<String, dynamic> map) =>
      ImageUrl(imageRef: ImageReference.fromMap(map));

  /// Returns a new [ImageUrl] with the given [builder] applied to [url].
  ImageUrl withTransform(TransformUrlBuilder builder) =>
      ImageUrl(imageRef: imageRef, transformUrl: builder);

  /// Returns a (optionally transformed) URL for this image.
  ///
  /// If a [TransformUrlBuilder] is set, builds transform params from the
  /// arguments and the image's hotspot/crop data, then delegates to the builder.
  /// Otherwise returns the raw URL from [imageRef].
  String? url({
    int? width,
    int? height,
    FitMode? fit,
    String? format,
    int? quality,
  }) {
    final baseUrl = imageRef.url;
    if (baseUrl == null) return null;
    if (_transformUrl == null) return baseUrl;
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
    return _transformUrl(baseUrl, params);
  }

  /// Outputs stored format — identical to [imageRef.toMap()].
  Map<String, dynamic> toMap() => imageRef.toMap();

  String? get blurHash => imageRef.blurHash;
  String? get lqip => imageRef.lqip;
  int? get width => imageRef.width;
  int? get height => imageRef.height;
}
```

- [ ] **Step 2: Update `image_url_mapper.dart`**

Replace entire file:

```dart
// packages/dart_desk/lib/src/media/image_url_mapper.dart
import 'package:dart_mappable/dart_mappable.dart';

import 'image_url.dart';

/// A [dart_mappable] custom mapper for [ImageUrl].
///
/// Decodes a stored or resolved imageReference JSON map → [ImageUrl].
/// Encodes [ImageUrl] → stored format (assetId + framing, no publicUrl).
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
      ImageUrl.fromMap(value as Map<String, dynamic>);

  @override
  Object encode(ImageUrl self) => self.toMap();
}
```

- [ ] **Step 3: Update `image_transform_params.dart`**

Replace import:

```dart
// packages/dart_desk/lib/src/media/image_transform_params.dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

class ImageTransformParams {
  final int? width;
  final int? height;
  final FitMode? fit;
  final String? format;
  final int? quality;
  final double? fpX;
  final double? fpY;
  final CropRect? crop;

  const ImageTransformParams({
    this.width,
    this.height,
    this.fit,
    this.format,
    this.quality,
    this.fpX,
    this.fpY,
    this.crop,
  });
}
```

Note: `FitMode` stays in `packages/dart_desk/lib/src/data/models/image_types.dart` (it's a CDN concept, not an annotation concept). The import of `CropRect` now comes from the annotation package via the barrel export.

Wait — `FitMode` is used by `ImageTransformParams` which is in dart_desk. And `image_transform_params.dart` currently imports from `../data/models/image_types.dart`. Since `FitMode` stays in dart_desk's `image_types.dart`, the import should be:

```dart
import '../data/models/image_types.dart';
```

Keep the original import unchanged. Only `CropRect` moved (via re-export from the same file), so no import change is needed.

- [ ] **Step 4: Verify**

Run: `cd packages/dart_desk && dart analyze`
Expected: Errors in files still referencing old `ImageReference` from `dart_desk` — expected, will fix in Task 5.

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk/lib/src/media/image_url.dart \
        packages/dart_desk/lib/src/media/image_url_mapper.dart \
        packages/dart_desk/lib/src/media/image_transform_params.dart
git commit -m "refactor: update ImageUrl to wrap annotation-layer ImageReference"
```

---

### Task 5: Update `ImageReference` in `dart_desk` to re-export + bridge

**Files:**
- Modify: `packages/dart_desk/lib/src/data/models/image_reference.dart`
- Modify: `packages/dart_desk/lib/src/data/data.dart`

The old `ImageReference` in dart_desk held a `MediaAsset`. It's used extensively by the CMS editor. We replace it with a re-export of the annotation `ImageReference`, plus a helper to bridge between `MediaAsset` and `ImageReference`.

- [ ] **Step 1: Rewrite `image_reference.dart`**

Replace entire file:

```dart
// packages/dart_desk/lib/src/data/models/image_reference.dart

// Re-export the unified ImageReference from the annotation package.
// All consumer code should use this type.
export 'package:dart_desk_annotation/src/models/image_ref.dart';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'media_asset.dart';

/// Extension to bridge between [MediaAsset] (CMS-internal) and [ImageReference].
extension ImageReferenceFromAsset on ImageReference {
  /// Creates an [ImageReference] populated with resolved fields from a [MediaAsset].
  static ImageReference fromAsset(
    MediaAsset asset, {
    Hotspot? hotspot,
    CropRect? crop,
    String? altText,
  }) =>
      ImageReference(
        assetId: asset.assetId,
        publicUrl: asset.publicUrl,
        width: asset.width,
        height: asset.height,
        blurHash: asset.blurHash,
        lqip: asset.lqip,
        hotspot: hotspot,
        crop: crop,
        altText: altText,
      );
}
```

- [ ] **Step 2: Verify data.dart exports still work**

`packages/dart_desk/lib/src/data/data.dart` line 36 already has:
```dart
export 'models/image_reference.dart';
```

This now re-exports the annotation `ImageReference` — all downstream imports resolve correctly.

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/lib/src/data/models/image_reference.dart
git commit -m "refactor: replace dart_desk ImageReference with re-export + MediaAsset bridge"
```

---

### Task 6: Update CMS editor (`image_input.dart`)

**Files:**
- Modify: `packages/dart_desk/lib/src/inputs/image_input.dart`

The editor currently constructs `ImageReference(asset: mediaAsset, ...)`. After the refactor, it uses `ImageReferenceFromAsset.fromAsset(mediaAsset, ...)`.

- [ ] **Step 1: Update imports**

Remove:
```dart
import '../data/models/image_reference.dart';
import '../data/models/image_types.dart';
import '../media/image_transform_params.dart';
import '../media/image_url.dart';
```

Add:
```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import '../data/models/image_reference.dart'; // for ImageReferenceFromAsset extension
import '../data/models/image_types.dart'; // for FitMode, MediaAssetMetadataStatus etc.
import '../data/models/media_asset.dart';
```

- [ ] **Step 2: Replace `ImageReference(asset: ...)` calls with `ImageReferenceFromAsset.fromAsset(...)`**

Search for all occurrences of `ImageReference(asset:` in the file and replace with `ImageReferenceFromAsset.fromAsset(`. For example:

Old (line ~209):
```dart
final imageRef = ImageReference(asset: asset);
```
New:
```dart
final imageRef = ImageReferenceFromAsset.fromAsset(asset);
```

Old (line ~315, from media browser):
```dart
final imageRef = ImageReference(asset: asset);
```
New:
```dart
final imageRef = ImageReferenceFromAsset.fromAsset(asset);
```

- [ ] **Step 3: Replace `ImageReference.fromDocumentJson(json, asset)` calls**

Old (line ~107-121 area):
```dart
final imageRef = ImageReference.fromDocumentJson(json, asset);
```
New:
```dart
final imageRef = ImageReferenceFromAsset.fromAsset(
  asset,
  hotspot: json['hotspot'] != null ? Hotspot.fromJson(json['hotspot'] as Map<String, dynamic>) : null,
  crop: json['crop'] != null ? CropRect.fromJson(json['crop'] as Map<String, dynamic>) : null,
  altText: json['altText'] as String?,
);
```

- [ ] **Step 4: Replace `imageRef.toDocumentJson()` with `imageRef.toMap()`**

Search for `.toDocumentJson()` and replace with `.toMap()`.

- [ ] **Step 5: Replace `ImageRef(externalUrl: value).toMap()` with `ImageReference(externalUrl: value).toMap()`**

Line ~735:
Old:
```dart
ImageRef(externalUrl: value).toMap()
```
New:
```dart
ImageReference(externalUrl: value).toMap()
```

- [ ] **Step 6: Replace `ImageReference.isImageReference` checks if needed**

These should still work — `ImageReference.isImageReference(map)` exists on the unified type.

- [ ] **Step 7: Verify**

Run: `cd packages/dart_desk && dart analyze`
Expected: Remaining errors may be in other files (hotspot editors, framing code) — addressed in Task 7.

- [ ] **Step 8: Commit**

```bash
git add packages/dart_desk/lib/src/inputs/image_input.dart
git commit -m "refactor: update CMS image input to use unified ImageReference"
```

---

### Task 7: Update hotspot/framing code

**Files:**
- Modify: `packages/dart_desk/lib/src/inputs/hotspot/framing_controller.dart`
- Modify: `packages/dart_desk/lib/src/inputs/hotspot/framing_math.dart`
- Modify: `packages/dart_desk/lib/src/inputs/hotspot/framing_status.dart`
- Modify: `packages/dart_desk/lib/src/inputs/hotspot/image_hotspot_editor.dart`
- Modify: `packages/dart_desk/lib/src/inputs/hotspot/hotspot_painter.dart`
- Modify: `packages/dart_desk/lib/src/inputs/hotspot/aspect_ratio_preview.dart`
- Modify: `packages/dart_desk/lib/src/inputs/hotspot/crop_overlay_painter.dart`

These files import `Hotspot` and `CropRect` from `../data/models/image_types.dart`. Since that file now re-exports from the annotation package, the imports should still resolve. No code changes needed unless there are direct `ImageReference(asset:)` calls.

- [ ] **Step 1: Check `framing_status.dart`**

This has `static String labelFor(ImageReference ref)` — it accesses `ref.hotspot` and `ref.crop`. Both exist on the unified `ImageReference`. The import of `ImageReference` comes through `../../data/models/image_reference.dart` which now re-exports the annotation type. Should work.

Verify: Read the file and check if it imports `ImageReference` directly or via barrel.

- [ ] **Step 2: Run analysis to catch any remaining issues**

Run: `cd packages/dart_desk && dart analyze`

Fix any errors found. The most likely issue is files that import `ImageReference` and access `.asset` — search for `.asset` usage:

```bash
grep -r '\.asset' packages/dart_desk/lib/src/inputs/hotspot/ --include='*.dart'
```

- [ ] **Step 3: Commit if changes were needed**

```bash
git add packages/dart_desk/lib/src/inputs/hotspot/
git commit -m "refactor: update hotspot code for unified ImageReference"
```

---

### Task 8: Update `dart_desk_app.dart` resolver

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/dart_desk_app.dart`

- [ ] **Step 1: Replace `ImageRef.defaultAssetResolver` with `ImageReference.defaultAssetResolver`**

Line 82:
Old:
```dart
ImageRef.defaultAssetResolver = (id) => '${_serverUrl}files/$id';
```
New:
```dart
ImageReference.defaultAssetResolver = (id) => '${_serverUrl}files/$id';
```

Since `ImageRef` is now a deprecated typedef for `ImageReference`, the old code would still compile, but update it for clarity.

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/lib/src/studio/dart_desk_app.dart
git commit -m "refactor: use ImageReference.defaultAssetResolver"
```

---

### Task 9: Update dart_desk barrel exports

**Files:**
- Modify: `packages/dart_desk/lib/dart_desk.dart`

- [ ] **Step 1: Add `image_transform_params.dart` export if not already present**

The barrel already exports `image_url.dart` and `image_url_mapper.dart`. `ImageReference` comes through the annotation re-export on line 33. Verify no duplicate exports of `ImageReference`:

Line 33: `export 'package:dart_desk_annotation/dart_desk_annotation.dart';` — this exports `ImageReference`, `ImageReferenceMapper`, `Hotspot`, `CropRect`.

Line 36: `export 'src/data/data.dart';` — data.dart exports `models/image_reference.dart` which re-exports the annotation `ImageReference`.

This creates a duplicate export. Fix by removing the re-export from `data.dart`:

In `packages/dart_desk/lib/src/data/data.dart`, change line 36:
```dart
export 'models/image_reference.dart';
```
To:
```dart
// ImageReference is exported via dart_desk_annotation barrel.
// This file provides the ImageReferenceFromAsset extension.
export 'models/image_reference.dart' show ImageReferenceFromAsset;
```

Wait — `ImageReferenceFromAsset` is an extension, and extensions need to be explicitly imported to be used. Since only internal CMS code uses it, this is fine. Consumer code only needs `ImageReference` from the annotation barrel.

- [ ] **Step 2: Verify no duplicate symbol exports**

Run: `cd packages/dart_desk && dart analyze`
Expected: No "ambiguous export" warnings.

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/lib/dart_desk.dart \
        packages/dart_desk/lib/src/data/data.dart
git commit -m "refactor: clean up barrel exports for unified ImageReference"
```

---

### Task 10: Update example data models

**Files:**
- Modify: `examples/data_models/lib/src/configs/storefront_config.dart`
- Modify: `examples/data_models/lib/src/configs/menu_highlight.dart`
- Modify: `examples/data_models/lib/src/configs/promo_offer.dart`
- Modify: `examples/data_models/lib/src/configs/delivery_settings.dart`
- Modify: `examples/data_models/lib/src/configs/app_theme.dart`
- Modify: `examples/data_models/lib/example_data.dart`

**Pattern 1 models** (ImageReference only): `StorefrontConfig`, `MenuHighlight`, `PromoOffer`, `DeliverySettings`
**Pattern 2 model** (ImageUrl with CDN): `AppTheme`

- [ ] **Step 1: Update `storefront_config.dart` — Pattern 1**

Replace `ImageUrlMapper` with `ImageReferenceMapper` in the import and `@MappableClass`. Keep `ImageReference?` field types (they now resolve to the annotation type). Remove the `ImageUrlMapper` import.

Change import:
```dart
import 'package:dart_desk/dart_desk.dart';
```
This already provides `ImageReference`, `ImageReferenceMapper` (via annotation re-export).

Change `@MappableClass`:
```dart
@MappableClass(
  ignoreNull: false,
  includeCustomMappers: [StorefrontColorMapper(), ImageReferenceMapper()],
)
```

The `ImageReference?` field types (`heroImage`, `logo`) stay the same.

In preview widget (`storefront_preview.dart`), image access changes:
Old: `config.heroImage!.url()` (this was `ImageUrl.url()`)
New: `config.heroImage!.url!` (this is `ImageReference.url` getter)

Wait — check the current storefront_config.dart. It uses `ImageReference?` as field type. With `ImageUrlMapper`, the mapper decodes JSON into `ImageUrl`, but the field type is `ImageReference` — that's a type mismatch. Let me re-read the file.

Looking at the file from context: storefront_config.dart line 14 has `includeCustomMappers: [StorefrontColorMapper()]` — no `ImageUrlMapper`. And field types are `ImageReference?`. So currently the mapper doesn't handle `ImageReference` at all — `dart_mappable` would try to decode it as a plain object and likely fail or use a default.

With the unified `ImageReference` having `fromMap`/`toMap`, adding `ImageReferenceMapper()` to `includeCustomMappers` will properly handle the serialization.

Update `storefront_config.dart`:
```dart
@MappableClass(
  ignoreNull: false,
  includeCustomMappers: [StorefrontColorMapper(), ImageReferenceMapper()],
)
```

- [ ] **Step 2: Update `menu_highlight.dart` — Pattern 1**

Change import show clause:
Old: `show ImageUrlMapper, ImageReference`
New: `show ImageReferenceMapper, ImageReference`

Change `@MappableClass`:
Old: `includeCustomMappers: [ImageUrlMapper()]`
New: `includeCustomMappers: [ImageReferenceMapper()]`

Field type `ImageReference? photo` stays the same.

- [ ] **Step 3: Update `promo_offer.dart` — Pattern 1**

Change import show clause:
Old: `show ImageUrl, ImageUrlMapper, ImageReference`
New: `show ImageReferenceMapper, ImageReference`

Change `@MappableClass`:
Old: `includeCustomMappers: [ColorMapper(), ImageUrlMapper()]`
New: `includeCustomMappers: [ColorMapper(), ImageReferenceMapper()]`

Field type `ImageReference? bannerImage` stays the same.

- [ ] **Step 4: Update `delivery_settings.dart` — Pattern 1**

Change import show clause:
Old: `show ImageUrl, ImageUrlMapper`
New: `show ImageReferenceMapper, ImageReference`

Change `@MappableClass`:
Old: `includeCustomMappers: [ImageUrlMapper()]`
New: `includeCustomMappers: [ImageReferenceMapper()]`

Check if any fields use `ImageUrl` type — if so, change to `ImageReference?`.

- [ ] **Step 5: Update `app_theme.dart` — Pattern 2 (ImageUrl with CDN)**

This model demonstrates the CDN transform pattern. Keep `ImageUrl` for the image fields.

Change import show clause:
Old: `show ImageUrl, ImageUrlMapper, ImageReference`
New: `show ImageUrl, ImageUrlMapper`

`@MappableClass` stays: `includeCustomMappers: [ColorMapper(), ImageUrlMapper()]`

Change field types from `ImageReference?` to `ImageUrl?`:
```dart
final ImageUrl? logoLight;
final ImageUrl? logoDark;
final ImageUrl? appIcon;
```

Update the constructor and `defaultValue` accordingly — `null` values remain `null`.

- [ ] **Step 6: Update `example_data.dart` barrel**

Ensure the barrel doesn't need to hide `ImageReferenceMapper` (it shouldn't conflict). Remove any `hide ImageUrlMapper` if present.

- [ ] **Step 7: Run code generation**

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs
```

This regenerates all `.desk.dart` and `.mapper.dart` files with the updated types.

- [ ] **Step 8: Verify**

Run: `cd examples/data_models && dart analyze`
Expected: No errors.

- [ ] **Step 9: Commit**

```bash
git add examples/data_models/
git commit -m "refactor: update example data models to use unified ImageReference"
```

---

### Task 11: Update example preview widgets

**Files:**
- Modify: `examples/example_app/lib/screens/storefront_preview.dart`
- Modify: `examples/example_app/lib/screens/menu_highlight_card.dart`
- Modify: `examples/example_app/lib/screens/promo_offer_banner.dart`
- Modify: `examples/example_app/lib/screens/app_theme_preview.dart`
- Modify: `examples/example_app/lib/screens/delivery_settings_view.dart`

- [ ] **Step 1: Update Pattern 1 widgets — use `imageRef.url!`**

In `storefront_preview.dart`, `menu_highlight_card.dart`, `promo_offer_banner.dart`:

Any `config.someImage!.url()` calls become `config.someImage!.url!` (getter, not method).

Any `Image.network(config.heroImage!.url())` becomes `Image.network(config.heroImage!.url!)`.

Search each file for `.url()` on image fields and replace with `.url!`.

- [ ] **Step 2: Update Pattern 2 widget (`app_theme_preview.dart`) — use `imageUrl.url()`**

With `AppTheme` fields now typed as `ImageUrl?`, access is:
```dart
config.logoLight!.url(width: 200, format: 'webp')!
```

This demonstrates CDN-aware responsive loading. Add a comment in the widget:
```dart
// ImageUrl.url() supports CDN transforms (width, height, format, quality).
// Without a TransformUrlBuilder configured, returns the raw URL.
Image.network(config.logoLight!.url(width: 200, format: 'webp')!)
```

- [ ] **Step 3: Verify**

Run: `cd examples/example_app && flutter analyze`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add examples/example_app/
git commit -m "refactor: update preview widgets for unified ImageReference"
```

---

### Task 12: Update CMS app wiring

**Files:**
- Modify: `examples/desk_app/lib/document_types.dart`

- [ ] **Step 1: Check document_types.dart**

The `builder:` callbacks use `StorefrontConfigMapper.fromMap(merged)` etc. Since the mapper now uses `ImageReferenceMapper` (or `ImageUrlMapper` for AppTheme), the deserialization should work. No changes needed unless the file imports `ImageUrl`/`ImageUrlMapper` directly.

- [ ] **Step 2: Verify CMS app compiles**

Run: `cd examples/desk_app && flutter analyze`
Expected: No errors.

- [ ] **Step 3: Commit if changes needed**

```bash
git add examples/desk_app/
git commit -m "refactor: update CMS app for unified ImageReference"
```

---

### Task 13: Update tests

**Files:**
- Modify: `packages/dart_desk/test/media/image_url_test.dart`
- Modify: `packages/dart_desk/test/inputs/image_hotspot_editor_test.dart`
- Modify: `packages/dart_desk/test/inputs/hotspot/framing_math_test.dart`
- Modify: `packages/dart_desk/test/data/models/media_asset_inline_json_test.dart`

- [ ] **Step 1: Update `image_url_test.dart`**

`ImageUrl.fromJson(map)` is now `ImageUrl.fromMap(map)`. Update test calls.

The test JSON must still include `publicUrl`, `width`, `height`, `blurHash` for a resolved node — `ImageReference.fromMap` reads these.

Old:
```dart
final imageUrl = ImageUrl.fromJson(json);
```
New:
```dart
final imageUrl = ImageUrl.fromMap(json);
```

Assertions on `.url()` should return the `publicUrl` value when no transform is set.

- [ ] **Step 2: Update hotspot/framing tests if needed**

These construct `Hotspot(...)` and `CropRect(...)` directly. The classes are identical (same constructors, same fields) — they just come from the annotation package now via re-export. Imports should resolve without changes.

- [ ] **Step 3: Run all tests**

```bash
cd packages/dart_desk && flutter test
```

Expected: All pass.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk/test/
git commit -m "test: update tests for unified ImageReference"
```

---

### Task 14: Update mock data source

**Files:**
- Modify: `packages/dart_desk/lib/src/testing/mock_desk_data_source.dart`

- [ ] **Step 1: Check for `ImageReference(asset:)` usage**

If the mock constructs `ImageReference(asset: mediaAsset)`, replace with `ImageReferenceFromAsset.fromAsset(mediaAsset)`.

- [ ] **Step 2: Verify**

Run: `cd packages/dart_desk && dart analyze`

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/lib/src/testing/mock_desk_data_source.dart
git commit -m "refactor: update mock data source for unified ImageReference"
```

---

### Task 15: Final verification

- [ ] **Step 1: Full analysis across all packages**

```bash
cd packages/dart_desk_annotation && dart analyze
cd packages/dart_desk && dart analyze
cd examples/data_models && dart analyze
cd examples/desk_app && flutter analyze
cd examples/example_app && flutter analyze
```

All should pass with zero errors.

- [ ] **Step 2: Run all tests**

```bash
cd packages/dart_desk && flutter test
```

- [ ] **Step 3: Verify serialization compatibility**

Confirm both types produce identical JSON:
```dart
// ImageReference
final ref = ImageReference(assetId: 'test-123', hotspot: Hotspot(x: 0.5, y: 0.3, width: 0.8, height: 0.6));
print(ref.toMap());
// { _type: imageReference, assetId: test-123, hotspot: {x: 0.5, y: 0.3, width: 0.8, height: 0.6} }

// ImageUrl wrapping the same data
final url = ImageUrl(imageRef: ref);
print(url.toMap());
// { _type: imageReference, assetId: test-123, hotspot: {x: 0.5, y: 0.3, width: 0.8, height: 0.6} }
// Identical ✓
```

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "refactor: unified ImageReference - final cleanup and verification"
```
