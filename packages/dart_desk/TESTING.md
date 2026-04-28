# Testing dart_desk

Four test layers, one responsibility each. Pick the right one for what you're
asserting; mixing layers is a smell.

## The four layers

| Layer | Where | What it tests | Boots app? | Data path |
|---|---|---|---|---|
| Component widget | `packages/dart_desk/test/` | Behavior, callbacks, state, async | No | Direct `tester.pumpWidget`, fixtures as data |
| Widget golden | `packages/dart_desk/test/` | Visual rendering of every widget × fixture variant — the visual catalog | No | Direct `tester.pumpWidget` |
| Screen golden | `examples/desk_app/test/screens/` | Visual rendering of curated canonical screens — capped at ~10 | Yes (`buildDeskApp`) | `MockDataSource()..seedFixtures(...)` |
| Real-stack integration | `packages/dart_desk/integration_test/` and `examples/example_app/integration_test/` | Wire format, persistence, file uploads, public endpoints | Yes (`buildDeskApp` / `buildExampleApp`) | Real `CloudDataSource` / `CloudPublicContentSource` against a local Serverpod |

## Discipline rules

Use the layer that matches what you're checking:

- Asserting **behavior** (callbacks, state, navigation, async timing) → widget test
- Asserting **appearance** (layout, colors, spacing, presence) → golden
- Asserting **real-stack correctness** (persistence, wire format, uploads) → integration test

### Smells

These mean you picked the wrong layer:

- `matchesGoldenFile` inside an integration test → the visual question belongs in a golden
- `find.byKey(...)` semantic assertions inside a golden → the behavior belongs in a widget test
- Pumping the full app inside a component widget test → you don't need the bootstrap; test the widget directly

Integration tests assert *semantic* outcomes (`find.byKey`, DB row presence, network payloads), never visual rendering.

### The screen-golden cap

Screen-level goldens are capped at **~10**. Adding a new visual edge case goes
to a widget golden, not a new screen. Screens are for *canonical* compositions
— the document editor with `allFieldsPopulated`, the document list with N docs,
the empty studio, the validation-error state, login. New variants of an
existing widget belong in that widget's gallery.

If you find yourself wanting an 11th screen, ask whether the question is really
about a single widget. Usually it is.

## Fixtures

`examples/data_models/lib/src/fixtures/` exposes `*Fixtures` classes — one per
document type. Every fixture is a named factory:

```dart
KioskProductFixtures.showcase();              // demo-quality, used by showcase apps + happy-path tests
KioskProductFixtures.empty();                 // all required fields at minimum
KioskProductFixtures.allFieldsPopulated();    // every optional field set
KioskProductFixtures.longStrings();           // 500-char title, 5000-char description
KioskProductFixtures.withValidationError();   // breaks a required field
```

**One source of truth for both purposes.** The showcase apps consume
`.showcase()`. Tests consume any variant, including `.showcase()` for
happy-path coverage. There is no parallel "test dataset."

If a widget test needs data the fixtures don't expose, add the variant to the
fixture class — don't construct an ad-hoc instance inline. That keeps fixtures
discoverable.

`examples/data_models/README.md` carries the feature-coverage checklist —
every dart_desk input × at least one fixture field exercising it.

## Goldens

We use [`flutter_test_goldens`](https://pub.dev/packages/flutter_test_goldens):
Gallery API for "widget × variants" stories, plus animation and interaction
timelines for transitions and hover/tap states.

### Real fonts

Goldens render with dart_desk's actual fonts, not Ahem. The visual catalog
must reflect the real product.

- TTFs ship with the package — `lib/fonts/` is declared in `pubspec.yaml`'s
  `flutter: fonts:` block, so consumers get them at runtime
- `test/flutter_test_config.dart` walks `lib/fonts/` and registers each face
  via `FontLoader` before any golden test runs (Flutter's test runner does
  not auto-load `pubspec.yaml fonts:` declarations)
- Filename convention is `Family-Variant.ttf` — the parser handles
  acronyms (`DMSans-Variable.ttf` → `"DM Sans"`)

### Pixel-diff tolerance

flutter_test_goldens's default tolerance absorbs imperceptible anti-aliasing
noise. Don't tune per-test.

### Platform pinning

Generate goldens on **Linux only**. macOS and Windows render fonts slightly
differently; multi-platform goldens would mean per-platform directories.
CI runs on Linux. Locally, regenerate via Docker (see below).

### `.gitattributes`

Golden PNGs are marked binary so git doesn't try to diff them.

### Failure diffs

When a golden test fails, flutter_test_goldens writes a diff PNG into a
`failures/` subdirectory next to the golden. These are throwaways —
`.gitignore` excludes `**/goldens/failures/`.

## Regenerating goldens locally

Use the Docker script so your local pixels match CI's pixels:

```sh
cd packages/dart_desk
./scripts/regenerate-goldens.sh
```

The script runs `flutter test --update-goldens` inside a Linux container with
the same Flutter version CI uses. Without it, you'd have to push to CI, fetch
the diff images from a failed run, and commit those — possible but slow.

## Running the suites

```sh
# Component widget + widget goldens
cd packages/dart_desk && flutter test

# Screen goldens
cd examples/desk_app && flutter test test/screens/

# Real-stack integration (requires a local Serverpod backend on :8080)
cd packages/dart_desk && flutter test integration_test/
cd examples/example_app && flutter test integration_test/
```

Integration tests pass `TEST_SERVER_URL`, `TEST_API_KEY`, `TEST_EMAIL`,
`TEST_PASSWORD` via `--dart-define`; defaults assume `localhost:8080` with the
e2e seed user.

## Mock channels for native plugins

`super_drag_and_drop` and `image_picker` initialize platform channels at
mount time, which fail in `flutter_test`. The helpers in
`test/helpers/input_test_helpers.dart` install no-op stubs:

- `installSuperDragAndDropMocks()` — register before any pumps that mount
  drop targets (e.g. `DeskImageInput`)
- `FakeImagePickerPlatform.install()` and `FakeFilePickerPlatform.install()`
  — exposed from `package:dart_desk/testing.dart` for integration tests

## Adding a new test

A quick decision tree:

1. Is the question "did this widget call its callback / change state / route correctly"?
   → component widget test in `test/`
2. Is the question "does this widget look right when given fixture variant X"?
   → widget golden in `test/`, add a variant to the existing gallery
3. Is the question "does the document editor with allFieldsPopulated render correctly"?
   → screen golden in `examples/desk_app/test/screens/` — but check the cap first
4. Is the question "does saving this field actually persist to the backend"?
   → integration test in `integration_test/`

When in doubt, the cheapest answer wins. A widget test runs in milliseconds,
a golden in seconds, an integration test in tens of seconds.
