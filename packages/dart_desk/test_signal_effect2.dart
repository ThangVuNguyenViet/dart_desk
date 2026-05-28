import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('Test SignalContainer inside Watch', (tester) async {
    final container = SignalContainer<int, String, Signal<int>>((key) => signal(0), cache: true);
    
    await tester.pumpWidget(MaterialApp(
      home: Watch((context) {
        final s = container('test');
        return Text('${s.value}');
      }),
    ));
    
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  });
}
