# 04 - Error Resilience

## Prerequisites
- E2E environment fully set up and running
- Marionette connected
- Access to `server_manager.sh` to stop/start the backend

## TC-E2E-04-01: Backend down during save
**Steps:**
1. Open a document and make an edit
2. Stop the backend server: `packages/dart_desk/tests/e2e/setup/server_manager.sh stop`
3. Attempt to save the document in the UI
4. Use `get_interactive_elements` to check for error indicators
5. Take a screenshot of the error state
6. Restart the backend: `packages/dart_desk/tests/e2e/setup/server_manager.sh start`

**Expected:**
- UI shows an error message (not a crash or blank screen)
- Unsaved changes are preserved in the form (not lost)
- No unhandled exception or app freeze

## TC-E2E-04-02: Invalid credentials / token
**Steps:**
1. Stop the Flutter app
2. Relaunch the Flutter app with invalid credentials or attempt API calls with an invalid token
3. Connect marionette to the new app instance
4. Attempt to navigate to a document type
5. Use `get_interactive_elements` to check for auth error indicators

**Expected:**
- App shows an authentication error message
- User cannot access documents or create content
- App does not crash

## TC-E2E-04-03: Operate on deleted document
**Steps:**
1. Open a document in the UI
2. Delete the same document via direct API call: `curl -X POST http://localhost:8080/api/document/deleteDocument -d '{"documentId": <id>}'`
3. Attempt to edit or save the document in the UI
4. Use `get_interactive_elements` to check for error handling

**Expected:**
- UI shows a graceful error (e.g., "Document not found" or similar)
- App redirects to the document list or shows an appropriate state
- No crash or unhandled exception

## TC-E2E-04-04: Backend restart recovery
**Steps:**
1. Open a document and verify it loads correctly
2. Stop the backend: `packages/dart_desk/tests/e2e/setup/server_manager.sh stop`
3. Wait 3 seconds
4. Restart the backend: `packages/dart_desk/tests/e2e/setup/server_manager.sh start`
5. Navigate to the document list
6. Open the same document

**Expected:**
- App recovers from the temporary backend outage
- Data is still accessible after restart
- No permanent error state
