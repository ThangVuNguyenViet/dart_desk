# Delete Document UI, Publish Version UI, and MapperException Fix — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add delete document and publish/archive version UI actions to the CMS studio, and fix a deserialization crash on the `featuredItems` field.

**Architecture:** Delete lives in a kebab menu (⋮) added to the toolbar ribbon. Publish/Archive are contextual buttons on each version item in the version history popover. The MapperException is fixed by normalizing JSON-string arrays in `configBuilder()`.

**Tech Stack:** Flutter, shadcn_ui (ShadButton, ShadPopover, ShadDialog, ShadToast), signals, font_awesome_flutter

**Spec:** `docs/superpowers/specs/2026-03-18-delete-publish-mapper-fix-design.md`

---

## File Structure

| File | Change | Responsibility |
|------|--------|---------------|
| `packages/flutter_cms/lib/src/studio/components/common/cms_toolbar_ribbon.dart` | Modify | Add kebab menu with "Delete document" action |
| `packages/flutter_cms/lib/src/studio/screens/cms_studio.dart` | Modify | Wire `onDelete` callback to view model |
| `packages/flutter_cms/lib/src/studio/components/version/cms_version_history.dart` | Modify | Add Publish/Archive buttons per version item |
| `examples/data_models/lib/src/configs/home_screen_config.dart` | Modify | Normalize `featuredItems` before mapper |

---

## Task 1: Fix MapperException on featuredItems

**Files:**
- Modify: `examples/data_models/lib/src/configs/home_screen_config.dart:149-154`

**Context:** The `configBuilder()` method merges raw backend data with defaults and passes it to `HomeScreenConfigMapper.fromMap()`. If `featuredItems` was stored as a JSON string (e.g., `"[\"a\",\"b\"]"`) instead of an actual List, the mapper throws. Fix: normalize before mapping.

- [ ] **Step 1: Add dart:convert import and normalize featuredItems**

In `home_screen_config.dart`, add `import 'dart:convert';` at the top if not already present, then modify `configBuilder()`:

```dart
static Widget configBuilder(Map<String, dynamic> config) {
  final mergedConfig = {...defaultValue.toMap(), ...config};

  // Normalize fields that may be stored as JSON strings instead of Lists
  final featuredItems = mergedConfig['featuredItems'];
  if (featuredItems is String) {
    try {
      mergedConfig['featuredItems'] = jsonDecode(featuredItems);
    } catch (_) {
      mergedConfig['featuredItems'] = <String>[];
    }
  }

  final homeScreenConfig = HomeScreenConfigMapper.fromMap(mergedConfig);
  return HomeScreen(config: homeScreenConfig);
}
```

- [ ] **Step 2: Verify it compiles**

```bash
cd examples/data_models && dart analyze lib/src/configs/home_screen_config.dart
```
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add examples/data_models/lib/src/configs/home_screen_config.dart
git commit -m "fix: normalize featuredItems JSON string before mapper deserialization"
```

---

## Task 2: Add Delete Document to Toolbar Kebab Menu

**Files:**
- Modify: `packages/flutter_cms/lib/src/studio/components/common/cms_toolbar_ribbon.dart`
- Modify: `packages/flutter_cms/lib/src/studio/screens/cms_studio.dart`

**Context:** `CmsToolbarRibbon` currently has Save/Discard buttons on the right. Add a kebab menu (⋮) button after them with a "Delete document" option. The menu should always be visible when a document is selected (not just when there are unsaved changes). `CmsStudio` wires `onDelete` to `viewModel.deleteDocument()` with a confirmation dialog.

### Step 1: Add onDelete callback to CmsToolbarRibbon

- [ ] **Step 1a: Add the `onDelete` parameter**

In `cms_toolbar_ribbon.dart`, add to `CmsToolbarRibbon`:

```dart
final VoidCallback? onDelete;
```

Add to constructor:

```dart
this.onDelete,
```

- [ ] **Step 1b: Add the kebab menu button after the save/discard section**

In the `build` method, after the `if (hasUnsavedChanges)` block (line 116) and before the closing `]` of the Row's children, add the kebab menu. It should be visible whenever `documentStatus != null` (i.e., a document is open):

```dart
if (documentStatus != null) ...[
  const SizedBox(width: CmsSpacing.sm),
  ShadButton.ghost(
    key: const ValueKey('more_actions_button'),
    size: ShadButtonSize.sm,
    height: 28,
    width: 28,
    padding: EdgeInsets.zero,
    onPressed: onDelete,
    icon: const FaIcon(
      FontAwesomeIcons.ellipsisVertical,
      size: 14,
    ),
  ),
],
```

Note: For now, since "Delete document" is the only action, the kebab button directly triggers `onDelete`. If more actions are added later, this can be refactored into a `ShadPopover` dropdown menu.

- [ ] **Step 2: Wire onDelete in CmsStudio**

In `cms_studio.dart`, add a `_deleteDocument` method to `_CmsStudioState`:

```dart
Future<void> _deleteDocument(BuildContext context) async {
  final viewModel = cmsViewModelProvider.of(context);
  final documentViewModel = documentViewModelProvider.of(context);
  final toaster = ShadToaster.of(context);
  final docId = documentViewModel.documentId.value;

  if (docId == null) return;

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

  if (confirmed != true || !mounted) return;

  try {
    final result = await viewModel.deleteDocument(docId);
    if (mounted) {
      if (result) {
        toaster.show(
          const ShadToast(description: Text('Document deleted')),
        );
      } else {
        toaster.show(
          ShadToast.destructive(
            description: const Text('Failed to delete document'),
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      toaster.show(
        ShadToast.destructive(
          description: Text('Failed to delete: $e'),
        ),
      );
    }
  }
}
```

- [ ] **Step 3: Pass onDelete to CmsToolbarRibbon**

In `_CmsStudioState.build()`, in the `CmsToolbarRibbon(...)` constructor call (around line 298), add:

```dart
onDelete: () => _deleteDocument(context),
```

- [ ] **Step 4: Verify it compiles**

```bash
cd packages/flutter_cms && dart analyze lib/src/studio/components/common/cms_toolbar_ribbon.dart lib/src/studio/screens/cms_studio.dart
```
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/components/common/cms_toolbar_ribbon.dart packages/flutter_cms/lib/src/studio/screens/cms_studio.dart
git commit -m "feat: add delete document action via toolbar kebab menu"
```

---

## Task 3: Add Publish/Archive Buttons to Version History

**Files:**
- Modify: `packages/flutter_cms/lib/src/studio/components/version/cms_version_history.dart`

**Context:** `_VersionMenuItem` displays version info (number, status badge, date, changelog). Add a contextual action button: "Publish" for draft versions, "Archive" for published versions. The parent `CmsVersionHistory` has access to `widget.viewModel` which has `publishVersion()` and `archiveVersion()` methods. These methods operate on `selectedVersionId`, so before calling, we need to ensure the correct version is selected.

**Important:** `publishVersion()` and `archiveVersion()` in `CmsViewModel` operate on `selectedVersionId.value`. When the user taps Publish/Archive on a version item, we must set `selectedVersionId` to that version's ID first, then call the method.

### Step 1: Add callbacks to _VersionMenuItem

- [ ] **Step 1a: Add onPublish and onArchive parameters**

In `_VersionMenuItem`, add:

```dart
final VoidCallback? onPublish;
final VoidCallback? onArchive;
```

Add to constructor:

```dart
this.onPublish,
this.onArchive,
```

- [ ] **Step 1b: Add action button to the version item row**

In `_VersionMenuItemState.build()`, in the `Row` children (after the `Expanded` content column at line ~435, before the selection checkmark at line ~437), add:

```dart
// Action button (publish for draft, archive for published)
if (widget.onPublish != null) ...[
  const SizedBox(width: 8),
  ShadButton(
    key: ValueKey('publish_button_${widget.version.id}'),
    size: ShadButtonSize.sm,
    height: 24,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    onPressed: widget.onPublish,
    child: const Text('Publish', style: TextStyle(fontSize: 11)),
  ),
],
if (widget.onArchive != null) ...[
  const SizedBox(width: 8),
  ShadButton.outline(
    key: ValueKey('archive_button_${widget.version.id}'),
    size: ShadButtonSize.sm,
    height: 24,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    onPressed: widget.onArchive,
    child: const Text('Archive', style: TextStyle(fontSize: 11)),
  ),
],
```

### Step 2: Wire callbacks in CmsVersionHistory

- [ ] **Step 2a: Add publish/archive handler methods to `_CmsVersionHistoryState`**

```dart
Future<void> _publishVersion(BuildContext context, DocumentVersion version) async {
  final confirmed = await showShadDialog<bool>(
    context: context,
    builder: (context) => ShadDialog(
      title: const Text('Publish version'),
      child: const Text(
        'Publishing this version will archive any currently published version.',
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ShadButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Publish'),
        ),
      ],
    ),
  );

  if (confirmed != true || !mounted) return;

  // Set the selected version before calling publishVersion
  widget.viewModel.selectedVersionId.value = version.id;

  try {
    await widget.viewModel.publishVersion();
    if (mounted) {
      ShadToaster.of(context).show(
        const ShadToast(description: Text('Version published')),
      );
    }
  } catch (e) {
    if (mounted) {
      ShadToaster.of(context).show(
        ShadToast.destructive(description: Text('Failed to publish: $e')),
      );
    }
  }
}

Future<void> _archiveVersion(BuildContext context, DocumentVersion version) async {
  final confirmed = await showShadDialog<bool>(
    context: context,
    builder: (context) => ShadDialog(
      title: const Text('Archive version'),
      child: const Text(
        'This version will no longer be the active published version.',
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ShadButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Archive'),
        ),
      ],
    ),
  );

  if (confirmed != true || !mounted) return;

  widget.viewModel.selectedVersionId.value = version.id;

  try {
    await widget.viewModel.archiveVersion();
    if (mounted) {
      ShadToaster.of(context).show(
        const ShadToast(description: Text('Version archived')),
      );
    }
  } catch (e) {
    if (mounted) {
      ShadToaster.of(context).show(
        ShadToast.destructive(description: Text('Failed to archive: $e')),
      );
    }
  }
}
```

- [ ] **Step 2b: Pass callbacks to _VersionMenuItem**

In `_buildVersionsList`, in the `_VersionMenuItem(...)` constructor (around line 259), add:

```dart
onPublish: version.isDraft
    ? () => _publishVersion(context, version)
    : null,
onArchive: version.isPublished
    ? () => _archiveVersion(context, version)
    : null,
```

- [ ] **Step 3: Verify it compiles**

```bash
cd packages/flutter_cms && dart analyze lib/src/studio/components/version/cms_version_history.dart
```
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/components/version/cms_version_history.dart
git commit -m "feat: add publish and archive version actions in version history panel"
```

---

## Task 4: Manual Verification

- [ ] **Step 1: Hot-reload the running app** (if still running) or launch:
```bash
cd examples/cms_app && flutter run -d chrome --web-port=60366 --web-browser-flag="--user-data-dir=/tmp/flutter_cms_chrome_profile"
```

- [ ] **Step 2: Verify MapperException fix** — Navigate to the document with corrupt `featuredItems` data. It should load without crashing.

- [ ] **Step 3: Verify Delete** — Open a document → tap ⋮ kebab menu → confirm dialog → document deleted, navigate back to list.

- [ ] **Step 4: Verify Publish** — Open a document → open version history → tap "Publish" on a draft version → confirm dialog → status changes to published.

- [ ] **Step 5: Verify Archive** — On the now-published version → tap "Archive" → confirm → status changes to archived.
