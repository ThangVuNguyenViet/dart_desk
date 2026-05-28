import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

class MyPill extends SignalWidget {
  final SignalContainer<AsyncState<int>, String, FutureSignal<int>> container;
  const MyPill(this.container, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = container('test').value;
    return Text('${s.value}');
  }
}

void main() {
  testWidgets('Test SignalWidget', (tester) async {
    final container = SignalContainer<AsyncState<int>, String, FutureSignal<int>>(
      (key) => FutureSignal(() async => 0), 
      cache: true,
    );
    
    await tester.pumpWidget(MaterialApp(
      home: MyPill(container),
    ));
    
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsOneWidget);
  });
}
