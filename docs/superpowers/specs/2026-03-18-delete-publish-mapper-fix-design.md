# Delete Document UI, Publish Version UI, and MapperException Fix

## Overview

Three changes to the Flutter CMS studio:
1. Add "Delete document" action via a toolbar kebab menu
2. Add "Publish" / "Archive" actions per version in the version history panel
3. Fix `MapperException` on `featuredItems` field deserialization

---

## 1. Delete Document — Toolbar Kebab Menu

### Location

`packages/flutter_cms/lib/src/studio/components/common/cms_toolbar_ribbon.dart`

### Design

Add a kebab menu button (⋮) to the **right side** of `CmsToolbarRibbon`, after the existing Save button.

**Menu contents:**
- "Delete document" — destructive style (red text)

**Flow:**
1. User taps ⋮ → `ShadPopover` or dropdown appears
2. User taps "Delete document"
3. `ShadDialog` confirmation appears: title "Delete document", body "This will permanently delete this document and all its versions. This cannot be undone.", actions: Cancel (outline) / Delete (destructive)
4. On confirm → call `viewModel.deleteDocument(docId)` (already exists in `CmsViewModel`, line ~264)
5. On success → navigate back to document list (clear `documentId` signal — already done by `deleteDocument()`)
6. On failure → show destructive `ShadToast` with error message

### Interface Change

`CmsToolbarRibbon` currently accepts `onSave` and `onDiscard` callbacks. Add:
- `onDelete` callback (or pass the full action handler from the parent)

The parent (`CmsStudio` or `CmsDocumentEditor`) wires this to the view model's `deleteDocument()`.

### Confirmation Dialog Pattern

Use the existing `showShadDialog<bool>` pattern (same as `datetime_input.dart`):

```dart
final confirmed = await showShadDialog<bool>(
  context: context,
  builder: (context) => ShadDialog(
    title: const Text('Delete document'),
    child: const Text(
      'This will permanently delete this document and all its versions. This cannot be undone.',
    ),
    actions: [
      ShadButton.outline(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      ShadButton.destructive(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Delete'),
      ),
    ],
  ),
);
```

---

## 2. Publish / Archive Version — Version History Panel

### Location

`packages/flutter_cms/lib/src/studio/components/version/cms_version_history.dart` — specifically `_VersionMenuItem` (line ~329)

### Design

Add a contextual action button to each `_VersionMenuItem` based on the version's status:

| Version Status | Action Button | Behavior |
|---------------|---------------|----------|
| Draft | "Publish" | Confirm → `viewModel.publishVersion()` → backend publishes this version and archives any currently published version |
| Published | "Archive" | Confirm → `viewModel.archiveVersion()` |
| Archived | (none) | No action |
| Scheduled | (none) | No action (future feature) |

**Button placement:** Small action button (icon or text) on the right side of each version menu item, next to the status badge.

**Confirmation dialogs:**

Publish:
- Title: "Publish version"
- Body: "Publishing this version will archive any currently published version."
- Actions: Cancel / Publish

Archive:
- Title: "Archive version"
- Body: "This version will no longer be the active published version."
- Actions: Cancel / Archive

**Flow:**
1. User opens version history panel
2. Each version item shows its status badge + action button (if applicable)
3. User taps action button → confirmation dialog
4. On confirm → call `viewModel.publishVersion()` or `viewModel.archiveVersion()`
5. These methods already exist in `CmsViewModel` (lines ~298-336) — they reload versions after the operation
6. On success → version list refreshes automatically (signals update), show success toast
7. On failure → show destructive toast

### Interface Change

`_VersionMenuItem` currently receives version data for display only. It needs:
- An `onPublish` callback (nullable — only provided for draft versions)
- An `onArchive` callback (nullable — only provided for published versions)

The parent (`CmsVersionHistory`) wires these to the view model methods.

---

## 3. MapperException Fix — featuredItems Deserialization

### Problem

Error: `"Failed to decode (HomeScreenConfig).featuredItems(List<String>): Expected a value of type Iterable<dynamic>, but got type String"`

The `HomeScreenConfig.configBuilder()` merges raw data from the backend with default values, then passes the merged map to the Mapper. If `featuredItems` was stored as a JSON-encoded String (e.g., `"[\"item1\",\"item2\"]"`) rather than an actual List, the mapper fails.

### Location

`examples/data_models/lib/src/configs/home_screen_config.dart` — `configBuilder()` method (line ~149)

### Fix

In `configBuilder()`, normalize fields that expect Lists before passing to the mapper. Add a helper that checks if the value is a String and attempts JSON decode:

```dart
static Widget configBuilder(Map<String, dynamic> config) {
  final mergedConfig = {...defaultValue.toMap(), ...config};

  // Normalize fields that may be stored as JSON strings instead of Lists
  if (mergedConfig['featuredItems'] is String) {
    try {
      mergedConfig['featuredItems'] = jsonDecode(mergedConfig['featuredItems'] as String);
    } catch (_) {
      mergedConfig['featuredItems'] = <String>[];
    }
  }

  final homeScreenConfig = HomeScreenConfigMapper.fromMap(mergedConfig);
  return HomeScreenConfigView(config: homeScreenConfig);
}
```

This is a data normalization fix at the boundary where raw backend data meets the typed config. It handles the case where CRDT operations store array values as JSON strings.

### Alternative Considered

Fixing the serialization at the CRDT/data source layer. Rejected because: (a) it would require migrating existing corrupt data, (b) the `configBuilder` boundary is the right place to be defensive about data shape since it receives arbitrary `Map<String, dynamic>` from the backend.

---

## Files to Change

| File | Change |
|------|--------|
| `packages/flutter_cms/lib/src/studio/components/common/cms_toolbar_ribbon.dart` | Add kebab menu with "Delete document" action |
| `packages/flutter_cms/lib/src/studio/screens/cms_studio.dart` | Wire delete handler to view model |
| `packages/flutter_cms/lib/src/studio/components/version/cms_version_history.dart` | Add publish/archive buttons per version item |
| `examples/data_models/lib/src/configs/home_screen_config.dart` | Normalize `featuredItems` in `configBuilder()` |

## Testing

- Backend integration tests (61 existing) should still pass — no backend changes
- E2E re-test: TC-E2E-01-04 (delete) and TC-E2E-01-05 (publish) should become testable
- Manual verification: delete document, publish version, open document with corrupt featuredItems data
