import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:example/bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

Future<void> main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(DeskMarionetteConfig.configuration);
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  final dataSource = MockDataSource()..seedDefaults();
  runApp(
    DartDeskApp.withDataSource(
      dataSource: dataSource,
      onSignOut: () {},
      config: deskAppConfig,
    ),
  );
}
