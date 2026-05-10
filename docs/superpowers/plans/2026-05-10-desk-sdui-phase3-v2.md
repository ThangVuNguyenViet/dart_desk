# desk_sdui Phase 3 v2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax for tracking. Each task dispatches a fresh Sonnet subagent.

**Goal:** Replace hand-written `builtin_widgets.dart` with codegen-driven auto-registration. Each `@Screen` codegens its own dependency-registration callback; the registry is the union across all screens.

**Architecture (dart_mappable-shaped):**

- For each `@Screen` source file, codegen produces two outputs alongside it: `<file>.sdui.g.dart` (binding + per-screen `register<Screen>Types(rt)` function) and `<file>.sdui.json` (wire payload). This is analogous to dart_mappable's `.mapper.dart` per source file.
- The setup generator writes a single `desk_sdui_setup.g.dart` that imports every per-screen `register<Screen>Types` and calls them all from `registerAllScreens(rt)`. This is analogous to dart_mappable's `.init.dart`.
- **Key invariant:** registrations are generated from the **type's analyzer element** (full constructor signature, full method signature), NOT from any single call site. So if chef and cart both use `Column`, both files emit the same `rt.registerWidget('Column', ...)` closure — bytewise identical. The setup calls both; last-writer-wins is safe because the writers are interchangeable. No merge logic needed; no duplicate-registration bug.
- Generation from the type definition means each registration covers the type's full surface (e.g. `Column`'s ~9 ctor params), so any payload using any subset works. Slightly larger code per registration; correctness by construction.

**Spec:** `docs/superpowers/specs/2026-05-10-desk-sdui-phase3-v2-design.md`

**Tech Stack:** Dart 3.7, analyzer 6.x, build_runner, source_gen, Flutter SDK widgets.

**Repo:** `/Users/vietthangvunguyen/Workspace/dart_desk_workspace/desk_sdui`

---

## File Structure

**Modified:**
- `packages/desk_sdui/lib/src/runtime.dart` — add `registerWidget` / `registerConstant` / `registerMethod` / `registerSubscript` / `registerValueBuilder` / `registerFunction`
- `packages/desk_sdui_annotation/lib/src/ir/ir_node.dart` — add `MethodCallNode`, `ValueCtorNode`
- `packages/desk_sdui_annotation/lib/src/ir/codec/json_encoder.dart` + `json_decoder.dart` — encode/decode new nodes
- `packages/desk_sdui_annotation/lib/src/ir/codec/dart_emitter.dart` (or equivalent) — Dart literal emit for new nodes
- `packages/desk_sdui_generator/lib/src/screen_lowering/widget_lowerer.dart` — emit registration entries instead of looking up builtins
- `packages/desk_sdui_generator/lib/src/screen_lowering/expression_lowerer.dart` — same, for method/constant/subscript refs
- `packages/desk_sdui_generator/lib/src/screen_lowering/screen_generator.dart` — emit `register<Screen>Dependencies` alongside binding
- `packages/desk_sdui_generator/lib/src/registry/registry_generator.dart` — union per-screen registration calls
- `packages/desk_sdui/lib/src/resolve.dart` — replace builtin lookups with registry lookups for new node kinds

**Created:**
- `packages/desk_sdui_annotation/lib/src/annotations.dart` — add `@RegisterForSdui` (extend existing file)
- `packages/desk_sdui_generator/lib/src/symbol_collector.dart` — analyzer pass classifying external refs
- `packages/desk_sdui_generator/lib/src/registration_emitter.dart` — turn classified symbols into registration code
- `packages/desk_sdui_generator/lib/src/lints/no_side_effects_in_screen.dart` — denylist analyzer rule

**Deleted:**
- `packages/desk_sdui/lib/src/builtins/builtin_widgets.dart`
- `packages/desk_sdui/test/builtins/builtin_widgets_test.dart` (if exists)

---

## Task 1: Add `Runtime` registration methods

**Files:**
- Modify: `packages/desk_sdui/lib/src/runtime.dart`
- Test: `packages/desk_sdui/test/runtime_registration_test.dart`

- [ ] **Step 1: Write failing test for `registerWidget` + lookup**

```dart
// test/runtime_registration_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desk_sdui/desk_sdui.dart';

void main() {
  test('registerWidget then resolveWidget returns the builder', () {
    final rt = Runtime();
    rt.registerWidget('Padding', (a) => Padding(
      padding: a['padding'] as EdgeInsetsGeometry,
      child: a['child'] as Widget?,
    ));
    final builder = rt.resolveWidget('Padding');
    expect(builder, isNotNull);
    final widget = builder!({'padding': const EdgeInsets.all(8), 'child': null});
    expect(widget, isA<Padding>());
    expect((widget as Padding).padding, const EdgeInsets.all(8));
  });

  test('registerConstant then resolveConstant returns the value', () {
    final rt = Runtime();
    rt.registerConstant('CrossAxisAlignment.start', CrossAxisAlignment.start);
    expect(rt.resolveConstant('CrossAxisAlignment.start'), CrossAxisAlignment.start);
  });

  test('registerMethod then invokeMethod runs the handler', () {
    final rt = Runtime();
    rt.registerMethod('String.toUpperCase', (recv, _) => (recv as String).toUpperCase());
    expect(rt.invokeMethod('String.toUpperCase', 'hello', const []), 'HELLO');
  });

  test('registerSubscript then invokeSubscript runs the handler', () {
    final rt = Runtime();
    rt.registerSubscript('Map.[]', (recv, key) => (recv as Map)[key]);
    expect(rt.invokeSubscript('Map.[]', {'a': 1, 'b': 2}, 'a'), 1);
  });

  test('registerValueBuilder then invokeValueBuilder runs the builder', () {
    final rt = Runtime();
    rt.registerValueBuilder('EdgeInsets.all', (a) => EdgeInsets.all(a[0] as double));
    final result = rt.invokeValueBuilder('EdgeInsets.all', const [8.0]);
    expect(result, const EdgeInsets.all(8.0));
  });

  test('resolveWidget returns null for unregistered name', () {
    final rt = Runtime();
    expect(rt.resolveWidget('NeverRegistered'), isNull);
  });
}
```

- [ ] **Step 2: Run — expect FAIL** (`Runtime` lacks the new methods).

```bash
cd packages/desk_sdui && dart test test/runtime_registration_test.dart
```

- [ ] **Step 3: Add the methods to `runtime.dart`**

Add to `class Runtime`:

```dart
typedef SduiWidgetBuilder = Widget Function(Map<String, Object?> args);
typedef SduiMethodHandler = Object? Function(Object? receiver, List<Object?> args);
typedef SduiSubscriptHandler = Object? Function(Object? receiver, Object? key);
typedef SduiValueBuilder = Object? Function(List<Object?> args);
typedef SduiFunctionHandler = Object? Function(List<Object?> args);

class Runtime {
  // existing fields...
  final Map<String, SduiWidgetBuilder> _widgets = {};
  final Map<String, Object?> _constants = {};
  final Map<String, SduiMethodHandler> _methods = {};
  final Map<String, SduiSubscriptHandler> _subscripts = {};
  final Map<String, SduiValueBuilder> _valueBuilders = {};
  final Map<String, SduiFunctionHandler> _functions = {};

  void registerWidget(String name, SduiWidgetBuilder builder) => _widgets[name] = builder;
  void registerConstant(String name, Object? value) => _constants[name] = value;
  void registerMethod(String name, SduiMethodHandler handler) => _methods[name] = handler;
  void registerSubscript(String name, SduiSubscriptHandler handler) => _subscripts[name] = handler;
  void registerValueBuilder(String name, SduiValueBuilder builder) => _valueBuilders[name] = builder;
  void registerFunction(String name, SduiFunctionHandler handler) => _functions[name] = handler;

  SduiWidgetBuilder? resolveWidget(String name) => _widgets[name];
  Object? resolveConstant(String name) => _constants[name];
  Object? invokeMethod(String name, Object? receiver, List<Object?> args) =>
      _methods[name]?.call(receiver, args);
  Object? invokeSubscript(String name, Object? receiver, Object? key) =>
      _subscripts[name]?.call(receiver, key);
  Object? invokeValueBuilder(String name, List<Object?> args) =>
      _valueBuilders[name]?.call(args);
  Object? invokeFunction(String name, List<Object?> args) =>
      _functions[name]?.call(args);
}
```

(Place at the existing `Runtime` class file; export typedefs from the package barrel.)

- [ ] **Step 4: Run — expect PASS**

```bash
cd packages/desk_sdui && dart test test/runtime_registration_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui/lib/src/runtime.dart packages/desk_sdui/test/runtime_registration_test.dart
git commit -m "feat(desk_sdui): Runtime register*/resolve* API for codegen-driven registry"
```

---

## Task 2: Add `MethodCallNode` and `ValueCtorNode` to IR

**Files:**
- Modify: `packages/desk_sdui_annotation/lib/src/ir/ir_node.dart`
- Modify: `packages/desk_sdui_annotation/lib/src/ir/codec/json_encoder.dart`
- Modify: `packages/desk_sdui_annotation/lib/src/ir/codec/json_decoder.dart`
- Test: `packages/desk_sdui_annotation/test/ir_node_test.dart` (extend existing or create)

- [ ] **Step 1: Failing test — round-trip MethodCallNode**

```dart
// add to existing ir_node_test.dart
test('MethodCallNode round-trips through JSON codec', () {
  final node = MethodCallNode(
    receiver: RefNode(path: 'data.title'),
    name: 'String.toUpperCase',
    args: const [],
  );
  final encoded = JsonIrCodec.encode(node);
  final decoded = JsonIrCodec.decode(encoded);
  expect(decoded, isA<MethodCallNode>());
  expect((decoded as MethodCallNode).name, 'String.toUpperCase');
  expect(decoded.receiver, isA<RefNode>());
});

test('ValueCtorNode round-trips through JSON codec', () {
  final node = ValueCtorNode(
    name: 'EdgeInsets.all',
    args: [LiteralNode(value: 8.0)],
  );
  final encoded = JsonIrCodec.encode(node);
  final decoded = JsonIrCodec.decode(encoded);
  expect(decoded, isA<ValueCtorNode>());
  expect((decoded as ValueCtorNode).name, 'EdgeInsets.all');
  expect(decoded.args, hasLength(1));
});
```

- [ ] **Step 2: Run — FAIL** (nodes don't exist).

```bash
cd packages/desk_sdui_annotation && dart test test/ir_node_test.dart
```

- [ ] **Step 3: Define `MethodCallNode` and `ValueCtorNode` in `ir_node.dart`**

```dart
/// Method invocation: `receiver.name(args)`. Resolved at runtime via
/// Runtime.invokeMethod(name, receiver, args).
final class MethodCallNode extends IrNode {
  const MethodCallNode({
    required this.receiver,
    required this.name,
    required this.args,
  });

  final IrNode receiver;
  /// Receiver-type-keyed handler name, e.g. `'String.toUpperCase'`.
  final String name;
  final List<IrNode> args;
}

/// Value-type constructor invocation: `name(args)`. Resolved at runtime via
/// Runtime.invokeValueBuilder(name, args). Used for non-Widget value classes
/// like EdgeInsets, BoxDecoration, Color when not const-folded.
final class ValueCtorNode extends IrNode {
  const ValueCtorNode({
    required this.name,
    required this.args,
  });

  /// Qualified constructor name, e.g. `'EdgeInsets.all'`, `'BoxDecoration'`.
  final String name;
  final List<IrNode> args;
}
```

- [ ] **Step 4: Encode/decode in JSON codec**

In `json_encoder.dart`, add cases for `MethodCallNode` (type `'MethodCall'`) and `ValueCtorNode` (type `'ValueCtor'`):

```dart
case MethodCallNode():
  return {
    'type': 'MethodCall',
    'receiver': encode(node.receiver),
    'name': node.name,
    'args': node.args.map(encode).toList(),
  };
case ValueCtorNode():
  return {
    'type': 'ValueCtor',
    'name': node.name,
    'args': node.args.map(encode).toList(),
  };
```

In `json_decoder.dart`, mirror:

```dart
case 'MethodCall':
  return MethodCallNode(
    receiver: decode(json['receiver']),
    name: json['name'] as String,
    args: (json['args'] as List).map(decode).toList(),
  );
case 'ValueCtor':
  return ValueCtorNode(
    name: json['name'] as String,
    args: (json['args'] as List).map(decode).toList(),
  );
```

- [ ] **Step 5: Run — PASS**

```bash
cd packages/desk_sdui_annotation && dart test test/ir_node_test.dart
```

- [ ] **Step 6: Commit**

```bash
git add packages/desk_sdui_annotation/lib/src/ir/ir_node.dart packages/desk_sdui_annotation/lib/src/ir/codec packages/desk_sdui_annotation/test/ir_node_test.dart
git commit -m "feat(desk_sdui_annotation): add MethodCallNode and ValueCtorNode to IR"
```

---

## Task 3: Update runtime resolver for new IR nodes

**Files:**
- Modify: `packages/desk_sdui/lib/src/resolve.dart`
- Test: `packages/desk_sdui/test/resolve_method_call_test.dart`

- [ ] **Step 1: Failing test**

```dart
// test/resolve_method_call_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:desk_sdui/desk_sdui.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';

void main() {
  test('MethodCallNode resolves via Runtime.invokeMethod', () {
    final rt = Runtime();
    rt.registerMethod('String.toUpperCase', (recv, _) => (recv as String).toUpperCase());
    final node = MethodCallNode(
      receiver: LiteralNode(value: 'hello'),
      name: 'String.toUpperCase',
      args: const [],
    );
    final result = resolve(node, rt, const {});
    expect(result, 'HELLO');
  });

  test('ValueCtorNode resolves via Runtime.invokeValueBuilder', () {
    final rt = Runtime();
    rt.registerValueBuilder('EdgeInsets.all', (a) => EdgeInsets.all(a[0] as double));
    final node = ValueCtorNode(
      name: 'EdgeInsets.all',
      args: [LiteralNode(value: 8.0)],
    );
    final result = resolve(node, rt, const {});
    expect(result, const EdgeInsets.all(8.0));
  });

  test('WidgetNode resolves via Runtime.resolveWidget (regression)', () {
    final rt = Runtime();
    rt.registerWidget('Padding', (a) => Padding(
      padding: a['padding'] as EdgeInsetsGeometry,
      child: a['child'] as Widget?,
    ));
    final node = WidgetNode(
      name: 'Padding',
      args: {
        'padding': ValueCtorNode(name: 'EdgeInsets.all', args: [LiteralNode(value: 8.0)]),
        'child': LiteralNode(value: null),
      },
    );
    rt.registerValueBuilder('EdgeInsets.all', (a) => EdgeInsets.all(a[0] as double));
    final result = resolve(node, rt, const {});
    expect(result, isA<Padding>());
  });
}
```

- [ ] **Step 2: Run — FAIL.**

- [ ] **Step 3: Extend `resolve.dart` to dispatch new nodes**

Find the existing switch over `IrNode` kinds; add cases for `MethodCallNode` and `ValueCtorNode`. For `WidgetNode`, change the lookup from `builtinWidgets[node.name]` to `runtime.resolveWidget(node.name)`. Throw a clear error if not found:

```dart
case MethodCallNode():
  final receiver = resolve(node.receiver, rt, scope);
  final args = node.args.map((a) => resolve(a, rt, scope)).toList();
  final handler = rt.resolveMethodHandler(node.name); // or peek into map
  if (handler == null) {
    throw StateError('Method "${node.name}" not registered. '
        'Add it to a @Screen body or @RegisterForSdui annotation.');
  }
  return handler(receiver, args);
case ValueCtorNode():
  final args = node.args.map((a) => resolve(a, rt, scope)).toList();
  final builder = rt.resolveValueBuilder(node.name);
  if (builder == null) {
    throw StateError('Value constructor "${node.name}" not registered.');
  }
  return builder(args);
```

(Add `resolveMethodHandler` and `resolveValueBuilder` getters on Runtime if invokeX-style isn't enough; or just use `_methods[name]` directly via a helper. Keep public API minimal — internal access via `package:desk_sdui/src/...` is fine.)

- [ ] **Step 4: Run — PASS**

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui/lib/src/resolve.dart packages/desk_sdui/test/resolve_method_call_test.dart
git commit -m "feat(desk_sdui): resolver dispatches MethodCallNode and ValueCtorNode"
```

---

## Task 4: Type collector — collect deduped TYPES referenced across all @Screens

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/type_collector.dart`
- Test: `packages/desk_sdui_generator/test/type_collector_test.dart`

The collector walks one or more `@Screen` AST bodies and outputs **deduped sets of element references** (not per-call-site usages). Multiple screens using the same widget contribute one entry total.

**Rationale for type-keyed (vs usage-keyed) collection:** if chef uses `Column(children:, crossAxisAlignment:)` and cart uses `Column(children:, mainAxisAlignment:)`, a usage-keyed approach would emit two `registerWidget('Column', ...)` calls — the second overwrites the first and silently drops `crossAxisAlignment` from chef's payload at runtime. Type-keyed collection emits ONE Column registration generated from `Column`'s ctor (covering all params), so any payload using any subset works.

- [ ] **Step 1: Define the data model**

```dart
// type_collector.dart
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

class CollectedTypes {
  CollectedTypes({
    Set<ClassElement>? widgets,
    Set<ClassElement>? valueTypes,
    Set<Element>? constants,        // FieldElement or PropertyAccessorElement
    Set<MethodElement>? methods,
    Set<DartType>? subscriptables,
    Set<FunctionElement>? functions,
  })  : widgets = widgets ?? {},
        valueTypes = valueTypes ?? {},
        constants = constants ?? {},
        methods = methods ?? {},
        subscriptables = subscriptables ?? {},
        functions = functions ?? {};

  final Set<ClassElement> widgets;       // {Column, Padding, Text, ...}
  final Set<ClassElement> valueTypes;    // {EdgeInsets, BoxDecoration, ...}
  final Set<Element> constants;          // {Icons.menu, Colors.white, ...} — element identity dedupes
  final Set<MethodElement> methods;      // {String.toUpperCase, num.toStringAsFixed, ...}
  final Set<DartType> subscriptables;    // {MaterialColor, Map<K,V>, List<E>, ...}
  final Set<FunctionElement> functions;  // {min, max, ...} — top-level fns

  void unionWith(CollectedTypes other) {
    widgets.addAll(other.widgets);
    valueTypes.addAll(other.valueTypes);
    constants.addAll(other.constants);
    methods.addAll(other.methods);
    subscriptables.addAll(other.subscriptables);
    functions.addAll(other.functions);
  }
}

CollectedTypes collectTypes(FunctionDeclaration screen) {
  final visitor = _TypeVisitor();
  screen.accept(visitor);
  return visitor.collected;
}
```

- [ ] **Step 2: Failing test for widget collection**

```dart
// test/symbol_collector_test.dart
import 'package:test/test.dart';
import 'package:desk_sdui_generator/src/symbol_collector.dart';
// ... use analyzer's resolved AST utility (existing test infra)

void main() {
  test('collects Padding constructor', () async {
    final screen = await resolveScreen('''
      import 'package:flutter/material.dart';
      Widget build() => Padding(padding: EdgeInsets.all(8), child: Text('hi'));
    ''');
    final symbols = collectSymbols(screen);
    expect(symbols, contains(isA<CollectedWidget>()
      .having((s) => s.qualifiedName, 'name', 'Padding')));
    expect(symbols, contains(isA<CollectedWidget>()
      .having((s) => s.qualifiedName, 'name', 'Text')));
  });

  test('collects Icons.menu constant', () async {
    final screen = await resolveScreen('''
      import 'package:flutter/material.dart';
      Widget build() => Icon(Icons.menu);
    ''');
    final symbols = collectSymbols(screen);
    expect(symbols, contains(isA<CollectedConstant>()
      .having((s) => s.qualifiedName, 'name', 'Icons.menu')));
  });

  test('collects String.toUpperCase method', () async {
    final screen = await resolveScreen('''
      import 'package:flutter/material.dart';
      Widget build(String name) => Text(name.toUpperCase());
    ''');
    final symbols = collectSymbols(screen);
    expect(symbols, contains(isA<CollectedMethod>()
      .having((s) => s.qualifiedName, 'name', 'String.toUpperCase')));
  });

  test('collects EdgeInsets.all value constructor', () async {
    final screen = await resolveScreen('''
      import 'package:flutter/material.dart';
      Widget build() => Padding(padding: EdgeInsets.all(8), child: SizedBox());
    ''');
    final symbols = collectSymbols(screen);
    expect(symbols, contains(isA<CollectedValueCtor>()
      .having((s) => s.qualifiedName, 'name', 'EdgeInsets.all')));
  });

  test('collects subscript Colors.grey[300]', () async {
    final screen = await resolveScreen('''
      import 'package:flutter/material.dart';
      Widget build() => Container(color: Colors.grey[300]);
    ''');
    final symbols = collectSymbols(screen);
    expect(symbols, contains(isA<CollectedSubscript>()));
  });
}

// Helper resolveScreen uses analyzer to produce a resolved FunctionDeclaration.
```

(The `resolveScreen` helper is the standard `package:analyzer/dart/analysis/utilities.dart` flow; existing generator tests use this — copy that pattern.)

- [ ] **Step 3: Run — FAIL.**

- [ ] **Step 4: Implement `_SymbolVisitor` extending `RecursiveAstVisitor<void>`**

Visit:
- `InstanceCreationExpression` → classify by element supertype: `Widget` → `CollectedWidget`, otherwise `CollectedValueCtor`
- `MethodInvocation` → resolve the static method element; if receiver type is non-null and method is registered against the receiver type → `CollectedMethod`
- `PropertyAccess` / `PrefixedIdentifier` (when target is a class, e.g. `Icons.menu`) → `CollectedConstant`
- `IndexExpression` → `CollectedSubscript`
- `FunctionExpressionInvocation` (top-level) → `CollectedFunction`

Each visitor branch builds the qualified name from `element.enclosingElement.name` + '.' + `element.name`. For widgets where the constructor is unnamed, the qualified name is just the class name (e.g. `Padding`).

Edge cases:
- Skip references to `@Screen`'s own parameters (those are not external).
- Skip references to other locals introduced by `for`/lambdas.
- Skip references to `controller.someMethod` if the controller is a parameter (those are bindings, not external Flutter calls).

- [ ] **Step 5: Run tests — PASS**

- [ ] **Step 6: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/symbol_collector.dart packages/desk_sdui_generator/test/symbol_collector_test.dart
git commit -m "feat(desk_sdui_generator): symbol collector classifies external refs in @Screen body"
```

---

## Task 5: Registration emitter — generate from type definitions

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/registration_emitter.dart`
- Test: `packages/desk_sdui_generator/test/registration_emitter_test.dart`

**CRITICAL invariant:** registrations are generated from the **type's analyzer element** (its full constructor signature, full method signature), NOT from the specific call shape at the usage site. This means:

- `Column` registration covers ALL named/positional params Column's ctor accepts (~9 params), with each param's default value filled in from `parameter.defaultValueCode` when available, and nullable types where the parameter is optional with no default.
- `String.toUpperCase` registration covers the full method signature (zero args, returns String).
- The same `Column` referenced from chef.dart and cart.dart produces bytewise-identical registration closures, so multiple registrations are idempotent (last-writer-wins is safe because writers are interchangeable).

Use `parameter.defaultValueCode` from the analyzer to emit defaults. For required params, no default. For positional params, generate `args[0]`-style indexing. For named params, generate `args['name']`-style lookup with default.

- [ ] **Step 1: Failing test**

```dart
// test/registration_emitter_test.dart
test('emitWidgetRegistration produces a registerWidget call', () {
  final symbol = CollectedWidget('Padding', mockConstructorElement('Padding',
    namedParams: ['padding', 'child']));
  final code = RegistrationEmitter().emitWidget(symbol);
  expect(code, contains("rt.registerWidget('Padding'"));
  expect(code, contains("padding: a['padding'] as EdgeInsetsGeometry"));
  expect(code, contains("child: a['child'] as Widget?"));
});

test('emitConstantRegistration produces a registerConstant call', () {
  final symbol = CollectedConstant('Icons.menu', mockFieldElement('Icons.menu'));
  final code = RegistrationEmitter().emitConstant(symbol);
  expect(code, contains("rt.registerConstant('Icons.menu', Icons.menu)"));
});

test('emitMethodRegistration produces a registerMethod call', () {
  final symbol = CollectedMethod('String.toUpperCase',
      mockMethodElement('toUpperCase', returns: 'String'),
      mockType('String'));
  final code = RegistrationEmitter().emitMethod(symbol);
  expect(code, contains("rt.registerMethod('String.toUpperCase'"));
  expect(code, contains("(recv, args) => (recv as String).toUpperCase()"));
});

test('emitValueCtorRegistration produces a registerValueBuilder call', () {
  final symbol = CollectedValueCtor('EdgeInsets.all',
      mockConstructorElement('EdgeInsets.all', positional: ['double']));
  final code = RegistrationEmitter().emitValueBuilder(symbol);
  expect(code, contains("rt.registerValueBuilder('EdgeInsets.all'"));
  expect(code, contains("(args) => EdgeInsets.all(args[0] as double)"));
});
```

- [ ] **Step 2: Run — FAIL.**

- [ ] **Step 3: Implement `RegistrationEmitter`** with one method per symbol kind. Each method takes a `CollectedX` and returns a `String` of Dart code.

Implementation notes:
- For widgets: read `constructorElement.parameters` → for each, emit `paramName: a['paramName'] as ParamType`. For required params, no `?`; for optional, `as ParamType?`.
- For constants: directly emit the static reference; the type is the field's static type (no cast needed).
- For methods: emit `(recv, args) => (recv as ReceiverType).methodName(args[0] as ArgType, ...)`. Method args are positional.
- For subscripts: emit `(recv, key) => (recv as ReceiverType)[key as KeyType]`.
- For value ctors: emit `(args) => CtorName(args[0] as ArgType, ...)` for unnamed ctor, or with named-arg map for named.

Use `code_builder` package or raw string templates — raw strings are fine for this scope.

- [ ] **Step 4: Run tests — PASS**

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/registration_emitter.dart packages/desk_sdui_generator/test/registration_emitter_test.dart
git commit -m "feat(desk_sdui_generator): registration emitter produces Dart code per symbol kind"
```

---

## Task 6: Wire collector + emitter into screen_generator

**Files:**
- Modify: `packages/desk_sdui_generator/lib/src/screen_lowering/screen_generator.dart`

- [ ] **Step 1: Failing integration test — chef regenerates with `registerChefDependencies`**

Use the existing chef.dart fixture in `desk_sdui_demo`. Run `dart run build_runner build` and assert that the produced `chef.sdui.g.dart` contains:

```dart
void registerChefDependencies(Runtime rt) {
  rt.registerWidget('Padding', ...);
  rt.registerWidget('Column', ...);
  // ... etc
}
```

- [ ] **Step 2: In `screen_generator.dart`, after the existing `_chefIr` and `chefBinding` emit, run the symbol collector against the `@Screen` body and the emitter against each collected symbol. Emit:**

```dart
buffer.writeln('void register${_capitalize(screenName)}Dependencies(Runtime rt) {');
for (final symbol in symbols) {
  buffer.writeln('  ' + emitter.emit(symbol));
}
buffer.writeln('}');
```

- [ ] **Step 3: Run codegen against chef.dart, inspect output**

```bash
cd packages/desk_sdui_demo && dart run build_runner build --delete-conflicting-outputs
cat lib/screens/chef.sdui.g.dart | head -80
```

- [ ] **Step 4: Update integration test, expect PASS**

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/screen_lowering/screen_generator.dart packages/desk_sdui_generator/test/screen_generator_test.dart packages/desk_sdui_demo/lib/screens/chef.sdui.g.dart
git commit -m "feat(desk_sdui_generator): emit per-screen registerXDependencies fn"
```

---

## Task 7: Setup file unions per-screen registrations (dart_mappable .init.dart pattern)

**Files:**
- Modify: `packages/desk_sdui_generator/lib/src/registry/registry_generator.dart`

This is the equivalent of dart_mappable's `.init.dart` builder: scan the package for `@Screen`-annotated source files, import each one's `<screen>.sdui.g.dart`, and emit a single `registerAllScreens(rt)` that calls every per-screen `register<Screen>Types(rt)`. Idempotent registration (Task 5 invariant) means overlap is safe.

- [ ] **Step 1: Failing test — `registerAllScreens` calls every per-screen register fn**

Build the demo package, inspect `desk_sdui_setup.g.dart`. Expected:

```dart
void registerAllScreens(Runtime rt) {
  rt.registerScreen(chefBinding);
  registerChefDependencies(rt);
}
```

(Plus any other screens as they're added.)

- [ ] **Step 2: In `registry_generator.dart`, after each `rt.registerScreen(...)` emit, also emit `register<Screen>Dependencies(rt);`**

- [ ] **Step 3: Run codegen, verify output**

- [ ] **Step 4: Run demo tests** — chef should still resolve. The runtime is now bootstrapped entirely from auto-generated registrations; no `builtin_widgets.dart` initialization.

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/registry/registry_generator.dart packages/desk_sdui_demo/lib/desk_sdui_setup.g.dart
git commit -m "feat(desk_sdui_generator): registry unions per-screen registrations"
```

---

## Task 8: Delete `builtin_widgets.dart`

**Files:**
- Delete: `packages/desk_sdui/lib/src/builtins/builtin_widgets.dart`
- Delete: `packages/desk_sdui/test/builtins/builtin_widgets_test.dart` (if exists)
- Modify: `packages/desk_sdui/lib/desk_sdui.dart` — remove the export
- Modify: any internal references to `builtinWidgets` map

- [ ] **Step 1: Identify references**

```bash
cd packages/desk_sdui && grep -rn "builtin_widgets\|builtinWidgets" --include='*.dart' .
```

- [ ] **Step 2: For each reference, replace with `runtime.resolveWidget(name)` or remove if unused.**

- [ ] **Step 3: Delete the file + its test (if present)**

```bash
git rm packages/desk_sdui/lib/src/builtins/builtin_widgets.dart
# repeat for tests if any
```

- [ ] **Step 4: `dart analyze` and `dart test` for desk_sdui — must be clean.**

- [ ] **Step 5: Run demo tests — chef must still render correctly.**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "refactor(desk_sdui): delete builtin_widgets.dart in favor of codegen-driven registry"
```

---

## Task 9: Add `@RegisterForSdui` annotation

**Files:**
- Modify: `packages/desk_sdui_annotation/lib/src/annotations.dart`
- Modify: `packages/desk_sdui_generator/lib/src/symbol_collector.dart` (handle annotation classes)
- Modify: `packages/desk_sdui_generator/lib/src/registry/registry_generator.dart` (process @RegisterForSdui-annotated classes)
- Test: `packages/desk_sdui_generator/test/register_for_sdui_test.dart`

- [ ] **Step 1: Define the annotation**

```dart
// annotations.dart
class RegisterForSdui {
  const RegisterForSdui(this.types);
  /// List of Type literals to register for SDUI use even if no @Screen
  /// references them. Use to pre-register widgets that only network-delivered
  /// payloads will reference.
  final List<Type> types;
}
```

- [ ] **Step 2: Failing test**

```dart
test('@RegisterForSdui([PageView]) emits a registerWidget for PageView in setup.g.dart', () async {
  // Build fixture with `@RegisterForSdui([PageView]) class _SduiCoverage {}`
  // Run codegen
  // Expect setup.g.dart to contain `rt.registerWidget('PageView', ...)`
});
```

- [ ] **Step 3: In symbol_collector, add a path that takes a `ClassElement` annotated with `@RegisterForSdui` and yields `CollectedWidget` (or other kinds based on the type) for each entry.**

- [ ] **Step 4: In registry_generator, before emitting `registerAllScreens`, find all classes in the package with `@RegisterForSdui`, collect their types, run them through registration_emitter, and emit the registrations into setup.g.dart.**

- [ ] **Step 5: Run tests, PASS.**

- [ ] **Step 6: Commit**

```bash
git add packages/desk_sdui_annotation packages/desk_sdui_generator/lib/src/symbol_collector.dart packages/desk_sdui_generator/lib/src/registry packages/desk_sdui_generator/test/register_for_sdui_test.dart
git commit -m "feat(desk_sdui): @RegisterForSdui annotation for network-only widget registration"
```

---

## Task 10: Denylist analyzer rule — `sdui_no_side_effects_in_screen`

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/lints/no_side_effects_in_screen.dart`
- Modify: `packages/desk_sdui_generator/lib/src/lints/plugin.dart` (or wherever lint rules are registered)
- Test: `packages/desk_sdui_generator/test/lints/no_side_effects_in_screen_test.dart`

- [ ] **Step 1: Failing test**

```dart
test('lint fires on dart:io reference in @Screen', () async {
  final source = '''
    import 'dart:io';
    import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
    @Screen('test')
    Widget buildTest() {
      File('/tmp/foo').readAsStringSync();
      return SizedBox();
    }
  ''';
  final diagnostics = await runLint(source, 'sdui_no_side_effects_in_screen');
  expect(diagnostics, isNotEmpty);
  expect(diagnostics.first.message, contains('dart:io'));
});

test('lint does not fire on package:flutter references', () async {
  final source = '''
    import 'package:flutter/material.dart';
    import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
    @Screen('test')
    Widget buildTest() => Text('hi');
  ''';
  final diagnostics = await runLint(source, 'sdui_no_side_effects_in_screen');
  expect(diagnostics, isEmpty);
});
```

- [ ] **Step 2: Implement the rule** — visit identifier references inside `@Screen`-annotated function bodies; if the resolved element's library URI matches one of the denylist URIs (`dart:io`, `dart:isolate`, `dart:ffi`, `dart:mirrors`), report a diagnostic.

- [ ] **Step 3: Wire into the plugin entry point.**

- [ ] **Step 4: Run tests — PASS.**

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/lints
git commit -m "feat(desk_sdui_generator): lint sdui_no_side_effects_in_screen — block dart:io etc."
```

---

## Task 11: Network-only screen end-to-end test

**Files:**
- Create: `packages/desk_sdui_demo/test/network_only_screen_test.dart`
- Create: `packages/desk_sdui_demo/lib/sdui_coverage.dart` (with `@RegisterForSdui([PageView])`)

- [ ] **Step 1: Author `sdui_coverage.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';

@RegisterForSdui([PageView])
class SduiCoverage {}
```

- [ ] **Step 2: Codegen — verify `desk_sdui_setup.g.dart` registers PageView**

```bash
cd packages/desk_sdui_demo && dart run build_runner build --delete-conflicting-outputs
grep "PageView" lib/desk_sdui_setup.g.dart
```

- [ ] **Step 3: Author the e2e test**

```dart
// test/network_only_screen_test.dart
testWidgets('network-only @Screen using @RegisterForSdui-only widget renders', (tester) async {
  // Build a .sdui.json payload that uses PageView (not used by any @Screen)
  final payload = jsonEncode({
    'type': 'Widget',
    'name': 'PageView',
    'args': {
      'children': [
        {'type': 'Widget', 'name': 'Text', 'args': {'data': {'type': 'Literal', 'value': 'page1'}}},
        {'type': 'Widget', 'name': 'Text', 'args': {'data': {'type': 'Literal', 'value': 'page2'}}},
      ],
    },
  });
  final rt = Runtime();
  registerAllScreens(rt); // runs the auto-generated setup
  final ir = JsonIrCodec.decode(jsonDecode(payload));
  await tester.pumpWidget(MaterialApp(home: Material(
    child: Builder(builder: (ctx) => resolve(ir, rt, const {}) as Widget),
  )));
  expect(find.byType(PageView), findsOneWidget);
});
```

- [ ] **Step 4: Run — PASS demonstrates the @RegisterForSdui pre-registration mechanism works end-to-end.**

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui_demo/lib/sdui_coverage.dart packages/desk_sdui_demo/lib/desk_sdui_setup.g.dart packages/desk_sdui_demo/test/network_only_screen_test.dart
git commit -m "test(desk_sdui_demo): e2e — @RegisterForSdui enables network-only widget rendering"
```

---

## Task 12: Re-codegen chef + verify

**Files:**
- Touch: `packages/desk_sdui_demo/lib/screens/chef.sdui.g.dart` and `chef.sdui.json` (regenerated)

- [ ] **Step 1: Re-codegen**

```bash
cd packages/desk_sdui_demo && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 2: Inspect `chef.sdui.g.dart` — verify it now contains `registerChefDependencies(rt)` with the full set of widgets/constants chef uses.**

- [ ] **Step 3: Run any chef rendering test (if exists)** — must still pass.

- [ ] **Step 4: Run `dart analyze` across all three packages** — must be clean.

- [ ] **Step 5: Commit (only if regen produced changes)**

```bash
git add -A
git commit -m "chore(desk_sdui_demo): regenerate chef under v2 codegen"
```

---

## Phase 3 v2 Done When

- [ ] All 12 tasks committed.
- [ ] `desk_sdui_setup.g.dart` is fully auto-generated.
- [ ] `builtin_widgets.dart` no longer exists.
- [ ] chef renders correctly under the new registry (existing chef tests pass).
- [ ] `@RegisterForSdui([PageView])` adds PageView to the registry; the network-only screen test demonstrates rendering works.
- [ ] `sdui_no_side_effects_in_screen` lint fires on `dart:io` and is silent on `package:flutter`.
- [ ] `dart analyze` clean across `desk_sdui`, `desk_sdui_annotation`, `desk_sdui_generator`, `desk_sdui_demo`.
- [ ] `dart test` clean for all three library packages; `flutter test` clean for demo.

After Phase 3 v2, Phase 4 can be re-attempted with confidence — the fixed registry no longer constrains what screens can use; only the lowering passes do.
