# 09 - Panel Layout

## Prerequisites
- App is on the studio screen
- A document type is registered

## TC-09-01: All panels are present
**Steps:**
1. Call get_interactive_elements

**Expected:**
- Sidebar panel exists (contains document type items, x < 310)
- Document list panel exists (contains "Search documents..." or document type header)
- Editor panel exists (rightmost, contains form fields or empty state)
- GestureDetector separators exist between panels (the draggable dividers)

## TC-09-02: Sidebar empty state when no type selected
**Steps:**
1. If possible, navigate to a state with no document type selected
2. Call get_interactive_elements

**Expected:**
- Document list shows "Select a document type" message
- Or document list shows the first type auto-selected

**Note:** If the app auto-selects the first document type on load, this empty state may not be reachable. Mark as SKIPPED if so.

## TC-09-03: Editor empty state when no document selected
**Steps:**
1. Ensure a document type is selected but no document is selected
2. Call get_interactive_elements

**Expected:**
- Editor panel shows empty state message (e.g., "Select a document" or similar)
- No form fields are visible in the editor
