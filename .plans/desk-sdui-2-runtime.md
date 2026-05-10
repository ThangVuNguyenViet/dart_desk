# desk_sdui Phase 2 — Runtime Implementation Plan

> **For agentic workers:** This plan implements the `desk_sdui` (Flutter runtime) package. Phase 1 (foundation: annotation node types + JSON codec) must be complete and committed first. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Flutter runtime that loads an `IrTree`, resolves it against an input map, and renders a Widget tree. Reactive subtrees rebuild via `ListenableBuilder` against `ValueListenable<T>` sources.

**Architecture:** Three runtime phases — LOAD (fetch + decode bytes → typed `IrTree`, cached by contentHash), RESOLVE (walk the node tree with input map → Widget tree), RENDER (Flutter reconciles, no resolver code at frame rate). The runtime depends on Flutter SDK + `desk_sdui_annotation` only — no state-management package.

**Tech Stack:** Flutter SDK, `desk_sdui_annotation` (path dep), `crypto` (for SHA-1 contentHash), `http` (for `RemoteIrFetcher`), `flutter_test`.

**Repo:** `/Users/vietthangvunguyen/Workspace/dart_desk_workspace/desk_sdui`

---

## Phase 1 node-class adapter notes (READ FIRST)

The actual Phase 1 node-class shapes diverge from earlier-drafted code samples in this plan. **Use the actual constructor signatures below; the code samples elsewhere in this plan that conflict are stale.** Confirm by reading `packages/desk_sdui_annotation/lib/src/ir/ir_node.dart` before each task.

| Node | Actual constructor | Notes |
|---|---|---|
| `LiteralNode` | `LiteralNode(value)` positional | |
| `ConstNode` | `ConstNode(value)` positional | |
| `RefNode` | `RefNode(path, {reactive = false})` — `path` positional | |
| `EventNode` | `EventNode(target, {args = const {}})` — `args` is **non-nullable** Map (default empty), not `Map?` | |
| `WidgetNode` | `WidgetNode({name, args, key, listenablePaths = const {}})` — `Set<String>` of dotted paths to Flutter Listenables in `input['__reactive__']` | **No separate `ReactiveScopeNode` exists.** Reactive metadata sits on `WidgetNode` directly. |
| `BuiltinWidgetNode` | `BuiltinWidgetNode({name, args, key})` | No `listenablePaths` field |
| `ListNode` | `ListNode(children)` positional | |
| `MapNode` | `MapNode(entries)` — entries is `Map<IrNode, IrNode>` (keys are IrNodes, not Strings) | |
| `RecordNode` | `RecordNode({positional = const [], named = const {}})` | |
| `ConditionalNode` | `ConditionalNode({condition, thenBranch, elseBranch})` | NOT `then`/`otherwise` |
| `ForNode` | `ForNode({variable, source, body})` / `ForNode.destructured({variables, source, body})` | Field names: `variable`/`variables`, NOT `loopVar`/`loopVars` |
| `SpreadNode` | `SpreadNode(source)` positional | |
| `NotOpNode` | `NotOpNode(operand)` positional | |
| `CompareOpNode` / `ArithOpNode` / `LogicOpNode` | `({op, left, right})` named | |
| `CoalesceOpNode` | `({left, right})` named | |
| `MemberAccessNode` | `({target, name})` — `name`, NOT `member` | |
| `IndexAccessNode` | `({target, key})` — `key`, NOT `index` | |
| `LengthOfNode` | `LengthOfNode(target)` positional | |
| `IsNullCheckNode` | `IsNullCheckNode(operand)` positional | |
| `StringInterpNode` | `StringInterpNode(parts)` — `parts: List<Object>` **alternating `String` literals and `IrNode` slots**, NOT `List<IrNode>` of `LiteralNode`s | |
| `IrTree` | Read its actual constructor in `ir_tree.dart`; check the `currentIrVersion` constant |

**Rewrite all code samples in this plan accordingly when implementing.** Where this plan refers to a `ReactiveScopeNode`, use `WidgetNode.listenablePaths` instead — see Task 6 below for the revised approach.

---

## File Structure

```
packages/desk_sdui/
├── lib/
│   ├── desk_sdui.dart              ← public exports
│   └── src/
│       ├── runtime.dart            ← Runtime, ScreenBinding, InputBinding
│       ├── sdui_screen.dart        ← SduiScreen StatefulWidget
│       ├── resolve.dart            ← IR walker → Widget
│       ├── expression_eval.dart    ← ExpressionNode evaluator
│       ├── ref_resolver.dart       ← path-walking RefNode resolver
│       ├── reactive.dart           ← ListenableBuilder helpers
│       ├── builtins/
│       │   ├── builtin_widgets.dart ← Column/Row/Padding/SizedBox/etc
│       │   └── builtin_fns.dart     ← length, contains, etc
│       └── loader/
│           ├── ir_fetcher.dart     ← IrFetcher abstract class
│           ├── asset_bundle_ir_fetcher.dart
│           └── remote_ir_fetcher.dart
└── test/
    ├── runtime_test.dart
    ├── resolve_test.dart
    ├── expression_eval_test.dart
    ├── ref_resolver_test.dart
    ├── reactive_test.dart
    ├── builtins_test.dart
    ├── loader_test.dart
    └── sdui_screen_test.dart
```

---

## Task 1: Wire dependencies

**Files:**
- Modify: `packages/desk_sdui/pubspec.yaml`

- [ ] **Step 1: Add deps**

```yaml
name: desk_sdui
description: Server-driven UI runtime for Flutter — renders desk_sdui IR.
version: 0.0.1-dev
publish_to: none

environment:
  sdk: ^3.6.0
  flutter: ">=3.27.0"

dependencies:
  flutter:
    sdk: flutter
  desk_sdui_annotation:
    path: ../desk_sdui_annotation
  crypto: ^3.0.5
  http: ^1.2.2
  meta: ^1.16.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  very_good_analysis: ^7.0.0
```

- [ ] **Step 2: Run `flutter pub get` from `packages/desk_sdui/`**

Expected: deps resolve, no errors.

- [ ] **Step 3: Commit**

```bash
git add packages/desk_sdui/pubspec.yaml packages/desk_sdui/pubspec.lock
git commit -m "chore(desk_sdui): wire runtime dependencies"
```

---

## Task 2: Define `InputBinding` and `ScreenBinding`

**Files:**
- Create: `packages/desk_sdui/lib/src/runtime.dart`
- Test: `packages/desk_sdui/test/runtime_test.dart`

These types describe the static contract a generated `.sdui.g.dart` file emits. `InputBinding` describes one parameter of a `@Screen` function (e.g., `data: CartData`); `ScreenBinding` ties everything together (name, node tree, inputs, methods, reactive sources).

- [ ] **Step 1: Write the test for `InputBinding`**

```dart
// packages/desk_sdui/test/runtime_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:desk_sdui/desk_sdui.dart';

void main() {
  group('InputBinding', () {
    test('stores name and reader', () {
      final binding = InputBinding<int>(
        name: 'count',
        read: (input) => input as int,
      );
      expect(binding.name, 'count');
      expect(binding.read(42), 42);
    });
  });
}
```

- [ ] **Step 2: Run — expect FAIL (`InputBinding` undefined)**

Run: `flutter test test/runtime_test.dart`

- [ ] **Step 3: Define `InputBinding` and `ScreenBinding`**

```dart
// packages/desk_sdui/lib/src/runtime.dart
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Describes a single parameter of a @Screen function.
class InputBinding<T> {
  const InputBinding({required this.name, required this.read});
  final String name;
  final T Function(Object? input) read;
}

/// A method exposed to the IR (e.g. `controller.removeItem`).
class MethodBinding {
  const MethodBinding({required this.name, required this.invoke});
  final String name;
  final Function invoke;
}

/// A reactive source exposed to the IR (e.g. `controller.showPromoCode` of type
/// `ValueListenable<bool>`). The runtime subscribes via `ListenableBuilder`.
class ReactiveBinding {
  const ReactiveBinding({required this.path, required this.read});
  final List<String> path;
  final ValueListenable<Object?> Function(Map<String, Object?> input) read;
}

/// Static binding for a @Screen — emitted by codegen.
class ScreenBinding {
  const ScreenBinding({
    required this.name,
    required this.ir,
    required this.inputs,
    this.methods = const [],
    this.reactives = const [],
  });
  final String name;
  final IrTree ir;
  final List<InputBinding<Object?>> inputs;
  final List<MethodBinding> methods;
  final List<ReactiveBinding> reactives;
}
```

- [ ] **Step 4: Add `Runtime` class with registries (stub `load`/`build` for now)**

```dart
class Runtime {
  Runtime({this.fetcher, this.assetBundle, this.errorBuilder, this.loadingBuilder});

  final IrFetcher? fetcher;
  final AssetBundle? assetBundle;
  final Widget Function(BuildContext, Object error)? errorBuilder;
  final Widget Function(BuildContext)? loadingBuilder;

  final Map<String, ScreenBinding> _screens = {};
  final Map<String, WidgetBuilderFn> _widgets = {};
  final Map<String, Function> _fns = {};

  void registerScreen(ScreenBinding binding) {
    _screens[binding.name] = binding;
  }

  void registerWidget(String name, WidgetBuilderFn builder) {
    _widgets[name] = builder;
  }

  void registerFn(String name, Function fn) {
    _fns[name] = fn;
  }

  ScreenBinding? screenFor(String name) => _screens[name];
  WidgetBuilderFn? widgetFor(String name) => _widgets[name];
  Function? fnFor(String name) => _fns[name];
}

typedef WidgetBuilderFn = Widget Function(
  BuildContext context,
  Map<String, Object?> args,
);

abstract class IrFetcher {
  Future<List<int>> fetch(String name);
}
```

- [ ] **Step 5: Add public exports**

```dart
// packages/desk_sdui/lib/desk_sdui.dart
library desk_sdui;

export 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
export 'src/runtime.dart';
```

- [ ] **Step 6: Add round-trip test for registries**

Add to `test/runtime_test.dart`:

```dart
group('Runtime', () {
  test('register and look up widget', () {
    final rt = Runtime();
    rt.registerWidget('Sentinel', (ctx, args) => const SizedBox());
    expect(rt.widgetFor('Sentinel'), isNotNull);
  });

  test('register and look up fn', () {
    final rt = Runtime();
    rt.registerFn('double', (int x) => x * 2);
    final fn = rt.fnFor('double');
    expect(fn, isNotNull);
    expect(Function.apply(fn!, [3]), 6);
  });

  test('register and look up screen', () {
    final rt = Runtime();
    final binding = ScreenBinding(
      name: 'home',
      ir: IrTree(name: 'home', version: 1, root: const LiteralNode(null)),
      inputs: const [],
    );
    rt.registerScreen(binding);
    expect(rt.screenFor('home')?.name, 'home');
  });
});
```

- [ ] **Step 7: Run — expect PASS**

Run: `flutter test test/runtime_test.dart`

- [ ] **Step 8: Commit**

```bash
git add packages/desk_sdui/lib packages/desk_sdui/test/runtime_test.dart
git commit -m "feat(desk_sdui): runtime registries + ScreenBinding"
```

---

## Task 3: Implement `RefResolver` (path walker)

A `RefNode` carries a `path: List<String>` like `['data', 'items', '0', 'title']`. The resolver walks the input map and returns the leaf value. Pre-split paths in the node tree mean per-build is just `Map.[]` / `List.[]`.

**Files:**
- Create: `packages/desk_sdui/lib/src/ref_resolver.dart`
- Test: `packages/desk_sdui/test/ref_resolver_test.dart`

- [ ] **Step 1: Write tests**

```dart
// test/ref_resolver_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:desk_sdui/src/ref_resolver.dart';

void main() {
  group('RefResolver', () {
    test('resolves single segment from map', () {
      expect(resolveRef(['count'], {'count': 7}), 7);
    });

    test('resolves nested map paths', () {
      final input = {
        'data': {'title': 'Hello'},
      };
      expect(resolveRef(['data', 'title'], input), 'Hello');
    });

    test('resolves list index segments', () {
      final input = {
        'data': {
          'items': [
            {'id': 'a'},
            {'id': 'b'},
          ],
        },
      };
      expect(resolveRef(['data', 'items', '0', 'id'], input), 'a');
      expect(resolveRef(['data', 'items', '1', 'id'], input), 'b');
    });

    test('resolves through getter accessors via __getters__ map', () {
      // When codegen emits a model field accessor it provides a
      // `__getters__` shim: `{'data': {'title': () => model.title}}`.
      final input = {
        'data': {
          '__getters__': {
            'title': () => 'Computed',
          },
        },
      };
      expect(resolveRef(['data', 'title'], input), 'Computed');
    });

    test('returns null on missing path', () {
      expect(resolveRef(['missing'], {}), isNull);
      expect(resolveRef(['data', 'missing'], {'data': {}}), isNull);
    });

    test('throws on non-indexable mid-path', () {
      expect(
        () => resolveRef(['a', 'b'], {'a': 42}),
        throwsA(isA<StateError>()),
      );
    });
  });
}
```

- [ ] **Step 2: Run — expect FAIL**

Run: `flutter test test/ref_resolver_test.dart`

- [ ] **Step 3: Implement**

```dart
// lib/src/ref_resolver.dart

/// Walks a pre-split path through nested maps/lists and returns the leaf.
///
/// Codegen emits paths like `['data','items','0','title']`; per-build cost
/// is one `Map.[]` or `List.[]` per segment.
Object? resolveRef(List<String> path, Map<String, Object?> input) {
  Object? current = input;
  for (final seg in path) {
    if (current == null) return null;
    if (current is Map) {
      // Codegen-emitted getter shim: `{'__getters__': {'title': () => ...}}`.
      final getters = current['__getters__'];
      if (getters is Map && getters.containsKey(seg)) {
        final g = getters[seg];
        if (g is Function) {
          current = Function.apply(g, const []);
          continue;
        }
      }
      current = current[seg];
      continue;
    }
    if (current is List) {
      final i = int.tryParse(seg);
      if (i == null || i < 0 || i >= current.length) return null;
      current = current[i];
      continue;
    }
    throw StateError(
      'RefResolver: cannot index segment "$seg" on ${current.runtimeType}',
    );
  }
  return current;
}
```

- [ ] **Step 4: Run — expect PASS**

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui/lib/src/ref_resolver.dart packages/desk_sdui/test/ref_resolver_test.dart
git commit -m "feat(desk_sdui): RefResolver path walker"
```

---

## Task 4: Implement `ExpressionEval`

Evaluate `ExpressionNode` subtrees against the input map. Pure function — no widget context needed.

**Files:**
- Create: `packages/desk_sdui/lib/src/expression_eval.dart`
- Test: `packages/desk_sdui/test/expression_eval_test.dart`

- [ ] **Step 1: Write tests covering each ExpressionNode subclass**

```dart
// test/expression_eval_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:desk_sdui/src/expression_eval.dart';

void main() {
  group('ExpressionEval', () {
    final input = <String, Object?>{
      'a': 5,
      'b': 3,
      'name': 'World',
      'flag': true,
      'xs': [1, 2, 3],
      'maybe': null,
    };

    test('CompareOp >', () {
      final node = CompareOpNode(
        op: CompareOp.gt,
        left: const RefNode(path: ['a']),
        right: const RefNode(path: ['b']),
      );
      expect(evalExpression(node, input), true);
    });

    test('CompareOp >= equal', () {
      final node = CompareOpNode(
        op: CompareOp.gte,
        left: const RefNode(path: ['a']),
        right: const LiteralNode(5),
      );
      expect(evalExpression(node, input), true);
    });

    test('ArithOp +', () {
      final node = ArithOpNode(
        op: ArithOp.add,
        left: const RefNode(path: ['a']),
        right: const RefNode(path: ['b']),
      );
      expect(evalExpression(node, input), 8);
    });

    test('LogicOp && short-circuits on false', () {
      final node = LogicOpNode(
        op: LogicOp.and,
        left: const LiteralNode(false),
        right: const RefNode(path: ['nonexistent']),
      );
      expect(evalExpression(node, input), false);
    });

    test('LogicOp || short-circuits on true', () {
      final node = LogicOpNode(
        op: LogicOp.or,
        left: const LiteralNode(true),
        right: const RefNode(path: ['nonexistent']),
      );
      expect(evalExpression(node, input), true);
    });

    test('NotOp', () {
      final node = NotOpNode(operand: const RefNode(path: ['flag']));
      expect(evalExpression(node, input), false);
    });

    test('CoalesceOp picks right when left is null', () {
      final node = CoalesceOpNode(
        left: const RefNode(path: ['maybe']),
        right: const LiteralNode('fallback'),
      );
      expect(evalExpression(node, input), 'fallback');
    });

    test('MemberAccess', () {
      final inputWithRecord = {
        'pair': {'first': 1, 'second': 2},
      };
      final node = MemberAccessNode(
        target: const RefNode(path: ['pair']),
        member: 'first',
      );
      expect(evalExpression(node, inputWithRecord), 1);
    });

    test('IndexAccess', () {
      final node = IndexAccessNode(
        target: const RefNode(path: ['xs']),
        index: const LiteralNode(1),
      );
      expect(evalExpression(node, input), 2);
    });

    test('LengthOf list', () {
      final node = LengthOfNode(target: const RefNode(path: ['xs']));
      expect(evalExpression(node, input), 3);
    });

    test('LengthOf string', () {
      final node = LengthOfNode(target: const RefNode(path: ['name']));
      expect(evalExpression(node, input), 5);
    });

    test('IsNullCheck true for null', () {
      final node = IsNullCheckNode(operand: const RefNode(path: ['maybe']));
      expect(evalExpression(node, input), true);
    });

    test('IsNullCheck false for non-null', () {
      final node = IsNullCheckNode(operand: const RefNode(path: ['a']));
      expect(evalExpression(node, input), false);
    });

    test('StringInterp concatenates', () {
      final node = StringInterpNode(parts: [
        const LiteralNode('Hi '),
        const RefNode(path: ['name']),
        const LiteralNode('!'),
      ]);
      expect(evalExpression(node, input), 'Hi World!');
    });

    test('LiteralNode passes through', () {
      expect(evalExpression(const LiteralNode(42), input), 42);
    });
  });
}
```

- [ ] **Step 2: Run — expect FAIL**

- [ ] **Step 3: Implement `evalExpression` with sealed switch**

```dart
// lib/src/expression_eval.dart
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'ref_resolver.dart';

Object? evalExpression(IrNode node, Map<String, Object?> input) {
  switch (node) {
    case LiteralNode(:final value): return value;
    case ConstNode(:final value): return value;
    case RefNode(:final path): return resolveRef(path, input);

    case CompareOpNode(:final op, :final left, :final right):
      final l = evalExpression(left, input);
      final r = evalExpression(right, input);
      return switch (op) {
        CompareOp.eq => l == r,
        CompareOp.neq => l != r,
        CompareOp.lt => (l as num) < (r as num),
        CompareOp.lte => (l as num) <= (r as num),
        CompareOp.gt => (l as num) > (r as num),
        CompareOp.gte => (l as num) >= (r as num),
      };

    case ArithOpNode(:final op, :final left, :final right):
      final l = evalExpression(left, input) as num;
      final r = evalExpression(right, input) as num;
      return switch (op) {
        ArithOp.add => l + r,
        ArithOp.sub => l - r,
        ArithOp.mul => l * r,
        ArithOp.div => l / r,
        ArithOp.mod => l % r,
      };

    case LogicOpNode(:final op, :final left, :final right):
      final l = evalExpression(left, input) as bool;
      return switch (op) {
        LogicOp.and => l && (evalExpression(right, input) as bool),
        LogicOp.or => l || (evalExpression(right, input) as bool),
      };

    case NotOpNode(:final operand):
      return !(evalExpression(operand, input) as bool);

    case CoalesceOpNode(:final left, :final right):
      final l = evalExpression(left, input);
      return l ?? evalExpression(right, input);

    case MemberAccessNode(:final target, :final member):
      final t = evalExpression(target, input);
      if (t is Map) return t[member];
      throw StateError('MemberAccess on non-map ${t.runtimeType}');

    case IndexAccessNode(:final target, :final index):
      final t = evalExpression(target, input);
      final i = evalExpression(index, input);
      if (t is List) return t[i as int];
      if (t is Map) return t[i];
      throw StateError('IndexAccess on ${t.runtimeType}');

    case LengthOfNode(:final target):
      final t = evalExpression(target, input);
      if (t is String) return t.length;
      if (t is List) return t.length;
      if (t is Map) return t.length;
      throw StateError('LengthOf on ${t.runtimeType}');

    case IsNullCheckNode(:final operand):
      return evalExpression(operand, input) == null;

    case StringInterpNode(:final parts):
      final buf = StringBuffer();
      for (final p in parts) {
        buf.write(evalExpression(p, input) ?? '');
      }
      return buf.toString();

    default:
      throw StateError('evalExpression: unsupported node $node');
  }
}
```

- [ ] **Step 4: Run — expect PASS**

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui/lib/src/expression_eval.dart packages/desk_sdui/test/expression_eval_test.dart
git commit -m "feat(desk_sdui): expression evaluator with sealed switch"
```

---

## Task 5: Implement `Resolver` (node-tree walker → Widget)

The resolve pass walks an `IrTree` against the input map and produces a `Widget`. It dispatches on `IrNode` subtype.

**Files:**
- Create: `packages/desk_sdui/lib/src/resolve.dart`
- Test: `packages/desk_sdui/test/resolve_test.dart`

- [ ] **Step 1: Write minimal tests for each non-expression IrNode**

```dart
// test/resolve_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:desk_sdui/desk_sdui.dart';
import 'package:desk_sdui/src/resolve.dart';

void main() {
  late Runtime rt;

  setUp(() {
    rt = Runtime();
    rt.registerWidget('Sentinel', (ctx, args) {
      return Text(args['label'] as String? ?? '', textDirection: TextDirection.ltr);
    });
    rt.registerWidget('Container', (ctx, args) {
      return Container(child: args['child'] as Widget?);
    });
    rt.registerWidget('Column', (ctx, args) {
      return Column(children: (args['children'] as List).cast<Widget>());
    });
  });

  Widget resolveOnce(IrNode root, Map<String, Object?> input) {
    return Builder(
      builder: (ctx) => resolveNode(ctx, root, input, rt),
    );
  }

  testWidgets('LiteralNode of widget passes through', (tester) async {
    // We don't have a LiteralWidgetNode — widgets always come from WidgetNode.
    // This case is for non-widget literals used in args; covered indirectly.
  });

  testWidgets('WidgetNode looks up registered builder', (tester) async {
    final ir = WidgetNode(name: 'Sentinel', args: {
      'label': const LiteralNode('hi'),
    });
    await tester.pumpWidget(resolveOnce(ir, {}));
    expect(find.text('hi'), findsOneWidget);
  });

  testWidgets('WidgetNode resolves RefNode args', (tester) async {
    final ir = WidgetNode(name: 'Sentinel', args: {
      'label': const RefNode(path: ['greeting']),
    });
    await tester.pumpWidget(resolveOnce(ir, {'greeting': 'hello'}));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('ListNode of WidgetNodes resolves to List<Widget>', (tester) async {
    final ir = WidgetNode(name: 'Column', args: {
      'children': ListNode(children: [
        WidgetNode(name: 'Sentinel', args: {'label': const LiteralNode('a')}),
        WidgetNode(name: 'Sentinel', args: {'label': const LiteralNode('b')}),
      ]),
    });
    await tester.pumpWidget(resolveOnce(ir, {}));
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
  });

  testWidgets('ConditionalNode picks then-branch when condition true',
      (tester) async {
    final ir = ConditionalNode(
      condition: const LiteralNode(true),
      then: WidgetNode(name: 'Sentinel', args: {'label': const LiteralNode('y')}),
      otherwise: WidgetNode(name: 'Sentinel', args: {'label': const LiteralNode('n')}),
    );
    await tester.pumpWidget(resolveOnce(ir, {}));
    expect(find.text('y'), findsOneWidget);
    expect(find.text('n'), findsNothing);
  });

  testWidgets('ConditionalNode without else returns SizedBox.shrink',
      (tester) async {
    final ir = WidgetNode(name: 'Column', args: {
      'children': ListNode(children: [
        ConditionalNode(
          condition: const LiteralNode(false),
          then: WidgetNode(name: 'Sentinel', args: {'label': const LiteralNode('x')}),
        ),
      ]),
    });
    await tester.pumpWidget(resolveOnce(ir, {}));
    expect(find.text('x'), findsNothing);
  });

  testWidgets('ForNode iterates and resolves body', (tester) async {
    final ir = WidgetNode(name: 'Column', args: {
      'children': ForNode(
        loopVar: 'item',
        source: const RefNode(path: ['xs']),
        body: WidgetNode(name: 'Sentinel', args: {
          'label': const RefNode(path: ['item']),
        }),
      ),
    });
    await tester.pumpWidget(resolveOnce(ir, {'xs': ['a', 'b', 'c']}));
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
    expect(find.text('c'), findsOneWidget);
  });

  testWidgets('ForNode destructured iterates with indexed pair', (tester) async {
    final ir = WidgetNode(name: 'Column', args: {
      'children': ForNode.destructured(
        loopVars: ['i', 'x'],
        source: const RefNode(path: ['xs']),
        body: WidgetNode(name: 'Sentinel', args: {
          'label': StringInterpNode(parts: [
            const RefNode(path: ['i']),
            const LiteralNode(':'),
            const RefNode(path: ['x']),
          ]),
        }),
      ),
    });
    // For destructured we expect the source to already be `.indexed` — for the
    // test we shape it as a list of (i, x) records; codegen handles real
    // `.indexed`.
    await tester.pumpWidget(resolveOnce(ir, {
      'xs': [
        {'first': 0, 'second': 'a'},
        {'first': 1, 'second': 'b'},
      ],
    }));
    expect(find.text('0:a'), findsOneWidget);
    expect(find.text('1:b'), findsOneWidget);
  });

  testWidgets('SpreadNode flattens into surrounding list', (tester) async {
    final ir = WidgetNode(name: 'Column', args: {
      'children': ListNode(children: [
        WidgetNode(name: 'Sentinel', args: {'label': const LiteralNode('head')}),
        SpreadNode(source: ListNode(children: [
          WidgetNode(name: 'Sentinel', args: {'label': const LiteralNode('m1')}),
          WidgetNode(name: 'Sentinel', args: {'label': const LiteralNode('m2')}),
        ])),
        WidgetNode(name: 'Sentinel', args: {'label': const LiteralNode('tail')}),
      ]),
    });
    await tester.pumpWidget(resolveOnce(ir, {}));
    expect(find.text('head'), findsOneWidget);
    expect(find.text('m1'), findsOneWidget);
    expect(find.text('m2'), findsOneWidget);
    expect(find.text('tail'), findsOneWidget);
  });

  testWidgets('Unregistered widget throws useful error', (tester) async {
    final ir = WidgetNode(name: 'NotRegistered', args: {});
    expect(
      () => Builder(builder: (ctx) => resolveNode(ctx, ir, {}, rt)),
      isNotNull, // build at runtime
    );
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (ctx) {
      try {
        return resolveNode(ctx, ir, {}, rt);
      } catch (e) {
        return Text(
          'caught:${e.runtimeType}',
          textDirection: TextDirection.ltr,
        );
      }
    })));
    expect(find.textContaining('caught:'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run — expect FAIL**

- [ ] **Step 3: Implement `resolveNode`**

```dart
// lib/src/resolve.dart
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:flutter/widgets.dart';
import 'expression_eval.dart';
import 'ref_resolver.dart';
import 'runtime.dart';

/// Resolves an IR node to a Widget. May recurse.
Widget resolveNode(
  BuildContext context,
  IrNode node,
  Map<String, Object?> input,
  Runtime runtime,
) {
  switch (node) {
    case ConstNode(:final value):
      if (value is Widget) return value;
      throw StateError('ConstNode at widget position must hold a Widget');

    case WidgetNode(:final name, :final args, :final key):
      final builder = runtime.widgetFor(name);
      if (builder == null) {
        throw StateError('Widget "$name" is not registered');
      }
      final resolvedArgs = <String, Object?>{};
      args.forEach((k, v) {
        resolvedArgs[k] = _resolveArg(context, v, input, runtime);
      });
      if (key != null) {
        resolvedArgs['key'] = _resolveArg(context, key, input, runtime);
      }
      return builder(context, resolvedArgs);

    case BuiltinWidgetNode(:final name, :final args):
      // Same as WidgetNode but routed through built-in registry; for v1 we
      // register builtins into the same `widgetFor` map at boot.
      return resolveNode(
        context,
        WidgetNode(name: name, args: args),
        input,
        runtime,
      );

    case ConditionalNode(:final condition, :final then, :final otherwise):
      final cond = evalExpression(condition, input);
      if (cond == true) return resolveNode(context, then, input, runtime);
      if (otherwise != null) return resolveNode(context, otherwise, input, runtime);
      return const SizedBox.shrink();

    case LiteralNode(:final value):
      if (value is Widget) return value;
      throw StateError('LiteralNode at widget position holds non-widget $value');

    default:
      throw StateError('resolveNode: $node not valid at widget position');
  }
}

/// Resolves a non-widget argument (any IrNode used as a property value).
Object? _resolveArg(
  BuildContext context,
  IrNode node,
  Map<String, Object?> input,
  Runtime runtime,
) {
  switch (node) {
    case LiteralNode(:final value): return value;
    case ConstNode(:final value): return value;
    case RefNode(:final path): return resolveRef(path, input);

    case ListNode(:final children):
      final out = <Object?>[];
      for (final child in children) {
        if (child is SpreadNode) {
          final spread = _resolveArg(context, child.source, input, runtime);
          if (spread is List) {
            out.addAll(spread);
          } else {
            throw StateError('SpreadNode source did not resolve to List');
          }
        } else if (child is WidgetNode || child is BuiltinWidgetNode || child is ConstNode) {
          out.add(resolveNode(context, child, input, runtime));
        } else if (child is ForNode) {
          out.addAll(_expandFor(context, child, input, runtime));
        } else if (child is ConditionalNode) {
          // Conditional inside a list: include only on truthy branch.
          final cond = evalExpression(child.condition, input);
          if (cond == true) {
            out.add(resolveNode(context, child.then, input, runtime));
          } else if (child.otherwise != null) {
            out.add(resolveNode(context, child.otherwise!, input, runtime));
          }
        } else {
          out.add(_resolveArg(context, child, input, runtime));
        }
      }
      return out;

    case MapNode(:final entries):
      return entries.map((k, v) => MapEntry(k, _resolveArg(context, v, input, runtime)));

    case ForNode():
      return _expandFor(context, node, input, runtime);

    case WidgetNode():
    case BuiltinWidgetNode():
      return resolveNode(context, node, input, runtime);

    case EventNode():
      return _bindEvent(node, input, runtime);

    default:
      // Expression evaluates to a primitive
      return evalExpression(node, input);
  }
}

List<Object?> _expandFor(
  BuildContext context,
  ForNode node,
  Map<String, Object?> input,
  Runtime runtime,
) {
  final source = evalExpression(node.source, input);
  if (source is! Iterable) {
    throw StateError('ForNode source did not resolve to Iterable');
  }
  final out = <Object?>[];
  for (final raw in source) {
    final scoped = Map<String, Object?>.of(input);
    if (node.loopVars != null) {
      // Destructured: expect a record-like with `first`/`second` keys (codegen
      // emits this from `xs.indexed`).
      if (raw is Map) {
        scoped[node.loopVars![0]] = raw['first'];
        scoped[node.loopVars![1]] = raw['second'];
      } else {
        throw StateError('ForNode.destructured requires Map<String, _> source items');
      }
    } else {
      scoped[node.loopVar!] = raw;
    }
    out.add(_resolveArg(context, node.body, scoped, runtime));
  }
  return out;
}

Object? _bindEvent(
  EventNode node,
  Map<String, Object?> input,
  Runtime runtime,
) {
  // Look up bound method via input['__methods__'] map keyed by joined path.
  final methods = input['__methods__'];
  if (methods is Map) {
    final key = node.target.join('.');
    final fn = methods[key];
    if (fn is Function) {
      // If args supplied, partially apply; else return as-is.
      if (node.args == null || node.args!.isEmpty) return fn;
      final positional = <Object?>[];
      for (var i = 0; ; i++) {
        final argKey = 'arg$i';
        if (!node.args!.containsKey(argKey)) break;
        positional.add(evalExpression(node.args![argKey]!, input));
      }
      return () => Function.apply(fn, positional);
    }
  }
  throw StateError('EventNode target ${node.target.join('.')} not bound');
}
```

- [ ] **Step 4: Run — expect PASS**

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui/lib/src/resolve.dart packages/desk_sdui/test/resolve_test.dart
git commit -m "feat(desk_sdui): IR resolver — WidgetNode/Conditional/For/Spread/List"
```

---

## Task 6: Reactive scope rendering

Phase 1 already added `WidgetNode.listenablePaths: Set<String>`. The runtime, when resolving a `WidgetNode` whose `listenablePaths` is non-empty, wraps the resulting subtree in a `ListenableBuilder` subscribed to the matching `Listenable`s from the input map. Only that subtree rebuilds on listenable change.

**No annotation-package changes required.** Each entry in `listenablePaths` is a stringified ref-path (e.g., `"controller.showPromoCode"`). The runtime looks each up in `input['__reactive__']`.

**Files:**
- Create: `packages/desk_sdui/lib/src/reactive.dart`
- Modify: `packages/desk_sdui/lib/src/resolve.dart` (consult `WidgetNode.listenablePaths`)
- Test: `packages/desk_sdui/test/reactive_test.dart`

- [ ] **Step 1: (skipped — no annotation changes)**

- [ ] **Step 2: Write the test**

```dart
// test/reactive_test.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:desk_sdui/desk_sdui.dart';
import 'package:desk_sdui/src/resolve.dart';

void main() {
  testWidgets(
    'WidgetNode.listenablePaths rebuilds only its subtree on listenable change',
    (tester) async {
      final rt = Runtime();
      var outerBuilds = 0;
      var innerBuilds = 0;
      rt.registerWidget('Outer', (ctx, args) {
        outerBuilds++;
        return Column(children: (args['children'] as List).cast<Widget>());
      });
      rt.registerWidget('Inner', (ctx, args) {
        innerBuilds++;
        return Text(
          args['label'].toString(),
          textDirection: TextDirection.ltr,
        );
      });

      final notifier = ValueNotifier<int>(0);
      final input = <String, Object?>{
        '__reactive__': {'count': notifier},
      };

      // The outer Column is non-reactive; the inner Text wrapper carries
      // `listenablePaths: {'count'}`.
      final ir = WidgetNode(
        name: 'Outer',
        args: {
          'children': ListNode([
            WidgetNode(
              name: 'Inner',
              listenablePaths: const {'count'},
              args: {
                'label': const RefNode(['count'], reactive: true),
              },
            ),
          ]),
        },
      );

      await tester.pumpWidget(Builder(builder: (ctx) {
        return resolveNode(ctx, ir, input, rt);
      }));

      expect(outerBuilds, 1);
      expect(innerBuilds, 1);
      expect(find.text('0'), findsOneWidget);

      notifier.value = 1;
      await tester.pump();

      expect(outerBuilds, 1, reason: 'outer should not rebuild');
      expect(innerBuilds, 2, reason: 'inner rebuilt by ListenableBuilder');
      expect(find.text('1'), findsOneWidget);
    },
  );
}
```

- [ ] **Step 3: Implement reactive scope handling in `resolveNode`**

When dispatching `WidgetNode`, if `listenablePaths.isNotEmpty`, wrap the resolution in a `ListenableBuilder`. Inside the builder, install `__getters__` shims at each reactive path so `RefNode(reactive: true)` reads return `listenable.value`.

```dart
case WidgetNode(
  :final name,
  :final args,
  :final key,
  :final listenablePaths,
):
  if (listenablePaths.isEmpty) {
    return _buildWidget(context, name, args, key, input, runtime);
  }
  final reactiveMap = input['__reactive__'];
  if (reactiveMap is! Map) {
    throw StateError(
      'WidgetNode "$name" declares listenablePaths but input has no __reactive__ map',
    );
  }
  final listenables = <Listenable>[];
  for (final pathStr in listenablePaths) {
    final l = reactiveMap[pathStr];
    if (l is Listenable) listenables.add(l);
  }
  return ListenableBuilder(
    listenable: Listenable.merge(listenables),
    builder: (ctx, _) {
      final scopedInput = Map<String, Object?>.of(input);
      for (final pathStr in listenablePaths) {
        _installReactiveGetter(scopedInput, pathStr.split('.'), reactiveMap);
      }
      return _buildWidget(ctx, name, args, key, scopedInput, runtime);
    },
  );
```

Where `_buildWidget` is the previously-inlined widget construction code (registry lookup + arg resolution + builder invocation), extracted into a helper.

```dart
void _installReactiveGetter(
  Map<String, Object?> input,
  List<String> path,
  Map reactiveMap,
) {
  final pathStr = path.join('.');
  final listenable = reactiveMap[pathStr];
  if (listenable is! ValueListenable) return;
  Map<String, Object?> cursor = input;
  for (var i = 0; i < path.length - 1; i++) {
    final next = cursor[path[i]];
    if (next is Map) {
      cursor = Map<String, Object?>.of(next.cast<String, Object?>());
      input[path[i]] = cursor;
    } else {
      final fresh = <String, Object?>{};
      cursor[path[i]] = fresh;
      cursor = fresh;
    }
  }
  final getters =
      (cursor['__getters__'] as Map?)?.cast<String, Object?>() ?? {};
  getters[path.last] = () => listenable.value;
  cursor['__getters__'] = getters;
}
```

- [ ] **Step 4: Run — expect PASS**

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui/lib/src/resolve.dart packages/desk_sdui/test/reactive_test.dart packages/desk_sdui_annotation
git commit -m "feat(desk_sdui): ReactiveScopeNode + ListenableBuilder integration"
```

---

## Task 7: Built-in widgets

Register a closed set of layout primitives so a developer doesn't need to register `Column`/`Row`/`Padding`/etc themselves.

**Files:**
- Create: `packages/desk_sdui/lib/src/builtins/builtin_widgets.dart`
- Test: `packages/desk_sdui/test/builtins_test.dart`

- [ ] **Step 1: Define `registerBuiltinWidgets(Runtime rt)`**

Cover at minimum: `Container`, `Padding`, `Center`, `SizedBox`, `Column`, `Row`, `Stack`, `Expanded`, `Flexible`, `Align`, `Text`, `Icon`, `InkWell`, `GestureDetector`, `ListView`, `ListView.builder` (as `ListView` with `children`), `SingleChildScrollView`, `ClipRRect`, `Card`, `Material`, `Divider`, `Spacer`, `AspectRatio`, `Wrap`, `IntrinsicHeight`, `SafeArea`, `Image.network` (as `NetworkImage`), `Image.asset` (as `AssetImage`).

Each builder reads named keys from `args` with type coercions (e.g., `EdgeInsets`/`AlignmentGeometry`/`Color`/`MainAxisAlignment` literals are stored as-is from `LiteralNode(<const>)` baked at build time).

```dart
// lib/src/builtins/builtin_widgets.dart
import 'package:flutter/material.dart';
import '../runtime.dart';

void registerBuiltinWidgets(Runtime rt) {
  rt.registerWidget('Container', (ctx, args) => Container(
    padding: args['padding'] as EdgeInsetsGeometry?,
    margin: args['margin'] as EdgeInsetsGeometry?,
    color: args['color'] as Color?,
    width: (args['width'] as num?)?.toDouble(),
    height: (args['height'] as num?)?.toDouble(),
    alignment: args['alignment'] as AlignmentGeometry?,
    child: args['child'] as Widget?,
  ));

  rt.registerWidget('Padding', (ctx, args) => Padding(
    padding: args['padding'] as EdgeInsetsGeometry,
    child: args['child'] as Widget,
  ));

  rt.registerWidget('SizedBox', (ctx, args) => SizedBox(
    width: (args['width'] as num?)?.toDouble(),
    height: (args['height'] as num?)?.toDouble(),
    child: args['child'] as Widget?,
  ));

  rt.registerWidget('Column', (ctx, args) => Column(
    mainAxisAlignment: args['mainAxisAlignment'] as MainAxisAlignment? ?? MainAxisAlignment.start,
    crossAxisAlignment: args['crossAxisAlignment'] as CrossAxisAlignment? ?? CrossAxisAlignment.center,
    mainAxisSize: args['mainAxisSize'] as MainAxisSize? ?? MainAxisSize.max,
    children: ((args['children'] as List?) ?? const []).cast<Widget>(),
  ));

  rt.registerWidget('Row', (ctx, args) => Row(
    mainAxisAlignment: args['mainAxisAlignment'] as MainAxisAlignment? ?? MainAxisAlignment.start,
    crossAxisAlignment: args['crossAxisAlignment'] as CrossAxisAlignment? ?? CrossAxisAlignment.center,
    mainAxisSize: args['mainAxisSize'] as MainAxisSize? ?? MainAxisSize.max,
    children: ((args['children'] as List?) ?? const []).cast<Widget>(),
  ));

  rt.registerWidget('Stack', (ctx, args) => Stack(
    alignment: args['alignment'] as AlignmentGeometry? ?? AlignmentDirectional.topStart,
    fit: args['fit'] as StackFit? ?? StackFit.loose,
    children: ((args['children'] as List?) ?? const []).cast<Widget>(),
  ));

  rt.registerWidget('Center', (ctx, args) => Center(child: args['child'] as Widget?));
  rt.registerWidget('Align', (ctx, args) => Align(
    alignment: args['alignment'] as AlignmentGeometry? ?? Alignment.center,
    child: args['child'] as Widget?,
  ));
  rt.registerWidget('Expanded', (ctx, args) => Expanded(
    flex: (args['flex'] as int?) ?? 1,
    child: args['child'] as Widget,
  ));
  rt.registerWidget('Flexible', (ctx, args) => Flexible(
    flex: (args['flex'] as int?) ?? 1,
    child: args['child'] as Widget,
  ));

  rt.registerWidget('Text', (ctx, args) => Text(
    args['data'] as String,
    style: args['style'] as TextStyle?,
    textAlign: args['textAlign'] as TextAlign?,
    maxLines: args['maxLines'] as int?,
    overflow: args['overflow'] as TextOverflow?,
  ));

  rt.registerWidget('Icon', (ctx, args) => Icon(
    args['icon'] as IconData,
    size: (args['size'] as num?)?.toDouble(),
    color: args['color'] as Color?,
  ));

  rt.registerWidget('InkWell', (ctx, args) => InkWell(
    onTap: args['onTap'] as VoidCallback?,
    child: args['child'] as Widget?,
  ));

  rt.registerWidget('GestureDetector', (ctx, args) => GestureDetector(
    onTap: args['onTap'] as VoidCallback?,
    child: args['child'] as Widget?,
  ));

  rt.registerWidget('SingleChildScrollView', (ctx, args) => SingleChildScrollView(
    scrollDirection: args['scrollDirection'] as Axis? ?? Axis.vertical,
    padding: args['padding'] as EdgeInsetsGeometry?,
    child: args['child'] as Widget?,
  ));

  rt.registerWidget('ListView', (ctx, args) => ListView(
    scrollDirection: args['scrollDirection'] as Axis? ?? Axis.vertical,
    padding: args['padding'] as EdgeInsetsGeometry?,
    shrinkWrap: (args['shrinkWrap'] as bool?) ?? false,
    children: ((args['children'] as List?) ?? const []).cast<Widget>(),
  ));

  rt.registerWidget('ClipRRect', (ctx, args) => ClipRRect(
    borderRadius: args['borderRadius'] as BorderRadiusGeometry? ?? BorderRadius.zero,
    child: args['child'] as Widget?,
  ));

  rt.registerWidget('Card', (ctx, args) => Card(
    elevation: (args['elevation'] as num?)?.toDouble(),
    color: args['color'] as Color?,
    margin: args['margin'] as EdgeInsetsGeometry?,
    child: args['child'] as Widget?,
  ));

  rt.registerWidget('Material', (ctx, args) => Material(
    color: args['color'] as Color?,
    elevation: (args['elevation'] as num?)?.toDouble() ?? 0,
    child: args['child'] as Widget?,
  ));

  rt.registerWidget('Divider', (ctx, args) => Divider(
    height: (args['height'] as num?)?.toDouble(),
    thickness: (args['thickness'] as num?)?.toDouble(),
    color: args['color'] as Color?,
  ));

  rt.registerWidget('Spacer', (ctx, args) => Spacer(flex: (args['flex'] as int?) ?? 1));

  rt.registerWidget('AspectRatio', (ctx, args) => AspectRatio(
    aspectRatio: (args['aspectRatio'] as num).toDouble(),
    child: args['child'] as Widget,
  ));

  rt.registerWidget('Wrap', (ctx, args) => Wrap(
    spacing: (args['spacing'] as num?)?.toDouble() ?? 0,
    runSpacing: (args['runSpacing'] as num?)?.toDouble() ?? 0,
    children: ((args['children'] as List?) ?? const []).cast<Widget>(),
  ));

  rt.registerWidget('IntrinsicHeight', (ctx, args) => IntrinsicHeight(
    child: args['child'] as Widget,
  ));

  rt.registerWidget('SafeArea', (ctx, args) => SafeArea(
    child: args['child'] as Widget,
  ));
}
```

- [ ] **Step 2: Add tests for each builtin (smoke level)**

```dart
// test/builtins_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:desk_sdui/desk_sdui.dart';
import 'package:desk_sdui/src/resolve.dart';
import 'package:desk_sdui/src/builtins/builtin_widgets.dart';

void main() {
  late Runtime rt;
  setUp(() {
    rt = Runtime();
    registerBuiltinWidgets(rt);
  });

  testWidgets('Column with two Text children', (tester) async {
    final ir = WidgetNode(name: 'Column', args: {
      'children': ListNode(children: [
        WidgetNode(name: 'Text', args: {'data': const LiteralNode('a')}),
        WidgetNode(name: 'Text', args: {'data': const LiteralNode('b')}),
      ]),
    });
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (ctx) {
      return resolveNode(ctx, ir, {}, rt);
    })));
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
  });

  testWidgets('Padding wraps child', (tester) async {
    final ir = WidgetNode(name: 'Padding', args: {
      'padding': const LiteralNode(EdgeInsets.all(8)),
      'child': WidgetNode(name: 'Text', args: {'data': const LiteralNode('p')}),
    });
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (ctx) {
      return resolveNode(ctx, ir, {}, rt);
    })));
    expect(find.text('p'), findsOneWidget);
    expect(find.byType(Padding), findsWidgets);
  });

  // ... one terse smoke test per builtin (Container, SizedBox, Row, Stack,
  // Center, Align, Expanded, Flexible, Icon, InkWell, ClipRRect, Card,
  // Material, Divider, Spacer, AspectRatio, Wrap, IntrinsicHeight, SafeArea,
  // SingleChildScrollView, ListView). Each ~5 lines.
}
```

- [ ] **Step 3: Run — expect PASS**

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui/lib/src/builtins packages/desk_sdui/test/builtins_test.dart
git commit -m "feat(desk_sdui): built-in widget registry — layout primitives"
```

---

## Task 8: `.sdui.json` fetchers

Three sources, all decode through Phase 1's `JsonIrCodec`.

**Files:**
- Create: `packages/desk_sdui/lib/src/loader/ir_fetcher.dart`
- Create: `packages/desk_sdui/lib/src/loader/asset_bundle_ir_fetcher.dart`
- Create: `packages/desk_sdui/lib/src/loader/remote_ir_fetcher.dart`
- Test: `packages/desk_sdui/test/loader_test.dart`

- [ ] **Step 1: Write tests**

```dart
// test/loader_test.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desk_sdui/src/loader/asset_bundle_ir_fetcher.dart';
import 'package:desk_sdui/src/loader/remote_ir_fetcher.dart';

void main() {
  group('AssetBundleIrFetcher', () {
    test('reads <prefix>/<name>.uib from bundle', () async {
      final bundle = _FakeBundle({'sdui/cart.uib': '{"name":"cart","version":1,"root":{"\$type":"literal","value":null}}'});
      final fetcher = AssetBundleIrFetcher(bundle: bundle, prefix: 'sdui');
      final bytes = await fetcher.fetch('cart');
      expect(utf8.decode(bytes), contains('"name":"cart"'));
    });
  });

  group('RemoteIrFetcher', () {
    test('GETs <endpoint>/<name>.uib', () async {
      late Uri capturedUri;
      final fetcher = RemoteIrFetcher(
        endpoint: Uri.parse('https://api.example.com/sdui'),
        client: (uri) async {
          capturedUri = uri;
          return utf8.encode('{"ok":true}');
        },
      );
      final bytes = await fetcher.fetch('home');
      expect(capturedUri.toString(), 'https://api.example.com/sdui/home.uib');
      expect(utf8.decode(bytes), '{"ok":true}');
    });
  });
}

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this._files);
  final Map<String, String> _files;

  @override
  Future<ByteData> load(String key) async {
    final s = _files[key];
    if (s == null) throw FlutterError('not found: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(s)));
  }
}
```

- [ ] **Step 2: Implement `IrFetcher` abstract**

```dart
// lib/src/loader/ir_fetcher.dart
abstract class IrFetcher {
  Future<List<int>> fetch(String name);
}
```

- [ ] **Step 3: Implement asset bundle fetcher**

```dart
// lib/src/loader/asset_bundle_ir_fetcher.dart
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'ir_fetcher.dart';

class AssetBundleIrFetcher implements IrFetcher {
  AssetBundleIrFetcher({required this.bundle, this.prefix = 'sdui'});
  final AssetBundle bundle;
  final String prefix;

  @override
  Future<List<int>> fetch(String name) async {
    final key = '$prefix/$name.uib';
    final data = await bundle.load(key);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
```

- [ ] **Step 4: Implement remote fetcher**

```dart
// lib/src/loader/remote_ir_fetcher.dart
import 'package:http/http.dart' as http;
import 'ir_fetcher.dart';

typedef HttpGet = Future<List<int>> Function(Uri uri);

class RemoteIrFetcher implements IrFetcher {
  RemoteIrFetcher({required this.endpoint, HttpGet? client})
      : _client = client ?? _defaultGet;

  final Uri endpoint;
  final HttpGet _client;

  @override
  Future<List<int>> fetch(String name) async {
    final uri = endpoint.replace(
      pathSegments: [...endpoint.pathSegments, '$name.uib'],
    );
    return _client(uri);
  }

  static Future<List<int>> _defaultGet(Uri uri) async {
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw StateError('GET $uri failed: ${res.statusCode}');
    }
    return res.bodyBytes;
  }
}
```

- [ ] **Step 5: Run — expect PASS**

- [ ] **Step 6: Commit**

```bash
git add packages/desk_sdui/lib/src/loader packages/desk_sdui/test/loader_test.dart
git commit -m "feat(desk_sdui): IR fetchers — asset bundle + remote"
```

---

## Task 9: Wire `Runtime.load` with cache

**Files:**
- Modify: `packages/desk_sdui/lib/src/runtime.dart`
- Test: extend `packages/desk_sdui/test/runtime_test.dart`

- [ ] **Step 1: Write test for cache + resolution order**

```dart
testWidgets('Runtime.load picks fetcher first, then asset, then in-binary',
    (tester) async {
  // ... validate that calling load('cart') consults fetcher; if absent,
  // asset; if absent, in-binary ScreenBinding.ir.
});

testWidgets('Runtime caches by (name, contentHash)', (tester) async {
  // ... validate that two consecutive loads of the same bytes resolve to
  // the identical IrTree instance.
});
```

- [ ] **Step 2: Implement `Future<IrTree> load(String name)` on Runtime**

```dart
import 'package:crypto/crypto.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';

extension RuntimeLoad on Runtime {
  Future<IrTree> load(String name) async {
    final cached = _cache['$name'];
    // Try fetcher
    if (fetcher != null) {
      try {
        final bytes = await fetcher!.fetch(name);
        return _decodeAndCache(name, bytes);
      } catch (_) { /* fall through */ }
    }
    if (assetBundle != null) {
      try {
        final fetcher = AssetBundleIrFetcher(bundle: assetBundle!);
        final bytes = await fetcher.fetch(name);
        return _decodeAndCache(name, bytes);
      } catch (_) { /* fall through */ }
    }
    final binding = screenFor(name);
    if (binding != null) return binding.ir;
    throw StateError('No source produced IR for "$name"');
  }

  IrTree _decodeAndCache(String name, List<int> bytes) {
    final hash = sha1.convert(bytes).toString();
    final key = '$name:$hash';
    final hit = _cache[key];
    if (hit != null) return hit;
    final tree = JsonIrCodec.decodeBytes(bytes);
    _cache[key] = tree;
    if (tree.version > IrCodec.currentIrVersion) {
      throw StateError('IR version ${tree.version} exceeds runtime');
    }
    return tree;
  }
}
```

(Add `_cache` field to Runtime: `final Map<String, IrTree> _cache = {};`. Add `JsonIrCodec.decodeBytes(List<int>)` helper to the annotation package if not present.)

- [ ] **Step 3: Run — expect PASS**

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui/lib/src/runtime.dart packages/desk_sdui/test/runtime_test.dart
git commit -m "feat(desk_sdui): Runtime.load with fetcher chain + contentHash cache"
```

---

## Task 10: `SduiScreen` widget

**Files:**
- Create: `packages/desk_sdui/lib/src/sdui_screen.dart`
- Test: `packages/desk_sdui/test/sdui_screen_test.dart`

- [ ] **Step 1: Write integration test**

```dart
testWidgets('SduiScreen mounts, loads, and resolves a registered screen',
    (tester) async {
  final rt = Runtime();
  registerBuiltinWidgets(rt);
  rt.registerScreen(ScreenBinding(
    name: 'hello',
    ir: IrTree(name: 'hello', version: 1, root: WidgetNode(
      name: 'Text',
      args: {'data': const LiteralNode('hello world')},
    )),
    inputs: const [],
  ));
  await tester.pumpWidget(MaterialApp(
    home: SduiScreen(name: 'hello', runtime: rt),
  ));
  // First frame: loadingBuilder. Then resolves.
  await tester.pumpAndSettle();
  expect(find.text('hello world'), findsOneWidget);
});
```

- [ ] **Step 2: Implement**

```dart
// lib/src/sdui_screen.dart
import 'package:flutter/widgets.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'resolve.dart';
import 'runtime.dart';

class SduiScreen extends StatefulWidget {
  const SduiScreen({
    super.key,
    required this.name,
    required this.runtime,
    this.inputs = const {},
  });

  final String name;
  final Runtime runtime;
  final Map<String, Object?> inputs;

  @override
  State<SduiScreen> createState() => _SduiScreenState();
}

class _SduiScreenState extends State<SduiScreen> {
  late Future<IrTree> _ir;

  @override
  void initState() {
    super.initState();
    _ir = widget.runtime.load(widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<IrTree>(
      future: _ir,
      builder: (ctx, snap) {
        if (snap.hasError) {
          return widget.runtime.errorBuilder?.call(ctx, snap.error!) ??
              ErrorWidget(snap.error!);
        }
        if (!snap.hasData) {
          return widget.runtime.loadingBuilder?.call(ctx) ??
              const SizedBox.shrink();
        }
        final binding = widget.runtime.screenFor(widget.name);
        final input = _composeInput(binding, widget.inputs);
        return resolveNode(ctx, snap.data!.root, input, widget.runtime);
      },
    );
  }

  Map<String, Object?> _composeInput(
    ScreenBinding? binding,
    Map<String, Object?> userInputs,
  ) {
    final input = <String, Object?>{...userInputs};
    if (binding != null) {
      // Build __methods__ map from binding.methods
      final methods = <String, Function>{};
      for (final m in binding.methods) {
        methods[m.name] = m.invoke;
      }
      input['__methods__'] = methods;
      // Build __reactive__ map from binding.reactives
      final reactives = <String, Listenable>{};
      for (final r in binding.reactives) {
        reactives[r.path.join('.')] = r.read(userInputs);
      }
      input['__reactive__'] = reactives;
    }
    return input;
  }
}
```

- [ ] **Step 3: Run — expect PASS**

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui/lib/src/sdui_screen.dart packages/desk_sdui/test/sdui_screen_test.dart
git commit -m "feat(desk_sdui): SduiScreen widget with FutureBuilder + binding compose"
```

---

## Task 11: Public API export pass

**Files:**
- Modify: `packages/desk_sdui/lib/desk_sdui.dart`

- [ ] **Step 1: Export everything users need**

```dart
library desk_sdui;

export 'package:desk_sdui_annotation/desk_sdui_annotation.dart';

export 'src/runtime.dart';
export 'src/sdui_screen.dart';
export 'src/builtins/builtin_widgets.dart' show registerBuiltinWidgets;
export 'src/loader/ir_fetcher.dart';
export 'src/loader/asset_bundle_ir_fetcher.dart';
export 'src/loader/remote_ir_fetcher.dart';
```

Internal modules (`resolve.dart`, `expression_eval.dart`, `ref_resolver.dart`, `reactive.dart`) stay unexported.

- [ ] **Step 2: Run full test suite**

```bash
cd packages/desk_sdui && flutter test
```

Expected: all tests PASS.

- [ ] **Step 3: Commit**

```bash
git add packages/desk_sdui/lib/desk_sdui.dart
git commit -m "chore(desk_sdui): finalize public API exports"
```

---

## Task 12: Final verification

- [ ] **Step 1: Run from repo root**

```bash
melos exec --scope="desk_sdui" -- flutter analyze
melos exec --scope="desk_sdui" -- flutter test
```

Expected: zero analyzer issues, all tests PASS.

- [ ] **Step 2: Manual smoke**

Build a tiny app inside `packages/desk_sdui/example/` (or a top-level `example/`) that registers a builtin, defines an inline `ScreenBinding`, and renders an `SduiScreen`. Confirm visually.

- [ ] **Step 3: Tag**

```bash
git tag desk_sdui-phase2-complete
```

## Phase 2 Done When

- [ ] `Runtime`, `ScreenBinding`, `InputBinding`, `MethodBinding`, `ReactiveBinding` defined and tested
- [ ] `RefResolver` walks pre-split paths through nested map/list/getter shims
- [ ] `evalExpression` dispatches on every `ExpressionNode` subtype with sealed switch
- [ ] `resolveNode` handles `WidgetNode`, `ConditionalNode`, `ForNode` (both shapes), `ListNode`, `SpreadNode`, `MapNode`, `EventNode`
- [ ] `ReactiveScopeNode` rebuilds only its subtree on listenable change
- [ ] Builtin widget registry covers ~25 layout primitives
- [ ] `AssetBundleIrFetcher` and `RemoteIrFetcher` decode bytes through `JsonIrCodec`
- [ ] `Runtime.load` resolves through fetcher → asset → in-binary fallback with contentHash cache
- [ ] `SduiScreen` mounts, loads, resolves
- [ ] All tests pass; analyzer clean
