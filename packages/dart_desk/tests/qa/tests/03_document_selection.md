# 03 - Document Selection

## Prerequisites
- "Test All Fields" document type is selected
- Document list shows pre-seeded documents
- No document is currently selected

## TC-03-01: Tap document selects it
**Steps:**
1. Tap "Test Document Alpha"
2. Call get_interactive_elements

**Expected:**
- "Test Document Alpha" tile shows selection styling:
  - Check circle icon (Icons.check_circle) visible next to title
  - Title text color changes to primary color
- Editor panel on the right loads with document fields
- "String Field" label is visible in the editor

## TC-03-02: Switch to different document
**Steps:**
1. Tap "Test Document Beta"
2. Call get_interactive_elements

**Expected:**
- "Test Document Beta" now has check circle icon
- "Test Document Alpha" no longer has check circle icon (back to default styling)
- Editor panel updates to show Beta's data
- String field value changes to "Second Document"

## TC-03-03: Re-tap selected document does nothing
**Steps:**
1. Tap "Test Document Beta" again (already selected)
2. Call get_interactive_elements

**Expected:**
- "Test Document Beta" remains selected (no change)
- Editor panel still shows Beta's data

## TC-03-04: Selection persists after switching back
**Steps:**
1. Tap "Test Document Alpha"
2. Call get_interactive_elements
3. Tap "Test Document Beta"
4. Call get_interactive_elements

**Expected:**
- After step 2: Alpha is selected, shows Alpha's data
- After step 4: Beta is selected, shows Beta's data
- Each switch properly updates both the list indicator and editor content
