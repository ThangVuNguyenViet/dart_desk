# Unified ImageReference Design

## Problem

dart_desk has three image types that overlap and confuse consumers:

- **`ImageRef`** (`dart_desk_annotation`) — lightweight DTO with `assetId`/`externalUrl`, resolves URL via static `defaultAssetResolver`
- **`ImageReference`** (`dart_desk`) — rich CMS-editor-internal model holding a full `MediaAsset`, `Hotspot`, `CropRect`, `altText`
- **`ImageUrl`** (`dart_desk`) — CDN transform wrapper around `ImageReference`, adds `url(width:, height:, format:)` via pluggable `TransformUrlBuilder`

Consumers don't know which to use. The example app accidentally used `ImageReference` (CMS-internal type) in consumer data models.

## Decision

Unify `ImageRef` + `ImageReference` into a single `ImageReference` in `dart_desk_annotation`. Keep `ImageUrl` in `dart_desk` as an optional CDN transform layer. Both serialize to the same wire format and are drop-in replaceable.

## Design

### `ImageReference` (in `dart_desk_annotation`)

Single image type for both stored and resolved formats.

**Fields:**

| Field | Type | Source |
|---|---|---|
| `assetId` | `String?` | Stored format — pointer to MediaAsset |
| `externalUrl` | `String?` | External URL (Lottie, CDN link) |
| `publicUrl` | `String?` | Server-resolved — direct URL to file |
| `width` | `int?` | Server-resolved |
| `height` | `int?` | Server-resolved |
| `blurHash` | `String?` | Server-resolved |
| `lqip` | `String?` | Server-resolved |
| `hotspot` | `Hotspot?` | Editor-set focal point (fractional 0..1) |
| `crop` | `CropRect?` | Editor-set crop region (fractional 0..1) |
| `altText` | `String?` | Editor-set accessibility text |

**URL resolution (`url` getter):**

```
publicUrl ?? externalUrl ?? defaultAssetResolver?.call(assetId!)
```

Priority: server-resolved URL > external URL > resolver fallback.

**Static resolver:**

```dart
static String Function(String assetId)? defaultAssetResolver;
```

Set once at app startup (by `DartDeskApp` or manually). Allows `ImageReference` to resolve URLs without the full `dart_desk` package.

**Serialization:**

- `fromMap(Map)` — auto-detects format by checking for `publicUrl` key. Reads all fields present.
- `toMap()` — always outputs **stored format only**: `_type`, `assetId`/`externalUrl`, `hotspot`, `crop`, `altText`. Never includes `publicUrl`/`width`/`height`/`blurHash`/`lqip` (these are transient server-resolved data).
- `isImageReference(Map)` — checks `map['_type'] == 'imageReference'`.

**Supporting types (also in `dart_desk_annotation`):**

```dart
class Hotspot {
  final double x, y, width, height; // fractional 0..1
}

class CropRect {
  final double top, bottom, left, right; // fractional 0..1
}
```

These move from `dart_desk` to `dart_desk_annotation` (pure Dart, no Flutter dependency).

### `ImageUrl` (stays in `dart_desk`)

Optional CDN transform wrapper. Adds `url()` method with width/height/format/quality params that delegates to a pluggable `TransformUrlBuilder`.

**Fields:**

| Field | Type | Purpose |
|---|---|---|
| `imageRef` | `ImageReference` | The underlying reference |
| `_transformUrl` | `TransformUrlBuilder?` | CDN URL builder function |

**`url()` method:**

```dart
String? url({int? width, int? height, FitMode? fit, String? format, int? quality})
```

- Builds `ImageTransformParams` from args + `imageRef.hotspot`/`imageRef.crop`
- If `_transformUrl` is set: returns `_transformUrl(imageRef.url, params)` (CDN-transformed URL)
- Otherwise: returns `imageRef.url` (raw URL, no transforms)

**Serialization — identical to `ImageReference`:**

- `ImageUrl.fromMap(map)` — calls `ImageReference.fromMap(map)`, wraps result
- `ImageUrl.toMap()` — delegates to `imageRef.toMap()`

This means swapping `ImageReference` to `ImageUrl` (or vice versa) in a data model requires zero changes to serialization, mappers, or stored data.

**Convenience accessors:**

- `blurHash` → `imageRef.blurHash`
- `lqip` → `imageRef.lqip`
- `width` → `imageRef.width`
- `height` → `imageRef.height`

### Mappers (for `dart_mappable`)

- `ImageReferenceMapper` (in `dart_desk_annotation`) — `SimpleMapper<ImageReference>`, calls `fromMap`/`toMap`
- `ImageUrlMapper` (in `dart_desk`) — `SimpleMapper<ImageUrl>`, calls `ImageUrl.fromMap`/`.toMap`

### Wire format (unchanged)

**Stored (DB):**
```json
{ "_type": "imageReference", "assetId": "image-abc-1920x1080-jpg", "hotspot": { "x": 0.5, "y": 0.3, "width": 0.8, "height": 0.6 }, "altText": "Hero image" }
```

**Resolved (API response):**
```json
{ "_type": "imageReference", "assetId": "image-abc-1920x1080-jpg", "publicUrl": "https://cdn.example.com/image.jpg", "width": 1920, "height": 1080, "blurHash": "LGF5?xYk^6#M", "lqip": "data:image/jpeg;base64,abc123", "hotspot": { "x": 0.5, "y": 0.3, "width": 0.8, "height": 0.6 }, "altText": "Hero image" }
```

**External URL:**
```json
{ "_type": "imageReference", "externalUrl": "https://example.com/animation.json" }
```

All three formats are produced/consumed by both `ImageReference.fromMap` and `ImageUrl.fromMap`.

## Example app — two usage patterns

### Pattern 1: `ImageReference` only (lightweight, no CDN)

Used by `StorefrontConfig`, `MenuHighlight`, `PromoOffer`, `DeliverySettings`.

```dart
// data_models/storefront_config.dart
@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
class StorefrontConfig with StorefrontConfigMappable, Serializable<StorefrontConfig> {
  @CmsImageFieldConfig(description: 'Hero image', option: CmsImageOption(hotspot: true))
  final ImageReference? heroImage;
  // ...
}

// example_app widget
if (config.heroImage != null)
  Image.network(config.heroImage!.url!, fit: BoxFit.cover);
```

### Pattern 2: `ImageUrl` with CDN transforms (optimized)

Used by `AppTheme` (brand logos, app icon — benefits from responsive sizing).

```dart
// data_models/app_theme.dart
@MappableClass(includeCustomMappers: [ImageUrlMapper(), AppThemeColorMapper()])
class AppTheme with AppThemeMappable, Serializable<AppTheme> {
  @CmsImageFieldConfig(description: 'Light mode logo', option: CmsImageOption(hotspot: false))
  final ImageUrl? logoLight;
  // ...
}

// example_app widget — requests 200px webp
if (config.logoLight != null)
  Image.network(config.logoLight!.url(width: 200, format: 'webp')!);
```

Both patterns serialize identically. Switching between them is a field type change + mapper swap — no data migration needed.

## Migration impact

### Removed
- `ImageRef` class in `dart_desk_annotation` (replaced by `ImageReference`)
- `ImageReference` class in `dart_desk` (moved to `dart_desk_annotation`)
- `MediaAsset` dependency from `ImageReference`

### Moved to `dart_desk_annotation`
- `Hotspot` class
- `CropRect` class
- `ImageReference` concept (enriched with resolved fields)

### Changed in `dart_desk`
- `ImageUrl.fromJson` renamed to `ImageUrl.fromMap` for consistency
- `ImageUrlMapper` delegates to `ImageReference.fromMap` instead of constructing via `MediaAsset`
- CMS editor (`CmsImageInput`) holds `MediaAsset` as a separate local variable, writes `ImageReference.toMap()` to `onChanged`
- `CmsImageField` supported types updated to include `ImageReference` (annotation) and `ImageUrl`

### Changed in `dart_desk_be`
- Server-side `_inlineAssets()` unchanged — it mutates JSON maps in-place, unaware of client types

### Changed in `dart_desk_cloud`
- `AwsImageStorageProvider` unchanged — it operates on URL strings, not image model types

### Changed in consumer apps (e.g. `hg_kiosk_data_models`)
- Replace `ImageRef` field types with `ImageReference`
- Replace `ImageRefMapper` with `ImageReferenceMapper`
- `ImageRef.defaultAssetResolver` → `ImageReference.defaultAssetResolver` (same API)
- `.url` getter unchanged
