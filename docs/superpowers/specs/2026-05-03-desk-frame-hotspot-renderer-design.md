# DeskFrame: Hotspot/Crop-Aware Image Rendering

**Date:** 2026-05-03
**Status:** Design
**Author:** thangvu

## Problem

The dart_desk studio lets authors set hotspot and crop on `ImageReference` (re-enabled by flipping `DeskImageOption.hotspot` default to `true`). The metadata is stored, and `framing_math.dart` already knows how to compute visible rects from it. But **nothing consumes that metadata downstream** — there is no runtime widget that renders an `ImageReference` honoring its hotspot/crop. Authors set framing in the studio and see no effect in real consumer apps.

## Goal

Provide a small, framework-style runtime widget that any consumer app (including those that do **not** depend on `dart_desk` the studio package) can use to render an `ImageReference` with its hotspot and crop applied.

## Non-Goals

- Cloud-side image transforms (imgproxy / Cloudflare Images / Imgix URL builders). Client-side framing first; URL builders slot in as an optional optimization later.
- Multi-layer compositing. Consumers stack widgets with Flutter's `Stack` — each layer is one `DeskFrame`, and each layer's hotspot self-aligns within the shared box.
- Replacing image loaders. Consumers keep using their own image widget (`Image.network`, `CachedNetworkImage`, custom CDN-backed widget). `DeskFrame` is a layout wrapper, not a pixel loader.

## Package Structure

The studio package (`dart_desk`) is heavy — it pulls in `shadcn_ui`, the entire input/widget system, generator-adjacent code, etc. Real consumer apps must not depend on it. So:

**New package: `dart_desk_widgets`**

Dependency graph:

```
real_app ─────────┐
                  ├─→ dart_desk_widgets ─→ dart_desk_annotation
dart_desk (studio)┘
```

- `dart_desk_widgets` houses runtime widgets that render data described by `dart_desk_annotation` types
- `dart_desk_annotation` keeps doing only schema/data
- `dart_desk` (studio) consumes `dart_desk_widgets` for the same widgets used in editor previews
- `framing_math.dart` moves from `packages/dart_desk/lib/src/inputs/hotspot/framing_math.dart` into `dart_desk_widgets`; studio re-imports it from there

## API

```dart
/// Layout wrapper that frames its child according to the crop and hotspot
/// metadata on [ref]. The child is expected to fill its parent box (i.e. use
/// `BoxFit.fill` semantics) — DeskFrame owns the geometry, child owns pixels.
class DeskFrame extends StatelessWidget {
  const DeskFrame({
    super.key,
    required this.ref,
    this.fit = BoxFit.cover,
    required this.child,
  });

  final ImageReference ref;
  final BoxFit fit;
  final Widget child;
}

/// Convenience: DeskFrame around an Image.network.
class DeskImage extends StatelessWidget {
  const DeskImage(this.ref, {super.key, this.fit = BoxFit.cover});

  final ImageReference ref;
  final BoxFit fit;

  // Roughly: DeskFrame(ref: ref, fit: fit,
  //   child: Image.network(ref.url, fit: BoxFit.fill))
}
```

### Constraints

- `ref` is required.
- `fit` defaults to `BoxFit.cover` (the sane default for hotspot — cover is the case where hotspot semantics matter most).
- `child` is required for `DeskFrame`. The child must fill its allocated box; if the child does its own fitting on top, framing breaks (double-fitting).

### Behavior

`DeskFrame` uses `LayoutBuilder` to measure the available box, then:

1. Reads `ref.crop` (a normalized 0–1 rect) and `ref.hotspot` (a normalized 0–1 point).
2. Calls into `framing_math.dart` to compute, given the cropped source aspect, the box's aspect, and `fit`:
   - The clip region in the box's coordinate space.
   - The transform (scale + translate) to apply to the child so that the cropped source fills the clip and the hotspot lands at the box's center (or as close as the box allows under `cover`).
3. Wraps `child` in `ClipRect` + `Transform`. The child sees an oversized rect that, after clipping, shows the right region with hotspot honored.

`BoxFit.contain` is supported but degenerate — hotspot has no effect because the whole image fits. `cover` is the headline case.

## Tests

- Unit tests for the framing math (these mostly exist already in `framing_math.dart`'s neighborhood; relocate alongside the move).
- Widget golden tests for `DeskFrame`:
  - `cover` × `{no crop / crop set}` × `{no hotspot / hotspot off-center}` × `{box wider than source / box taller than source}`.
  - `contain` baseline (hotspot ignored, fully visible).
- A Stack composition golden: two `DeskFrame`s in a `Stack` with hotspots set to align — the test asserts hotspots line up at the same point in the output.

## Publishing (Melos)

`dart_desk_widgets` must be publishable to pub.dev alongside the existing packages.

Changes to `melos.yaml`:

```yaml
packages:
  - packages/dart_desk
  - packages/dart_desk_annotation
  - packages/dart_desk_generator
  - packages/dart_desk_widgets   # new
  - examples/*

scripts:
  analyze:
    run: dart analyze --fatal-infos
    packageFilters:
      scope:
        - dart_desk
        - dart_desk_annotation
        - dart_desk_generator
        - dart_desk_widgets       # new
```

Existing `version`, `publish`, and `dry-run` commands already filter by `noPrivate` and pick up any package without `publish_to: none`, so no further wiring is needed.

`packages/dart_desk_widgets/pubspec.yaml`:

```yaml
name: dart_desk_widgets
description: Runtime Flutter widgets for rendering Dart Desk content (hotspot/crop-aware image framing, etc.).
version: 0.0.1
homepage: https://github.com/ThangVuNguyenViet/dart_desk
repository: https://github.com/ThangVuNguyenViet/dart_desk
issue_tracker: https://github.com/ThangVuNguyenViet/dart_desk/issues

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  dart_desk_annotation: ^0.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
```

Plus seeded `CHANGELOG.md` (`0.0.1 - Initial release with DeskFrame and DeskImage`), `README.md` with usage examples, and a `LICENSE` mirroring sibling packages.

## Migration

- Move `packages/dart_desk/lib/src/inputs/hotspot/framing_math.dart` → `packages/dart_desk_widgets/lib/src/framing_math.dart`.
- Update `packages/dart_desk` to depend on `dart_desk_widgets` and re-import `framing_math` from there. The hotspot editor and existing studio inputs keep working.
- No existing public API in `dart_desk` changes; this is purely additive.

## Out-of-Scope Follow-Ups

- **Cloud transform URL builder.** A function `imageUrl(ref, w, h, fit)` that emits transform-server params (`fp-x`, `fp-y`, `rect`, `w`, `h`, `fit`) for whatever service is configured (imgproxy, Cloudflare Images, Imgix). When configured, `DeskImage` would prefer the transformed URL. Pure addition, no API churn.
- **Other runtime renderers.** `DeskBlockContent` for portable text, etc. — these naturally live in `dart_desk_widgets` once the package exists.
