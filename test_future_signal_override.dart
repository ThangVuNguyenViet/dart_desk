import 'package:signals/signals.dart';

void main() async {
  final s = futureSignal(() async {
    await Future.delayed(Duration(milliseconds: 100));
    return 1;
  });
  await s.future;
  print('after fetch: ${s.value.value}');
  s.value = AsyncData(2);
  print('after override: ${s.value.value}');
}
