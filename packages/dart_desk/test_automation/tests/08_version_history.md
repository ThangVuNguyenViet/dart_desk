# 08 - Version History

## Prerequisites
- "Test All Fields" document type is selected
- "Test Document Alpha" is selected (has 2 versions: v1 published, v2 draft)

## TC-08-01: Version dropdown is visible
**Steps:**
1. Call get_interactive_elements
2. Look for version indicator or dropdown in the editor panel

**Expected:**
- A version indicator or dropdown is visible
- Current version number or status is displayed

## TC-08-02: Open version dropdown
**Steps:**
1. Tap the version dropdown/popover trigger
2. Call get_interactive_elements

**Expected:**
- Version list appears showing:
  - Version 2 (draft) -- most recent
  - Version 1 (published)
- Each version shows version number and status badge

## TC-08-03: Switch to older version
**Steps:**
1. Open version dropdown
2. Tap Version 1
3. Call get_interactive_elements

**Expected:**
- Editor loads Version 1's data
- String field shows "Hello World" (v1 seed value, not "Hello World (v2)")
- Version indicator updates to show v1 is selected

## TC-08-04: Switch back to latest version
**Steps:**
1. Open version dropdown
2. Tap Version 2
3. Call get_interactive_elements

**Expected:**
- Editor loads Version 2's data
- String field shows "Hello World (v2)"
- Version indicator shows v2 is selected
