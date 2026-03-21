# 03 - CRDT & Collaboration

## Prerequisites
- E2E environment fully set up and running
- Marionette connected
- Ability to open two browser tabs/windows to the same document

**Note:** These tests require opening the same document in two separate browser sessions. This may require launching a second Chrome instance or using two tabs. Marionette can only connect to one Flutter app at a time, so verification may alternate between sessions.

## TC-E2E-03-01: Two sessions editing different fields
**Steps:**
1. Create a document with at least two editable fields (e.g., title + description)
2. Open the document in Session A
3. Open the same document in Session B (second browser tab)
4. In Session A, edit Field 1 (e.g., change title to "Session A Title")
5. Save in Session A
6. In Session B, edit Field 2 (e.g., change description to "Session B Description")
7. Save in Session B
8. Reload the document in both sessions
9. Verify both changes are present

**Expected:**
- Field 1 has Session A's value
- Field 2 has Session B's value
- No data loss from either session

## TC-E2E-03-02: Two sessions editing same field
**Steps:**
1. Open the same document in two sessions
2. In Session A, edit a text field to "Value A"
3. In Session B, edit the same text field to "Value B"
4. Save Session A first, then save Session B
5. Reload the document

**Expected:**
- The field contains "Value B" (last write wins)
- No crash, error dialog, or data corruption
- Other fields remain unchanged

## TC-E2E-03-03: Rapid sequential edits
**Steps:**
1. Open a document
2. Make 5+ rapid edits to the same field (type, delete, type again)
3. Save the document
4. Reload the document

**Expected:**
- Final state matches the last edit
- No partial or corrupted data
- CRDT operations are ordered correctly (verify via backend API if needed)
