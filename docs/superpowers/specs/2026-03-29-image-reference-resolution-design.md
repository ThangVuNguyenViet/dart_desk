# Image Reference Resolution Design

**Date:** 2026-03-29
**Status:** Approved

## Problem

Image fields in consumer models are typed as `String` (URL only). The document JSON stores `imageReference` objects containing only `assetId` — no URL, no dimensions, no hotspot/crop data. A consumer receiving a `PublicDocument` cannot display images without making additional API calls to resolve each `assetId` to a `MediaAsset`.

Additionally, `ImageUrl` — the class designed to be the consumer-facing image helper — is unused because no pipeline wires `imageReference` data into it.

## Solution Overview

Resolve image references server-side at read time. Inline asset data into the document JSON before returning from `PublicContentEndpoint`. Change consumer model image fields from `String` to `ImageUrl`. Update codegen to emit `ImageUrl?` for `@CmsImageFieldConfig` fields.

---

## Section 1: Resolved JSON Format

`PublicContentEndpoint` enriches every `imageReference` node before returning it. The stored format:

```json
{ "_type": "imageReference", "assetId": "image-abc123-1920x1080-jpg" }
```

Becomes the resolved format:

```json
{
  "_type": "imageReference",
  "assetId": "image-abc123-1920x1080-jpg",
  "publicUrl": "https://...",
  "width": 1920,
  "height": 1080,
  "blurHash": "LGF5?xYk^6#M@-5c,1J5",
  "lqip": "data:image/jpeg;base64,...",
  "hotspot": { "x": 0.5, "y": 0.3, "width": 0.8, "height": 0.6 },
  "crop": null,
  "altText": "A cool photo"
}
```

- `assetId` is kept for SDK identification of resolved nodes
- Asset fields (`publicUrl`, `width`, `height`, `blurHash`, `lqip`) are inlined from `MediaAsset`
- `hotspot`, `crop`, `altText` stay on the reference (per-usage, not per-asset)

---

## Section 2: Consumer Model Type

Image fields change from `String` to `ImageUrl?`.

```dart
// Before
@CmsImageFieldConfig(
  description: 'Background image for the hero section',
  option: CmsImageOption(hotspot: false),
)
final String backgroundImageUrl;

// After
@CmsImageFieldConfig(
  description: 'Background image for the hero section',
  option: CmsImageOption(hotspot: false),
)
final ImageUrl? backgroundImage;
```

**Naming convention:** The `Url` suffix is dropped when renaming from `String` to `ImageUrl`. This is a manual rename for existing fields; codegen will use the Dart field name as-is going forward.

### `ImageUrl` additions

Two new members on the existing `ImageUrl` class:

**`fromJson` factory** — decodes the resolved JSON shape without a separate asset fetch:

```dart
factory ImageUrl.fromJson(Map<String, dynamic> json) {
  final asset = MediaAsset.fromInlineJson(json);
  final ref = ImageReference.fromDocumentJson(json, asset);
  return ImageUrl(imageRef: ref); // transformUrl: null initially
}
```

`MediaAsset.fromInlineJson` is a new factory on `MediaAsset` that reads the subset of fields present in the resolved image node (`assetId`, `publicUrl`, `width`, `height`, `blurHash`, `lqip`) and fills remaining required fields with safe defaults (e.g. `fileSize: 0`, `mimeType: 'image/*'`). It is distinct from `MediaAsset.fromJson`, which decodes a full DB record.

**`withTransform` method** — injects a `TransformUrlBuilder` after decode:

```dart
ImageUrl withTransform(TransformUrlBuilder builder) =>
    ImageUrl(imageRef: imageRef, transformUrl: builder);
```

### Consumer usage

```dart
// Raw URL — works immediately, no transform needed
Image.network(config.backgroundImage?.url() ?? '');

// With CDN transform — injected at app startup
Image.network(
  config.backgroundImage
      ?.withTransform(myImgixBuilder)
      .url(width: 800, fit: FitMode.crop) ?? '',
);

// Blur placeholder while loading
final blurHash = config.backgroundImage?.blurHash;
```

---

## Section 3: Backend — Image Reference Resolver

`PublicContentEndpoint._toPublicDocument` becomes async and resolves image references before returning.

### Resolution algorithm

1. Walk the document `data` JSON recursively, collect all unique `assetId` values from nodes where `_type == 'imageReference'`
2. If none found, return early (no DB query)
3. Batch-fetch: `SELECT * FROM media_assets WHERE asset_id IN (...)`  — one query, uses the existing unique index `media_asset_asset_id_idx`
4. Walk the JSON again, replace each `imageReference` node in-place with the enriched shape

### Scope

All five public endpoint methods produce `PublicDocument` via `_toPublicDocument`. The resolver is added there, so all methods benefit automatically:

- `getAllContents`
- `getDefaultContents`
- `getContentsByType`
- `getDefaultContent`
- `getContentBySlug`

### Performance note

For `getContentBySlug` / `getDefaultContent` (single document): one extra indexed batch query — negligible.

For `getAllContents` (all documents): one batch query per document. This is acceptable since `getAllContents` is already a heavy endpoint and callers are expected to cache its result. A future optimization could collect all `assetId`s across all documents and issue a single query, but this is not required now.

---

## Section 4: Codegen Changes

### Generated field type

`@CmsImageFieldConfig` emits `CmsData<ImageUrl?>` instead of `CmsData<String>`:

```dart
// Before (cms.g.dart)
final CmsData<String> backgroundImageUrl;

// After (cms.g.dart)
final CmsData<ImageUrl?> backgroundImage;
```

### `ImageUrlMapper`

A custom `dart_mappable` mapper decodes the resolved JSON shape:

```dart
class ImageUrlMapper extends SimpleMapper<ImageUrl> {
  const ImageUrlMapper();

  @override
  ImageUrl decode(Object value) =>
      ImageUrl.fromJson(value as Map<String, dynamic>);

  @override
  Object encode(ImageUrl self) =>
      self.imageRef.toDocumentJson(); // round-trips to assetId-only form
}
```

Applied to config classes:

```dart
@MappableClass(includeCustomMappers: [ColorMapper(), ImageUrlMapper()])
class HomeScreenConfig ...
```

---

## What Does Not Change

- The CMS studio internals (`CmsImageInput`, `DataSource`, upload flow) — unchanged
- `ImageReference.toDocumentJson()` — still serializes `assetId` only (storage format unchanged)
- `MediaAsset` DB schema — unchanged
- The `TransformUrlBuilder` typedef — unchanged; remains the extension point for CDN integrations

---

## Implementation Scope

1. `dart_desk_be`: Add `_resolveImageReferences` to `PublicContentEndpoint`
2. `dart_desk`: Add `MediaAsset.fromInlineJson`, `ImageUrl.fromJson`, `ImageUrl.withTransform`
3. `dart_desk`: Add `ImageUrlMapper`
4. `dart_desk_annotation` + codegen: `@CmsImageFieldConfig` → `ImageUrl?` field type
5. `examples/data_models`: Migrate `HomeScreenConfig` image fields from `String` → `ImageUrl?`
