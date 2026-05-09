import 'package:dart_desk/studio.dart';
import 'package:example/bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

const _defaultServerUrl = 'http://localhost:8080/';

Future<void> main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(DeskMarionetteConfig.configuration);
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: _defaultServerUrl,
  );
  const apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    throw StateError('API_KEY must be provided via --dart-define=API_KEY=…');
  }
  runApp(
    DartDeskApp(
      serverUrl: serverUrl,
      apiKey: apiKey,
      config: deskAppConfig,
    ),
  );
}
