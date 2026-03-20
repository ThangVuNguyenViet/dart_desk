# Integration Testing Execution Plan

> **For agentic workers:** Use `superpowers:subagent-driven-development` to execute this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Execute all integration tests (backend + E2E), fix bugs found during test runs, and produce a passing test suite.

**Source Plan:** `docs/superpowers/plans/2026-03-17-integration-testing.md`
**Spec:** `docs/superpowers/specs/2026-03-17-integration-testing-design.md`

---

## Agent Configuration

| Agent | Model | Isolation | Purpose |
|-------|-------|-----------|---------|
| backend-test-runner | sonnet | worktree | Run backend integration tests, report failures |
| e2e-test-runner | sonnet | none (needs marionette MCP) | Run E2E tests sequentially via marionette — **single session only** |
| bug-fixer | opus | worktree | Fix bugs found by test runners |

### Constraints
- **E2E agent must be single-threaded** — only 1 marionette MCP session can interact with 1 Flutter app at a time. Run E2E test specs sequentially (01 → 02 → 03 → 04 → 05).
- **Bug-fixer receives failure reports** from test runners and fixes them. After fixing, the relevant test runner re-runs to verify.
- Backend tests and E2E tests are independent — they can run in parallel.

---

## Phase 1: Backend Integration Tests

### Task 1: Run All Backend Integration Tests

**Agent:** backend-test-runner (sonnet, worktree)

**Prerequisites:** Docker must be running.

- [ ] **Step 1: Start Docker test services**
```bash
cd flutter_cms_be/flutter_cms_be_server
docker compose up -d postgres_test redis_test
until docker compose exec -T postgres_test pg_isready -U postgres; do sleep 1; done
```

- [ ] **Step 2: Run all integration tests**
```bash
cd flutter_cms_be/flutter_cms_be_server
dart test test/integration/ --tags integration --concurrency=1
```

- [ ] **Step 3: Report results**
Produce a structured report:
```
## Backend Test Results
- Total: X tests
- Passed: X
- Failed: X
- Failures:
  - [test file]:[test name] — [error message + stack trace snippet]
```

If all pass → Phase 1 complete.
If failures → send each failure to **bug-fixer** agent with:
  - The failing test file path
  - The error message and stack trace
  - The endpoint source file being tested (from `lib/src/endpoints/`)

- [ ] **Step 4: After bug fixes, re-run failing tests to verify**

---

## Phase 2: E2E Tests (Sequential, Single Marionette Session)

### Task 2: E2E Environment Setup

**Agent:** e2e-test-runner (sonnet, **no worktree** — needs marionette MCP access)

- [ ] **Step 1: Start Docker + backend server**
```bash
cd flutter_cms/test_e2e/setup
bash docker_manager.sh up
bash server_manager.sh start
```

- [ ] **Step 2: Seed test data**
```bash
bash seed_data.sh
```
Note the API token from output.

- [ ] **Step 3: Launch Flutter app** (as Client A)
Use `mcp__dart__launch_app` with:
- `root`: `flutter_cms/examples/cms_app`
- `device`: `chrome`
- `target`: `lib/main_e2e.dart`

Defaults (server=localhost:8080, client=e2e-client-a, token) are baked into `main_e2e.dart` — no `--dart-define` needed.

- [ ] **Step 4: Connect marionette**
Use `mcp__marionette__connect` with the VM service URI.

- [ ] **Step 5: Sign in via marionette**
The app launches to the sign-in screen. The E2E agent must sign in using marionette:
1. Use `enter_text` to type the E2E test email into the Email field
2. Use `enter_text` to type the E2E test password into the Password field
3. Use `tap` to tap "Sign in with email"

### Task 3: Run E2E Test Specs (Sequential)

**Agent:** e2e-test-runner (same session as Task 2)

Run each test spec one at a time. For each spec:
1. Read the spec file from `test_e2e/tests/`
2. Execute each test case using marionette tools (tap, enter_text, scroll_to, take_screenshots, get_interactive_elements)
3. Record PASS/FAIL for each test case
4. Take screenshots on failure

**Important:** Between test specs, clean up test data if needed (create fresh documents, etc.)

- [ ] **Step 1: Run 01_data_persistence.md**
- [ ] **Step 2: Run 02_media_handling.md**
- [ ] **Step 3: Run 03_crdt_collaboration.md**
- [ ] **Step 4: Run 04_error_resilience.md**
- [ ] **Step 5: Run 05_multi_tenancy.md**

- [ ] **Step 6: Report results**
Produce a structured report:
```
## E2E Test Results
- Spec: 01_data_persistence
  - TC-E2E-01-01: PASS/FAIL [details]
  - TC-E2E-01-02: PASS/FAIL [details]
  ...
- Spec: 02_media_handling
  ...
```

Save report to `test_e2e/results/reports/YYYY-MM-DD-HHMM.md`.

If failures → send each failure to **bug-fixer** agent with:
  - The test case ID and description
  - What happened vs what was expected
  - Screenshots (file paths)
  - Relevant source files (frontend widget or backend endpoint)

- [ ] **Step 7: After bug fixes, hot-reload and re-run failing test cases**

### Task 4: E2E Teardown & Data Cleanup

- [ ] **Step 1: Stop Flutter app**
- [ ] **Step 2: Stop server**
```bash
cd flutter_cms/test_e2e/setup
bash server_manager.sh stop
```
- [ ] **Step 3: Clean up test data** (truncates documents, versions, CRDT data, media — preserves clients, users, tokens)
```bash
bash docker_manager.sh reset
```
- [ ] **Step 4: Stop Docker** (or leave running if re-running tests)
```bash
bash docker_manager.sh down
```

**Note:** `docker_manager.sh reset` truncates document-related tables only. Client, user, and API token data is preserved so you don't need to re-seed auth on the next run.

---

## Phase 3: Bug Fixing

### Task 5: Fix Backend Test Failures

**Agent:** bug-fixer (opus, worktree)

For each failure received from backend-test-runner:

- [ ] **Step 1: Read the failing test to understand expected behavior**
- [ ] **Step 2: Read the endpoint source code being tested**
- [ ] **Step 3: Identify the root cause**
  - Is it a test issue (wrong assertion, wrong setup)?
  - Is it a backend bug (endpoint logic, query, auth)?
  - Is it a schema issue (missing field, wrong type)?
- [ ] **Step 4: Fix the issue** — prefer fixing the production code if it's a real bug; fix the test only if the test itself is wrong
- [ ] **Step 5: Run `dart analyze` on changed files**
- [ ] **Step 6: Commit the fix**

### Task 6: Fix E2E Test Failures

**Agent:** bug-fixer (opus, worktree for backend fixes; direct for frontend fixes)

For each failure received from e2e-test-runner:

- [ ] **Step 1: Analyze the failure — is it frontend, backend, or test spec issue?**
- [ ] **Step 2: Read relevant source code**
- [ ] **Step 3: Fix the issue**
- [ ] **Step 4: Run `dart analyze` on changed files**
- [ ] **Step 5: Commit the fix**

After fixing, notify e2e-test-runner to hot-reload and re-test.

---

## Execution Order

```
┌─────────────────────┐     ┌─────────────────────┐
│  backend-test-runner │     │  e2e-test-runner     │
│  (sonnet, worktree)  │     │  (sonnet, no worktree│
│                      │     │   — needs marionette) │
│  1. Start Docker     │     │  1. Setup environment │
│  2. Run all tests    │     │  2. Run specs 01→05   │
│  3. Report failures  │     │  3. Report failures   │
└──────────┬──────────┘     └──────────┬──────────┘
           │                            │
           ▼                            ▼
     ┌─────────────────────────────────────┐
     │         bug-fixer (opus)             │
     │  Receives failures from both runners │
     │  Fixes bugs, commits                 │
     └─────────────────────────────────────┘
           │                            │
           ▼                            ▼
┌──────────────────────┐    ┌────────────────────────┐
│  Re-run backend tests│    │  Hot-restart + re-test │
└──────────────────────┘    └────────────────────────┘
```

**Parallelism:** Backend tests (Phase 1) and E2E setup+tests (Phase 2) can run in parallel. Bug fixing (Phase 3) happens as failures are reported — doesn't need to wait for all tests to complete.
