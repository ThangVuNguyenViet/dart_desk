# Reactive Effect-Based VM Communication

## Goal

Establish clear signal ownership between `CmsViewModel` and `CmsDocumentViewModel` using signals `effect()` for cross-VM communication. Each VM only writes to signals it owns.

## Signal Ownership

### CmsViewModel owns and writes:
- `selectedDocumentId` (Signal<int?>) — set during route changes, create, delete
- All existing signals: `currentDocumentTypeSlug`, `currentDocumentId`, `currentVersionId`, `selectedVersionId`, `searchQuery`, `isSaving`, `sidebarCollapsed`, `documentListVisible`
- All existing containers: `documentsContainer`, `versionsContainer`, `documentDataContainer`

### CmsDocumentViewModel owns and writes:
- `documentId` (Signal<int?>) — synced reactively from `selectedDocumentId`
- `editedData` (MapSignal<String, dynamic>) — reset on doc change, populated on auto-load
- All existing signals: `title`, `slug`, `isDefault`, `isSaving`, `selectedDocument`

## Reactive Wiring

`CmsDocumentViewModel.listenTo(CmsViewModel cmsVM)` sets up an effect:

```dart
_cleanup = effect(() {
  final newDocId = cmsVM.selectedDocumentId.value; // tracked
  final currentDocId = untracked(() => documentId.value); // untracked to avoid loop

  if (currentDocId != newDocId) {
    batch(() {
      documentId.value = newDocId;
      editedData.value = {};
    });

    // Auto-load latest version data (async, fire-and-forget)
    if (newDocId != null) {
      _autoLoadLatestData(cmsVM, newDocId);
    }
  }
});
```

## Changes to CmsViewModel

- **Remove:** `_documentId` and `_editedData` constructor params and fields
- **Add:** `selectedDocumentId = Signal<int?>(null, debugLabel: 'selectedDocumentId')`
- **`setRouteParams`:** Write to `selectedDocumentId.value` instead of `_documentId.value`. Remove direct writes to `_editedData`. Remove the `_autoSelectLatestVersion` call (moved to CmsDocumentViewModel).
- **`createDocument`:** Write to `selectedDocumentId.value` instead of `_documentId.value`
- **`deleteDocument`:** Compare/write `selectedDocumentId.value` instead of `_documentId.value`
- **Read-only methods** (`updateDocumentData`, `publishVersion`, `archiveVersion`, `deleteVersion`, `refreshVersions`): Read `selectedDocumentId.value` instead of `_documentId.value`
- **Remove:** `_autoSelectLatestVersion` method (moves to CmsDocumentViewModel)
- **Add:** `selectedDocumentId` to `dispose()`

## Changes to CmsDocumentViewModel

- **Add:** `EffectCleanup? _cleanup` field
- **Add:** `listenTo(CmsViewModel cmsVM)` method containing the effect
- **Add:** `_autoLoadLatestData(CmsViewModel cmsVM, int docId)` async method — moved from `CmsViewModel._autoSelectLatestVersion`. Fetches versions, gets active version data, writes to `editedData`. Also sets `cmsVM.selectedVersionId.value` (the only cross-write, justified because version selection is a route-level concern triggered by document loading).
- **Update `dispose()`:** Call `_cleanup?.call()`

## StudioProvider Wiring

```dart
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

No more signal passing in CmsViewModel constructor.

## Consumer Impact

Zero consumer changes. Consumers that read `GetIt.I<CmsDocumentViewModel>().documentId` or `.editedData` continue working — the signals are the same objects, just written by a different code path.

## Files Modified

1. `packages/dart_desk/lib/src/studio/core/view_models/cms_view_model.dart` — remove signal params, add `selectedDocumentId`, move `_autoSelectLatestVersion` out, update all write/read sites
2. `packages/dart_desk/lib/src/studio/core/view_models/cms_document_view_model.dart` — add `listenTo()`, `_autoLoadLatestData()`, `_cleanup` field
3. `packages/dart_desk/lib/src/studio/providers/studio_provider.dart` — simplify constructor call, add `docVM.listenTo(cmsVM)`
