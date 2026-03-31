# isDefault Document UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Surface `CmsDocument.isDefault` as a fully interactive UI feature — badge indicator on tiles, overflow menu action to set default, toast feedback, and auto-default enforcement on create/delete.

**Architecture:** MockDataSource handles auto-default logic in-process (no external calls). CmsViewModel adds `setDefaultDocument` and updates `deleteDocument` to return a record carrying the auto-assigned default. Two callers in shell/screen are updated to show the additional toast. The document tile's existing `PopupMenuButton` gains a "Set as default" item wired directly to the ViewModel.

**Tech Stack:** Flutter, signals, shadcn_ui (`ShadBadge`, `ShadToast`), MockDataSource (unit tests), CloudDataSource (Serverpod client stub).

---

> **Backend note:** `CloudDataSource.setDefaultDocument` (Task 9) calls `_client.document.setDefaultDocument(...)`. The Serverpod endpoint + DB migration must be implemented separately in `dart_desk_be` using the `serverpod` skill. That work is out of scope for this plan.

---

### Task 1: Add `setDefaultDocument` to the DataSource interface

**Files:**
- Modify: `lib/src/data/cms_data_source.dart`

- [ ] **Step 1: Open the file and locate the abstract class**

  Read `lib/src/data/cms_data_source.dart`. Find the `abstract class DataSource` block.

- [ ] **Step 2: Add the new abstract method**

  After `Future<bool> deleteDocument(int documentId);`, add:

  ```dart
  /// Atomically unsets the current default for [documentTypeSlug] and sets
  /// [documentId] as the new default. Returns the updated document.
  Future<CmsDocument> setDefaultDocument(
    String documentTypeSlug,
    int documentId,
  );
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add lib/src/data/cms_data_source.dart
  git commit -m "feat: add setDefaultDocument to DataSource interface"
  ```

---

### Task 2: Implement `setDefaultDocument` in MockDataSource (TDD)

**Files:**
- Modify: `test/testing/mock_data_source_test.dart`
- Modify: `lib/src/testing/mock_cms_data_source.dart`

- [ ] **Step 1: Add the failing test group**

  Open `test/testing/mock_data_source_test.dart`. Add after the existing `Document CRUD` group:

  ```dart
  // ============================================================
  // N. setDefaultDocument
  // ============================================================

  group('setDefaultDocument', () {
    test('swaps isDefault from the current default to a new document', () async {
      // Seed: doc 1 is already default in 'test_all_fields'. Create another.
      final doc4 = await dataSource.createDocument(
        'test_all_fields',
        'Doc Four',
        {},
        slug: 'doc-four',
      );

      final updated = await dataSource.setDefaultDocument(
        'test_all_fields',
        doc4.id!,
      );

      expect(updated.isDefault, isTrue);

      // Old default should now be false
      final old = await dataSource.getDocument(1);
      expect(old?.isDefault, isFalse);
    });

    test('returns the updated document with isDefault true', () async {
      final doc4 = await dataSource.createDocument(
        'test_all_fields',
        'Doc Four',
        {},
        slug: 'doc-four',
      );
      final result = await dataSource.setDefaultDocument('test_all_fields', doc4.id!);
      expect(result.id, doc4.id);
      expect(result.isDefault, isTrue);
    });

    test('throws CmsNotFoundException for unknown documentId', () async {
      expect(
        () => dataSource.setDefaultDocument('test_all_fields', 99999),
        throwsA(isA<CmsNotFoundException>()),
      );
    });
  });
  ```

- [ ] **Step 2: Run the tests — expect compile failure (method not on MockDataSource yet)**

  ```bash
  cd packages/dart_desk && flutter test test/testing/mock_data_source_test.dart
  ```

  Expected: compile error — `MockDataSource` does not implement `setDefaultDocument`.

- [ ] **Step 3: Implement `setDefaultDocument` in MockDataSource**

  Open `lib/src/testing/mock_cms_data_source.dart`. Add the following method to the `MockDataSource` class (after `deleteDocument`):

  ```dart
  @override
  Future<CmsDocument> setDefaultDocument(
    String documentTypeSlug,
    int documentId,
  ) async {
    // Unset any existing default for this type
    final currentDefault = _documents.values.firstWhereOrNull(
      (d) => d.documentType == documentTypeSlug && d.isDefault,
    );
    if (currentDefault?.id != null) {
      _documents[currentDefault!.id!] =
          currentDefault.copyWith(isDefault: false);
    }

    // Set new default
    final doc = _documents[documentId];
    if (doc == null) {
      throw CmsNotFoundException('Document $documentId not found');
    }
    final updated = doc.copyWith(isDefault: true);
    _documents[documentId] = updated;
    return updated;
  }
  ```

  Add the `collection` import at the top of the file if not already present:

  ```dart
  import 'package:collection/collection.dart';
  ```

- [ ] **Step 4: Run tests — expect pass**

  ```bash
  cd packages/dart_desk && flutter test test/testing/mock_data_source_test.dart
  ```

  Expected: all tests pass.

- [ ] **Step 5: Commit**

  ```bash
  git add lib/src/testing/mock_cms_data_source.dart test/testing/mock_data_source_test.dart
  git commit -m "feat: implement setDefaultDocument in MockDataSource"
  ```

---

### Task 3: Auto-default on create and delete in MockDataSource (TDD)

**Files:**
- Modify: `test/testing/mock_data_source_test.dart`
- Modify: `lib/src/testing/mock_cms_data_source.dart`

- [ ] **Step 1: Add failing tests**

  Append to `test/testing/mock_data_source_test.dart`:

  ```dart
  // ============================================================
  // N+1. Auto-default behaviours
  // ============================================================

  group('Auto-default on create', () {
    test('first document for a new type is auto-set as default', () async {
      final doc = await dataSource.createDocument(
        'new_type',
        'First Doc',
        {},
        slug: 'first-doc',
      );
      expect(doc.isDefault, isTrue);
    });

    test('second document for a type is NOT auto-set as default', () async {
      await dataSource.createDocument('new_type', 'First', {}, slug: 'first');
      final second = await dataSource.createDocument(
        'new_type',
        'Second',
        {},
        slug: 'second',
      );
      expect(second.isDefault, isFalse);
    });
  });

  group('Auto-default on delete', () {
    test('sole remaining document becomes default when the default is deleted', () async {
      // Create two docs in a fresh type; first is auto-default
      final a = await dataSource.createDocument('solo_type', 'A', {}, slug: 'a');
      final b = await dataSource.createDocument('solo_type', 'B', {}, slug: 'b');
      expect(a.isDefault, isTrue);

      // Delete the default (a)
      await dataSource.deleteDocument(a.id!);

      final remaining = await dataSource.getDocument(b.id!);
      expect(remaining?.isDefault, isTrue);
    });

    test('no auto-default when a non-default is deleted and multiple remain',
        () async {
      final a = await dataSource.createDocument('multi_type', 'A', {}, slug: 'a');
      final b = await dataSource.createDocument('multi_type', 'B', {}, slug: 'b');
      final c = await dataSource.createDocument('multi_type', 'C', {}, slug: 'c');
      expect(a.isDefault, isTrue);

      // Delete non-default (c)
      await dataSource.deleteDocument(c.id!);

      final stillDefault = await dataSource.getDocument(a.id!);
      final bDoc = await dataSource.getDocument(b.id!);
      expect(stillDefault?.isDefault, isTrue);
      expect(bDoc?.isDefault, isFalse);
    });
  });
  ```

- [ ] **Step 2: Run tests — expect failures**

  ```bash
  cd packages/dart_desk && flutter test test/testing/mock_data_source_test.dart
  ```

  Expected: `Auto-default on create` and `Auto-default on delete` groups fail.

- [ ] **Step 3: Update `createDocument` in MockDataSource**

  Find `createDocument` in `lib/src/testing/mock_cms_data_source.dart`. Locate where the new `CmsDocument` is constructed (the line that sets `isDefault: isDefault`). Change the surrounding logic to:

  ```dart
  // Determine effective isDefault: auto-assign if this is the first doc for this type
  final isFirstForType =
      !_documents.values.any((d) => d.documentType == documentType);
  final effectiveIsDefault = isDefault || isFirstForType;
  ```

  Then replace `isDefault: isDefault` with `isDefault: effectiveIsDefault` in the `CmsDocument(...)` constructor call.

- [ ] **Step 4: Update `deleteDocument` in MockDataSource**

  Find `deleteDocument` in `lib/src/testing/mock_cms_data_source.dart`. Before removing the document, capture whether it was the default:

  ```dart
  @override
  Future<bool> deleteDocument(int documentId) async {
    final doc = _documents[documentId];
    if (doc == null) return false;

    final wasDefault = doc.isDefault;
    final docType = doc.documentType;

    // Remove document and all its versions
    final versionIds = _versions[documentId]?.keys.toList() ?? [];
    for (final vId in versionIds) {
      _versionData.remove(vId);
    }
    _versions.remove(documentId);
    _documents.remove(documentId);

    // Auto-assign default to the sole remaining document if needed
    if (wasDefault) {
      final remaining =
          _documents.values.where((d) => d.documentType == docType).toList();
      if (remaining.length == 1) {
        final newDefault = remaining.first;
        _documents[newDefault.id!] = newDefault.copyWith(isDefault: true);
      }
    }

    return true;
  }
  ```

  > **Note:** The version-removal block above replaces whatever was there before. Verify the original version-removal code matches the structure of `_versions` and `_versionData` before pasting — keep whichever is already correct and only add the `wasDefault`/`remaining` block.

- [ ] **Step 5: Run tests — expect all pass**

  ```bash
  cd packages/dart_desk && flutter test test/testing/mock_data_source_test.dart
  ```

  Expected: all tests pass.

- [ ] **Step 6: Commit**

  ```bash
  git add lib/src/testing/mock_cms_data_source.dart test/testing/mock_data_source_test.dart
  git commit -m "feat: auto-default on create and delete in MockDataSource"
  ```

---

### Task 4: Add `setDefaultDocument` + update `deleteDocument` in CmsViewModel

**Files:**
- Modify: `lib/src/studio/core/view_models/cms_view_model.dart`

- [ ] **Step 1: Add the `collection` import**

  Open `lib/src/studio/core/view_models/cms_view_model.dart`. Add at the top if not already present:

  ```dart
  import 'package:collection/collection.dart';
  ```

- [ ] **Step 2: Add `setDefaultDocument` method**

  After the existing `createDocument` method, add:

  ```dart
  /// Sets [documentId] as the default document for the current type.
  /// Returns the updated document on success, or null on failure.
  Future<CmsDocument?> setDefaultDocument(int documentId) async {
    final docTypeName = currentDocumentType.value?.name ?? '';
    try {
      final updated =
          await dataSource.setDefaultDocument(docTypeName, documentId);
      documentsContainer(docTypeName).awaitableReload();
      return updated;
    } catch (_) {
      return null;
    }
  }
  ```

- [ ] **Step 3: Update `deleteDocument` return type to a record**

  Replace the existing `deleteDocument` method entirely with:

  ```dart
  /// Deletes [documentId]. Returns a record with:
  /// - [deleted]: whether the deletion succeeded.
  /// - [newDefault]: the document that was auto-assigned as default (if the
  ///   deleted document was the default and one other remained), or null.
  Future<({bool deleted, CmsDocument? newDefault})> deleteDocument(
    int documentId,
  ) async {
    final docTypeName = currentDocumentType.value?.name ?? '';

    // Snapshot whether this doc is currently the default
    final snapshot =
        untracked(() => documentsContainer(docTypeName).value);
    final wasDefault = snapshot.map(
      data: (d) =>
          d?.documents.any((doc) => doc.id == documentId && doc.isDefault) ??
          false,
      loading: () => false,
      error: (_, __) => false,
    );

    final result = await dataSource.deleteDocument(documentId);
    if (!result) return (deleted: false, newDefault: null);

    if (selectedDocumentId.value == documentId) {
      selectedDocumentId.value = null;
      selectedVersionId.value = null;
    }
    documentsContainer(docTypeName).awaitableReload();

    if (wasDefault) {
      try {
        final docList = await dataSource.getDocuments(docTypeName);
        final newDefault =
            docList.documents.firstWhereOrNull((d) => d.isDefault);
        return (deleted: true, newDefault: newDefault);
      } catch (_) {}
    }

    return (deleted: true, newDefault: null);
  }
  ```

- [ ] **Step 4: Commit**

  ```bash
  git add lib/src/studio/core/view_models/cms_view_model.dart
  git commit -m "feat: add setDefaultDocument and update deleteDocument return in CmsViewModel"
  ```

---

### Task 5: Update `deleteDocument` callers — shell screen and document type screen

**Files:**
- Modify: `lib/src/studio/screens/studio_shell_screen.dart`
- Modify: `lib/src/studio/screens/document_type_screen.dart`

Both files have an identical `_deleteDocument` private method. Apply the same changes to each.

- [ ] **Step 1: Update `studio_shell_screen.dart`**

  Find `_deleteDocument` in `lib/src/studio/screens/studio_shell_screen.dart`. Replace the `try` block:

  ```dart
  // BEFORE:
  try {
    final result = await viewModel.deleteDocument(docId);
    if (mounted) {
      if (result) {
        toaster.show(const ShadToast(description: Text('Document deleted')));
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
        ShadToast.destructive(description: Text('Failed to delete: $e')),
      );
    }
  }

  // AFTER:
  try {
    final result = await viewModel.deleteDocument(docId);
    if (mounted) {
      if (result.deleted) {
        toaster.show(const ShadToast(description: Text('Document deleted')));
        if (result.newDefault != null) {
          toaster.show(ShadToast(
            description:
                Text('"${result.newDefault!.title}" is now the default.'),
          ));
        }
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
        ShadToast.destructive(description: Text('Failed to delete: $e')),
      );
    }
  }
  ```

- [ ] **Step 2: Update `document_type_screen.dart`**

  Apply the identical replacement to `_deleteDocument` in `lib/src/studio/screens/document_type_screen.dart`. The only difference in the original is `context.mounted` instead of `mounted` — preserve that.

  ```dart
  // BEFORE:
  try {
    final result = await viewModel.deleteDocument(docId);
    if (context.mounted) {
      if (result) {
        toaster.show(const ShadToast(description: Text('Document deleted')));
      } else {
        toaster.show(ShadToast.destructive(
            description: const Text('Failed to delete document')));
      }
    }
  } catch (e) {
    if (context.mounted) {
      toaster.show(
          ShadToast.destructive(description: Text('Failed to delete: $e')));
    }
  }

  // AFTER:
  try {
    final result = await viewModel.deleteDocument(docId);
    if (context.mounted) {
      if (result.deleted) {
        toaster.show(const ShadToast(description: Text('Document deleted')));
        if (result.newDefault != null) {
          toaster.show(ShadToast(
            description:
                Text('"${result.newDefault!.title}" is now the default.'),
          ));
        }
      } else {
        toaster.show(ShadToast.destructive(
            description: const Text('Failed to delete document')));
      }
    }
  } catch (e) {
    if (context.mounted) {
      toaster.show(
          ShadToast.destructive(description: Text('Failed to delete: $e')));
    }
  }
  ```

- [ ] **Step 3: Build check**

  ```bash
  cd packages/dart_desk && flutter analyze lib/src/studio/screens/studio_shell_screen.dart lib/src/studio/screens/document_type_screen.dart
  ```

  Expected: no errors.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/src/studio/screens/studio_shell_screen.dart lib/src/studio/screens/document_type_screen.dart
  git commit -m "feat: handle auto-default toast in delete handlers"
  ```

---

### Task 6: Replace "Default" text with `ShadBadge` in document tile

**Files:**
- Modify: `lib/src/studio/screens/document_list.dart`

- [ ] **Step 1: Find the isDefault label in `_buildDocumentTile`**

  In `lib/src/studio/screens/document_list.dart`, find this block (around line 510):

  ```dart
  if (doc.isDefault) ...[
    Text(
      'Default',
      style: TextStyle(
        fontSize: 9,
        color: theme.colorScheme.mutedForeground,
      ),
    ),
    Text(
      ' · ',
      style: TextStyle(
        fontSize: 9,
        color: theme.colorScheme.mutedForeground,
      ),
    ),
  ],
  ```

- [ ] **Step 2: Replace with `ShadBadge`**

  Replace the block found in Step 1 with:

  ```dart
  if (doc.isDefault) ...[
    ShadBadge.secondary(
      child: const Text('Default', style: TextStyle(fontSize: 10)),
    ),
    const SizedBox(width: 6),
  ],
  ```

  `ShadBadge` is already available via `import 'package:shadcn_ui/shadcn_ui.dart';` at the top of the file.

  > **Note:** If `ShadBadge.secondary` is not available in the installed shadcn_ui version, check the package API and use the equivalent: `ShadBadge(variant: ShadBadgeVariant.secondary, child: ...)`.

- [ ] **Step 3: Hot reload check**

  Run the app via `mcp__dart__launch_app` or hot-reload if already running. Navigate to a document type with a default document. Verify the badge appears in the tile footer.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/src/studio/screens/document_list.dart
  git commit -m "feat: replace Default text with ShadBadge in document tile"
  ```

---

### Task 7: Add "Set as default" to tile overflow menu

**Files:**
- Modify: `lib/src/studio/screens/document_list.dart`

- [ ] **Step 1: Find the `PopupMenuButton` in `_buildDocumentTile`**

  In `_buildDocumentTile`, find:

  ```dart
  PopupMenuButton<String>(
    key: ValueKey('document_menu_${doc.id}'),
    padding: EdgeInsets.zero,
    iconSize: 14,
    icon: const FaIcon(
      FontAwesomeIcons.ellipsisVertical,
      size: 12,
    ),
    onSelected: (value) {
      if (value == 'delete') {
        widget.onDeleteDocument!(doc.id!);
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem<String>(
        key: const ValueKey('delete_document_button'),
        value: 'delete',
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.trashCan,
              size: 12,
              color: theme.colorScheme.destructive,
            ),
            const SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                color: theme.colorScheme.destructive,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
  ```

- [ ] **Step 2: Replace with updated version**

  Replace the entire `PopupMenuButton` widget found in Step 1 with:

  ```dart
  PopupMenuButton<String>(
    key: ValueKey('document_menu_${doc.id}'),
    padding: EdgeInsets.zero,
    iconSize: 14,
    icon: const FaIcon(
      FontAwesomeIcons.ellipsisVertical,
      size: 12,
    ),
    onSelected: (value) async {
      if (value == 'set_default') {
        final toaster = ShadToaster.of(context);
        final newDefault = await viewModel.setDefaultDocument(doc.id!);
        if (context.mounted && newDefault != null) {
          toaster.show(ShadToast(
            description:
                Text('"${newDefault.title}" is now the default.'),
          ));
        }
      } else if (value == 'delete') {
        widget.onDeleteDocument!(doc.id!);
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem<String>(
        value: 'set_default',
        enabled: !doc.isDefault,
        child: const Text(
          'Set as default',
          style: TextStyle(fontSize: 13),
        ),
      ),
      PopupMenuItem<String>(
        key: const ValueKey('delete_document_button'),
        value: 'delete',
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.trashCan,
              size: 12,
              color: theme.colorScheme.destructive,
            ),
            const SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                color: theme.colorScheme.destructive,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
  ```

- [ ] **Step 3: Verify with hot-reload**

  Hot-reload the app. Open the overflow menu on a non-default document — "Set as default" should be enabled. On the current default, it should be greyed out. Tap "Set as default" — the badge should move to the new document and a toast should appear.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/src/studio/screens/document_list.dart
  git commit -m "feat: add Set as default to document tile overflow menu"
  ```

---

### Task 8: Show auto-default toast when the first document is created

**Files:**
- Modify: `lib/src/studio/screens/document_list.dart`

- [ ] **Step 1: Find the Create button `onPressed` in `_buildInlineCreateForm`**

  In `lib/src/studio/screens/document_list.dart`, find the `ShadButton` `onPressed` callback in `_buildInlineCreateForm` — the block that calls `viewModel.createDocument(title, ..., slug: slug)`.

  The relevant section looks like:

  ```dart
  onPressed: () async {
    if (_titleController.text.trim().isNotEmpty &&
        _slugController.text.trim().isNotEmpty) {
      final title = _titleController.text.trim();
      final slug = _slugController.text.trim();

      documentViewModel.documentId.value = null;

      setState(() {
        _isCreatingNew = false;
        _titleController.clear();
        _slugController.clear();
      });

      final document = await viewModel.createDocument(
        title,
        viewModel.currentDocumentType.value?.defaultValue?.toMap() ?? {},
        slug: slug,
      );

      if (document?.id != null) {
        widget.onOpenDocument?.call(document!.id.toString());
      }
    }
  },
  ```

- [ ] **Step 2: Add toast capture before `await` and toast display after**

  Replace the `onPressed` body with:

  ```dart
  onPressed: () async {
    if (_titleController.text.trim().isNotEmpty &&
        _slugController.text.trim().isNotEmpty) {
      final title = _titleController.text.trim();
      final slug = _slugController.text.trim();

      documentViewModel.documentId.value = null;

      setState(() {
        _isCreatingNew = false;
        _titleController.clear();
        _slugController.clear();
      });

      // Capture toaster before the async gap
      final toaster = ShadToaster.of(context);

      final document = await viewModel.createDocument(
        title,
        viewModel.currentDocumentType.value?.defaultValue?.toMap() ?? {},
        slug: slug,
      );

      if (document?.id != null) {
        widget.onOpenDocument?.call(document!.id.toString());
      }
      if (document?.isDefault == true && context.mounted) {
        toaster.show(ShadToast(
          description: Text('"${document!.title}" is now the default.'),
        ));
      }
    }
  },
  ```

- [ ] **Step 3: Verify**

  Hot-reload. Delete all existing documents for a type (or use a fresh type in mock). Create the first document — a toast should appear: `"[Title]" is now the default.`

- [ ] **Step 4: Commit**

  ```bash
  git add lib/src/studio/screens/document_list.dart
  git commit -m "feat: show auto-default toast when first document is created"
  ```

---

### Task 9: Implement `setDefaultDocument` in CloudDataSource

**Files:**
- Modify: `lib/src/cloud/cloud_data_source.dart`

> **Prerequisite:** The Serverpod backend must expose `document.setDefaultDocument(String documentTypeSlug, int documentId)` before this task is testable end-to-end. Implement the backend endpoint in `dart_desk_be` (use the `serverpod` skill) first. This task only adds the frontend stub.

- [ ] **Step 1: Add `setDefaultDocument` to CloudDataSource**

  Open `lib/src/cloud/cloud_data_source.dart`. Find `updateDocument` or `deleteDocument` for placement context. Add:

  ```dart
  @override
  Future<CmsDocument> setDefaultDocument(
    String documentTypeSlug,
    int documentId,
  ) async {
    try {
      final doc = await _client.document
          .setDefaultDocument(documentTypeSlug, documentId);
      return _toCmsDocument(doc);
    } on ServerpodClientException catch (e) {
      if (e.statusCode == 401) throw CmsAuthenticationException();
      rethrow;
    }
  }
  ```

- [ ] **Step 2: Analyze**

  ```bash
  cd packages/dart_desk && flutter analyze lib/src/cloud/cloud_data_source.dart
  ```

  Expected: no errors (the `_client.document.setDefaultDocument` call will show an unresolved method until the Serverpod client is regenerated after the BE is implemented — that is expected at this stage).

- [ ] **Step 3: Commit**

  ```bash
  git add lib/src/cloud/cloud_data_source.dart
  git commit -m "feat: add setDefaultDocument to CloudDataSource"
  ```

---

### Task 10: Full analyze + run all tests

- [ ] **Step 1: Analyze the whole package**

  ```bash
  cd packages/dart_desk && flutter analyze
  ```

  Expected: no errors. Fix any issues before continuing.

- [ ] **Step 2: Run all tests**

  ```bash
  cd packages/dart_desk && flutter test
  ```

  Expected: all tests pass.

- [ ] **Step 3: Commit if any fixes were made during analyze/test**

  ```bash
  git add -p
  git commit -m "fix: resolve analyze warnings after isDefault feature"
  ```
