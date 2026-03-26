# 08 - API Token Lifecycle

Context: Tests the full API token lifecycle in the **manage app** (`dart_desk_cloud/dart_desk_manage`). Tokens authenticate CMS app and API requests via the `x-api-key` header. The manage app uses shadcn_ui dialogs for token creation and reveal.

## TC-E2E-08-01: Create a read token and verify reveal dialog

**Steps:**
1. Connect Marionette to the manage app
2. Navigate to the Tokens screen
3. `get_interactive_elements` — verify "API Tokens" header and "Add API Token" button visible
4. Tap "Add API Token"
5. `get_interactive_elements` — verify "Create API Token" dialog appears
6. Enter token name: `E2E Read Token`
7. Tap the "Viewer" role card (read-only access)
8. Tap "Create Token"
9. `get_interactive_elements` — verify TokenRevealDialog appears with:
   - Title containing "Token Created: E2E Read Token"
   - Warning text "Copy the token below"
   - A monospace token value starting with `cms_r_`
10. `take_screenshots` — capture the reveal dialog
11. Read the token value from the SelectableText element
12. Tap "Done" to dismiss the reveal dialog

**Expected:**
- Token reveal dialog shows plaintext token starting with `cms_r_` (49 characters total)
- After dismissing, the token table shows "E2E Read Token" with role "Viewer" and status "Active"
- Token prefix/suffix displayed in monospace in the table row
- Backend confirms token exists:
  ```
  curl -H "x-api-key: <seeded-admin-token>" http://localhost:8080/api/apiToken/getTokens
  ```

## TC-E2E-08-02: Create a write token and verify it works in CMS app

**Steps:**
1. From the Tokens screen, tap "Add API Token"
2. Enter token name: `E2E Write Token`
3. Tap the "Editor" role card (read & write)
4. Tap "Create Token"
5. Read the plaintext token from the reveal dialog (should start with `cms_w_`)
6. Tap "Done"
7. Verify the token table now shows 2 tokens
8. Launch the CMS app with the new token:
   ```
   flutter run --dart-define=API_KEY=cms_w_<token>
   ```
9. Connect a second Marionette session to the CMS app
10. Sign in with `e2e@dartdesk.dev` / `e2e-password-123`
11. `get_interactive_elements` — verify the document list loads (no 401 errors)
12. Create a new document to confirm write access works

**Expected:**
- CMS app authenticates successfully with the write token
- Document list loads without "Missing x-api-key" or "Invalid API key" errors
- Document creation succeeds (write permission granted)

## TC-E2E-08-03: Deactivate token and verify CMS app rejects requests

**Steps:**
1. In the manage app Tokens screen, locate "E2E Write Token" row
2. Tap the actions menu (ellipsis icon) on that row
3. Tap "Deactivate"
4. `get_interactive_elements` — verify status badge changes from "Active" to "Inactive"
5. `take_screenshots` — capture the deactivated state
6. In the CMS app (still connected), attempt to create a new document
7. `get_logs` — check for 401 / "Invalid API key" error

**Expected:**
- Token status shows "Inactive" in the table
- CMS app requests fail with 401 after deactivation
- Backend rejects the token:
  ```
  curl -H "x-api-key: cms_w_<token>" http://localhost:8080/api/document/getDocuments
  # → 401 {"error":"Invalid API key"}
  ```

## TC-E2E-08-04: Reactivate token and verify CMS app works again

**Steps:**
1. In the manage app, tap the actions menu on "E2E Write Token"
2. Tap "Activate"
3. `get_interactive_elements` — verify status returns to "Active"
4. In the CMS app, retry creating a document

**Expected:**
- Token status shows "Active" again
- CMS app requests succeed after reactivation

## TC-E2E-08-05: Regenerate token — old token stops working, new one works

**Steps:**
1. In the manage app, tap the actions menu on "E2E Write Token"
2. Tap "Regenerate"
3. `get_interactive_elements` — verify confirmation dialog appears with warning text
4. Tap "Confirm"
5. Verify TokenRevealDialog appears with a new plaintext token
6. Read the new token value (should start with `cms_w_`)
7. Tap "Done"
8. In the CMS app (still using the old token), attempt an API call
9. `get_logs` — verify 401 error (old token invalidated)
10. Relaunch CMS app with the new token
11. Verify document list loads successfully

**Expected:**
- Regeneration shows confirmation dialog before proceeding
- New token is different from the old one
- Old token immediately stops working (401)
- New token authenticates successfully
- Token table still shows same name, but prefix/suffix have changed

## TC-E2E-08-06: Delete token

**Steps:**
1. In the manage app, tap the actions menu on "E2E Read Token"
2. Tap "Delete"
3. `get_interactive_elements` — verify confirmation dialog with "Are you sure you want to delete"
4. Tap "Confirm"
5. `get_interactive_elements` — verify "E2E Read Token" is no longer in the table
6. Verify backend confirms deletion:
   ```
   curl -H "x-api-key: <seeded-admin-token>" http://localhost:8080/api/apiToken/getTokens
   ```

**Expected:**
- Confirmation dialog shown before deletion
- Token removed from the table
- Backend no longer returns the deleted token
- Only "E2E Write Token" (regenerated) remains

## TC-E2E-08-07: Empty state after deleting all tokens

**Steps:**
1. Delete the remaining "E2E Write Token" (actions menu → Delete → Confirm)
2. `get_interactive_elements` — verify empty state appears
3. `take_screenshots` — capture the empty state

**Expected:**
- Empty state shows key icon, "No API Tokens" heading
- "Create your first API token" description text visible
- "Add API Token" button available in the empty state
