# 02 - Document CRUD

## Prerequisites
- "Test All Fields" document type is selected in the sidebar
- Document list is visible with 3 pre-seeded documents

## TC-02-01: Open create document form
**Steps:**
1. Tap the "+" button (ShadIconButton in document list header)
2. Call get_interactive_elements

**Expected:**
- Inline create form appears at the top of the document list
- "Create New Document" title is visible
- "Document title" placeholder input is visible
- "slug (auto-generated)" placeholder input is visible
- "Cancel" and "Create" buttons are visible

## TC-02-02: Cancel create form
**Steps:**
1. Tap "+" to open create form (if not open)
2. Tap "Cancel"
3. Call get_interactive_elements

**Expected:**
- Create form disappears
- Document list shows the original 3 documents

## TC-02-03: Create a new document
**Steps:**
1. Tap "+" to open create form
2. Enter "New QA Document" in the "Document title" field
3. Wait 1 second for slug auto-generation
4. Call get_interactive_elements to verify slug field populated
5. Tap "Create"
6. Call get_interactive_elements

**Expected:**
- After step 4: slug field shows "new-qa-document" (or similar auto-generated value)
- After step 6: Create form disappears
- "New QA Document" appears in the document list
- Document list now has 4 documents

## TC-02-04: Search documents
**Steps:**
1. Enter "Alpha" in the "Search documents..." field
2. Call get_interactive_elements

**Expected:**
- Only "Test Document Alpha" is visible in the document list
- "Test Document Beta" and "Test Document Gamma" are NOT visible

## TC-02-05: Clear search shows all documents
**Steps:**
1. Clear the search field (enter empty text in "Search documents..." or the current search text)
2. Call get_interactive_elements

**Expected:**
- All documents are visible again (3 or 4 depending on whether TC-02-03 ran)

## TC-02-06: Delete a document
**Steps:**
1. Select "Test Document Gamma" by tapping it
2. Look for a delete action (button or menu item)
3. If delete is available, tap it
4. Call get_interactive_elements

**Expected:**
- "Test Document Gamma" is removed from the document list
- If the deleted document was selected, the editor panel shows empty/no selection state

**Note:** If delete is not exposed in the UI, mark this test as SKIPPED with note "Delete not available in document list UI"
