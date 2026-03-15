# 06 - Field Types Complex

## Prerequisites
- "Test All Fields" document type is selected
- "Test Document Alpha" is selected
- Editor panel is visible

## TC-06-01: Array field displays items
**Steps:**
1. Scroll to "Array Field"
2. Call get_interactive_elements

**Expected:**
- "Array Field" label is visible
- 3 items are listed: "Item 1", "Item 2", "Item 3" (seed data)
- Each item has a delete button
- "Add" button is visible

## TC-06-02: Array field add item
**Steps:**
1. Scroll to "Array Field"
2. Tap the "Add" button
3. Call get_interactive_elements
4. Enter "Item 4" in the new item's input field
5. Call get_interactive_elements

**Expected:**
- A new empty item input appears after tapping Add
- After entering text, 4 items are in the list

## TC-06-03: Array field remove item
**Steps:**
1. Find the delete button for "Item 3"
2. Tap the delete button
3. Call get_interactive_elements

**Expected:**
- "Item 3" is removed from the list
- Remaining items are still visible

## TC-06-04: Object field displays nested fields
**Steps:**
1. Scroll to "Object Field"
2. Call get_interactive_elements

**Expected:**
- "Object Field" label is visible
- Nested fields are visible:
  - "Nested Title" with value "Nested Value"
  - "Nested Count" with value "10"

## TC-06-05: Geopoint field displays coordinates
**Steps:**
1. Scroll to "Geopoint Field"
2. Call get_interactive_elements

**Expected:**
- "Geopoint Field" label is visible
- Latitude input shows "37.7749" (seed value)
- Longitude input shows "-122.4194" (seed value)

## TC-06-06: Preview reflects live field data
**Steps:**
1. Call get_interactive_elements
2. Verify the preview panel shows seed data values (e.g. "preview:string_field: Hello World")
3. Verify the preview panel shows "preview:array_field:" with the array data
4. Verify the preview panel shows "preview:geopoint_field:" with the geopoint data

**Expected:**
- Preview panel renders all field values from the current edited data
- Text elements with "preview:{field_name}:" prefix are visible for each field
