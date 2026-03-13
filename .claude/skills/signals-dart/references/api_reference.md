# Signals.dart Complete API Reference

## Table of Contents
1. [Signal Lifecycle](#signal-lifecycle)
2. [Computed Advanced](#computed-advanced)
3. [Effect Advanced](#effect-advanced)
4. [Flutter Hooks](#flutter-hooks)
5. [SignalProvider](#signalprovider)
6. [ValueNotifier Compatibility](#valuenotifier-compatibility)
7. [Async Signals Detail](#async-signals-detail)
8. [Collections Detail](#collections-detail)
9. [Advanced Patterns](#advanced-patterns)
10. [Testing](#testing)
11. [Migration Guides](#migration-guides)

---

## Signal Lifecycle

```dart
// Disposal callbacks
signal.onDispose(() => print('cleaned up'));
signal.dispose();  // Freezes value and stops tracking
final isDisposed = signal.disposed;  // Check status

// Subscribe to changes
signal.subscribe((value) => print(value));
```

---

## Computed Advanced

```dart
// Force recomputation
fullName.recompute();

// Auto-disposal when no listeners
final computed = computed(
  () => name.value,
  autoDispose: true,
);
```

---

## Effect Advanced

```dart
// With onDispose callback
effect(
  () => print(s.value),
  onDispose: () => print('Effect destroyed'),
);
```

---

## Flutter Hooks

```dart
import 'package:signals/signals_flutter.dart';

Widget build(BuildContext context) {
  final count = useSignal(0);
  final doubled = useComputed(() => count.value * 2);

  useSignalEffect(() {
    print('Count: ${count.value}');
  });

  // Async hooks
  final future = useFutureSignal(() async => fetchData());
  final stream = useStreamSignal(() => dataStream);

  // Collection hooks
  final list = useListSignal([1, 2, 3]);
  final map = useMapSignal({'key': 'value'});
  final set = useSetSignal({1, 2, 3});

  return Text('Count: ${count.value}');
}
```

---

## SignalProvider

Share signals across widget tree:

```dart
// Create signal class
class Counter extends FlutterSignal<int> {
  Counter() : super(0);
}

// Provide
SignalProvider<Counter>(
  create: () => Counter(),
  child: MyApp(),
);

// Access
final counter = SignalProvider.of<Counter>(context);  // Listens
final counter = SignalProvider.of<Counter>(context, listen: false);  // No rebuild
```

---

## ValueNotifier Compatibility

```dart
final count = signal(0);
final ValueNotifier<int> notifier = count;  // Works!

// Convert existing ValueNotifier
final existingNotifier = ValueNotifier(10);
final signal = existingNotifier.toSignal();  // Bidirectional

// Convert ValueListenable
final ValueListenable listenable = /* ... */;
final signal = listenable.toSignal();
```

---

## Async Signals Detail

### FutureSignal

```dart
// From callback
final future = futureSignal(() async => fetchData());

// Convert existing future
final future = Future(() => fetchData()).toSignal();

// With dependencies (re-executes on change)
final count = signal(0);
final future = futureSignal(
  () async => fetchDataForCount(count.value),
  dependencies: [count],
);
```

### StreamSignal

```dart
// From callback
final stream = streamSignal(() => dataStream);

// Convert existing stream
final stream = dataStream.toSignal();

// With dependencies
final stream = streamSignal(
  () async* { yield count.value; },
  dependencies: [count],
);
```

### AsyncState

Sealed union class:

```dart
// Create states
final loading = AsyncState<int>.loading();
final data = AsyncState.data(42);
final error = AsyncState<int>.error('Error', stackTrace);

// Check state
state.isLoading
state.hasValue
state.hasError
state.isRefreshing  // Loading with existing value/error
state.isReloading   // Loading with prior value/error

// Access data
state.value         // Nullable
state.requireValue  // Throws if null/error
state.error
state.stackTrace
```

### Async Computed

```dart
// computedAsync - syntax sugar around FutureSignal
final movieId = signal('id');
final movie = computedAsync(() => fetchMovie(movieId.value));
// Note: Access signal values BEFORE any await statements

// computedFrom - explicit dependencies (no await timing issues)
final movie = computedFrom(
  [movieId],
  (args) => fetchMovie(args.first),
);
```

### Connect - Stream to Signal

```dart
final s = signal(0);
final c = connect(s);

// Add streams
c.from(stream1).from(stream2);
// Or: c << stream1 << stream2;

c.dispose();
```

---

## Collections Detail

### ListSignal

```dart
final list = listSignal([1, 2, 3]);
// Or: final list = [1, 2, 3].toSignal();

list[0] = -1;
list.add(4);
list.addAll([5, 6]);
print(list.first);
print(list.length);

// Custom operators
final intersection = list & [3, 4, 5];
```

### MapSignal

```dart
final map = mapSignal({'a': 1, 'b': 2});
// Or: final map = {'a': 1}.toSignal();

map['a'] = -1;
map.addAll({'c': 3});
map.remove('b');
print(map.keys);
```

### SetSignal

```dart
final set = setSignal({1, 2, 3});
// Or: final set = {1, 2, 3}.toSignal();

set.add(4);
set.remove(1);
print(set.length);
print(set.contains(2));
final intersection = set.intersection({2, 3, 4});
```

---

## Advanced Patterns

### SignalsContainer

Create signals dynamically:

```dart
// Without caching
final counters = signalContainer<int, int>((id) => signal(id));
final counter1 = counters(1);
final counter2 = counters(2);

// With caching
final cachedCounters = signalContainer<int, int>(
  (id) => signal(id),
  cache: true,
);

// Practical: persisted settings
final setting = signalContainer<String, (String, String)>(
  (args) {
    final (key, defaultValue) = args;
    return signal(prefs.getString(key) ?? defaultValue);
  },
  cache: true,
);
```

### Persisted Signals

```dart
abstract class KeyValueStore {
  Future<void> setItem(String key, String value);
  Future<String?> getItem(String key);
  Future<void> removeItem(String key);
}

class PersistedSignal<T> extends FlutterSignal<T>
    with PersistedSignalMixin<T> {
  PersistedSignal(this.key, T defaultValue, {required this.store})
      : super(defaultValue);

  @override final String key;
  @override final KeyValueStore store;
  @override String encode(T value) => value.toString();
  @override T decode(String serialized) => /* parse */;
}

// For enums
@override String encode(MyEnum value) => value.name;
@override MyEnum decode(String s) => MyEnum.values.byName(s);

// For colors
@override String encode(Color value) => value.value.toString();
@override Color decode(String s) => Color(int.parse(s));
```

### Bi-directional Data Flow

```dart
final a = signal(0);
final b = signal(0);

// With untracked: safe
effect(() {
  b.value = untracked(() => a.value + 1);
});

effect(() {
  a.value = untracked(() => b.value + 1);
});
```

### SignalsObserver

```dart
class MyObserver extends SignalsObserver {
  @override void onSignalCreated(Signal signal) {}
  @override void onSignalUpdated(Signal signal, dynamic value) {}
  @override void onComputedCreated(Computed computed) {}
  @override void onComputedUpdated(Computed computed, dynamic value) {}
}

void main() {
  // Debug only - performance overhead!
  SignalsObserver.instance = LoggingSignalsObserver();
  runApp(MyApp());
}

// Disable
SignalsObserver.instance = null;
```

### Available Mixins

- `ValueListenableSignalMixin` - Implements ValueListenable protocol
- `ValueNotifierSignalMixin` - Implements ValueNotifier protocol
- `ChangeStackSignalMixin` - Undo/redo functionality
- `ListSignalMixin`, `MapSignalMixin`, `SetSignalMixin` - Collection methods
- `StreamSignalMixin` - Makes signals usable as streams
- `TrackedSignalMixin` - Tracks initial/previous values

---

## Dependency Injection Patterns

**Provider:**
```dart
Provider<CounterSignal>(
  create: (_) => signal(0),
  dispose: (_, s) => s.dispose(),
  child: MyApp(),
);
```

**GetIt:**
```dart
final getIt = GetIt.instance;
getIt.registerSingleton(signal(0));
```

**Riverpod:**
```dart
@riverpodSignal
Signal<int> counter(CounterRef ref) => signal(0);
```

---

## Testing

### Convert to Stream

```dart
test('signal updates', () async {
  final s = signal(0);
  final stream = s.toStream();

  s.value = 1;
  s.value = 2;

  await expectLater(stream, emitsInOrder([0, 1, 2]));
});
```

### Override Values

```dart
test('with mocked value', () {
  final s = signal(0);
  final overridden = s.overrideWith(42);

  expect(overridden.value, 42);
});
```

---

## Common Patterns

### Loading State

```dart
final data = futureSignal(() => api.fetchData());

Watch((context) {
  return data.value.map(
    loading: () => CircularProgressIndicator(),
    data: (value) => DataWidget(value),
    error: (err, _) => ErrorWidget(err),
  );
});
```

### Form Validation

```dart
final email = signal('');
final isValidEmail = computed(() =>
  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.value)
);

TextField(
  onChanged: (value) => email.value = value,
  decoration: InputDecoration(
    errorText: Watch((context) =>
      isValidEmail.value ? null : 'Invalid email'
    ),
  ),
)
```

### Reactive List Filtering

```dart
final items = listSignal(['apple', 'banana', 'cherry']);
final filter = signal('');
final filtered = computed(() =>
  items.where((item) => item.contains(filter.value)).toList()
);
```

---

## Migration Guides

### From ValueNotifier
- Replace `ValueNotifier` with `signal`
- Use `.toSignal()` for gradual migration
- Signals work cross-platform

### From Provider
- Replace `ChangeNotifier` with signals
- Use `Watch` instead of `Consumer`
- Use `SignalProvider` for scoped signals

### From Riverpod
- Replace providers with signals
- Use computed for derived state
- Use effects for side effects

### From BLoC
- Replace streams with signals
- Replace StreamBuilder with `Watch`
- Use `streamSignal` to wrap existing streams

---

## Resources

- Documentation: https://dartsignals.dev
- GitHub: https://github.com/rodydavis/signals.dart
- Pub.dev: https://pub.dev/packages/signals
- LLM-friendly docs: https://dartsignals.dev/llms.txt
