# 01 - Data Persistence & Consistency

## Prerequisites
- E2E server running on port 8080 (via `setup/server_manager.sh start`)
- Docker test services running (via `setup/docker_manager.sh up`)
- Test user and API token seeded (via `setup/seed_data.sh`)
- Flutter app running with CloudDataSource pointing at http://localhost:8080/
- Marionette connected to Flutter VM service URI
- At least one document type registered

## TC-E2E-01-01: Create document persists to backend
**Steps:**
1. Navigate to a document type in the sidebar
2. Tap the "Create" or "+" button to create a new document
3. Enter a title (e.g., "Persistence Test Doc")
4. Fill in at least one field with a known value
5. Tap "Save"
6. Use `get_interactive_elements` to verify the document appears in the list
7. Query the backend API directly: `curl http://localhost:8080/api/document/getDocuments?documentType=<type>` to verify the document exists

**Expected:**
- Document appears in the UI list after save
- Document exists in the backend API response with matching title and field values
- Document has a valid ID and timestamps

## TC-E2E-01-02: Edit persists across browser refresh
**Steps:**
1. Open an existing document (created in TC-E2E-01-01 or create a new one)
2. Edit a text field to a new value (e.g., change "Hello" to "Updated Value")
3. Tap "Save" and wait for save confirmation
4. Take a screenshot to record current state
5. Trigger a page refresh (navigate away and back, or hot restart the app)
6. Reconnect marionette after restart
7. Navigate back to the same document
8. Use `get_interactive_elements` to verify the edited field

**Expected:**
- After refresh, the document loads with the updated field value
- No data loss from the edit

## TC-E2E-01-03: Version history is accurate
**Steps:**
1. Create a new document with initial content
2. Save the document
3. Edit a field and save again (creating a new state)
4. Navigate to the version history panel (if available in UI)
5. Use `get_interactive_elements` to inspect version list

**Expected:**
- Version history shows at least one version entry
- Version numbers are sequential
- Draft/published status is displayed correctly

## TC-E2E-01-04: Delete removes from backend
**Steps:**
1. Create a new document via UI
2. Note the document's title
3. Delete the document via the UI delete action
4. Verify it's gone from the UI list using `get_interactive_elements`
5. Query the backend API to verify: `curl http://localhost:8080/api/document/getDocument?documentId=<id>`

**Expected:**
- Document no longer appears in the UI list
- Backend API returns null/empty for the deleted document ID

## TC-E2E-01-05: Publish version via UI
**Steps:**
1. Create a new document and save it (creates an initial draft)
2. Navigate to the version/publishing controls in the UI
3. Tap "Publish" (or equivalent action)
4. Use `get_interactive_elements` to verify the status indicator

**Expected:**
- Version status changes to "published" in the UI
- A published timestamp is displayed
