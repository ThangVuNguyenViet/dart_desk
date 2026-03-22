# 15 — Context-Aware Dropdown & Simplified Document Container

Validates the two changes from the preview-context plan:
1. `CmsDropdownOption.options(BuildContext)` — the API accepts context (backward-compatible for `CmsDropdownSimpleOption`)
2. `documentsContainer` keyed on `String documentType` — document list loads, search filters client-side, CRUD reloads the list

## Prerequisites

- CMS QA Test app running (`main_test.dart`) with MockDataSource
- Marionette connected
- `allFieldsDocumentType` loaded (has 3 seed documents + a static dropdown field)

---

## TC-15-01: Document list loads with simplified container

**Steps:**
1. Tap "Test All Fields" in the sidebar to select the document type
2. Verify the document list panel shows all 3 seeded documents: "Test Document Alpha", "Test Document Beta", "Test Document Gamma"

**Expected:** All 3 documents are visible in the list.

---

## TC-15-02: Client-side search filters documents

**Steps:**
1. With "Test All Fields" selected, locate the search input ("Search documents...")
2. Enter "Alpha" in the search field
3. Verify only "Test Document Alpha" is visible; Beta and Gamma are hidden

**Expected:** Client-side filtering reduces the list to matching documents only.

---

## TC-15-03: Clearing search restores full list

**Steps:**
1. Clear the search field (enter empty string or delete text)
2. Verify all 3 documents are visible again

**Expected:** Full document list is restored after clearing search.

---

## TC-15-04: Static dropdown field still works (CmsDropdownSimpleOption backward compat)

**Steps:**
1. Tap "Test Document Alpha" to open it in the editor
2. Scroll to the "Dropdown Field" in the form
3. Verify the dropdown shows the current value "Option A" (seed data: `option_a`)
4. Open the dropdown and verify all 3 options appear: "Option A", "Option B", "Option C"
5. Select "Option B"
6. Verify the dropdown now shows "Option B"

**Expected:** Static dropdown field works exactly as before with the new `options(BuildContext)` API.

---

## TC-15-05: Create document updates the list

**Steps:**
1. Tap the "+" button in the document list header to open inline create form
2. Enter "Test Document Delta" as the title
3. Wait for slug auto-generation
4. Tap "Create"
5. Verify "Test Document Delta" appears in the document list

**Expected:** New document appears in the list (proving `documentsContainer.reload()` works after create).

---

## TC-15-06: Delete document updates the list

**Steps:**
1. Locate "Test Document Delta" in the list
2. Open its context menu (three-dot icon)
3. Tap "Delete"
4. Verify "Test Document Delta" is no longer in the list
5. Verify the other 3 documents are still present

**Expected:** Deleted document disappears from the list (proving container reload after delete).
