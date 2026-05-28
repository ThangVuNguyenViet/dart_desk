import 'package:signals_core/signals_core.dart';

void main() {
  final container = mapSignal<String, String>({});
  final docId = signal('doc1');

  effect(() {
    final id = docId.value;
    print('Effect running for $id');
    container.putIfAbsent(id, () => 'data for $id');
  });

  print('Container: $container');
}
