# Studio Layout Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the toolbar ribbon, make panels self-collapsible, relocate save/discard buttons to editor bottom-right, and add a reusable CmsButton with loading state.

**Architecture:** The toolbar ribbon is deleted entirely. The document list gets a header chevron for collapse/expand. Save/Discard buttons move into the existing Stack in CmsDocumentEditor. A new CmsButton widget wraps ShadButton with loading support.

**Tech Stack:** Flutter, shadcn_ui, signals, font_awesome_flutter

**Spec:** `docs/superpowers/specs/2026-03-19-studio-layout-cleanup-design.md`

---

## File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `packages/flutter_cms/lib/src/studio/components/common/cms_button.dart` | Reusable button with loading state |
| Modify | `packages/flutter_cms/lib/src/studio/screens/document_editor.dart` | Add Positioned save/discard buttons, remove saving overlay |
| Modify | `packages/flutter_cms/lib/src/studio/components/forms/cms_form.dart` | Remove unused onSave/onDiscard params |
| Modify | `packages/flutter_cms/lib/src/studio/screens/document_list.dart` | Add collapse chevron to header |
| Modify | `packages/flutter_cms/lib/src/studio/screens/cms_studio.dart` | Remove toolbar ribbon, add AnimatedContainer for doc list, add expand handle |
| Delete | `packages/flutter_cms/lib/src/studio/components/common/cms_toolbar_ribbon.dart` | No longer needed |

---

### Task 1: Create CmsButton Widget

**Files:**
- Create: `packages/flutter_cms/lib/src/studio/components/common/cms_button.dart`

- [ ] **Step 1: Create CmsButton widget**

```dart
// packages/flutter_cms/lib/src/studio/components/common/cms_button.dart

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Reusable button wrapping ShadButton with loading state support.
class CmsButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final ShadButtonVariant variant;
  final ShadButtonSize size;

  const CmsButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.variant = ShadButtonVariant.primary,
    this.size = ShadButtonSize.sm,
  });

  @override
  Widget build(BuildContext context) {
    return ShadButton.raw(
      variant: variant,
      size: size,
      onPressed: loading ? null : onPressed,
      leading: loading
          ? SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ShadTheme.of(context).colorScheme.primaryForeground,
              ),
            )
          : null,
      child: Text(loading ? 'Please wait' : text),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `cd packages/flutter_cms && flutter analyze lib/src/studio/components/common/cms_button.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/components/common/cms_button.dart
git commit -m "feat: add CmsButton widget with loading state"
```

---

### Task 2: Move Save/Discard Buttons into Document Editor

**Files:**
- Modify: `packages/flutter_cms/lib/src/studio/screens/document_editor.dart:159-182`
- Modify: `packages/flutter_cms/lib/src/studio/components/forms/cms_form.dart:182-195`

- [ ] **Step 1: Remove onSave/onDiscard from CmsForm**

In `cms_form.dart`, remove the `onSave` and `onDiscard` parameters from the `CmsForm` constructor (lines 182-183, 193-194). The form's `build()` method doesn't use them, so no other changes needed in this file.

After edit, `CmsForm` constructor should be:
```dart
class CmsForm extends StatefulWidget {
  final List<CmsField> fields;
  final Map<String, dynamic> data;
  final String? title;
  final OnFieldChanged? onFieldChanged;

  const CmsForm({
    super.key,
    required this.fields,
    this.data = const {},
    this.title,
    this.onFieldChanged,
  });
  // ...
}
```

- [ ] **Step 2: Update document_editor.dart _buildEditor to use CmsButton**

Replace `_buildEditor` method (lines 159-182). This removes the full-screen saving overlay (`Positioned.fill` with black overlay + `ShadProgress`) and replaces it with inline `CmsButton` loading state. Replace with:

```dart
Widget _buildEditor(Map<String, dynamic> documentData, bool isSaving) {
  final edited = editedData.watch(context);
  final hasUnsavedChanges = edited.isNotEmpty;

  return Stack(
    children: [
      CmsForm(
        fields: widget.fields,
        data: Map<String, dynamic>.from(documentData),
        title: widget.title,
        onFieldChanged: (fieldName, value) => editedData[fieldName] = value,
      ),
      if (hasUnsavedChanges)
        Positioned(
          bottom: 16,
          right: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CmsButton(
                text: 'Discard',
                variant: ShadButtonVariant.outline,
                onPressed: isSaving ? null : _discardDocument,
              ),
              const SizedBox(width: 8),
              CmsButton(
                text: 'Save',
                loading: isSaving,
                onPressed: isSaving ? null : _saveDocument,
              ),
            ],
          ),
        ),
    ],
  );
}
```

Add import at top of `document_editor.dart`:
```dart
import '../components/common/cms_button.dart';
```

- [ ] **Step 3: Verify it compiles**

Run: `cd packages/flutter_cms && flutter analyze lib/src/studio/screens/document_editor.dart lib/src/studio/components/forms/cms_form.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/screens/document_editor.dart packages/flutter_cms/lib/src/studio/components/forms/cms_form.dart
git commit -m "feat: move save/discard buttons to editor bottom-right with CmsButton"
```

---

### Task 3: Add Collapse Chevron to Document List Header

**Files:**
- Modify: `packages/flutter_cms/lib/src/studio/screens/document_list.dart:162-194`

- [ ] **Step 1: Add collapse chevron to header row**

In `_buildContent` method, modify the header `Row` (lines 162-194) to add a collapse chevron button before the `+` button:

```dart
Row(
  children: [
    if (widget.icon != null) ...[
      FaIcon(widget.icon!, size: 18, color: theme.colorScheme.primary),
      const SizedBox(width: 8),
    ],
    Expanded(
      child: Text(
        widget.selectedDocumentType.title,
        style: theme.textTheme.large.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    ShadIconButton.ghost(
      onPressed: () {
        final viewModel = cmsViewModelProvider.of(context);
        viewModel.documentListVisible.value = false;
      },
      icon: const FaIcon(FontAwesomeIcons.anglesLeft, size: 14),
    ),
    ShadIconButton.secondary(
      onPressed: () {
        setState(() {
          _isCreatingNew = !_isCreatingNew;
          if (!_isCreatingNew) {
            _titleController.clear();
            _slugController.clear();
          }
        });
      },
      icon: FaIcon(
        _isCreatingNew ? FontAwesomeIcons.xmark : FontAwesomeIcons.plus,
        size: 16,
      ),
    ),
  ],
),
```

Add import if not present:
```dart
import '../providers/studio_provider.dart';
```

- [ ] **Step 2: Verify it compiles**

Run: `cd packages/flutter_cms && flutter analyze lib/src/studio/screens/document_list.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/screens/document_list.dart
git commit -m "feat: add collapse chevron to document list header"
```

---

### Task 4: Remove Toolbar Ribbon and Wire Up Collapsible Document List

**Files:**
- Modify: `packages/flutter_cms/lib/src/studio/screens/cms_studio.dart`
- Delete: `packages/flutter_cms/lib/src/studio/components/common/cms_toolbar_ribbon.dart`

- [ ] **Step 1: Remove dead code from CmsStudio**

Remove these methods from `_CmsStudioState`:
- `_saveDocument` (lines 32-58)
- `_discardDocument` (lines 60-75)
- `_deriveToolbarStatus` (lines 323-337)

Remove these imports:
- `import '../components/common/cms_toolbar_ribbon.dart';`
- `import '../../data/models/document_version.dart';` (used only by `_deriveToolbarStatus` and `_discardDocument`, both being removed)

Remove unused variables from `build()`:
- `isSaving` (line 348)
- `editedData` (line 349)

- [ ] **Step 2: Replace toolbar ribbon + document list section in build()**

Replace the `build()` method body. Remove the `CmsToolbarRibbon` widget. Replace the conditional `if (isListVisible)` document list with an `AnimatedContainer` + expand handle:

```dart
@override
Widget build(BuildContext context) {
  final theme = ShadTheme.of(context);
  final viewModel = cmsViewModelProvider.of(context);

  final isListVisible = viewModel.documentListVisible.watch(context);
  final isSidebarCollapsed = viewModel.sidebarCollapsed.watch(context);
  final docType = viewModel.currentDocumentType.watch(context);

  return Scaffold(
    backgroundColor: theme.colorScheme.background,
    body: Row(
      children: [
        // Sidebar (already handles its own width/collapse)
        widget.sidebar,
        // Document list (collapsible via header chevron)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isListVisible ? 220 : 0,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            border: Border(
              right: BorderSide(
                color: theme.colorScheme.border.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: docType == null
              ? _buildEmptyState(
                  theme: theme,
                  icon: FontAwesomeIcons.folderOpen,
                  title: 'Documents',
                  description:
                      'Select a document type to see available documents',
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CmsSpacing.md,
                    CmsSpacing.sm,
                    CmsSpacing.md,
                    CmsSpacing.md,
                  ),
                  child: CmsDocumentListView(
                    selectedDocumentType: docType,
                    icon: FontAwesomeIcons.file,
                    onOpenDocument: (documentId) {
                      widget.coordinator.pushOrMoveToTop(
                        DocumentRoute(docType.name, documentId),
                      );
                    },
                    onDeleteDocument: (docId) =>
                        _deleteDocument(context, docId: docId),
                  ),
                ),
        ),
        // Expand handle when document list is collapsed
        if (!isListVisible)
          GestureDetector(
            onTap: () => viewModel.documentListVisible.value = true,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.card,
                  border: Border(
                    right: BorderSide(
                      color:
                          theme.colorScheme.border.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.anglesRight,
                    size: 12,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
            ),
          ),
        // Editor + Preview split
        Expanded(child: _buildEditorPreview(context, theme, viewModel)),
      ],
    ),
  );
}
```

Note: The `Column` wrapping `Scaffold.body` is removed since the toolbar ribbon is gone — the body is now just the `Row` directly.

- [ ] **Step 3: Delete toolbar ribbon file**

```bash
git rm packages/flutter_cms/lib/src/studio/components/common/cms_toolbar_ribbon.dart
```

- [ ] **Step 4: Remove _buildDocumentsList helper method**

Delete the `_buildDocumentsList` method (lines 133-174) — its logic is now inlined in `build()`.

- [ ] **Step 5: Verify it compiles**

Run: `cd packages/flutter_cms && flutter analyze lib/src/studio/screens/cms_studio.dart`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add -u packages/flutter_cms/lib/src/studio/
git commit -m "feat: remove toolbar ribbon, add collapsible document list with expand handle"
```

---

### Task 5: Visual Verification

- [ ] **Step 1: Run the CMS app**

```bash
cd examples/cms_app && flutter run -d chrome --web-browser-flag="--user-data-dir=/tmp/flutter_cms_chrome_profile"
```

- [ ] **Step 2: Verify these behaviors:**

1. No toolbar ribbon below the top bar
2. Sidebar collapses/expands via its own bottom button (unchanged)
3. Document list has `<<` chevron in header — clicking it collapses the list
4. When document list is collapsed, a thin `>>` strip appears to re-expand
5. Save/Discard buttons appear at bottom-right of editor when there are unsaved changes
6. Save button shows loading spinner while saving
7. Discard button resets changes correctly

- [ ] **Step 3: Fix any issues found, then commit**

```bash
git add -u && git commit -m "fix: visual verification fixes for layout cleanup"
```
