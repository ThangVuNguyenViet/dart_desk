// Boots the consumer-facing example_app against the real Serverpod backend.
//
// Mirrors `desk_app/integration_test/test_utils/test_app.dart` but uses
// `CloudPublicContentSource` (read-only public endpoints) instead of
// `CloudDataSource` (authenticated studio writes).
//
// Tests that need to publish content from the studio side use
// [studioDataSource] alongside the example_app boot.
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk_client/dart_desk_client.dart';
import 'package:example_app/bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class _TestConnectivityMonitor extends ConnectivityMonitor {
  _TestConnectivityMonitor() {
    notifyListeners(true);
  }
}

const _testServerUrl = String.fromEnvironment(
  'TEST_SERVER_URL',
  defaultValue: 'http://localhost:8080/',
);

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

String get testBackendUrl => _testServerUrl;

IntegrationTestWidgetsFlutterBinding ensureTestInitialized() {
  return IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

Client _newClient({FlutterAuthSessionManager? sessionManager}) {
  final session = sessionManager ?? FlutterAuthSessionManager();
  return Client(_testServerUrl)
    ..connectivityMonitor = _TestConnectivityMonitor()
    ..authSessionManager = session
    ..authKeyProvider = DartDeskAuthKeyProvider(
      apiKey: _testApiKey,
      inner: session,
    );
}

/// Builds an authenticated studio-side data source for tests that need to
/// publish documents before reading them through the public endpoint.
Future<CloudDataSource> studioDataSource() async {
  final session = FlutterAuthSessionManager();
  await session.initialize();
  final client = _newClient(sessionManager: session);
  if (!session.isAuthenticated) {
    final auth = await client.emailIdp.login(
      email: _testEmail,
      password: _testPassword,
    );
    await session.updateSignedInUser(auth);
  }
  return CloudDataSource(client);
}

/// Returns a read-only [PublicContentSource] backed by the test backend.
PublicContentSource publicContentSource() {
  return CloudPublicContentSource(_newClient());
}

/// Pumps the example_app pointed at the test backend's public endpoint.
Future<void> pumpExampleApp(WidgetTester tester) async {
  final app = await buildExampleApp(contentSource: publicContentSource());
  await tester.pumpWidget(app);
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(minutes: 1),
  );
}
