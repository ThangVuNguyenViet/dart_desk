# Flutter CMS E2E Tests

End-to-end integration tests for the Flutter CMS app against a real Serverpod backend.

## Prerequisites

- Docker installed and running
- Flutter SDK available
- No other process using port 8080
- Backend project at `../../flutter_cms_be/` (sibling directory)

## Quick Start

```bash
# 1. Start test infrastructure
./setup/docker_manager.sh up
./setup/server_manager.sh start
./setup/seed_data.sh

# 2. Launch the Flutter app (configure CloudDataSource in main.dart)
cd ../../examples/cms_app
flutter run -d chrome --web-port=60366

# 3. Run tests via Claude Code:
#    "run E2E tests"

# 4. Teardown
./setup/server_manager.sh stop
./setup/docker_manager.sh down
```

## Test Suites

| File | Description |
|------|-------------|
| `01_data_persistence.md` | Create, edit, delete, version — verify data survives round-trips |
| `02_media_handling.md` | Upload images/files, verify storage and display |
| `03_crdt_collaboration.md` | Multi-session editing, conflict resolution |
| `04_error_resilience.md` | Backend outages, invalid tokens, deleted documents |
| `05_multi_tenancy.md` | Client isolation, cross-client access prevention |

## Architecture

- **Backend**: Real Serverpod server running on port 8080 (`config/e2e.yaml`)
- **Database**: Test PostgreSQL on port 9090 (via Docker)
- **Frontend**: Flutter web app with `CloudDataSource`
- **Test Driver**: Claude Code + Marionette MCP

## Differences from test_automation/

The existing `test_automation/` suite uses `MockCmsDataSource` (in-memory, no network). This E2E suite uses `CloudDataSource` against a real backend to test scenarios that mocks cannot cover: data persistence, real media storage, CRDT collaboration, error recovery, and multi-tenancy.
