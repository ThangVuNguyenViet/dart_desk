# Reactive VM Communication Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish clear signal ownership between CmsViewModel and CmsDocumentViewModel using signals `effect()` for cross-VM reactive communication.

**Architecture:** CmsViewModel owns `selectedDocumentId` and only writes to it. CmsDocumentViewModel listens via `effect()` and reacts by updating its own `documentId`/`editedData` signals and auto-loading version data. No VM directly mutates another VM's signals.

**Tech Stack:** Flutter, signals, get_it

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `packages/dart_desk/lib/src/studio/core/view_models/cms_view_model.dart` | Modify | Remove signal params, add `selectedDocumentId`, move `_autoSelectLatestVersion` out, update all read/write sites |
| `packages/dart_desk/lib/src/studio/core/view_models/cms_document_view_model.dart` | Modify | Add `listenTo()`, `_autoLoadLatestData()`, `_cleanup` field |
| `packages/dart_desk/lib/src/studio/providers/studio_provider.dart` | Modify | Simplify constructor, wire `docVM.listenTo(cmsVM)` |

---

### Task 1: Update CmsViewModel — remove signal params, add selectedDocumentId

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/core/view_models/cms_view_model.dart`

- [ ] **Step 1: Remove `_documentId` and `_editedData` fields and constructor params, add `selectedDocumentId`**

Replace the fields and constructor:

```dart
// Remove these two fields:
final Signal<int?> _documentId;
final MapSignal<String, dynamic> _editedData;

// Remove constructor params:
CmsViewModel({
  required this.dataSource,
  required Signal<int?> documentId,
  required MapSignal<String, dynamic> editedData,
  required this.documentTypes,
})  : _documentId = documentId,
      _editedData = editedData;

// Replace with:
final selectedDocumentId = Signal<int?>(null, debugLabel: 'selectedDocumentId');

CmsViewModel({
  required this.dataSource,
  required this.documentTypes,
});
```

- [ ] **Step 2: Update `setRouteParams` — write to `selectedDocumentId`, remove `_editedData` writes and `_autoSelectLatestVersion` call**

Replace the current `setRouteParams` method with:

```dart
void setRouteParams({
  String? documentTypeSlug,
  String? documentId,
  String? versionId,
}) {
  currentDocumentTypeSlug.value = documentTypeSlug;

  final docIdInt = documentId != null ? int.tryParse(documentId) : null;
  selectedDocumentId.value = docIdInt;
  currentDocumentId.value = documentId;

  // Update version ID
  currentVersionId.value = versionId;

  final versionIdInt = versionId != null ? int.tryParse(versionId) : null;
  selectedVersionId.value = versionIdInt;
}
```

- [ ] **Step 3: Update `createDocument` — write to `selectedDocumentId` instead of `_documentId`**

Change line 219 from:
```dart
_documentId.value = document.id;
```
to:
```dart
selectedDocumentId.value = document.id;
```

- [ ] **Step 4: Update `deleteDocument` — use `selectedDocumentId` instead of `_documentId`**

Change the method body from:
```dart
if (_documentId.value == documentId) {
  _documentId.value = null;
  selectedVersionId.value = null;
}
```
to:
```dart
if (selectedDocumentId.value == documentId) {
  selectedDocumentId.value = null;
  selectedVersionId.value = null;
}
```

- [ ] **Step 5: Update read-only methods — replace `_documentId` with `selectedDocumentId`**

In `updateDocumentData`, change:
```dart
final documentId = _documentId.value;
```
to:
```dart
final documentId = selectedDocumentId.value;
```

In `publishVersion`, `archiveVersion`, `deleteVersion`, change all occurrences of:
```dart
final docId = _documentId.value;
```
to:
```dart
final docId = selectedDocumentId.value;
```

In `refreshVersions`, change:
```dart
final docId = _documentId.value;
```
to:
```dart
final docId = selectedDocumentId.value;
```

- [ ] **Step 6: Remove `_autoSelectLatestVersion` method entirely**

Delete the entire method (lines 160-186 in current file). This logic moves to `CmsDocumentViewModel`.

- [ ] **Step 7: Add `selectedDocumentId` to `dispose()`**

Add `selectedDocumentId.dispose();` to the dispose method, after `selectedVersionId.dispose();`.

- [ ] **Step 8: Verify compilation**

```bash
cd packages/dart_desk && dart analyze lib/src/studio/core/view_models/cms_view_model.dart
```

Expected: No errors (StudioProvider will have errors until Task 3, but this file should be clean).

- [ ] **Step 9: Commit**

```bash
git add packages/dart_desk/lib/src/studio/core/view_models/cms_view_model.dart
git commit -m "refactor: CmsViewModel owns selectedDocumentId, remove signal params"
```

---

### Task 2: Update CmsDocumentViewModel — add listenTo() and _autoLoadLatestData()

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/core/view_models/cms_document_view_model.dart`

- [ ] **Step 1: Add import for CmsViewModel and document_version model**

Add these imports at the top of the file:

```dart
import '../../../data/models/document_version.dart';
import 'cms_view_model.dart';
```

- [ ] **Step 2: Add `_cleanup` field**

Add after the `editedData` field:

```dart
EffectCleanup? _cleanup;
```

- [ ] **Step 3: Add `listenTo` method**

Add after the constructor:

```dart
/// Sets up a reactive effect that watches [cmsVM.selectedDocumentId].
/// When it changes, syncs [documentId], resets [editedData], and
/// auto-loads the latest version data.
void listenTo(CmsViewModel cmsVM) {
  _cleanup = effect(() {
    final newDocId = cmsVM.selectedDocumentId.value;
    final currentDocId = untracked(() => documentId.value);

    if (currentDocId != newDocId) {
      batch(() {
        documentId.value = newDocId;
        editedData.value = {};
      });

      if (newDocId != null) {
        _autoLoadLatestData(cmsVM, newDocId);
      }
    }
  });
}
```

- [ ] **Step 4: Add `_autoLoadLatestData` method**

Add after `listenTo`:

```dart
/// Fetches versions for a document and auto-loads the latest data.
/// Sets [editedData] from the document's active version data and
/// updates [cmsVM.selectedVersionId].
Future<void> _autoLoadLatestData(CmsViewModel cmsVM, int docId) async {
  try {
    final versions = await dataSource.getDocumentVersions(docId);
    if (versions.versions.isNotEmpty) {
      final versionId = versions.versions.first.id!;

      // Use the document's activeVersionData which reflects the latest
      // CRDT-merged state, rather than getDocumentVersionData which only
      // reconstructs state up to the version's snapshot HLC.
      final doc = await dataSource.getDocument(docId);
      final docData = doc?.activeVersionData;
      if (docData != null && docData.isNotEmpty) {
        editedData.value = Map<String, dynamic>.from(docData);
      }

      // Set version ID after editedData so the editor's early-return
      // path (editedData.isNotEmpty) prevents the loading→form transition.
      cmsVM.selectedVersionId.value = versionId;
    }
  } catch (_) {
    // Silently ignore — editor will show empty state
  }
}
```

- [ ] **Step 5: Update `dispose` to clean up the effect**

Change dispose from:
```dart
void dispose() {
  documentId.dispose();
```
to:
```dart
void dispose() {
  _cleanup?.call();
  documentId.dispose();
```

- [ ] **Step 6: Verify compilation**

```bash
cd packages/dart_desk && dart analyze lib/src/studio/core/view_models/cms_document_view_model.dart
```

Expected: No errors.

- [ ] **Step 7: Commit**

```bash
git add packages/dart_desk/lib/src/studio/core/view_models/cms_document_view_model.dart
git commit -m "feat: CmsDocumentViewModel.listenTo() with reactive effect"
```

---

### Task 3: Update StudioProvider — simplify wiring

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/providers/studio_provider.dart`

- [ ] **Step 1: Simplify initState — remove signal params, add listenTo call**

Replace the current `initState` body with:

```dart
@override
void initState() {
  super.initState();
  final docVM = CmsDocumentViewModel(widget.dataSource);
  final cmsVM = CmsViewModel(
    dataSource: widget.dataSource,
    documentTypes: widget.documentTypes,
  );
  GetIt.I.registerSingleton<CmsDocumentViewModel>(docVM);
  GetIt.I.registerSingleton<CmsViewModel>(cmsVM);
  docVM.listenTo(cmsVM);
}
```

- [ ] **Step 2: Verify full compilation**

```bash
cd packages/dart_desk && dart analyze
```

Expected: No errors (warnings about unused variables in tests are OK).

- [ ] **Step 3: Run tests**

```bash
cd packages/dart_desk && flutter test
```

Expected: All 147 tests pass.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk/lib/src/studio/providers/studio_provider.dart
git commit -m "refactor: wire reactive VM communication in StudioProvider"
```

---

### Task 4: Final verification

- [ ] **Step 1: Verify no direct cross-VM signal writes remain**

```bash
cd packages/dart_desk && grep -rn "_documentId\|_editedData" lib/src/studio/core/view_models/cms_view_model.dart
```

Expected: No matches — CmsViewModel no longer references these fields.

- [ ] **Step 2: Verify CmsViewModel has no dependency on CmsDocumentViewModel**

```bash
cd packages/dart_desk && grep -n "cms_document_view_model\|CmsDocumentViewModel" lib/src/studio/core/view_models/cms_view_model.dart
```

Expected: No matches.

- [ ] **Step 3: Run full test suite**

```bash
cd packages/dart_desk && flutter test
```

Expected: All tests pass.
