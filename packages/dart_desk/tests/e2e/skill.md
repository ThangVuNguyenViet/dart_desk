---
name: e2e-testing
description: Run E2E integration tests against a real Dart Desk backend using Marionette MCP
---

# E2E Integration Testing Skill

## Overview

This skill runs end-to-end tests for the Dart Desk app against a real Serverpod backend. Unlike the mock-based QA suite (`packages/dart_desk/tests/qa/`), these tests verify data persistence, media handling, CRDT collaboration, error resilience, and authentication against a live database.

## Prerequisites

All E2E tests share these prerequisites. Individual test files do not repeat them.

### Environment

- **Test DB:** `postgres_test` on port 9090, database `dart_desk_be_test`
- **Test Redis:** `redis_test` on port 9091
- **Serverpod:** running in `e2e` mode on port 8080 (connects to test DB)
- Dev database on port 8090 is **never touched** by E2E tests.

### Setup

```bash
# Start test DB + Redis + Serverpod server
./packages/dart_desk/tests/e2e/setup/e2e_env.sh up
```

### Before Each Test File

```bash
# Reset test database to clean state (truncates all tables)
./packages/dart_desk/tests/e2e/setup/e2e_env.sh reset

# Optional: seed auth user for tests that skip registration
./packages/dart_desk/tests/e2e/setup/e2e_env.sh seed
```

### Launch Apps

Use dart MCP tools — do not use manual `flutter run` commands.

- **CMS app:** `mcp__dart__launch_app` with root=`examples/cms_app`, device=`chrome`, target=`lib/main_e2e.dart`
- **Manage app:** `mcp__dart__launch_app` with root=`dart_desk_cloud/dart_desk_manage`, device=`chrome`

Then connect Marionette to the Flutter VM service URI.

### Teardown

```bash
# Stop server + test DB + Redis
./packages/dart_desk/tests/e2e/setup/e2e_env.sh down
```

## Running Tests

- "run E2E tests" → run all test files
- "run E2E test 01" or "run data persistence tests" → run specific file
- "run E2E test TC-E2E-01-02" → run specific test case

## Test Execution

For each test file in `packages/dart_desk/tests/e2e/tests/`:

1. Run `e2e_env.sh reset` to start from clean state
2. Launch the required app(s) via dart MCP tools
3. Connect Marionette to the Flutter VM service URI
4. Check for existing replay in `packages/dart_desk/tests/e2e/replays/`
5. Execute test cases sequentially using Marionette tools
6. After each test case, call `get_interactive_elements` to verify state
7. Take screenshots at verification checkpoints, save to `packages/dart_desk/tests/results/screenshots/`
8. After all test cases pass, save replay to `packages/dart_desk/tests/e2e/replays/{test_file_name}.json`

## Report Format

Generate a report at `packages/dart_desk/tests/reports/YYYY-MM-DD-HHmm.md`:

```markdown
# E2E Test Report - {date}

## Summary
- **Total:** X test cases
- **Passed:** Y
- **Failed:** Z
- **Skipped:** W

## Results

### 01 - Data Persistence & Consistency
| ID | Title | Result | Notes |
|---|---|---|---|
| TC-E2E-01-01 | Create persists to backend | PASS | |
...
```
