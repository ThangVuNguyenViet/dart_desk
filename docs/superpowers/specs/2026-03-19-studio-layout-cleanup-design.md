# Studio Layout Cleanup — Collapsible Panels & Button Relocation

**Date:** 2026-03-19
**Status:** Draft

## Summary

Remove the toolbar ribbon, make sidebar and document list independently collapsible via their own controls, move Discard/Save to the bottom-right of the editor panel, and introduce a `CmsButton` widget with loading state support.

## Current State

The studio layout has a 40px toolbar ribbon below the top bar containing:
- "Sidebar" toggle button
- "List" toggle button
- Status pill ("changed") and "Updated just now" timestamp
- Discard and Save buttons (visible when unsaved changes exist)

The sidebar already has a collapse button at its bottom. The document list visibility is toggled only via the toolbar "List" button.

**Duplicate save/discard logic exists:** Both `CmsStudio` (lines 32-75) and `CmsDocumentEditor` (lines 38-115) have their own `_saveDocument` and `_discardDocument` methods. The editor's versions are more complete (handle both create and update, show toast messages). The `CmsStudio` versions feed the toolbar ribbon.

## Changes

### 1. Remove Toolbar Ribbon

Delete the `CmsToolbarRibbon` widget and its 40px row from `CmsStudio.build()`. All functionality it provided is either relocated or removed.

**Files:**
- `cms_toolbar_ribbon.dart` — delete file
- `cms_studio.dart` — remove `CmsToolbarRibbon` from the layout column, remove `_saveDocument` and `_discardDocument` methods (the editor's versions are kept), remove `_deriveToolbarStatus` helper (dead code after ribbon removal)

### 2. Document List — Header Collapse Button

Add a collapse/expand chevron to the document list header, next to the existing title and `+` button.

- **Expanded state:** `<<` chevron icon in the header row. Clicking it sets `viewModel.documentListVisible` to `false`.
- **Collapsed state:** The document list wraps in an `AnimatedContainer` (200ms duration, matching the sidebar's existing animation). Width animates from 220px to 0. When collapsed, a thin 24px-wide vertical strip renders between the sidebar and preview area containing a `>>` icon button to re-expand.
- Uses the existing `documentListVisible` signal — no new state needed.

**Files:**
- `document_list.dart` — add chevron button to header
- `cms_studio.dart` — wrap document list in `AnimatedContainer`, add collapsed expand-handle widget

### 3. Sidebar — No Changes

The sidebar already has its own collapse/expand button at the bottom (`<< Collapse`). Removing the toolbar "Sidebar" button is the only change — the sidebar's own mechanism is unaffected.

### 4. Discard & Save — Bottom-Right of Editor Panel

The editor (`CmsDocumentEditor`) already has save/discard logic and a `Stack` in `_buildEditor`. Add `Positioned` Discard/Save buttons at the bottom-right of this existing stack. Remove the full-screen saving overlay and replace with the `CmsButton` loading state.

- Save button uses `CmsButton` with `loading: isSaving`. Already has access to `isSaving` via `viewModel.isSaving.watch(context)` at line 121.
- Discard button uses `CmsButton` (outline variant), disabled while saving.
- Only visible when `hasUnsavedChanges` is true.
- Remove `onSave`/`onDiscard` callbacks from `CmsForm` — the form no longer renders these buttons. `CmsForm` becomes purely a field renderer.

**Files:**
- `document_editor.dart` — add Positioned buttons in `_buildEditor`, remove saving overlay
- `cms_form.dart` — remove `onSave`/`onDiscard` parameters and any button rendering

### 5. Remove Status Indicator

The "changed" status pill and "Updated just now" timestamp are removed entirely. The appearance of Save/Discard buttons is sufficient signal that changes exist.

Note: `CmsStatusPill` may still be used in `document_list.dart` for document status badges (draft/published). Only remove it from the toolbar; do not delete the widget file if it has other consumers.

### 6. CmsButton Widget

New reusable button wrapping `ShadButton` with a `loading` parameter.

**API:**
```dart
CmsButton({
  required String text,
  required VoidCallback? onPressed,
  bool loading = false,
  ShadButtonVariant variant = ShadButtonVariant.primary,
  ShadButtonSize size = ShadButtonSize.sm,
})
```

**Behavior:**
- When `loading: true`: passes a 16x16 `CircularProgressIndicator(strokeWidth: 2)` as the `icon` parameter of `ShadButton`, disables `onPressed`
- When `loading: false`: renders as normal `ShadButton`
- Defaults to `ShadButtonSize.sm` to match existing button sizing

**File:**
- New: `packages/flutter_cms/lib/src/studio/components/common/cms_button.dart`

## Layout After Changes

```
TopBar (48px)
├── Logo + Breadcrumbs
├── Theme toggle, version history
└── User avatar

Main Content (remaining height)
├── Sidebar (48-180px, self-collapsing via bottom button)
├── Document List (0-220px, collapsing via header chevron)
│   └── When collapsed: 24px expand-handle strip with >> icon
└── Preview + Editor (flex)
    ├── Preview (left half)
    └── Editor (right half)
        └── [Discard] [Save] (bottom-right, only when unsaved changes)
```

## Out of Scope

- Drag-to-resize panels
- Keyboard shortcuts for panel toggling
- Persisting panel collapse state across sessions
