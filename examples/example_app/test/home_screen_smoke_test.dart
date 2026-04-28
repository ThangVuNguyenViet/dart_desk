import 'package:data_models/example_data.dart';
import 'package:example_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeScreen renders default config', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Suppress network image errors in test environment (HTTP 400 from test binding)
    final List<FlutterErrorDetails> ignored = [];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception.toString().contains('NetworkImageLoadException') ||
          details.exception.toString().contains('statusCode: 400')) {
        ignored.add(details);
      } else {
        originalOnError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: HomeScreen(
            config: HomeConfig.defaultValue,
            theme: BrandTheme.defaultValue,
          ),
        ),
      ),
    ));
    expect(find.text('A table for the long evening.'), findsOneWidget);
    expect(find.text('Order now'), findsOneWidget);
  });
}
