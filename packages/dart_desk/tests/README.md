# Dart Desk Test Suite

Two test suites for the Dart Desk CMS: **QA** (mock-based, fast) and **E2E** (real backend, full stack).

## Directory Structure

```
tests/
├── qa/                    # Mock-based QA tests (49 cases, 10 suites)
│   ├── skill.md           # Skill definition for Claude Code
│   ├── tests/             # Test case specs (.md)
│   └── replays/           # Auto-generated replay JSONs
├── e2e/                   # Frontend-to-backend E2E tests (19 cases, 5 suites)
│   ├── skill.md           # Skill definition for Claude Code
│   ├── tests/             # Test case specs (.md)
│   ├── setup/             # Docker, server, and seed scripts
│   └── replays/           # Auto-generated replay JSONs
├── reports/               # Test run reports (both suites)
└── results/               # Runtime outputs (screenshots, etc.)
```

## QA Tests

Tests UI behavior using `MockDeskDataSource` — no backend required.

**Prerequisites:**
1. Launch the test app (`lib/main_test.dart`) with `allFieldsDocumentType` via `mcp__dart__launch_app`
2. Connect Marionette to the app's VM service URI

**Run:**
- "run the CMS test suite" — all 10 suites
- "run test 04" — specific suite by number
- "re-discover test 02" — force re-run discovery

**Suites:** sidebar navigation, document CRUD, document selection, field types (basic/advanced/complex), form save/discard, version history, panel layout, error states.

## E2E Tests

Tests full-stack behavior against a real Serverpod backend with PostgreSQL.

**Prerequisites:**
1. Docker running
2. Start test infrastructure:
   ```bash
   ./packages/dart_desk/tests/e2e/setup/docker_manager.sh up
   ./packages/dart_desk/tests/e2e/setup/server_manager.sh start
   ```
3. Launch the E2E app (`examples/desk_app`, target `lib/main_e2e.dart`) via `mcp__dart__launch_app`
4. Connect Marionette

**Run:**
- "run E2E tests" — all suites
- "run E2E test 01" — specific suite

**Teardown:**
```bash
./packages/dart_desk/tests/e2e/setup/server_manager.sh stop
./packages/dart_desk/tests/e2e/setup/docker_manager.sh down
```

**Suites:** data persistence, media handling, CRDT collaboration, error resilience, single-tenant auth.

## Reports

Test reports are saved to `reports/` with naming convention:
- QA: `qa_run_YYYY-MM-DD.md`
- E2E: `YYYY-MM-DD-{description}.md`

## Adding New Tests

1. Create a `.md` file in the appropriate `tests/` directory
2. Follow the existing format (test case IDs: `TC-{suite}-{case}` for QA, `TC-E2E-{suite}-{case}` for E2E)
3. Use sequential numbering for new suites
