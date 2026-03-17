# 05 - Multi-Tenancy

## Prerequisites
- E2E environment fully set up and running
- Two test clients seeded with different API tokens (Client A and Client B)
- Marionette connected

**Note:** These tests require restarting the Flutter app with different client configurations. Each test client needs its own slug and API token.

## TC-E2E-05-01: Client isolation
**Steps:**
1. Launch the Flutter app configured as Client A (with Client A's slug and API token)
2. Connect marionette
3. Create 2-3 documents as Client A
4. Use `get_interactive_elements` to verify documents are visible
5. Take a screenshot of Client A's document list
6. Stop the Flutter app
7. Relaunch the app configured as Client B (with Client B's slug and API token)
8. Connect marionette to the new instance
9. Navigate to the same document type
10. Use `get_interactive_elements` to check the document list

**Expected:**
- Client B's document list is empty (or contains only Client B's documents)
- None of Client A's documents are visible
- Document counts differ between clients

## TC-E2E-05-02: Cross-client API access
**Steps:**
1. Note a document ID from Client A (from TC-E2E-05-01)
2. While running as Client B, query the backend API directly for Client A's document:
   `curl http://localhost:8080/api/document/getDocument?documentId=<clientA_doc_id>`
3. Check the response

**Expected:**
- Returns null/404 or access denied
- Client A's data is not leaked to Client B's API context

## TC-E2E-05-03: Same slug for different clients
**Steps:**
1. Launch as Client A and create a document with slug "hello-world"
2. Save and verify creation succeeded
3. Relaunch as Client B
4. Create a document with the same slug "hello-world"
5. Verify creation succeeded

**Expected:**
- Both clients can have documents with slug "hello-world"
- No uniqueness conflict across clients
- Each client sees only their own "hello-world" document
