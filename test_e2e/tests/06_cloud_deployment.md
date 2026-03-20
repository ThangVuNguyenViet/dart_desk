# 06 - Cloud Deployment E2E

## Prerequisites
- E2E environment fully set up and running (Docker + Serverpod)
- Seed data applied (including manage app auth user: `e2e@dartdesk.dev` / `e2e-password-123`)
- Manage app launched in Chrome pointed at localhost:8080
- Marionette connected to manage app's VM service
- `dart_desk.yaml` present in `dart_desk/examples/cms_app/` (slug: `e2e-deploy-test`, server: `http://localhost:8080`)

## Phase 1: Manage App — Login + Create Project + API Token

### TC-E2E-06-01: Login to manage app
**Steps:**
1. Use `get_interactive_elements` to verify the login screen is visible (email field, password field, "Sign In" button)
2. Tap the email input field, enter `e2e@dartdesk.dev`
3. Tap the password input field, enter `e2e-password-123`
4. Tap "Sign In"
5. Wait for navigation — expect either client picker/setup wizard or overview screen

**Expected:**
- Login succeeds, user is authenticated
- Redirected to setup wizard (no clients yet) or client picker

### TC-E2E-06-02: Create a new project
**Steps:**
1. If on setup wizard: tap "Create New Project" (or equivalent)
2. Enter project name: `E2E Deploy Test`
3. Verify the slug auto-generates to `e2e-deploy-test`
4. Tap "Create Project"
5. Wait for redirect to overview screen

**Expected:**
- Project is created successfully
- Overview screen shows project name "E2E Deploy Test"
- Slug is `e2e-deploy-test`

### TC-E2E-06-03: Create an API token
**Steps:**
1. Tap the "API" tab
2. Tap "Add API Token"
3. Enter token name: `Deploy Token`
4. Tap the "Admin" role card to select it
5. Tap "Create Token"
6. In the token reveal dialog, use `get_interactive_elements` to read the token value from the selectable text widget
7. **Save the token value** — it will be used for CLI deployment
8. Tap "Done"
9. Take a screenshot

**Expected:**
- Token is created and displayed in reveal dialog
- Token value starts with `cms_ad_` (admin prefix)
- After dismissing dialog, token appears in the table with name "Deploy Token", role "Admin", status "Active"

## Phase 2: CLI Deploy

### TC-E2E-06-04: Build and deploy via CLI
**Steps:**
1. Verify `dart_desk/examples/cms_app/dart_desk.yaml` exists with content:
   ```yaml
   slug: e2e-deploy-test
   server: http://localhost:8080
   ```
2. Run: `cd dart_desk/examples/cms_app && flutter build web --release`
3. Wait for build to complete successfully
4. Run: `dart run dart_desk_cli deploy --token {captured_token} --skip-build`
5. Capture stdout

**Expected:**
- Build completes without errors
- CLI deploy output contains "Deployed v1" (or similar success message)
- Output includes the URL `http://localhost:8082/preview/e2e-deploy-test/`

## Phase 3: Preview Route Verification

### TC-E2E-06-05: Preview route serves index.html with rewritten base href
**Steps:**
1. Run: `curl -s http://localhost:8082/preview/e2e-deploy-test/`
2. Inspect the response body

**Expected:**
- HTTP 200
- Response contains `<base href="/preview/e2e-deploy-test/">`
- Response does NOT contain `<base href="/">`
- Response is valid HTML containing Flutter web bootstrap (`flutter_service_worker.js` or `main.dart.js` reference)

### TC-E2E-06-06: Preview route serves static assets
**Steps:**
1. Run: `curl -sI http://localhost:8082/preview/e2e-deploy-test/main.dart.js`
2. Run: `curl -sI http://localhost:8082/preview/e2e-deploy-test/flutter_service_worker.js`

**Expected:**
- Both return HTTP 200
- `main.dart.js` response has `content-type: application/javascript` (or similar JS MIME type)
- Assets are served verbatim (no base href rewriting on non-HTML files)

### TC-E2E-06-07: Preview route SPA fallback serves rewritten index.html
**Steps:**
1. Run: `curl -s http://localhost:8082/preview/e2e-deploy-test/some/deep/route`
2. Inspect the response body

**Expected:**
- HTTP 200 (not 404)
- Response contains `<base href="/preview/e2e-deploy-test/">`
- Response is the same rewritten index.html (SPA fallback)

### TC-E2E-06-08: Preview route returns 404 for nonexistent slug
**Steps:**
1. Run: `curl -s http://localhost:8082/preview/nonexistent-slug/`
2. Inspect the response body

**Expected:**
- HTTP 404
- Response contains "Studio Not Found"
- Response contains "nonexistent-slug"

## Phase 4: Manage App — Verify Deployments Tab

### TC-E2E-06-09: Verify deployment appears in manage app
**Steps:**
1. Switch back to the manage app browser tab
2. Tap "Deployments" tab
3. Use `get_interactive_elements` to inspect the deployments table
4. Verify the following elements are present:
   - "v1" text in the version column
   - "active" status badge
   - "Current" text (indicating it's the active deployment)
5. Verify "Activate" button is NOT present (current deployment doesn't need activation)
6. Verify "Open Live Site" button is present
7. Take a screenshot

**Expected:**
- Deployments table shows exactly one row with version "v1"
- Status is "active" and shows "Current" label
- "Open Live Site" button opens `http://localhost:8082/preview/e2e-deploy-test/`

## Phase 5: Manage App — Verify Open Studio URL

### TC-E2E-06-10: Verify Open Studio URL on overview
**Steps:**
1. Tap "Overview" tab
2. Use `get_interactive_elements` to find the "Open Studio" button in the quick links section
3. Take a screenshot

**Expected:**
- "Open Studio" button is present
- Clicking it would open `http://localhost:8082/preview/e2e-deploy-test/`

### TC-E2E-06-11: Verify Open Studio URL in top bar
**Steps:**
1. Use `get_interactive_elements` to find the "Open Studio" button in the top navigation bar
2. Take a screenshot

**Expected:**
- Top bar "Open Studio" button is present
- Clicking it would open `http://localhost:8082/preview/e2e-deploy-test/`

## Phase 6: Deploy v2 + Verify Rollback

### TC-E2E-06-12: Deploy v2 via CLI
**Steps:**
1. Run CLI deploy again: `cd dart_desk/examples/cms_app && dart run dart_desk_cli deploy --token {captured_token} --skip-build`
2. Capture stdout

**Expected:**
- CLI deploy output contains "Deployed v2" (or similar success for version 2)
- Output includes the URL `http://localhost:8082/preview/e2e-deploy-test/`

### TC-E2E-06-13: Verify v2 is active and v1 can be rolled back
**Steps:**
1. Switch to manage app
2. Tap "Deployments" tab (or refresh if already there)
3. Use `get_interactive_elements` to inspect the table
4. Verify:
   - "v2" row shows "active" status and "Current" label
   - "v1" row shows "inactive" status and has an "Activate" button
5. Take a screenshot

**Expected:**
- Two deployment rows visible: v2 (active/current) and v1 (inactive)
- v1 has an "Activate" button for rollback
- v2 does NOT have an "Activate" button (it's current)

### TC-E2E-06-14: Rollback to v1
**Steps:**
1. Tap "Activate" on the v1 row
2. Wait for the activation to complete
3. Use `get_interactive_elements` to verify the table updated:
   - v1 is now "active" with "Current" label
   - v2 is now "inactive" with "Activate" button
4. Take a screenshot

**Expected:**
- v1 successfully activated (rolled back)
- v2 becomes inactive
- The active deployment version changed from v2 to v1

### TC-E2E-06-15: Verify preview route serves rolled-back version
**Steps:**
1. Run: `curl -s http://localhost:8082/preview/e2e-deploy-test/`
2. Inspect the response body

**Expected:**
- HTTP 200
- Response contains `<base href="/preview/e2e-deploy-test/">`
- Preview route serves the v1 deployment (rollback took effect)
