import 'package:signals/signals.dart';
void main() async {
  final s = futureSignal(() async {
    await Future.delayed(Duration(milliseconds: 10));
    return 42;
  });
  
  s.subscribe((val) {
    print('state: ' + val.toString());
  });
  
  print('init: ' + s.value.toString());
  await Future.delayed(Duration(milliseconds: 20));
  print('after: ' + s.value.toString());
}
