# Image System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Sanity-inspired image system with asset-as-document storage, interactive hotspot/crop UI, a media browser, URL-based transforms, and e2e test coverage via Marionette.

**Architecture:** Three-layer system: dart_desk (Flutter widgets + client models), dart_desk_be (Serverpod backend with MediaAsset model, upload/CRUD endpoints, metadata extraction), dart_desk_cloud (AWS S3 + Serverless Image Handler for transforms). The client extracts quick metadata (dimensions, blurHash, content hash) on pick, the server stores to cloud storage and enriches with palette/EXIF asynchronously.

**Tech Stack:** Flutter, Serverpod, shadcn_ui, signals, super_drag_and_drop, image_picker, CustomPainter, Marionette MCP (e2e), AWS S3 + CloudFront + Lambda@Edge (cloud)

**Spec:** `docs/superpowers/specs/2026-03-21-image-system-design.md`

---

## File Map

### Phase 1: Data Models & Backend (dart_desk_be)

| Action | File | Responsibility |
|---|---|---|
| Create | `dart_desk_be_server/lib/src/models/media_asset.spy.yaml` | Serverpod model for MediaAsset (replaces media_file) |
| Create | `dart_desk_be_server/lib/src/models/media_asset_metadata_status.spy.yaml` | Enum: pending, complete, failed |
| Modify | `dart_desk_be_server/lib/src/endpoints/media_endpoint.dart` | Update to new MediaAsset model, add search/filter, dedup, validation |
| Create | `dart_desk_be_server/lib/src/services/image_storage_provider.dart` | Abstract interface for storage + transforms |
| Create | `dart_desk_be_server/lib/src/services/local_image_storage_provider.dart` | Default local implementation |
| Create | `dart_desk_be_server/lib/src/services/metadata_extractor.dart` | Server-side palette, LQIP, EXIF, geolocation extraction |
| Delete | `dart_desk_be_server/lib/src/models/media_file.spy.yaml` | Replaced by media_asset |
| Delete | `dart_desk_be_server/lib/src/models/upload_response.spy.yaml` | No longer needed — endpoint returns MediaAsset directly |

### Phase 2: Client Models & Data Layer (dart_desk)

| Action | File | Responsibility |
|---|---|---|
| Create | `packages/dart_desk/lib/src/data/models/media_asset.dart` | Client-side MediaAsset model (mirrors server) |
| Create | `packages/dart_desk/lib/src/data/models/image_reference.dart` | Per-usage reference with hotspot/crop/altText + JSON serialization |
| Create | `packages/dart_desk/lib/src/data/models/image_types.dart` | Hotspot, CropRect, MediaPalette, PaletteColor, MediaGeoLocation, QuickImageMetadata, FitMode |
| Create | `packages/dart_desk/lib/src/data/models/media_page.dart` | MediaPage, MediaTypeFilter, MediaSort |
| Modify | `packages/dart_desk/lib/src/data/cms_data_source.dart` | Update media methods to new signatures |
| Modify | `packages/dart_desk/lib/src/testing/mock_cms_data_source.dart` | Update mock to implement new interface |
| Delete | `packages/dart_desk/lib/src/data/models/media_file.dart` | Replaced by media_asset.dart |
| Delete | `packages/dart_desk/lib/src/data/models/media_upload_result.dart` | No longer needed |
| Modify | `packages/dart_desk/lib/src/data/data.dart` | Update barrel exports |

### Phase 3: Quick Metadata Extraction (dart_desk)

| Action | File | Responsibility |
|---|---|---|
| Create | `packages/dart_desk/lib/src/media/quick_metadata_extractor.dart` | Isolate-based image decode, blurHash, SHA-256 |
| Modify | `packages/dart_desk/pubspec.yaml` | Add `blurhash`, `crypto` dependencies |

### Phase 4: Image Transform URL Builder (dart_desk)

| Action | File | Responsibility |
|---|---|---|
| Create | `packages/dart_desk/lib/src/media/image_url.dart` | ImageUrl class + TransformUrlBuilder typedef |
| Create | `packages/dart_desk/lib/src/media/image_transform_params.dart` | ImageTransformParams class |

### Phase 5: Updated CmsImageInput (dart_desk)

| Action | File | Responsibility |
|---|---|---|
| Modify | `packages/dart_desk/lib/src/inputs/image_input.dart` | Rewrite: upload via CmsDataSource, emit ImageReference, drop zone, blurHash placeholder |
| Modify | `packages/dart_desk/pubspec.yaml` | Add `super_drag_and_drop` dependency |

### Phase 6: Hotspot & Crop Editor (dart_desk)

| Action | File | Responsibility |
|---|---|---|
| Create | `packages/dart_desk/lib/src/inputs/hotspot/image_hotspot_editor.dart` | Main editor widget with crop overlay + hotspot ellipse |
| Create | `packages/dart_desk/lib/src/inputs/hotspot/crop_overlay_painter.dart` | CustomPainter for crop darkening + drag handles |
| Create | `packages/dart_desk/lib/src/inputs/hotspot/hotspot_painter.dart` | CustomPainter for hotspot ellipse + resize handles |
| Create | `packages/dart_desk/lib/src/inputs/hotspot/aspect_ratio_preview.dart` | Live preview strip showing 16:9, 4:3, 1:1 crops |

### Phase 7: Media Browser (dart_desk)

| Action | File | Responsibility |
|---|---|---|
| Create | `packages/dart_desk/lib/src/media/browser/media_browser.dart` | Main browser widget (standalone + picker modes) |
| Create | `packages/dart_desk/lib/src/media/browser/media_grid.dart` | Grid view with blurHash placeholders, drag sources |
| Create | `packages/dart_desk/lib/src/media/browser/media_list_view.dart` | List view alternative |
| Create | `packages/dart_desk/lib/src/media/browser/media_toolbar.dart` | Search, type filter, sort, view toggle |
| Create | `packages/dart_desk/lib/src/media/browser/asset_detail_panel.dart` | Detail panel with metadata, palette, EXIF, usage, actions |
| Create | `packages/dart_desk/lib/src/media/browser/media_browser_state.dart` | Signals-based state management for browser |

### Phase 8: Cloud Provider (dart_desk_cloud)

| Action | File | Responsibility |
|---|---|---|
| Create | `dart_desk_cloud/lib/src/services/aws_image_storage_provider.dart` | S3 store + AWS Serverless Image Handler transform URLs |
| Modify | `dart_desk_cloud/lib/src/cloud_server.dart` | Register AwsImageStorageProvider |
| Create | `dart_desk_cloud/deploy/aws/terraform/image_handler.tf` | Terraform for AWS Serverless Image Handler CloudFront + Lambda@Edge |

### Phase 9: E2E Tests with Marionette

| Action | File | Responsibility |
|---|---|---|
| Modify | `examples/cms_app/lib/main_test.dart` | Add image fields to test document types, add ValueKeys |
| Modify | `packages/dart_desk/lib/src/testing/test_document_types.dart` | Add image field to test document type |

---

## Task Breakdown

### Task 1: Serverpod MediaAsset Model

**Files:**
- Create: `dart_desk_be_server/lib/src/models/media_asset.spy.yaml`
- Create: `dart_desk_be_server/lib/src/models/media_asset_metadata_status.spy.yaml`
- Delete: `dart_desk_be_server/lib/src/models/media_file.spy.yaml`
- Delete: `dart_desk_be_server/lib/src/models/upload_response.spy.yaml`

**Context:** Serverpod models are YAML files in `/models/`. Run `serverpod generate` to produce Dart classes. The existing `media_file.spy.yaml` has fields: clientId, fileName, fileType, fileSize, storagePath, publicUrl, altText?, metadata?, uploadedByUserId, createdAt. We're replacing it with a richer MediaAsset.

- [ ] **Step 1: Create the MediaAssetMetadataStatus enum model**

```yaml
# dart_desk_be_server/lib/src/models/media_asset_metadata_status.spy.yaml
class: MediaAssetMetadataStatus
type: enum
values:
  - pending
  - complete
  - failed
```

- [ ] **Step 2: Create the MediaAsset model**

```yaml
# dart_desk_be_server/lib/src/models/media_asset.spy.yaml
class: MediaAsset
table: media_assets
fields:
  clientId: int, relation(parent=cms_clients, onDelete=Restrict)
  assetId: String
  fileName: String
  mimeType: String
  fileSize: int
  storagePath: String
  publicUrl: String
  width: int
  height: int
  hasAlpha: bool
  blurHash: String
  lqip: String?
  paletteJson: String?
  exifJson: String?
  locationLat: double?
  locationLng: double?
  uploadedByUserId: int?
  metadataStatus: MediaAssetMetadataStatus
indexes:
  media_asset_client_id_idx:
    fields: clientId
  media_asset_asset_id_idx:
    fields: assetId
    unique: true
  media_asset_file_name_idx:
    fields: fileName
  media_asset_mime_type_idx:
    fields: mimeType
```

Note: `palette` and `exif` are stored as JSON strings (`paletteJson`, `exifJson`) because Serverpod models don't support nested complex types directly. Parse/serialize in the endpoint layer. The `clientId` field preserves multi-tenancy — all queries MUST filter by `clientId` (same pattern as existing `MediaFile` and `CmsDocument`). Also note: `serverpod generate` will also regenerate `dart_desk_be_client/` generated files — both packages must be regenerated.

- [ ] **Step 3: Remove old models**

Delete `dart_desk_be_server/lib/src/models/media_file.spy.yaml` and `dart_desk_be_server/lib/src/models/upload_response.spy.yaml`.

- [ ] **Step 4: Run serverpod generate**

Run: `cd /path/to/dart_desk_be_server && serverpod generate`
Expected: Generated Dart classes for MediaAsset and MediaAssetMetadataStatus. Compilation errors in media_endpoint.dart (expected — we'll fix that next).

- [ ] **Step 5: Create database migration**

Run: `cd /path/to/dart_desk_be_server && serverpod create-migration`
Expected: Migration file created that drops `media_files` table and creates `media_assets` table with the unique index on `assetId`.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(be): add MediaAsset model replacing MediaFile"
```

---

### Task 2: ImageStorageProvider Interface & Local Implementation

**Files:**
- Create: `dart_desk_be_server/lib/src/services/image_storage_provider.dart`
- Create: `dart_desk_be_server/lib/src/services/local_image_storage_provider.dart`

**Context:** The abstract interface decouples storage from the endpoint. `LocalImageStorageProvider` uses Serverpod's built-in `session.storage` API. `transformUrl()` returns `null` for local (no transforms).

- [ ] **Step 1: Create the abstract interface**

```dart
// dart_desk_be_server/lib/src/services/image_storage_provider.dart
import 'dart:typed_data';

/// Fit modes for image transforms.
enum FitMode { clip, crop, fill, max, scale }

/// Crop rectangle with 0-1 fractional values.
class CropRect {
  final double top;
  final double bottom;
  final double left;
  final double right;

  const CropRect({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });
}

/// Parameters for image URL transforms.
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

/// Abstract storage + transform provider.
/// Implementations: LocalImageStorageProvider (default), AwsImageStorageProvider (cloud).
abstract class ImageStorageProvider {
  /// Store file, return public URL.
  Future<String> store(String assetId, String fileName, Uint8List data);

  /// Delete file by its storage path.
  Future<void> delete(String storagePath);

  /// Generate a transform URL. Returns null if transforms not supported.
  String? transformUrl(String publicUrl, ImageTransformParams params);
}
```

- [ ] **Step 2: Create the local implementation**

```dart
// dart_desk_be_server/lib/src/services/local_image_storage_provider.dart
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import 'image_storage_provider.dart';

/// Default storage provider using Serverpod's built-in cloud storage.
/// No image transforms — returns null for transformUrl.
class LocalImageStorageProvider implements ImageStorageProvider {
  final Session session;

  LocalImageStorageProvider(this.session);

  @override
  Future<String> store(String assetId, String fileName, Uint8List data) async {
    final storagePath = 'media/$assetId/$fileName';
    await session.storage.storeFile(
      storageId: 'public',
      path: storagePath,
      byteData: ByteData.sublistView(data),
    );
    final publicUrl = await session.storage.getPublicUrl(
      storageId: 'public',
      path: storagePath,
    );
    return publicUrl.toString();
  }

  @override
  Future<void> delete(String storagePath) async {
    await session.storage.deleteFile(
      storageId: 'public',
      path: storagePath,
    );
  }

  @override
  String? transformUrl(String publicUrl, ImageTransformParams params) {
    // Local provider does not support transforms.
    return null;
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add dart_desk_be_server/lib/src/services/image_storage_provider.dart \
       dart_desk_be_server/lib/src/services/local_image_storage_provider.dart
git commit -m "feat(be): add ImageStorageProvider interface and local implementation"
```

---

### Task 3: Update MediaEndpoint

**Files:**
- Modify: `dart_desk_be_server/lib/src/endpoints/media_endpoint.dart`

**Context:** The existing endpoint has `uploadImage`, `uploadFile`, `deleteMedia`, `getMedia`, `listMedia`. We need to:
1. Accept `QuickImageMetadata` (width, height, hasAlpha, blurHash, contentHash) in upload
2. Implement content-hash deduplication with unique constraint catch
3. Add search/filter/sort to listMedia
4. Add `getMediaUsageCount` (scan document data for assetId references)
5. Block delete when usage > 0
6. Server-side MIME type + file size validation
7. Dispatch async metadata enrichment after upload

- [ ] **Step 1: Rewrite uploadImage with dedup and validation**

Replace the existing `uploadImage` method. Key changes:
- Accept additional parameters: `int width`, `int height`, `bool hasAlpha`, `String blurHash`, `String contentHash`
- Check for existing asset by contentHash before storing
- On unique constraint violation, re-fetch and return existing
- Validate MIME type against allowed list
- Store via `session.storage` (existing pattern)
- Create MediaAsset record with `metadataStatus: pending`
- Dispatch async metadata extraction via `session.messages` or a future call

```dart
Future<MediaAsset> uploadImage(
  Session session,
  String fileName,
  Uint8List fileData,
  int width,
  int height,
  bool hasAlpha,
  String blurHash,
  String contentHash,
) async {
  // NOTE: Check existing endpoint code for the correct session.authenticated pattern.
  // In current Serverpod version used by this project, it may be synchronous.
  final authInfo = await session.authenticated;
  final userId = authInfo?.userId;
  final cmsUser = await CmsUser.db.findFirstRow(session, where: (t) => t.userId.equals(userId));
  final clientId = cmsUser!.clientId;

  // Validate MIME type
  final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
  const allowedTypes = [
    'image/jpeg', 'image/png', 'image/webp', 'image/gif',
    'image/svg+xml', 'image/avif', 'image/heic', 'image/heif',
    'image/tiff', 'image/bmp',
  ];
  if (!allowedTypes.contains(mimeType)) {
    throw CmsValidationException('Unsupported image type: $mimeType');
  }

  // Validate file size (10MB)
  if (fileData.length > 10 * 1024 * 1024) {
    throw CmsValidationException('File too large: ${fileData.length} bytes (max 10MB)');
  }

  // Check for existing asset by content hash
  final ext = fileName.split('.').last.toLowerCase();
  final assetId = 'image-$contentHash-${width}x$height-$ext';

  final existing = await MediaAsset.db.findFirstRow(
    session,
    where: (t) => t.assetId.equals(assetId),
  );
  if (existing != null) return existing;

  // Store file via ImageStorageProvider
  // NOTE: The provider is obtained from the Serverpod instance or injected.
  // Pattern: `final provider = session.serverpod.getImageStorageProvider(session);`
  // or create inline: `final provider = LocalImageStorageProvider(session);`
  final provider = LocalImageStorageProvider(session);
  final storagePath = 'media/$assetId/$fileName';
  final publicUrl = await provider.store(assetId, fileName, fileData);

  // Create asset record (includes clientId for multi-tenancy)
  final asset = MediaAsset(
    clientId: clientId,
    assetId: assetId,
    fileName: fileName,
    mimeType: mimeType,
    fileSize: fileData.length,
    storagePath: storagePath,
    publicUrl: publicUrl,
    width: width,
    height: height,
    hasAlpha: hasAlpha,
    blurHash: blurHash,
    uploadedByUserId: userId,
    metadataStatus: MediaAssetMetadataStatus.pending,
  );

  try {
    final inserted = await MediaAsset.db.insertRow(session, asset);
    // TODO: Dispatch async metadata extraction (Task 4)
    return inserted;
  } catch (e) {
    // Unique constraint violation — race condition, re-fetch
    final reFetched = await MediaAsset.db.findFirstRow(
      session,
      where: (t) => t.assetId.equals(assetId),
    );
    if (reFetched != null) return reFetched;
    rethrow;
  }
}
```

- [ ] **Step 2: Add search/filter/sort to listMedia**

```dart
Future<List<MediaAsset>> listMedia(
  Session session, {
  String? search,
  String? mimeTypePrefix,  // e.g. "image/", "video/", "application/"
  String sortBy = 'dateDesc',  // dateDesc, dateAsc, nameAsc, nameDesc, sizeDesc, sizeAsc
  int limit = 50,
  int offset = 0,
}) async {
  // Build where clause
  Expression<bool>? where;
  if (search != null && search.isNotEmpty) {
    where = MediaAsset.t.fileName.ilike('%$search%');
  }
  if (mimeTypePrefix != null) {
    final typeFilter = MediaAsset.t.mimeType.ilike('$mimeTypePrefix%');
    where = where != null ? where & typeFilter : typeFilter;
  }

  // Build order
  final orderField = switch (sortBy) {
    'dateAsc' => MediaAsset.t.id,
    'nameAsc' => MediaAsset.t.fileName,
    'nameDesc' => MediaAsset.t.fileName,
    'sizeDesc' => MediaAsset.t.fileSize,
    'sizeAsc' => MediaAsset.t.fileSize,
    _ => MediaAsset.t.id,  // dateDesc
  };
  final descending = sortBy.endsWith('Desc') || sortBy == 'dateDesc';

  final items = await MediaAsset.db.find(
    session,
    where: where != null ? (t) => where! : null,
    orderBy: (t) => orderField,
    orderDescending: descending,
    limit: limit,
    offset: offset,
  );

  final total = await MediaAsset.db.count(
    session,
    where: where != null ? (t) => where! : null,
  );

  // Return both items and total for pagination.
  // The endpoint return type should be a custom class with {items, total}
  // or return a Serverpod-generated model wrapping both.
  return (items: items, total: total);
}
```

- [ ] **Step 3: Add getMediaUsageCount**

```dart
/// Count how many documents reference this assetId in their CRDT snapshot data.
/// IMPORTANT: document content is stored in `document_crdt_snapshots`, NOT `document_versions`.
Future<int> getMediaUsageCount(Session session, String assetId) async {
  final result = await session.db.query(
    'SELECT COUNT(DISTINCT document_id) FROM document_crdt_snapshots '
    'WHERE data::text LIKE \$1',
    parameters: QueryParameters.positional(['%$assetId%']),
  );
  return result.firstOrNull?.firstOrNull as int? ?? 0;
}
```

- [ ] **Step 4: Update deleteMedia with safety check**

```dart
Future<bool> deleteMedia(Session session, String assetId) async {
  final usageCount = await getMediaUsageCount(session, assetId);
  if (usageCount > 0) {
    throw CmsValidationException(
      'Cannot delete asset: still referenced by $usageCount document(s)',
    );
  }

  final asset = await MediaAsset.db.findFirstRow(
    session,
    where: (t) => t.assetId.equals(assetId),
  );
  if (asset == null) return false;

  final provider = LocalImageStorageProvider(session);
  await provider.delete(asset.storagePath);
  await MediaAsset.db.deleteRow(session, asset);
  return true;
}
```

- [ ] **Step 5: Run serverpod generate to update protocol**

Run: `cd /path/to/dart_desk_be_server && serverpod generate`

- [ ] **Step 6: Commit**

```bash
git add dart_desk_be_server/lib/src/endpoints/media_endpoint.dart
git commit -m "feat(be): update media endpoint with dedup, search, validation, delete safety"
```

---

### Task 4: Server-side Metadata Extractor

**Files:**
- Create: `dart_desk_be_server/lib/src/services/metadata_extractor.dart`
- Modify: `dart_desk_be_server/pubspec.yaml` (add `image`, `exif` packages)

**Context:** Runs asynchronously after upload. Extracts color palette, LQIP (tiny base64 thumbnail), EXIF camera data, and geolocation. Updates the MediaAsset record.

- [ ] **Step 1: Add dependencies to pubspec.yaml**

Add to `dart_desk_be_server/pubspec.yaml` dependencies:
```yaml
  image: ^4.5.0
  exif: ^3.4.0
```

- [ ] **Step 2: Create the metadata extractor**

```dart
// dart_desk_be_server/lib/src/services/metadata_extractor.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:exif/exif.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class MetadataExtractor {
  /// Extract rich metadata and update the asset record.
  static Future<void> extractAndUpdate(Session session, MediaAsset asset) async {
    try {
      // Download file from storage
      final byteData = await session.storage.retrieveFile(
        storageId: 'public',
        path: asset.storagePath,
      );
      if (byteData == null) {
        await _markFailed(session, asset);
        return;
      }
      final bytes = byteData.buffer.asUint8List();

      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) {
        await _markFailed(session, asset);
        return;
      }

      // Generate LQIP (20px wide thumbnail as base64 JPEG)
      final thumbnail = img.copyResize(image, width: 20);
      final lqipBytes = img.encodeJpg(thumbnail, quality: 30);
      final lqip = 'data:image/jpeg;base64,${base64Encode(lqipBytes)}';

      // Extract palette (sample dominant colors)
      final palette = _extractPalette(image);

      // Extract EXIF
      Map<String, dynamic>? exifData;
      double? lat;
      double? lng;
      try {
        final exifTags = await readExifFromBytes(bytes);
        if (exifTags.isNotEmpty) {
          exifData = {};
          for (final entry in exifTags.entries) {
            exifData[entry.key] = entry.value.toString();
          }
          // Extract GPS coordinates if present
          final gpsLat = exifTags['GPS GPSLatitude'];
          final gpsLng = exifTags['GPS GPSLongitude'];
          final gpsLatRef = exifTags['GPS GPSLatitudeRef'];
          final gpsLngRef = exifTags['GPS GPSLongitudeRef'];
          if (gpsLat != null && gpsLng != null) {
            lat = _parseGpsCoordinate(gpsLat.toString(), gpsLatRef?.toString());
            lng = _parseGpsCoordinate(gpsLng.toString(), gpsLngRef?.toString());
          }
        }
      } catch (_) {
        // EXIF extraction is best-effort
      }

      // Update asset
      asset
        ..lqip = lqip
        ..paletteJson = palette != null ? jsonEncode(palette) : null
        ..exifJson = exifData != null ? jsonEncode(exifData) : null
        ..locationLat = lat
        ..locationLng = lng
        ..metadataStatus = MediaAssetMetadataStatus.complete;
      await MediaAsset.db.updateRow(session, asset);
    } catch (e) {
      await _markFailed(session, asset);
    }
  }

  static Future<void> _markFailed(Session session, MediaAsset asset) async {
    asset.metadataStatus = MediaAssetMetadataStatus.failed;
    await MediaAsset.db.updateRow(session, asset);
  }

  static Map<String, dynamic>? _extractPalette(img.Image image) {
    // Simple dominant color extraction by sampling pixels
    final colorCounts = <int, int>{};
    final step = (image.width * image.height / 1000).ceil().clamp(1, 100);
    for (var i = 0; i < image.width * image.height; i += step) {
      final x = i % image.width;
      final y = i ~/ image.width;
      final pixel = image.getPixel(x, y);
      // Quantize to reduce color space
      final r = (pixel.r.toInt() >> 4) << 4;
      final g = (pixel.g.toInt() >> 4) << 4;
      final b = (pixel.b.toInt() >> 4) << 4;
      final key = (r << 16) | (g << 8) | b;
      colorCounts[key] = (colorCounts[key] ?? 0) + 1;
    }
    final sorted = colorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) return null;

    String colorToHex(int c) {
      final r = (c >> 16) & 0xFF;
      final g = (c >> 8) & 0xFF;
      final b = c & 0xFF;
      return '#${r.toRadixString(16).padLeft(2, '0')}'
          '${g.toRadixString(16).padLeft(2, '0')}'
          '${b.toRadixString(16).padLeft(2, '0')}';
    }

    Map<String, dynamic> toColor(int c) => {
      'r': (c >> 16) & 0xFF,
      'g': (c >> 8) & 0xFF,
      'b': c & 0xFF,
      'hex': colorToHex(c),
    };

    return {
      'dominant': toColor(sorted[0].key),
      if (sorted.length > 1) 'vibrant': toColor(sorted[1].key),
      if (sorted.length > 2) 'muted': toColor(sorted[2].key),
      if (sorted.length > 3) 'darkMuted': toColor(sorted[3].key),
    };
  }

  static double? _parseGpsCoordinate(String value, String? ref) {
    // Parse EXIF GPS format: "[deg, min, sec]"
    try {
      final parts = value
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((s) => s.trim())
          .toList();
      if (parts.length < 3) return null;
      final deg = _parseRational(parts[0]);
      final min = _parseRational(parts[1]);
      final sec = _parseRational(parts[2]);
      var result = deg + min / 60.0 + sec / 3600.0;
      if (ref == 'S' || ref == 'W') result = -result;
      return result;
    } catch (_) {
      return null;
    }
  }

  static double _parseRational(String value) {
    if (value.contains('/')) {
      final parts = value.split('/');
      return double.parse(parts[0]) / double.parse(parts[1]);
    }
    return double.parse(value);
  }
}
```

- [ ] **Step 3: Wire metadata extraction into the upload endpoint**

In `media_endpoint.dart`'s `uploadImage` method, after the `MediaAsset.db.insertRow` call, add:

```dart
// Dispatch async metadata extraction
// Using unawaited to not block the upload response
unawaited(MetadataExtractor.extractAndUpdate(session, inserted));
```

Add import: `import 'dart:async';` and `import '../services/metadata_extractor.dart';`

- [ ] **Step 4: Commit**

```bash
git add dart_desk_be_server/lib/src/services/metadata_extractor.dart \
       dart_desk_be_server/lib/src/endpoints/media_endpoint.dart \
       dart_desk_be_server/pubspec.yaml
git commit -m "feat(be): add async metadata extraction (palette, LQIP, EXIF, geolocation)"
```

---

### Task 5: Client-side Data Models (dart_desk)

**Files:**
- Create: `packages/dart_desk/lib/src/data/models/media_asset.dart`
- Create: `packages/dart_desk/lib/src/data/models/image_reference.dart`
- Create: `packages/dart_desk/lib/src/data/models/image_types.dart`
- Create: `packages/dart_desk/lib/src/data/models/media_page.dart`
- Delete: `packages/dart_desk/lib/src/data/models/media_file.dart`
- Delete: `packages/dart_desk/lib/src/data/models/media_upload_result.dart`
- Modify: `packages/dart_desk/lib/src/data/data.dart`

**Context:** These are plain Dart models (not Serverpod-generated) that mirror the server types for the client. They need `fromJson`/`toJson`, `copyWith`, and `==`/`hashCode`.

- [ ] **Step 1: Create image_types.dart (supporting types)**

```dart
// packages/dart_desk/lib/src/data/models/image_types.dart

enum FitMode { clip, crop, fill, max, scale }

enum MediaAssetMetadataStatus { pending, complete, failed }

enum MediaTypeFilter { image, video, file, all }

enum MediaSort { dateDesc, dateAsc, nameAsc, nameDesc, sizeDesc, sizeAsc }

class Hotspot {
  final double x;
  final double y;
  final double width;
  final double height;

  const Hotspot({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory Hotspot.fromJson(Map<String, dynamic> json) => Hotspot(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    width: (json['width'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'width': width, 'height': height};

  Hotspot copyWith({double? x, double? y, double? width, double? height}) =>
    Hotspot(x: x ?? this.x, y: y ?? this.y, width: width ?? this.width, height: height ?? this.height);
}

class CropRect {
  final double top;
  final double bottom;
  final double left;
  final double right;

  const CropRect({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });

  factory CropRect.fromJson(Map<String, dynamic> json) => CropRect(
    top: (json['top'] as num).toDouble(),
    bottom: (json['bottom'] as num).toDouble(),
    left: (json['left'] as num).toDouble(),
    right: (json['right'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'top': top, 'bottom': bottom, 'left': left, 'right': right};
}

class PaletteColor {
  final int r;
  final int g;
  final int b;
  final String hex;

  const PaletteColor({required this.r, required this.g, required this.b, required this.hex});

  factory PaletteColor.fromJson(Map<String, dynamic> json) => PaletteColor(
    r: json['r'] as int,
    g: json['g'] as int,
    b: json['b'] as int,
    hex: json['hex'] as String,
  );

  Map<String, dynamic> toJson() => {'r': r, 'g': g, 'b': b, 'hex': hex};
}

class MediaPalette {
  final PaletteColor dominant;
  final PaletteColor? vibrant;
  final PaletteColor? muted;
  final PaletteColor? darkMuted;

  const MediaPalette({required this.dominant, this.vibrant, this.muted, this.darkMuted});

  factory MediaPalette.fromJson(Map<String, dynamic> json) => MediaPalette(
    dominant: PaletteColor.fromJson(json['dominant']),
    vibrant: json['vibrant'] != null ? PaletteColor.fromJson(json['vibrant']) : null,
    muted: json['muted'] != null ? PaletteColor.fromJson(json['muted']) : null,
    darkMuted: json['darkMuted'] != null ? PaletteColor.fromJson(json['darkMuted']) : null,
  );

  Map<String, dynamic> toJson() => {
    'dominant': dominant.toJson(),
    if (vibrant != null) 'vibrant': vibrant!.toJson(),
    if (muted != null) 'muted': muted!.toJson(),
    if (darkMuted != null) 'darkMuted': darkMuted!.toJson(),
  };
}

class MediaGeoLocation {
  final double lat;
  final double lng;

  const MediaGeoLocation({required this.lat, required this.lng});

  factory MediaGeoLocation.fromJson(Map<String, dynamic> json) => MediaGeoLocation(
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class QuickImageMetadata {
  final int width;
  final int height;
  final bool hasAlpha;
  final String blurHash;
  final String contentHash;

  const QuickImageMetadata({
    required this.width,
    required this.height,
    required this.hasAlpha,
    required this.blurHash,
    required this.contentHash,
  });
}
```

- [ ] **Step 2: Create media_asset.dart**

```dart
// packages/dart_desk/lib/src/data/models/media_asset.dart
import 'dart:convert';
import 'image_types.dart';

class MediaAsset {
  final int id;
  final String assetId;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final String publicUrl;
  final int width;
  final int height;
  final bool hasAlpha;
  final String blurHash;
  final String? lqip;
  final MediaPalette? palette;
  final Map<String, dynamic>? exif;
  final MediaGeoLocation? location;
  final int? uploadedByUserId;
  final DateTime createdAt;
  final MediaAssetMetadataStatus metadataStatus;

  const MediaAsset({
    required this.id,
    required this.assetId,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.publicUrl,
    required this.width,
    required this.height,
    required this.hasAlpha,
    required this.blurHash,
    this.lqip,
    this.palette,
    this.exif,
    this.location,
    this.uploadedByUserId,
    required this.createdAt,
    required this.metadataStatus,
  });

  bool get isImage => mimeType.startsWith('image/');

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory MediaAsset.fromJson(Map<String, dynamic> json) => MediaAsset(
    id: json['id'] as int,
    assetId: json['assetId'] as String,
    fileName: json['fileName'] as String,
    mimeType: json['mimeType'] as String,
    fileSize: json['fileSize'] as int,
    publicUrl: json['publicUrl'] as String,
    width: json['width'] as int,
    height: json['height'] as int,
    hasAlpha: json['hasAlpha'] as bool,
    blurHash: json['blurHash'] as String,
    lqip: json['lqip'] as String?,
    palette: json['paletteJson'] != null
        ? MediaPalette.fromJson(jsonDecode(json['paletteJson']))
        : null,
    exif: json['exifJson'] != null
        ? jsonDecode(json['exifJson']) as Map<String, dynamic>
        : null,
    location: json['locationLat'] != null && json['locationLng'] != null
        ? MediaGeoLocation(
            lat: (json['locationLat'] as num).toDouble(),
            lng: (json['locationLng'] as num).toDouble(),
          )
        : null,
    uploadedByUserId: json['uploadedByUserId'] as int?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    metadataStatus: MediaAssetMetadataStatus.values.byName(json['metadataStatus'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'assetId': assetId,
    'fileName': fileName,
    'mimeType': mimeType,
    'fileSize': fileSize,
    'publicUrl': publicUrl,
    'width': width,
    'height': height,
    'hasAlpha': hasAlpha,
    'blurHash': blurHash,
    'lqip': lqip,
    'paletteJson': palette != null ? jsonEncode(palette!.toJson()) : null,
    'exifJson': exif != null ? jsonEncode(exif) : null,
    'locationLat': location?.lat,
    'locationLng': location?.lng,
    'uploadedByUserId': uploadedByUserId,
    'createdAt': createdAt.toIso8601String(),
    'metadataStatus': metadataStatus.name,
  };
}
```

- [ ] **Step 3: Create image_reference.dart**

```dart
// packages/dart_desk/lib/src/data/models/image_reference.dart
import 'image_types.dart';
import 'media_asset.dart';

class ImageReference {
  final MediaAsset asset;
  final Hotspot? hotspot;
  final CropRect? crop;
  final String? altText;

  const ImageReference({
    required this.asset,
    this.hotspot,
    this.crop,
    this.altText,
  });

  ImageReference copyWith({
    MediaAsset? asset,
    Hotspot? hotspot,
    CropRect? crop,
    String? altText,
  }) => ImageReference(
    asset: asset ?? this.asset,
    hotspot: hotspot ?? this.hotspot,
    crop: crop ?? this.crop,
    altText: altText ?? this.altText,
  );

  /// Serialize for document data storage.
  Map<String, dynamic> toDocumentJson() => {
    '_type': 'imageReference',
    'assetId': asset.assetId,
    if (hotspot != null) 'hotspot': hotspot!.toJson(),
    if (crop != null) 'crop': crop!.toJson(),
    if (altText != null) 'altText': altText,
  };

  /// Deserialize from document data JSON + a pre-fetched MediaAsset.
  /// The caller must fetch the asset via `CmsDataSource.getMediaAsset(json['assetId'])`.
  factory ImageReference.fromDocumentJson(Map<String, dynamic> json, MediaAsset asset) {
    return ImageReference(
      asset: asset,
      hotspot: json['hotspot'] != null ? Hotspot.fromJson(json['hotspot']) : null,
      crop: json['crop'] != null ? CropRect.fromJson(json['crop']) : null,
      altText: json['altText'] as String?,
    );
  }

  /// Check if a JSON map is an ImageReference.
  static bool isImageReference(Map<String, dynamic> json) =>
      json['_type'] == 'imageReference';
}
```

- [ ] **Step 4: Create media_page.dart**

```dart
// packages/dart_desk/lib/src/data/models/media_page.dart
import 'media_asset.dart';

class MediaPage {
  final List<MediaAsset> items;
  final int total;

  const MediaPage({required this.items, required this.total});
}
```

- [ ] **Step 5: Delete old models and update barrel export**

Delete `packages/dart_desk/lib/src/data/models/media_file.dart` and `packages/dart_desk/lib/src/data/models/media_upload_result.dart`.

Update `packages/dart_desk/lib/src/data/data.dart` to export the new models instead of the old ones.

- [ ] **Step 6: Commit**

```bash
git add packages/dart_desk/lib/src/data/
git commit -m "feat: add client-side MediaAsset, ImageReference, and supporting types"
```

---

### Task 6: Update CmsDataSource Interface & MockCmsDataSource

**Files:**
- Modify: `packages/dart_desk/lib/src/data/cms_data_source.dart`
- Modify: `packages/dart_desk/lib/src/testing/mock_cms_data_source.dart`

- [ ] **Step 1: Update CmsDataSource media methods**

Replace the media section of `cms_data_source.dart` with the new signatures from the spec:

```dart
// Media methods — replaces old MediaFile-based methods
Future<MediaAsset> uploadImage(
  String fileName,
  Uint8List fileData,
  QuickImageMetadata metadata,
);
Future<MediaAsset> uploadFile(String fileName, Uint8List fileData);
Future<bool> deleteMedia(String assetId);
Future<MediaAsset?> getMediaAsset(String assetId);
Future<MediaPage> listMedia({
  String? search,
  MediaTypeFilter? type,
  MediaSort sort = MediaSort.dateDesc,
  int limit = 50,
  int offset = 0,
});
Future<MediaAsset> updateMediaAsset(String assetId, {String? fileName});
Future<int> getMediaUsageCount(String assetId);
```

Update imports to use new model types.

- [ ] **Step 2: Update MockCmsDataSource**

Replace the mock's media implementation to use `Map<String, MediaAsset> _media` keyed by assetId. Implement all new methods with in-memory logic: deduplication by contentHash (via assetId), search by fileName contains, type filtering by mimeType prefix, sorting, pagination, usage count scanning `_documents` data for assetId strings.

- [ ] **Step 3: Fix compilation errors**

Check all imports/references to `MediaFile` and `MediaUploadResult` across the codebase. Update any remaining references in:
- `packages/dart_desk/lib/src/inputs/image_input.dart` (will be rewritten in Task 8, but fix to compile)
- `packages/dart_desk/lib/src/inputs/file_input.dart`
- Any barrel exports

- [ ] **Step 4: Verify compilation**

Run: `cd packages/dart_desk && flutter analyze`
Expected: No errors (warnings acceptable for now on unused code).

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk/lib/src/data/cms_data_source.dart \
       packages/dart_desk/lib/src/testing/mock_cms_data_source.dart \
       packages/dart_desk/lib/src/inputs/
git commit -m "feat: update CmsDataSource interface and mock for MediaAsset"
```

---

### Task 7: Quick Metadata Extractor (Client-side)

**Files:**
- Create: `packages/dart_desk/lib/src/media/quick_metadata_extractor.dart`
- Modify: `packages/dart_desk/pubspec.yaml`

- [ ] **Step 1: Add dependencies**

Add to `packages/dart_desk/pubspec.yaml`:
```yaml
  blurhash_dart: ^1.2.1
  crypto: ^3.0.6
  image: ^4.5.0
```

**IMPORTANT**: Before implementation, verify that `blurhash_dart` works on Flutter web. If it requires FFI (likely), use the `blurhash` pure-Dart package instead. The `image` package is needed for decoding in the isolate to extract dimensions and generate the blurHash input.

- [ ] **Step 2: Create the extractor**

```dart
// packages/dart_desk/lib/src/media/quick_metadata_extractor.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:image/image.dart' as img;
import '../data/models/image_types.dart';

class QuickMetadataExtractor {
  /// Extract quick metadata from image bytes.
  /// Runs in a separate isolate to avoid UI jank.
  static Future<QuickImageMetadata> extract(Uint8List bytes) async {
    return compute(_extractInIsolate, bytes);
  }

  static QuickImageMetadata _extractInIsolate(Uint8List bytes) {
    // Decode image
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Dimensions
    final width = image.width;
    final height = image.height;
    final hasAlpha = image.hasAlpha;

    // BlurHash (4x3 components)
    final blurHash = BlurHash.encode(image, numCompX: 4, numCompY: 3).hash;

    // Content hash (SHA-256)
    final digest = sha256.convert(bytes);
    final contentHash = digest.toString(); // Full SHA-256 hex (64 chars) for robust dedup

    return QuickImageMetadata(
      width: width,
      height: height,
      hasAlpha: hasAlpha,
      blurHash: blurHash,
      contentHash: contentHash,
    );
  }
}
```

Note: The `image` package is used here for decoding in the isolate. It's heavy — if this causes issues on web, provide a web-specific implementation that uses `dart:html` `ImageElement` for dimensions and skips blurHash (server generates it instead).

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/lib/src/media/quick_metadata_extractor.dart \
       packages/dart_desk/pubspec.yaml
git commit -m "feat: add client-side quick metadata extractor (blurHash, dimensions, hash)"
```

---

### Task 8: ImageUrl Builder & Transform Params

**Files:**
- Create: `packages/dart_desk/lib/src/media/image_transform_params.dart`
- Create: `packages/dart_desk/lib/src/media/image_url.dart`

- [ ] **Step 1: Create ImageTransformParams**

```dart
// packages/dart_desk/lib/src/media/image_transform_params.dart
import '../data/models/image_types.dart';

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

- [ ] **Step 2: Create ImageUrl builder**

```dart
// packages/dart_desk/lib/src/media/image_url.dart
import '../data/models/image_reference.dart';
import '../data/models/image_types.dart';
import 'image_transform_params.dart';

/// Client-side typedef for transform URL generation.
/// Provided by the app (e.g., from dart_desk_cloud's AwsImageStorageProvider).
/// Returns null if transforms are not supported.
typedef TransformUrlBuilder = String? Function(
  String publicUrl,
  ImageTransformParams params,
);

/// Builds image URLs with optional transforms applied.
class ImageUrl {
  final ImageReference imageRef;
  final TransformUrlBuilder? _transformUrl;

  const ImageUrl({
    required this.imageRef,
    TransformUrlBuilder? transformUrl,
  }) : _transformUrl = transformUrl;

  /// Build a URL with the given transform parameters.
  /// Falls back to the original public URL if transforms are not available.
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
    return _transformUrl?.call(imageRef.asset.publicUrl, params)
        ?? imageRef.asset.publicUrl;
  }

  /// BlurHash for immediate placeholder display. Always available.
  String get blurHash => imageRef.asset.blurHash;

  /// LQIP base64 thumbnail. Available after server-side metadata extraction.
  String? get lqip => imageRef.asset.lqip;
}
```

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/lib/src/media/
git commit -m "feat: add ImageUrl builder and TransformUrlBuilder typedef"
```

---

### Task 9: Rewrite CmsImageInput

**Files:**
- Modify: `packages/dart_desk/lib/src/inputs/image_input.dart`
- Modify: `packages/dart_desk/pubspec.yaml`

**Context:** Current widget only picks files and emits a path string. New version:
1. Picks image → extracts quick metadata in isolate → uploads via CmsDataSource → emits ImageReference
2. Shows blurHash placeholder during upload
3. Drop zone for OS files via `super_drag_and_drop`
4. "Edit crop" button to open ImageHotspotEditor (Task 10)
5. "Browse" button to open MediaBrowser in picker mode (Task 11)

- [ ] **Step 1: Add super_drag_and_drop dependency**

Add to `packages/dart_desk/pubspec.yaml`:
```yaml
  super_drag_and_drop: ^0.8.0
```

- [ ] **Step 2: Rewrite CmsImageInput**

Full rewrite of `image_input.dart`. Key changes:
- `onChanged` type: `ValueChanged<Map<String, dynamic>?>` (serialized ImageReference)
- New required parameter: `CmsDataSource dataSource` (for upload)
- Optional `TransformUrlBuilder? transformUrl` (for preview transforms)
- States: empty → picking → extracting metadata → uploading → loaded → editing hotspot
- Uses `super_drag_and_drop` `DropRegion` for OS file drops
- Shows blurHash placeholder via `BlurHashImage` widget during upload
- "Browse media" button opens MediaBrowser in picker mode
- "Edit crop" button opens ImageHotspotEditor
- Remove button clears the reference

The widget should use signals for local state management. Key signals:
- `imageRef` — the current ImageReference (nullable)
- `uploadProgress` — upload state (idle, extracting, uploading, done, error)
- `errorMessage` — validation/upload error text

Implementation should handle:
- File pick via image_picker → read bytes → QuickMetadataExtractor.extract() → dataSource.uploadImage() → set imageRef
- Drop via super_drag_and_drop → same flow
- Media browser pick → receives MediaAsset → create ImageReference → set imageRef
- Hotspot edit → opens editor → receives updated hotspot/crop → update imageRef
- All emits via onChanged with imageRef.toDocumentJson()

- [ ] **Step 3: Verify compilation**

Run: `cd packages/dart_desk && flutter analyze`

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk/lib/src/inputs/image_input.dart \
       packages/dart_desk/pubspec.yaml
git commit -m "feat: rewrite CmsImageInput with upload, blurHash, drop zone, ImageReference"
```

---

### Task 10: Hotspot & Crop Editor

**Files:**
- Create: `packages/dart_desk/lib/src/inputs/hotspot/image_hotspot_editor.dart`
- Create: `packages/dart_desk/lib/src/inputs/hotspot/crop_overlay_painter.dart`
- Create: `packages/dart_desk/lib/src/inputs/hotspot/hotspot_painter.dart`
- Create: `packages/dart_desk/lib/src/inputs/hotspot/aspect_ratio_preview.dart`

- [ ] **Step 1: Create crop_overlay_painter.dart**

A `CustomPainter` that:
- Draws a darkened overlay over the entire image
- Cuts out the visible crop region (clear rectangle)
- Draws drag handles at corners and edges of the crop region
- Receives `CropRect` (0-1 fractions) and the image display size

```dart
// packages/dart_desk/lib/src/inputs/hotspot/crop_overlay_painter.dart
import 'package:flutter/material.dart';
import '../../../data/models/image_types.dart';

class CropOverlayPainter extends CustomPainter {
  final CropRect crop;
  final Size imageSize;

  CropOverlayPainter({required this.crop, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final cropRect = Rect.fromLTRB(
      crop.left * size.width,
      crop.top * size.height,
      size.width - crop.right * size.width,
      size.height - crop.bottom * size.height,
    );

    // IMPORTANT: saveLayer is required for BlendMode.clear to work correctly
    canvas.saveLayer(Offset.zero & size, Paint());

    // Dark overlay
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.5);
    canvas.drawRect(Offset.zero & size, overlayPaint);

    // Clear the crop region
    canvas.drawRect(cropRect, Paint()..blendMode = BlendMode.clear);

    canvas.restore();

    // Border
    canvas.drawRect(
      cropRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Drag handles (small squares at corners and midpoints)
    final handlePaint = Paint()..color = Colors.white;
    const handleSize = 8.0;
    final handles = [
      cropRect.topLeft, cropRect.topRight,
      cropRect.bottomLeft, cropRect.bottomRight,
      cropRect.topCenter, cropRect.bottomCenter,
      cropRect.centerLeft, cropRect.centerRight,
    ];
    for (final point in handles) {
      canvas.drawRect(
        Rect.fromCenter(center: point, width: handleSize, height: handleSize),
        handlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) =>
      crop != oldDelegate.crop || imageSize != oldDelegate.imageSize;
}
```

- [ ] **Step 2: Create hotspot_painter.dart**

A `CustomPainter` that draws the hotspot ellipse with resize handles.

```dart
// packages/dart_desk/lib/src/inputs/hotspot/hotspot_painter.dart
import 'package:flutter/material.dart';
import '../../../data/models/image_types.dart';

class HotspotPainter extends CustomPainter {
  final Hotspot hotspot;

  HotspotPainter({required this.hotspot});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(hotspot.x * size.width, hotspot.y * size.height);
    final rx = hotspot.width * size.width / 2;
    final ry = hotspot.height * size.height / 2;

    // Ellipse fill
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      Paint()..color = Colors.blue.withOpacity(0.2),
    );

    // Ellipse border
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Center dot
    canvas.drawCircle(center, 4, Paint()..color = Colors.blue);

    // Resize handles at cardinal points
    final handlePaint = Paint()..color = Colors.blue;
    const hs = 6.0;
    for (final offset in [
      Offset(center.dx, center.dy - ry),
      Offset(center.dx, center.dy + ry),
      Offset(center.dx - rx, center.dy),
      Offset(center.dx + rx, center.dy),
    ]) {
      canvas.drawCircle(offset, hs, handlePaint);
    }
  }

  @override
  bool shouldRepaint(HotspotPainter old) => hotspot != old.hotspot;
}
```

- [ ] **Step 3: Create aspect_ratio_preview.dart**

```dart
// packages/dart_desk/lib/src/inputs/hotspot/aspect_ratio_preview.dart
import 'package:flutter/material.dart';
import '../../../data/models/image_types.dart';

/// Shows a row of small preview thumbnails at different aspect ratios,
/// cropped respecting the hotspot center.
class AspectRatioPreviewStrip extends StatelessWidget {
  final String imageUrl;
  final Hotspot? hotspot;
  final CropRect? crop;

  const AspectRatioPreviewStrip({
    super.key,
    required this.imageUrl,
    this.hotspot,
    this.crop,
  });

  static const _ratios = [
    (label: '16:9', width: 16.0, height: 9.0),
    (label: '4:3', width: 4.0, height: 3.0),
    (label: '1:1', width: 1.0, height: 1.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _ratios.map((ratio) {
        final aspectRatio = ratio.width / ratio.height;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Column(
            children: [
              SizedBox(
                width: 80,
                height: 80 / aspectRatio,
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    alignment: hotspot != null
                        ? Alignment(
                            (hotspot!.x - 0.5) * 2,
                            (hotspot!.y - 0.5) * 2,
                          )
                        : Alignment.center,
                    child: Image.network(imageUrl),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(ratio.label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );
      }).toList(),
    );
  }
}
```

- [ ] **Step 4: Create image_hotspot_editor.dart**

The main editor widget. Opens as a dialog/overlay. Contains:
- The image with `CropOverlayPainter` and `HotspotPainter` stacked on top
- `GestureDetector` regions for dragging crop handles and hotspot
- `AspectRatioPreviewStrip` at the bottom
- Done and Reset buttons

Uses signals for reactive state:
- `crop` signal (CropRect)
- `hotspot` signal (Hotspot)

```dart
// packages/dart_desk/lib/src/inputs/hotspot/image_hotspot_editor.dart
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../data/models/image_types.dart';
import 'crop_overlay_painter.dart';
import 'hotspot_painter.dart';
import 'aspect_ratio_preview.dart';

class ImageHotspotEditor extends StatefulWidget {
  final String imageUrl;
  final Hotspot? initialHotspot;
  final CropRect? initialCrop;
  final ValueChanged<({Hotspot? hotspot, CropRect? crop})> onChanged;

  const ImageHotspotEditor({
    super.key,
    required this.imageUrl,
    this.initialHotspot,
    this.initialCrop,
    required this.onChanged,
  });

  @override
  State<ImageHotspotEditor> createState() => _ImageHotspotEditorState();
}

class _ImageHotspotEditorState extends State<ImageHotspotEditor> {
  late final _crop = signal(
    widget.initialCrop ?? const CropRect(top: 0, bottom: 0, left: 0, right: 0),
  );
  late final _hotspot = signal(
    widget.initialHotspot ?? const Hotspot(x: 0.5, y: 0.5, width: 0.3, height: 0.3),
  );

  // Track which element is being dragged
  String? _dragTarget; // 'hotspot', 'crop_top', 'crop_bottom', etc.

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('hotspot_editor'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image with overlay
        AspectRatio(
          aspectRatio: 16 / 9, // Will be replaced with actual image aspect ratio
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onPanStart: (details) => _onPanStart(details, constraints.biggest),
                onPanUpdate: (details) => _onPanUpdate(details, constraints.biggest),
                onPanEnd: (_) => _dragTarget = null,
                child: Stack(
                  children: [
                    // Base image
                    Positioned.fill(
                      child: Image.network(widget.imageUrl, fit: BoxFit.contain),
                    ),
                    // Crop overlay
                    Positioned.fill(
                      child: Watch((context) => CustomPaint(
                        painter: CropOverlayPainter(
                          crop: _crop.value,
                          imageSize: constraints.biggest,
                        ),
                      )),
                    ),
                    // Hotspot overlay
                    Positioned.fill(
                      child: Watch((context) => CustomPaint(
                        painter: HotspotPainter(hotspot: _hotspot.value),
                      )),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Aspect ratio previews
        Watch((context) => AspectRatioPreviewStrip(
          imageUrl: widget.imageUrl,
          hotspot: _hotspot.value,
          crop: _crop.value,
        )),
        const SizedBox(height: 12),
        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ShadButton.outline(
              key: const ValueKey('reset_button'),
              onPressed: _reset,
              child: const Text('Reset'),
            ),
            const SizedBox(width: 8),
            ShadButton(
              key: const ValueKey('done_button'),
              onPressed: _done,
              child: const Text('Done'),
            ),
          ],
        ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details, Size size) {
    final pos = details.localPosition;
    final h = _hotspot.value;
    final hotspotCenter = Offset(h.x * size.width, h.y * size.height);

    // Check if near hotspot center (within 20px)
    if ((pos - hotspotCenter).distance < 20) {
      _dragTarget = 'hotspot';
      return;
    }

    // Check crop handles (simplified — check proximity to edges)
    final c = _crop.value;
    final topY = c.top * size.height;
    final bottomY = size.height - c.bottom * size.height;
    final leftX = c.left * size.width;
    final rightX = size.width - c.right * size.width;

    if ((pos.dy - topY).abs() < 15) _dragTarget = 'crop_top';
    else if ((pos.dy - bottomY).abs() < 15) _dragTarget = 'crop_bottom';
    else if ((pos.dx - leftX).abs() < 15) _dragTarget = 'crop_left';
    else if ((pos.dx - rightX).abs() < 15) _dragTarget = 'crop_right';
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    final pos = details.localPosition;
    switch (_dragTarget) {
      case 'hotspot':
        _hotspot.value = _hotspot.value.copyWith(
          x: (pos.dx / size.width).clamp(0.0, 1.0),
          y: (pos.dy / size.height).clamp(0.0, 1.0),
        );
      case 'crop_top':
        _crop.value = CropRect(
          top: (pos.dy / size.height).clamp(0.0, 1.0 - _crop.value.bottom - 0.1),
          bottom: _crop.value.bottom,
          left: _crop.value.left,
          right: _crop.value.right,
        );
      case 'crop_bottom':
        _crop.value = CropRect(
          top: _crop.value.top,
          bottom: (1.0 - pos.dy / size.height).clamp(0.0, 1.0 - _crop.value.top - 0.1),
          left: _crop.value.left,
          right: _crop.value.right,
        );
      case 'crop_left':
        _crop.value = CropRect(
          top: _crop.value.top,
          bottom: _crop.value.bottom,
          left: (pos.dx / size.width).clamp(0.0, 1.0 - _crop.value.right - 0.1),
          right: _crop.value.right,
        );
      case 'crop_right':
        _crop.value = CropRect(
          top: _crop.value.top,
          bottom: _crop.value.bottom,
          left: _crop.value.left,
          right: (1.0 - pos.dx / size.width).clamp(0.0, 1.0 - _crop.value.left - 0.1),
        );
    }
  }

  void _reset() {
    _crop.value = const CropRect(top: 0, bottom: 0, left: 0, right: 0);
    _hotspot.value = const Hotspot(x: 0.5, y: 0.5, width: 0.3, height: 0.3);
  }

  void _done() {
    widget.onChanged((hotspot: _hotspot.value, crop: _crop.value));
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk/lib/src/inputs/hotspot/
git commit -m "feat: add ImageHotspotEditor with crop overlay, hotspot ellipse, aspect ratio previews"
```

---

### Task 11: Media Browser

**Files:**
- Create: `packages/dart_desk/lib/src/media/browser/media_browser_state.dart`
- Create: `packages/dart_desk/lib/src/media/browser/media_toolbar.dart`
- Create: `packages/dart_desk/lib/src/media/browser/media_grid.dart`
- Create: `packages/dart_desk/lib/src/media/browser/media_list_view.dart`
- Create: `packages/dart_desk/lib/src/media/browser/asset_detail_panel.dart`
- Create: `packages/dart_desk/lib/src/media/browser/media_browser.dart`

**Context:** This is the largest UI component. Build bottom-up: state → toolbar → grid → detail panel → browser shell.

- [ ] **Step 1: Create media_browser_state.dart**

Signals-based state for the media browser:

```dart
// packages/dart_desk/lib/src/media/browser/media_browser_state.dart
import 'package:signals/signals.dart';
import '../../data/cms_data_source.dart';
import '../../data/models/media_asset.dart';
import '../../data/models/media_page.dart';
import '../../data/models/image_types.dart';

class MediaBrowserState {
  final CmsDataSource dataSource;

  // Filter/search state
  final search = signal('');
  final typeFilter = signal(MediaTypeFilter.all);
  final sort = signal(MediaSort.dateDesc);
  final page = signal(0);
  final pageSize = 24;

  // View state
  final isGridView = signal(true);
  final selectedAssetId = signal<String?>(null);
  final isLoading = signal(false);

  // Data
  final assets = signal<List<MediaAsset>>([]);
  final totalCount = signal(0);

  MediaBrowserState({required this.dataSource});

  Future<void> loadAssets() async {
    isLoading.value = true;
    try {
      final result = await dataSource.listMedia(
        search: search.value.isEmpty ? null : search.value,
        type: typeFilter.value,
        sort: sort.value,
        limit: pageSize,
        offset: page.value * pageSize,
      );
      assets.value = result.items;
      totalCount.value = result.total;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAsset(String assetId) async {
    await dataSource.deleteMedia(assetId);
    await loadAssets();
    if (selectedAssetId.value == assetId) {
      selectedAssetId.value = null;
    }
  }

  int get totalPages => (totalCount.value / pageSize).ceil();
}
```

- [ ] **Step 2: Create media_toolbar.dart**

Search input, type filter dropdown, sort dropdown, grid/list toggle. Uses shadcn_ui components.

```dart
// packages/dart_desk/lib/src/media/browser/media_toolbar.dart
// Contains: search ShadInput, ShadSelect for type filter, ShadSelect for sort,
// ShadButton.outline toggle for grid/list view.
// All controls read/write from MediaBrowserState signals.
// On any filter change, calls state.loadAssets().
// Key: ValueKey('media_search'), ValueKey('media_filter_type'), etc.
```

- [ ] **Step 3: Create media_grid.dart**

Grid of asset thumbnails with blurHash placeholders and drag sources.

```dart
// packages/dart_desk/lib/src/media/browser/media_grid.dart
// GridView.builder with SliverGridDelegateWithMaxCrossAxisExtent (150px).
// Each tile: Stack with blurHash background + Image.network on top.
// Selected tile has a blue border.
// Each tile is a DragItemWidget (super_drag_and_drop) for drag-to-field.
// OnTap: sets state.selectedAssetId.
// Key per tile: ValueKey('media_grid_item_${asset.assetId}').
```

- [ ] **Step 4: Create media_list_view.dart**

Alternative list view (file name, type, size, date, thumbnail).

- [ ] **Step 5: Create asset_detail_panel.dart**

Side panel showing full asset details when an asset is selected.

```dart
// packages/dart_desk/lib/src/media/browser/asset_detail_panel.dart
// Shows: large preview, filename, dimensions, file size, mimeType, upload date.
// Editable alt text ShadInput.
// Palette colors as colored squares (if metadataStatus == complete).
// EXIF summary (camera, lens if available).
// Usage count via dataSource.getMediaUsageCount().
// metadataStatus indicator: pending (spinner), complete (checkmark), failed (warning).
// If pending, polls dataSource.getMediaAsset() every 2 seconds until complete/failed.
// Actions: "Edit crop" button, "Replace" button, "Delete" button.
// Delete disabled with tooltip when usage > 0.
```

- [ ] **Step 6: Create media_browser.dart**

Shell widget combining toolbar, grid/list, and detail panel.

```dart
// packages/dart_desk/lib/src/media/browser/media_browser.dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import '../../data/cms_data_source.dart';
import '../../data/models/media_asset.dart';
import 'media_browser_state.dart';
import 'media_toolbar.dart';
import 'media_grid.dart';
import 'media_list_view.dart';
import 'asset_detail_panel.dart';

enum MediaBrowserMode { standalone, picker }

class MediaBrowser extends StatefulWidget {
  final CmsDataSource dataSource;
  final MediaBrowserMode mode;
  /// Called when user selects an asset in picker mode.
  final ValueChanged<MediaAsset>? onAssetSelected;
  final VoidCallback? onClose;

  const MediaBrowser({
    super.key,
    required this.dataSource,
    this.mode = MediaBrowserMode.standalone,
    this.onAssetSelected,
    this.onClose,
  });

  @override
  State<MediaBrowser> createState() => _MediaBrowserState();
}

class _MediaBrowserState extends State<MediaBrowser> {
  late final _state = MediaBrowserState(dataSource: widget.dataSource);

  @override
  void initState() {
    super.initState();
    _state.loadAssets();
  }

  @override
  Widget build(BuildContext context) {
    // Layout:
    // - Header: "Media Library" title + Upload button + Close button
    // - MediaToolbar
    // - Body: Row of [grid/list (flex 2)] + [detail panel (flex 1) if asset selected]
    // - Footer: pagination
    // The whole thing is a DropRegion for OS file drops (uploads immediately).
    // In picker mode, double-click or "Select" button calls onAssetSelected.
    return const Placeholder(); // Full implementation in actual code
  }
}
```

- [ ] **Step 7: Commit**

```bash
git add packages/dart_desk/lib/src/media/browser/
git commit -m "feat: add MediaBrowser with grid, list, search, detail panel, drag support"
```

---

### Task 12: Wire Up Barrel Exports & Studio Integration

**Files:**
- Modify: `packages/dart_desk/lib/studio.dart` (or main barrel)
- Modify: `packages/dart_desk/lib/src/studio/screens/document_editor.dart` (if image fields are rendered here)

- [ ] **Step 1: Export new public API from barrel file**

Add exports for:
- `MediaAsset`, `ImageReference`, `ImageUrl`, `TransformUrlBuilder`
- `MediaBrowser`, `MediaBrowserMode`
- `ImageHotspotEditor`
- `Hotspot`, `CropRect`, `FitMode`, `MediaPalette`, etc.

- [ ] **Step 2: Integrate MediaBrowser into studio sidebar/routes**

Add a "Media" route to the studio navigation that opens `MediaBrowser` in standalone mode. This depends on the existing zenrouter setup — add a new route alongside document type routes.

- [ ] **Step 3: Verify full compilation**

Run: `cd packages/dart_desk && flutter analyze`
Expected: Clean analysis (no errors).

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk/lib/
git commit -m "feat: export image system API and integrate media browser into studio"
```

---

### Task 13: AwsImageStorageProvider (dart_desk_cloud)

**Files:**
- Create: `dart_desk_cloud/lib/src/services/aws_image_storage_provider.dart`
- Modify: `dart_desk_cloud/lib/src/cloud_server.dart`

- [ ] **Step 1: Create the AWS provider**

```dart
// dart_desk_cloud/lib/src/services/aws_image_storage_provider.dart
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import 'package:dart_desk_be_server/src/services/image_storage_provider.dart';

/// AWS implementation: S3 for storage, AWS Serverless Image Handler for transforms.
class AwsImageStorageProvider implements ImageStorageProvider {
  final Session session;
  final String transformHost; // e.g., 'transforms.dartdesk.dev'

  AwsImageStorageProvider({
    required this.session,
    required this.transformHost,
  });

  @override
  Future<String> store(String assetId, String fileName, Uint8List data) async {
    final storagePath = 'media/$assetId/$fileName';
    await session.storage.storeFile(
      storageId: 'public',
      path: storagePath,
      byteData: ByteData.sublistView(data),
    );
    final publicUrl = (await session.storage.getPublicUrl(
      storageId: 'public',
      path: storagePath,
    )).toString();
    return publicUrl;
  }

  @override
  Future<void> delete(String storagePath) async {
    await session.storage.deleteFile(
      storageId: 'public',
      path: storagePath,
    );
  }

  @override
  String? transformUrl(String publicUrl, ImageTransformParams params) {
    // Build AWS Serverless Image Handler (Thumbor-compatible) URL
    final segments = <String>[];

    // Filters
    final filters = <String>[];
    if (params.crop != null) {
      // CropRect: trim edges. Convert fractions to percentage-based trim.
      // Thumbor uses pixel-based crop, so this needs the original dimensions.
      // For now, pass as a custom filter or handle in the focal point.
    }
    if (params.format != null) filters.add('format(${params.format})');
    if (params.quality != null) filters.add('quality(${params.quality})');
    if (filters.isNotEmpty) segments.add('filters:${filters.join(':')}');

    // Fit and dimensions
    if (params.width != null || params.height != null) {
      final w = params.width ?? 0;
      final h = params.height ?? 0;
      final fit = params.fit ?? FitMode.clip;
      if (fit == FitMode.clip || fit == FitMode.max) {
        segments.insert(0, 'fit-in/${w}x$h');
      } else {
        segments.insert(0, '${w}x$h');
      }
    }

    // Focal point
    if (params.fpX != null && params.fpY != null) {
      // Thumbor uses smart cropping with focal point
      segments.add('smart');
    }

    if (segments.isEmpty) return null; // No transforms needed

    // Extract the path from the public URL
    final uri = Uri.parse(publicUrl);
    final path = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;

    return 'https://$transformHost/${segments.join("/")}/$path';
  }
}
```

- [ ] **Step 2: Register in cloud_server.dart**

After the S3 storage registration, store a reference to the transform host from passwords config so it can be passed to endpoint sessions.

- [ ] **Step 3: Commit**

```bash
git add dart_desk_cloud/lib/src/services/aws_image_storage_provider.dart \
       dart_desk_cloud/lib/src/cloud_server.dart
git commit -m "feat(cloud): add AwsImageStorageProvider with Serverless Image Handler transforms"
```

---

### Task 14: Terraform for AWS Serverless Image Handler

**Files:**
- Create: `dart_desk_cloud/deploy/aws/terraform/image_handler.tf`

- [ ] **Step 1: Create Terraform config**

Deploy the AWS Serverless Image Handler CloudFormation stack via Terraform's `aws_cloudformation_stack` resource, or define the equivalent resources (CloudFront distribution + Lambda@Edge + IAM role) directly in Terraform.

Key resources:
- CloudFront distribution at `transforms.dartdesk.dev`
- Lambda@Edge function using Sharp for image transforms
- Origin pointing to the existing S3 public bucket
- Route53 CNAME for `transforms.dartdesk.dev`
- ACM certificate (or use existing wildcard cert)

```hcl
# dart_desk_cloud/deploy/aws/terraform/image_handler.tf
# Reference the existing S3 bucket
# Define Lambda@Edge for image transforms
# Define CloudFront distribution for transforms.dartdesk.dev
# Route53 CNAME
```

- [ ] **Step 2: Commit**

```bash
git add dart_desk_cloud/deploy/aws/terraform/image_handler.tf
git commit -m "infra: add Terraform for AWS Serverless Image Handler (transforms CDN)"
```

---

### Task 15: Add ValueKeys & Test Document Type for E2E

**Files:**
- Modify: `packages/dart_desk/lib/src/testing/test_document_types.dart`
- Modify: `packages/dart_desk/lib/src/inputs/image_input.dart` (add ValueKeys if not already present)
- Modify: `examples/cms_app/lib/main_test.dart`

**Context:** Marionette finds elements by `ValueKey<String>`. We need keys on all interactive elements and an image field in the test document type.

- [ ] **Step 1: Add image field to test document type**

In `test_document_types.dart`, add an `@CmsImageField` to the `allFieldsDocumentType` or create a dedicated image test document type.

- [ ] **Step 2: Verify ValueKeys are present on all interactive elements**

Check that these keys exist in the widgets built in previous tasks:
- `image_input_{fieldName}` on CmsImageInput root
- `upload_button` on the pick/upload button
- `edit_crop_button` on the edit crop button
- `hotspot_editor` on ImageHotspotEditor root
- `done_button` and `reset_button` in the editor
- `media_browser` on MediaBrowser root
- `media_search` on the search input
- `media_filter_type` on the type filter
- `media_grid_item_{assetId}` on each grid item

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/lib/src/testing/test_document_types.dart \
       packages/dart_desk/lib/src/inputs/ \
       examples/cms_app/lib/main_test.dart
git commit -m "feat: add ValueKeys and image test document type for Marionette e2e"
```

---

### Task 16: E2E Tests with Marionette

**Context:** E2E tests are run interactively via Marionette MCP tools against the running `examples/cms_app` (main_test.dart entry point with MockCmsDataSource). Use `@marionette-testing` skill for interaction patterns.

**Prerequisites:**
- Launch the test app: use `mcp__dart__launch_app` with the `main_test.dart` entry point
- Connect Marionette to the running app's VM service URI

- [ ] **Step 1: Upload flow test**

Using Marionette MCP tools:
1. `mcp__marionette__connect` to VM service URI
2. `mcp__marionette__get_interactive_elements` — find the image input field
3. `mcp__marionette__tap` on `upload_button`
4. `mcp__marionette__take_screenshots` — verify image picker opened or image preview shown
5. Verify blurHash placeholder appears (screenshot check)
6. Verify final image URL is displayed after upload completes

- [ ] **Step 2: Hotspot/crop UI test**

1. After upload, `mcp__marionette__tap` on `edit_crop_button`
2. `mcp__marionette__take_screenshots` — verify hotspot editor overlay
3. Verify crop rectangle and hotspot ellipse are visible
4. `mcp__marionette__tap` on `done_button`
5. `mcp__marionette__take_screenshots` — verify editor closed, image field shows updated crop

- [ ] **Step 3: Media browser test**

1. Navigate to media library route
2. `mcp__marionette__get_interactive_elements` — verify grid items present
3. `mcp__marionette__tap` on `media_search`, then `mcp__marionette__enter_text` with a search term
4. `mcp__marionette__take_screenshots` — verify filtered results
5. `mcp__marionette__tap` on a grid item — verify detail panel appears
6. `mcp__marionette__take_screenshots` — verify metadata shown

- [ ] **Step 4: Media browser picker mode test**

1. Navigate to a document with an image field
2. Tap "Browse media" button on the image input
3. Verify media browser opens in picker mode
4. Tap an asset in the grid
5. Verify the image field is populated with the selected asset

- [ ] **Step 5: Document findings and take final screenshots**

Take screenshots of:
- Empty image field state
- Image field with blurHash placeholder during upload
- Image field with loaded image
- Hotspot editor with crop and hotspot
- Media browser in grid view
- Media browser detail panel with metadata
- Media browser in picker mode

---

## Build Order Summary

```
Task 1:  Serverpod MediaAsset model          (dart_desk_be)
Task 2:  ImageStorageProvider interface       (dart_desk_be)
Task 3:  Update MediaEndpoint                 (dart_desk_be)
Task 4:  Metadata extractor                   (dart_desk_be)
  ↓
Task 5:  Client data models                   (dart_desk)
Task 6:  Update CmsDataSource + Mock          (dart_desk)
Task 7:  Quick metadata extractor             (dart_desk)
Task 8:  ImageUrl builder                     (dart_desk)
  ↓
Task 9:  Rewrite CmsImageInput                (dart_desk)
Task 10: Hotspot/crop editor                  (dart_desk)
Task 11: Media browser                        (dart_desk)
Task 12: Barrel exports + studio integration  (dart_desk)
  ↓
Task 13: AwsImageStorageProvider              (dart_desk_cloud)
Task 14: Terraform image handler              (dart_desk_cloud)
  ↓
Task 15: ValueKeys + test document type       (dart_desk + examples)
Task 16: E2E tests with Marionette            (interactive)
```

Tasks 1-4 are backend (can be done first in dart_desk_be).
Tasks 5-12 are client library (depend on 1-4 for model alignment).
Tasks 13-14 are cloud infra (independent of 5-12 but need 1-4).
Tasks 15-16 are testing (depend on everything above).
