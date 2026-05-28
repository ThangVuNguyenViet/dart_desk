import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals/signals.dart';
import 'package:signals/signals_flutter.dart';

void main() {
  testWidgets('watch context updates', (tester) async {
    final sig = FutureSignal(() => Future.delayed(Duration(milliseconds: 100), () => 'hello'));
    int builds = 0;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            builds++;
            final val = sig.watch(context);
            print("val: ${val.runtimeType}");
            return Text('val: ${val.runtimeType}');
          }
        )
      )
    );
    
    await tester.pumpAndSettle(Duration(milliseconds: 200));
    print("Builds: $builds");
  });
}
