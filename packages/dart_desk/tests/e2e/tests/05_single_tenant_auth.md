# 05 - Single-Tenant Authentication

## TC-E2E-05-01: Login creates User record
**Steps:**
1. Launch the Flutter app pointing at localhost:8080
2. Connect marionette
3. Use `get_interactive_elements` to verify the sign-in screen is visible
4. Enter email: `e2e@dartdesk.dev`
5. Enter password: `e2e-password-123`
6. Tap "Sign in with email"
7. Wait for navigation to the document list
8. Query the backend API to verify the User record exists:
   `curl http://localhost:8080/api/user/getCurrentUser` (with auth header)

**Expected:**
- User is logged in and sees the document list
- User record exists in the `users` table with `tenantId = NULL`
- User has role 'admin' (seeded)

## TC-E2E-05-02: ensureUser is implicit on first API call
**Steps:**
1. After logging in (from TC-E2E-05-01), navigate to a document type
2. Create a new document
3. Verify the document has `createdByUserId` set to the current user's ID

**Expected:**
- Document creation succeeds without explicit `ensureUser` call
- The `createdByUserId` field is populated with the authenticated user's ID

## TC-E2E-05-03: Sign out and re-authenticate
**Steps:**
1. From the authenticated state, find and tap the sign-out button
2. Verify the sign-in screen appears
3. Sign in again with the same credentials
4. Verify previously created documents are still visible

**Expected:**
- Sign-out returns to the sign-in screen
- Re-authentication succeeds
- Data persists across auth sessions
