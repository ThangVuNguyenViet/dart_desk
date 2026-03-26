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
