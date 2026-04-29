// Smoke test: app boots without crashing.
// Uses FakePublicContentSource so no network is required.

import 'package:dart_desk/testing.dart';
import 'package:example_app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    final source = FakePublicContentSource();
    final app = await buildExampleApp(contentSource: source);
    await tester.pumpWidget(app);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
