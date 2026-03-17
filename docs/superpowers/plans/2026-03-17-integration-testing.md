# Integration Testing Suite Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a two-suite integration testing system — backend endpoint tests using Serverpod's `withServerpod` and full-stack E2E tests using Marionette against a real backend.

**Architecture:** Backend tests run in-process via `withServerpod` with automatic DB rollback. E2E tests launch a real Serverpod server (`config/e2e.yaml`, port 8080), connect a Flutter app via `CloudDataSource`, and drive it with Marionette MCP. Both suites share Docker test services (Postgres port 9090, Redis port 9091).

**Tech Stack:** Dart, Serverpod 3.4.3, `serverpod_test` package, Flutter, Marionette MCP, Docker Compose, shell scripts.

**Spec:** `docs/superpowers/specs/2026-03-17-integration-testing-design.md`

---

## File Structure

### Backend Tests (in `flutter_cms_be/flutter_cms_be_server/`)

| File | Responsibility |
|------|---------------|
| `test/integration/helpers/test_data_factory.dart` | Factory methods to create test entities via real endpoints |
| `test/integration/document_endpoint_test.dart` | Document CRUD tests |
| `test/integration/document_versioning_test.dart` | Version lifecycle tests |
| `test/integration/document_crdt_test.dart` | CRDT operation correctness |
| `test/integration/media_endpoint_test.dart` | Media upload/delete tests |
| `test/integration/cms_client_endpoint_test.dart` | Client management tests |
| `test/integration/cms_api_token_endpoint_test.dart` | API token tests |
| `test/integration/user_endpoint_test.dart` | User management tests |
| `test/integration/multi_tenancy_test.dart` | Cross-client isolation tests |
| `config/e2e.yaml` | E2E server config (fixed port 8080) |

### E2E Tests (in `flutter_cms/`)

| File | Responsibility |
|------|---------------|
| `test_e2e/setup/docker_manager.sh` | Start/stop Docker test services |
| `test_e2e/setup/server_manager.sh` | Start/stop Serverpod E2E server |
| `test_e2e/setup/seed_data.sh` | Seed test client + API token |
| `test_e2e/tests/01_data_persistence.md` | Data persistence test specs |
| `test_e2e/tests/02_media_handling.md` | Media handling test specs |
| `test_e2e/tests/03_crdt_collaboration.md` | CRDT collaboration test specs |
| `test_e2e/tests/04_error_resilience.md` | Error resilience test specs |
| `test_e2e/tests/05_multi_tenancy.md` | Multi-tenancy test specs |
| `test_e2e/skill/e2e_testing.md` | Claude Code skill for E2E runner |
| `test_e2e/README.md` | Setup and usage instructions |

### Orchestration Scripts

| File | Responsibility |
|------|---------------|
| `flutter_cms_be/run_integration_tests.sh` | One-command backend test runner |

---

## Phase 1: Backend Test Infrastructure

### Task 1: Test Data Factory

**Files:**
- Create: `flutter_cms_be/flutter_cms_be_server/test/integration/helpers/test_data_factory.dart`

**Context:** This factory provides reusable helper methods that create test entities via real endpoint calls. Every subsequent test file depends on this. The factory needs a `TestSessionBuilder` and `TestEndpoints` (provided by `withServerpod`). All write endpoints require authentication, so the factory must configure an authenticated session.

**Reference:**
- `test/integration/test_tools/serverpod_test_tools.dart` — auto-generated, provides `withServerpod`, `TestSessionBuilder`, `TestEndpoints`
- `lib/src/endpoints/document_endpoint.dart` — `createDocument` has hardcoded `clientId: 1`
- `lib/src/endpoints/cms_client_endpoint.dart` — `createClient` returns `ClientWithToken`
- `lib/src/endpoints/cms_api_token_endpoint.dart` — `createToken` returns `CmsApiTokenWithValue`
- `lib/src/endpoints/user_endpoint.dart` — `ensureUser` creates user if needed

- [ ] **Step 1: Create test_data_factory.dart with client/user helpers**

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:flutter_cms_be_server/src/generated/protocol.dart';
import '../test_tools/serverpod_test_tools.dart';

/// Factory for creating test entities via real endpoint calls.
/// Requires an authenticated session — use [authenticatedSession] helper.
class TestDataFactory {
  final TestSessionBuilder sessionBuilder;
  final TestEndpoints endpoints;

  TestDataFactory({
    required this.sessionBuilder,
    required this.endpoints,
  });

  /// Creates an authenticated session builder.
  /// withServerpod sessions are unauthenticated by default.
  TestSessionBuilder authenticatedSession({
    String userIdentifier = 'test-user-1',
  }) {
    return sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        userIdentifier,
        {},
      ),
    );
  }

  /// Creates a CmsClient and returns it with its plaintext API token.
  Future<ClientWithToken> createTestClient({
    String name = 'Test Client',
    String slug = 'test-client',
    String? description,
  }) async {
    final authed = authenticatedSession();
    return await endpoints.cmsClient.createClient(
      authed,
      name,
      slug,
      description: description,
    );
  }

  /// Creates a document via the document endpoint.
  /// Note: DocumentEndpoint.createDocument currently has hardcoded clientId: 1.
  /// A CmsClient with id=1 must exist for this to work, or the endpoint
  /// must be fixed to derive clientId from the session.
  Future<CmsDocument> createTestDocument({
    String documentType = 'test_type',
    String title = 'Test Document',
    Map<String, dynamic> data = const {'field1': 'value1'},
    String? slug,
    bool isDefault = false,
  }) async {
    final authed = authenticatedSession();
    return await endpoints.document.createDocument(
      authed,
      documentType,
      title,
      data,
      slug: slug,
      isDefault: isDefault,
    );
  }

  /// Creates a document version.
  Future<DocumentVersion> createTestVersion(
    int documentId, {
    DocumentVersionStatus status = DocumentVersionStatus.draft,
    String? changeLog,
  }) async {
    final authed = authenticatedSession();
    return await endpoints.document.createDocumentVersion(
      authed,
      documentId,
      status: status,
      changeLog: changeLog,
    );
  }

  /// Uploads a minimal test PNG image (1x1 pixel).
  Future<UploadResponse> uploadTestImage({
    String fileName = 'test_image.png',
  }) async {
    final authed = authenticatedSession();
    // Minimal valid 1x1 PNG file (67 bytes)
    final pngBytes = <int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1
      0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, // RGB, filters
      0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, // IDAT chunk
      0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00, // compressed data
      0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC, // checksum
      0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, // IEND chunk
      0x44, 0xAE, 0x42, 0x60, 0x82,
    ];
    final byteData = ByteData.sublistView(Uint8List.fromList(pngBytes));
    return await endpoints.media.uploadImage(authed, fileName, byteData);
  }

  /// Uploads a minimal test text file.
  Future<UploadResponse> uploadTestFile({
    String fileName = 'test_file.txt',
    String content = 'test file content',
  }) async {
    final authed = authenticatedSession();
    final bytes = utf8.encode(content);
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return await endpoints.media.uploadFile(authed, fileName, byteData);
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run from `flutter_cms_be/flutter_cms_be_server/`:
```bash
dart analyze test/integration/helpers/test_data_factory.dart
```
Expected: No errors. Fix any import issues — the exact import paths depend on the generated code. Check `test_tools/serverpod_test_tools.dart` for the correct import of `TestSessionBuilder` and `TestEndpoints`.

- [ ] **Step 3: Commit**

```bash
cd flutter_cms_be/flutter_cms_be_server
git add test/integration/helpers/test_data_factory.dart
git commit -m "test: add TestDataFactory for integration test entity creation"
```

---

### Task 2: Document CRUD Endpoint Tests

**Files:**
- Create: `flutter_cms_be/flutter_cms_be_server/test/integration/document_endpoint_test.dart`

**Context:** Tests basic document CRUD operations. The `createDocument` endpoint currently hardcodes `clientId: 1`, so a `CmsClient` record with `id=1` must be seeded first via `createTestClient`. Since `withServerpod` rolls back the DB after each test, the first `createTestClient` call in `setUp` should get `id=1` due to sequence reset. If this is flaky, seed the client via direct DB insert using `sessionBuilder.build()` to guarantee `id=1`. All write ops require an authenticated session.

**Reference:**
- `lib/src/endpoints/document_endpoint.dart` — all method signatures
- `test/integration/helpers/test_data_factory.dart` — factory from Task 1

- [ ] **Step 1: Write the test file**

```dart
import 'dart:convert';
import 'package:test/test.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:flutter_cms_be_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('Document endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      // Seed a client so createDocument (hardcoded clientId:1) works.
      // This may need adjustment once clientId is derived from session.
      await factory.createTestClient(slug: 'test-client-doc');
    });

    group('createDocument', () {
      test('creates document with required fields', () async {
        final doc = await factory.createTestDocument(
          documentType: 'blog_post',
          title: 'My First Post',
          data: {'body': 'Hello world'},
        );

        expect(doc.id, isNotNull);
        expect(doc.title, equals('My First Post'));
        expect(doc.documentType, equals('blog_post'));
      });

      test('creates document with custom slug', () async {
        final doc = await factory.createTestDocument(
          title: 'Custom Slug Post',
          slug: 'custom-slug',
        );

        expect(doc.slug, equals('custom-slug'));
      });

      test('creates document with isDefault flag', () async {
        final doc = await factory.createTestDocument(
          title: 'Default Post',
          isDefault: true,
        );

        expect(doc.isDefault, isTrue);
      });
    });

    group('getDocument', () {
      test('returns document by ID', () async {
        final created = await factory.createTestDocument(title: 'Fetch Me');
        final fetched = await endpoints.document.getDocument(
          sessionBuilder,
          created.id!,
        );

        expect(fetched, isNotNull);
        expect(fetched!.title, equals('Fetch Me'));
      });

      test('returns null for nonexistent ID', () async {
        final fetched = await endpoints.document.getDocument(
          sessionBuilder,
          999999,
        );
        expect(fetched, isNull);
      });
    });

    group('getDocumentBySlug', () {
      test('returns document by slug', () async {
        await factory.createTestDocument(
          title: 'Slug Test',
          slug: 'slug-test',
        );
        final fetched = await endpoints.document.getDocumentBySlug(
          sessionBuilder,
          'slug-test',
        );

        expect(fetched, isNotNull);
        expect(fetched!.title, equals('Slug Test'));
      });

      test('returns null for nonexistent slug', () async {
        final fetched = await endpoints.document.getDocumentBySlug(
          sessionBuilder,
          'nonexistent-slug',
        );
        expect(fetched, isNull);
      });
    });

    group('getDefaultDocument', () {
      test('returns default document for type', () async {
        await factory.createTestDocument(
          documentType: 'page',
          title: 'Default Page',
          isDefault: true,
        );
        final fetched = await endpoints.document.getDefaultDocument(
          sessionBuilder,
          'page',
        );

        expect(fetched, isNotNull);
        expect(fetched!.isDefault, isTrue);
      });

      test('returns null when no default exists', () async {
        await factory.createTestDocument(
          documentType: 'article',
          title: 'Not Default',
          isDefault: false,
        );
        final fetched = await endpoints.document.getDefaultDocument(
          sessionBuilder,
          'article',
        );
        expect(fetched, isNull);
      });
    });

    group('getDocuments', () {
      test('lists documents with pagination', () async {
        for (var i = 0; i < 5; i++) {
          await factory.createTestDocument(
            title: 'Doc $i',
            documentType: 'list_test',
          );
        }

        final result = await endpoints.document.getDocuments(
          sessionBuilder,
          'list_test',
          limit: 3,
          offset: 0,
        );

        expect(result.documents.length, equals(3));
        expect(result.total, equals(5));
      });

      test('searches documents by title', () async {
        await factory.createTestDocument(
          title: 'Alpha Post',
          documentType: 'search_test',
        );
        await factory.createTestDocument(
          title: 'Beta Post',
          documentType: 'search_test',
        );

        final result = await endpoints.document.getDocuments(
          sessionBuilder,
          'search_test',
          search: 'Alpha',
        );

        expect(result.documents.length, equals(1));
        expect(result.documents.first.title, equals('Alpha Post'));
      });
    });

    group('updateDocument', () {
      test('updates title', () async {
        final doc = await factory.createTestDocument(title: 'Old Title');
        final authed = factory.authenticatedSession();
        final updated = await endpoints.document.updateDocument(
          authed,
          doc.id!,
          title: 'New Title',
        );

        expect(updated, isNotNull);
        expect(updated!.title, equals('New Title'));
      });

      test('updates slug', () async {
        final doc = await factory.createTestDocument(title: 'Slug Update');
        final authed = factory.authenticatedSession();
        final updated = await endpoints.document.updateDocument(
          authed,
          doc.id!,
          slug: 'new-slug',
        );

        expect(updated!.slug, equals('new-slug'));
      });
    });

    group('deleteDocument', () {
      test('deletes existing document', () async {
        final doc = await factory.createTestDocument(title: 'Delete Me');
        final result = await endpoints.document.deleteDocument(
          sessionBuilder,
          doc.id!,
        );

        expect(result, isTrue);

        final fetched = await endpoints.document.getDocument(
          sessionBuilder,
          doc.id!,
        );
        expect(fetched, isNull);
      });
    });

    group('suggestSlug', () {
      test('generates slug from title', () async {
        final slug = await endpoints.document.suggestSlug(
          sessionBuilder,
          'My Amazing Blog Post',
          'blog',
        );

        expect(slug, contains('my-amazing-blog-post'));
      });

      test('handles duplicate slugs', () async {
        await factory.createTestDocument(
          title: 'Duplicate',
          slug: 'duplicate',
          documentType: 'slug_test',
        );

        final slug = await endpoints.document.suggestSlug(
          sessionBuilder,
          'Duplicate',
          'slug_test',
        );

        // Should append a suffix to avoid collision
        expect(slug, isNot(equals('duplicate')));
      });
    });
  });
}
```

- [ ] **Step 2: Start Docker test services and run the test**

```bash
cd flutter_cms_be/flutter_cms_be_server
docker compose up -d postgres_test redis_test
# Wait for postgres
until docker compose exec -T postgres_test pg_isready -U postgres; do sleep 1; done
dart test test/integration/document_endpoint_test.dart --concurrency=1
```

Expected: All tests PASS. If `createDocument` fails due to missing client with `id=1`, the `setUp` client creation must run first — check that `createTestClient` returns a client and that `withServerpod`'s migration creates the necessary tables.

- [ ] **Step 3: Fix any failures and re-run**

Common issues:
- Missing imports (check `serverpod_test_tools.dart` for exact types)
- `clientId: 1` hardcoding — ensure `createTestClient` is called in `setUp`
- Auth required — use `factory.authenticatedSession()` for write operations

- [ ] **Step 4: Commit**

```bash
git add test/integration/document_endpoint_test.dart
git commit -m "test: add document CRUD integration tests"
```

---

### Task 3: Document Versioning Tests

**Files:**
- Create: `flutter_cms_be/flutter_cms_be_server/test/integration/document_versioning_test.dart`

**Context:** Tests the document version lifecycle — create draft, publish, archive, version history. Uses `DocumentVersionStatus` enum and `DocumentVersionListWithOperations` return type.

**Reference:**
- `lib/src/endpoints/document_endpoint.dart` — `createDocumentVersion`, `publishDocumentVersion`, `archiveDocumentVersion`, `getDocumentVersions`
- Return type: `DocumentVersionListWithOperations` contains `versions: List<DocumentVersionWithOperations>`, each wrapping a `DocumentVersion`

- [ ] **Step 1: Write the test file**

```dart
import 'package:test/test.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:flutter_cms_be_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('Document versioning', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.createTestClient(slug: 'test-client-ver');
    });

    group('createDocumentVersion', () {
      test('creates draft version', () async {
        final doc = await factory.createTestDocument(title: 'Versioned Doc');
        final version = await factory.createTestVersion(doc.id!);

        expect(version.id, isNotNull);
        expect(version.documentId, equals(doc.id));
        expect(version.status, equals(DocumentVersionStatus.draft));
        expect(version.versionNumber, equals(1));
      });

      test('increments version number', () async {
        final doc = await factory.createTestDocument(title: 'Multi Version');
        final v1 = await factory.createTestVersion(doc.id!);
        final v2 = await factory.createTestVersion(doc.id!);

        expect(v1.versionNumber, equals(1));
        expect(v2.versionNumber, equals(2));
      });

      test('stores changeLog', () async {
        final doc = await factory.createTestDocument(title: 'Changelog Doc');
        final version = await factory.createTestVersion(
          doc.id!,
          changeLog: 'Initial draft with hero section',
        );

        expect(version.changeLog, equals('Initial draft with hero section'));
      });
    });

    group('publishDocumentVersion', () {
      test('changes status to published and sets publishedAt', () async {
        final doc = await factory.createTestDocument(title: 'Publish Test');
        final draft = await factory.createTestVersion(doc.id!);
        final authed = factory.authenticatedSession();

        final published = await endpoints.document.publishDocumentVersion(
          authed,
          draft.id!,
        );

        expect(published, isNotNull);
        expect(published!.status, equals(DocumentVersionStatus.published));
        expect(published.publishedAt, isNotNull);
      });
    });

    group('archiveDocumentVersion', () {
      test('changes status to archived and sets archivedAt', () async {
        final doc = await factory.createTestDocument(title: 'Archive Test');
        final draft = await factory.createTestVersion(doc.id!);
        final authed = factory.authenticatedSession();

        // Publish first, then archive
        await endpoints.document.publishDocumentVersion(authed, draft.id!);
        final archived = await endpoints.document.archiveDocumentVersion(
          authed,
          draft.id!,
        );

        expect(archived, isNotNull);
        expect(archived!.status, equals(DocumentVersionStatus.archived));
        expect(archived.archivedAt, isNotNull);
      });
    });

    group('getDocumentVersions', () {
      test('returns versions ordered by versionNumber descending', () async {
        final doc = await factory.createTestDocument(title: 'History Doc');
        await factory.createTestVersion(doc.id!);
        await factory.createTestVersion(doc.id!);
        await factory.createTestVersion(doc.id!);

        final result = await endpoints.document.getDocumentVersions(
          sessionBuilder,
          doc.id!,
        );

        expect(result.versions.length, equals(3));
        // Descending order: v3, v2, v1
        expect(
          result.versions.first.version.versionNumber,
          greaterThan(result.versions.last.version.versionNumber),
        );
      });

      test('paginates version list', () async {
        final doc = await factory.createTestDocument(title: 'Paginated Doc');
        for (var i = 0; i < 5; i++) {
          await factory.createTestVersion(doc.id!);
        }

        final page1 = await endpoints.document.getDocumentVersions(
          sessionBuilder,
          doc.id!,
          limit: 2,
          offset: 0,
        );

        expect(page1.versions.length, equals(2));
        expect(page1.total, equals(5));
      });
    });

    group('publishDocumentVersion edge cases', () {
      test('publish already-published version returns error', () async {
        final doc = await factory.createTestDocument(title: 'Double Publish');
        final draft = await factory.createTestVersion(doc.id!);
        final authed = factory.authenticatedSession();

        // Publish first time — should succeed
        await endpoints.document.publishDocumentVersion(authed, draft.id!);

        // Publish again — should throw or return error
        expect(
          () => endpoints.document.publishDocumentVersion(authed, draft.id!),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('version snapshot data', () {
      test('version snapshot contains correct data at point-in-time', () async {
        final doc = await factory.createTestDocument(
          title: 'Snapshot Doc',
          data: {'content': 'v1'},
        );
        final authed = factory.authenticatedSession();

        // Create version at v1
        final v1 = await factory.createTestVersion(doc.id!);

        // Update data to v2
        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'content': 'v2'},
        );

        // Retrieve v1 snapshot data — should still be v1
        final v1Data = await endpoints.document.getDocumentVersionData(
          sessionBuilder,
          v1.id!,
        );

        expect(v1Data, isNotNull);
        expect(v1Data!['content'], equals('v1'));
      });
    });

    group('deleteDocumentVersion', () {
      test('deletes a draft version', () async {
        final doc = await factory.createTestDocument(title: 'Delete Ver');
        final version = await factory.createTestVersion(doc.id!);
        final authed = factory.authenticatedSession();

        final result = await endpoints.document.deleteDocumentVersion(
          authed,
          version.id!,
        );
        expect(result, isTrue);

        final fetched = await endpoints.document.getDocumentVersion(
          sessionBuilder,
          version.id!,
        );
        expect(fetched, isNull);
      });
    });
  });
}
```

- [ ] **Step 2: Run the test**

```bash
dart test test/integration/document_versioning_test.dart --concurrency=1
```

Expected: All tests PASS.

- [ ] **Step 3: Fix any failures and re-run**

- [ ] **Step 4: Commit**

```bash
git add test/integration/document_versioning_test.dart
git commit -m "test: add document versioning integration tests"
```

---

### Task 4: CRDT Operation Tests

**Files:**
- Create: `flutter_cms_be/flutter_cms_be_server/test/integration/document_crdt_test.dart`

**Context:** Tests CRDT-based document editing. Uses `updateDocumentData` for field-level updates and `DocumentCollaborationEndpoint` for operation inspection. Some tests may need `rollbackDatabase: RollbackDatabase.disabled` if they use concurrent transactions.

**Reference:**
- `lib/src/endpoints/document_endpoint.dart` — `updateDocumentData(session, documentId, updates, {sessionId})`
- `lib/src/endpoints/document_collaboration_endpoint.dart` — `getOperationsSince`, `submitEdit`, `getOperationCount`, `getCurrentHlc`
- `lib/src/services/document_crdt_service.dart` — CRDT merge logic

- [ ] **Step 1: Write the test file**

```dart
import 'dart:convert';
import 'package:test/test.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:flutter_cms_be_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('Document CRDT operations', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.createTestClient(slug: 'test-client-crdt');
    });

    group('updateDocumentData', () {
      test('sequential updates produce correct merged state', () async {
        final doc = await factory.createTestDocument(
          title: 'CRDT Doc',
          data: {'field1': 'initial'},
        );
        final authed = factory.authenticatedSession();

        // First update
        final updated1 = await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'field1': 'updated', 'field2': 'new_value'},
        );

        // Parse the data field (stored as JSON string)
        final data1 = jsonDecode(updated1.data!) as Map<String, dynamic>;
        expect(data1['field1'], equals('updated'));
        expect(data1['field2'], equals('new_value'));

        // Second update
        final updated2 = await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'field3': 'another_value'},
        );

        final data2 = jsonDecode(updated2.data!) as Map<String, dynamic>;
        expect(data2['field1'], equals('updated'));
        expect(data2['field2'], equals('new_value'));
        expect(data2['field3'], equals('another_value'));
      });

      test('updates to different fields merge cleanly', () async {
        final doc = await factory.createTestDocument(
          title: 'Merge Doc',
          data: {'a': '1', 'b': '2'},
        );
        final authed = factory.authenticatedSession();

        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'a': 'updated_a'},
        );
        final result = await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'b': 'updated_b'},
        );

        final data = jsonDecode(result.data!) as Map<String, dynamic>;
        expect(data['a'], equals('updated_a'));
        expect(data['b'], equals('updated_b'));
      });
    });

    group('CRDT operations tracking', () {
      test('operations are recorded and countable', () async {
        final doc = await factory.createTestDocument(
          title: 'Ops Doc',
          data: {'x': '1'},
        );
        final authed = factory.authenticatedSession();

        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'x': '2'},
        );
        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'y': '3'},
        );

        final count = await endpoints.documentCollaboration.getOperationCount(
          sessionBuilder,
          doc.id!,
        );

        // At least 2 operations from our updates (may be more from create)
        expect(count, greaterThanOrEqualTo(2));
      });

      test('getCurrentHlc returns a valid HLC', () async {
        final doc = await factory.createTestDocument(
          title: 'HLC Doc',
          data: {'z': '1'},
        );
        final authed = factory.authenticatedSession();

        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'z': '2'},
        );

        final hlc = await endpoints.documentCollaboration.getCurrentHlc(
          sessionBuilder,
          doc.id!,
        );

        expect(hlc, isNotNull);
        expect(hlc!.isNotEmpty, isTrue);
      });
    });
  });
}
```

- [ ] **Step 2: Run the test**

```bash
dart test test/integration/document_crdt_test.dart --concurrency=1
```

Expected: All tests PASS. The `data` field on `CmsDocument` is a `String?` containing JSON — verify by checking how `updateDocumentData` returns data. If the field is already a `Map`, adjust the parsing.

- [ ] **Step 3: Fix any failures and re-run**

- [ ] **Step 4: Commit**

```bash
git add test/integration/document_crdt_test.dart
git commit -m "test: add CRDT operation integration tests"
```

---

### Task 5: Media Endpoint Tests

**Files:**
- Create: `flutter_cms_be/flutter_cms_be_server/test/integration/media_endpoint_test.dart`

**Context:** Tests media upload/download/delete. `uploadImage` accepts `ByteData` and validates file extensions (jpg, jpeg, png, gif, webp). `uploadFile` accepts pdf, doc, docx, txt, csv, xlsx. Max size: 10MB.

**Reference:**
- `lib/src/endpoints/media_endpoint.dart` — all method signatures
- Allowed image types: jpg, jpeg, png, gif, webp
- Allowed file types: pdf, doc, docx, txt, csv, xlsx

- [ ] **Step 1: Write the test file**

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:flutter_cms_be_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('Media endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.createTestClient(slug: 'test-client-media');
    });

    group('uploadImage', () {
      test('uploads PNG and returns URL', () async {
        final result = await factory.uploadTestImage(
          fileName: 'hero.png',
        );

        expect(result.url, isNotEmpty);
        expect(result.id, isNotEmpty);
      });

      test('rejects non-image file type', () async {
        final authed = factory.authenticatedSession();
        final bytes = utf8.encode('not an image');
        final byteData = ByteData.sublistView(Uint8List.fromList(bytes));

        expect(
          () => endpoints.media.uploadImage(authed, 'bad.xyz', byteData),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('uploadFile', () {
      test('uploads text file and returns URL', () async {
        final result = await factory.uploadTestFile(
          fileName: 'document.txt',
          content: 'Hello, world!',
        );

        expect(result.url, isNotEmpty);
        expect(result.id, isNotEmpty);
      });
    });

    group('getMedia', () {
      test('returns media metadata by ID', () async {
        final uploaded = await factory.uploadTestImage();
        final authed = factory.authenticatedSession();
        final mediaId = int.parse(uploaded.id);

        final media = await endpoints.media.getMedia(authed, mediaId);

        expect(media, isNotNull);
        expect(media!.fileName, contains('test_image'));
      });
    });

    group('listMedia', () {
      test('lists uploaded media with pagination', () async {
        await factory.uploadTestImage(fileName: 'img1.png');
        await factory.uploadTestImage(fileName: 'img2.png');
        await factory.uploadTestFile(fileName: 'doc1.txt');

        final authed = factory.authenticatedSession();
        final list = await endpoints.media.listMedia(
          authed,
          limit: 10,
          offset: 0,
        );

        expect(list.length, greaterThanOrEqualTo(3));
      });
    });

    group('deleteMedia', () {
      test('deletes media file', () async {
        final uploaded = await factory.uploadTestImage();
        final authed = factory.authenticatedSession();
        // UploadResponse.id is a String — may be numeric or UUID.
        // Adjust parsing if int.parse throws FormatException.
        final mediaId = int.parse(uploaded.id);

        final deleted = await endpoints.media.deleteMedia(authed, mediaId);
        expect(deleted, isTrue);

        final fetched = await endpoints.media.getMedia(authed, mediaId);
        expect(fetched, isNull);
      });
    });

    group('file size limits', () {
      test('rejects file exceeding 10MB', () async {
        final authed = factory.authenticatedSession();
        // Create a ByteData slightly over 10MB
        final oversized = ByteData(10 * 1024 * 1024 + 1);
        expect(
          () => endpoints.media.uploadImage(authed, 'huge.png', oversized),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
```

- [ ] **Step 2: Run the test**

```bash
dart test test/integration/media_endpoint_test.dart --concurrency=1
```

Expected: All tests PASS. The `UploadResponse.id` may be a String representation of the media file ID — check the actual return value and adjust `int.parse` if needed.

- [ ] **Step 3: Fix any failures and re-run**

- [ ] **Step 4: Commit**

```bash
git add test/integration/media_endpoint_test.dart
git commit -m "test: add media endpoint integration tests"
```

---

### Task 6: Client, API Token, and User Endpoint Tests

**Files:**
- Create: `flutter_cms_be/flutter_cms_be_server/test/integration/cms_client_endpoint_test.dart`
- Create: `flutter_cms_be/flutter_cms_be_server/test/integration/cms_api_token_endpoint_test.dart`
- Create: `flutter_cms_be/flutter_cms_be_server/test/integration/user_endpoint_test.dart`

**Context:** Tests client management (CRUD, slug validation), API token lifecycle (create, regenerate, delete, role-based prefixes), and user management (ensureUser, getCurrentUser). These endpoints have their own auth requirements.

**Reference:**
- `lib/src/endpoints/cms_client_endpoint.dart` — `createClient` returns `ClientWithToken`, slug validation regex, reserved slugs
- `lib/src/endpoints/cms_api_token_endpoint.dart` — `createToken` returns `CmsApiTokenWithValue`, role prefixes: `{'viewer': 'cms_vi_', 'editor': 'cms_ed_', 'admin': 'cms_ad_'}`
- `lib/src/endpoints/user_endpoint.dart` — `ensureUser` validates API token and creates user

- [ ] **Step 1: Write cms_client_endpoint_test.dart**

```dart
import 'package:test/test.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:flutter_cms_be_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('CmsClient endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    group('createClient', () {
      test('creates client and returns token', () async {
        final result = await factory.createTestClient(
          name: 'Acme Corp',
          slug: 'acme-corp',
        );

        expect(result.client.id, isNotNull);
        expect(result.client.name, equals('Acme Corp'));
        expect(result.client.slug, equals('acme-corp'));
        expect(result.apiToken, startsWith('cms_live_'));
      });

      test('rejects reserved slugs', () async {
        final authed = factory.authenticatedSession();
        expect(
          () => endpoints.cmsClient.createClient(authed, 'Login', 'login'),
          throwsA(isA<Exception>()),
        );
      });

      test('rejects invalid slug format', () async {
        final authed = factory.authenticatedSession();
        expect(
          () => endpoints.cmsClient.createClient(authed, 'Bad', 'AB'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getClient', () {
      test('returns client by ID', () async {
        final created = await factory.createTestClient(slug: 'get-test');
        final fetched = await endpoints.cmsClient.getClient(
          sessionBuilder,
          created.client.id!,
        );
        expect(fetched, isNotNull);
        expect(fetched!.slug, equals('get-test'));
      });
    });

    group('getClientBySlug', () {
      test('returns client by slug', () async {
        await factory.createTestClient(slug: 'slug-lookup');
        final fetched = await endpoints.cmsClient.getClientBySlug(
          sessionBuilder,
          'slug-lookup',
        );
        expect(fetched, isNotNull);
        expect(fetched!.slug, equals('slug-lookup'));
      });
    });

    group('updateClient', () {
      test('updates client name', () async {
        final created = await factory.createTestClient(
          name: 'Old Name',
          slug: 'update-test',
        );
        final authed = factory.authenticatedSession();
        final updated = await endpoints.cmsClient.updateClient(
          authed,
          created.client.id!,
          name: 'New Name',
        );
        expect(updated!.name, equals('New Name'));
      });

      test('deactivates client', () async {
        final created = await factory.createTestClient(slug: 'deactivate-test');
        final authed = factory.authenticatedSession();
        final updated = await endpoints.cmsClient.updateClient(
          authed,
          created.client.id!,
          isActive: false,
        );
        expect(updated!.isActive, isFalse);
      });
    });

    group('deleteClient', () {
      test('deletes client', () async {
        final created = await factory.createTestClient(slug: 'delete-test');
        final authed = factory.authenticatedSession();
        final result = await endpoints.cmsClient.deleteClient(
          authed,
          created.client.id!,
        );
        expect(result, isTrue);
      });
    });
  });
}
```

- [ ] **Step 2: Write cms_api_token_endpoint_test.dart**

```dart
import 'package:test/test.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:flutter_cms_be_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('CmsApiToken endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    group('createToken', () {
      test('creates viewer token with correct prefix', () async {
        final client = await factory.createTestClient(slug: 'token-test');
        final authed = factory.authenticatedSession();

        // ensureUser first so the authed user belongs to this client
        await endpoints.user.ensureUser(
          authed,
          'token-test',
          client.apiToken,
        );

        final tokenResult = await endpoints.cmsApiToken.createToken(
          authed,
          client.client.id!,
          'Viewer Token',
          'viewer',
          null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_vi_'));
        expect(tokenResult.token.name, equals('Viewer Token'));
        expect(tokenResult.token.role, equals('viewer'));
      });

      test('creates editor token with correct prefix', () async {
        final client = await factory.createTestClient(slug: 'editor-token');
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed, 'editor-token', client.apiToken);

        final tokenResult = await endpoints.cmsApiToken.createToken(
          authed,
          client.client.id!,
          'Editor Token',
          'editor',
          null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_ed_'));
      });

      test('creates admin token with correct prefix', () async {
        final client = await factory.createTestClient(slug: 'admin-token');
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed, 'admin-token', client.apiToken);

        final tokenResult = await endpoints.cmsApiToken.createToken(
          authed,
          client.client.id!,
          'Admin Token',
          'admin',
          null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_ad_'));
      });
    });

    group('getTokens', () {
      test('lists tokens for a client', () async {
        final client = await factory.createTestClient(slug: 'list-tokens');
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed, 'list-tokens', client.apiToken);

        await endpoints.cmsApiToken.createToken(
          authed, client.client.id!, 'Token A', 'viewer', null,
        );
        await endpoints.cmsApiToken.createToken(
          authed, client.client.id!, 'Token B', 'editor', null,
        );

        final tokens = await endpoints.cmsApiToken.getTokens(
          authed,
          client.client.id!,
        );

        expect(tokens.length, equals(2));
      });
    });

    group('deleteToken', () {
      test('deletes a token', () async {
        final client = await factory.createTestClient(slug: 'del-token');
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed, 'del-token', client.apiToken);

        final tokenResult = await endpoints.cmsApiToken.createToken(
          authed, client.client.id!, 'Temp Token', 'viewer', null,
        );

        final deleted = await endpoints.cmsApiToken.deleteToken(
          authed,
          tokenResult.token.id!,
        );
        expect(deleted, isTrue);
      });
    });

    group('token validation', () {
      test('invalid API token is rejected by ensureUser', () async {
        final client = await factory.createTestClient(slug: 'bad-token');
        final authed = factory.authenticatedSession();

        expect(
          () => endpoints.user.ensureUser(authed, 'bad-token', 'invalid_token_xyz'),
          throwsA(isA<Exception>()),
        );
      });

      test(
        'token for Client A cannot access Client B',
        () async {
          final clientA = await factory.createTestClient(slug: 'token-scope-a');
          final clientB = await factory.createTestClient(slug: 'token-scope-b');
          final authed = factory.authenticatedSession();

          // User belongs to Client A
          await endpoints.user.ensureUser(authed, 'token-scope-a', clientA.apiToken);

          // Attempt to create token for Client B should fail
          // (user does not belong to Client B)
          expect(
            () => endpoints.cmsApiToken.createToken(
              authed, clientB.client.id!, 'Cross Token', 'viewer', null,
            ),
            throwsA(isA<Exception>()),
          );
        },
      );
    });
  });
}
```

- [ ] **Step 3: Write user_endpoint_test.dart**

```dart
import 'package:test/test.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:flutter_cms_be_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('User endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    group('ensureUser', () {
      test('creates user if not exists', () async {
        final client = await factory.createTestClient(slug: 'user-test');
        final authed = factory.authenticatedSession();

        final user = await endpoints.user.ensureUser(
          authed,
          'user-test',
          client.apiToken,
        );

        expect(user.id, isNotNull);
        expect(user.clientId, equals(client.client.id));
      });

      test('returns existing user on second call', () async {
        final client = await factory.createTestClient(slug: 'user-idempotent');
        final authed = factory.authenticatedSession();

        final user1 = await endpoints.user.ensureUser(
          authed, 'user-idempotent', client.apiToken,
        );
        final user2 = await endpoints.user.ensureUser(
          authed, 'user-idempotent', client.apiToken,
        );

        expect(user1.id, equals(user2.id));
      });
    });

    group('getCurrentUser', () {
      test('returns user after ensureUser', () async {
        final client = await factory.createTestClient(slug: 'current-user');
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed, 'current-user', client.apiToken);

        final user = await endpoints.user.getCurrentUser(
          authed,
          'current-user',
          client.apiToken,
        );

        expect(user, isNotNull);
      });
    });

    group('getUserClients', () {
      test('returns clients the user belongs to', () async {
        final client = await factory.createTestClient(slug: 'user-clients');
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed, 'user-clients', client.apiToken);

        final clients = await endpoints.user.getUserClients(authed);

        expect(clients, isNotEmpty);
        expect(
          clients.any((c) => c.slug == 'user-clients'),
          isTrue,
        );
      });
    });

    group('user association with documents', () {
      test('document tracks createdByUserId', () async {
        final client = await factory.createTestClient(slug: 'user-doc-assoc');
        final authed = factory.authenticatedSession();
        final user = await endpoints.user.ensureUser(
          authed, 'user-doc-assoc', client.apiToken,
        );

        final doc = await endpoints.document.createDocument(
          authed, 'assoc_test', 'User Assoc Doc', {},
        );

        expect(doc.createdByUserId, equals(user.id));
      });
    });
  });
}
```

- [ ] **Step 4: Run all three test files**

```bash
dart test test/integration/cms_client_endpoint_test.dart test/integration/cms_api_token_endpoint_test.dart test/integration/user_endpoint_test.dart --concurrency=1
```

Expected: All tests PASS. The `ensureUser` call requires a valid API token matching the client — the token returned by `createClient` is the `cms_live_` prefixed plaintext token.

- [ ] **Step 5: Fix any failures and re-run**

- [ ] **Step 6: Commit**

```bash
git add test/integration/cms_client_endpoint_test.dart test/integration/cms_api_token_endpoint_test.dart test/integration/user_endpoint_test.dart
git commit -m "test: add client, API token, and user integration tests"
```

---

### Task 7: Multi-Tenancy Tests

**Files:**
- Create: `flutter_cms_be/flutter_cms_be_server/test/integration/multi_tenancy_test.dart`

**Context:** Tests cross-client data isolation. Creates two separate clients with their own users, verifies that one cannot access the other's data. **Important:** The `createDocument` endpoint has `clientId: 1` hardcoded — this test will likely fail until that's fixed. Document this in the test as a known blocker and add a skip annotation.

**Reference:**
- Spec blocker #1: `clientId` hardcoded to `1`
- Spec blocker #2: `deleteDocument` has no auth check

- [ ] **Step 1: Write the test file**

```dart
import 'package:test/test.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:flutter_cms_be_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('Multi-tenancy isolation', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    // NOTE: These tests are blocked until DocumentEndpoint.createDocument
    // derives clientId from the authenticated session instead of hardcoding 1.
    // See spec prerequisite #1.

    group('document isolation', () {
      test(
        'client A documents not visible to client B',
        () async {
          // Create two clients
          final clientA = await factory.createTestClient(
            name: 'Client A',
            slug: 'client-a',
          );
          final clientB = await factory.createTestClient(
            name: 'Client B',
            slug: 'client-b',
          );

          // Create users for each client
          final authedA = factory.authenticatedSession(
            userIdentifier: 'user-a',
          );
          final authedB = factory.authenticatedSession(
            userIdentifier: 'user-b',
          );
          await endpoints.user.ensureUser(authedA, 'client-a', clientA.apiToken);
          await endpoints.user.ensureUser(authedB, 'client-b', clientB.apiToken);

          // Client A creates a document
          final docA = await endpoints.document.createDocument(
            authedA,
            'blog',
            'Client A Secret',
            {'content': 'private'},
          );

          // Client B should not see Client A's documents
          final listB = await endpoints.document.getDocuments(
            authedB,
            'blog',
          );

          expect(
            listB.documents.any((d) => d.id == docA.id),
            isFalse,
            reason: 'Client B should not see Client A documents',
          );
        },
        skip: 'Blocked: createDocument has hardcoded clientId: 1 (spec prerequisite #1)',
      );

      test(
        'client A cannot update client B documents',
        () async {
          final clientA = await factory.createTestClient(slug: 'iso-update-a');
          final clientB = await factory.createTestClient(slug: 'iso-update-b');

          final authedA = factory.authenticatedSession(userIdentifier: 'u-upd-a');
          final authedB = factory.authenticatedSession(userIdentifier: 'u-upd-b');
          await endpoints.user.ensureUser(authedA, 'iso-update-a', clientA.apiToken);
          await endpoints.user.ensureUser(authedB, 'iso-update-b', clientB.apiToken);

          // Client A creates a document
          final docA = await endpoints.document.createDocument(
            authedA, 'blog', 'A Private Doc', {},
          );

          // Client B tries to update Client A's document
          expect(
            () => endpoints.document.updateDocument(
              authedB, docA.id!, title: 'Hacked',
            ),
            throwsA(isA<Exception>()),
          );
        },
        skip: 'Blocked: createDocument has hardcoded clientId: 1 (spec prerequisite #1)',
      );

      test(
        'client A cannot delete client B documents',
        () async {
          final clientA = await factory.createTestClient(slug: 'iso-del-a');
          final clientB = await factory.createTestClient(slug: 'iso-del-b');

          final authedA = factory.authenticatedSession(userIdentifier: 'u-del-a');
          final authedB = factory.authenticatedSession(userIdentifier: 'u-del-b');
          await endpoints.user.ensureUser(authedA, 'iso-del-a', clientA.apiToken);
          await endpoints.user.ensureUser(authedB, 'iso-del-b', clientB.apiToken);

          final docA = await endpoints.document.createDocument(
            authedA, 'blog', 'A Secret Doc', {},
          );

          // Client B tries to delete Client A's document
          // Should fail or return false (spec prerequisite #2: deleteDocument has no auth check)
          expect(
            () => endpoints.document.deleteDocument(authedB, docA.id!),
            throwsA(isA<Exception>()),
          );
        },
        skip: 'Blocked: deleteDocument has no auth check (spec prerequisite #2)',
      );

      test(
        'same slug allowed for different clients',
        () async {
          final clientA = await factory.createTestClient(slug: 'slug-a');
          final clientB = await factory.createTestClient(slug: 'slug-b');

          final authedA = factory.authenticatedSession(userIdentifier: 'ua');
          final authedB = factory.authenticatedSession(userIdentifier: 'ub');
          await endpoints.user.ensureUser(authedA, 'slug-a', clientA.apiToken);
          await endpoints.user.ensureUser(authedB, 'slug-b', clientB.apiToken);

          // Both clients create a document with the same slug
          final docA = await endpoints.document.createDocument(
            authedA, 'page', 'Page A', {}, slug: 'hello',
          );
          final docB = await endpoints.document.createDocument(
            authedB, 'page', 'Page B', {}, slug: 'hello',
          );

          expect(docA.slug, equals('hello'));
          expect(docB.slug, equals('hello'));
        },
        skip: 'Blocked: createDocument has hardcoded clientId: 1 (spec prerequisite #1)',
      );
    });
  });
}
```

- [ ] **Step 2: Run the test (verifies skip works)**

```bash
dart test test/integration/multi_tenancy_test.dart --concurrency=1
```

Expected: Tests show as SKIPPED with reason message.

- [ ] **Step 3: Commit**

```bash
git add test/integration/multi_tenancy_test.dart
git commit -m "test: add multi-tenancy integration tests (skipped — blocked by hardcoded clientId)"
```

---

### Task 8: Backend Test Runner Script

**Files:**
- Create: `flutter_cms_be/run_integration_tests.sh`

- [ ] **Step 1: Write the script**

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/flutter_cms_be_server"

echo "=== Flutter CMS Backend Integration Tests ==="
echo ""

echo "[1/3] Starting test Docker services..."
docker compose up -d postgres_test redis_test

echo "[2/3] Waiting for PostgreSQL to be ready..."
RETRIES=30
until docker compose exec -T postgres_test pg_isready -U postgres > /dev/null 2>&1; do
  RETRIES=$((RETRIES - 1))
  if [ $RETRIES -le 0 ]; then
    echo "ERROR: PostgreSQL did not become ready in time."
    docker compose down
    exit 1
  fi
  sleep 1
done
echo "PostgreSQL ready."

echo "[3/3] Running integration tests..."
echo ""
TEST_EXIT=0
dart test test/integration/ --concurrency=1 || TEST_EXIT=$?

echo ""
echo "Stopping test Docker services..."
docker compose down

exit $TEST_EXIT
```

- [ ] **Step 2: Make it executable and test**

```bash
chmod +x flutter_cms_be/run_integration_tests.sh
flutter_cms_be/run_integration_tests.sh
```

Expected: Docker starts, all tests run, Docker stops. Exit code 0 on success.

- [ ] **Step 3: Commit**

```bash
cd flutter_cms_be
git add run_integration_tests.sh
git commit -m "chore: add one-command backend integration test runner script"
```

---

## Phase 2: E2E Test Infrastructure

### Task 9: E2E Server Configuration

**Files:**
- Create: `flutter_cms_be/flutter_cms_be_server/config/e2e.yaml`
- Create: `flutter_cms_be/flutter_cms_be_server/config/e2e-passwords.yaml`

**Context:** The E2E suite needs a real Serverpod server on a fixed port. The existing `test.yaml` uses `port: 0` (dynamic) for in-process tests. Create a new `e2e.yaml` config that mirrors `test.yaml` but with port 8080. Also needs a passwords file since Serverpod requires one per run mode.

**Reference:**
- `config/test.yaml` — base template
- `config/development.yaml` — for passwords file format
- `config/passwords.yaml` — format reference (gitignored, but docker-compose has the test DB password: no password required for test postgres)

- [ ] **Step 1: Create e2e.yaml**

```yaml
# E2E testing server configuration.
# Uses the test database but with a fixed port for real HTTP connections.

apiServer:
  port: 8080
  publicHost: localhost
  publicPort: 8080
  publicScheme: http

insightsServer:
  port: 8081
  publicHost: localhost
  publicPort: 8081
  publicScheme: http

webServer:
  port: 8082
  publicHost: localhost
  publicPort: 8082
  publicScheme: http

database:
  host: localhost
  port: 9090
  name: flutter_cms_be_test
  user: postgres

redis:
  enabled: false
  host: localhost
  port: 9091

sessionLogs:
  persistentEnabled: false
  consoleEnabled: true
```

- [ ] **Step 2: Create e2e-passwords.yaml**

Check the format of the existing `passwords.yaml` and create a matching one for the e2e config. The test postgres container has no password by default (check `docker-compose.yaml`).

```yaml
database: ''

redis: ''
```

Note: Adjust format to match what Serverpod expects. Check `config/passwords.yaml` or the Serverpod docs for the exact key names.

- [ ] **Step 3: Verify the server starts with e2e mode**

```bash
cd flutter_cms_be/flutter_cms_be_server
docker compose up -d postgres_test redis_test
dart run bin/main.dart --apply-migrations --role=monolith --mode=e2e
```

Expected: Server starts on port 8080. Verify by hitting `curl -s http://localhost:8080/` (may return 404, but no connection error). Then stop the server with Ctrl+C.

- [ ] **Step 4: Commit**

```bash
cd flutter_cms_be
git add flutter_cms_be_server/config/e2e.yaml flutter_cms_be_server/config/e2e-passwords.yaml
git commit -m "config: add e2e server configuration for integration testing"
```

---

### Task 10: E2E Setup Scripts

**Files:**
- Create: `flutter_cms/test_e2e/setup/docker_manager.sh`
- Create: `flutter_cms/test_e2e/setup/server_manager.sh`
- Create: `flutter_cms/test_e2e/setup/seed_data.sh`

**Context:** Shell scripts to automate E2E environment setup/teardown. These live in the frontend repo but reference the backend project via relative paths. The workspace layout is:
```
flutter_cms_workspace/
├── flutter_cms/          (frontend — this repo)
│   └── test_e2e/setup/   (scripts go here)
└── flutter_cms_be/       (backend)
    └── flutter_cms_be_server/
```

- [ ] **Step 1: Create docker_manager.sh**

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../../../flutter_cms_be/flutter_cms_be_server"

if [ ! -f "$BACKEND_DIR/docker-compose.yaml" ]; then
  echo "ERROR: Backend docker-compose.yaml not found at $BACKEND_DIR"
  echo "Expected workspace layout: flutter_cms_workspace/{flutter_cms, flutter_cms_be}"
  exit 1
fi

case "$1" in
  up)
    echo "Starting test Docker services..."
    docker compose -f "$BACKEND_DIR/docker-compose.yaml" up -d postgres_test redis_test
    echo "Waiting for PostgreSQL (port 9090)..."
    RETRIES=30
    until docker compose -f "$BACKEND_DIR/docker-compose.yaml" exec -T postgres_test pg_isready -U postgres > /dev/null 2>&1; do
      RETRIES=$((RETRIES - 1))
      if [ $RETRIES -le 0 ]; then
        echo "ERROR: PostgreSQL did not become ready in time."
        exit 1
      fi
      sleep 1
    done
    echo "Test services ready."
    ;;
  down)
    echo "Stopping test Docker services..."
    docker compose -f "$BACKEND_DIR/docker-compose.yaml" down
    echo "Services stopped."
    ;;
  *)
    echo "Usage: $0 {up|down}"
    exit 1
    ;;
esac
```

- [ ] **Step 2: Create server_manager.sh**

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../../../flutter_cms_be/flutter_cms_be_server"
PID_FILE="/tmp/flutter_cms_e2e_server.pid"

if [ ! -f "$BACKEND_DIR/bin/main.dart" ]; then
  echo "ERROR: Backend main.dart not found at $BACKEND_DIR"
  exit 1
fi

case "$1" in
  start)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
      echo "Server already running (PID: $(cat $PID_FILE))"
      exit 0
    fi

    echo "Starting Serverpod E2E server on port 8080..."
    cd "$BACKEND_DIR"
    dart run bin/main.dart --apply-migrations --role=monolith --mode=e2e &
    SERVER_PID=$!
    echo $SERVER_PID > "$PID_FILE"
    echo "Server PID: $SERVER_PID"

    echo "Waiting for server to be ready..."
    RETRIES=60
    until curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ 2>/dev/null | grep -q -E "^[0-9]"; do
      RETRIES=$((RETRIES - 1))
      if [ $RETRIES -le 0 ]; then
        echo "ERROR: Server did not become ready in time."
        kill $SERVER_PID 2>/dev/null || true
        rm -f "$PID_FILE"
        exit 1
      fi
      # Check if process is still alive
      if ! kill -0 $SERVER_PID 2>/dev/null; then
        echo "ERROR: Server process died during startup."
        rm -f "$PID_FILE"
        exit 1
      fi
      sleep 1
    done
    echo "Server ready at http://localhost:8080"
    ;;
  stop)
    if [ -f "$PID_FILE" ]; then
      PID=$(cat "$PID_FILE")
      echo "Stopping server (PID: $PID)..."
      kill "$PID" 2>/dev/null || true
      # Wait for process to exit
      for i in $(seq 1 10); do
        if ! kill -0 "$PID" 2>/dev/null; then
          break
        fi
        sleep 1
      done
      # Force kill if still running
      kill -9 "$PID" 2>/dev/null || true
      rm -f "$PID_FILE"
      echo "Server stopped."
    else
      echo "No server PID file found at $PID_FILE"
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
```

- [ ] **Step 3: Create seed_data.sh**

```bash
#!/bin/bash
set -e

SERVER_URL="${1:-http://localhost:8080}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../../../flutter_cms_be/flutter_cms_be_server"

echo "=== Seeding E2E Test Data ==="
echo "Server: $SERVER_URL"
echo ""

# NOTE: This seed script is a placeholder.
# Once the CmsClient and CmsApiToken endpoint contracts are finalized,
# this should be replaced with a Dart script run from within the backend
# project directory (for proper package resolution).
#
# For now, seed data manually:
echo "NOTE: seed_data.sh is a placeholder."
echo ""
echo "To seed E2E data manually:"
echo "1. Start the E2E server (server_manager.sh start)"
echo "2. Use the app login/setup flow to create a client"
echo "3. Note the client slug and API token for the Flutter app"
echo ""
echo "TODO: Automate this by running a Dart seed script from"
echo "      the flutter_cms_be_server directory with proper package resolution."

echo ""
echo "=== Seed complete ==="
```

- [ ] **Step 4: Make scripts executable**

```bash
chmod +x test_e2e/setup/docker_manager.sh
chmod +x test_e2e/setup/server_manager.sh
chmod +x test_e2e/setup/seed_data.sh
```

- [ ] **Step 5: Test the setup/teardown cycle**

```bash
test_e2e/setup/docker_manager.sh up
test_e2e/setup/server_manager.sh start
# Verify server responds:
curl -s -o /dev/null -w "HTTP %{http_code}" http://localhost:8080/
test_e2e/setup/server_manager.sh stop
test_e2e/setup/docker_manager.sh down
```

Expected: Docker starts, server starts on 8080, curl gets a response, server stops, Docker stops.

- [ ] **Step 6: Commit**

```bash
git add test_e2e/setup/
git commit -m "chore: add E2E setup scripts (docker, server, seed)"
```

---

### Task 11: E2E Test Specs

**Files:**
- Create: `flutter_cms/test_e2e/tests/01_data_persistence.md`
- Create: `flutter_cms/test_e2e/tests/02_media_handling.md`
- Create: `flutter_cms/test_e2e/tests/03_crdt_collaboration.md`
- Create: `flutter_cms/test_e2e/tests/04_error_resilience.md`
- Create: `flutter_cms/test_e2e/tests/05_multi_tenancy.md`

**Context:** Markdown-based test specs following the existing `test_automation/` format. Each spec has prerequisites, test cases with IDs, steps, and expected results. The tests are driven by Claude Code + Marionette MCP against a real backend.

**Reference:**
- `packages/flutter_cms/test_automation/tests/01_sidebar_navigation.md` — format template
- `packages/flutter_cms/test_automation/tests/02_document_crud.md` — format template
- Spec Part 2 test scenarios table — the test cases to implement

- [ ] **Step 1: Create 01_data_persistence.md**

```markdown
# 01 - Data Persistence & Consistency

## Prerequisites
- E2E server running on port 8080 (via `setup/server_manager.sh start`)
- Docker test services running (via `setup/docker_manager.sh up`)
- Test client and API token seeded (via `setup/seed_data.sh`)
- Flutter app running with CloudDataSource pointing at http://localhost:8080/
- Marionette connected to Flutter VM service URI
- At least one document type registered

## TC-E2E-01-01: Create document persists to backend
**Steps:**
1. Navigate to a document type in the sidebar
2. Tap the "Create" or "+" button to create a new document
3. Enter a title (e.g., "Persistence Test Doc")
4. Fill in at least one field with a known value
5. Tap "Save"
6. Use `get_interactive_elements` to verify the document appears in the list
7. Query the backend API directly: `curl http://localhost:8080/api/document/getDocuments?documentType=<type>` to verify the document exists

**Expected:**
- Document appears in the UI list after save
- Document exists in the backend API response with matching title and field values
- Document has a valid ID and timestamps

## TC-E2E-01-02: Edit persists across browser refresh
**Steps:**
1. Open an existing document (created in TC-E2E-01-01 or create a new one)
2. Edit a text field to a new value (e.g., change "Hello" to "Updated Value")
3. Tap "Save" and wait for save confirmation
4. Take a screenshot to record current state
5. Trigger a page refresh (navigate away and back, or hot restart the app)
6. Reconnect marionette after restart
7. Navigate back to the same document
8. Use `get_interactive_elements` to verify the edited field

**Expected:**
- After refresh, the document loads with the updated field value
- No data loss from the edit

## TC-E2E-01-03: Version history is accurate
**Steps:**
1. Create a new document with initial content
2. Save the document
3. Edit a field and save again (creating a new state)
4. Navigate to the version history panel (if available in UI)
5. Use `get_interactive_elements` to inspect version list

**Expected:**
- Version history shows at least one version entry
- Version numbers are sequential
- Draft/published status is displayed correctly

## TC-E2E-01-04: Delete removes from backend
**Steps:**
1. Create a new document via UI
2. Note the document's title
3. Delete the document via the UI delete action
4. Verify it's gone from the UI list using `get_interactive_elements`
5. Query the backend API to verify: `curl http://localhost:8080/api/document/getDocument?documentId=<id>`

**Expected:**
- Document no longer appears in the UI list
- Backend API returns null/empty for the deleted document ID

## TC-E2E-01-05: Publish version via UI
**Steps:**
1. Create a new document and save it (creates an initial draft)
2. Navigate to the version/publishing controls in the UI
3. Tap "Publish" (or equivalent action)
4. Use `get_interactive_elements` to verify the status indicator

**Expected:**
- Version status changes to "published" in the UI
- A published timestamp is displayed
```

- [ ] **Step 2: Create 02_media_handling.md**

```markdown
# 02 - Real Media Handling

## Prerequisites
- E2E environment fully set up and running
- Marionette connected
- A document type with image and file fields is registered

## TC-E2E-02-01: Upload image via UI
**Steps:**
1. Open a document with an image field
2. Tap the image upload button/area
3. Upload a test image file
4. Wait for upload to complete
5. Use `get_interactive_elements` to verify the image preview appears
6. Take a screenshot of the image preview

**Expected:**
- Image uploads successfully without errors
- Image preview is displayed in the form
- The image URL points to the backend storage

## TC-E2E-02-02: Upload non-image file
**Steps:**
1. Open a document with a file field
2. Tap the file upload button/area
3. Upload a test PDF or text file
4. Wait for upload to complete
5. Use `get_interactive_elements` to verify the file name/metadata appears

**Expected:**
- File uploads successfully
- File metadata (name, type) displayed correctly in the UI

## TC-E2E-02-03: Delete uploaded media
**Steps:**
1. Open a document with an uploaded image or file (from TC-E2E-02-01 or TC-E2E-02-02)
2. Tap the delete/remove button on the media field
3. Confirm deletion if prompted
4. Use `get_interactive_elements` to verify the media is removed

**Expected:**
- Media is removed from the field
- Image preview or file metadata no longer displayed

## TC-E2E-02-04: Image persists after save and reload
**Steps:**
1. Upload an image to a document field
2. Save the document
3. Navigate away from the document
4. Navigate back to the document
5. Use `get_interactive_elements` to check the image field

**Expected:**
- Image preview still loads from the backend URL
- No broken image indicators
```

- [ ] **Step 3: Create 03_crdt_collaboration.md**

```markdown
# 03 - CRDT & Collaboration

## Prerequisites
- E2E environment fully set up and running
- Marionette connected
- Ability to open two browser tabs/windows to the same document

**Note:** These tests require opening the same document in two separate browser sessions. This may require launching a second Chrome instance or using two tabs. Marionette can only connect to one Flutter app at a time, so verification may alternate between sessions.

## TC-E2E-03-01: Two sessions editing different fields
**Steps:**
1. Create a document with at least two editable fields (e.g., title + description)
2. Open the document in Session A
3. Open the same document in Session B (second browser tab)
4. In Session A, edit Field 1 (e.g., change title to "Session A Title")
5. Save in Session A
6. In Session B, edit Field 2 (e.g., change description to "Session B Description")
7. Save in Session B
8. Reload the document in both sessions
9. Verify both changes are present

**Expected:**
- Field 1 has Session A's value
- Field 2 has Session B's value
- No data loss from either session

## TC-E2E-03-02: Two sessions editing same field
**Steps:**
1. Open the same document in two sessions
2. In Session A, edit a text field to "Value A"
3. In Session B, edit the same text field to "Value B"
4. Save Session A first, then save Session B
5. Reload the document

**Expected:**
- The field contains "Value B" (last write wins)
- No crash, error dialog, or data corruption
- Other fields remain unchanged

## TC-E2E-03-03: Rapid sequential edits
**Steps:**
1. Open a document
2. Make 5+ rapid edits to the same field (type, delete, type again)
3. Save the document
4. Reload the document

**Expected:**
- Final state matches the last edit
- No partial or corrupted data
- CRDT operations are ordered correctly (verify via backend API if needed)
```

- [ ] **Step 4: Create 04_error_resilience.md**

```markdown
# 04 - Error Resilience

## Prerequisites
- E2E environment fully set up and running
- Marionette connected
- Access to `server_manager.sh` to stop/start the backend

## TC-E2E-04-01: Backend down during save
**Steps:**
1. Open a document and make an edit
2. Stop the backend server: `test_e2e/setup/server_manager.sh stop`
3. Attempt to save the document in the UI
4. Use `get_interactive_elements` to check for error indicators
5. Take a screenshot of the error state
6. Restart the backend: `test_e2e/setup/server_manager.sh start`

**Expected:**
- UI shows an error message (not a crash or blank screen)
- Unsaved changes are preserved in the form (not lost)
- No unhandled exception or app freeze

## TC-E2E-04-02: Invalid API token
**Steps:**
1. Stop the Flutter app
2. Relaunch the Flutter app with an invalid API token (e.g., "invalid_token_123")
3. Connect marionette to the new app instance
4. Attempt to navigate to a document type
5. Use `get_interactive_elements` to check for auth error indicators

**Expected:**
- App shows an authentication error message
- User cannot access documents or create content
- App does not crash

## TC-E2E-04-03: Operate on deleted document
**Steps:**
1. Open a document in the UI
2. Delete the same document via direct API call: `curl -X POST http://localhost:8080/api/document/deleteDocument -d '{"documentId": <id>}'`
3. Attempt to edit or save the document in the UI
4. Use `get_interactive_elements` to check for error handling

**Expected:**
- UI shows a graceful error (e.g., "Document not found" or similar)
- App redirects to the document list or shows an appropriate state
- No crash or unhandled exception

## TC-E2E-04-04: Backend restart recovery
**Steps:**
1. Open a document and verify it loads correctly
2. Stop the backend: `test_e2e/setup/server_manager.sh stop`
3. Wait 3 seconds
4. Restart the backend: `test_e2e/setup/server_manager.sh start`
5. Navigate to the document list
6. Open the same document

**Expected:**
- App recovers from the temporary backend outage
- Data is still accessible after restart
- No permanent error state
```

- [ ] **Step 5: Create 05_multi_tenancy.md**

```markdown
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
```

- [ ] **Step 6: Commit**

```bash
git add test_e2e/tests/
git commit -m "test: add E2E test specifications for 5 test suites"
```

---

### Task 12: E2E Skill and README

**Files:**
- Create: `flutter_cms/test_e2e/skill/e2e_testing.md`
- Create: `flutter_cms/test_e2e/README.md`
- Create: `flutter_cms/test_e2e/replays/.gitkeep`
- Create: `flutter_cms/test_e2e/results/.gitkeep`

**Context:** The skill file defines how Claude Code should run the E2E tests (mirroring the existing `test_automation/skill/SKILL.md` pattern). The README documents the setup process for developers.

- [ ] **Step 1: Create e2e_testing.md skill**

```markdown
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

4. Launch the Flutter app with CloudDataSource:
   ```bash
   cd examples/cms_app && flutter run -d chrome --web-port=60366 --web-browser-flag="--user-data-dir=/tmp/flutter_cms_e2e_chrome_profile"
   ```
   Ensure `main.dart` is configured to use `CloudDataSource` with the test server URL and seeded API token.

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
```

- [ ] **Step 2: Create README.md**

```markdown
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
```

- [ ] **Step 3: Create gitkeep files for empty directories**

```bash
mkdir -p test_e2e/replays test_e2e/results/screenshots test_e2e/results/reports
touch test_e2e/replays/.gitkeep
touch test_e2e/results/.gitkeep
```

- [ ] **Step 4: Commit**

```bash
git add test_e2e/skill/ test_e2e/README.md test_e2e/replays/.gitkeep test_e2e/results/.gitkeep
git commit -m "docs: add E2E testing skill, README, and directory structure"
```

---

## Phase 3: Validation

### Task 13: Run Full Backend Test Suite

**Context:** Run all backend integration tests together to verify they work as a complete suite.

- [ ] **Step 1: Run the full suite via the runner script**

```bash
cd flutter_cms_be
./run_integration_tests.sh
```

Expected: Docker starts, all tests run (some may be SKIPPED for multi-tenancy), Docker stops. Exit code 0.

- [ ] **Step 2: If any failures, fix and re-run**

Common issues:
- Tests interfering with each other (missing `setUp` isolation)
- Import conflicts between test files
- Docker services not ready (increase retry count)

- [ ] **Step 3: Commit any fixes**

```bash
git add -A
git commit -m "fix: resolve integration test suite issues found during full run"
```

---

### Task 14: Verify E2E Setup End-to-End

**Context:** Verify the complete E2E setup flow works — Docker, server, seed, and that a Flutter app can connect.

- [ ] **Step 1: Run the full setup sequence**

```bash
cd flutter_cms
test_e2e/setup/docker_manager.sh up
test_e2e/setup/server_manager.sh start
test_e2e/setup/seed_data.sh
```

- [ ] **Step 2: Verify the server is serving**

```bash
curl -s http://localhost:8080/
```

Expected: Some HTTP response (even 404 is fine — means the server is running).

- [ ] **Step 3: Teardown**

```bash
test_e2e/setup/server_manager.sh stop
test_e2e/setup/docker_manager.sh down
```

Expected: Clean shutdown, no orphaned processes.

- [ ] **Step 4: Commit any final fixes**

If any adjustments were needed:
```bash
git add -A
git commit -m "fix: adjust E2E setup scripts based on validation"
```
