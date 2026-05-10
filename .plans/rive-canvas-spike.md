# Rive Canvas v1 — Slot-Bounds Runtime Spike Plan

> **For agentic workers (opencode):** Implement tasks in order. Each task ends with verify commands; do not proceed past a failing verify. Steps use checkbox (`- [ ]`) syntax. The spike is exploratory in places — for tasks marked `[exploratory]` the test contract is fixed but you may discover the actual Rive API; capture what you found in the findings doc (Task 14).

**Goal:** Decide whether a Flutter widget can be reliably mounted at the world-rect of a named layout container inside a Rive artboard, at 60fps, using only published `rive: ^0.14.6` APIs. Produce working software (a probe app + unit tests) and a written go/no-go finding. This is the gating spike from spec §11 step 1.

**Architecture:** Standalone Flutter package `dart_desk_canvas` containing the `SlotBoundsRuntime` (walks a Rive artboard, finds layout components prefixed `slot:`, exposes their world rect each frame as `ValueListenable<Rect>`). A standalone example app `canvas_spike` loads a fixture `.riv`, renders the artboard full-bleed, and overlays a Flutter `Container` at the slot rect — visually proving the runtime works as the artboard animates and resizes.

**Tech Stack:** Flutter (SDK ^3.10.1), `rive: ^0.14.6`, melos workspace, `flutter_test`, `path_provider`.

**Spec:** [docs/superpowers/specs/2026-05-09-rive-canvas-server-driven-ui-design.md](../docs/superpowers/specs/2026-05-09-rive-canvas-server-driven-ui-design.md)

**Repo:** `dart_desk` (Flutter side only; no backend work in this plan).

**Worktree:** Implementer must run inside a `git worktree` off `main` named `spike/rive-canvas`. The plan assumes this worktree exists; create it if not via `git -C <repo> worktree add ../dart_desk-spike-rive-canvas spike/rive-canvas` before starting.

---

## File structure

### Created
- `packages/dart_desk_canvas/` — new package
  - `pubspec.yaml`
  - `analysis_options.yaml`
  - `lib/dart_desk_canvas.dart` — public exports
  - `lib/src/slot_bounds_runtime.dart` — `SlotBoundsRuntime` + helpers
  - `test/slot_bounds_runtime_test.dart` — unit tests
  - `test/fixtures/spike_artboard.riv` — fixture (binary asset committed to repo)
  - `test/fixtures/README.md` — how the fixture was authored
- `examples/canvas_spike/` — visual probe app (excluded from publishing via `publish_to: none`)
  - `pubspec.yaml`
  - `lib/main.dart`
  - `assets/spike_artboard.riv` — same fixture, copied for asset bundling
  - `linux/`, `macos/`, `windows/`, `android/`, `ios/` — created via `flutter create`
- `docs/spikes/2026-05-09-rive-canvas-spike-findings.md` — written go/no-go report at end

### Modified
- `melos.yaml` — register the new package and example
- (none else)

---

## Task 1: Create `dart_desk_canvas` package skeleton

**Files:**
- Create: `packages/dart_desk_canvas/pubspec.yaml`
- Create: `packages/dart_desk_canvas/analysis_options.yaml`
- Create: `packages/dart_desk_canvas/lib/dart_desk_canvas.dart`
- Modify: `melos.yaml`

- [ ] **Step 1: Create `pubspec.yaml`**

```yaml
name: dart_desk_canvas
description: Server-driven Rive canvas runtime for dart_desk apps. v1 spike.
version: 0.0.1
publish_to: none

environment:
  sdk: ^3.10.1
  flutter: ">=3.0.0"

resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  rive: ^0.14.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

- [ ] **Step 2: Create `analysis_options.yaml`**

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
```

- [ ] **Step 3: Create stub public exports `lib/dart_desk_canvas.dart`**

```dart
library;

export 'src/slot_bounds_runtime.dart';
```

- [ ] **Step 4: Register package in `melos.yaml`**

In the `packages:` list, add `- packages/dart_desk_canvas` and `- examples/canvas_spike` if not already covered by `examples/*`. (The existing config already has `examples/*`, so only the package line is new.)

Edit `melos.yaml`: in the `packages:` block, after `- packages/dart_desk_widgets`, add:
```yaml
  - packages/dart_desk_canvas
```

Also add `dart_desk_canvas` to the `analyze` script's `scope` list:
```yaml
  analyze:
    run: dart analyze --fatal-infos
    packageFilters:
      scope:
        - dart_desk
        - dart_desk_annotation
        - dart_desk_generator
        - dart_desk_widgets
        - dart_desk_canvas
```

- [ ] **Step 5: Run pub get via melos**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk && melos bootstrap`
Expected: completes with no errors; `dart_desk_canvas` is listed.

- [ ] **Step 6: Commit**

```bash
git add melos.yaml packages/dart_desk_canvas
git commit -m "feat(canvas): scaffold dart_desk_canvas package for spike"
```

---

## Task 2: Create the fixture `.riv` artboard

This task is **manual** — it produces the binary asset the rest of the plan depends on. Do this once and commit the binary.

**Files:**
- Create: `packages/dart_desk_canvas/test/fixtures/spike_artboard.riv`
- Create: `packages/dart_desk_canvas/test/fixtures/README.md`

**Required artboard contents:**
- Artboard named `Spike` sized 800×1200, default fit/alignment.
- A state machine named `SM` with two states: `Idle` and `Animated`. Add a number input `t` (0..1); animation in `Animated` translates the slot container 100px down over 2s as `t` advances.
- Inside the artboard, a Layout column with three children:
  1. A solid red rectangle 800×200 at top, named `header` (decoration).
  2. An empty Layout container 800×400, **name: `slot:probe`**, Fill alignment.
  3. A solid blue rectangle 800×200 at bottom, named `footer` (decoration).
- A ViewModel `SpikeVm` exposing one number property `t` bound to the SM input `t`.
- Export `.riv` from the Rive editor.

- [ ] **Step 1: Author the artboard in Rive editor (rive.app) per the spec above**

If you do not have a Rive account, create a free one. The artboard layout, names, state machine, and VM property names listed above are required by later tests — do not deviate.

- [ ] **Step 2: Save the exported `.riv` to `packages/dart_desk_canvas/test/fixtures/spike_artboard.riv`**

- [ ] **Step 3: Write `packages/dart_desk_canvas/test/fixtures/README.md`**

```markdown
# spike_artboard.riv

Fixture used by `dart_desk_canvas` tests and the `canvas_spike` example.

## Authored contents

- Artboard `Spike`, 800×1200, default fit.
- State machine `SM` with input `t` (number, 0..1).
  - `Idle` (default): nothing.
  - `Animated`: as `t` ramps 0→1 over 2s, the layout container `slot:probe` translates 100px downward.
- Layout column (top to bottom):
  - `header`: red rect, 800×200.
  - `slot:probe`: empty layout container, 800×400, Fill alignment.
  - `footer`: blue rect, 800×200.
- ViewModel `SpikeVm` with number property `t` bound to SM input `t`.

If this file is regenerated or modified, also update tests under
`packages/dart_desk_canvas/test/` and the example app under
`examples/canvas_spike/`.
```

- [ ] **Step 4: Commit the fixture**

```bash
git add packages/dart_desk_canvas/test/fixtures
git commit -m "test(canvas): add Rive fixture artboard for slot-bounds spike"
```

---

## Task 3: Write a failing test that loads the fixture and locates `slot:probe`

The first test fixes the public contract: given an artboard, return the layout component named `slot:probe`, or null.

**Files:**
- Create: `packages/dart_desk_canvas/lib/src/slot_bounds_runtime.dart`
- Create: `packages/dart_desk_canvas/test/slot_bounds_runtime_test.dart`

- [ ] **Step 1: Create the empty implementation file**

```dart
// packages/dart_desk_canvas/lib/src/slot_bounds_runtime.dart
import 'package:rive/rive.dart';

class SlotBoundsRuntime {
  /// Finds the named slot container inside [artboard].
  /// Returns null if not found.
  /// A "slot container" is a layout component whose name begins with `slot:`.
  static Object? findSlotContainer(Object artboard, String slotName) {
    throw UnimplementedError();
  }
}
```

(The `Object?` return type is intentional for now — Task 5 will tighten it once we know the actual rive API type.)

- [ ] **Step 2: Write the failing test**

```dart
// packages/dart_desk_canvas/test/slot_bounds_runtime_test.dart
import 'dart:io';

import 'package:dart_desk_canvas/dart_desk_canvas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart';
import 'package:rive_native/rive_native.dart';

void main() {
  late File fixture;

  setUpAll(() {
    fixture = File('test/fixtures/spike_artboard.riv');
    expect(fixture.existsSync(), isTrue,
        reason: 'fixture must be authored — see Task 2');
  });

  test('findSlotContainer returns the slot:probe component', () async {
    final bytes = await fixture.readAsBytes();
    final riveFile = await File.asset(
      // adjust loader to use bytes — actual API discovered in Task 5
    );
    final artboard = riveFile.artboard('Spike');
    final probe = SlotBoundsRuntime.findSlotContainer(artboard, 'probe');
    expect(probe, isNotNull);
  });

  test('findSlotContainer returns null for unknown slot name', () async {
    final bytes = await fixture.readAsBytes();
    // ... loader pattern same as above
    final artboard = /* ... */;
    final missing = SlotBoundsRuntime.findSlotContainer(artboard, 'does_not_exist');
    expect(missing, isNull);
  });
}
```

(The loader call is intentionally pseudo — Task 4 finalises it once the actual rive 0.14.6 loader API is confirmed.)

- [ ] **Step 3: Run the test and confirm it fails**

Run: `cd packages/dart_desk_canvas && flutter test test/slot_bounds_runtime_test.dart`
Expected: FAIL — `UnimplementedError` and/or compile errors on the loader pattern. **Do not proceed until you observe a real failure** (not skipped tests).

---

## Task 4: Implement the loader and confirm the API surface `[exploratory]`

Discover the correct rive 0.14.6 API for: loading a `.riv` from bytes, getting an artboard by name. The public `rive` package exports include `RiveFile`/`File`, `RiveWidgetController`, `Artboard`, `Component`, `ViewModelInstance`. Look in `package:rive/rive.dart` and the published API on pub.dev.

- [ ] **Step 1: Skim `lib/dart_desk_canvas/.dart_tool/package_config.json` to find the resolved rive package path, then read `<rive>/lib/rive.dart` exports**

Run: `cd packages/dart_desk_canvas && cat .dart_tool/package_config.json | grep rive`
Then `cat` the resolved `rive.dart` to list exports.

- [ ] **Step 2: Update the test loader to use the discovered API**

The shape will look something like:
```dart
final bytes = await fixture.readAsBytes();
final riveFile = await File.decode(bytes, riveFactory: Factory.flutter);
final artboard = riveFile.artboard('Spike');
```

Use the **actual** API name from your discovery; the snippet above is the documented 0.14.x shape but may have evolved. Capture the final loader pattern in a private helper `_loadFixture()` at the top of the test file.

- [ ] **Step 3: Run the test**

Run: `cd packages/dart_desk_canvas && flutter test test/slot_bounds_runtime_test.dart`
Expected: tests still fail, but now on `UnimplementedError` from `findSlotContainer`, not on the loader.

---

## Task 5: Implement `findSlotContainer` `[exploratory]`

Walk the artboard's component tree to find a layout component whose name starts with `slot:`. The rive package exposes `Component` with a `name` property; layout components are a subtype. Look for a tree-walk helper or use `artboard.objects` / similar enumeration.

- [ ] **Step 1: Discover the traversal API**

Read `lib/src/rive_extensions.dart` exported by `package:rive`. Look for any `forEachChild`, `objects`, `components`, or visitor pattern. Document what you find inline as a code comment in `slot_bounds_runtime.dart`.

- [ ] **Step 2: Replace `findSlotContainer` body with the discovered traversal**

Tighten the signature once the type is known, e.g.:

```dart
import 'package:rive/rive.dart';

class SlotBoundsRuntime {
  /// Returns the layout component named `slot:<slotName>` inside [artboard],
  /// or null if no such component exists.
  static Component? findSlotContainer(Artboard artboard, String slotName) {
    final target = 'slot:$slotName';
    Component? found;
    artboard.forEachComponent((c) {
      if (found == null && c.name == target) found = c;
    });
    return found;
  }
}
```

If `forEachComponent` does not exist verbatim, use whatever traversal API the rive 0.14.6 source provides. Do not invent APIs — only use what is exported or accessible.

- [ ] **Step 3: Run the tests**

Run: `cd packages/dart_desk_canvas && flutter test test/slot_bounds_runtime_test.dart`
Expected: both tests PASS.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk_canvas
git commit -m "feat(canvas): findSlotContainer locates named layout containers"
```

---

## Task 6: Failing test — slot's local bounds are non-zero

`Component.localBounds` was exposed in rive 0.14.0-dev.7. Verify it returns a sane rect for our 800×400 slot.

- [ ] **Step 1: Add the test**

Append to `slot_bounds_runtime_test.dart`:

```dart
test('slot:probe has local bounds matching the authored 800x400 size', () async {
  final artboard = await _loadFixture();
  final probe = SlotBoundsRuntime.findSlotContainer(artboard, 'probe')!;
  final rect = SlotBoundsRuntime.localBoundsOf(probe);
  expect(rect.width, closeTo(800, 1.0));
  expect(rect.height, closeTo(400, 1.0));
});
```

- [ ] **Step 2: Run, confirm failure**

Run: `cd packages/dart_desk_canvas && flutter test`
Expected: FAIL on missing `localBoundsOf` method.

---

## Task 7: Implement `localBoundsOf` `[exploratory]`

- [ ] **Step 1: Locate `localBounds` on `Component`**

Read the rive package's component source. The 0.14.0-dev.7 changelog says: *"Expose `localBounds` on `Component`."* Confirm the type — likely `AABB` (rive's axis-aligned bounding box) with `min` / `max` or `left/top/right/bottom` accessors. Adapt to a Flutter `Rect`.

- [ ] **Step 2: Add the method**

```dart
import 'dart:ui';
import 'package:rive/rive.dart';

extension on Object {
  // Note: import the right type for AABB → Rect conversion based on the
  // discovered API surface. The shape below is illustrative.
}

class SlotBoundsRuntime {
  // ... existing findSlotContainer ...

  /// Returns the slot's local bounds as a Flutter [Rect].
  static Rect localBoundsOf(Component c) {
    final aabb = c.localBounds; // adapt if the field name differs
    return Rect.fromLTRB(aabb.left, aabb.top, aabb.right, aabb.bottom);
  }
}
```

- [ ] **Step 3: Run test**

Run: `cd packages/dart_desk_canvas && flutter test`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk_canvas
git commit -m "feat(canvas): expose slot localBounds as Flutter Rect"
```

---

## Task 8: Failing test — artboard-space bounds account for the parent layout

The slot lives at y≈200 inside the artboard (after the 200px header). Local bounds alone aren't enough — we need artboard-space bounds. Use `getTransformTo` (mentioned in 0.14.0-dev.12 changelog) to compose the parent transform.

- [ ] **Step 1: Add the test**

```dart
test('artboardBoundsOf positions slot:probe below the header in artboard space', () async {
  final artboard = await _loadFixture();
  final probe = SlotBoundsRuntime.findSlotContainer(artboard, 'probe')!;
  final rect = SlotBoundsRuntime.artboardBoundsOf(probe, artboard);
  // Header is 200px tall, so slot top should be ~200.
  expect(rect.top, closeTo(200, 2.0));
  expect(rect.left, closeTo(0, 2.0));
  expect(rect.width, closeTo(800, 2.0));
  expect(rect.height, closeTo(400, 2.0));
});
```

- [ ] **Step 2: Run, confirm failure**

Run: `cd packages/dart_desk_canvas && flutter test`
Expected: FAIL on missing `artboardBoundsOf`.

---

## Task 9: Implement `artboardBoundsOf` `[exploratory]`

- [ ] **Step 1: Find the parent-chain transform API**

Look for any of: `c.worldTransform`, `c.getTransformTo(artboard)`, `c.parent`, `Component.computeWorldTransform()`. The 0.14.0-dev.12 changelog mentions `getTransformTo` returning a transform — adapt.

- [ ] **Step 2: Implement**

Pseudocode shape (adjust to actual API):

```dart
static Rect artboardBoundsOf(Component c, Artboard artboard) {
  final local = localBoundsOf(c);
  final transform = c.getTransformTo(artboard); // discover actual API
  // transform is a Mat2D or Float32List; transform the four corners and AABB them
  final tl = transform.transformPoint(local.topLeft);
  final tr = transform.transformPoint(local.topRight);
  final bl = transform.transformPoint(local.bottomLeft);
  final br = transform.transformPoint(local.bottomRight);
  return Rect.fromLTRB(
    [tl.dx, tr.dx, bl.dx, br.dx].reduce(min),
    [tl.dy, tr.dy, bl.dy, br.dy].reduce(min),
    [tl.dx, tr.dx, bl.dx, br.dx].reduce(max),
    [tl.dy, tr.dy, bl.dy, br.dy].reduce(max),
  );
}
```

If `getTransformTo` does not exist, fall back to walking `c.parent` and composing each layout offset manually.

- [ ] **Step 3: Run tests**

Run: `cd packages/dart_desk_canvas && flutter test`
Expected: all tests PASS.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk_canvas
git commit -m "feat(canvas): compose artboard-space bounds via parent transform"
```

---

## Task 10: Failing test — widget-space rect maps to the rendered viewport

Given an artboard rendered with `Fit.contain` in a 1080×1920 viewport (phone portrait), a slot at artboard y≈200 of an 800×1200 artboard should map to roughly y≈300 in widget pixels (artboard scaled to 1080×1620 letterboxed, so each artboard pixel = 1.35 widget px; 200 * 1.35 = 270 plus letterbox offset of ~150).

- [ ] **Step 1: Add the test**

```dart
test('widgetRectFor maps artboard rect to rendered viewport with Fit.contain', () async {
  final artboard = await _loadFixture();
  final probe = SlotBoundsRuntime.findSlotContainer(artboard, 'probe')!;
  final ab = SlotBoundsRuntime.artboardBoundsOf(probe, artboard);
  const viewport = Size(1080, 1920);
  final widgetRect = SlotBoundsRuntime.widgetRectFor(
    artboardRect: ab,
    artboardSize: const Size(800, 1200),
    viewport: viewport,
    fit: BoxFit.contain,
    alignment: Alignment.center,
  );
  // 800x1200 artboard in 1080x1920 viewport with contain: scale = 1.35,
  // rendered size = 1080x1620, vertical letterbox = (1920-1620)/2 = 150.
  // Slot at artboard y=200 → viewport y = 150 + 200*1.35 = 420.
  expect(widgetRect.top, closeTo(420, 2.0));
  expect(widgetRect.left, closeTo(0, 2.0));
  expect(widgetRect.width, closeTo(1080, 2.0));
  expect(widgetRect.height, closeTo(540, 2.0));
});
```

- [ ] **Step 2: Run, confirm failure**

Run: `cd packages/dart_desk_canvas && flutter test`
Expected: FAIL on missing `widgetRectFor`.

---

## Task 11: Implement `widgetRectFor`

This one is **not exploratory** — it's pure math, mirroring what Flutter's `BoxFit` does.

- [ ] **Step 1: Implement**

```dart
static Rect widgetRectFor({
  required Rect artboardRect,
  required Size artboardSize,
  required Size viewport,
  required BoxFit fit,
  required Alignment alignment,
}) {
  final fitted = applyBoxFit(fit, artboardSize, viewport);
  final scaleX = fitted.destination.width / fitted.source.width;
  final scaleY = fitted.destination.height / fitted.source.height;
  // For Fit.contain / Fit.cover etc. the source is artboardSize and the
  // destination is the rendered area inside the viewport.
  final renderedSize = fitted.destination;
  final dx = (viewport.width - renderedSize.width) * (alignment.x + 1) / 2;
  final dy = (viewport.height - renderedSize.height) * (alignment.y + 1) / 2;
  return Rect.fromLTWH(
    dx + artboardRect.left * scaleX,
    dy + artboardRect.top * scaleY,
    artboardRect.width * scaleX,
    artboardRect.height * scaleY,
  );
}
```

- [ ] **Step 2: Run tests**

Run: `cd packages/dart_desk_canvas && flutter test`
Expected: all tests PASS.

- [ ] **Step 3: Add an additional test for `Fit.cover` to lock the math**

```dart
test('widgetRectFor handles Fit.cover by clipping the source', () async {
  // 800x1200 artboard in 1080x600 viewport with cover: scale = 1.35 (height limited),
  // wait — cover scales to 1080/800=1.35 and 600/1200=0.5; cover takes the larger=1.35.
  // Rendered size = 1080x1620, viewport y-offset = (600-1620)/2 = -510.
  // Slot at artboard y=200 → viewport y = -510 + 200*1.35 = -240.
  final artboardRect = const Rect.fromLTWH(0, 200, 800, 400);
  final w = SlotBoundsRuntime.widgetRectFor(
    artboardRect: artboardRect,
    artboardSize: const Size(800, 1200),
    viewport: const Size(1080, 600),
    fit: BoxFit.cover,
    alignment: Alignment.center,
  );
  expect(w.top, closeTo(-240, 2.0));
  expect(w.height, closeTo(540, 2.0));
});
```

Run again: `flutter test` — expect PASS.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk_canvas
git commit -m "feat(canvas): map artboard-space rects into Flutter viewport pixels"
```

---

## Task 12: Build the visual probe app

Now the hard part: prove this actually works on screen, while the artboard animates.

**Files:**
- Create: `examples/canvas_spike/` (full Flutter app via `flutter create`)
- Create: `examples/canvas_spike/lib/main.dart`
- Create: `examples/canvas_spike/assets/spike_artboard.riv` (copy of the fixture)
- Modify: `examples/canvas_spike/pubspec.yaml`

- [ ] **Step 1: Generate the app skeleton**

Run from the dart_desk repo root:
```bash
flutter create --org dev.dartdesk --platforms=ios,android,macos --project-name canvas_spike examples/canvas_spike
```

- [ ] **Step 2: Replace the generated `examples/canvas_spike/pubspec.yaml`**

```yaml
name: canvas_spike
description: Visual probe for the Rive canvas slot-bounds runtime spike.
version: 0.0.1
publish_to: none

environment:
  sdk: ^3.10.1
  flutter: ">=3.0.0"

resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  rive: ^0.14.6
  dart_desk_canvas:
    path: ../../packages/dart_desk_canvas

flutter:
  uses-material-design: true
  assets:
    - assets/spike_artboard.riv
```

- [ ] **Step 3: Copy the fixture into the example app's assets**

```bash
cp packages/dart_desk_canvas/test/fixtures/spike_artboard.riv \
   examples/canvas_spike/assets/spike_artboard.riv
```

- [ ] **Step 4: Replace `examples/canvas_spike/lib/main.dart`**

```dart
import 'package:dart_desk_canvas/dart_desk_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const SpikeApp());
}

class SpikeApp extends StatelessWidget {
  const SpikeApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SpikeHome(),
      );
}

class SpikeHome extends StatefulWidget {
  const SpikeHome({super.key});
  @override
  State<SpikeHome> createState() => _SpikeHomeState();
}

class _SpikeHomeState extends State<SpikeHome> {
  RiveWidgetController? _controller;
  Component? _slot;
  final _slotRect = ValueNotifier<Rect>(Rect.zero);
  Ticker? _ticker;
  BoxFit _fit = BoxFit.contain;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bytes = await rootBundle.load('assets/spike_artboard.riv');
    final file = await File.decode(
      bytes.buffer.asUint8List(),
      riveFactory: Factory.flutter,
    );
    // The 0.14.5 changelog adds an optional `viewModelInstance` parameter
    // to `File.artboardToBind` — use that path so the SpikeVm is bound and
    // available for Task 13. The exact constructor/factory name comes from
    // the discovery in Task 4; the line below is the documented shape.
    final controller = RiveWidgetController(file, artboardName: 'Spike');
    final slot = SlotBoundsRuntime.findSlotContainer(controller.artboard, 'probe');
    setState(() {
      _controller = controller;
      _slot = slot;
    });
    _ticker = Ticker((_) => _updateRect())..start();
  }

  void _updateRect() {
    final c = _controller, s = _slot;
    if (c == null || s == null) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final viewport = renderBox.size;
    final ab = SlotBoundsRuntime.artboardBoundsOf(s, c.artboard);
    final widget = SlotBoundsRuntime.widgetRectFor(
      artboardRect: ab,
      artboardSize: Size(c.artboard.width, c.artboard.height),
      viewport: viewport,
      fit: _fit,
      alignment: Alignment.center,
    );
    if (widget != _slotRect.value) _slotRect.value = widget;
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canvas spike'),
        actions: [
          PopupMenuButton<BoxFit>(
            initialValue: _fit,
            onSelected: (v) => setState(() => _fit = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: BoxFit.contain, child: Text('contain')),
              PopupMenuItem(value: BoxFit.cover, child: Text('cover')),
              PopupMenuItem(value: BoxFit.fill, child: Text('fill')),
            ],
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          RiveWidget(controller: c, fit: _fit),
          ValueListenableBuilder<Rect>(
            valueListenable: _slotRect,
            builder: (_, r, __) => Positioned.fromRect(
              rect: r,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent, width: 3),
                    color: Colors.green.withValues(alpha: 0.15),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'slot:probe (Flutter)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

(If `RiveWidgetController`, `Factory.flutter`, or `RiveWidget` constructor signatures differ from what you discovered in Task 4, adjust to match. Document any deviation in the findings doc, Task 14.)

- [ ] **Step 5: Run on macOS or your dev simulator**

Run: `cd examples/canvas_spike && flutter run -d macos`
(Or another available device — `flutter devices` to list.)

Expected: the app launches; the artboard renders with header / slot / footer; a green-bordered Flutter overlay appears precisely over the `slot:probe` rectangle. Resize the window — the overlay tracks. Switch fit mode — overlay still tracks.

- [ ] **Step 6: Commit**

```bash
git add examples/canvas_spike melos.yaml
git commit -m "feat(canvas-spike): visual probe app for slot-bounds tracking"
```

---

## Task 13: Animate the artboard and verify the overlay tracks at 60fps

The fixture's `Animated` state translates `slot:probe` 100px down over 2s. Trigger that animation and confirm the overlay follows smoothly.

**Files:**
- Modify: `examples/canvas_spike/lib/main.dart`

- [ ] **Step 1: Add a button that drives the `t` ViewModel input from 0→1 over 2s**

Inside `_SpikeHomeState`, after `_load()`, add:

```dart
late ViewModelInstance _vm;

Future<void> _load() async {
  // ... existing load code ...
  _vm = controller.artboard.viewModelInstance!;
  // store on state
}

void _animate() async {
  final tProp = _vm.number('t')!;
  final start = DateTime.now();
  while (mounted) {
    final elapsed = DateTime.now().difference(start).inMilliseconds / 2000;
    if (elapsed >= 1) {
      tProp.value = 1.0;
      break;
    }
    tProp.value = elapsed.clamp(0.0, 1.0);
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }
}
```

Add a FloatingActionButton:
```dart
floatingActionButton: FloatingActionButton(
  onPressed: _animate,
  child: const Icon(Icons.play_arrow),
),
```

- [ ] **Step 2: Run the probe again, tap play, observe**

Run: `flutter run -d <device> --profile`
Expected: the green Flutter overlay translates smoothly with the slot during the 2-second animation. **Watch for jitter, frame drops, lag.** This is the actual signal of whether the spike succeeds.

- [ ] **Step 3: Capture FPS via `flutter run --profile` performance overlay**

Toggle the perf overlay (tap with two fingers on simulator, or `P` in CLI). Record steady-state FPS during the animation. Note in the findings doc.

- [ ] **Step 4: Commit**

```bash
git add examples/canvas_spike/lib/main.dart
git commit -m "feat(canvas-spike): animate artboard and verify overlay tracking"
```

---

## Task 14: Write the spike findings document

The deliverable that gates the rest of the project.

**Files:**
- Create: `docs/spikes/2026-05-09-rive-canvas-spike-findings.md`

- [ ] **Step 1: Author the findings doc**

```markdown
# Rive Canvas Slot-Bounds Spike — Findings

**Date:** 2026-05-09
**Goal:** decide go/no-go on the canvas approach (spec §11 step 1).

## Outcome

[GO | CONDITIONAL GO | NO-GO]

[One paragraph summary.]

## What worked

- [API name] for [purpose] — verified via test [test name].
- ...

## What didn't work / what's flaky

- ...

## Final API surface used

| Need | rive 0.14.6 API used |
|---|---|
| Load file from bytes | `File.decode(bytes, riveFactory: Factory.flutter)` |
| Get artboard by name | `RiveFile.artboard(name)` |
| Walk component tree | [actual API] |
| Component name | `Component.name` |
| Local bounds | `Component.localBounds` |
| Parent transform | [actual API] |
| ... | ... |

## Performance

- Device: [e.g. M2 MacBook, Pixel 7]
- Build mode: profile
- Steady-state FPS during animation: [N]
- Worst-case FPS: [N]
- Jank events: [yes/no, description]

## Recommendation

[Proceed to platform plan | Pause and re-spike with X | Fall back to composition-list approach]

## Caveats for the platform plan

- [Anything the v1 platform plan needs to know that wasn't in the spec.]
- [Open questions that should be resolved before proceeding.]
```

Fill in honestly based on what you observed.

- [ ] **Step 2: Commit**

```bash
git add docs/spikes/2026-05-09-rive-canvas-spike-findings.md
git commit -m "docs(canvas): spike findings — go/no-go decision recorded"
```

- [ ] **Step 3: Run final analyze + test for hygiene**

Run from the dart_desk repo root:
```bash
melos run analyze
cd packages/dart_desk_canvas && flutter test
```

Expected: no analyzer issues; all tests pass.

---

## Verification gate

Before declaring the spike complete, all of these must be true:

- [ ] `flutter test` in `packages/dart_desk_canvas` exits 0 with all tests passing.
- [ ] `melos run analyze` exits 0 with zero issues in `dart_desk_canvas`.
- [ ] `examples/canvas_spike` runs on at least one platform; the green overlay visibly tracks `slot:probe` while the artboard animates.
- [ ] FPS during animation is recorded in the findings doc.
- [ ] `docs/spikes/2026-05-09-rive-canvas-spike-findings.md` ends with a clear GO / CONDITIONAL GO / NO-GO recommendation.
- [ ] All commits are pushed to the `spike/rive-canvas` branch.

---

## What's NOT in this plan (deferred)

- `RiveBundleCache` (spec §3.1) — covered in the v1 platform plan, after the spike passes.
- `RiveTemplatedScreen` widget proper (spec §3.1) — same.
- `SlotRegistry`, `ActionCatalog`, `RiveEventDispatcher`, `ScrollOffsetBridge`, `TemplateFallback` — same.
- `HitTestPartitioner` — same; for the spike, the overlay is an `IgnorePointer`.
- All Serverpod work (spec §3.2) — separate plan in `dart_desk_be`.
- All CMS authoring UI (spec §3.2) — separate plan.
- Probe screen with real `addToCart` — separate plan after the platform exists.

The spike's purpose is *only* to confirm that mounting Flutter widgets at named-slot world rects is technically viable. Everything else assumes that answer is yes.
