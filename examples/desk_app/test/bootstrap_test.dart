import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:example/bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  testWidgets('buildDeskApp renders DartDeskApp with the given data source',
      (tester) async {
    // Suppress overflow errors from the test-size viewport (800×600)
    // which are cosmetic and not relevant to bootstrapping correctness.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('RenderFlex overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };

    final source = MockDataSource();
    final app = await buildDeskApp(dataSource: source);
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(DartDeskApp), findsOneWidget);
    expect(find.byType(ShadApp), findsWidgets);

    FlutterError.onError = originalOnError;
  });
}
