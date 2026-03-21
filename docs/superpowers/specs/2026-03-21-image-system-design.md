# Image System Design — Sanity-inspired Architecture

**Date:** 2026-03-21
**Status:** Draft
**Scope:** dart_desk (Flutter library), dart_desk_be (Serverpod backend), dart_desk_cloud (cloud infra)

## Overview

A Sanity-inspired image uploading, processing, and management system for dart_desk. Core principles:

- **Asset-as-document**: Images are stored as reusable asset records, referenced by content documents
- **Context-specific crop/hotspot**: Each usage of an image can have its own hotspot and crop
- **URL-based transforms**: Server-side image processing via CDN URL parameters
- **Split metadata extraction**: Client extracts basics immediately, server enriches asynchronously
- **Works OOTB on cloud, pluggable for self-host**

## Data Model

### MediaAsset (asset-as-document, in dart_desk_be)

Replaces the current `MediaFile` model. One record per uploaded file, reusable across documents.

| Field | Type | Notes |
|---|---|---|
| id | int | PK |
| assetId | String | Unique, content-hash based: `image-{hash}-{WxH}-{ext}` |
| fileName | String | Original filename |
| mimeType | String | e.g. `image/jpeg` |
| fileSize | int | Bytes |
| publicUrl | String | CDN URL to original |
| width | int | Pixels |
| height | int | Pixels |
| hasAlpha | bool | Transparency info |
| blurHash | String | BlurHash string for placeholder |
| lqip | String? | Tiny base64 thumbnail, set async |
| palette | MediaPalette? | Color palette, set async |
| exif | Map\<String, dynamic\>? | Camera data, set async |
| location | MediaGeoLocation? | Lat/lng, set async |
| uploadedBy | int? | User ID |
| createdAt | DateTime | |
| metadataStatus | enum | pending \| complete \| failed |

### ImageReference (per-usage, on content documents)

What an image field value looks like — references the asset + context-specific crop/hotspot.

| Field | Type | Notes |
|---|---|---|
| asset | MediaAsset | Reference to asset record |
| hotspot | Hotspot? | `{ x, y, width, height }` — 0-1 fractions |
| crop | CropRect? | `{ top, bottom, left, right }` — 0-1 fractions |
| altText | String? | Per-usage alt text |

### Supporting types

```
MediaPalette { dominant, vibrant?, muted?, darkMuted? } → PaletteColor { r, g, b, hex }
MediaGeoLocation { lat, lng }
Hotspot { x, y, width, height }    // all 0.0–1.0
CropRect { top, bottom, left, right }  // all 0.0–1.0
```

### ImageReference JSON serialization (in document data)

When stored in a document's `data: Map<String, dynamic>`, an image field value is serialized as:

```json
{
  "_type": "imageReference",
  "assetId": "image-a1b2c3-1920x1080-jpg",
  "hotspot": { "x": 0.5, "y": 0.3, "width": 0.4, "height": 0.3 },
  "crop": { "top": 0.0, "bottom": 0.1, "left": 0.0, "right": 0.05 },
  "altText": "A sunset over the ocean"
}
```

`CmsImageInput.onChanged` changes from `ValueChanged<String?>` (plain URL) to `ValueChanged<Map<String, dynamic>?>` (serialized ImageReference). This is a **breaking change** to the existing API.

### Key decisions

- `assetId` uses content-hash so the same file uploaded twice is deduplicated
- Hotspot/crop live on `ImageReference`, not `MediaAsset` — same image, different crops per usage
- `metadataStatus` tracks async enrichment so the UI knows when palette/EXIF are ready
- `altText` lives on the reference (per-usage), not the asset
- Deduplication: `assetId` has a **unique constraint** at the database level. On conflict (race condition), the server catches the constraint violation, re-fetches the existing record, and returns it

## Updated CmsDataSource Interface

The existing `CmsDataSource` interface is updated to reflect the new model. `MediaFile` is replaced by `MediaAsset`, and the upload signature accepts quick metadata.

```dart
// Replaces the old MediaFile-based methods
abstract class CmsDataSource {
  // ... existing document methods unchanged ...

  // --- Media (updated) ---

  /// Upload an image with client-extracted quick metadata.
  /// Returns the MediaAsset (existing if deduplicated, new otherwise).
  Future<MediaAsset> uploadImage(
    String fileName,
    Uint8List fileData,
    QuickImageMetadata metadata,
  );

  /// Upload a non-image file.
  Future<MediaAsset> uploadFile(String fileName, Uint8List fileData);

  /// Delete a media asset. Fails if asset is still referenced by documents.
  Future<bool> deleteMedia(String assetId);

  /// Get a single asset by ID.
  Future<MediaAsset?> getMediaAsset(String assetId);

  /// List/search media assets with filtering and sorting.
  Future<MediaPage> listMedia({
    String? search,          // filename, alt text
    MediaTypeFilter? type,   // image, video, file, all
    MediaSort sort = MediaSort.dateDesc,
    int limit = 50,
    int offset = 0,
  });

  /// Update mutable asset fields (alt text on the asset level is not used,
  /// but fileName can be renamed).
  Future<MediaAsset> updateMediaAsset(String assetId, {String? fileName});

  /// Get usage count: how many documents reference this asset.
  Future<int> getMediaUsageCount(String assetId);
}

class QuickImageMetadata {
  final int width;
  final int height;
  final bool hasAlpha;
  final String blurHash;
  final String contentHash;  // SHA-256 hex string
}

class MediaPage {
  final List<MediaAsset> items;
  final int total;
}

enum MediaTypeFilter { image, video, file, all }
enum MediaSort { dateDesc, dateAsc, nameAsc, nameDesc, sizeDesc, sizeAsc }
```

### Migration from MediaFile

`MediaFile` and `MediaUploadResult` are deprecated and replaced by `MediaAsset`. Existing `CmsDataSource` implementations (including `MockCmsDataSource`) must be updated.

## Upload Flow

### Sequence

```
1. User picks image in CmsImageInput
2. Client extracts quick metadata:
   - Decode image → width, height, hasAlpha
   - Generate blurHash
   - Compute content hash (SHA-256 of file bytes)
3. Client calls: uploadImage(fileName, fileData, quickMetadata)
4. Server checks: does a MediaAsset with this content hash exist?
   ├─ YES → return existing asset reference (deduplication)
   └─ NO  → continue
5. Server generates assetId: "image-{hash}-{width}x{height}-{ext}"
6. Server stores file to CloudStorage (S3 in cloud, local in dev)
7. Server creates MediaAsset record with client + server metadata
   - metadataStatus: pending
8. Server returns MediaAsset to client immediately
9. Server dispatches async metadata job:
   - Extract: palette, LQIP, EXIF, geolocation
   - Update MediaAsset, set metadataStatus: complete
```

### Platform considerations

- **Isolate usage**: Client-side metadata extraction (decode + blurHash + SHA-256) runs in a **separate isolate** via `compute()` to avoid UI jank on large images (>2-3 MB)
- **HEIC/HEIF**: iOS `image_picker` returns HEIC by default. The `image` package cannot decode HEIC. Mitigation: set `image_picker`'s `requestFullMetadata: false` and request JPEG output, or accept that HEIC files skip client-side dimension extraction and let the server handle it
- **Web**: `image_picker` on web returns blob URLs. Reading full bytes for SHA-256 is memory-intensive for large files. For web, compute hash from the first 1MB + file size as a fast fingerprint, with full-hash dedup as a server-side fallback
- **BlurHash on web**: `blurhash_dart` requires FFI. Use a pure-Dart BlurHash encoder (e.g., `blurhash` package) or fall back to server-side generation for web platform

### Abstract interface (dart_desk_be)

```dart
abstract class ImageStorageProvider {
  /// Store file, return public URL
  Future<String> store(String assetId, String fileName, Uint8List data);

  /// Delete file
  Future<void> delete(String assetId);

  /// Generate a transform URL for the given asset
  /// Returns null if transforms not supported (self-host fallback)
  String? transformUrl(String publicUrl, ImageTransformParams params);
}

class ImageTransformParams {
  final int? width;
  final int? height;
  final FitMode? fit;       // clip, crop, fill, max, scale
  final String? format;     // jpg, png, webp, avif
  final int? quality;       // 0-100
  final double? fpX, fpY;   // focal point from hotspot (0-1)
  final CropRect? crop;
}
```

### Implementations

- **`AwsImageStorageProvider`** (dart_desk_cloud): Uses Serverpod S3 storage, generates AWS Serverless Image Handler URLs
- **`LocalImageStorageProvider`** (dart_desk_be, default): Serverpod local file storage, `transformUrl()` returns `null`

## Image Transform Pipeline

### URL-based transforms (cloud)

```
Original:    https://storage.dartdesk.dev/image-a1b2c3-1920x1080-jpg
Transformed: https://transforms.dartdesk.dev/filters:quality(80)/fit-in/400x300/image-a1b2c3-1920x1080-jpg
```

### Capabilities (via AWS Serverless Image Handler)

| Operation | Example | Notes |
|---|---|---|
| Resize | `fit-in/400x300` | Fit within bounds |
| Crop to aspect | `400x300` (no fit-in) | Exact dimensions |
| Focal point crop | Uses hotspot x,y | Smart crop around subject |
| Format conversion | `filters:format(webp)` | jpg, png, webp, avif |
| Quality | `filters:quality(80)` | 0–100 |
| Blur | `filters:blur(10)` | Placeholder effect |
| Sharpen | `filters:sharpen(1,0.5,0)` | Post-resize |

### Processing order

**crop → resize → effects** (same as Sanity)

1. Apply CropRect (trim edges based on 0-1 fractions)
2. Apply focal point from Hotspot (center crop around x,y)
3. Resize to requested dimensions
4. Apply format conversion, quality, blur, sharpen
5. Cache at CDN edge

### Infrastructure (dart_desk_cloud)

Separate CloudFront distribution for transforms (`transforms.dartdesk.dev`) vs originals (`storage.dartdesk.dev`).

```
Client request → CloudFront (transforms.dartdesk.dev)
  → cache miss → Lambda@Edge (Sharp via AWS Serverless Image Handler)
  → reads original from S3
  → transforms + returns → CloudFront caches result
```

### Client-side URL builder (dart_desk)

The `ImageUrl` builder lives in dart_desk and depends on a **client-side interface** (`TransformUrlBuilder`), not the server-side `ImageStorageProvider` directly. This avoids a cross-package dependency.

```dart
/// Defined in dart_desk — client-side only
typedef TransformUrlBuilder = String? Function(String publicUrl, ImageTransformParams params);
```

```dart
class ImageUrl {
  final ImageReference imageRef;
  final TransformUrlBuilder? transformUrl;

  String url({int? width, int? height, FitMode? fit, String? format, int? quality}) {
    final params = ImageTransformParams(
      width: width, height: height, fit: fit, format: format, quality: quality,
      fpX: imageRef.hotspot?.x, fpY: imageRef.hotspot?.y,
      crop: imageRef.crop,
    );
    return transformUrl?.call(imageRef.asset.publicUrl, params)
        ?? imageRef.asset.publicUrl;
  }

  String get blurHash => imageRef.asset.blurHash;
}
```

## Hotspot & Crop UI

### Widget: `ImageHotspotEditor`

Full Sanity-style interactive editor overlaid on the image.

```
┌──────────────────────────────────┐
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │  ← Darkened crop-out area
│  │  ┌─────────────────────┐  │  │
│  │  │                     │  │  │  ← Visible crop region (draggable edges)
│  │  │      (●)            │  │  │  ← Hotspot ellipse (draggable, resizable)
│  │  │                     │  │  │
│  │  └─────────────────────┘  │  │
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
│  Aspect ratio previews:          │
│  ┌──────┐ ┌────┐ ┌─┐            │
│  │ 16:9 │ │ 4:3│ │1│            │
│  │      │ │    │ │:│            │
│  └──────┘ └────┘ │1│            │
│                   └─┘            │
│           [Done]  [Reset]        │
└──────────────────────────────────┘
```

### Interactions

| Action | Behavior |
|---|---|
| Drag crop edges/corners | Adjusts CropRect (top/bottom/left/right) |
| Drag hotspot ellipse | Moves hotspot center (x, y) |
| Drag hotspot handles | Resizes hotspot ellipse (width, height) |
| Aspect ratio preview | Live preview respecting hotspot |
| Done | Saves hotspot + crop to ImageReference |
| Reset | Clears to defaults |

### Data flow

```
User drags hotspot/crop
  → ImageHotspotEditor updates local state (signals)
  → Aspect ratio previews re-render live
  → User clicks Done
  → onChanged emits updated ImageReference
  → Content document saves reference (asset unchanged)
```

### Built with

- **shadcn_ui** for modal, buttons, layout
- **signals** for reactive state
- **CustomPainter** for overlay (crop darkening, hotspot ellipse, drag handles)
- **GestureDetector** for drag interactions

## Media Browser

### Layout

```
┌──────────────────────────────────────────────────────┐
│ Media Library                        [Upload] [Close]│
├──────────────────────────────────────────────────────┤
│ [Search...          ]  [Type ▾] [Sort ▾] [Grid│List] │
├──────────────────────────────────────────────────────┤
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐        │
│ │ img1 │ │ img2 │ │ img3 │ │ img4 │ │ img5 │        │
│ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘        │
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐                 │
│ │ img6 │ │ img7 │ │ img8 │ │ img9 │  ← draggable   │
│ └──────┘ └──────┘ └──────┘ └──────┘                  │
├──────────────────────────────────────────────────────┤
│ Showing 9 of 142            [← 1 2 3 ... 15 →]      │
└──────────────────────────────────────────────────────┘
```

### Two modes

| Mode | Triggered by | Behavior |
|---|---|---|
| **Standalone** | Studio sidebar/menu | Browse, upload, delete, edit metadata |
| **Picker** | Image field click | Same UI + select/drag to return ImageReference |

### Drag & drop (via `super_drag_and_drop`)

| Interaction | Source | Target |
|---|---|---|
| OS file → image field | Finder/desktop | CmsImageInput drop zone |
| OS file → media browser | Finder/desktop | Media browser drop zone (uploads immediately) |
| Media browser → image field | Grid item | CmsImageInput drop zone |
| Multi-select drag | Grid items (shift/cmd) | Image field or batch operations |

### Asset detail panel

Shows on thumbnail click: preview, dimensions, file size, format, upload date, alt text (editable), palette colors, EXIF data, usage count ("Used in: 3 documents"), and actions (edit crop, replace, delete).

### Search & filter

- **Text search**: filename, alt text
- **Type filter**: images, videos, files, all
- **Sort**: date uploaded, file name, file size
- **Pagination**: server-side, configurable page size

### Built with

- **shadcn_ui** for layout, buttons, inputs, dialog
- **signals** for reactive search/filter/selection state
- **super_drag_and_drop** for all drag interactions
- BlurHash placeholders while thumbnails load

## Self-host Story

| Layer | Cloud (OOTB) | Self-host |
|---|---|---|
| Storage | S3 via `AwsImageStorageProvider` | Serverpod local storage, or custom `ImageStorageProvider` |
| Transforms | AWS Serverless Image Handler | `transformUrl()` returns `null` → originals served. Or plug in Thumbor/Imgix. |
| CDN | CloudFront | None, or Nginx/Cloudflare in front |
| Metadata extraction | Same server-side code | Same — no cloud dependency |
| Hotspot/crop UI | Same | Same — fully client-side |
| Media browser | Same | Same |

Everything in dart_desk and dart_desk_be works without transforms. The `ImageUrl` builder gracefully falls back to the original URL.

## Edge Cases & Safety

### Async metadata completion notification

The client learns about metadata enrichment completion via **polling on the asset detail panel**. When a user opens the detail panel for an asset with `metadataStatus: pending`, the panel polls `getMediaAsset()` every 2 seconds until status is `complete` or `failed`. No WebSocket/streaming needed — enrichment typically completes within seconds, and the palette/EXIF data is only shown in the detail panel (not latency-sensitive).

### Delete safety / referential integrity

- `deleteMedia()` calls `getMediaUsageCount()` first. If usage > 0, the delete is **blocked** and returns an error with the count.
- The media browser UI shows "Used in N documents" and disables the delete button when N > 0, with a tooltip explaining why.
- No soft-delete or cascading — assets are either in use (protected) or unused (deletable).

### Server-side validation

The upload endpoint validates before storing:
- **Max file size**: 10 MB (configurable via Serverpod config, already set in production.yaml)
- **Accepted MIME types**: `image/jpeg`, `image/png`, `image/webp`, `image/gif`, `image/svg+xml`, `image/avif`, `image/heic`, `image/heif`, `image/tiff`, `image/bmp` for image uploads. Configurable.
- **Rejection**: returns a typed error with reason (file too large, unsupported type)

### Processing order clarification

CropRect and Hotspot serve different roles in the transform pipeline:
1. **CropRect** trims the source image (absolute edge removal based on 0-1 fractions)
2. **Hotspot** is passed as a **focal point** (`fpX`/`fpY`) to guide the resize step's smart-crop — it is not a sequential crop operation
3. **Resize** applies with the focal point as the center of attention
4. **Effects** (format, quality, blur, sharpen) applied last

## E2E Testing with Marionette

### Test coverage

Using Marionette MCP to test the full image workflow in the running studio app.

#### Upload flow tests

| Test | Steps |
|---|---|
| Upload via file picker | Open CmsImageInput → tap pick button → verify image preview appears → verify blurHash placeholder shown during upload → verify final image displayed |
| Upload deduplication | Upload same image twice → verify single MediaAsset created → verify both fields reference same asset |
| Upload progress | Start upload → verify progress indicator visible → verify completion state |

#### Hotspot/crop UI tests

| Test | Steps |
|---|---|
| Open hotspot editor | Tap "Edit crop" on image field → verify overlay appears with crop rectangle and hotspot ellipse |
| Drag hotspot | Drag hotspot ellipse to new position → verify aspect ratio previews update live |
| Adjust crop | Drag crop edges → verify darkened area updates → verify preview updates |
| Save hotspot/crop | Adjust hotspot → tap Done → verify ImageReference updated with new values |
| Reset | Adjust hotspot → tap Reset → verify defaults restored |

#### Media browser tests

| Test | Steps |
|---|---|
| Open standalone | Open media library from sidebar → verify grid of assets displayed |
| Search | Type search query → verify results filter |
| Filter by type | Select image filter → verify only images shown |
| Open picker mode | Click image field browse button → verify media browser opens in picker mode |
| Select from picker | Click asset in picker mode → verify ImageReference returned to field |
| Asset detail | Click thumbnail → verify detail panel shows metadata, palette, EXIF |
| Delete asset | Click delete on asset → verify confirmation → verify removal |

#### Drag & drop tests

| Test | Steps |
|---|---|
| Drag from media browser to field | Open media browser + image field → drag thumbnail to field → verify ImageReference set |

#### Async metadata tests

| Test | Steps |
|---|---|
| Metadata enrichment | Upload image → open asset detail → verify metadataStatus shows pending → wait → verify palette and EXIF appear once complete |
| Metadata failure | Upload corrupted file → verify metadataStatus shows failed → verify detail panel shows graceful fallback |

#### Transform URL tests

| Test | Steps |
|---|---|
| Transformed image display | Upload image → set hotspot → render at specific size → verify transformed URL contains correct params |
| Fallback without transforms | Configure local storage provider → verify original URL served |

### Marionette setup

- Tests run against the example CMS app (`examples/cms_app`)
- Connect to VM service URI of the running app
- Use `ValueKey` annotations on all interactive elements:
  - `image_input_{fieldName}`, `hotspot_editor`, `crop_handle_{direction}`
  - `media_browser`, `media_grid_item_{assetId}`, `media_search`, `media_filter_type`
  - `upload_button`, `edit_crop_button`, `done_button`, `reset_button`
- Take screenshots at key checkpoints for visual verification

## Architecture Summary

```
dart_desk (Flutter library — pub.dev)
  ├─ CmsImageInput (pick + hotspot/crop + drop zone)
  ├─ ImageHotspotEditor (full interactive editor)
  ├─ MediaBrowser (grid, search, filter, drag, reuse)
  ├─ ImageUrl builder (generates transform URLs)
  └─ BlurHash placeholder rendering

dart_desk_be (Serverpod, open-source)
  ├─ MediaAsset model (asset-as-document)
  ├─ ImageReference model (per-usage hotspot/crop)
  ├─ Upload endpoint (store + dedup + return)
  ├─ Async metadata extraction (palette, EXIF, geo, LQIP)
  ├─ ImageStorageProvider (abstract interface)
  ├─ LocalImageStorageProvider (default, no transforms)
  └─ Media CRUD endpoints (list, search, delete)

dart_desk_cloud (closed-source)
  ├─ AwsImageStorageProvider (S3 + transform URLs)
  ├─ AWS Serverless Image Handler (CloudFront + Lambda@Edge)
  └─ CloudFront CDN (storage.dartdesk.dev + transforms.dartdesk.dev)
```

## Dependencies

### New packages

| Package | Where | Purpose |
|---|---|---|
| `super_drag_and_drop` | dart_desk | OS + in-app drag and drop |
| `blurhash` (pure Dart, web-compatible) | dart_desk | Client-side blurHash generation |
| `crypto` | dart_desk | SHA-256 content hashing |
| `image` (`pub.dev/packages/image`) | dart_desk_be | Server-side metadata extraction (palette, LQIP) |
| `exif` (`pub.dev/packages/exif`) | dart_desk_be | EXIF data extraction (pure Dart, works server-side) |

### Existing packages (already in use)

- `image_picker` — file selection
- `shadcn_ui` — UI components
- `signals` — reactive state
- `serverpod_cloud_storage_s3` — S3 integration (dart_desk_cloud)
