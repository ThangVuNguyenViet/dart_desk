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
  const apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'desk_w_rjjQNv3VTxL9KYijSnpc0LYVv0I5b0bLt5RR60P1mE0',
  );
  runApp(
    DartDeskApp(
      serverUrl: serverUrl,
      apiKey: apiKey,
      config: deskAppConfig,
    ),
  );
}
