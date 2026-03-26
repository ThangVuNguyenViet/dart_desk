# Disco to get_it Migration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the `disco` dependency injection package with `get_it: ^9.2.1` as a pure service locator.

**Architecture:** Two view models (`CmsDocumentViewModel`, `CmsViewModel`) are registered as singletons in `GetIt.I` by the `StudioProvider` widget. All consumer files replace `xxxProvider.of(context)` with `GetIt.I<T>()`.

**Tech Stack:** Flutter, get_it ^9.2.1

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `packages/dart_desk/pubspec.yaml` | Modify | Swap disco for get_it |
| `packages/dart_desk/lib/src/studio/providers/studio_provider.dart` | Rewrite | GetIt registration/unregistration |
| `packages/dart_desk/lib/src/studio/routes/studio_layout.dart` | Modify | Replace provider access (3 sites) |
| `packages/dart_desk/lib/src/studio/screens/document_editor.dart` | Modify | Replace provider access (7 sites) |
| `packages/dart_desk/lib/src/studio/screens/document_list.dart` | Modify | Replace provider access (6 sites) |
| `packages/dart_desk/lib/src/studio/screens/cms_studio.dart` | Modify | Replace provider access (4 sites) |
| `packages/dart_desk/lib/src/studio/components/version/cms_version_history.dart` | Modify | Replace provider access (1 site) |
| `packages/dart_desk/lib/src/studio/components/navigation/cms_document_type_sidebar.dart` | Modify | Replace provider access (1 site) |
| `packages/dart_desk/lib/src/studio/components/forms/cms_form.dart` | Modify | Replace provider access (1 site) |
| `packages/dart_desk/lib/src/testing/test_document_types.dart` | Modify | Replace provider access (2 sites) |
| `packages/dart_desk/test/studio/editor_preview_widget_test.dart` | Modify | Replace provider access (8 sites) |
| `packages/dart_desk/test/studio/context_aware_dropdown_test.dart` | Modify | Replace provider access (11 sites) |

---

### Task 1: Swap dependency and rewrite StudioProvider

**Files:**
- Modify: `packages/dart_desk/pubspec.yaml:34`
- Rewrite: `packages/dart_desk/lib/src/studio/providers/studio_provider.dart`

- [ ] **Step 1: Update pubspec.yaml**

In `packages/dart_desk/pubspec.yaml`, replace line 34:

```yaml
# Remove:
  disco: ^1.0.3+1
# Add:
  get_it: ^9.2.1
```

- [ ] **Step 2: Run pub get**

```bash
cd packages/dart_desk && dart pub get
```

Expected: resolves successfully, `get_it` appears in `pubspec.lock`.

- [ ] **Step 3: Rewrite studio_provider.dart**

Replace entire contents of `packages/dart_desk/lib/src/studio/providers/studio_provider.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../dart_desk.dart';
import '../../../studio.dart';
import '../core/view_models/cms_document_view_model.dart';

class StudioProvider extends StatefulWidget {
  const StudioProvider({
    super.key,
    required this.child,
    required this.dataSource,
    required this.documentTypes,
  });

  final Widget child;
  final DataSource dataSource;
  final List<DocumentType> documentTypes;

  @override
  State<StudioProvider> createState() => _StudioProviderState();
}

class _StudioProviderState extends State<StudioProvider> {
  @override
  void initState() {
    super.initState();
    final docVM = CmsDocumentViewModel(widget.dataSource);
    GetIt.I.registerSingleton<CmsDocumentViewModel>(docVM);
    GetIt.I.registerSingleton<CmsViewModel>(
      CmsViewModel(
        dataSource: widget.dataSource,
        documentTypes: widget.documentTypes,
        documentViewModel: docVM,
      ),
    );
  }

  @override
  void dispose() {
    GetIt.I.unregister<CmsViewModel>();
    GetIt.I.unregister<CmsDocumentViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
```

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk/pubspec.yaml packages/dart_desk/pubspec.lock packages/dart_desk/lib/src/studio/providers/studio_provider.dart
git commit -m "refactor: replace disco with get_it in StudioProvider"
```

---

### Task 2: Migrate consumer files (lib)

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/routes/studio_layout.dart`
- Modify: `packages/dart_desk/lib/src/studio/screens/document_editor.dart`
- Modify: `packages/dart_desk/lib/src/studio/screens/document_list.dart`
- Modify: `packages/dart_desk/lib/src/studio/screens/cms_studio.dart`
- Modify: `packages/dart_desk/lib/src/studio/components/version/cms_version_history.dart`
- Modify: `packages/dart_desk/lib/src/studio/components/navigation/cms_document_type_sidebar.dart`
- Modify: `packages/dart_desk/lib/src/studio/components/forms/cms_form.dart`
- Modify: `packages/dart_desk/lib/src/testing/test_document_types.dart`

For each file, apply these two changes:

**Import change:** Replace:
```dart
import '../providers/studio_provider.dart';
// (or the relative variant for each file)
```
with:
```dart
import 'package:get_it/get_it.dart';
import 'package:dart_desk/src/studio/core/view_models/cms_view_model.dart';
import 'package:dart_desk/src/studio/core/view_models/cms_document_view_model.dart';
```

Note: Some files may already import `CmsViewModel`/`CmsDocumentViewModel` via barrel exports (`studio.dart`, `dart_desk.dart`). In that case, only add the `get_it` import and remove the `studio_provider` import. Check each file's existing imports to see if the VM types are already in scope.

**Access pattern change:** In every file, apply these mechanical replacements:
- `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- `documentViewModelProvider.of(context)` → `GetIt.I<CmsDocumentViewModel>()`

Here are the exact sites per file:

**studio_layout.dart** (import on line 9):
- Line 84: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- Line 118: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- Line 146: `documentViewModelProvider.of(context)` → `GetIt.I<CmsDocumentViewModel>()`

**document_editor.dart** (import on line 9):
- Line 26: `documentViewModelProvider.of(context).editedData` → `GetIt.I<CmsDocumentViewModel>().editedData`
- Line 30: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- Line 40: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- Line 42: `documentViewModelProvider.of(context)` → `GetIt.I<CmsDocumentViewModel>()`
- Line 51: `documentViewModelProvider.of(context)` → `GetIt.I<CmsDocumentViewModel>()`
- Line 86: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- Line 120: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`

**document_list.dart** (import on line 15):
- Line 63: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- Line 126: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- Line 235: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- Line 244: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- Line 245: `documentViewModelProvider.of(context)` → `GetIt.I<CmsDocumentViewModel>()`
- Line 379: `documentViewModelProvider.of(context)` → `GetIt.I<CmsDocumentViewModel>()`

**cms_studio.dart** (import on line 10):
- Line 34: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- Line 35: `documentViewModelProvider.of(context)` → `GetIt.I<CmsDocumentViewModel>()`
- Line 138: `documentViewModelProvider.of(context)` → `GetIt.I<CmsDocumentViewModel>()`
- Line 236: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`

**cms_version_history.dart** (import on line 8):
- Line 58: `documentViewModelProvider.of(context)` → `GetIt.I<CmsDocumentViewModel>()`

**cms_document_type_sidebar.dart** (import on line 5):
- Line 34: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`

**cms_form.dart** (import on line 18):
- Line 221: `cmsViewModelProvider.of(context).dataSource` → `GetIt.I<CmsViewModel>().dataSource`

**test_document_types.dart** (import on line 5):
- Line 179: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- Line 248: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`

- [ ] **Step 1: Migrate all 8 consumer files**

Apply the import and access pattern changes described above to all 8 files.

- [ ] **Step 2: Verify compilation**

```bash
cd packages/dart_desk && dart analyze lib/
```

Expected: No errors related to disco, provider access, or missing imports.

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/lib/
git commit -m "refactor: migrate consumer files from disco to get_it"
```

---

### Task 3: Migrate test files

**Files:**
- Modify: `packages/dart_desk/test/studio/editor_preview_widget_test.dart`
- Modify: `packages/dart_desk/test/studio/context_aware_dropdown_test.dart`

Same pattern — replace import and access sites.

**editor_preview_widget_test.dart** (import on line 4):

Replace import:
```dart
// Remove:
import 'package:dart_desk/src/studio/providers/studio_provider.dart';
// Add:
import 'package:get_it/get_it.dart';
import 'package:dart_desk/src/studio/core/view_models/cms_view_model.dart';
import 'package:dart_desk/src/studio/core/view_models/cms_document_view_model.dart';
```

Access sites:
- Line 26: `documentViewModelProvider.of(context).editedData.watch(context)` → `GetIt.I<CmsDocumentViewModel>().editedData.watch(context)`
- Line 46: `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`
- Line 51: `documentViewModelProvider.of(context)` → `GetIt.I<CmsDocumentViewModel>()`
- Line 89: `cmsViewModelProvider.of(context).currentDocumentTypeSlug.value =` → `GetIt.I<CmsViewModel>().currentDocumentTypeSlug.value =`
- Line 253: `documentViewModelProvider.of(context).editedData` → `GetIt.I<CmsDocumentViewModel>().editedData`
- Line 275: `documentViewModelProvider.of(context).editedData` → `GetIt.I<CmsDocumentViewModel>().editedData`
- Line 297: `documentViewModelProvider.of(context).editedData` → `GetIt.I<CmsDocumentViewModel>().editedData`
- Line 423: `documentViewModelProvider.of(context).editedData` → `GetIt.I<CmsDocumentViewModel>().editedData`
- Line 481: `documentViewModelProvider.of(context).editedData` → `GetIt.I<CmsDocumentViewModel>().editedData`

**context_aware_dropdown_test.dart** (import on line 3):

Replace import:
```dart
// Remove:
import 'package:dart_desk/src/studio/providers/studio_provider.dart';
// Add:
import 'package:get_it/get_it.dart';
import 'package:dart_desk/src/studio/core/view_models/cms_view_model.dart';
```

Access sites (all `cmsViewModelProvider.of(context)` → `GetIt.I<CmsViewModel>()`):
- Lines: 27, 212, 261, 292, 327, 361, 397, 432, 469, 493, 529

- [ ] **Step 1: Migrate both test files**

Apply the import and access pattern changes described above.

- [ ] **Step 2: Verify compilation**

```bash
cd packages/dart_desk && dart analyze test/
```

Expected: No errors.

- [ ] **Step 3: Run tests**

```bash
cd packages/dart_desk && flutter test test/studio/
```

Expected: All tests pass. Note: tests that use `StudioProvider` as a wrapper widget will still register into GetIt via `initState`, so they should work without changes to test setup. However, if tests run in parallel and share a global GetIt, there may be "already registered" errors. If so, add `GetIt.I.reset()` in `setUp`/`tearDown` of each test group.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk/test/
git commit -m "refactor: migrate test files from disco to get_it"
```

---

### Task 4: Cleanup and final verification

- [ ] **Step 1: Verify disco is fully removed**

```bash
cd packages/dart_desk && grep -r "disco" lib/ test/ pubspec.yaml
```

Expected: No matches.

- [ ] **Step 2: Run full analysis**

```bash
cd packages/dart_desk && dart analyze
```

Expected: No errors.

- [ ] **Step 3: Run full test suite**

```bash
cd packages/dart_desk && flutter test
```

Expected: All tests pass.

- [ ] **Step 4: Final commit (if any cleanup needed)**

Only commit if prior steps revealed issues that needed fixing.
