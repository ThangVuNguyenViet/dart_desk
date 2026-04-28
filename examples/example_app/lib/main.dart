import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk_client/dart_desk_client.dart';
import 'package:example_app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

const _defaultServerUrl = 'http://localhost:8080/';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const serverUrl = String.fromEnvironment('SERVER_URL', defaultValue: _defaultServerUrl);
  const apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'desk_w_5cRn9tCk-cdHTP0KM5Wiia02WhNMTL2rCzrz8guMVgk',
  );
  final client = Client(serverUrl)
    ..authKeyProvider = DartDeskAuthKeyProvider(apiKey: apiKey)
    ..connectivityMonitor = FlutterConnectivityMonitor();
  final source = CloudPublicContentSource(client);
  final app = await buildExampleApp(contentSource: source);
  runApp(app);
}
