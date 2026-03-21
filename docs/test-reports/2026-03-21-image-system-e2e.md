# E2E Test Report — Image System (Task 16)

**Date:** 2026-03-21
**Platform:** macOS (debug mode)
**App:** `examples/cms_app/lib/main_test.dart` with `MockCmsDataSource`
**Tools:** Marionette MCP + Dart MCP

---

## Code Changes

| File | Change |
|---|---|
| `packages/dart_desk/lib/src/studio/components/forms/cms_form.dart` | Pass `dataSource` from `cmsViewModelProvider` to `CmsImageInput` (fixes "No data source configured" on upload/browse buttons) |
| `packages/dart_desk/lib/src/studio/routes/media_route.dart` | Wire `MediaBrowser(standalone)` into `MediaRoute.build()` (was `SizedBox.shrink()`) |
| `packages/dart_desk/lib/src/media/browser/media_browser.dart` | Fix `ShadButtonSize.icon` → `ShadButtonSize.sm` (enum value doesn't exist in shadcn_ui 0.52.1) |
| `packages/dart_desk/lib/src/media/browser/media_toolbar.dart` | Fix `ShadButtonSize.icon` → `ShadButtonSize.sm` |
| `examples/cms_app/lib/main_test.dart` | Add `scrollByKey` custom Marionette extension for scrolling `CustomScrollView` forms |
| `examples/cms_app/pubspec.yaml` | Fix worktree-relative paths + add `dependency_overrides` for worktree resolution |

### External (outside worktree)

| File | Change |
|---|---|
| `dart_desk_be_client/.../cloud_data_source.dart` | Reverted by user — will be updated separately when backend catches up |

---

## Test Results

| # | Test Case | Result | Details |
|---|---|---|---|
| 1 | `flutter analyze` | PASS | Clean — no errors on `packages/dart_desk` |
| 2 | App launch (macOS) | PASS | Builds and runs with `MockCmsDataSource` + `allFieldsDocumentType` |
| 3 | Document list renders | PASS | 3 test documents visible: Alpha, Beta, Gamma |
| 4 | Navigate to document | PASS | Tapping "Test Document Beta" loads form; breadcrumb updates to "Document" |
| 5 | Form fields render | PASS | String, Text, Number, Boolean, Checkbox fields visible with Beta's data |
| 6 | Scroll to image field | PASS | Custom `scrollByKey` extension scrolls form to image input (progressive scroll needed for slivers) |
| 7 | Image field empty state | PASS | Drop zone with "Drop image or click to upload" text, upload arrow icon |
| 8 | Upload button enabled | PASS | `dataSource` fix confirmed — button is active (not "No data source configured") |
| 9 | Browse media button enabled | PASS | `dataSource` fix confirmed — button is active |
| 10 | Edit crop button hidden | PASS | Correctly hidden when no image is loaded (`hotspotEnabled && hasImage` is false) |
| 11 | Remove button hidden | PASS | Correctly hidden when no image is loaded |
| 12 | Browse media dialog opens | PASS | Tapping "Browse media" dims the screen (dialog overlay appears) |
| 13 | Browse media dialog interaction | BLOCKED | Marionette returns 0 interactive elements inside `ShadDialog` overlay — cannot interact with media browser picker. See Known Issues below. |
| 14 | Upload flow | NOT TESTABLE | `ImagePicker.pickImage()` opens native OS file dialog — not automatable via Marionette |
| 15 | Hotspot editor | NOT TESTABLE | Requires loaded `ImageReference`; seed data uses plain URL strings, not `ImageReference` JSON |
| 16 | Media route (`/media`) standalone | CODE DONE | `MediaBrowser` wired into `MediaRoute.build()` — not navigated to in E2E (requires coordinator navigation API) |

---

## Known Issues & Gaps

### 1. ShadDialog overlay not traversable by Marionette

**Symptom:** `get_interactive_elements` returns 0 elements when a `ShadDialog` is open.

**Root cause:** Not a Marionette bug. Marionette's tree traversal starts from `rootElement` and should reach overlay entries. The issue is likely in `shouldStopTraversal` or `_isBuiltInStopWidget` cutting off traversal before reaching dialog content. Our `CmsMarionetteConfig` registers `ShadButton` etc. as interactive, but the traversal path through the dialog's widget subtree may be blocked.

**No GitHub issue filed** for this specific symptom. Related: Issue #44 (fixed in 0.4.0) addressed tapping behind modal barriers.

**Fix needed:** Debug the specific traversal path for `ShadDialog` content in `CmsMarionetteConfig`.

### 2. Marionette `scroll_to` fails with CustomScrollView/SliverList

**Symptom:** `scroll_to` by key or text returns "Server error" for off-screen widgets in sliver-based scroll views.

**Root cause:** `CustomScrollView` can have infinite `maxScrollExtent` (Flutter only knows extents of rendered slivers). Marionette falls back to 50 attempts × 64px = 3,200px max scroll. Also, the target widget may not exist in the element tree until its sliver is built.

**No GitHub issue filed.**

**Workaround:** Custom Marionette extension using `Scrollable.ensureVisible()` with progressive scrolling (scroll to intermediate widgets first to force slivers to build, then scroll to the target).

### 3. Native image picker not automatable

`ImagePicker.pickImage()` opens the OS file dialog, which is outside Flutter's widget tree. Cannot be tested via Marionette.

### 4. Seed data format mismatch

Test documents in `MockCmsDataSource` store plain URL strings for `image_field` (e.g. `'https://picsum.photos/200'`), not `ImageReference` JSON. The `CmsImageInput._initFromData` doesn't hydrate from plain strings, so existing documents show empty image state.

### 5. Mock starts with no media assets

`MockCmsDataSource` has no pre-seeded `MediaAsset` items, so the media browser picker would show "No media found" even if the dialog were interactable.

---

## Marionette Test Infrastructure

### Custom Extension: `scrollByKey`

Registered in `main_test.dart` via `registerMarionetteExtension` (public API since Marionette 0.4.0). Uses `Scrollable.ensureVisible()` to programmatically scroll `CustomScrollView` forms. Required because Marionette's built-in `scroll_to` doesn't handle infinite-extent slivers.

Usage via MCP:
```
call_custom_extension(extension: "scrollByKey", args: {"key": "image_input_image_field"})
```

**Note:** For off-screen sliver widgets, progressive scrolling is needed — scroll to intermediate widgets first (e.g. `checkbox_field` → `image_input_image_field`) to force Flutter to build intervening slivers.
