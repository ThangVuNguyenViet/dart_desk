---
name: e2e-testing
description: Run E2E integration tests against a real Flutter CMS backend using Marionette MCP
---

# E2E Integration Testing Skill

## Overview

This skill runs end-to-end tests for the Flutter CMS app against a real Serverpod backend. Unlike the mock-based `test_automation/` suite, these tests verify data persistence, media handling, CRDT collaboration, error resilience, and multi-tenancy against a live database.

## Setup

Before running tests, ensure the E2E environment is up:

1. Start Docker test services:
   ```bash
   ./test_e2e/setup/docker_manager.sh up
   ```

2. Start the Serverpod E2E server:
   ```bash
   ./test_e2e/setup/server_manager.sh start
   ```

3. Seed test data:
   ```bash
   ./test_e2e/setup/seed_data.sh
   ```

4. Launch the Flutter app via Dart MCP:
   Use `mcp__dart__launch_app` with root=`examples/cms_app`, device=`chrome`, target=`lib/main_e2e.dart`.
   Defaults (server, client ID, API token) are baked into `main_e2e.dart`.

5. Connect Marionette to the Flutter VM service URI.

## Running Tests

- "run E2E tests" → run all test files (01-05)
- "run E2E test 01" or "run data persistence tests" → run specific file
- "run E2E test TC-E2E-01-02" → run specific test case

## Test Execution

For each test file in `test_e2e/tests/`:

1. Read the test file prerequisites
2. Check for existing replay in `test_e2e/replays/`
3. Execute test cases sequentially using Marionette tools
4. After each test case, call `get_interactive_elements` to verify state
5. Take screenshots at verification checkpoints, save to `test_e2e/results/screenshots/`
6. After all test cases pass, save replay to `test_e2e/replays/{test_file_name}.json`

## Teardown

After testing:
```bash
./test_e2e/setup/server_manager.sh stop
./test_e2e/setup/docker_manager.sh down
```

## Report Format

Generate a report at `test_e2e/results/reports/YYYY-MM-DD-HHmm.md`:

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
