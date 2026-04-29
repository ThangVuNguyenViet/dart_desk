import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/studio.dart';
import 'package:dart_desk_client/dart_desk_client.dart';
import 'package:example/bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

const _defaultServerUrl = 'http://localhost:8080/';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(DeskMarionetteConfig.configuration);
  }
  const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: _defaultServerUrl,
  );
  const apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'desk_w_rjjQNv3VTxL9KYijSnpc0LYVv0I5b0bLt5RR60P1mE0',
  );
  final client = Client(serverUrl)
    ..authKeyProvider = DartDeskAuthKeyProvider(apiKey: apiKey)
    ..connectivityMonitor = FlutterConnectivityMonitor();
  final dataSource = CloudDataSource(client);
  final app = await buildDeskApp(
    dataSource: dataSource,
    // TODO: wire real sign-out handler
    onSignOut: () {},
  );
  runApp(app);
}
