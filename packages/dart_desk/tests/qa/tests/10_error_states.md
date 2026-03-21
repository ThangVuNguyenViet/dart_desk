# 10 - Error States

## Prerequisites
- App is on the studio screen
- Mock data source is active

## TC-10-01: Empty document list shows message
**Steps:**
1. Select "Test All Fields" document type
2. Enter a search query that matches nothing: "xyznonexistent"
3. Call get_interactive_elements

**Expected:**
- "No documents match your search" message is visible
- Inbox icon is displayed
- No document tiles are shown

## TC-10-02: Create document with empty title fails
**Steps:**
1. Tap "+" to open create form
2. Leave title empty
3. Tap "Create"
4. Call get_interactive_elements

**Expected:**
- Document is NOT created (validation prevents it)
- Create form remains open
- The create button should not trigger if title is empty

## TC-10-03: Create document with empty slug fails
**Steps:**
1. Tap "+" to open create form
2. Enter "Test Title" in the title field
3. Clear the slug field (if auto-generated, clear it manually)
4. Tap "Create"
5. Call get_interactive_elements

**Expected:**
- Document is NOT created
- Create form remains open

## TC-10-04: Search with no results then clear
**Steps:**
1. Enter "nomatch" in search field
2. Call get_interactive_elements
3. Verify "No documents match your search" is shown
4. Clear the search field
5. Call get_interactive_elements

**Expected:**
- After step 3: Empty state message visible
- After step 5: All documents are visible again
