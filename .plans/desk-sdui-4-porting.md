# desk_sdui Phase 4 — Porting & Validation Plan

> **For agentic workers:** This plan ports six real screens to `@Screen`, validates them against original Dart-only versions via golden tests, and locks the v1 success criteria. Phases 1-3 must be complete and committed first. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Validate the v1 spec by porting `chef_screen.dart` (from `examples/example_app`) and the five `home_screen` variants (from `foodtech_flutter_design_system`) as `@Screen` functions, render them via `desk_sdui`, and golden-test side-by-side parity with the originals. Cap with a perf benchmark and a 15-min onboarding README.

**Architecture:** New consumer package `packages/desk_sdui_demo/` inside the desk_sdui repo, with both the original Dart-only screens (vendored from foodtech and example_app) and the new `@Screen` ports. Each port is its own `_Test` widget feeding a deterministic data + ViewModel into both renderings. Goldens captured under `goldens/`.

**Tech Stack:** `desk_sdui` + `desk_sdui_annotation` + `desk_sdui_generator` (path deps), Flutter SDK, `flutter_test` for golden tests, source assets vendored from `foodtech_flutter_design_system` and `examples/example_app/lib/screens/chef_screen.dart`.

**Repo:** `/Users/vietthangvunguyen/Workspace/dart_desk_workspace/desk_sdui`

---

## File Structure

```
packages/desk_sdui_demo/
├── pubspec.yaml
├── lib/
│   ├── desk_sdui_demo.dart          ← public exports for tests
│   ├── desk_sdui_setup.dart          ← handwritten init
│   ├── desk_sdui_setup.sdui.g.dart   ← generated _registerAll
│   ├── data/
│   │   ├── chef_data.dart
│   │   └── home_data.dart
│   ├── controllers/
│   │   ├── chef_controller.dart
│   │   └── home_controller.dart
│   ├── widgets/
│   │   ├── app_image.dart           ← user-defined widgets used by screens
│   │   ├── category_tile.dart
│   │   ├── product_card.dart
│   │   ├── recent_order_tile.dart
│   │   └── ...
│   ├── original/                     ← vendored Dart-only screens (untouched)
│   │   ├── chef_screen_original.dart
│   │   ├── home_vertical_basic.dart
│   │   ├── home_vertical_categories.dart
│   │   ├── home_vertical_image.dart
│   │   ├── home_vertical_recent_order.dart
│   │   └── home_vertical_scroll.dart
│   └── screens/                      ← @Screen ports
│       ├── chef.dart                 ← + chef.sdui.g.dart + chef.uib
│       ├── home_basic.dart
│       ├── home_categories.dart
│       ├── home_image.dart
│       ├── home_recent_order.dart
│       └── home_scroll.dart
├── test/
│   ├── parity/
│   │   ├── chef_parity_test.dart
│   │   ├── home_basic_parity_test.dart
│   │   ├── home_categories_parity_test.dart
│   │   ├── home_image_parity_test.dart
│   │   ├── home_recent_order_parity_test.dart
│   │   └── home_scroll_parity_test.dart
│   ├── misuse/
│   │   ├── async_in_screen_test.dart
│   │   ├── set_state_test.dart
│   │   ├── mutable_local_test.dart
│   │   ├── try_catch_test.dart
│   │   ├── counter_loop_test.dart
│   │   ├── nested_function_test.dart
│   │   └── unregistered_widget_test.dart
│   └── perf/
│       └── resolve_benchmark_test.dart
└── goldens/                           ← captured by parity tests
    ├── chef.png
    ├── chef.sdui.png
    ├── home_basic.png
    ├── home_basic.sdui.png
    └── ...
```

---

## Task 1: Bootstrap `desk_sdui_demo` package

**Files:**
- Create: `packages/desk_sdui_demo/pubspec.yaml`
- Create: `packages/desk_sdui_demo/analysis_options.yaml`
- Create: `packages/desk_sdui_demo/lib/desk_sdui_demo.dart`
- Modify: workspace `melos.yaml` (add the new package)

- [ ] **Step 1: pubspec**

```yaml
name: desk_sdui_demo
description: Reference + parity tests for desk_sdui — ports of chef_screen + home variants.
version: 0.0.1-dev
publish_to: none

environment:
  sdk: ^3.6.0
  flutter: ">=3.27.0"

dependencies:
  flutter:
    sdk: flutter
  desk_sdui:
    path: ../desk_sdui
  desk_sdui_annotation:
    path: ../desk_sdui_annotation

dev_dependencies:
  flutter_test:
    sdk: flutter
  desk_sdui_generator:
    path: ../desk_sdui_generator
  build_runner: ^2.15.0
  very_good_analysis: ^7.0.0
```

- [ ] **Step 2: analysis_options**

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  plugins:
    - desk_sdui_generator
```

- [ ] **Step 3: melos.yaml** — append `packages/desk_sdui_demo`

- [ ] **Step 4: `flutter pub get`**

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui_demo melos.yaml
git commit -m "chore(desk_sdui_demo): bootstrap demo package"
```

---

## Task 2: Vendor original screens

Copy `chef_screen.dart` and the five home variants into `lib/original/`. **Do not modify them.** They become the parity reference.

**Files:**
- Copy: `~/Workspace/dart_desk_workspace/dart_desk/examples/example_app/lib/screens/chef_screen.dart` → `packages/desk_sdui_demo/lib/original/chef_screen_original.dart`
- Copy: each of `~/Workspace/foodtech_flutter_design_system/foodtech/lib/screens/home_screens/home_screen_*.dart` → `packages/desk_sdui_demo/lib/original/home_vertical_*.dart`

- [ ] **Step 1: Identify exact source paths**

Run from the dart_desk repo root:
```bash
find /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/examples/example_app -name 'chef_screen.dart'
find /Users/vietthangvunguyen/Workspace/foodtech_flutter_design_system -name 'home_screen*.dart' | head -10
```

Capture the absolute paths.

- [ ] **Step 2: Copy each file** preserving its structure under `lib/original/`. Update import paths to point at `desk_sdui_demo` types where the originals depend on shared types.

- [ ] **Step 3: Replace cross-package imports**

The vendored files originally import from `foodtech_*` packages. Either:
- (a) Vendor those types too into `lib/widgets/` and `lib/data/`, or
- (b) Rewrite imports to point at small re-implementations sufficient to render.

Pick (a) — it's the lowest-friction path and we want byte-faithful goldens.

- [ ] **Step 4: Verify originals render**

Quickly write a smoke test that pumps each original screen with deterministic data and asserts no exceptions.

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui_demo/lib/original packages/desk_sdui_demo/lib/widgets packages/desk_sdui_demo/lib/data
git commit -m "feat(desk_sdui_demo): vendor original chef + home screens"
```

---

## Task 3: Define ViewModels and data shapes

The original screens may use varied state-management; for the parity test we want a single deterministic shape both versions can consume.

**Files:**
- Create: `packages/desk_sdui_demo/lib/data/chef_data.dart`
- Create: `packages/desk_sdui_demo/lib/data/home_data.dart`
- Create: `packages/desk_sdui_demo/lib/controllers/chef_controller.dart`
- Create: `packages/desk_sdui_demo/lib/controllers/home_controller.dart`

- [ ] **Step 1: Extract data shapes from each original screen**

For each screen, identify what data it reads (e.g., `data.title`, `data.items[i].imageUrl`). Write a plain Dart class capturing exactly that surface.

```dart
// lib/data/chef_data.dart
class ChefData {
  const ChefData({
    required this.title,
    required this.heroImage,
    required this.bio,
    required this.specialties,
  });

  final String title;
  final String heroImage;
  final String bio;
  final List<ChefSpecialty> specialties;
}

class ChefSpecialty {
  const ChefSpecialty({required this.id, required this.name, required this.imageUrl});
  final String id;
  final String name;
  final String imageUrl;
}
```

(Repeat for `HomeData` covering the union of fields the five variants read.)

- [ ] **Step 2: Define ViewModels**

For each ViewModel, expose the methods + reactive listenables a `@Screen` would call. Keep them small.

```dart
// lib/controllers/chef_controller.dart
import 'package:flutter/foundation.dart';

class ChefController {
  ChefController({this.onSpecialtyTapped});
  final void Function(String id)? onSpecialtyTapped;
  final ValueNotifier<bool> isLiked = ValueNotifier(false);

  void toggleLike() => isLiked.value = !isLiked.value;
  void selectSpecialty(String id) => onSpecialtyTapped?.call(id);
}
```

- [ ] **Step 3: Build deterministic fixtures**

```dart
// lib/data/fixtures.dart
const chefFixture = ChefData(
  title: 'Chef Anna',
  heroImage: 'assets/chef.png',
  bio: 'Lorem ipsum',
  specialties: [
    ChefSpecialty(id: 's1', name: 'Pasta', imageUrl: 'assets/pasta.png'),
    ChefSpecialty(id: 's2', name: 'Risotto', imageUrl: 'assets/risotto.png'),
  ],
);
```

(Likewise for home variants.)

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui_demo/lib/data packages/desk_sdui_demo/lib/view_models
git commit -m "feat(desk_sdui_demo): data shapes + ViewModels + fixtures"
```

---

## Task 4: Refactor each `original/*.dart` to consume the new data + ViewModel

The originals as vendored may take different shapes — refactor each to take `(<XData>, <XController>)` so both the original and the `@Screen` port have the **identical input contract**. This is the only modification we make to vendored originals.

- [ ] **Step 1: For each original screen, add a top-level `Widget renderXOriginal(XData data, XController controller)` wrapper**

If the original uses provider/inherited state, replace those reads with the explicit `data`/`controller` arguments. Keep the visual output unchanged.

- [ ] **Step 2: Verify each `renderXOriginal` renders without errors against its fixture**

- [ ] **Step 3: Commit**

```bash
git add packages/desk_sdui_demo/lib/original
git commit -m "refactor(desk_sdui_demo): adapt original screens to take (data, controller) args"
```

---

## Task 5: Port `chef_screen` first

This is the smallest screen — port it before tackling home variants.

**Files:**
- Create: `packages/desk_sdui_demo/lib/screens/chef.dart`
- Codegen output: `packages/desk_sdui_demo/lib/screens/chef.sdui.g.dart` and `chef.uib`

- [ ] **Step 1: Author the @Screen function**

```dart
// lib/screens/chef.dart
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:flutter/material.dart';
import '../data/chef_data.dart';
import '../controllers/chef_controller.dart';
import '../widgets/app_image.dart';

part 'chef.sdui.g.dart';

@Screen('chef')
Widget buildChef(ChefData data, ChefController controller) {
  return Column(
    children: [
      AppImage(url: data.heroImage),
      Text(data.title),
      Text(data.bio),
      InkWell(
        onTap: controller.toggleLike,
        child: Icon(
          controller.isLiked() ? Icons.favorite : Icons.favorite_border,
        ),
      ),
      for (final s in data.specialties)
        InkWell(
          key: ValueKey(s.id),
          onTap: () => controller.selectSpecialty(s.id),
          child: Column(children: [
            AppImage(url: s.imageUrl),
            Text(s.name),
          ]),
        ),
    ],
  );
}
```

- [ ] **Step 2: Run build_runner**

```bash
cd packages/desk_sdui_demo
dart run build_runner build --delete-conflicting-outputs
```

Expected: `chef.sdui.g.dart` + `chef.uib` produced; no analyzer plugin errors.

- [ ] **Step 3: Verify it compiles**

```bash
flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui_demo/lib/screens/chef.dart packages/desk_sdui_demo/lib/screens/chef.sdui.g.dart packages/desk_sdui_demo/lib/screens/chef.uib packages/desk_sdui_demo/lib/widgets
git commit -m "feat(desk_sdui_demo): @Screen port of chef_screen"
```

---

## Task 6: Parity test for `chef`

**Files:**
- Create: `packages/desk_sdui_demo/test/parity/chef_parity_test.dart`
- Create on first run: `goldens/chef.png`, `goldens/chef.sdui.png`

- [ ] **Step 1: Write the parity test**

```dart
// test/parity/chef_parity_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desk_sdui/desk_sdui.dart';
import 'package:desk_sdui_demo/desk_sdui_demo.dart';
import 'package:desk_sdui_demo/data/fixtures.dart';
import 'package:desk_sdui_demo/data/chef_data.dart';
import 'package:desk_sdui_demo/controllers/chef_controller.dart';
import 'package:desk_sdui_demo/original/chef_screen_original.dart' as original;
import 'package:desk_sdui_demo/desk_sdui_setup.dart';

void main() {
  testWidgets('chef original render', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: original.renderChefOriginal(chefFixture, ChefController()),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../goldens/chef.png'),
    );
  });

  testWidgets('chef @Screen render', (tester) async {
    initSdui();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SduiScreen(
          name: 'chef',
          runtime: sduiRuntime,
          inputs: {
            'data': chefFixture,
            'controller': ChefController(),
          },
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../goldens/chef.sdui.png'),
    );
  });

  testWidgets('chef parity — pixel-identical', (tester) async {
    // Capture original
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: original.renderChefOriginal(chefFixture, ChefController())),
    ));
    await tester.pumpAndSettle();
    final originalImage = await _captureScene(tester);

    // Capture sdui port
    initSdui();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SduiScreen(
        name: 'chef',
        runtime: sduiRuntime,
        inputs: {'data': chefFixture, 'controller': ChefController()},
      )),
    ));
    await tester.pumpAndSettle();
    final sduiImage = await _captureScene(tester);

    expect(originalImage, equals(sduiImage),
        reason: 'sdui chef render must be pixel-identical to original');
  });
}

Future<List<int>> _captureScene(WidgetTester tester) async {
  // Convenience: capture root widget bytes for byte-equality comparison.
  final boundary = tester.firstWidget(find.byType(MaterialApp));
  // ... use RepaintBoundary trick from flutter goldens infrastructure
  return const [];
}
```

(Use Flutter's golden-test machinery rather than rolling pixel comparison; `matchesGoldenFile` already does byte equality.)

- [ ] **Step 2: First run captures goldens**

```bash
flutter test test/parity/chef_parity_test.dart --update-goldens
```

- [ ] **Step 3: Verify goldens are equal — visually inspect or hash**

```bash
shasum goldens/chef.png goldens/chef.sdui.png
```

If hashes differ, debug the port until they match.

- [ ] **Step 4: Run again without `--update-goldens` to lock**

```bash
flutter test test/parity/chef_parity_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui_demo/test/parity/chef_parity_test.dart packages/desk_sdui_demo/goldens
git commit -m "test(desk_sdui_demo): chef parity goldens — sdui matches original"
```

---

## Task 7-11: Port + parity-test each home variant

Repeat Task 5 + Task 6 for each of the five variants. Pattern is identical; only the screen body differs.

**Files per variant** (using `home_basic` as example — same shape for each):
- Create: `packages/desk_sdui_demo/lib/screens/home_basic.dart`
- Codegen: `packages/desk_sdui_demo/lib/screens/home_basic.sdui.g.dart` + `.uib`
- Test: `packages/desk_sdui_demo/test/parity/home_basic_parity_test.dart`
- Goldens: `goldens/home_basic.png`, `goldens/home_basic.sdui.png`

For **each** of `home_basic`, `home_categories`, `home_image`, `home_recent_order`, `home_scroll`:

- [ ] **Step 1: Author `@Screen` port** — read original, transcribe to @Screen-flavored Dart that conforms to the subset
- [ ] **Step 2: Run `dart run build_runner build`**
- [ ] **Step 3: Author parity test mirroring `chef_parity_test.dart`**
- [ ] **Step 4: Capture goldens** (`flutter test --update-goldens`)
- [ ] **Step 5: Lock — re-run without flag**
- [ ] **Step 6: Commit**

```bash
git add packages/desk_sdui_demo/lib/screens/home_basic.dart \
        packages/desk_sdui_demo/lib/screens/home_basic.sdui.g.dart \
        packages/desk_sdui_demo/lib/screens/home_basic.uib \
        packages/desk_sdui_demo/test/parity/home_basic_parity_test.dart \
        packages/desk_sdui_demo/goldens/home_basic.png \
        packages/desk_sdui_demo/goldens/home_basic.sdui.png
git commit -m "feat(desk_sdui_demo): @Screen port + parity test — home_basic"
```

When porting reveals a missing IR construct or a missing built-in widget — *stop, file the gap as a Phase 1/2/3 fix-up commit, fix it there, and resume.* The whole point of porting is to surface these gaps.

---

## Task 12: Misuse test suite

For every forbidden construct in the spec, write a small `.dart` fixture and assert that the analyzer plugin (or the codegen) produces a useful error.

**Files:**
- Create: `packages/desk_sdui_demo/test/misuse/<rule>_test.dart` × 7

- [ ] **Step 1: For each rule in Phase 3 Task 13, write a fixture + a test that runs the plugin on it and asserts the diagnostic surfaces**

Example:

```dart
// test/misuse/async_in_screen_test.dart
test('@Screen with await produces sdui_no_async_in_screen', () async {
  final source = '''
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:flutter/widgets.dart';

@Screen('bad')
Widget buildBad() async {
  await Future.delayed(Duration.zero);
  return Text('hi');
}
''';
  final diagnostics = await analyzeSource(source);
  expect(
    diagnostics.where((d) => d.code == 'sdui_no_async_in_screen'),
    isNotEmpty,
  );
});
```

`analyzeSource` is a small helper in `test/_helpers/analyze.dart` that runs the analyzer plugin against an in-memory source and returns diagnostics.

- [ ] **Step 2: One test per rule** — async, set_state, mutable_locals, function_definition, try_catch, counter_loop, unregistered_widget

- [ ] **Step 3: Commit**

```bash
git add packages/desk_sdui_demo/test/misuse
git commit -m "test(desk_sdui_demo): misuse test suite — every forbidden construct surfaces a useful error"
```

---

## Task 13: Perf benchmark

Validate spec criterion: "resolve cost <0.5ms per build for largest screen."

**Files:**
- Create: `packages/desk_sdui_demo/test/perf/resolve_benchmark_test.dart`

- [ ] **Step 1: Pick the largest of the 6 screens** (likely `home_scroll` or `chef`). Identify by IR node count after lowering.

- [ ] **Step 2: Write benchmark**

```dart
// test/perf/resolve_benchmark_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:desk_sdui/desk_sdui.dart';
import 'package:desk_sdui/src/resolve.dart';
import 'package:desk_sdui_demo/desk_sdui_setup.dart';
import 'package:desk_sdui_demo/data/fixtures.dart';

void main() {
  testWidgets('resolve cost is <0.5ms per build for largest screen', (tester) async {
    initSdui();
    final binding = sduiRuntime.screenFor('home_scroll')!;
    final input = <String, Object?>{'data': homeScrollFixture, 'controller': /* ... */ };

    // Warm up
    for (var i = 0; i < 100; i++) {
      await tester.pumpWidget(Builder(builder: (ctx) {
        return resolveNode(ctx, binding.ir.root, input, sduiRuntime);
      }));
    }

    // Measure
    final stopwatch = Stopwatch()..start();
    const iterations = 1000;
    for (var i = 0; i < iterations; i++) {
      await tester.pumpWidget(Builder(builder: (ctx) {
        return resolveNode(ctx, binding.ir.root, input, sduiRuntime);
      }));
    }
    stopwatch.stop();

    final perBuildUs = stopwatch.elapsedMicroseconds / iterations;
    print('resolve cost: ${perBuildUs.toStringAsFixed(1)}µs per build');
    expect(perBuildUs, lessThan(500),
        reason: 'spec target: <0.5ms (500µs) per build');
  });
}
```

- [ ] **Step 3: Run; log result; commit**

```bash
flutter test test/perf/resolve_benchmark_test.dart
git add packages/desk_sdui_demo/test/perf
git commit -m "test(desk_sdui_demo): resolve perf benchmark — <0.5ms/build target"
```

If the benchmark fails, the resolver needs profiling — surface as a separate fix commit on the runtime package. Don't paper over with a relaxed target.

---

## Task 14: 15-minute onboarding README

Spec criterion: "README walks a new dev from 'fresh checkout' to 'first `@Screen` authored' in 15 minutes."

**Files:**
- Create: `packages/desk_sdui/README.md` (top-level package README — the public-facing doc)
- Modify: top-level `README.md` (repo root) with project overview

- [ ] **Step 1: Outline**

```markdown
# desk_sdui

Server-driven UI for Flutter. Author screens as Dart, ship them as data.

## Quick start (15 minutes)

### 1. Install (1 min)
```yaml
dependencies:
  desk_sdui: ^0.0.1
  desk_sdui_annotation: ^0.0.1
dev_dependencies:
  desk_sdui_generator: ^0.0.1
  build_runner: ^2.15.0
```

### 2. Bootstrap (2 min)
… `desk_sdui_setup.dart` template …

### 3. Author your first screen (5 min)
… complete cart.dart example …

### 4. Generate (1 min)
… `dart run build_runner watch --force-aot` …

### 5. Mount (1 min)
… `SduiScreen` example …

### 6. Reactive state (5 min)
… ValueListenable example with a counter …

## How it works
… 3-phase diagram, IR shape, build vs frame rate …

## Subset boundaries
… what works, what doesn't, why …

## Authoring checklist
… per-screen mental model …
```

- [ ] **Step 2: Write each section against a real working example from `desk_sdui_demo`**

A new dev should be able to copy-paste the `cart.dart` example and have it compile and render.

- [ ] **Step 3: Time yourself doing the README from a fresh checkout**

Literally: `git clone`, follow README, see render. Aim for ≤15 minutes. If it takes longer, fix the README.

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui/README.md README.md
git commit -m "docs: 15-minute quick-start README"
```

---

## Task 15: Final v1 acceptance check

- [ ] **Step 1: Run the full suite**

```bash
melos exec -- flutter analyze
melos exec --dir-exists=test -- flutter test
```

Expected: zero analyzer issues, all tests pass.

- [ ] **Step 2: Tick the v1 success criteria from the spec**

Confirm against `docs/superpowers/specs/2026-05-10-desk-sdui-design.md`:

- [ ] All 6 named screens render identically to original Dart-only versions (golden parity)
- [ ] Edit-save-reload cycle <1.5s — measure once and record:
  ```bash
  cd packages/desk_sdui_demo
  time { sed -i.bak "s/'hi'/'updated'/" lib/screens/chef.dart && \
         dart run build_runner build --delete-conflicting-outputs ; \
         mv lib/screens/chef.dart.bak lib/screens/chef.dart ; }
  ```
- [ ] Misuse test suite confirms each forbidden construct produces a useful analyzer error
- [ ] Perf benchmark: resolve cost <0.5ms per build for largest screen
- [ ] README walks a new dev from "fresh checkout" to "first `@Screen` authored" in 15 minutes (timed)

- [ ] **Step 3: Tag**

```bash
git tag desk_sdui-v1
```

- [ ] **Step 4: PR (or merge to main if no review gate)**

```bash
git push origin main
git push --tags
```

## Phase 4 Done When

- [ ] `desk_sdui_demo` package builds clean with `dart run build_runner build`
- [ ] All 6 screens (`chef` + 5 home variants) ported to `@Screen`
- [ ] All 6 screens have parity tests with byte-identical goldens against vendored originals
- [ ] All 7 misuse tests surface the expected analyzer-plugin diagnostic
- [ ] Resolve perf benchmark passes (<0.5ms/build for largest screen)
- [ ] Edit-save-reload cycle measured at <1.5s
- [ ] Top-level + per-package READMEs let a new dev render their first `@Screen` in ≤15 minutes
- [ ] `desk_sdui-v1` tag created
- [ ] All v1 spec criteria from the spec ticked
