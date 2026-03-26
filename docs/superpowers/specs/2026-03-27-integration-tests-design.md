# Integration Test Suite Design — dart_desk

**Date:** 2026-03-27
**Scope:** `packages/dart_desk` — Flutter integration_test suite replacing Marionette e2e tests
**References:** `packages/dart_desk/tests/e2e/tests/01_data_persistence.md`, `02_media_handling.md`, `07_image_upload_e2e.md`

---

## Approach

Flutter `integration_test` with the Robot Pattern, running against a real Serverpod backend authenticated via a pre-seeded API key. Each robot encapsulates all UI interactions for one screen or widget area. Tests call robot methods only — never `tester.tap()` or `find.*` directly.

**Why real backend:** Test cases verify backend persistence (document exists in DB after save, image asset deduplication by content hash, data survives reload). These cannot be meaningfully tested with `MockDataSource`.

**Auth strategy:** `DartDeskApp(serverUrl:, apiKey:)` — API key mode, no login screen. The key is a pre-seeded editor token created by `e2e_env.sh` before tests run.

---

## Active Test Scope

| Spec file | Status | Reason |
|---|---|---|
| `01_data_persistence.md` | ✅ Active | 5 tests |
| `02_media_handling.md` | ✅ Active | 4 tests, uses FakeImagePickerPlatform |
| `03_crdt_collaboration.md` | ⏭ Deferred | Requires two simultaneous WidgetTester sessions — not supported |
| `04_error_resilience.md` | ⏭ Deferred | Backend-down simulation not feasible in integration_test |
| `05_single_tenant_auth.md` | ⏭ Deferred | API key mode has no login screen |
| `07_image_upload_e2e.md` | ✅ Active | 4 tests, uses FakeImagePickerPlatform |

---

## Session Lifecycle

One APK build per test file. App stays warm between `testWidgets` calls within a file.

```
setUpAll:    DbHelper.reset() → DbHelper.seedDocuments() (if needed)
each test:   pumpTestApp(tester) → robot interactions
tearDownAll: DbHelper.reset()
```

`pumpTestApp` re-runs `runApp()` per test (cheap). DB is seeded once in `setUpAll` and shared across tests in the file. Tests that need a clean document state create their own documents and clean up via the UI.

---

## File Structure

```
packages/dart_desk/
└── integration_test/
    ├── test_utils/
    │   ├── test_app.dart              # pumpTestApp() + FakeImagePickerPlatform
    │   ├── db_helper.dart             # HTTP seed/reset against e2e backend
    │   ├── finders.dart               # CMS-specific widget finders
    │   └── test_document_type.dart    # integrationTestDocumentType definition
    ├── robots/
    │   ├── sidebar_robot.dart         # document type navigation in left panel
    │   ├── document_list_robot.dart   # list view: create, tap, delete
    │   ├── document_editor_robot.dart # editor: enter fields, save, publish
    │   └── image_field_robot.dart     # image field: upload, remove, verify preview
    ├── data_persistence_test.dart     # TC-E2E-01-01 through 01-05
    ├── media_handling_test.dart       # TC-E2E-02-01 through 02-04
    └── image_upload_test.dart         # TC-E2E-07-01 through 07-04
```

---

## Test Utilities

### `test_app.dart` — `pumpTestApp(WidgetTester tester)`

```dart
const testServerUrl = String.fromEnvironment(
  'TEST_SERVER_URL',
  defaultValue: 'http://localhost:8080/',
);
const testApiKey = String.fromEnvironment('TEST_API_KEY');

Future<void> pumpTestApp(WidgetTester tester) async {
  FakeImagePickerPlatform.install();
  await tester.pumpWidget(DartDeskApp(
    serverUrl: testServerUrl,
    apiKey: testApiKey,
    config: DartDeskConfig(documentTypes: [integrationTestDocumentType]),
  ));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}
```

`FakeImagePickerPlatform.install()` is idempotent — safe to call on every pump. Installed here so all test files get it automatically, including `media_handling_test.dart` and `image_upload_test.dart`. If it turns out not to be idempotent, move the call to `setUpAll` in each test file instead.

### `test_document_type.dart` — `integrationTestDocumentType`

A document type defined specifically for integration tests. Includes:
- A required string field (`title`)
- An optional text field (`body`)
- An image field (`image_field`)
- A file field (`file_field`)

Defined inline in `test_utils/` — not imported from `examples/data_models`.

### `db_helper.dart` — `DbHelper`

HTTP helpers calling the backend's e2e endpoints:

```dart
static Future<void> reset()
static Future<void> seedDocuments()     // seeds known documents if tests need pre-existing data
```

These call the same `e2e_env.sh`-backed endpoints used by the Marionette e2e setup. If HTTP seeding endpoints are not yet available, these are no-ops with a debug print — same pattern as `dart_desk_manage`.

### `finders.dart`

CMS-specific finders for widgets that don't expose standard text or key finders:

```dart
Finder findShadButton(String label)
Finder findShadInput(String placeholder)
Finder findByKey(String key)
```

---

## Robot Interfaces

### `SidebarRobot`
```dart
Future<void> tapDocumentType(String name)
void expectDocumentTypeVisible(String name)
```

### `DocumentListRobot`
```dart
Future<void> tapCreate()
Future<void> tapDocument(String title)
Future<void> deleteDocument(String title)
void expectDocumentVisible(String title)
void expectDocumentNotVisible(String title)
void expectEmptyState()
```

### `DocumentEditorRobot`
```dart
Future<void> enterField(String fieldKey, String value)
Future<void> tapSave()
Future<void> tapPublish()
Future<void> navigateBack()
void expectSaveConfirmation()
void expectFieldValue(String fieldKey, String value)
void expectPublishedStatus()
```

### `ImageFieldRobot`
```dart
Future<void> tapUpload(String fieldKey)
Future<void> tapRemove(String fieldKey)
void expectImagePreview(String fieldKey)
void expectFieldEmpty(String fieldKey)
```

---

## Test File Patterns

### `data_persistence_test.dart`

```dart
// References: packages/dart_desk/tests/e2e/tests/01_data_persistence.md

setUpAll(() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await DbHelper.reset();
});
tearDownAll(() => DbHelper.reset());

// TC-E2E-01-01: Create document persists to backend
testWidgets('...', (tester) async {
  await pumpTestApp(tester);
  final sidebar = SidebarRobot(tester);
  final list = DocumentListRobot(tester);
  final editor = DocumentEditorRobot(tester);

  await sidebar.tapDocumentType('Integration Test');
  await list.tapCreate();
  await editor.enterField('title', 'Persistence Test Doc');
  await editor.tapSave();
  editor.expectSaveConfirmation();
  await editor.navigateBack();
  list.expectDocumentVisible('Persistence Test Doc');
});

// TC-E2E-01-02: Edit persists across reload
// TC-E2E-01-03: Version history is accurate
// TC-E2E-01-04: Delete removes from backend
// TC-E2E-01-05: Publish version via UI
```

### `image_upload_test.dart`

```dart
// References: packages/dart_desk/tests/e2e/tests/07_image_upload_e2e.md

setUpAll(() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await DbHelper.reset();
});
tearDownAll(() => DbHelper.reset());

// TC-E2E-07-01: Upload image → backend receives file with metadata
testWidgets('...', (tester) async {
  await pumpTestApp(tester); // FakeImagePickerPlatform already installed
  final sidebar = SidebarRobot(tester);
  final list = DocumentListRobot(tester);
  final image = ImageFieldRobot(tester);

  await sidebar.tapDocumentType('Integration Test');
  await list.tapCreate();
  await image.tapUpload('image_field');
  image.expectImagePreview('image_field');
});

// TC-E2E-07-02: Uploaded image persists after save and reload
// TC-E2E-07-03: Upload, save, then delete image → data cleared
// TC-E2E-07-04: Upload same image twice → backend deduplicates
```

---

## pubspec.yaml Changes

Add to `packages/dart_desk/pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

---

## Constraints

- `TEST_API_KEY` must be a pre-seeded editor token — created by `e2e_env.sh` before running tests
- `TEST_SERVER_URL` defaults to `http://localhost:8080/`
- `FakeImagePickerPlatform` returns a bundled test PNG asset — registered once in `pumpTestApp`
- CRDT, error resilience, and auth tests are deferred until the framework supports multi-session or backend injection
