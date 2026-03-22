# 16 — Context-Aware Multi-Select Dropdown E2E (Marionette)

Validates that a `CmsMultiDropdownOption` subclass using `documentsContainer.watch(context)`
resolves options reactively in the running app with multi-select support.

## Prerequisites

- CMS QA Test app running (`main_test.dart`) with MockDataSource
- Marionette connected
- `allFieldsDocumentType` loaded with `TestDocumentRefDropdownOption` field (multi-select)

---

## TC-16-01: Context-aware multi-dropdown loads document titles as options

**Steps:**
1. Tap "Test Document Alpha" to open it in the editor
2. Scroll to "Document Reference" field
3. Verify the dropdown shows placeholder "Select documents..."
4. Open the dropdown
5. Verify 3 options appear: "Test Document Alpha", "Test Document Beta", "Test Document Gamma"
6. Verify dropdown stays open after selection (closeOnSelect: false)

**Expected:** The multi-dropdown resolved its options from `documentsContainer('test_all_fields').watch(context)`.

**Result:** PASS (2026-03-22) — Placeholder "Select documents..." confirmed, 3 options loaded, dropdown stays open after selection.

---

## TC-16-02: Selecting multiple document references persists to preview

**Steps:**
1. With the "Document Reference" dropdown open, select "Test Document Alpha" and "Test Document Beta"
2. Verify the dropdown shows "Test Document Alpha, Test Document Beta"
3. Check the preview panel shows `preview:document_ref_dropdown: [1, 2] (Test Document Alpha, Test Document Beta)`

**Expected:** Multi-selection persists to editedData as List and preview updates reactively with all titles.

**Result:** PASS (2026-03-22) — Selected Alpha and Beta, preview shows `[1, 2] (Test Document Alpha, Test Document Beta)`. Dropdown remained open between selections.

---

## TC-16-03: Creating a document adds it to the context-aware multi-dropdown

**Steps:**
1. Discard unsaved changes
2. Tap "+" to open the create form
3. Create a new document "Test Document Delta"
4. After creation, tap "Test Document Alpha" to re-open it
5. Scroll to "Document Reference" and open the dropdown
6. Verify 4 options now appear, including "Test Document Delta"

**Expected:** The context-aware multi-dropdown reactively picks up the new document
because `documentsContainer('test_all_fields')` was reloaded after create.

**Result:** PASS (2026-03-22) — Created "Test Document Delta", dropdown showed 4 options including Delta.

---

## TC-16-04: Deleting a document removes it from the context-aware multi-dropdown

**Steps:**
1. Close the dropdown
2. Delete "Test Document Delta" via its context menu
3. Re-open the "Document Reference" dropdown on Alpha
4. Verify only 3 options remain (Delta is gone)

**Expected:** The multi-dropdown reactively updates when the backing document list changes.

**Result:** PASS (2026-03-22) — Deleted Delta, dropdown back to 3 options (Alpha, Beta, Gamma).
