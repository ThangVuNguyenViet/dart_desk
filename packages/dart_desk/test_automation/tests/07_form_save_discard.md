# 07 - Form Save/Discard

## Prerequisites
- "Test All Fields" document type is selected
- "Test Document Alpha" is selected
- Editor panel shows the document's fields

## TC-07-01: Save and Discard buttons are visible
**Steps:**
1. Call get_interactive_elements

**Expected:**
- "Save" button is visible at the bottom of the editor
- "Discard" button is visible at the bottom of the editor

## TC-07-02: Edit field then save
**Steps:**
1. Find the string field and clear it
2. Enter "Saved Value" in the string field
3. Verify the preview panel shows "preview:string_field: Saved Value" (live update before save)
4. Tap "Save"
5. Call get_interactive_elements

**Expected:**
- Preview shows "preview:string_field: Saved Value" before save (live update)
- After save, no error messages appear
- String field still shows "Saved Value" (persisted)
- Preview still shows "preview:string_field: Saved Value" after save

## TC-07-03: Edit field then discard
**Steps:**
1. Find the string field
2. Clear it and enter "Temporary Value"
3. Verify the preview panel shows "preview:string_field: Temporary Value" (live update)
4. Tap "Discard"
5. Call get_interactive_elements

**Expected:**
- Preview shows "preview:string_field: Temporary Value" before discard (live update)
- After discard, string field reverts to its previous value
- Preview reverts to show the original value (e.g. "preview:string_field: Hello World")

## TC-07-04: Multiple edits then discard reverts all
**Steps:**
1. Edit the string field to "Change 1"
2. Toggle the boolean field
3. Tap "Discard"
4. Call get_interactive_elements

**Expected:**
- String field reverts to original value
- Boolean field reverts to original state
- All changes are discarded

## TC-07-05: Save shows loading state
**Steps:**
1. Edit any field
2. Tap "Save"
3. Immediately call get_interactive_elements

**Expected:**
- During save, a loading indicator may be visible
- Save button may be disabled during the operation
- After save completes, buttons return to normal state

**Note:** The mock data source is instant, so the loading state may be too brief to capture. If not observable, mark as SKIPPED with note "Mock too fast to observe loading state"
