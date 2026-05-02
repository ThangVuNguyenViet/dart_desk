import 'package:data_models/example_data.dart';
import 'package:example_app/screens/rewards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RewardsScreen renders default config', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Suppress network image errors in test environment
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
          child: RewardsScreen(
            config: RewardsConfig.initialValue,
            theme: BrandTheme.initialValue,
          ),
        ),
      ),
    ));
    expect(find.text('Your coupons'), findsOneWidget);
    expect(find.text('412 pts'), findsOneWidget);
  });
}
