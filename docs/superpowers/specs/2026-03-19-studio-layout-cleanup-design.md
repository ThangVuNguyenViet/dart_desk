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

## Changes

### 1. Remove Toolbar Ribbon

Delete the `CmsToolbarRibbon` widget and its 40px row from `CmsStudio.build()`. All functionality it provided is either relocated or removed.

**Files:**
- `cms_toolbar_ribbon.dart` — delete file
- `cms_studio.dart` — remove `CmsToolbarRibbon` from the layout column

### 2. Document List — Header Collapse Button

Add a collapse/expand chevron to the document list header, next to the existing title and `+` button.

- **Expanded state:** `<<` chevron in the header row. Clicking it sets `viewModel.documentListVisible` to `false`.
- **Collapsed state:** The document list panel animates to 0 width. A small `>>` expand button appears at the boundary so the user can re-open it.
- Uses the existing `documentListVisible` signal — no new state needed.

**Files:**
- `document_list.dart` — add chevron button to header, add collapsed expand handle

### 3. Sidebar — No Changes

The sidebar already has its own collapse/expand button at the bottom (`<< Collapse`). Removing the toolbar "Sidebar" button is the only change — the sidebar's own mechanism is unaffected.

### 4. Discard & Save — Bottom-Right of Editor Panel

Move buttons into `CmsDocumentEditor`, positioned at the bottom-right using a `Stack` + `Positioned` widget. Only visible when there are unsaved changes.

- Save button uses `CmsButton` with `loading: isSaving`.
- Discard button uses `CmsButton` (outline variant), disabled while saving.

**Files:**
- `document_editor.dart` — add Discard/Save buttons at bottom-right

### 5. Remove Status Indicator

The "changed" status pill and "Updated just now" timestamp are removed entirely. The appearance of Save/Discard buttons is sufficient signal that changes exist.

### 6. CmsButton Widget

New reusable button wrapping `ShadButton` with a `loading` parameter.

**API:**
```dart
CmsButton({
  required String text,
  required VoidCallback? onPressed,
  bool loading = false,
  ShadButtonVariant variant = ShadButtonVariant.primary,
})
```

**Behavior:**
- When `loading: true`: shows `CircularProgressIndicator` as leading icon, disables the button
- When `loading: false`: renders as normal `ShadButton`

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
└── Preview + Editor (flex)
    ├── Preview (left half)
    └── Editor (right half)
        └── [Discard] [Save] (bottom-right, only when unsaved changes)
```

## Out of Scope

- Drag-to-resize panels
- Keyboard shortcuts for panel toggling
- Persisting panel collapse state across sessions
