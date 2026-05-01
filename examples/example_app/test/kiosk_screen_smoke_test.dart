import 'package:data_models/example_data.dart';
import 'package:example_app/screens/kiosk_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('KioskScreen renders default config', (tester) async {
    tester.view.physicalSize = const Size(1194, 834);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Suppress network image errors in test environment (HTTP 400 from test binding)
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception.toString().contains('NetworkImageLoadException') ||
          details.exception.toString().contains('statusCode: 400')) {
        // ignore
      } else {
        originalOnError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: KioskScreen(
            config: KioskConfig.initialValue,
            theme: BrandTheme.initialValue,
          ),
        ),
      ),
    ));
    expect(find.text('Spring, plated.'), findsOneWidget);
    expect(find.text('Table 12'), findsOneWidget);
  });
}
