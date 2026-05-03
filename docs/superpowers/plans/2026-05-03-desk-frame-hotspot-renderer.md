# DeskFrame Hotspot/Crop-Aware Renderer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a publishable `dart_desk_widgets` package containing `DeskFrame` (a layout wrapper that frames any child widget per `ImageReference.crop` + `hotspot`) and `DeskImage` (convenience wrapper around `Image.network`), plus relocate `framing_math.dart` from the studio package so consumer apps can render hotspot-aware images without depending on `dart_desk`.

**Architecture:** New leaf package `dart_desk_widgets` in the workspace, depending only on `dart_desk_annotation` + Flutter. Studio package `dart_desk` depends on it (for editor-side previews and to reuse `framing_math`). Real consumer apps depend on `dart_desk_widgets` directly. `DeskFrame` uses `LayoutBuilder` + `ClipRect` + `Transform` to position any child widget; the child is responsible for filling its allocated rect (`BoxFit.fill` semantics). Cloud-side image transforms are out of scope.

**Tech Stack:** Dart 3, Flutter, Melos workspace, `dart_desk_annotation` (for `ImageReference`/`Hotspot`/`CropRect`), `flutter_test` (widget + golden tests).

**Spec:** [`docs/superpowers/specs/2026-05-03-desk-frame-hotspot-renderer-design.md`](../specs/2026-05-03-desk-frame-hotspot-renderer-design.md)

**Pre-flight context:**
- `Hotspot` and `CropRect` already live in `packages/dart_desk_annotation/lib/src/models/image_types.dart`. `ImageReference` (which exposes nullable `hotspot` and `crop`) lives in `packages/dart_desk_annotation/lib/src/models/image_ref.dart`.
- Existing `framing_math.dart` is at `packages/dart_desk/lib/src/inputs/hotspot/framing_math.dart`. Today it imports `Hotspot`/`CropRect` from a duplicate file at `packages/dart_desk/lib/src/data/models/image_types.dart`. **The studio's local `image_types.dart` is a duplicate of the annotation one** — both define the same shape. After this plan, `framing_math` will live in `dart_desk_widgets` and import from `dart_desk_annotation`. The studio's local duplicate is left alone (out of scope; can be deduped later).
- All goldens for `dart_desk` must run in Linux Docker — that constraint extends to the new `dart_desk_widgets` goldens. The package's `flutter test --update-goldens` will be run via the same Docker harness used for `dart_desk`.

---

## Task 1: Scaffold `dart_desk_widgets` package

**Files:**
- Create: `packages/dart_desk_widgets/pubspec.yaml`
- Create: `packages/dart_desk_widgets/README.md`
- Create: `packages/dart_desk_widgets/CHANGELOG.md`
- Create: `packages/dart_desk_widgets/LICENSE`
- Create: `packages/dart_desk_widgets/analysis_options.yaml`
- Create: `packages/dart_desk_widgets/.gitignore`
- Create: `packages/dart_desk_widgets/lib/dart_desk_widgets.dart` (empty exports for now)

- [ ] **Step 1: Create `pubspec.yaml`**

```yaml
name: dart_desk_widgets
description: Runtime Flutter widgets for rendering Dart Desk content — hotspot/crop-aware image framing and related primitives.
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
  flutter_lints: ^4.0.0
```

- [ ] **Step 2: Create `analysis_options.yaml`**

```yaml
include: package:flutter_lints/flutter.yaml
```

- [ ] **Step 3: Create `.gitignore`**

```
.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies
pubspec.lock
```

- [ ] **Step 4: Create `LICENSE`**

Copy verbatim from `packages/dart_desk_annotation/LICENSE`.

```bash
cp packages/dart_desk_annotation/LICENSE packages/dart_desk_widgets/LICENSE
```

- [ ] **Step 5: Create `CHANGELOG.md`**

```markdown
## 0.0.1

- Initial release. Adds `DeskFrame` and `DeskImage` for hotspot/crop-aware rendering of `ImageReference`.
- Houses `framing_math` (relocated from `dart_desk`).
```

- [ ] **Step 6: Create empty entry-point `lib/dart_desk_widgets.dart`**

```dart
/// Runtime Flutter widgets for rendering Dart Desk content.
///
/// Provides hotspot/crop-aware image framing for `ImageReference` values
/// produced by the dart_desk studio.
library;
```

- [ ] **Step 7: Create `README.md`**

```markdown
# dart_desk_widgets

Runtime Flutter widgets for rendering content authored in the
[dart_desk](https://github.com/ThangVuNguyenViet/dart_desk) studio.

## What's here

- **`DeskFrame`** — a layout wrapper that frames its child according to the
  `crop` and `hotspot` metadata on an `ImageReference`. The child is any
  widget that fills its parent box.
- **`DeskImage`** — convenience: `DeskFrame` around `Image.network(ref.url)`.

This package is intentionally minimal and depends only on
`dart_desk_annotation` and Flutter — consumer apps can use it without pulling
in the heavier studio package.

## Usage

```dart
import 'package:dart_desk_widgets/dart_desk_widgets.dart';

// Simple case
DeskImage(myImageRef, fit: BoxFit.cover);

// Custom child
DeskFrame(
  ref: myImageRef,
  fit: BoxFit.cover,
  child: CachedNetworkImage(
    imageUrl: myImageRef.publicUrl!,
    fit: BoxFit.fill, // child must fill its allocated box
  ),
);
```
```

- [ ] **Step 8: Verify the package resolves**

```bash
cd packages/dart_desk_widgets && flutter pub get
```

Expected: completes without errors. `pubspec.lock` may be created (gitignored).

- [ ] **Step 9: Commit**

```bash
git add packages/dart_desk_widgets/
git commit -m "feat(dart_desk_widgets): scaffold publishable widget package"
```

---

## Task 2: Add `dart_desk_widgets` to melos config

**Files:**
- Modify: `melos.yaml`

- [ ] **Step 1: Add the package to `packages:` and `analyze` scope**

Edit `melos.yaml`:

Replace the `packages:` block:

```yaml
packages:
  - packages/dart_desk
  - packages/dart_desk_annotation
  - packages/dart_desk_generator
  - examples/*
```

with:

```yaml
packages:
  - packages/dart_desk
  - packages/dart_desk_annotation
  - packages/dart_desk_generator
  - packages/dart_desk_widgets
  - examples/*
```

And replace the `scripts.analyze.packageFilters.scope` block:

```yaml
  analyze:
    run: dart analyze --fatal-infos
    packageFilters:
      scope:
        - dart_desk
        - dart_desk_annotation
        - dart_desk_generator
```

with:

```yaml
  analyze:
    run: dart analyze --fatal-infos
    packageFilters:
      scope:
        - dart_desk
        - dart_desk_annotation
        - dart_desk_generator
        - dart_desk_widgets
```

`version`, `publish`, `dry-run`, and `test` already filter by `noPrivate` / `dirExists: test` and pick up the new package automatically.

- [ ] **Step 2: Bootstrap melos**

```bash
melos bootstrap
```

Expected: completes; `dart_desk_widgets` appears in the package list.

- [ ] **Step 3: Run analyze across all packages**

```bash
melos run analyze
```

Expected: passes for all four packages including `dart_desk_widgets`.

- [ ] **Step 4: Run dry-run publish to verify metadata**

```bash
melos run dry-run --no-select
```

Expected: `dart_desk_widgets` reports a successful dry-run (or warns about transient items like `homepage` URL not yet live — non-fatal).

- [ ] **Step 5: Commit**

```bash
git add melos.yaml
git commit -m "chore(melos): include dart_desk_widgets in workspace"
```

---

## Task 3: Move `framing_math.dart` into `dart_desk_widgets`

**Files:**
- Create: `packages/dart_desk_widgets/lib/src/framing_math.dart`
- Modify: `packages/dart_desk_widgets/lib/dart_desk_widgets.dart`
- Delete (after re-export shim is wired): `packages/dart_desk/lib/src/inputs/hotspot/framing_math.dart` (replaced with a re-export)

- [ ] **Step 1: Create `framing_math.dart` in the new package, importing `Hotspot`/`CropRect` from annotation**

Write `packages/dart_desk_widgets/lib/src/framing_math.dart`:

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart' show Alignment;

class FramingDefaults {
  static const defaultCrop = CropRect(top: 0, bottom: 0, left: 0, right: 0);
  static const defaultHotspot = Hotspot(
    x: 0.5,
    y: 0.5,
    width: 0.3,
    height: 0.3,
  );
}

class FramingMath {
  static Hotspot clampHotspotToCrop(Hotspot hotspot, CropRect crop) {
    final minX = crop.left;
    final maxX = 1.0 - crop.right;
    final minY = crop.top;
    final maxY = 1.0 - crop.bottom;

    return hotspot.copyWith(
      x: hotspot.x.clamp(minX, maxX).toDouble(),
      y: hotspot.y.clamp(minY, maxY).toDouble(),
    );
  }

  static Alignment previewAlignment({
    required CropRect crop,
    required Hotspot hotspot,
  }) {
    final clamped = clampHotspotToCrop(hotspot, crop);
    final visibleCenterX = (crop.left + (1.0 - crop.right)) / 2;
    final visibleCenterY = (crop.top + (1.0 - crop.bottom)) / 2;

    return Alignment(
      ((clamped.x - visibleCenterX) * 2).clamp(-1.0, 1.0),
      ((clamped.y - visibleCenterY) * 2).clamp(-1.0, 1.0),
    );
  }
}
```

- [ ] **Step 2: Re-export `framing_math` from the package entry point**

Edit `packages/dart_desk_widgets/lib/dart_desk_widgets.dart`:

```dart
/// Runtime Flutter widgets for rendering Dart Desk content.
///
/// Provides hotspot/crop-aware image framing for `ImageReference` values
/// produced by the dart_desk studio.
library;

export 'src/framing_math.dart';
```

- [ ] **Step 3: Update studio's `framing_math.dart` to be a re-export shim**

Replace `packages/dart_desk/lib/src/inputs/hotspot/framing_math.dart` entirely with:

```dart
/// Re-export of framing math from `dart_desk_widgets` for backwards
/// compatibility with existing studio imports.
export 'package:dart_desk_widgets/dart_desk_widgets.dart' show FramingDefaults, FramingMath;
```

- [ ] **Step 4: Add `dart_desk_widgets` as a dependency in `dart_desk`**

Edit `packages/dart_desk/pubspec.yaml`. Find the `dependencies:` block and add (alphabetically near the other `dart_desk_*` entries):

```yaml
  dart_desk_widgets: ^0.0.1
```

- [ ] **Step 5: Bootstrap & analyze**

```bash
melos bootstrap
melos run analyze
```

Expected: passes. The studio's hotspot editor and any other consumer of `FramingMath` keep working through the re-export shim.

- [ ] **Step 6: Run existing studio tests to confirm no regressions**

```bash
cd packages/dart_desk && flutter test
```

Expected: all existing tests pass (framing math behavior is unchanged; only the source-of-truth file moved).

- [ ] **Step 7: Commit**

```bash
git add packages/dart_desk_widgets/lib packages/dart_desk/lib/src/inputs/hotspot/framing_math.dart packages/dart_desk/pubspec.yaml
git commit -m "refactor(dart_desk_widgets): relocate framing_math from studio package"
```

---

## Task 4: Build framing geometry helper for runtime rendering

`framing_math.dart` today only computes a `previewAlignment` for the studio editor. The runtime needs the **clip rect inside the box** and the **child transform** to honor crop + hotspot under `BoxFit.cover` / `BoxFit.contain`. Add these as pure functions, fully tested.

**Files:**
- Modify: `packages/dart_desk_widgets/lib/src/framing_math.dart`
- Create: `packages/dart_desk_widgets/test/framing_geometry_test.dart`

- [ ] **Step 1: Write the failing tests**

Write `packages/dart_desk_widgets/test/framing_geometry_test.dart`:

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FramingMath.frameGeometry', () {
    const noCrop = CropRect(top: 0, bottom: 0, left: 0, right: 0);
    const centerHotspot = Hotspot(x: 0.5, y: 0.5, width: 0.3, height: 0.3);

    test('contain with no crop, square box, square source: child fills box exactly', () {
      final geom = FramingMath.frameGeometry(
        boxSize: const Size(100, 100),
        sourceSize: const Size(200, 200),
        crop: noCrop,
        hotspot: centerHotspot,
        fit: BoxFit.contain,
      );

      // Child rect equals the box; no overflow, no offset.
      expect(geom.childRect, const Rect.fromLTWH(0, 0, 100, 100));
    });

    test('cover with no crop, source wider than box: child scaled by box height, centered horizontally', () {
      // box 100x100, source 200x100 (2:1) → cover scales by box.height/source.height=1.0
      // child becomes 200x100, hotspot at 0.5 maps to source x=100, child centered → child.left = -50.
      final geom = FramingMath.frameGeometry(
        boxSize: const Size(100, 100),
        sourceSize: const Size(200, 100),
        crop: noCrop,
        hotspot: centerHotspot,
        fit: BoxFit.cover,
      );

      expect(geom.childRect.size, const Size(200, 100));
      expect(geom.childRect.left, -50);
      expect(geom.childRect.top, 0);
    });

    test('cover with off-center hotspot keeps hotspot in view', () {
      // Hotspot at x=0.9 should pull the child left so the focal point lands at box center where possible.
      final geom = FramingMath.frameGeometry(
        boxSize: const Size(100, 100),
        sourceSize: const Size(200, 100),
        crop: noCrop,
        hotspot: const Hotspot(x: 0.9, y: 0.5, width: 0.1, height: 0.1),
        fit: BoxFit.cover,
      );

      // child width=200, scaled-source x for hotspot 0.9 = 180 → desired child.left = 50 - 180 = -130,
      // clamped so child.right >= 100 → child.left >= 100 - 200 = -100. So clamped to -100.
      expect(geom.childRect.left, -100);
    });

    test('crop trims source: child rect reflects only the cropped region', () {
      // Crop top=0.25, bottom=0.25 → visible source vertical span is 50% of original.
      // Source 200x200, after crop the visible source is 200x100, displayed under cover into box 100x100
      // → child should be sized so the *cropped* region maps to box; uncropped overflow handled by clip.
      final geom = FramingMath.frameGeometry(
        boxSize: const Size(100, 100),
        sourceSize: const Size(200, 200),
        crop: const CropRect(top: 0.25, bottom: 0.25, left: 0, right: 0),
        hotspot: centerHotspot,
        fit: BoxFit.cover,
      );

      // Visible source is 200x100 (2:1). Under cover into 100x100 box: scale = 1.0, child width=200, height=100…
      // …but the child renders the *full* source, not just the cropped band. So the rendered child is
      // scaled to the cropped size and translated so the cropped band aligns with the box.
      // Effective child rect (full source, not just cropped band) = full-source-scale 1.0 → child 200x200,
      // shifted up by 50 (top crop = 0.25 of 200 = 50) and left by 50 (centered horizontally on cover scale).
      expect(geom.childRect, const Rect.fromLTWH(-50, -50, 200, 200));
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd packages/dart_desk_widgets && flutter test test/framing_geometry_test.dart
```

Expected: FAILS — `FramingMath.frameGeometry` is undefined.

- [ ] **Step 3: Implement `frameGeometry`**

Edit `packages/dart_desk_widgets/lib/src/framing_math.dart` — append (do not delete existing classes):

```dart
class FrameGeometry {
  /// The rect, in the box's local coordinate space, where the child widget
  /// should be laid out. May extend outside the box (negative offsets, sizes
  /// larger than the box) — the caller clips to the box.
  final Rect childRect;

  const FrameGeometry({required this.childRect});
}

extension FramingMathRuntime on FramingMath {
  // namespace anchor — methods declared on FramingMath below
}

// (non-extension static method on FramingMath)
```

Then add a static method on `FramingMath` (extend the existing class body):

```dart
class FramingMath {
  // ... existing members ...

  static FrameGeometry frameGeometry({
    required Size boxSize,
    required Size sourceSize,
    required CropRect crop,
    required Hotspot hotspot,
    required BoxFit fit,
  }) {
    // Visible source size after applying crop (still in source pixel space).
    final visibleW = sourceSize.width * (1.0 - crop.left - crop.right);
    final visibleH = sourceSize.height * (1.0 - crop.top - crop.bottom);
    if (visibleW <= 0 || visibleH <= 0) {
      return FrameGeometry(childRect: Rect.fromLTWH(0, 0, boxSize.width, boxSize.height));
    }

    // Scale that maps the visible (cropped) region into the box per [fit].
    final double scale;
    switch (fit) {
      case BoxFit.cover:
        scale = (boxSize.width / visibleW) > (boxSize.height / visibleH)
            ? boxSize.width / visibleW
            : boxSize.height / visibleH;
        break;
      case BoxFit.contain:
        scale = (boxSize.width / visibleW) < (boxSize.height / visibleH)
            ? boxSize.width / visibleW
            : boxSize.height / visibleH;
        break;
      default:
        scale = boxSize.width / visibleW; // fallback: width-fit
    }

    // The child widget renders the FULL source image (not just the crop), so its
    // size in box coords is the full source size scaled by [scale].
    final childW = sourceSize.width * scale;
    final childH = sourceSize.height * scale;

    // Hotspot position in scaled source coords.
    final clamped = clampHotspotToCrop(hotspot, crop);
    final hotspotX = clamped.x * childW;
    final hotspotY = clamped.y * childH;

    // Desired child offset so hotspot lands at box center.
    double left = boxSize.width / 2 - hotspotX;
    double top = boxSize.height / 2 - hotspotY;

    // Account for crop offset: the cropped region's top-left in scaled source is
    // (crop.left*childW, crop.top*childH). Under [cover], the cropped region
    // should fill the box, so its top-left in box coords stays within [0..0].
    // Clamp [left]/[top] so the cropped region fully covers the box.
    final cropLeftPx = crop.left * childW;
    final cropTopPx = crop.top * childH;
    final cropRightPx = crop.right * childW;
    final cropBottomPx = crop.bottom * childH;

    if (fit == BoxFit.cover) {
      // The visible cropped region must cover the box:
      // box.left >= child.left + cropLeftPx  → left <= -cropLeftPx
      // box.right <= child.right - cropRightPx → left + childW >= boxSize.width + cropRightPx
      //   → left >= boxSize.width + cropRightPx - childW
      final maxLeft = -cropLeftPx;
      final minLeft = boxSize.width + cropRightPx - childW;
      if (minLeft > maxLeft) {
        // Cropped region narrower than the box at this scale — center it.
        left = (maxLeft + minLeft) / 2;
      } else {
        left = left.clamp(minLeft, maxLeft).toDouble();
      }

      final maxTop = -cropTopPx;
      final minTop = boxSize.height + cropBottomPx - childH;
      if (minTop > maxTop) {
        top = (maxTop + minTop) / 2;
      } else {
        top = top.clamp(minTop, maxTop).toDouble();
      }
    } else if (fit == BoxFit.contain) {
      // Center the cropped region inside the box.
      left = (boxSize.width - (childW - cropLeftPx - cropRightPx)) / 2 - cropLeftPx;
      top = (boxSize.height - (childH - cropTopPx - cropBottomPx)) / 2 - cropTopPx;
    }

    return FrameGeometry(childRect: Rect.fromLTWH(left, top, childW, childH));
  }
}
```

(Remove the empty `extension FramingMathRuntime` placeholder if you added it; it was just a syntactic anchor.)

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd packages/dart_desk_widgets && flutter test test/framing_geometry_test.dart
```

Expected: all 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk_widgets/lib/src/framing_math.dart packages/dart_desk_widgets/test/framing_geometry_test.dart
git commit -m "feat(dart_desk_widgets): compute frame geometry for cover/contain with crop+hotspot"
```

---

## Task 5: Implement `DeskFrame` widget

**Files:**
- Create: `packages/dart_desk_widgets/lib/src/desk_frame.dart`
- Modify: `packages/dart_desk_widgets/lib/dart_desk_widgets.dart`
- Create: `packages/dart_desk_widgets/test/desk_frame_test.dart`

- [ ] **Step 1: Write the failing widget tests**

Write `packages/dart_desk_widgets/test/desk_frame_test.dart`:

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _ref200x200 = ImageReference(
  publicUrl: 'https://example.com/img.png',
  width: 200,
  height: 200,
);

void main() {
  group('DeskFrame', () {
    testWidgets('lays out child to fill the box when no crop, no hotspot, contain', (tester) async {
      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: DeskFrame(
              ref: _ref200x200,
              fit: BoxFit.contain,
              child: const _ProbeChild(),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(_ProbeChild));
      expect(size, const Size(100, 100));
    });

    testWidgets('cover with wider source produces child wider than box (clipped)', (tester) async {
      const wideRef = ImageReference(
        publicUrl: 'https://example.com/wide.png',
        width: 200,
        height: 100,
      );

      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: DeskFrame(
              ref: wideRef,
              fit: BoxFit.cover,
              child: const _ProbeChild(),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(_ProbeChild));
      expect(size.width, 200);
      expect(size.height, 100);
    });

    testWidgets('clips child to the box bounds', (tester) async {
      const wideRef = ImageReference(
        publicUrl: 'https://example.com/wide.png',
        width: 200,
        height: 100,
      );

      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: DeskFrame(
              ref: wideRef,
              fit: BoxFit.cover,
              child: const _ProbeChild(),
            ),
          ),
        ),
      );

      // The DeskFrame's render box (the SizedBox) must be 100x100 — the clip.
      final clipSize = tester.getSize(find.byType(DeskFrame));
      expect(clipSize, const Size(100, 100));
    });

    testWidgets('handles missing image dimensions by treating source as square box-sized', (tester) async {
      const noDimRef = ImageReference(publicUrl: 'https://example.com/x.png');

      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: DeskFrame(
              ref: noDimRef,
              child: const _ProbeChild(),
            ),
          ),
        ),
      );

      // No crash; child sized to box (default cover fallback when source unknown).
      final size = tester.getSize(find.byType(_ProbeChild));
      expect(size, const Size(100, 100));
    });
  });
}

class _ProbeChild extends StatelessWidget {
  const _ProbeChild();
  @override
  Widget build(BuildContext context) =>
      const SizedBox.expand(child: ColoredBox(color: Color(0xFF00FF00)));
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd packages/dart_desk_widgets && flutter test test/desk_frame_test.dart
```

Expected: FAILS — `DeskFrame` is undefined.

- [ ] **Step 3: Implement `DeskFrame`**

Write `packages/dart_desk_widgets/lib/src/desk_frame.dart`:

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/widgets.dart';

import 'framing_math.dart';

/// Layout wrapper that frames [child] according to [ref.crop] and
/// [ref.hotspot]. The child must fill its allocated box (BoxFit.fill
/// semantics) — DeskFrame owns the geometry.
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
        );

        final sourceSize = (ref.width != null && ref.height != null)
            ? Size(ref.width!.toDouble(), ref.height!.toDouble())
            : boxSize;

        final geom = FramingMath.frameGeometry(
          boxSize: boxSize,
          sourceSize: sourceSize,
          crop: ref.crop ?? FramingDefaults.defaultCrop,
          hotspot: ref.hotspot ?? FramingDefaults.defaultHotspot,
          fit: fit,
        );

        return ClipRect(
          child: SizedBox(
            width: boxSize.width,
            height: boxSize.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: geom.childRect.left,
                  top: geom.childRect.top,
                  width: geom.childRect.width,
                  height: geom.childRect.height,
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 4: Export `DeskFrame` from the package entry point**

Edit `packages/dart_desk_widgets/lib/dart_desk_widgets.dart`:

```dart
/// Runtime Flutter widgets for rendering Dart Desk content.
///
/// Provides hotspot/crop-aware image framing for `ImageReference` values
/// produced by the dart_desk studio.
library;

export 'src/desk_frame.dart';
export 'src/framing_math.dart';
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd packages/dart_desk_widgets && flutter test test/desk_frame_test.dart
```

Expected: all 4 tests PASS.

- [ ] **Step 6: Commit**

```bash
git add packages/dart_desk_widgets/lib packages/dart_desk_widgets/test/desk_frame_test.dart
git commit -m "feat(dart_desk_widgets): add DeskFrame layout wrapper"
```

---

## Task 6: Implement `DeskImage` convenience widget

**Files:**
- Create: `packages/dart_desk_widgets/lib/src/desk_image.dart`
- Modify: `packages/dart_desk_widgets/lib/dart_desk_widgets.dart`
- Create: `packages/dart_desk_widgets/test/desk_image_test.dart`

- [ ] **Step 1: Write failing test**

Write `packages/dart_desk_widgets/test/desk_image_test.dart`:

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DeskImage wraps an Image.network in a DeskFrame', (tester) async {
    const ref = ImageReference(
      publicUrl: 'https://example.com/img.png',
      width: 100,
      height: 100,
    );

    await tester.pumpWidget(
      Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: DeskImage(ref),
        ),
      ),
    );

    expect(find.byType(DeskFrame), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('DeskImage requires publicUrl; assertion fires when both publicUrl and externalUrl are null', (tester) async {
    const ref = ImageReference(width: 10, height: 10);
    expect(
      () => DeskImage(ref),
      throwsAssertionError,
    );
  });
}
```

- [ ] **Step 2: Verify test fails**

```bash
cd packages/dart_desk_widgets && flutter test test/desk_image_test.dart
```

Expected: FAILS — `DeskImage` undefined.

- [ ] **Step 3: Implement `DeskImage`**

Write `packages/dart_desk_widgets/lib/src/desk_image.dart`:

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/widgets.dart';

import 'desk_frame.dart';

/// Convenience wrapper: a [DeskFrame] around `Image.network(ref.publicUrl ?? ref.externalUrl)`.
class DeskImage extends StatelessWidget {
  DeskImage(this.ref, {super.key, this.fit = BoxFit.cover})
      : assert(
          ref.publicUrl != null || ref.externalUrl != null,
          'DeskImage requires publicUrl or externalUrl on the ImageReference',
        );

  final ImageReference ref;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = ref.publicUrl ?? ref.externalUrl!;
    return DeskFrame(
      ref: ref,
      fit: fit,
      child: Image.network(url, fit: BoxFit.fill),
    );
  }
}
```

- [ ] **Step 4: Export from entry point**

Edit `packages/dart_desk_widgets/lib/dart_desk_widgets.dart`:

```dart
/// Runtime Flutter widgets for rendering Dart Desk content.
library;

export 'src/desk_frame.dart';
export 'src/desk_image.dart';
export 'src/framing_math.dart';
```

- [ ] **Step 5: Verify tests pass**

```bash
cd packages/dart_desk_widgets && flutter test
```

Expected: all tests across the package PASS.

- [ ] **Step 6: Commit**

```bash
git add packages/dart_desk_widgets/lib packages/dart_desk_widgets/test/desk_image_test.dart
git commit -m "feat(dart_desk_widgets): add DeskImage convenience widget"
```

---

## Task 7: Golden tests for `DeskFrame`

Run all goldens **inside the existing Linux Docker harness** used for `dart_desk` (per project convention: goldens never run natively on macOS). Use the project's golden runner; if a sibling package shows a Docker invocation pattern, reuse it.

**Files:**
- Create: `packages/dart_desk_widgets/test/desk_frame_golden_test.dart`
- Create: `packages/dart_desk_widgets/test/goldens/` (directory; populated by `--update-goldens`)

- [ ] **Step 1: Write golden test scaffold**

Write `packages/dart_desk_widgets/test/desk_frame_golden_test.dart`:

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _SolidImage extends StatelessWidget {
  const _SolidImage();
  @override
  Widget build(BuildContext context) {
    // A simple 4-quadrant pattern lets goldens visibly assert orientation.
    return CustomPaint(painter: _QuadrantPainter(), child: const SizedBox.expand());
  }
}

class _QuadrantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width / 2, h = size.height / 2;
    final paints = [
      Paint()..color = const Color(0xFFE53935), // red
      Paint()..color = const Color(0xFF1E88E5), // blue
      Paint()..color = const Color(0xFF43A047), // green
      Paint()..color = const Color(0xFFFDD835), // yellow
    ];
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paints[0]);
    canvas.drawRect(Rect.fromLTWH(w, 0, w, h), paints[1]);
    canvas.drawRect(Rect.fromLTWH(0, h, w, h), paints[2]);
    canvas.drawRect(Rect.fromLTWH(w, h, w, h), paints[3]);
  }

  @override
  bool shouldRepaint(_) => false;
}

Widget _frame({
  required Size box,
  required ImageReference ref,
  required BoxFit fit,
}) {
  return Center(
    child: SizedBox(
      width: box.width,
      height: box.height,
      child: DeskFrame(ref: ref, fit: fit, child: const _SolidImage()),
    ),
  );
}

void main() {
  const ref = ImageReference(
    publicUrl: 'about:blank',
    width: 200,
    height: 100,
  );

  testWidgets('cover, no crop, no hotspot — square box, wide source', (tester) async {
    await tester.pumpWidget(_frame(box: const Size(120, 120), ref: ref, fit: BoxFit.cover));
    await expectLater(
      find.byType(DeskFrame),
      matchesGoldenFile('goldens/desk_frame_cover_no_crop_no_hotspot.png'),
    );
  });

  testWidgets('cover, hotspot off-center', (tester) async {
    final r = ImageReference(
      publicUrl: 'about:blank',
      width: 200,
      height: 100,
      hotspot: Hotspot(x: 0.85, y: 0.5, width: 0.1, height: 0.1),
    );
    await tester.pumpWidget(_frame(box: const Size(120, 120), ref: r, fit: BoxFit.cover));
    await expectLater(
      find.byType(DeskFrame),
      matchesGoldenFile('goldens/desk_frame_cover_hotspot_offcenter.png'),
    );
  });

  testWidgets('cover, with crop', (tester) async {
    final r = ImageReference(
      publicUrl: 'about:blank',
      width: 200,
      height: 100,
      crop: const CropRect(top: 0, bottom: 0, left: 0.25, right: 0.25),
    );
    await tester.pumpWidget(_frame(box: const Size(120, 120), ref: r, fit: BoxFit.cover));
    await expectLater(
      find.byType(DeskFrame),
      matchesGoldenFile('goldens/desk_frame_cover_with_crop.png'),
    );
  });

  testWidgets('contain baseline', (tester) async {
    await tester.pumpWidget(_frame(box: const Size(120, 120), ref: ref, fit: BoxFit.contain));
    await expectLater(
      find.byType(DeskFrame),
      matchesGoldenFile('goldens/desk_frame_contain.png'),
    );
  });
}
```

- [ ] **Step 2: Generate the goldens inside Linux Docker**

Use the same Docker harness used for the `dart_desk` package's goldens. From the workspace root:

```bash
# Adjust to match the existing dart_desk Docker invocation pattern.
docker run --rm -v "$PWD:/work" -w /work/packages/dart_desk_widgets <flutter-image> \
  flutter test --update-goldens test/desk_frame_golden_test.dart
```

Expected: `test/goldens/*.png` files created.

- [ ] **Step 3: Re-run goldens (no `--update-goldens`) inside Docker to verify**

```bash
docker run --rm -v "$PWD:/work" -w /work/packages/dart_desk_widgets <flutter-image> \
  flutter test test/desk_frame_golden_test.dart
```

Expected: PASS.

- [ ] **Step 4: Visually inspect generated PNGs**

Open each file under `packages/dart_desk_widgets/test/goldens/` and confirm:
- `cover_no_crop_no_hotspot.png` — wide source covers square box, image centered, top/bottom of source clipped (you see the top edge of all four quadrants but the left/right edges are clipped... wait, source is wider than box at cover with equal heights → actually height-fitting → see all of top and full vertical, sides clipped). The point is to confirm orientation visually.
- `cover_hotspot_offcenter.png` — compared to baseline, the visible region is shifted toward the right side of the source (you see more of the blue/yellow quadrants).
- `cover_with_crop.png` — left/right slivers of the source are removed; the visible band shows only the central 50% of source horizontally.
- `contain.png` — wide source letterboxed inside the square box.

If any image looks wrong, the geometry math is wrong: stop and debug Task 4 before continuing.

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk_widgets/test/desk_frame_golden_test.dart packages/dart_desk_widgets/test/goldens/
git commit -m "test(dart_desk_widgets): goldens for DeskFrame cover/contain × crop × hotspot"
```

---

## Task 8: Stack-composition golden (flame + dish use case)

Validates the headline use case: two layers in a `Stack`, each its own `DeskFrame`, hotspots aligning their focal points so the layers compose correctly.

**Files:**
- Modify: `packages/dart_desk_widgets/test/desk_frame_golden_test.dart`
- Create: `packages/dart_desk_widgets/test/goldens/desk_frame_stack_aligned.png` (via `--update-goldens`)

- [ ] **Step 1: Append a stack composition test**

Append to `packages/dart_desk_widgets/test/desk_frame_golden_test.dart` (inside `void main()`):

```dart
  testWidgets('two DeskFrames in a Stack align via hotspots', (tester) async {
    // "Background" layer with focal point top-center.
    final bgRef = ImageReference(
      publicUrl: 'about:blank',
      width: 200,
      height: 100,
      hotspot: Hotspot(x: 0.5, y: 0.2, width: 0.1, height: 0.1),
    );
    // "Foreground" layer with focal point also at its own visual center.
    final fgRef = ImageReference(
      publicUrl: 'about:blank',
      width: 100,
      height: 100,
      hotspot: Hotspot(x: 0.5, y: 0.5, width: 0.1, height: 0.1),
    );

    await tester.pumpWidget(
      Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DeskFrame(ref: bgRef, fit: BoxFit.cover, child: const _SolidImage()),
              DeskFrame(ref: fgRef, fit: BoxFit.contain, child: const _SolidImage()),
            ],
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(Stack).first,
      matchesGoldenFile('goldens/desk_frame_stack_aligned.png'),
    );
  });
```

- [ ] **Step 2: Generate and verify the golden inside Docker**

```bash
docker run --rm -v "$PWD:/work" -w /work/packages/dart_desk_widgets <flutter-image> \
  flutter test --update-goldens test/desk_frame_golden_test.dart
docker run --rm -v "$PWD:/work" -w /work/packages/dart_desk_widgets <flutter-image> \
  flutter test test/desk_frame_golden_test.dart
```

Expected: PASS.

- [ ] **Step 3: Visually inspect**

Open `desk_frame_stack_aligned.png`. The foreground square should sit centered in the box; the background's hotspot focal point (top-center of the wide image) should anchor to the box center. Confirm both layers are visible and not collapsed.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk_widgets/test/desk_frame_golden_test.dart packages/dart_desk_widgets/test/goldens/desk_frame_stack_aligned.png
git commit -m "test(dart_desk_widgets): golden for Stack composition with aligned hotspots"
```

---

## Task 9: Final verification across the workspace

- [ ] **Step 1: Bootstrap fresh**

```bash
melos clean && melos bootstrap
```

Expected: completes; all packages resolve.

- [ ] **Step 2: Analyze everything**

```bash
melos run analyze
```

Expected: PASS for all four packages.

- [ ] **Step 3: Test everything (non-golden tests, native)**

```bash
melos run test
```

Expected: PASS, including the existing `dart_desk` tests (which still consume `framing_math` via the re-export shim) and the new `dart_desk_widgets` non-golden tests.

- [ ] **Step 4: Run goldens for both `dart_desk` and `dart_desk_widgets` inside Docker**

Use the existing Docker harness for `dart_desk` goldens, plus the new `dart_desk_widgets` goldens:

```bash
docker run --rm -v "$PWD:/work" -w /work/packages/dart_desk <flutter-image> flutter test
docker run --rm -v "$PWD:/work" -w /work/packages/dart_desk_widgets <flutter-image> flutter test
```

Expected: both PASS.

- [ ] **Step 5: Publish dry-run**

```bash
melos run dry-run --no-select
```

Expected: `dart_desk_widgets` reports a successful dry-run (warnings about live homepage URL acceptable). `dart_desk_annotation`, `dart_desk_generator`, and `dart_desk` continue to pass dry-run.

- [ ] **Step 6: Commit any incidental fixes from verification**

```bash
git status
# If any files changed during verification, review and commit.
git commit -m "chore: post-verification fixes" || true
```

---

## Out of Scope (separate plans, not addressed here)

- Cloud transform URL builder (`imageUrl(ref, w, h, fit)` for imgproxy / Cloudflare Images / Imgix).
- Deduping `packages/dart_desk/lib/src/data/models/image_types.dart` against `packages/dart_desk_annotation/lib/src/models/image_types.dart`.
- Migrating existing studio editor previews to render via `DeskFrame` instead of their current ad-hoc pipeline.
- Additional runtime widgets (`DeskBlockContent`, etc.).
