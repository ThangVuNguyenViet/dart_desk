# 16 — Context-Aware Dropdown E2E (Marionette)

Validates that a `CmsDropdownOption` subclass using `documentsContainer.watch(context)`
resolves options reactively in the running app.

## Prerequisites

- CMS QA Test app running (`main_test.dart`) with MockDataSource
- Marionette connected
- `allFieldsDocumentType` loaded with `TestDocumentRefDropdownOption` field

---

## TC-16-01: Context-aware dropdown loads document titles as options

**Steps:**
1. Tap "Test Document Alpha" to open it in the editor
2. Scroll to "Document Reference" field
3. Verify the dropdown shows placeholder "Select a document..."
4. Open the dropdown
5. Verify 3 options appear: "Test Document Alpha", "Test Document Beta", "Test Document Gamma"

**Expected:** The dropdown resolved its options from `documentsContainer('test_all_fields').watch(context)`.

---

## TC-16-02: Selecting a document reference persists to preview

**Steps:**
1. With the "Document Reference" dropdown open, select "Test Document Beta"
2. Verify the dropdown now shows "Test Document Beta"
3. Check the preview panel shows `preview:document_ref_dropdown: 2` (Beta's ID)

**Expected:** Selection persists to editedData and preview updates reactively.

---

## TC-16-03: Creating a document adds it to the context-aware dropdown

**Steps:**
1. Discard unsaved changes
2. Tap "+" to open the create form
3. Create a new document "Test Document Delta"
4. After creation, tap "Test Document Alpha" to re-open it
5. Scroll to "Document Reference" and open the dropdown
6. Verify 4 options now appear, including "Test Document Delta"

**Expected:** The context-aware dropdown reactively picks up the new document
because `documentsContainer('test_all_fields')` was reloaded after create.

---

## TC-16-04: Deleting a document removes it from the context-aware dropdown

**Steps:**
1. Close the dropdown
2. Delete "Test Document Delta" via its context menu
3. Re-open the "Document Reference" dropdown on Alpha
4. Verify only 3 options remain (Delta is gone)

**Expected:** The dropdown reactively updates when the backing document list changes.
