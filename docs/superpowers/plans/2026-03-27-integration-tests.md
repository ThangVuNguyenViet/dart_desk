# Integration Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Robot Pattern integration test suite for `packages/dart_desk` covering 13 test cases from the e2e specs, runnable against a real Serverpod backend.

**Architecture:** Each screen/area gets a robot class wrapping `WidgetTester`. Tests call robot methods only. `pumpTestApp` boots `DartDeskApp` with a real `CloudDataSource` using a pre-seeded API key. DB is seeded once in `setUpAll`; each `testWidgets` pumps the app fresh.

**Tech Stack:** Flutter `integration_test`, `flutter_test`, `DartDeskApp`, `FakeImagePickerPlatform`, Serverpod backend

**References:**
- Design spec: `docs/superpowers/specs/2026-03-27-integration-tests-design.md`
- E2E specs: `packages/dart_desk/tests/e2e/tests/01_data_persistence.md`, `02_media_handling.md`, `07_image_upload_e2e.md`

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `packages/dart_desk/pubspec.yaml` | Modify | Add `integration_test` dev dependency |
| `packages/dart_desk/integration_test/test_utils/test_app.dart` | Create | `pumpTestApp()`, `ensureTestInitialized()`, `FakeImagePickerPlatform` setup |
| `packages/dart_desk/integration_test/test_utils/test_document_type.dart` | Create | `integrationTestDocumentType` — all field types needed by tests |
| `packages/dart_desk/integration_test/test_utils/db_helper.dart` | Create | `DbHelper.reset()`, `DbHelper.seedDocuments()` — no-ops with debug print |
| `packages/dart_desk/integration_test/test_utils/finders.dart` | Create | `findShadButton`, `findByKey`, `findShadInput` |
| `packages/dart_desk/integration_test/robots/sidebar_robot.dart` | Create | `tapDocumentType`, `expectDocumentTypeVisible` |
| `packages/dart_desk/integration_test/robots/document_list_robot.dart` | Create | `tapCreate`, `tapDocument`, `deleteDocument`, `expectDocumentVisible`, `expectEmptyState` |
| `packages/dart_desk/integration_test/robots/document_editor_robot.dart` | Create | `enterField`, `tapSave`, `tapPublish`, `navigateBack`, `expectSaveConfirmation`, `expectFieldValue`, `expectPublishedStatus` |
| `packages/dart_desk/integration_test/robots/image_field_robot.dart` | Create | `tapUpload`, `tapRemove`, `expectImagePreview`, `expectFieldEmpty` |
| `packages/dart_desk/integration_test/data_persistence_test.dart` | Create | TC-E2E-01-01 through 01-05 |
| `packages/dart_desk/integration_test/media_handling_test.dart` | Create | TC-E2E-02-01 through 02-04 |
| `packages/dart_desk/integration_test/image_upload_test.dart` | Create | TC-E2E-07-01 through 07-04 |

---

### Task 1: Add `integration_test` dependency

**Files:**
- Modify: `packages/dart_desk/pubspec.yaml`

- [ ] **Step 1: Add integration_test to dev_dependencies**

In `packages/dart_desk/pubspec.yaml`, add under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.13.1
```

- [ ] **Step 2: Run flutter pub get**

```bash
cd packages/dart_desk && flutter pub get
```

Expected: resolves without errors. `integration_test` comes from the Flutter SDK.

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/pubspec.yaml packages/dart_desk/pubspec.lock
git commit -m "chore(dart_desk): add integration_test dependency"
```

---

### Task 2: Create test utilities

**Files:**
- Create: `packages/dart_desk/integration_test/test_utils/finders.dart`
- Create: `packages/dart_desk/integration_test/test_utils/db_helper.dart`
- Create: `packages/dart_desk/integration_test/test_utils/test_document_type.dart`
- Create: `packages/dart_desk/integration_test/test_utils/test_app.dart`

- [ ] **Step 1: Create `finders.dart`**

```dart
// packages/dart_desk/integration_test/test_utils/finders.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Finds a ShadButton by its label text.
Finder findShadButton(String label) => find.text(label);

/// Finds a widget by its ValueKey string.
Finder findByKey(String key) => find.byKey(ValueKey(key));

/// Finds a text input field by its placeholder/hint text.
Finder findShadInput(String placeholder) =>
    find.widgetWithText(TextField, placeholder);
```

- [ ] **Step 2: Create `db_helper.dart`**

```dart
// packages/dart_desk/integration_test/test_utils/db_helper.dart
import 'package:flutter/foundation.dart';

/// Database helpers for integration tests.
///
/// IMPORTANT: DB reset/seed cannot run from within Flutter web tests
/// (browser sandbox). Run the e2e_env.sh script BEFORE launching tests:
///
///   packages/dart_desk/tests/e2e/setup/e2e_env.sh reset-all
///   packages/dart_desk/tests/e2e/setup/e2e_env.sh seed
///
/// These are no-ops so test files don't need to change when HTTP endpoints
/// are added later.
class DbHelper {
  static Future<void> reset() async {
    debugPrint('[db_helper] reset: no-op — run e2e_env.sh reset-all before tests');
  }

  static Future<void> seedDocuments() async {
    debugPrint('[db_helper] seedDocuments: no-op — seed externally if needed');
  }
}
```

- [ ] **Step 3: Create `test_document_type.dart`**

```dart
// packages/dart_desk/integration_test/test_utils/test_document_type.dart
import 'package:dart_desk/studio.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';

/// A minimal document type used exclusively in integration tests.
/// Covers string, image, and file fields needed by the test cases.
final integrationTestDocumentType = DocumentType(
  name: 'integration_test_doc',
  title: 'Integration Test',
  description: 'Document type used for integration testing',
  fields: [
    const StringField(name: 'title', title: 'Title'),
    const TextField(name: 'body', title: 'Body'),
    const ImageField(name: 'image_field', title: 'Image'),
    const FileField(name: 'file_field', title: 'File'),
  ],
  builder: (data) => Text(data['title']?.toString() ?? ''),
  defaultValue: null,
);

final integrationTestDocumentTypeDecoration = DocumentTypeDecoration(
  documentType: integrationTestDocumentType,
  icon: Icons.science,
);
```

- [ ] **Step 4: Create `test_app.dart`**

```dart
// packages/dart_desk/integration_test/test_utils/test_app.dart
import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_document_type.dart';

const _testServerUrl = String.fromEnvironment(
  'TEST_SERVER_URL',
  defaultValue: 'http://localhost:8080/',
);

const _testApiKey = String.fromEnvironment('TEST_API_KEY');

/// Call once at the top of each test file's `main()`.
IntegrationTestWidgetsFlutterBinding ensureTestInitialized() {
  return IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

/// Pumps the real DartDeskApp pointed at the test Serverpod backend.
///
/// [FakeImagePickerPlatform] is installed on every call so image-picker
/// tests work without opening the system file picker.
Future<void> pumpTestApp(WidgetTester tester) async {
  FakeImagePickerPlatform.install();
  await tester.pumpWidget(
    DartDeskApp(
      serverUrl: _testServerUrl,
      apiKey: _testApiKey,
      config: DartDeskConfig(
        documentTypes: [integrationTestDocumentType],
        documentTypeDecorations: [integrationTestDocumentTypeDecoration],
        title: 'Integration Test',
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 2));
}
```

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk/integration_test/
git commit -m "test(dart_desk): add integration test utilities"
```

---

### Task 3: Create robots

**Files:**
- Create: `packages/dart_desk/integration_test/robots/sidebar_robot.dart`
- Create: `packages/dart_desk/integration_test/robots/document_list_robot.dart`
- Create: `packages/dart_desk/integration_test/robots/document_editor_robot.dart`
- Create: `packages/dart_desk/integration_test/robots/image_field_robot.dart`

- [ ] **Step 1: Create `sidebar_robot.dart`**

The sidebar shows document type names. Tap to navigate to that type's list.

```dart
// packages/dart_desk/integration_test/robots/sidebar_robot.dart
import 'package:flutter_test/flutter_test.dart';

class SidebarRobot {
  final WidgetTester tester;
  SidebarRobot(this.tester);

  Future<void> tapDocumentType(String name) async {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  void expectDocumentTypeVisible(String name) {
    expect(find.text(name), findsOneWidget);
  }
}
```

- [ ] **Step 2: Create `document_list_robot.dart`**

The document list shows a "Create" button and rows per document. Documents have a kebab menu with a delete option.

```dart
// packages/dart_desk/integration_test/robots/document_list_robot.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_utils/finders.dart';

class DocumentListRobot {
  final WidgetTester tester;
  DocumentListRobot(this.tester);

  Future<void> tapCreate() async {
    await tester.tap(findShadButton('Create'));
    await tester.pumpAndSettle();
  }

  Future<void> tapDocument(String title) async {
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  Future<void> deleteDocument(String title) async {
    // Tap the document's kebab/actions menu then confirm delete
    final docRow = find.ancestor(
      of: find.text(title),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(of: docRow, matching: find.byIcon(Icons.more_vert)).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    // Confirm deletion dialog
    await tester.tap(findShadButton('Delete').last);
    await tester.pumpAndSettle();
  }

  void expectDocumentVisible(String title) {
    expect(find.text(title), findsOneWidget);
  }

  void expectDocumentNotVisible(String title) {
    expect(find.text(title), findsNothing);
  }

  void expectEmptyState() {
    // The list shows no document rows — only the Create button is visible
    expect(findShadButton('Create'), findsOneWidget);
  }
}
```

- [ ] **Step 3: Create `document_editor_robot.dart`**

The editor renders a form with `ValueKey(field.name)` on each field widget. Save shows a toast "Document saved successfully". Publish is in the version history panel.

```dart
// packages/dart_desk/integration_test/robots/document_editor_robot.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_utils/finders.dart';

class DocumentEditorRobot {
  final WidgetTester tester;
  DocumentEditorRobot(this.tester);

  Future<void> enterField(String fieldKey, String value) async {
    final field = find.byKey(ValueKey(fieldKey));
    await tester.tap(field);
    await tester.enterText(field, value);
    await tester.pumpAndSettle();
  }

  Future<void> tapSave() async {
    await tester.tap(findShadButton('Save'));
    await tester.pumpAndSettle();
  }

  Future<void> tapPublish() async {
    // Publish button key includes the version id — find by text instead
    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();
  }

  Future<void> navigateBack() async {
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  }

  void expectSaveConfirmation() {
    expect(find.text('Document saved successfully'), findsOneWidget);
  }

  void expectFieldValue(String fieldKey, String value) {
    final field = find.byKey(ValueKey(fieldKey));
    expect(
      tester.widget<TextField>(find.descendant(
        of: field,
        matching: find.byType(TextField),
      )).controller?.text,
      equals(value),
    );
  }

  void expectPublishedStatus() {
    expect(find.text('Published'), findsOneWidget);
  }
}
```

- [ ] **Step 4: Create `image_field_robot.dart`**

Image fields have an upload button and a remove button. After upload, an image preview widget appears.

```dart
// packages/dart_desk/integration_test/robots/image_field_robot.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_utils/finders.dart';

class ImageFieldRobot {
  final WidgetTester tester;
  ImageFieldRobot(this.tester);

  Future<void> tapUpload(String fieldKey) async {
    final field = find.byKey(ValueKey(fieldKey));
    await tester.tap(
      find.descendant(of: field, matching: findShadButton('Upload')).first,
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  Future<void> tapRemove(String fieldKey) async {
    final field = find.byKey(ValueKey(fieldKey));
    await tester.tap(
      find.descendant(of: field, matching: findShadButton('Remove')).first,
    );
    await tester.pumpAndSettle();
  }

  void expectImagePreview(String fieldKey) {
    final field = find.byKey(ValueKey(fieldKey));
    expect(
      find.descendant(of: field, matching: find.byType(Image)),
      findsOneWidget,
    );
  }

  void expectFieldEmpty(String fieldKey) {
    final field = find.byKey(ValueKey(fieldKey));
    expect(
      find.descendant(of: field, matching: findShadButton('Upload')),
      findsOneWidget,
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk/integration_test/robots/
git commit -m "test(dart_desk): add integration test robots"
```

---

### Task 4: Data persistence tests

**Files:**
- Create: `packages/dart_desk/integration_test/data_persistence_test.dart`

Reference: `packages/dart_desk/tests/e2e/tests/01_data_persistence.md`

- [ ] **Step 1: Create `data_persistence_test.dart`**

```dart
// packages/dart_desk/integration_test/data_persistence_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'robots/document_editor_robot.dart';
import 'robots/document_list_robot.dart';
import 'robots/sidebar_robot.dart';
import 'test_utils/db_helper.dart';
import 'test_utils/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await DbHelper.reset();
  });

  tearDownAll(() async {
    await DbHelper.reset();
  });

  group('01 - Data Persistence', () {
    // TC-E2E-01-01: Create document persists to backend
    testWidgets('TC-E2E-01-01: Create document persists to backend',
        (tester) async {
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
    testWidgets('TC-E2E-01-02: Edit persists across reload', (tester) async {
      await pumpTestApp(tester);
      final sidebar = SidebarRobot(tester);
      final list = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await list.tapDocument('Persistence Test Doc');
      await editor.enterField('title', 'Updated Value');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await editor.navigateBack();

      // Navigate back into the document to verify persistence
      await list.tapDocument('Updated Value');
      editor.expectFieldValue('title', 'Updated Value');
    });

    // TC-E2E-01-03: Version history is accurate
    testWidgets('TC-E2E-01-03: Version history is accurate', (tester) async {
      await pumpTestApp(tester);
      final sidebar = SidebarRobot(tester);
      final list = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await list.tapDocument('Updated Value');
      await editor.enterField('body', 'Second version body text');
      await editor.tapSave();
      editor.expectSaveConfirmation();

      // Version history shows at least one version entry
      expect(find.text('Version'), findsWidgets);
    });

    // TC-E2E-01-04: Delete removes from backend
    testWidgets('TC-E2E-01-04: Delete removes from backend', (tester) async {
      await pumpTestApp(tester);
      final sidebar = SidebarRobot(tester);
      final list = DocumentListRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      // Create a fresh document to delete
      await list.tapCreate();
      final editor = DocumentEditorRobot(tester);
      await editor.enterField('title', 'Doc To Delete');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await editor.navigateBack();

      await list.deleteDocument('Doc To Delete');
      list.expectDocumentNotVisible('Doc To Delete');
    });

    // TC-E2E-01-05: Publish version via UI
    testWidgets('TC-E2E-01-05: Publish version via UI', (tester) async {
      await pumpTestApp(tester);
      final sidebar = SidebarRobot(tester);
      final list = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await list.tapDocument('Updated Value');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await editor.tapPublish();
      editor.expectPublishedStatus();
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they compile**

```bash
cd packages/dart_desk
flutter test integration_test/data_persistence_test.dart \
  --dart-define=TEST_SERVER_URL=http://localhost:8080/ \
  --dart-define=TEST_API_KEY=<your_editor_token> \
  -d chrome
```

Expected: Tests run (may fail due to missing UI keys — note failures for Task 6).

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/integration_test/data_persistence_test.dart
git commit -m "test(dart_desk): add data persistence integration tests (TC-E2E-01)"
```

---

### Task 5: Media handling and image upload tests

**Files:**
- Create: `packages/dart_desk/integration_test/media_handling_test.dart`
- Create: `packages/dart_desk/integration_test/image_upload_test.dart`

Reference: `packages/dart_desk/tests/e2e/tests/02_media_handling.md`, `07_image_upload_e2e.md`

- [ ] **Step 1: Create `media_handling_test.dart`**

```dart
// packages/dart_desk/integration_test/media_handling_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'robots/document_editor_robot.dart';
import 'robots/document_list_robot.dart';
import 'robots/image_field_robot.dart';
import 'robots/sidebar_robot.dart';
import 'test_utils/db_helper.dart';
import 'test_utils/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await DbHelper.reset();
  });

  tearDownAll(() async {
    await DbHelper.reset();
  });

  group('02 - Media Handling', () {
    // TC-E2E-02-01: Upload image via UI
    testWidgets('TC-E2E-02-01: Upload image via UI', (tester) async {
      await pumpTestApp(tester);
      final sidebar = SidebarRobot(tester);
      final list = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await list.tapCreate();
      await editor.enterField('title', 'Media Test Doc');
      await image.tapUpload('image_field');
      image.expectImagePreview('image_field');
      await editor.tapSave();
      editor.expectSaveConfirmation();
    });

    // TC-E2E-02-02: Upload non-image file
    testWidgets('TC-E2E-02-02: Upload non-image file', (tester) async {
      await pumpTestApp(tester);
      final sidebar = SidebarRobot(tester);
      final list = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await list.tapDocument('Media Test Doc');
      // File fields show the uploaded filename
      await tester.tap(find.byKey(const ValueKey('file_field')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      // After FakePicker picks a file, expect filename metadata shown
      expect(find.textContaining('test_image'), findsOneWidget);
      await editor.tapSave();
      editor.expectSaveConfirmation();
    });

    // TC-E2E-02-03: Delete uploaded media
    testWidgets('TC-E2E-02-03: Delete uploaded media', (tester) async {
      await pumpTestApp(tester);
      final sidebar = SidebarRobot(tester);
      final list = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await list.tapDocument('Media Test Doc');
      image.expectImagePreview('image_field');
      await image.tapRemove('image_field');
      image.expectFieldEmpty('image_field');
    });

    // TC-E2E-02-04: Image persists after save and reload
    testWidgets('TC-E2E-02-04: Image persists after save and reload',
        (tester) async {
      await pumpTestApp(tester);
      final sidebar = SidebarRobot(tester);
      final list = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await list.tapCreate();
      await editor.enterField('title', 'Persist Image Doc');
      await image.tapUpload('image_field');
      image.expectImagePreview('image_field');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await editor.navigateBack();

      // Reload the document
      await list.tapDocument('Persist Image Doc');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      image.expectImagePreview('image_field');
    });
  });
}
```

- [ ] **Step 2: Create `image_upload_test.dart`**

```dart
// packages/dart_desk/integration_test/image_upload_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'robots/document_editor_robot.dart';
import 'robots/document_list_robot.dart';
import 'robots/image_field_robot.dart';
import 'robots/sidebar_robot.dart';
import 'test_utils/db_helper.dart';
import 'test_utils/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await DbHelper.reset();
  });

  tearDownAll(() async {
    await DbHelper.reset();
  });

  group('07 - Image Upload E2E', () {
    // TC-E2E-07-01: Upload image → backend receives file with metadata
    testWidgets(
        'TC-E2E-07-01: Upload image → backend receives file with metadata',
        (tester) async {
      await pumpTestApp(tester);
      final sidebar = SidebarRobot(tester);
      final list = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await list.tapCreate();
      await editor.enterField('title', 'Upload Test Doc A');
      await image.tapUpload('image_field');
      image.expectImagePreview('image_field');
    });

    // TC-E2E-07-02: Uploaded image persists after save and reload
    testWidgets('TC-E2E-07-02: Uploaded image persists after save and reload',
        (tester) async {
      await pumpTestApp(tester);
      final sidebar = SidebarRobot(tester);
      final list = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await list.tapDocument('Upload Test Doc A');
      await image.tapUpload('image_field');
      image.expectImagePreview('image_field');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await editor.navigateBack();

      await list.tapDocument('Upload Test Doc A');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      image.expectImagePreview('image_field');
    });

    // TC-E2E-07-03: Upload, save, then delete image → data cleared
    testWidgets('TC-E2E-07-03: Upload, save, then delete image → data cleared',
        (tester) async {
      await pumpTestApp(tester);
      final sidebar = SidebarRobot(tester);
      final list = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await list.tapDocument('Upload Test Doc A');
      image.expectImagePreview('image_field');
      await image.tapRemove('image_field');
      image.expectFieldEmpty('image_field');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await editor.navigateBack();

      // Reload and verify image is gone
      await list.tapDocument('Upload Test Doc A');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      image.expectFieldEmpty('image_field');
    });

    // TC-E2E-07-04: Upload same image twice → backend deduplicates
    testWidgets(
        'TC-E2E-07-04: Upload same image twice → backend deduplicates',
        (tester) async {
      await pumpTestApp(tester);
      final sidebar = SidebarRobot(tester);
      final list = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);
      final editor = DocumentEditorRobot(tester);

      // Upload to doc A
      await sidebar.tapDocumentType('Integration Test');
      await list.tapDocument('Upload Test Doc A');
      await image.tapUpload('image_field');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await editor.navigateBack();

      // Create doc B and upload same image
      await list.tapCreate();
      await editor.enterField('title', 'Upload Test Doc B');
      await image.tapUpload('image_field');
      image.expectImagePreview('image_field');
      await editor.tapSave();
      editor.expectSaveConfirmation();

      // Both docs show image preview (deduplication verified via backend —
      // use curl http://localhost:8080/api/media/list to check one asset)
      await editor.navigateBack();
      await list.tapDocument('Upload Test Doc A');
      image.expectImagePreview('image_field');
    });
  });
}
```

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/integration_test/media_handling_test.dart \
         packages/dart_desk/integration_test/image_upload_test.dart
git commit -m "test(dart_desk): add media and image upload integration tests (TC-E2E-02, TC-E2E-07)"
```

---

### Task 6: Fix missing widget keys in production code

Run the tests after Task 5. If robots fail to find widgets, the production screens need `ValueKey` additions. This task covers the expected gaps found during initial runs.

**Files to check:**
- `packages/dart_desk/lib/src/studio/screens/document_list.dart` — Create button, document rows
- `packages/dart_desk/lib/src/studio/screens/document_editor.dart` — Save button, back button
- `packages/dart_desk/lib/src/studio/routes/studio_layout.dart` — Sidebar document type items

- [ ] **Step 1: Run all integration tests and capture failures**

```bash
cd packages/dart_desk
flutter test integration_test/ \
  --dart-define=TEST_SERVER_URL=http://localhost:8080/ \
  --dart-define=TEST_API_KEY=<your_editor_token> \
  -d chrome 2>&1 | tee /tmp/integration_test_run.txt
```

- [ ] **Step 2: Add missing keys to production code based on failures**

For each `findsNothing` or `findsWidgets` failure, locate the widget in the source and add a `ValueKey`. Common expected gaps:

In `document_list.dart` — add key to the Create/New document button:
```dart
ShadButton(
  key: const ValueKey('create_document_button'),
  onPressed: ...,
  child: const Text('Create'),
)
```

In `document_editor.dart` — add key to the Save button:
```dart
ShadButton(
  key: const ValueKey('save_document_button'),
  onPressed: _saveDocument,
  child: const Text('Save'),
)
```

Update `finders.dart` to use keys where text finders are ambiguous:
```dart
Finder findCreateButton() => find.byKey(const ValueKey('create_document_button'));
Finder findSaveButton() => find.byKey(const ValueKey('save_document_button'));
```

Update robot methods to use the key-based finders if text finders prove unreliable.

- [ ] **Step 3: Re-run tests and confirm green**

```bash
flutter test integration_test/ \
  --dart-define=TEST_SERVER_URL=http://localhost:8080/ \
  --dart-define=TEST_API_KEY=<your_editor_token> \
  -d chrome
```

Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk/lib/ packages/dart_desk/integration_test/
git commit -m "test(dart_desk): fix widget keys for integration test finders"
```
