import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/testing.dart';
import 'package:example_app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buildExampleApp renders with FakePublicContentSource', (tester) async {
    final source = FakePublicContentSource()
      ..seed([
        PublicDeskDocument(
          id: 'theme-1',
          documentType: 'brandTheme',
          title: 'Aura',
          slug: 'default',
          isDefault: true,
          data: const {'documentType': 'brandTheme', 'name': 'Aura'},
          publishedAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      ]);

    final app = await buildExampleApp(contentSource: source);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
