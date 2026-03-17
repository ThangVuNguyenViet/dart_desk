# Integration Testing Suite Design

## Overview

Two-suite testing approach for the Flutter CMS workspace:
1. **Backend endpoint tests** — Dart integration tests using Serverpod's `withServerpod` in `flutter_cms_be_server/test/integration/`
2. **Full-stack E2E tests** — Marionette-driven UI tests against a real backend in `flutter_cms/test_e2e/`

The existing `test_automation/` suite (10 markdown specs against `MockCmsDataSource`) remains unchanged. The new E2E suite covers scenarios that only a real backend can reveal.

### Prerequisites / Blockers

1. ~~**`clientId` hardcoded to `1`**~~ — RESOLVED: `createDocument` now uses `cmsUser.clientId`.
2. ~~**No auth check on `deleteDocument`**~~ — RESOLVED: `deleteDocument` now requires auth and verifies client ownership.
3. **`seed_data.sh` implementation** — The E2E seed script depends on `CmsClient` and `CmsApiToken` endpoint signatures being finalized. This is a blocking dependency for the E2E suite.

---

## Part 1: Backend Endpoint Tests

### Location

`flutter_cms_be/flutter_cms_be_server/test/integration/`

### Structure

```
test/integration/
├── test_tools/
│   └── serverpod_test_tools.dart       (already exists, auto-generated)
├── document_endpoint_test.dart
├── document_versioning_test.dart
├── document_crdt_test.dart
├── media_endpoint_test.dart
├── cms_client_endpoint_test.dart
├── cms_api_token_endpoint_test.dart
├── user_endpoint_test.dart
├── multi_tenancy_test.dart
└── helpers/
    └── test_data_factory.dart
```

### Pattern

Uses Serverpod's `withServerpod` — endpoints are called **in-process** (no HTTP server started). The test framework provides `sessionBuilder` and `endpoints`. Database rolls back automatically after each test via the default `rollbackDatabase: afterEach`.

```dart
import 'test_tools/serverpod_test_tools.dart';

withServerpod('Document endpoint', (sessionBuilder, endpoints) {
  test('creates a document and retrieves it', () async {
    final doc = await endpoints.document.createDocument(
      sessionBuilder,
      'blog_post',       // documentType
      'My First Post',   // title
      {'title': 'Hello'}, // data
    );

    final fetched = await endpoints.document.getDocument(
      sessionBuilder,
      doc.id!,
    );

    // getDocument returns CmsDocument? (nullable)
    expect(fetched, isNotNull);
    expect(fetched!.title, equals('My First Post'));
  });
});
```

**Note on endpoint signatures:** The actual backend endpoint signatures may use enums (e.g., `DocumentVersionStatus.draft` instead of `'draft'` string) and return wrapper types (e.g., `DocumentVersionListWithOperations` instead of plain `DocumentVersionList`). Always reference the generated `serverpod_test_tools.dart` for exact type signatures during implementation.

### Authentication

Use `AuthenticationOverride` to simulate auth states:

```dart
final authedSession = sessionBuilder.copyWith(
  authentication: AuthenticationOverride.authenticationInfo(
    'user-123',
    {Scope('cms')},
  ),
);

final unauthedSession = sessionBuilder.copyWith(
  authentication: AuthenticationOverride.unauthenticated(),
);
```

### Test Data Factory

`helpers/test_data_factory.dart` provides factory methods that call real endpoints to create test entities:

```dart
class TestDataFactory {
  final TestSessionBuilder sessionBuilder;
  final TestEndpoints endpoints;

  Future<CmsDocument> createTestDocument({
    String documentType = 'test_type',
    String title = 'Test Document',
    Map<String, dynamic> data = const {},
  }) async { ... }

  Future<DocumentVersion> createTestVersion(int documentId) async { ... }

  Future<MediaFile> uploadTestImage() async { ... }
}
```

### Coverage

#### Document CRUD (`document_endpoint_test.dart`)
- Create document with all required fields
- Get document by ID
- Get document by slug (`getDocumentBySlug`)
- Get default document for a type (`getDefaultDocument`)
- Update document metadata (title, slug, isDefault)
- Delete document
- List documents with pagination (limit, offset)
- Search documents by title
- Slug auto-generation from title (`suggestSlug`)
- Slug uniqueness constraint within (clientId, documentType)
- Get nonexistent document returns null/error

#### Versioning (`document_versioning_test.dart`)
- Create draft version (uses `DocumentVersionStatus.draft` enum)
- Publish version — status changes, publishedAt set
- Archive version — status changes, archivedAt set
- Version history ordered by versionNumber descending (returns `DocumentVersionListWithOperations`)
- Version pagination with `includeOperations` parameter
- Publish already-published version returns error
- Version snapshot contains correct data at point-in-time

#### CRDT (`document_crdt_test.dart`)
- Sequential field updates produce correct merged state
- Updates to different fields merge cleanly
- Operation ordering via HLC timestamps
- Data reconstruction from CRDT operations matches document.data
- **Note:** Tests requiring concurrent `session.db.transaction()` calls must use `rollbackDatabase: RollbackDatabase.disabled` and run with `--concurrency=1`

#### Media (`media_endpoint_test.dart`)
- Upload image — returns URL, stored correctly
- Upload file — returns URL, metadata correct
- List media with pagination
- Get media by ID
- Delete media — removed from storage
- File size limit enforcement (>10MB rejected)

#### Multi-Tenancy (`multi_tenancy_test.dart`)
- Client A cannot read Client B's documents
- Client A cannot update/delete Client B's documents
- Document listing filtered by clientId
- Slug uniqueness is per-client (same slug OK for different clients)

#### Auth (`cms_api_token_endpoint_test.dart`, `cms_client_endpoint_test.dart`)
- Valid API token accepted
- Invalid/expired token rejected
- Missing client ID rejected
- Token scoping — token for Client A cannot access Client B

#### User (`user_endpoint_test.dart`)
- User creation and retrieval
- User association with document operations (createdByUserId, updatedByUserId)

### Running Backend Tests

```bash
cd flutter_cms_be/flutter_cms_be_server

# Start test Docker services
docker compose up -d postgres_test redis_test

# Wait for services to be healthy
# (docker compose healthcheck or pg_isready)

# Run all integration tests
dart test test/integration/ --tags integration --concurrency=1

# Run a specific test file
dart test test/integration/document_endpoint_test.dart
```

`--concurrency=1` is used because some tests (CRDT) use `rollbackDatabase: disabled`. For test files that don't need this, concurrency could be higher, but keeping it at 1 is simpler and avoids subtle issues.

**Note:** The `withServerpod` macro automatically applies the `integration` tag (configured in `dart_test.yaml`). No manual `@Tags` annotation is needed on test files.

**Note:** Redis is disabled in `test.yaml`. If future tests require Redis (e.g., session caching), enable it in the test config and ensure `redis_test` Docker service is running.

---

## Part 2: Full-Stack E2E Tests

### Location

`flutter_cms/test_e2e/`

### Structure

```
test_e2e/
├── README.md
├── skill/                              (Claude Code skill definition)
│   └── e2e_testing.md
├── setup/
│   ├── docker_manager.sh              (start/stop Docker services)
│   ├── server_manager.sh              (start/stop Serverpod server)
│   └── seed_data.sh                   (seed test client + API token via API)
├── tests/
│   ├── 01_data_persistence.md
│   ├── 02_media_handling.md
│   ├── 03_crdt_collaboration.md
│   ├── 04_error_resilience.md
│   └── 05_multi_tenancy.md
├── replays/
└── results/
```

### Test Format

Markdown-based test specs (same format as existing `test_automation/`), driven by Claude Code + Marionette MCP against a real backend.

### Environment Setup

#### Prerequisites
- Docker installed and running
- Flutter SDK available
- No other process using port 8080

#### Server Configuration

The existing `config/test.yaml` uses `port: 0` (dynamic) because it's designed for `withServerpod` in-process tests. E2E tests need a real server on a fixed port, so a new `config/e2e.yaml` must be created:

```yaml
# config/e2e.yaml — fixed port for E2E testing
apiServer:
  port: 8080
  publicHost: localhost
  publicPort: 8080
  publicScheme: http

database:
  host: localhost
  port: 9090          # Uses test Postgres (same as withServerpod tests)
  name: flutter_cms_be_test
  user: postgres

redis:
  enabled: false
  host: localhost
  port: 9091
```

#### Setup Flow

1. **`docker_manager.sh up`** — Starts test Postgres (port 9090) + Redis (port 9091) via docker-compose
2. **`server_manager.sh start`** — Starts Serverpod server on port 8080 using `e2e` run mode (reads `config/e2e.yaml`), applies migrations
3. **`seed_data.sh`** — Creates a test client and API token via backend API calls, outputs the token for use in the Flutter app
4. **Launch Flutter app** — `flutter run -d chrome` with `CloudDataSource` pointing at `http://localhost:8080/` using the seeded API token
5. **Connect Marionette** — Connect to the Flutter VM service URI

#### Teardown

```bash
# Stop Flutter app (Ctrl+C or via Marionette)
server_manager.sh stop
docker_manager.sh down
```

### Test Scenarios

#### 01 — Data Persistence & Consistency (`01_data_persistence.md`)

| ID | Test Case | Steps | Expected |
|----|-----------|-------|----------|
| TC-E2E-01-01 | Create persists to DB | Create document via UI, query backend API to verify | Document exists in API response with correct fields |
| TC-E2E-01-02 | Edit persists across refresh | Edit fields, save, refresh browser | All edits preserved after refresh |
| TC-E2E-01-03 | Version history accurate | Create multiple versions, check version list | Version numbers sequential, data snapshots correct |
| TC-E2E-01-04 | Delete removes from backend | Delete document via UI, query API | 404 from API, gone from UI list |
| TC-E2E-01-05 | Publish version via UI | Publish a draft, verify status | Version status is "published", publishedAt is set |

#### 02 — Real Media Handling (`02_media_handling.md`)

| ID | Test Case | Steps | Expected |
|----|-----------|-------|----------|
| TC-E2E-02-01 | Upload image | Upload via image field in UI | File stored, URL accessible, preview displays |
| TC-E2E-02-02 | Upload non-image file | Upload via file field | Metadata correct, download works |
| TC-E2E-02-03 | Delete media | Delete uploaded file | Removed from storage, field cleared |
| TC-E2E-02-04 | Image field displays URL | Upload image, save, reload | Image preview loads from backend URL |

#### 03 — CRDT & Collaboration (`03_crdt_collaboration.md`)

| ID | Test Case | Steps | Expected |
|----|-----------|-------|----------|
| TC-E2E-03-01 | Two sessions different fields | Open same doc in 2 browser tabs, edit different fields in each, save both | Both changes present in final document |
| TC-E2E-03-02 | Two sessions same field | Edit same field in 2 tabs, save both | Last save wins, no crash or data corruption |
| TC-E2E-03-03 | Rapid sequential edits | Make many quick edits, save | All changes applied, CRDT operations ordered correctly |

#### 04 — Error Resilience (`04_error_resilience.md`)

| ID | Test Case | Steps | Expected |
|----|-----------|-------|----------|
| TC-E2E-04-01 | Backend down during save | Stop server, attempt save in UI | Error message shown, no crash, no data loss of unsaved state |
| TC-E2E-04-02 | Invalid API token | Launch app with bad token | Auth error shown, cannot access documents |
| TC-E2E-04-03 | Operate on deleted document | Delete doc via API while UI has it open, attempt edit | Graceful error, redirects to list |
| TC-E2E-04-04 | Backend restart | Stop and restart server mid-session | App recovers, data still accessible |

#### 05 — Multi-Tenancy (`05_multi_tenancy.md`)

| ID | Test Case | Steps | Expected |
|----|-----------|-------|----------|
| TC-E2E-05-01 | Client isolation | Seed 2 clients, launch as Client A, create docs, relaunch as Client B | Client B sees no Client A documents |
| TC-E2E-05-02 | Cross-client API access | From Client B's app, attempt to fetch Client A's doc ID via API | 403 or 404, no data leaked |
| TC-E2E-05-03 | Same slug different clients | Create doc with slug "hello" as Client A, same slug as Client B | Both succeed, no conflict |

---

## Part 3: Test Orchestration

### Backend Tests Script

`flutter_cms_be/run_integration_tests.sh`:

```bash
#!/bin/bash
set -e

cd "$(dirname "$0")/flutter_cms_be_server"

echo "Starting test Docker services..."
docker compose up -d postgres_test redis_test

echo "Waiting for PostgreSQL to be ready..."
until docker compose exec -T postgres_test pg_isready -U postgres; do
  sleep 1
done

echo "Running integration tests..."
dart test test/integration/ --tags integration --concurrency=1

echo "Stopping test Docker services..."
docker compose down
```

### E2E Tests Setup Scripts

`flutter_cms/test_e2e/setup/docker_manager.sh`:

```bash
#!/bin/bash
set -e

BACKEND_DIR="$(dirname "$0")/../../../flutter_cms_be/flutter_cms_be_server"

case "$1" in
  up)
    echo "Starting test Docker services..."
    docker compose -f "$BACKEND_DIR/docker-compose.yaml" up -d postgres_test redis_test
    echo "Waiting for PostgreSQL..."
    until docker compose -f "$BACKEND_DIR/docker-compose.yaml" exec -T postgres_test pg_isready -U postgres; do
      sleep 1
    done
    echo "Test services ready."
    ;;
  down)
    echo "Stopping test Docker services..."
    docker compose -f "$BACKEND_DIR/docker-compose.yaml" down
    ;;
  *)
    echo "Usage: $0 {up|down}"
    exit 1
    ;;
esac
```

`flutter_cms/test_e2e/setup/server_manager.sh`:

```bash
#!/bin/bash
set -e

BACKEND_DIR="$(dirname "$0")/../../../flutter_cms_be/flutter_cms_be_server"
PID_FILE="/tmp/flutter_cms_test_server.pid"

case "$1" in
  start)
    echo "Starting Serverpod E2E server on port 8080..."
    cd "$BACKEND_DIR"
    dart run bin/main.dart --apply-migrations --role=monolith --mode=e2e &
    echo $! > "$PID_FILE"
    echo "Server started (PID: $(cat $PID_FILE))"
    # Wait for server to be ready
    until curl -s http://localhost:8080/ > /dev/null 2>&1; do
      sleep 1
    done
    echo "Server ready."
    ;;
  stop)
    if [ -f "$PID_FILE" ]; then
      echo "Stopping server (PID: $(cat $PID_FILE))..."
      kill "$(cat $PID_FILE)" 2>/dev/null || true
      rm "$PID_FILE"
      echo "Server stopped."
    else
      echo "No server PID file found."
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
```

`flutter_cms/test_e2e/setup/seed_data.sh`:

```bash
#!/bin/bash
set -e

SERVER_URL="${1:-http://localhost:8080}"

echo "Seeding test client and API token..."

# Create test client via API
# (Exact endpoint calls depend on CmsClient/CmsApiToken endpoint signatures)
# This script will be finalized during implementation once endpoint contracts are confirmed.

echo "Seed complete. Use the output token to configure the Flutter app."
```

### CI Integration

- **Backend tests**: Run in any CI with Docker support. Add to GitHub Actions workflow.
- **E2E tests**: Require Chrome + Flutter SDK. More suited for dedicated CI runner or local execution via Claude Code. Can be added to CI later with headless Chrome.

---

## Design Decisions

| Decision | Rationale |
|----------|-----------|
| Two separate suites (Approach B) | Backend tests stay close to backend code using native Serverpod tooling; E2E tests follow existing markdown spec pattern |
| `withServerpod` for backend tests (in-process, no HTTP) | Serverpod's recommended pattern — faster, simpler, automatic DB rollback |
| Separate `config/e2e.yaml` with fixed port 8080 | `test.yaml` uses port 0 (dynamic) for in-process tests; E2E needs a real server on a fixed port matching the Flutter app's config |
| Seed data via API (not SQL) | Tests exercise real creation path, no coupling to DB schema, each test documents its own setup |
| New E2E scenarios (not porting mock-based specs) | Existing `test_automation/` already covers UI behavior; E2E suite focuses on backend-specific concerns |
| `--concurrency=1` for backend tests | Some CRDT tests need `rollbackDatabase: disabled`; simpler to keep all sequential |
| Automated Docker/server management | CI-friendly; developer runs one script instead of manual setup |
| Markdown test specs for E2E | Consistent with existing `test_automation/` pattern; driven by Claude Code + Marionette |
