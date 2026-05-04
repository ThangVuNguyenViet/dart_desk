import 'package:dart_desk/src/inputs/optional_field_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

Widget _wrap(Widget child) => buildInputApp(child);

void main() {
  testWidgets('shows title only when not optional', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const OptionalFieldHeader(
          title: 'Article Title',
          isOptional: false,
          isEnabled: true,
          onToggle: _noop,
        ),
      ),
    );
    expect(find.text('Article Title'), findsOneWidget);
    expect(find.byType(ShadCheckbox), findsNothing);
  });

  testWidgets('shows checkbox when optional and reflects isEnabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const OptionalFieldHeader(
          title: 'Article Title',
          isOptional: true,
          isEnabled: false,
          onToggle: _noop,
        ),
      ),
    );
    expect(find.byType(ShadCheckbox), findsOneWidget);
    final cb = tester.widget<ShadCheckbox>(find.byType(ShadCheckbox));
    expect(cb.value, isFalse);
  });

  testWidgets('toggling the checkbox calls onToggle with new value', (
    tester,
  ) async {
    bool? captured;
    await tester.pumpWidget(
      _wrap(
        OptionalFieldHeader(
          title: 'Title',
          isOptional: true,
          isEnabled: false,
          onToggle: (v) => captured = v,
        ),
      ),
    );
    await tester.tap(find.byType(ShadCheckbox));
    await tester.pumpAndSettle();
    expect(captured, isTrue);
  });
}

void _noop(bool _) {}
