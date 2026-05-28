import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('Test FutureSignal inside Watch', (tester) async {
    final container = SignalContainer<AsyncState<int>, String, FutureSignal<int>>(
      (key) => FutureSignal(() async => 0), 
      cache: true,
    );
    
    await tester.pumpWidget(MaterialApp(
      home: Watch((context) {
        final s = container('test');
        return Text('${s.value}');
      }),
    ));
    
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsOneWidget);
  });
}
