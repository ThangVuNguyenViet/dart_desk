// examples/desk_app/integration_test/test_utils/test_app.dart
import 'package:dart_desk/src/cloud/cloud_data_source.dart';
import 'package:dart_desk/testing.dart';
import 'package:dart_desk_client/dart_desk_client.dart';
import 'package:example/bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'settle.dart';

/// No-op connectivity monitor that doesn't hold a live stream subscription.
/// [FlutterConnectivityMonitor] listens to `connectivity_plus` which keeps
/// the event loop alive and prevents [WidgetTester.pumpAndSettle] from
/// ever settling.
class _TestConnectivityMonitor extends ConnectivityMonitor {
  _TestConnectivityMonitor() {
    // Immediately report connected so the client works normally.
    notifyListeners(true);
  }
}

const _testServerUrl = String.fromEnvironment(
  'TEST_SERVER_URL',
  defaultValue: 'http://localhost:8080/',
);

/// Exposed for [DbHelper] to verify backend reachability.
String get testBackendUrl => _testServerUrl;

const _testApiKey = String.fromEnvironment(
  'TEST_API_KEY',
  defaultValue: 'desk_w_e2eTestTokenForDartDeskIntegration00aaaa',
);

const _testEmail = String.fromEnvironment(
  'TEST_EMAIL',
  defaultValue: 'e2e@dartdesk.dev',
);

const _testPassword = String.fromEnvironment(
  'TEST_PASSWORD',
  defaultValue: 'e2e-password-123',
);

/// Call once at the top of each test file's `main()`.
IntegrationTestWidgetsFlutterBinding ensureTestInitialized() {
  return IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

/// Pumps the real DartDeskApp pointed at the test Serverpod backend.
///
/// Authenticates via email/password upfront so tests start with an
/// authenticated session, bypassing the login UI entirely.
///
/// [FakeImagePickerPlatform] is installed on every call so image-picker
/// tests work without opening the system file picker.
Future<void> pumpTestApp(WidgetTester tester) async {
  FakeImagePickerPlatform.install();
  FakeFilePickerPlatform.install();

  // Build a pre-authenticated client so we bypass the login screen.
  final sessionManager = FlutterAuthSessionManager();
  final client = Client(_testServerUrl)
    ..connectivityMonitor = _TestConnectivityMonitor()
    ..authSessionManager = sessionManager
    ..authKeyProvider = DartDeskAuthKeyProvider(
      apiKey: _testApiKey,
      inner: sessionManager,
    );
  await sessionManager.initialize();

  if (!sessionManager.isAuthenticated) {
    final authSuccess = await client.emailIdp.login(
      email: _testEmail,
      password: _testPassword,
    );
    await sessionManager.updateSignedInUser(authSuccess);
  }

  final dataSource = CloudDataSource(client);

  // Boot through the same bootstrap the showcase app uses — integration
  // tests exercise the real entry point against a real backend.
  final app = await buildDeskApp(
    dataSource: dataSource,
    onSignOut: () async => sessionManager.signOutDevice(),
  );
  await tester.pumpWidget(app);
  await tester.settle();
}
