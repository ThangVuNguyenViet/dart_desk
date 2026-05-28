import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthSuccess extends Mock {}

void main() {
  final first = _MockAuthSuccess();
  final refreshed = _MockAuthSuccess();
  print('first == refreshed? \${first == refreshed}');
  
  final notifier = ValueNotifier<dynamic>(null);
  notifier.addListener(() {
    print('notifier called!');
  });
  
  notifier.value = first;
  notifier.value = refreshed;
}
