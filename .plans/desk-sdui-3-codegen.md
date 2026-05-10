# desk_sdui Phase 3 — Codegen Implementation Plan

> **For agentic workers:** This plan implements `desk_sdui_generator` (build_runner codegen). Phases 1 (foundation) and 2 (runtime) must be complete and committed first. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Two `build_runner` builders that compile `@Screen`-annotated functions to a node tree and emit `<file>.sdui.g.dart` + `<file>.uib`, and discover all `@Screen`s in a package to emit `desk_sdui_setup.sdui.g.dart` with `_registerAll()`. Plus an analyzer plugin enforcing the authored-DSL subset.

**Architecture:** `screenBuilder` runs per-`.dart`, walking each `@Screen` body via `package:analyzer` AST visitors → node tree. Three lowering passes follow: const-fold, reactive-scope hoist, key inference. Emits a Dart node-tree literal + JSON wire form. `registryBuilder` runs once per package, glob-collects all `@Screen`s, emits the `_registerAll()` part file. Analyzer plugin shares the lowering rules to surface IDE errors before build.

**Tech Stack:** `analyzer ^7.0.0`, `build ^2.4.0`, `source_gen ^2.0.0`, `build_runner ^2.15.0` with `--force-aot`, no `dart:mirrors`. `code_builder` ^4.10.0 for emitting Dart literals.

**Repo:** `/Users/vietthangvunguyen/Workspace/dart_desk_workspace/desk_sdui`

---

## Phase 1+2 node-class adapter notes (READ FIRST)

Code samples in this plan that conflict with actual constructor signatures are stale — use these instead, confirmed by reading `packages/desk_sdui_annotation/lib/src/ir/ir_node.dart` and `packages/desk_sdui/lib/src/runtime.dart`.

| Node / class | Actual signature |
|---|---|
| `LiteralNode(value)` | positional |
| `ConstNode(value)` | positional |
| `RefNode(path, {reactive = false})` | path positional |
| `EventNode(target, {args = const {}})` | args is **non-nullable** Map (default empty) |
| `WidgetNode({name, args, key, listenablePaths = const {}})` | `listenablePaths: Set<String>` (paths joined with `.`) — **no separate ReactiveScopeNode exists**; the reactive-hoist pass writes into this field |
| `BuiltinWidgetNode({name, args, key})` | no listenablePaths |
| `ListNode(children)` | positional |
| `MapNode(entries)` | `Map<IrNode, IrNode>` (keys are IrNodes) |
| `RecordNode({positional, named})` | both default `const []`/`const {}` |
| `ConditionalNode({condition, thenBranch, elseBranch})` | NOT `then`/`otherwise` |
| `ForNode({variable, source, body})` / `ForNode.destructured({variables, source, body})` | `variable`/`variables`, NOT `loopVar`/`loopVars` |
| `SpreadNode(source)` | positional |
| `NotOpNode(operand)` | positional |
| `CompareOpNode` / `ArithOpNode` / `LogicOpNode` | `({op, left, right})` |
| `CoalesceOpNode({left, right})` | named |
| `MemberAccessNode({target, name})` | `name`, NOT `member` |
| `IndexAccessNode({target, key})` | `key`, NOT `index` |
| `LengthOfNode(target)` | positional |
| `IsNullCheckNode(operand)` | positional |
| `StringInterpNode(parts)` | `parts: List<Object>` **alternating `String` literals and `IrNode` slots** — NOT `List<IrNode>` |
| `ScreenBinding({name, ir, inputs, methods = const [], reactives = const []})` | `inputs: List<InputBinding<Object?>>`, `methods: List<MethodBinding>`, `reactives: List<ReactiveBinding>` |
| `InputBinding<T>({name, read})` | `read: T Function(Object? input)` |
| `MethodBinding({name, invoke})` | `invoke: Function` |
| `ReactiveBinding({path, read})` | `read: ValueListenable<Object?> Function(Map<String, Object?>)` |

**Reactive scope hoisting (Task 7):** instead of inserting a `ReactiveScopeNode`, the pass walks the tree and **mutates** (or rebuilds, since the node tree is immutable — emit a copy) the LCA `WidgetNode` to set its `listenablePaths` field. For a group of reactive RefNodes whose joined paths are e.g. `['controller.count', 'controller.flag']`, the LCA WidgetNode becomes `WidgetNode(..., listenablePaths: {'controller.count', 'controller.flag'})`. If the LCA is not a `WidgetNode` (e.g., a `ListNode`), promote it: wrap its parent so the reactive scope lands on a WidgetNode boundary, OR raise a build-time warning and let the reactive subscription happen at the nearest enclosing WidgetNode.

The simplest correct rule: walk up from each `RefNode(reactive: true)` to the nearest enclosing `WidgetNode` ancestor; record the path in that WidgetNode's `listenablePaths`. This is a coarser scope than full LCA but always lands on a node the runtime knows how to wrap. v1 uses this rule; LCA optimization is deferred.

**Annotation API:** `Screen` is constructed as `@Screen('name')` — `name` is a positional String. Confirm by reading `packages/desk_sdui_annotation/lib/src/annotations.dart`.

---

## File Structure

```
packages/desk_sdui_generator/
├── lib/
│   ├── desk_sdui_generator.dart    ← public Builder factories
│   └── src/
│       ├── builders.dart            ← screenBuilder, registryBuilder factories
│       ├── screen_lowering/
│       │   ├── screen_generator.dart   ← SourceGen Generator entry
│       │   ├── ast_to_ir.dart           ← AST visitor → IrNode
│       │   ├── expression_lowerer.dart  ← AST → ExpressionNode
│       │   ├── widget_lowerer.dart      ← AST constructor invocation → WidgetNode
│       │   ├── closure_lowerer.dart     ← AST closure → EventNode (whitelist)
│       │   ├── const_fold_pass.dart
│       │   ├── reactive_hoist_pass.dart
│       │   ├── key_infer_pass.dart
│       │   ├── ir_emitter_dart.dart     ← IR → Dart literal source
│       │   └── ir_emitter_json.dart     ← IR → JSON bytes via JsonIrCodec
│       ├── registry/
│       │   └── registry_generator.dart  ← walks package, emits _registerAll
│       ├── analyzer_plugin/
│       │   ├── plugin.dart
│       │   └── rules/
│       │       ├── no_async_in_screen.dart
│       │       ├── no_set_state.dart
│       │       ├── no_mutable_locals.dart
│       │       ├── no_function_definition.dart
│       │       ├── no_try_catch.dart
│       │       ├── unsupported_loop.dart
│       │       ├── unregistered_symbol.dart
│       │       └── missing_key_warning.dart
│       └── diagnostics.dart
├── build.yaml
└── test/
    ├── ast_to_ir_test.dart
    ├── expression_lowerer_test.dart
    ├── widget_lowerer_test.dart
    ├── closure_lowerer_test.dart
    ├── const_fold_pass_test.dart
    ├── reactive_hoist_pass_test.dart
    ├── key_infer_pass_test.dart
    ├── ir_emitter_dart_test.dart
    ├── ir_emitter_json_test.dart
    ├── screen_generator_golden/    ← golden source-in/source-out tests
    │   ├── simple_text/
    │   ├── conditional/
    │   ├── for_loop/
    │   ├── reactive_listenable/
    │   └── ...
    └── analyzer_plugin/
        └── rules_test.dart
```

---

## Task 1: Wire dependencies + build.yaml

**Files:**
- Modify: `packages/desk_sdui_generator/pubspec.yaml`
- Create: `packages/desk_sdui_generator/build.yaml`

- [ ] **Step 1: pubspec**

```yaml
name: desk_sdui_generator
description: build_runner codegen + analyzer plugin for desk_sdui.
version: 0.0.1-dev
publish_to: none

environment:
  sdk: ^3.6.0

dependencies:
  analyzer: ^7.0.0
  analyzer_plugin: ^0.13.0
  build: ^2.4.0
  source_gen: ^2.0.0
  code_builder: ^4.10.0
  dart_style: ^3.0.0
  glob: ^2.1.2
  path: ^1.9.0
  meta: ^1.16.0
  desk_sdui_annotation:
    path: ../desk_sdui_annotation

dev_dependencies:
  build_runner: ^2.15.0
  build_test: ^2.2.0
  test: ^1.25.0
  very_good_analysis: ^7.0.0
```

- [ ] **Step 2: build.yaml**

```yaml
builders:
  screen_builder:
    import: 'package:desk_sdui_generator/desk_sdui_generator.dart'
    builder_factories: ['screenBuilder']
    build_extensions: {".dart": [".sdui.g.dart", ".uib"]}
    auto_apply: dependents
    build_to: source
    applies_builders: [':screen_builder']

  registry_builder:
    import: 'package:desk_sdui_generator/desk_sdui_generator.dart'
    builder_factories: ['registryBuilder']
    build_extensions: {"$package$": ["lib/desk_sdui_setup.sdui.g.dart"]}
    auto_apply: dependents
    build_to: source
    runs_before: [':screen_builder']
```

- [ ] **Step 3: Public Builder factories stub**

```dart
// lib/desk_sdui_generator.dart
library desk_sdui_generator;

import 'package:build/build.dart';
import 'src/builders.dart' as impl;

Builder screenBuilder(BuilderOptions options) => impl.screenBuilder(options);
Builder registryBuilder(BuilderOptions options) => impl.registryBuilder(options);
```

```dart
// lib/src/builders.dart
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'screen_lowering/screen_generator.dart';
import 'registry/registry_generator.dart';

Builder screenBuilder(BuilderOptions _) => PartBuilder(
  [ScreenGenerator()],
  '.sdui.g.dart',
  header: '// GENERATED CODE — DO NOT MODIFY BY HAND',
);

Builder registryBuilder(BuilderOptions _) => RegistryBuilder();
```

- [ ] **Step 4: Run `dart pub get` from `packages/desk_sdui_generator/`**

- [ ] **Step 5: Commit**

```bash
git add packages/desk_sdui_generator/pubspec.yaml packages/desk_sdui_generator/build.yaml packages/desk_sdui_generator/lib/desk_sdui_generator.dart packages/desk_sdui_generator/lib/src/builders.dart
git commit -m "chore(desk_sdui_generator): wire deps + build.yaml"
```

---

## Task 2: AST → node tree — expression lowerer

Lower analyzer `Expression` nodes (binary ops, prefix ops, property access, etc) to `ExpressionNode` node types.

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/screen_lowering/expression_lowerer.dart`
- Test: `packages/desk_sdui_generator/test/expression_lowerer_test.dart`

- [ ] **Step 1: Write tests using `parseString` from analyzer**

```dart
// test/expression_lowerer_test.dart
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:desk_sdui_generator/src/screen_lowering/expression_lowerer.dart';
import 'package:test/test.dart';

void main() {
  IrNode lower(String src) {
    final result = parseString(content: 'final x = $src;');
    final decl = result.unit.declarations.single as TopLevelVariableDeclaration;
    final init = decl.variables.variables.single.initializer!;
    return lowerExpression(init);
  }

  test('integer literal', () {
    final ir = lower('42');
    expect(ir, isA<LiteralNode>());
    expect((ir as LiteralNode).value, 42);
  });

  test('string literal', () {
    final ir = lower("'hello'");
    expect((ir as LiteralNode).value, 'hello');
  });

  test('binary +', () {
    final ir = lower('a + b') as ArithOpNode;
    expect(ir.op, ArithOp.add);
    expect((ir.left as RefNode).path, ['a']);
  });

  test('binary >=', () {
    final ir = lower('count >= 5') as CompareOpNode;
    expect(ir.op, CompareOp.gte);
  });

  test('logical &&', () {
    final ir = lower('a && b') as LogicOpNode;
    expect(ir.op, LogicOp.and);
  });

  test('prefix !', () {
    final ir = lower('!flag') as NotOpNode;
    expect((ir.operand as RefNode).path, ['flag']);
  });

  test('null-coalesce ??', () {
    final ir = lower('a ?? b') as CoalesceOpNode;
    expect((ir.left as RefNode).path, ['a']);
    expect((ir.right as RefNode).path, ['b']);
  });

  test('member access a.b.c', () {
    final ir = lower('a.b.c') as RefNode;
    expect(ir.path, ['a', 'b', 'c']);
  });

  test('list .length', () {
    final ir = lower('xs.length') as LengthOfNode;
    expect((ir.target as RefNode).path, ['xs']);
  });

  test('index access xs[0]', () {
    final ir = lower('xs[0]') as IndexAccessNode;
    expect((ir.target as RefNode).path, ['xs']);
    expect((ir.index as LiteralNode).value, 0);
  });

  test('null check ==null', () {
    final ir = lower('x == null') as IsNullCheckNode;
    expect((ir.operand as RefNode).path, ['x']);
  });

  test('string interpolation', () {
    final ir = lower(r"'hi $name!'") as StringInterpNode;
    expect(ir.parts.length, 3);
    expect((ir.parts[0] as LiteralNode).value, 'hi ');
    expect((ir.parts[1] as RefNode).path, ['name']);
    expect((ir.parts[2] as LiteralNode).value, '!');
  });

  test('conditional ?:', () {
    final ir = lower('a ? b : c') as ConditionalNode;
    expect((ir.condition as RefNode).path, ['a']);
  });
}
```

- [ ] **Step 2: Run — expect FAIL**

- [ ] **Step 3: Implement `lowerExpression`**

Use a `switch` on the analyzer node type. Map every supported AST shape to a node constructor; for unsupported, throw a `LoweringError` with the source range.

```dart
// lib/src/screen_lowering/expression_lowerer.dart
import 'package:analyzer/dart/ast/ast.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import '../diagnostics.dart';

IrNode lowerExpression(Expression expr) {
  if (expr is IntegerLiteral) return LiteralNode(expr.value);
  if (expr is DoubleLiteral) return LiteralNode(expr.value);
  if (expr is BooleanLiteral) return LiteralNode(expr.value);
  if (expr is NullLiteral) return const LiteralNode(null);
  if (expr is SimpleStringLiteral) return LiteralNode(expr.value);

  if (expr is StringInterpolation) {
    final parts = <IrNode>[];
    for (final element in expr.elements) {
      if (element is InterpolationString) {
        if (element.value.isNotEmpty) parts.add(LiteralNode(element.value));
      } else if (element is InterpolationExpression) {
        parts.add(lowerExpression(element.expression));
      }
    }
    return StringInterpNode(parts: parts);
  }

  if (expr is SimpleIdentifier) {
    return RefNode(path: [expr.name]);
  }

  if (expr is PrefixedIdentifier) {
    return RefNode(path: [expr.prefix.name, expr.identifier.name]);
  }

  if (expr is PropertyAccess) {
    // a.b.c → RefNode(['a','b','c']) when target is also a Ref-like chain.
    // Special property: .length → LengthOfNode.
    if (expr.propertyName.name == 'length') {
      return LengthOfNode(target: lowerExpression(expr.target!));
    }
    final target = lowerExpression(expr.target!);
    if (target is RefNode) {
      return RefNode(path: [...target.path, expr.propertyName.name]);
    }
    return MemberAccessNode(target: target, member: expr.propertyName.name);
  }

  if (expr is IndexExpression) {
    return IndexAccessNode(
      target: lowerExpression(expr.target!),
      index: lowerExpression(expr.index),
    );
  }

  if (expr is BinaryExpression) {
    final left = lowerExpression(expr.leftOperand);
    final right = lowerExpression(expr.rightOperand);
    switch (expr.operator.lexeme) {
      case '+': return ArithOpNode(op: ArithOp.add, left: left, right: right);
      case '-': return ArithOpNode(op: ArithOp.sub, left: left, right: right);
      case '*': return ArithOpNode(op: ArithOp.mul, left: left, right: right);
      case '/': return ArithOpNode(op: ArithOp.div, left: left, right: right);
      case '%': return ArithOpNode(op: ArithOp.mod, left: left, right: right);
      case '==':
        if (right is LiteralNode && right.value == null) {
          return IsNullCheckNode(operand: left);
        }
        return CompareOpNode(op: CompareOp.eq, left: left, right: right);
      case '!=':
        return CompareOpNode(op: CompareOp.neq, left: left, right: right);
      case '<': return CompareOpNode(op: CompareOp.lt, left: left, right: right);
      case '<=': return CompareOpNode(op: CompareOp.lte, left: left, right: right);
      case '>': return CompareOpNode(op: CompareOp.gt, left: left, right: right);
      case '>=': return CompareOpNode(op: CompareOp.gte, left: left, right: right);
      case '&&': return LogicOpNode(op: LogicOp.and, left: left, right: right);
      case '||': return LogicOpNode(op: LogicOp.or, left: left, right: right);
      case '??': return CoalesceOpNode(left: left, right: right);
    }
    throw LoweringError('unsupported binary operator ${expr.operator.lexeme}', expr);
  }

  if (expr is PrefixExpression && expr.operator.lexeme == '!') {
    return NotOpNode(operand: lowerExpression(expr.operand));
  }

  if (expr is ConditionalExpression) {
    return ConditionalNode(
      condition: lowerExpression(expr.condition),
      then: lowerExpression(expr.thenExpression),
      otherwise: lowerExpression(expr.elseExpression),
    );
  }

  if (expr is ListLiteral) {
    return ListNode(children: expr.elements
        .map((e) => lowerExpression(e as Expression))
        .toList());
  }

  if (expr is MethodInvocation) {
    // Specific recognized invocations: e.g., `xs.contains(x)` or const ctor.
    // For non-recognized: defer to `widget_lowerer` if InstanceCreation.
    throw LoweringError('method invocation not yet supported', expr);
  }

  if (expr is InstanceCreationExpression) {
    // Const constructor call (e.g., `EdgeInsets.all(8)`) — caller may resolve
    // via `widget_lowerer.tryLowerConstCtor`; here we surface it raw.
    throw LoweringError('handle InstanceCreationExpression in widget_lowerer', expr);
  }

  throw LoweringError('unsupported expression: ${expr.runtimeType}', expr);
}
```

- [ ] **Step 4: Add `diagnostics.dart`**

```dart
// lib/src/diagnostics.dart
import 'package:analyzer/dart/ast/ast.dart';

class LoweringError implements Exception {
  LoweringError(this.message, this.node);
  final String message;
  final AstNode node;
  @override
  String toString() => 'LoweringError @ ${node.offset}: $message';
}
```

- [ ] **Step 5: Run — expect PASS**

- [ ] **Step 6: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/screen_lowering/expression_lowerer.dart packages/desk_sdui_generator/lib/src/diagnostics.dart packages/desk_sdui_generator/test/expression_lowerer_test.dart
git commit -m "feat(desk_sdui_generator): expression lowerer (analyzer Expression → ExpressionNode)"
```

---

## Task 3: AST → node tree — widget lowerer

Lower analyzer `InstanceCreationExpression` nodes (constructor calls like `Column(children: [...])`) to `WidgetNode`. Recognize a curated set of const constructors (`EdgeInsets.all(8)`, `Color(0xFF...)`, `BorderRadius.circular(N)`, `TextStyle(...)`, `ValueKey(...)`, `Alignment.center`) as `LiteralNode(<const>)` baked at build time.

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/screen_lowering/widget_lowerer.dart`
- Test: `packages/desk_sdui_generator/test/widget_lowerer_test.dart`

- [ ] **Step 1: Tests**

```dart
test('Column with empty children → WidgetNode', () {
  final ir = lower('Column(children: [])') as WidgetNode;
  expect(ir.name, 'Column');
  expect((ir.args['children']! as ListNode).children, isEmpty);
});

test('Padding with EdgeInsets.all literal-folds', () {
  final ir = lower('Padding(padding: EdgeInsets.all(8), child: Text(\'hi\'))') as WidgetNode;
  expect(ir.name, 'Padding');
  expect(ir.args['padding'], isA<LiteralNode>()); // const-folded
});

test('Text with positional arg → args.data', () {
  final ir = lower("Text('hello')") as WidgetNode;
  expect(ir.name, 'Text');
  expect((ir.args['data']! as LiteralNode).value, 'hello');
});

test('key: ValueKey(item.id) extracted', () {
  final ir = lower('ItemTile(key: ValueKey(item.id))') as WidgetNode;
  expect(ir.key, isA<WidgetNode>()); // or a special KeyNode
});

test('unknown widget surfaces analyzer error', () {
  expect(() => lower('CompletelyUnknownThing()'),
      throwsA(isA<LoweringError>()));
});
```

- [ ] **Step 2: Implement `lowerWidget(InstanceCreationExpression)`**

```dart
// lib/src/screen_lowering/widget_lowerer.dart
import 'package:analyzer/dart/ast/ast.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import '../diagnostics.dart';
import 'expression_lowerer.dart';
import 'closure_lowerer.dart';

/// Whitelist of constructors we evaluate to a const Dart literal at build time.
const _constCtors = {
  'EdgeInsets.all', 'EdgeInsets.symmetric', 'EdgeInsets.only', 'EdgeInsets.fromLTRB',
  'Color', 'Color.fromARGB', 'Color.fromRGBO',
  'BorderRadius.all', 'BorderRadius.circular', 'BorderRadius.only',
  'TextStyle',
  'Alignment',
  'Duration',
  'IconData',
};

IrNode lowerWidget(InstanceCreationExpression expr) {
  final ctorName = expr.constructorName.toString();

  // 1. Const constructor literal-fold
  if (_isConstFoldable(ctorName)) {
    return ConstNode(value: _evaluateConst(expr));
  }

  // 2. Recognized widget — lower constructor args
  final widgetName = ctorName.split('.').first;
  final args = <String, IrNode>{};
  IrNode? key;

  // Positional args: if widget has a known positional param (e.g., Text takes
  // `data` positional), map by index.
  for (var i = 0; i < expr.argumentList.arguments.length; i++) {
    final a = expr.argumentList.arguments[i];
    if (a is NamedExpression) {
      final name = a.name.label.name;
      final value = _lowerArg(a.expression);
      if (name == 'key') {
        key = value;
      } else {
        args[name] = value;
      }
    } else {
      // Positional → resolve via constructor signature lookup. For builtins
      // we hard-code the convention (Text positional → 'data', Icon positional
      // → 'icon').
      final paramName = _positionalParamName(widgetName, i);
      args[paramName] = _lowerArg(a as Expression);
    }
  }

  return WidgetNode(name: widgetName, args: args, key: key);
}

IrNode _lowerArg(Expression a) {
  if (a is FunctionExpression) {
    return lowerClosure(a);
  }
  if (a is InstanceCreationExpression) {
    return lowerWidget(a);
  }
  if (a is ListLiteral) {
    return ListNode(children: a.elements.map((e) {
      if (e is IfElement) return _lowerIfElement(e);
      if (e is ForElement) return _lowerForElement(e);
      if (e is SpreadElement) {
        return SpreadNode(source: _lowerArg(e.expression));
      }
      return _lowerArg(e as Expression);
    }).toList());
  }
  if (a is MethodInvocation) {
    // Tear-off as event: controller.method (zero-arg call)
    return lowerClosure(a);
  }
  return lowerExpression(a);
}

IrNode _lowerIfElement(IfElement el) {
  // `if (cond) child` or `if (cond) child else other`
  final cond = lowerExpression(el.expression);
  final then = _lowerArg(el.thenElement as Expression);
  final otherwise = el.elseElement == null
      ? null
      : _lowerArg(el.elseElement! as Expression);
  return ConditionalNode(condition: cond, then: then, otherwise: otherwise);
}

IrNode _lowerForElement(ForElement el) {
  final parts = el.forLoopParts;
  if (parts is ForEachPartsWithDeclaration) {
    final loopVar = parts.loopVariable.name.lexeme;
    final source = lowerExpression(parts.iterable);
    final body = _lowerArg(el.body as Expression);
    return ForNode(loopVar: loopVar, source: source, body: body);
  }
  if (parts is ForEachPartsWithPattern) {
    // Destructured: `for (final (i, x) in xs.indexed)`
    final names = _extractPatternNames(parts.pattern);
    final source = lowerExpression(parts.iterable);
    final body = _lowerArg(el.body as Expression);
    return ForNode.destructured(loopVars: names, source: source, body: body);
  }
  throw LoweringError('counter-style for not supported', el);
}

bool _isConstFoldable(String ctor) {
  for (final c in _constCtors) {
    if (ctor == c || ctor.startsWith('$c.')) return true;
  }
  return false;
}

Object? _evaluateConst(InstanceCreationExpression expr) {
  // Use analyzer's `computeConstantValue` if `expr.staticType` is available.
  // For builders we already invoke from a `LibraryReader` context, so the
  // node is resolved.
  final value = expr.computeConstantValue();
  if (value == null) {
    throw LoweringError('failed to evaluate const constructor', expr);
  }
  return value.toDartObject();
}

String _positionalParamName(String widget, int index) {
  // Hardcoded conventions for builtins; for user widgets we use index.
  switch (widget) {
    case 'Text': return index == 0 ? 'data' : 'arg$index';
    case 'Icon': return index == 0 ? 'icon' : 'arg$index';
    case 'SizedBox': return 'arg$index';
  }
  return 'arg$index';
}

List<String> _extractPatternNames(DartPattern pat) {
  // Walks a record pattern and collects identifier names in order.
  final names = <String>[];
  if (pat is RecordPattern) {
    for (final field in pat.fields) {
      final p = field.pattern;
      if (p is DeclaredVariablePattern) {
        names.add(p.name.lexeme);
      }
    }
  }
  return names;
}
```

(The exact analyzer API method names — `computeConstantValue`, `toDartObject`, etc — may need refinement when running. Validate against analyzer 7.x docs during implementation.)

- [ ] **Step 3: Run — expect PASS**

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/screen_lowering/widget_lowerer.dart packages/desk_sdui_generator/test/widget_lowerer_test.dart
git commit -m "feat(desk_sdui_generator): widget lowerer with const-fold whitelist"
```

---

## Task 4: Closure lowerer (whitelist)

The 5 supported closure shapes from the spec — anything else is a `LoweringError`.

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/screen_lowering/closure_lowerer.dart`
- Test: `packages/desk_sdui_generator/test/closure_lowerer_test.dart`

- [ ] **Step 1: Tests covering all 5 supported shapes + 2 rejected**

```dart
test('tear-off controller.foo → EventNode', () {
  final ir = lower('controller.foo') as EventNode;
  expect(ir.target, ['controller', 'foo']);
});
test('() => controller.foo() → EventNode no args', () {
  final ir = lower('() => controller.foo()') as EventNode;
  expect(ir.target, ['controller', 'foo']);
  expect(ir.args, anyOf(isNull, isEmpty));
});
test('() => controller.foo(42) → EventNode with literal arg', () {
  final ir = lower('() => controller.foo(42)') as EventNode;
  expect((ir.args!['arg0']! as LiteralNode).value, 42);
});
test('() => controller.foo(item.id) → EventNode with RefNode arg', () {
  final ir = lower('() => controller.foo(item.id)') as EventNode;
  expect((ir.args!['arg0']! as RefNode).path, ['item', 'id']);
});
test('(value) => controller.foo(value) → EventNode pass-through', () {
  final ir = lower('(value) => controller.foo(value)') as EventNode;
  expect((ir.args!['arg0']! as RefNode).path, ['_callback_arg_0']);
});
test('(a) => controller.foo(transform(a)) → LoweringError', () {
  expect(() => lower('(a) => controller.foo(transform(a))'),
      throwsA(isA<LoweringError>()));
});
test('() { var x = 1; return controller.foo(x); } → LoweringError (statement body)', () {
  expect(() => lower('() { var x = 1; return controller.foo(x); }'),
      throwsA(isA<LoweringError>()));
});
```

- [ ] **Step 2: Implement**

```dart
// lib/src/screen_lowering/closure_lowerer.dart
import 'package:analyzer/dart/ast/ast.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import '../diagnostics.dart';
import 'expression_lowerer.dart';

/// Lowers a closure/tear-off expression to an EventNode.
/// Rejects anything outside the whitelist with a LoweringError.
IrNode lowerClosure(Expression expr) {
  // Shape 1: tear-off — `controller.foo` (PrefixedIdentifier or PropertyAccess)
  if (expr is PrefixedIdentifier) {
    return EventNode(target: [expr.prefix.name, expr.identifier.name]);
  }
  if (expr is PropertyAccess && expr.target is SimpleIdentifier) {
    return EventNode(target: [
      (expr.target as SimpleIdentifier).name,
      expr.propertyName.name,
    ]);
  }

  // Shape 2-5: function expression `() => ...` or `(p) => ...`
  if (expr is FunctionExpression) {
    final body = expr.body;
    if (body is! ExpressionFunctionBody) {
      throw LoweringError(
        'closure must be expression-bodied (`() => x`, not `() { return x; }`)',
        expr,
      );
    }
    final inner = body.expression;
    if (inner is MethodInvocation) {
      final target = _extractTarget(inner);
      if (target == null) {
        throw LoweringError(
          'closure body must call a method like `controller.foo(...)`',
          inner,
        );
      }
      // Lower each call arg per whitelist
      final args = <String, IrNode>{};
      final params = expr.parameters?.parameters ?? const [];
      for (var i = 0; i < inner.argumentList.arguments.length; i++) {
        final a = inner.argumentList.arguments[i];
        if (a is! Expression) {
          throw LoweringError('named call args not supported in closure', a);
        }
        args['arg$i'] = _lowerCallArg(a, params, expr);
      }
      return EventNode(target: target, args: args.isEmpty ? null : args);
    }
    throw LoweringError(
      'closure body must be a single method call; extract more complex logic to a ViewModel method',
      inner,
    );
  }

  if (expr is MethodInvocation) {
    // Direct invocation that codegen treats as a tear-off-with-args:
    // `controller.foo(x)` written inline (rare; usually wrapped in closure).
    final target = _extractTarget(expr);
    if (target != null) {
      final args = <String, IrNode>{};
      for (var i = 0; i < expr.argumentList.arguments.length; i++) {
        args['arg$i'] = lowerExpression(expr.argumentList.arguments[i] as Expression);
      }
      return EventNode(target: target, args: args.isEmpty ? null : args);
    }
  }

  throw LoweringError('unsupported closure shape', expr);
}

List<String>? _extractTarget(MethodInvocation call) {
  final target = call.target;
  if (target is SimpleIdentifier) {
    return [target.name, call.methodName.name];
  }
  if (target is PrefixedIdentifier) {
    return [target.prefix.name, target.identifier.name, call.methodName.name];
  }
  return null;
}

IrNode _lowerCallArg(
  Expression arg,
  List<FormalParameter> params,
  FunctionExpression closure,
) {
  // Pass-through: `(value) => controller.foo(value)` — `value` reads as `_callback_arg_0`.
  if (arg is SimpleIdentifier) {
    final paramIndex = params.indexWhere((p) => p.name?.lexeme == arg.name);
    if (paramIndex >= 0) {
      return RefNode(path: ['_callback_arg_$paramIndex']);
    }
    // Otherwise it's a closed-over loop variable or scope identifier
    return RefNode(path: [arg.name]);
  }
  if (arg is IntegerLiteral || arg is StringLiteral || arg is BooleanLiteral) {
    return lowerExpression(arg);
  }
  if (arg is PrefixedIdentifier || arg is PropertyAccess) {
    return lowerExpression(arg);
  }
  // Anything else — analyzer error with fix-it
  throw LoweringError(
    'unsupported closure arg shape — extract `${arg.toSource()}` to a top-level fn or controller method',
    arg,
  );
}
```

- [ ] **Step 3: Run — expect PASS**

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/screen_lowering/closure_lowerer.dart packages/desk_sdui_generator/test/closure_lowerer_test.dart
git commit -m "feat(desk_sdui_generator): closure lowerer (5-shape whitelist)"
```

---

## Task 5: AST → node tree — top-level `astToIr`

Composes expression + widget + closure lowerers into one entry point that walks a `@Screen` function body.

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/screen_lowering/ast_to_ir.dart`
- Test: `packages/desk_sdui_generator/test/ast_to_ir_test.dart`

- [ ] **Step 1: Tests**

```dart
test('@Screen Widget buildHello() => Text(\'hi\') lowers fully', () {
  final result = lowerScreen('''
@Screen('hello')
Widget buildHello() => Text('hi');
''');
  expect(result.name, 'hello');
  expect(result.root, isA<WidgetNode>());
});

test('@Screen with reactive ValueListenable param', () {
  final result = lowerScreen('''
@Screen('counter')
Widget buildCounter(ValueNotifier<int> count) => Text('\$count');
''');
  // count usage should be reactive: true after lowering
});
```

- [ ] **Step 2: Implement `lowerScreen`**

```dart
// lib/src/screen_lowering/ast_to_ir.dart
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import '../diagnostics.dart';
import 'widget_lowerer.dart';
import 'expression_lowerer.dart';

class ScreenLowerResult {
  ScreenLowerResult({
    required this.name,
    required this.root,
    required this.params,
    required this.reactiveParams,
    required this.methodRefs,
    required this.widgetRefs,
    required this.fnRefs,
  });

  final String name;
  final IrNode root;
  /// Parameter names + Dart type strings, in declaration order.
  final List<({String name, String type})> params;
  /// Subset of params that are reactive (`ValueListenable<T>` subtypes).
  final List<String> reactiveParams;
  /// Method tear-offs/closures referenced (e.g., `controller.removeItem`).
  final List<List<String>> methodRefs;
  /// Widget class names referenced.
  final Set<String> widgetRefs;
  /// Top-level functions referenced.
  final Set<String> fnRefs;
}

ScreenLowerResult lowerScreen(FunctionDeclaration fn, ScreenAnnotationData ann) {
  final body = fn.functionExpression.body;
  if (body is! ExpressionFunctionBody) {
    throw LoweringError('@Screen function must be `=>`-bodied', fn);
  }
  final exprIr = lowerExpression(body.expression); // dispatch through widget too
  // … walk and collect methodRefs, widgetRefs, fnRefs via a visitor.
  // … detect reactive params via element.type analysis.
  // …
  return ScreenLowerResult(/* … */);
}

class ScreenAnnotationData {
  ScreenAnnotationData({required this.name});
  final String name;
}
```

The visitor pattern collects all `WidgetNode` names → `widgetRefs`, all `EventNode` targets → `methodRefs`, all top-level function calls → `fnRefs`.

- [ ] **Step 3: Run — expect PASS**

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/screen_lowering/ast_to_ir.dart packages/desk_sdui_generator/test/ast_to_ir_test.dart
git commit -m "feat(desk_sdui_generator): ast_to_ir top-level — composes lowerers + collects refs"
```

---

## Task 6: Const-fold pass

After lowering, walk the node tree. Replace any subtree where every leaf is `LiteralNode`/`ConstNode` (no `RefNode`/`EventNode`) with a `ConstNode(constructedWidget)`.

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/screen_lowering/const_fold_pass.dart`
- Test: `packages/desk_sdui_generator/test/const_fold_pass_test.dart`

- [ ] **Step 1: Tests**

```dart
test('Text with literal arg folds to ConstNode', () {
  final input = WidgetNode(name: 'Text', args: {'data': const LiteralNode('hi')});
  final out = constFold(input);
  expect(out, isA<ConstNode>());
});

test('Text with RefNode arg does NOT fold', () {
  final input = WidgetNode(name: 'Text', args: {'data': const RefNode(path: ['name'])});
  final out = constFold(input);
  expect(out, isA<WidgetNode>());
});

test('Padding with const child folds entirely', () {
  final input = WidgetNode(name: 'Padding', args: {
    'padding': const ConstNode(value: EdgeInsets.all(8)),
    'child': WidgetNode(name: 'Text', args: {'data': const LiteralNode('hi')}),
  });
  final out = constFold(input);
  expect(out, isA<ConstNode>());
});
```

- [ ] **Step 2: Implement**

```dart
// lib/src/screen_lowering/const_fold_pass.dart
IrNode constFold(IrNode node) {
  // Recursively fold children first
  final folded = _foldChildren(node);
  if (_isPureLiteral(folded)) {
    final value = _materializeWidget(folded);
    if (value != null) return ConstNode(value: value);
  }
  return folded;
}

bool _isPureLiteral(IrNode node) {
  // No RefNode, EventNode, or any reactive subtree anywhere.
  // Visitor returns false on first non-pure descendant.
  // ...
}
```

(The materializer maps `WidgetNode('Text', {data: 'hi'})` to a `const Text('hi')` literal — emitted as Dart source by `ir_emitter_dart`. For the const-fold pass we keep `ConstNode(value: <pseudo>)` and let the emitter recognize it.)

- [ ] **Step 3: Run — expect PASS**

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/screen_lowering/const_fold_pass.dart packages/desk_sdui_generator/test/const_fold_pass_test.dart
git commit -m "feat(desk_sdui_generator): const-fold pass"
```

---

## Task 7: Reactive scope hoisting pass

For every `RefNode(reactive: true)`, find the **nearest enclosing `WidgetNode` ancestor** and add the joined ref path (e.g., `'controller.count'`) to its `listenablePaths: Set<String>`. (Per the adapter notes: v1 uses nearest-WidgetNode-ancestor, not full LCA, since `WidgetNode` is the only node type that carries the field and the runtime only wraps WidgetNode in `ListenableBuilder`.)

The pass is rewriting — the node tree is immutable, so emit a copy of the WidgetNode with the augmented `listenablePaths`.

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/screen_lowering/reactive_hoist_pass.dart`
- Test: `packages/desk_sdui_generator/test/reactive_hoist_pass_test.dart`

- [ ] **Step 1: Tests**

```dart
test('reactive RefNode lifts to nearest WidgetNode ancestor', () {
  final input = WidgetNode(name: 'Outer', args: {
    'child': WidgetNode(name: 'Inner', args: {
      'label': const RefNode(['controller', 'count'], reactive: true),
    }),
  });
  final out = reactiveHoist(input) as WidgetNode;
  final inner = out.args['child']! as WidgetNode;
  expect(inner.listenablePaths, {'controller.count'});
  expect(out.listenablePaths, isEmpty,
      reason: 'outer should not get the listenable — its inner WidgetNode wraps it');
});

test('multiple reactive refs to same path collapse to one entry', () {
  final input = WidgetNode(name: 'Inner', args: {
    'a': const RefNode(['controller', 'count'], reactive: true),
    'b': const RefNode(['controller', 'count'], reactive: true),
  });
  final out = reactiveHoist(input) as WidgetNode;
  expect(out.listenablePaths, {'controller.count'});
});

test('multiple reactive refs to different paths merge', () {
  final input = WidgetNode(name: 'Inner', args: {
    'a': const RefNode(['controller', 'count'], reactive: true),
    'b': const RefNode(['controller', 'flag'], reactive: true),
  });
  final out = reactiveHoist(input) as WidgetNode;
  expect(out.listenablePaths, {'controller.count', 'controller.flag'});
});

test('reactive RefNode under ConditionalNode lifts past it', () {
  // ConditionalNode is not a WidgetNode — reactive ref bubbles through.
  final input = WidgetNode(name: 'Outer', args: {
    'child': ConditionalNode(
      condition: const LiteralNode(true),
      thenBranch: WidgetNode(name: 'Inner', args: {
        'label': const RefNode(['controller', 'count'], reactive: true),
      }),
    ),
  });
  final out = reactiveHoist(input) as WidgetNode;
  final cond = out.args['child']! as ConditionalNode;
  final inner = cond.thenBranch as WidgetNode;
  expect(inner.listenablePaths, {'controller.count'});
});
```

- [ ] **Step 2: Implement**

Walk the tree; on each `WidgetNode`, recursively process children, then collect all reactive paths reachable through non-WidgetNode descendants and assign to that node's `listenablePaths`. Use a recursive function returning `(rewrittenNode, paths)` where `paths` is the set of reactive paths the parent must absorb (only when this node is NOT a WidgetNode).

- [ ] **Step 3: Run — expect PASS**

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/screen_lowering/reactive_hoist_pass.dart packages/desk_sdui_generator/test/reactive_hoist_pass_test.dart
git commit -m "feat(desk_sdui_generator): reactive scope hoisting pass"
```

---

## Task 8: Key inference pass

For every `ForNode` whose body's root is a `WidgetNode` with no `key`, inspect the loop variable's static type (analyzer `Element`) for an `id`/`uuid`/`@KeyField`-annotated field. If found, synthesize `key: ValueKey(item.id)` (a `WidgetNode('ValueKey', {arg0: RefNode([loopVar, 'id'])})`). Else emit a build-time warning.

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/screen_lowering/key_infer_pass.dart`
- Test: `packages/desk_sdui_generator/test/key_infer_pass_test.dart`

- [ ] **Step 1: Tests** — synth key when `id` field present; warning when absent; respect `// sdui:no-key` and explicit `key: null`

- [ ] **Step 2: Implement** — pass takes `(ir, lookupTypeForLoopVar)` so it can be unit-tested without a full analyzer driver

- [ ] **Step 3: Run — expect PASS**

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/screen_lowering/key_infer_pass.dart packages/desk_sdui_generator/test/key_infer_pass_test.dart
git commit -m "feat(desk_sdui_generator): key inference pass for ForNode bodies"
```

---

## Task 9: Node tree → Dart literal emitter

Generate the `.sdui.g.dart` part file. Emits a `ScreenBinding` with the node tree as a constant Dart literal, the `inputs`/`methods`/`reactives` lists synthesized from `ScreenLowerResult`.

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/screen_lowering/ir_emitter_dart.dart`
- Test: `packages/desk_sdui_generator/test/ir_emitter_dart_test.dart`

- [ ] **Step 1: Test — golden source-out**

```dart
test('emits ScreenBinding with const IR for trivial @Screen', () {
  final result = ScreenLowerResult(
    name: 'hello',
    root: WidgetNode(name: 'Text', args: {'data': const LiteralNode('hi')}),
    params: [(name: 'data', type: 'HelloData')],
    reactiveParams: const [],
    methodRefs: const [],
    widgetRefs: const {'Text'},
    fnRefs: const {},
  );
  final source = emitDart(result);
  expect(source, contains('const ScreenBinding('));
  expect(source, contains("name: 'hello'"));
  expect(source, contains('WidgetNode'));
});
```

- [ ] **Step 2: Implement using `code_builder`**

Walks the node tree; for each node type emit a corresponding `const Foo(...)` Dart expression. `ConstNode` emits its inner value as a `const ...` Dart literal directly.

- [ ] **Step 3: Run — expect PASS**

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/screen_lowering/ir_emitter_dart.dart packages/desk_sdui_generator/test/ir_emitter_dart_test.dart
git commit -m "feat(desk_sdui_generator): IR → Dart literal emitter"
```

---

## Task 10: `.sdui.json` emitter (`.uib`)

Reuses Phase 1's `JsonIrCodec`. Drops `ConstNode` widgets back to their constituent `WidgetNode` form before encoding (so wire form is portable; `ConstNode` is a Dart-only optimization).

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/screen_lowering/ir_emitter_json.dart`
- Test: `packages/desk_sdui_generator/test/ir_emitter_json_test.dart`

- [ ] **Step 1: Test — round-trip via Phase 1's codec**

- [ ] **Step 2: Implement — walk, demote `ConstNode` to original WidgetNode shape, encode**

- [ ] **Step 3: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/screen_lowering/ir_emitter_json.dart packages/desk_sdui_generator/test/ir_emitter_json_test.dart
git commit -m "feat(desk_sdui_generator): IR → JSON emitter (.uib wire form)"
```

---

## Task 11: `ScreenGenerator` — wire the SourceGen entry

Implements `GeneratorForAnnotation<Screen>` from `source_gen`. For each annotated function: lower → const-fold → reactive-hoist → key-infer → emit Dart + JSON.

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/screen_lowering/screen_generator.dart`
- Test: golden tests in `test/screen_generator_golden/`

- [ ] **Step 1: Implement**

```dart
// lib/src/screen_lowering/screen_generator.dart
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'ast_to_ir.dart';
import 'const_fold_pass.dart';
import 'reactive_hoist_pass.dart';
import 'key_infer_pass.dart';
import 'ir_emitter_dart.dart';
import 'ir_emitter_json.dart';

class ScreenGenerator extends GeneratorForAnnotation<Screen> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! FunctionElement) {
      throw InvalidGenerationSourceError(
        '@Screen must be on a top-level function',
        element: element,
      );
    }
    final fnDecl = await _resolveDecl(element, buildStep); // helper
    final ann = ScreenAnnotationData(name: annotation.read('name').stringValue);

    var result = lowerScreen(fnDecl, ann);
    var ir = constFold(result.root);
    ir = reactiveHoist(ir);
    ir = inferKeys(ir, lookupType: (loopVar) => /* via element */ );

    // Emit .uib alongside (separate AssetWriter call)
    final jsonBytes = emitJson(IrTree(name: ann.name, version: 1, root: ir));
    await buildStep.writeAsBytes(
      buildStep.inputId.changeExtension('.uib'),
      jsonBytes,
    );

    return emitDart(result.copyWith(root: ir));
  }
}
```

- [ ] **Step 2: Add golden test fixtures**

`test/screen_generator_golden/simple_text/input.dart`:
```dart
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:flutter/widgets.dart';
part 'input.sdui.g.dart';

@Screen('hello')
Widget buildHello() => Text('hi');
```

`test/screen_generator_golden/simple_text/output.sdui.g.dart` — expected output.

Use `build_test`'s `testBuilder` to verify each fixture.

- [ ] **Step 3: Run — expect PASS**

- [ ] **Step 4: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/screen_lowering/screen_generator.dart packages/desk_sdui_generator/test/screen_generator_golden
git commit -m "feat(desk_sdui_generator): ScreenGenerator with full lowering pipeline + golden tests"
```

---

## Task 12: `RegistryBuilder`

Glob-collects every library in the package using a `LibraryReader`, finds every `@Screen` annotation, emits `lib/desk_sdui_setup.sdui.g.dart` with `void _registerAll(Runtime rt)` calling `rt.registerScreen(<screenName>Binding)` for each.

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/registry/registry_generator.dart`
- Test: `packages/desk_sdui_generator/test/registry_generator_test.dart`

- [ ] **Step 1: Implement as a `Builder` (not `GeneratorForAnnotation`) since it produces a single output per package**

```dart
class RegistryBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    r'$package$': ['lib/desk_sdui_setup.sdui.g.dart'],
  };

  @override
  Future<void> build(BuildStep step) async {
    final screens = <_ScreenInfo>[];
    await for (final input in step.findAssets(Glob('lib/**.dart'))) {
      if (input.path.endsWith('.sdui.g.dart')) continue;
      final lib = await step.resolver.libraryFor(input);
      for (final el in lib.topLevelElements) {
        if (el is FunctionElement) {
          for (final ann in el.metadata) {
            final name = ann.computeConstantValue()?.getField('name')?.toStringValue();
            if (name != null) {
              screens.add(_ScreenInfo(name: name, bindingSymbol: '${el.name}Binding', sourceImport: input.uri));
            }
          }
        }
      }
    }
    final source = _emitRegistry(screens);
    await step.writeAsString(
      AssetId(step.inputId.package, 'lib/desk_sdui_setup.sdui.g.dart'),
      source,
    );
  }
}
```

- [ ] **Step 2: Test with `testBuilder` against a fake package with two screens**

- [ ] **Step 3: Commit**

```bash
git add packages/desk_sdui_generator/lib/src/registry packages/desk_sdui_generator/test/registry_generator_test.dart
git commit -m "feat(desk_sdui_generator): RegistryBuilder — emits _registerAll part file"
```

---

## Task 13: Analyzer plugin — 8 lint rules

**Files:**
- Create: `packages/desk_sdui_generator/lib/src/analyzer_plugin/plugin.dart`
- Create: `packages/desk_sdui_generator/lib/src/analyzer_plugin/rules/<rule>.dart` × 8
- Test: `packages/desk_sdui_generator/test/analyzer_plugin/rules_test.dart`

Rules from spec:

1. `sdui_no_async_in_screen` — flag `await` inside `@Screen`
2. `sdui_no_set_state` — flag `setState(...)` reference
3. `sdui_no_mutable_locals` — flag `var x = ...` (only `final`/`let`-style allowed)
4. `sdui_no_function_definition` — flag nested `FunctionDeclaration`
5. `sdui_no_try_catch` — flag `TryStatement`
6. `sdui_unsupported_loop` — flag `WhileStatement`, `DoStatement`, counter-style `ForStatement`
7. `sdui_unregistered_symbol` — flag `InstanceCreationExpression` for a class that isn't a registered widget (heuristic: not a Flutter SDK class and not annotated `@Screen`)
8. `sdui_missing_key_warning` — warning on `for`-element body without inferable key

- [ ] **Step 1: One TDD pair per rule** (test detects expected error → implement rule → tests pass)

- [ ] **Step 2: Wire plugin entry**

```dart
// lib/src/analyzer_plugin/plugin.dart
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'rules/no_async_in_screen.dart';
// ...

class DeskSduiPlugin extends ServerPlugin {
  // Register all 8 rules.
}
```

- [ ] **Step 3: Commit per rule**

```bash
git commit -m "feat(desk_sdui_generator): lint sdui_no_async_in_screen"
# … 7 more
```

Final commit:

```bash
git add packages/desk_sdui_generator/lib/src/analyzer_plugin/plugin.dart
git commit -m "feat(desk_sdui_generator): analyzer plugin entry wiring 8 rules"
```

---

## Task 14: Full integration test in a fake consumer package

Create `packages/desk_sdui_generator/test/integration_consumer/` — a minimal consumer with one `@Screen`. Run `build_runner` against it via `build_test`. Assert the generated outputs compile.

**Files:**
- Create: `packages/desk_sdui_generator/test/integration_consumer/`
- Create: `packages/desk_sdui_generator/test/integration_test.dart`

- [ ] **Step 1: Build fixture package**
- [ ] **Step 2: Test runs builders end-to-end and asserts emitted Dart compiles**
- [ ] **Step 3: Commit**

```bash
git add packages/desk_sdui_generator/test/integration_consumer packages/desk_sdui_generator/test/integration_test.dart
git commit -m "test(desk_sdui_generator): end-to-end builder integration"
```

---

## Task 15: Final verification

- [ ] **Step 1**

```bash
melos exec --scope="desk_sdui*" -- dart analyze
melos exec --scope="desk_sdui_generator" -- dart test
```

- [ ] **Step 2: Tag**

```bash
git tag desk_sdui-phase3-complete
```

## Phase 3 Done When

- [ ] Expression lowerer covers every `ExpressionNode` subclass with corresponding analyzer AST shape
- [ ] Widget lowerer handles `InstanceCreationExpression`, const-fold whitelist, named/positional args, `if`/`for`/spread elements in lists
- [ ] Closure lowerer accepts the 5 whitelisted shapes and rejects others with a `LoweringError`
- [ ] `astToIr.lowerScreen` walks an entire `@Screen` body and collects (params, reactive params, method refs, widget refs, fn refs)
- [ ] Const-fold pass replaces purely literal subtrees with `ConstNode`
- [ ] Reactive scope hoisting wraps the LCA of each reactive ref-group in `ReactiveScopeNode`
- [ ] Key inference synthesizes `ValueKey(item.id)` for `ForNode` bodies when feasible; warns otherwise
- [ ] `ir_emitter_dart` produces a compilable `.sdui.g.dart` part file with `ScreenBinding` + bindings
- [ ] `ir_emitter_json` produces a `.uib` byte payload that round-trips through Phase 1's `JsonIrCodec`
- [ ] `ScreenGenerator` integrates all passes
- [ ] `RegistryBuilder` discovers all `@Screen`s and emits `_registerAll`
- [ ] 8 analyzer-plugin lint rules with test coverage
- [ ] End-to-end integration test compiles a fixture consumer
- [ ] All tests pass; analyzer clean
