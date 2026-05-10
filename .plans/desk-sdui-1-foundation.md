# desk_sdui Phase 1 — Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap a new sibling repo `dart_desk_workspace/desk_sdui/` with a melos workspace and three package skeletons, then ship a working `desk_sdui_annotation` package — `@Screen` annotation, the complete node-class hierarchy, and a `JsonIrCodec` with round-trip tests for every node type. CI green at the end.

**Architecture:** A Dart melos workspace with three packages: `desk_sdui_annotation` (pure Dart, no Flutter), `desk_sdui` (Flutter runtime, empty in this phase), and `desk_sdui_generator` (build_runner codegen, empty in this phase). Phase 1 only puts substantive code in `desk_sdui_annotation` — the node definitions and a JSON codec. The other two packages exist as empty pubspec'd skeletons so the dependency edges and CI matrix are wired up early.

**Tech Stack:** Dart 3.5+, Flutter SDK (only for the runtime package's stub `pubspec.yaml`), melos workspace, `very_good_analysis` lints, `test` for unit tests, GitHub Actions for CI.

**Spec reference:** `dart_desk/docs/superpowers/specs/2026-05-10-desk-sdui-design.md` (committed at `95c9fee`).

---

## File Structure

After this phase, the repo layout is:

```
dart_desk_workspace/
└── desk_sdui/                                 ← NEW REPO
    ├── .gitignore
    ├── .github/
    │   └── workflows/
    │       └── ci.yaml                        ← analyze + format + test
    ├── analysis_options.yaml                  ← workspace-wide lints
    ├── melos.yaml                             ← workspace config
    ├── pubspec.yaml                           ← workspace root pubspec
    ├── README.md
    └── packages/
        ├── desk_sdui_annotation/
        │   ├── analysis_options.yaml          ← extends workspace
        │   ├── pubspec.yaml
        │   ├── CHANGELOG.md
        │   ├── README.md
        │   ├── lib/
        │   │   ├── desk_sdui_annotation.dart  ← public exports
        │   │   └── src/
        │   │       ├── annotations.dart       ← @Screen
        │   │       └── ir/
        │   │           ├── ir_node.dart       ← sealed IrNode + WidgetNode, BuiltinWidgetNode, LiteralNode, ConstNode, RefNode, EventNode, ListNode, MapNode, RecordNode, ConditionalNode, ForNode, SpreadNode
        │   │           ├── ir_expression.dart ← sealed ExpressionNode + CompareOp, ArithOp, LogicOp, NotOp, CoalesceOp, MemberAccess, IndexAccess, LengthOf, IsNullCheck, StringInterp
        │   │           ├── compare_op.dart    ← enum (eq, neq, lt, lte, gt, gte)
        │   │           ├── arith_op.dart      ← enum (add, sub, mul, div, mod)
        │   │           ├── logic_op.dart      ← enum (and, or)
        │   │           ├── ir_tree.dart       ← root container with version + root node
        │   │           └── codec/
        │   │               ├── json_ir_codec.dart   ← encode/decode public API
        │   │               ├── json_encoder.dart    ← IrNode → Map<String, Object?>
        │   │               └── json_decoder.dart    ← Map<String, Object?> → IrNode
        │   └── test/
        │       ├── annotations_test.dart
        │       └── ir/
        │           ├── ir_node_test.dart            ← equality, hashCode, toString
        │           ├── ir_expression_test.dart
        │           └── codec/
        │               └── json_ir_codec_round_trip_test.dart  ← every node type round-trips
        ├── desk_sdui/
        │   ├── analysis_options.yaml
        │   ├── pubspec.yaml
        │   ├── CHANGELOG.md
        │   ├── README.md
        │   ├── lib/
        │   │   └── desk_sdui.dart                   ← empty placeholder export
        │   └── test/
        │       └── desk_sdui_test.dart              ← single trivial test so CI has something to run
        └── desk_sdui_generator/
            ├── analysis_options.yaml
            ├── pubspec.yaml
            ├── CHANGELOG.md
            ├── README.md
            ├── lib/
            │   └── desk_sdui_generator.dart         ← empty placeholder export
            └── test/
                └── desk_sdui_generator_test.dart
```

Constraints from spec:
- `desk_sdui_annotation`: pure Dart, depends on `meta` only
- `desk_sdui`: depends on `flutter`, `desk_sdui_annotation`. Must NOT depend on any state-management package.
- `desk_sdui_generator`: depends on `analyzer`, `build`, `source_gen`, `build_runner: ^2.15.0`, `desk_sdui_annotation`. Must NOT use `dart:mirrors`.

---

## Task 1: Bootstrap the repo

**Files:**
- Create directory: `dart_desk_workspace/desk_sdui/`
- Create: `dart_desk_workspace/desk_sdui/.gitignore`
- Create: `dart_desk_workspace/desk_sdui/README.md`

- [ ] **Step 1: Create the repo directory and init git**

```bash
mkdir -p ~/Workspace/dart_desk_workspace/desk_sdui
cd ~/Workspace/dart_desk_workspace/desk_sdui
git init -b main
```

Expected: `Initialized empty Git repository in .../desk_sdui/.git/`

- [ ] **Step 2: Write `.gitignore`**

Create `dart_desk_workspace/desk_sdui/.gitignore` with:

```gitignore
# Dart / Flutter
.dart_tool/
.packages
.pub-cache/
.pub/
build/
pubspec.lock

# IDE
.idea/
.vscode/
*.iml

# OS
.DS_Store
Thumbs.db

# Coverage
coverage/
.test_coverage.dart

# Generated
*.g.dart
*.freezed.dart
```

- [ ] **Step 3: Write top-level `README.md`**

Create `dart_desk_workspace/desk_sdui/README.md`:

```markdown
# desk_sdui

Server-driven UI for Flutter. Author screens as `@Screen` Dart-subset, ship layouts as data, render on device by composing registered native widgets.

This is a melos workspace with three packages:

- **`desk_sdui_annotation`** — `@Screen` annotation and node types. Pure Dart.
- **`desk_sdui`** — runtime that renders the node tree into a Flutter widget tree.
- **`desk_sdui_generator`** — `build_runner` codegen + analyzer plugin.

Design spec: see `dart_desk/docs/superpowers/specs/2026-05-10-desk-sdui-design.md` in the sibling `dart_desk` repo.

## Status

Phase 1 of v1 — foundation only. The annotation package ships the node-class hierarchy and JSON codec; the runtime and generator are empty skeletons.
```

- [ ] **Step 4: Initial commit**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
git add .gitignore README.md
git commit -m "chore: init desk_sdui repo"
```

Expected: `[main (root-commit) ...] chore: init desk_sdui repo`

---

## Task 2: Set up the melos workspace

**Files:**
- Create: `desk_sdui/pubspec.yaml`
- Create: `desk_sdui/melos.yaml`
- Create: `desk_sdui/analysis_options.yaml`

- [ ] **Step 1: Write workspace root `pubspec.yaml`**

Create `desk_sdui/pubspec.yaml`:

```yaml
name: desk_sdui_workspace
publish_to: none

environment:
  sdk: ">=3.5.0 <4.0.0"

dev_dependencies:
  melos: ^6.2.0
```

- [ ] **Step 2: Write `melos.yaml`**

Create `desk_sdui/melos.yaml`:

```yaml
name: desk_sdui

packages:
  - packages/*

command:
  bootstrap:
    runPubGetInParallel: true

scripts:
  analyze:
    description: Run dart analyze on all packages
    run: melos exec --concurrency=1 -- dart analyze --fatal-infos --fatal-warnings

  format:
    description: Verify all Dart files are formatted
    run: melos exec --concurrency=1 -- dart format --output=none --set-exit-if-changed .

  format:apply:
    description: Apply dart format to all packages
    run: melos exec --concurrency=1 -- dart format .

  test:
    description: Run tests in every package that has a test/ dir
    run: melos exec --concurrency=1 --dir-exists=test -- dart test
```

- [ ] **Step 3: Write workspace `analysis_options.yaml`**

Create `desk_sdui/analysis_options.yaml`:

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    public_member_api_docs: false  # not enforced for v1; relax later
    sort_pub_dependencies: false
```

- [ ] **Step 4: Install melos and bootstrap (sanity check — no packages yet, will succeed trivially)**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
dart pub get
```

Expected: `Got dependencies!` (only `melos` itself).

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml melos.yaml analysis_options.yaml
git commit -m "chore: set up melos workspace"
```

---

## Task 3: Scaffold `desk_sdui_annotation` package

**Files:**
- Create: `packages/desk_sdui_annotation/pubspec.yaml`
- Create: `packages/desk_sdui_annotation/analysis_options.yaml`
- Create: `packages/desk_sdui_annotation/CHANGELOG.md`
- Create: `packages/desk_sdui_annotation/README.md`
- Create: `packages/desk_sdui_annotation/lib/desk_sdui_annotation.dart`

- [ ] **Step 1: Write `pubspec.yaml`**

Create `packages/desk_sdui_annotation/pubspec.yaml`:

```yaml
name: desk_sdui_annotation
description: Annotations and node types for desk_sdui — pure Dart, no Flutter.
version: 0.0.1-dev
publish_to: none  # not yet publishing

environment:
  sdk: ">=3.5.0 <4.0.0"

dependencies:
  meta: ^1.16.0

dev_dependencies:
  test: ^1.25.0
  very_good_analysis: ^7.0.0
```

- [ ] **Step 2: Write package `analysis_options.yaml`**

Create `packages/desk_sdui_annotation/analysis_options.yaml`:

```yaml
include: ../../analysis_options.yaml
```

- [ ] **Step 3: Write `CHANGELOG.md`**

Create `packages/desk_sdui_annotation/CHANGELOG.md`:

```markdown
## 0.0.1-dev

- Initial scaffold. `@Screen` annotation and node-class hierarchy.
```

- [ ] **Step 4: Write `README.md`**

Create `packages/desk_sdui_annotation/README.md`:

```markdown
# desk_sdui_annotation

Annotations and node types for [desk_sdui](../desk_sdui). Pure Dart, no Flutter dependency.

## What's here

- `@Screen('name')` — annotation marking a function as an SDUI screen.
- `IrNode` and subclasses — typed intermediate representation of a screen layout.
- `JsonIrCodec` — encode/decode `IrNode` to/from JSON.

This package is consumed by `desk_sdui` (runtime) and `desk_sdui_generator` (codegen).
```

- [ ] **Step 5: Write empty public export**

Create `packages/desk_sdui_annotation/lib/desk_sdui_annotation.dart`:

```dart
/// Annotations and IR types for desk_sdui.
library;

export 'src/annotations.dart';
export 'src/ir/ir_node.dart';
export 'src/ir/ir_expression.dart';
export 'src/ir/ir_tree.dart';
export 'src/ir/compare_op.dart';
export 'src/ir/arith_op.dart';
export 'src/ir/logic_op.dart';
export 'src/ir/codec/json_ir_codec.dart';
```

(The `src/` files don't exist yet — `dart analyze` will fail until they're created in subsequent tasks. That's expected; we'll fix it as we add files.)

- [ ] **Step 6: Bootstrap melos**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
dart pub global activate melos 6.2.0
melos bootstrap
```

Expected: bootstrap succeeds (annotation package's `meta` and `test` deps resolve).

- [ ] **Step 7: Commit**

```bash
git add packages/desk_sdui_annotation/
git commit -m "chore(annotation): scaffold desk_sdui_annotation package"
```

---

## Task 4: Define `@Screen` annotation (TDD)

**Files:**
- Create: `packages/desk_sdui_annotation/lib/src/annotations.dart`
- Create: `packages/desk_sdui_annotation/test/annotations_test.dart`

- [ ] **Step 1: Write the failing test**

Create `packages/desk_sdui_annotation/test/annotations_test.dart`:

```dart
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:test/test.dart';

void main() {
  group('Screen', () {
    test('stores the name', () {
      const annotation = Screen('cart');
      expect(annotation.name, 'cart');
    });

    test('two annotations with same name are equal', () {
      expect(const Screen('home'), const Screen('home'));
      expect(const Screen('home').hashCode, const Screen('home').hashCode);
    });

    test('two annotations with different names are not equal', () {
      expect(const Screen('a') == const Screen('b'), isFalse);
    });

    test('toString includes the name', () {
      expect(const Screen('cart').toString(), contains('cart'));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd packages/desk_sdui_annotation
dart test test/annotations_test.dart
```

Expected: FAIL — file `lib/src/annotations.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

Create `packages/desk_sdui_annotation/lib/src/annotations.dart`:

```dart
import 'package:meta/meta.dart';

/// Marks a function as an SDUI screen. The function's body is lowered to
/// IR by `desk_sdui_generator` at build time.
///
/// The [name] is the screen's identifier — used both in the generated
/// `ScreenBinding` and as the filename stem for the published `.uib` blob.
@immutable
@Target({TargetKind.function, TargetKind.method})
class Screen {
  const Screen(this.name);

  /// Stable identifier for this screen.
  final String name;

  @override
  bool operator ==(Object other) =>
      other is Screen && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Screen($name)';
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/annotations_test.dart
```

Expected: PASS — all four tests green.

- [ ] **Step 5: Run analyzer**

```bash
dart analyze lib/src/annotations.dart test/annotations_test.dart
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
git add packages/desk_sdui_annotation/lib/src/annotations.dart packages/desk_sdui_annotation/test/annotations_test.dart
git commit -m "feat(annotation): add @Screen annotation"
```

---

## Task 5: Define operator enums

Three small enum files used by expression nodes. Doing them first so later tasks can reference them.

**Files:**
- Create: `packages/desk_sdui_annotation/lib/src/ir/compare_op.dart`
- Create: `packages/desk_sdui_annotation/lib/src/ir/arith_op.dart`
- Create: `packages/desk_sdui_annotation/lib/src/ir/logic_op.dart`

- [ ] **Step 1: Write the operator enums**

Create `packages/desk_sdui_annotation/lib/src/ir/compare_op.dart`:

```dart
/// Comparison operators supported in IR expressions.
enum CompareOp { eq, neq, lt, lte, gt, gte }
```

Create `packages/desk_sdui_annotation/lib/src/ir/arith_op.dart`:

```dart
/// Arithmetic operators supported in IR expressions.
enum ArithOp { add, sub, mul, div, mod }
```

Create `packages/desk_sdui_annotation/lib/src/ir/logic_op.dart`:

```dart
/// Logical operators supported in IR expressions.
enum LogicOp { and, or }
```

- [ ] **Step 2: Verify analyzer**

```bash
cd packages/desk_sdui_annotation
dart analyze lib/src/ir/compare_op.dart lib/src/ir/arith_op.dart lib/src/ir/logic_op.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
git add packages/desk_sdui_annotation/lib/src/ir/
git commit -m "feat(annotation): add IR operator enums (CompareOp, ArithOp, LogicOp)"
```

---

## Task 6: Define `IrNode` sealed hierarchy (TDD)

The base class and all non-expression node types. Equality, hashCode, toString tested for each.

**Files:**
- Create: `packages/desk_sdui_annotation/lib/src/ir/ir_node.dart`
- Create: `packages/desk_sdui_annotation/test/ir/ir_node_test.dart`

- [ ] **Step 1: Write failing tests for the full node hierarchy**

Create `packages/desk_sdui_annotation/test/ir/ir_node_test.dart`:

```dart
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:test/test.dart';

void main() {
  group('LiteralNode', () {
    test('equality by value', () {
      expect(const LiteralNode(42), const LiteralNode(42));
      expect(const LiteralNode('a') == const LiteralNode('b'), isFalse);
    });

    test('hashCode by value', () {
      expect(const LiteralNode(true).hashCode, const LiteralNode(true).hashCode);
    });

    test('toString includes value', () {
      expect(const LiteralNode(42).toString(), contains('42'));
    });
  });

  group('RefNode', () {
    test('equality by path and reactive flag', () {
      expect(
        const RefNode(['controller', 'flag']),
        const RefNode(['controller', 'flag']),
      );
      expect(
        const RefNode(['controller', 'flag']) ==
            const RefNode(['controller', 'flag'], reactive: true),
        isFalse,
      );
    });

    test('default reactive is false', () {
      expect(const RefNode(['x']).reactive, isFalse);
    });
  });

  group('EventNode', () {
    test('equality by target and args', () {
      expect(
        const EventNode(['controller', 'foo']),
        const EventNode(['controller', 'foo']),
      );
    });

    test('args defaults to empty', () {
      expect(const EventNode(['controller', 'foo']).args, isEmpty);
    });
  });

  group('WidgetNode', () {
    test('stores name and args', () {
      const node = WidgetNode(name: 'Column', args: {});
      expect(node.name, 'Column');
      expect(node.args, isEmpty);
      expect(node.key, isNull);
    });

    test('reactiveSignals defaults to empty set', () {
      expect(const WidgetNode(name: 'X', args: {}).reactiveSignals, isEmpty);
    });
  });

  group('ConditionalNode', () {
    test('elseBranch is optional', () {
      const node = ConditionalNode(
        condition: LiteralNode(true),
        thenBranch: LiteralNode('y'),
      );
      expect(node.elseBranch, isNull);
    });
  });

  group('ForNode', () {
    test('stores variable, source, body', () {
      const node = ForNode(
        variable: 'item',
        source: RefNode(['xs']),
        body: LiteralNode('x'),
      );
      expect(node.variable, 'item');
    });

    test('destructured form supports two variable names', () {
      const node = ForNode.destructured(
        variables: ['i', 'item'],
        source: RefNode(['xs']),
        body: LiteralNode('x'),
      );
      expect(node.variables, ['i', 'item']);
    });
  });

  group('ListNode and SpreadNode', () {
    test('ListNode equality by children', () {
      expect(
        const ListNode([LiteralNode(1), LiteralNode(2)]),
        const ListNode([LiteralNode(1), LiteralNode(2)]),
      );
    });

    test('SpreadNode wraps a source', () {
      const node = SpreadNode(RefNode(['xs']));
      expect(node.source, isA<RefNode>());
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd packages/desk_sdui_annotation
dart test test/ir/ir_node_test.dart
```

Expected: FAIL — `lib/src/ir/ir_node.dart` not found.

- [ ] **Step 3: Implement `IrNode` and all subclasses**

Create `packages/desk_sdui_annotation/lib/src/ir/ir_node.dart`:

```dart
import 'package:meta/meta.dart';

/// Base class for every IR node. Sealed so the resolver/codegen exhaustively
/// dispatch on subtype.
@immutable
sealed class IrNode {
  const IrNode();
}

/// A literal value. The value must be a const-constructible primitive
/// (bool, int, double, String, null) or a recognized const Dart value type
/// (e.g., `EdgeInsets.all(8)`, `Color(0xFF...)`).
final class LiteralNode extends IrNode {
  const LiteralNode(this.value);

  final Object? value;

  @override
  bool operator ==(Object other) =>
      other is LiteralNode && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'LiteralNode($value)';
}

/// A const-folded subtree. Differs from `LiteralNode` in that its value is
/// a constructed object (a Flutter widget, typically) rather than a scalar.
/// Emitted by the lowerer's const-fold pass.
final class ConstNode extends IrNode {
  const ConstNode(this.value);

  /// The const-constructed value. The codec round-trips this as a typed
  /// reference (it is NOT serialized as a generic value — only the lowerer
  /// knows what const value lives here, encoded as a stable id).
  final Object? value;

  @override
  bool operator ==(Object other) =>
      other is ConstNode && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ConstNode($value)';
}

/// Reads a value from the resolver's input map by walking [path]. If
/// [reactive] is true, the runtime subscribes to the listenable at the
/// resolved value.
final class RefNode extends IrNode {
  const RefNode(this.path, {this.reactive = false});

  final List<String> path;
  final bool reactive;

  @override
  bool operator ==(Object other) =>
      other is RefNode &&
      _listEquals(other.path, path) &&
      other.reactive == reactive;

  @override
  int get hashCode => Object.hash(Object.hashAll(path), reactive);

  @override
  String toString() => 'RefNode($path, reactive: $reactive)';
}

/// Calls a bound method on the resolver's input map. Args are themselves
/// IrNodes (literals, refs, etc.) resolved at call time.
final class EventNode extends IrNode {
  const EventNode(this.target, {this.args = const {}});

  final List<String> target;
  final Map<String, IrNode> args;

  @override
  bool operator ==(Object other) =>
      other is EventNode &&
      _listEquals(other.target, target) &&
      _mapEquals(other.args, args);

  @override
  int get hashCode => Object.hash(Object.hashAll(target), Object.hashAll(args.entries));

  @override
  String toString() => 'EventNode($target, args: $args)';
}

/// A registered widget invocation. [name] is the registered widget id;
/// [args] map argument names to IrNodes; [key] is an optional ValueKey
/// expression. [reactiveSignals] is metadata emitted by the lowerer's
/// reactive-scope-hoisting pass.
final class WidgetNode extends IrNode {
  const WidgetNode({
    required this.name,
    required this.args,
    this.key,
    this.reactiveSignals = const {},
  });

  final String name;
  final Map<String, IrNode> args;
  final IrNode? key;
  final Set<String> reactiveSignals;

  @override
  bool operator ==(Object other) =>
      other is WidgetNode &&
      other.name == name &&
      _mapEquals(other.args, args) &&
      other.key == key &&
      _setEquals(other.reactiveSignals, reactiveSignals);

  @override
  int get hashCode => Object.hash(
        name,
        Object.hashAll(args.entries),
        key,
        Object.hashAll(reactiveSignals),
      );

  @override
  String toString() => 'WidgetNode($name)';
}

/// A built-in widget — same shape as [WidgetNode] but reserved for SDK
/// primitives the runtime ships unconditionally. Distinct subtype so the
/// resolver can fast-path and the codegen can refuse to override builtins.
final class BuiltinWidgetNode extends IrNode {
  const BuiltinWidgetNode({
    required this.name,
    required this.args,
    this.key,
  });

  final String name;
  final Map<String, IrNode> args;
  final IrNode? key;

  @override
  bool operator ==(Object other) =>
      other is BuiltinWidgetNode &&
      other.name == name &&
      _mapEquals(other.args, args) &&
      other.key == key;

  @override
  int get hashCode => Object.hash(name, Object.hashAll(args.entries), key);

  @override
  String toString() => 'BuiltinWidgetNode($name)';
}

/// A list of IrNodes. Used inside `args` slots that take child lists.
final class ListNode extends IrNode {
  const ListNode(this.children);

  final List<IrNode> children;

  @override
  bool operator ==(Object other) =>
      other is ListNode && _listEquals(other.children, children);

  @override
  int get hashCode => Object.hashAll(children);

  @override
  String toString() => 'ListNode(${children.length} items)';
}

/// Map literal in the IR (rare; mostly for typed constructor args like
/// `style: TextStyle(...)`).
final class MapNode extends IrNode {
  const MapNode(this.entries);

  final Map<IrNode, IrNode> entries;

  @override
  bool operator ==(Object other) =>
      other is MapNode && _mapEquals(other.entries, entries);

  @override
  int get hashCode => Object.hashAll(entries.entries);

  @override
  String toString() => 'MapNode(${entries.length} entries)';
}

/// Dart record literal in the IR (positional + named fields).
final class RecordNode extends IrNode {
  const RecordNode({
    this.positional = const [],
    this.named = const {},
  });

  final List<IrNode> positional;
  final Map<String, IrNode> named;

  @override
  bool operator ==(Object other) =>
      other is RecordNode &&
      _listEquals(other.positional, positional) &&
      _mapEquals(other.named, named);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(positional),
        Object.hashAll(named.entries),
      );

  @override
  String toString() => 'RecordNode(positional: $positional, named: $named)';
}

/// `if (cond) then else else?` and ternary `cond ? then : else`.
final class ConditionalNode extends IrNode {
  const ConditionalNode({
    required this.condition,
    required this.thenBranch,
    this.elseBranch,
  });

  final IrNode condition;
  final IrNode thenBranch;
  final IrNode? elseBranch;

  @override
  bool operator ==(Object other) =>
      other is ConditionalNode &&
      other.condition == condition &&
      other.thenBranch == thenBranch &&
      other.elseBranch == elseBranch;

  @override
  int get hashCode => Object.hash(condition, thenBranch, elseBranch);

  @override
  String toString() =>
      'ConditionalNode($condition ? $thenBranch : $elseBranch)';
}

/// `for (final x in xs) body` — single-variable form.
/// `for (final (i, x) in xs.indexed) body` — destructured form (use
/// [ForNode.destructured]).
final class ForNode extends IrNode {
  const ForNode({
    required String this.variable,
    required this.source,
    required this.body,
  }) : variables = null;

  const ForNode.destructured({
    required List<String> this.variables,
    required this.source,
    required this.body,
  }) : variable = null;

  final String? variable;
  final List<String>? variables;
  final IrNode source;
  final IrNode body;

  @override
  bool operator ==(Object other) =>
      other is ForNode &&
      other.variable == variable &&
      _listEquals(other.variables, variables) &&
      other.source == source &&
      other.body == body;

  @override
  int get hashCode => Object.hash(
        variable,
        variables == null ? null : Object.hashAll(variables!),
        source,
        body,
      );

  @override
  String toString() {
    final v = variable ?? variables;
    return 'ForNode($v in $source)';
  }
}

/// `...somelist` inside a list literal.
final class SpreadNode extends IrNode {
  const SpreadNode(this.source);

  final IrNode source;

  @override
  bool operator ==(Object other) =>
      other is SpreadNode && other.source == source;

  @override
  int get hashCode => source.hashCode;

  @override
  String toString() => 'SpreadNode($source)';
}

// ───────────────────────────── helpers ─────────────────────────────

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key)) return false;
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}

bool _setEquals<T>(Set<T>? a, Set<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final item in a) {
    if (!b.contains(item)) return false;
  }
  return true;
}
```

(`ir_node.dart` does not reference any expression types directly — those are added in Task 7. The public-surface export in `desk_sdui_annotation.dart` ties them together.)

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd packages/desk_sdui_annotation
dart test test/ir/ir_node_test.dart
```

Expected: PASS — all groups green.

- [ ] **Step 5: Run analyzer**

```bash
dart analyze lib/src/ir/ir_node.dart
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
git add packages/desk_sdui_annotation/lib/src/ir/ir_node.dart packages/desk_sdui_annotation/test/ir/ir_node_test.dart
git commit -m "feat(annotation): add IrNode sealed hierarchy"
```

---

## Task 7: Define `ExpressionNode` sealed hierarchy (TDD)

**Files:**
- Create: `packages/desk_sdui_annotation/lib/src/ir/ir_expression.dart`
- Create: `packages/desk_sdui_annotation/test/ir/ir_expression_test.dart`

- [ ] **Step 1: Write failing tests**

Create `packages/desk_sdui_annotation/test/ir/ir_expression_test.dart`:

```dart
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:test/test.dart';

void main() {
  group('CompareOpNode', () {
    test('equality by op and operands', () {
      const a = CompareOpNode(
        op: CompareOp.gte,
        left: LiteralNode(50),
        right: LiteralNode(100),
      );
      const b = CompareOpNode(
        op: CompareOp.gte,
        left: LiteralNode(50),
        right: LiteralNode(100),
      );
      expect(a, b);
    });

    test('different ops are not equal', () {
      const a = CompareOpNode(
        op: CompareOp.gte,
        left: LiteralNode(1),
        right: LiteralNode(2),
      );
      const b = CompareOpNode(
        op: CompareOp.gt,
        left: LiteralNode(1),
        right: LiteralNode(2),
      );
      expect(a == b, isFalse);
    });
  });

  group('ArithOpNode', () {
    test('stores op and operands', () {
      const node = ArithOpNode(
        op: ArithOp.add,
        left: LiteralNode(1),
        right: LiteralNode(2),
      );
      expect(node.op, ArithOp.add);
    });
  });

  group('LogicOpNode', () {
    test('and/or distinguished', () {
      const a = LogicOpNode(
        op: LogicOp.and,
        left: LiteralNode(true),
        right: LiteralNode(false),
      );
      const b = LogicOpNode(
        op: LogicOp.or,
        left: LiteralNode(true),
        right: LiteralNode(false),
      );
      expect(a == b, isFalse);
    });
  });

  group('NotOpNode', () {
    test('wraps an operand', () {
      const node = NotOpNode(LiteralNode(true));
      expect(node.operand, const LiteralNode(true));
    });
  });

  group('CoalesceOpNode', () {
    test('a ?? b structure', () {
      const node = CoalesceOpNode(
        left: RefNode(['x']),
        right: LiteralNode('default'),
      );
      expect(node.left, isA<RefNode>());
    });
  });

  group('MemberAccessNode', () {
    test('a.b structure', () {
      const node = MemberAccessNode(
        target: RefNode(['data']),
        name: 'title',
      );
      expect(node.name, 'title');
    });
  });

  group('IndexAccessNode', () {
    test('a[k] structure', () {
      const node = IndexAccessNode(
        target: RefNode(['xs']),
        key: LiteralNode(0),
      );
      expect(node.key, isA<LiteralNode>());
    });
  });

  group('LengthOfNode', () {
    test('xs.length structure', () {
      const node = LengthOfNode(RefNode(['xs']));
      expect(node.target, isA<RefNode>());
    });
  });

  group('IsNullCheckNode', () {
    test('a == null structure', () {
      const node = IsNullCheckNode(RefNode(['a']));
      expect(node.operand, isA<RefNode>());
    });
  });

  group('StringInterpNode', () {
    test('parts list of mixed string/IrNode', () {
      const node = StringInterpNode([LiteralNode('hello '), RefNode(['name'])]);
      expect(node.parts.length, 2);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd packages/desk_sdui_annotation
dart test test/ir/ir_expression_test.dart
```

Expected: FAIL — `lib/src/ir/ir_expression.dart` not found.

- [ ] **Step 3: Implement expression nodes**

Create `packages/desk_sdui_annotation/lib/src/ir/ir_expression.dart`:

```dart
import 'package:meta/meta.dart';

import 'arith_op.dart';
import 'compare_op.dart';
import 'ir_node.dart';
import 'logic_op.dart';

/// Base for IR expression nodes (Tier 1 — pre-built AST, evaluated by the
/// runtime in O(1) per node via sealed-switch).
@immutable
sealed class ExpressionNode extends IrNode {
  const ExpressionNode();
}

/// `a == b`, `a != b`, `<`, `<=`, `>`, `>=` — the [op] selects which.
final class CompareOpNode extends ExpressionNode {
  const CompareOpNode({
    required this.op,
    required this.left,
    required this.right,
  });

  final CompareOp op;
  final IrNode left;
  final IrNode right;

  @override
  bool operator ==(Object other) =>
      other is CompareOpNode &&
      other.op == op &&
      other.left == left &&
      other.right == right;

  @override
  int get hashCode => Object.hash(op, left, right);

  @override
  String toString() => 'CompareOpNode($left ${op.name} $right)';
}

/// `+`, `-`, `*`, `/`, `%`.
final class ArithOpNode extends ExpressionNode {
  const ArithOpNode({
    required this.op,
    required this.left,
    required this.right,
  });

  final ArithOp op;
  final IrNode left;
  final IrNode right;

  @override
  bool operator ==(Object other) =>
      other is ArithOpNode &&
      other.op == op &&
      other.left == left &&
      other.right == right;

  @override
  int get hashCode => Object.hash(op, left, right);

  @override
  String toString() => 'ArithOpNode($left ${op.name} $right)';
}

/// `&&`, `||`.
final class LogicOpNode extends ExpressionNode {
  const LogicOpNode({
    required this.op,
    required this.left,
    required this.right,
  });

  final LogicOp op;
  final IrNode left;
  final IrNode right;

  @override
  bool operator ==(Object other) =>
      other is LogicOpNode &&
      other.op == op &&
      other.left == left &&
      other.right == right;

  @override
  int get hashCode => Object.hash(op, left, right);

  @override
  String toString() => 'LogicOpNode($left ${op.name} $right)';
}

/// `!operand`.
final class NotOpNode extends ExpressionNode {
  const NotOpNode(this.operand);

  final IrNode operand;

  @override
  bool operator ==(Object other) =>
      other is NotOpNode && other.operand == operand;

  @override
  int get hashCode => operand.hashCode;

  @override
  String toString() => 'NotOpNode(!$operand)';
}

/// `a ?? b`.
final class CoalesceOpNode extends ExpressionNode {
  const CoalesceOpNode({
    required this.left,
    required this.right,
  });

  final IrNode left;
  final IrNode right;

  @override
  bool operator ==(Object other) =>
      other is CoalesceOpNode &&
      other.left == left &&
      other.right == right;

  @override
  int get hashCode => Object.hash(left, right);

  @override
  String toString() => 'CoalesceOpNode($left ?? $right)';
}

/// `a.b` — accesses a property on the target.
final class MemberAccessNode extends ExpressionNode {
  const MemberAccessNode({
    required this.target,
    required this.name,
  });

  final IrNode target;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is MemberAccessNode &&
      other.target == target &&
      other.name == name;

  @override
  int get hashCode => Object.hash(target, name);

  @override
  String toString() => 'MemberAccessNode($target.$name)';
}

/// `a[k]` — index lookup (List, Map, etc.).
final class IndexAccessNode extends ExpressionNode {
  const IndexAccessNode({
    required this.target,
    required this.key,
  });

  final IrNode target;
  final IrNode key;

  @override
  bool operator ==(Object other) =>
      other is IndexAccessNode &&
      other.target == target &&
      other.key == key;

  @override
  int get hashCode => Object.hash(target, key);

  @override
  String toString() => 'IndexAccessNode($target[$key])';
}

/// `xs.length` — kept as its own node because length is so common and cheap
/// to special-case at runtime.
final class LengthOfNode extends ExpressionNode {
  const LengthOfNode(this.target);

  final IrNode target;

  @override
  bool operator ==(Object other) =>
      other is LengthOfNode && other.target == target;

  @override
  int get hashCode => target.hashCode;

  @override
  String toString() => 'LengthOfNode($target.length)';
}

/// `a == null` — separate from CompareOpNode because the runtime fast-paths
/// null checks without unboxing.
final class IsNullCheckNode extends ExpressionNode {
  const IsNullCheckNode(this.operand);

  final IrNode operand;

  @override
  bool operator ==(Object other) =>
      other is IsNullCheckNode && other.operand == operand;

  @override
  int get hashCode => operand.hashCode;

  @override
  String toString() => 'IsNullCheckNode($operand == null)';
}

/// `'hello $name!'` — parts is an alternating list of `String` literals and
/// `IrNode`s for the interpolation slots.
final class StringInterpNode extends ExpressionNode {
  const StringInterpNode(this.parts);

  /// Each element is either a `String` (literal text) or an `IrNode`
  /// (an interpolation slot).
  final List<Object> parts;

  @override
  bool operator ==(Object other) =>
      other is StringInterpNode &&
      _partsEquals(other.parts, parts);

  @override
  int get hashCode => Object.hashAll(parts);

  @override
  String toString() => 'StringInterpNode(${parts.length} parts)';
}

bool _partsEquals(List<Object> a, List<Object> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
dart test test/ir/ir_expression_test.dart
```

Expected: PASS.

- [ ] **Step 5: Run analyzer on full package**

```bash
dart analyze
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
git add packages/desk_sdui_annotation/lib/src/ir/ir_expression.dart packages/desk_sdui_annotation/test/ir/ir_expression_test.dart
git commit -m "feat(annotation): add ExpressionNode sealed hierarchy"
```

---

## Task 8: Define `IrTree` container

A small wrapper around the root `IrNode` carrying a version int and the screen name.

**Files:**
- Create: `packages/desk_sdui_annotation/lib/src/ir/ir_tree.dart`

- [ ] **Step 1: Implement `IrTree`**

Create `packages/desk_sdui_annotation/lib/src/ir/ir_tree.dart`:

```dart
import 'package:meta/meta.dart';

import 'ir_node.dart';

/// Root container for a full screen's IR. Carries the screen's identifier,
/// a schema version (used to gate runtime compatibility), and the root node.
@immutable
class IrTree {
  const IrTree({
    required this.name,
    required this.version,
    required this.root,
  });

  /// Stable identifier (matches the `@Screen('...')` argument).
  final String name;

  /// Schema version. Bumped when the IR shape changes incompatibly.
  /// Runtime refuses to load a tree whose [version] is newer than what it
  /// supports.
  final int version;

  /// The screen's root node.
  final IrNode root;

  @override
  bool operator ==(Object other) =>
      other is IrTree &&
      other.name == name &&
      other.version == version &&
      other.root == root;

  @override
  int get hashCode => Object.hash(name, version, root);

  @override
  String toString() => 'IrTree($name, v$version)';
}

/// Current IR schema version. Bump when adding/changing nodes incompatibly.
const int currentIrVersion = 1;
```

- [ ] **Step 2: Run analyzer**

```bash
cd packages/desk_sdui_annotation
dart analyze lib/src/ir/ir_tree.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
git add packages/desk_sdui_annotation/lib/src/ir/ir_tree.dart
git commit -m "feat(annotation): add IrTree container with version"
```

---

## Task 9: JSON encoder (TDD per node type)

Encodes an `IrNode` to a `Map<String, Object?>`. Each node type is tagged
with a discriminator key (`$type`) and serializes its fields as a flat map.

**Files:**
- Create: `packages/desk_sdui_annotation/lib/src/ir/codec/json_encoder.dart`
- Test continues in Task 11 (round-trip test exercises this).

- [ ] **Step 1: Implement encoder using sealed-switch**

Create `packages/desk_sdui_annotation/lib/src/ir/codec/json_encoder.dart`:

```dart
import '../ir_expression.dart';
import '../ir_node.dart';

/// Encodes an IR tree to JSON-serializable maps. Every node carries a
/// `$type` discriminator. Constructors (e.g., `EdgeInsets.all(8)`) encoded
/// as `LiteralNode` values are NOT supported by this codec — only scalars
/// (bool/int/double/String/null). Constructed-value `LiteralNode`s and
/// `ConstNode`s use a stable string id resolved by the runtime registry.
class JsonIrEncoder {
  const JsonIrEncoder();

  Map<String, Object?> encode(IrNode node) => _encodeNode(node);

  Map<String, Object?> _encodeNode(IrNode node) {
    return switch (node) {
      LiteralNode() => {
          r'$type': 'literal',
          'value': _encodeScalar(node.value),
        },
      ConstNode() => {
          r'$type': 'const',
          'id': _requireConstId(node.value),
        },
      RefNode() => {
          r'$type': 'ref',
          'path': node.path,
          if (node.reactive) 'reactive': true,
        },
      EventNode() => {
          r'$type': 'event',
          'target': node.target,
          if (node.args.isNotEmpty)
            'args': node.args.map((k, v) => MapEntry(k, _encodeNode(v))),
        },
      WidgetNode() => {
          r'$type': 'widget',
          'name': node.name,
          'args': node.args.map((k, v) => MapEntry(k, _encodeNode(v))),
          if (node.key != null) 'key': _encodeNode(node.key!),
          if (node.reactiveSignals.isNotEmpty)
            'reactiveSignals': node.reactiveSignals.toList(),
        },
      BuiltinWidgetNode() => {
          r'$type': 'builtin',
          'name': node.name,
          'args': node.args.map((k, v) => MapEntry(k, _encodeNode(v))),
          if (node.key != null) 'key': _encodeNode(node.key!),
        },
      ListNode() => {
          r'$type': 'list',
          'children': node.children.map(_encodeNode).toList(),
        },
      MapNode() => {
          r'$type': 'map',
          'entries': node.entries.entries
              .map((e) => [_encodeNode(e.key), _encodeNode(e.value)])
              .toList(),
        },
      RecordNode() => {
          r'$type': 'record',
          if (node.positional.isNotEmpty)
            'positional': node.positional.map(_encodeNode).toList(),
          if (node.named.isNotEmpty)
            'named': node.named.map((k, v) => MapEntry(k, _encodeNode(v))),
        },
      ConditionalNode() => {
          r'$type': 'cond',
          'condition': _encodeNode(node.condition),
          'then': _encodeNode(node.thenBranch),
          if (node.elseBranch != null) 'else': _encodeNode(node.elseBranch!),
        },
      ForNode() => {
          r'$type': 'for',
          if (node.variable != null) 'variable': node.variable,
          if (node.variables != null) 'variables': node.variables,
          'source': _encodeNode(node.source),
          'body': _encodeNode(node.body),
        },
      SpreadNode() => {
          r'$type': 'spread',
          'source': _encodeNode(node.source),
        },
      CompareOpNode() => {
          r'$type': 'cmp',
          'op': node.op.name,
          'left': _encodeNode(node.left),
          'right': _encodeNode(node.right),
        },
      ArithOpNode() => {
          r'$type': 'arith',
          'op': node.op.name,
          'left': _encodeNode(node.left),
          'right': _encodeNode(node.right),
        },
      LogicOpNode() => {
          r'$type': 'logic',
          'op': node.op.name,
          'left': _encodeNode(node.left),
          'right': _encodeNode(node.right),
        },
      NotOpNode() => {
          r'$type': 'not',
          'operand': _encodeNode(node.operand),
        },
      CoalesceOpNode() => {
          r'$type': 'coalesce',
          'left': _encodeNode(node.left),
          'right': _encodeNode(node.right),
        },
      MemberAccessNode() => {
          r'$type': 'member',
          'target': _encodeNode(node.target),
          'name': node.name,
        },
      IndexAccessNode() => {
          r'$type': 'index',
          'target': _encodeNode(node.target),
          'key': _encodeNode(node.key),
        },
      LengthOfNode() => {
          r'$type': 'length',
          'target': _encodeNode(node.target),
        },
      IsNullCheckNode() => {
          r'$type': 'isnull',
          'operand': _encodeNode(node.operand),
        },
      StringInterpNode() => {
          r'$type': 'interp',
          'parts': node.parts
              .map<Object?>(
                (p) => p is String ? p : _encodeNode(p as IrNode),
              )
              .toList(),
        },
    };
  }

  Object? _encodeScalar(Object? value) {
    if (value == null) return null;
    if (value is bool || value is num || value is String) return value;
    throw UnsupportedError(
      'JsonIrEncoder only handles scalar LiteralNode values '
      '(bool/num/String/null). Use ConstNode for constructed values. '
      'Got: ${value.runtimeType}',
    );
  }

  String _requireConstId(Object? value) {
    throw UnimplementedError(
      'ConstNode JSON encoding requires a stable id resolved by the runtime '
      'registry. v1 const-fold pass uses Dart-literal output only; the wire '
      'format does not yet support ConstNode. Lower without const-folding '
      'when emitting .uib until the const id system lands in Phase 2.',
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
cd packages/desk_sdui_annotation
dart analyze lib/src/ir/codec/json_encoder.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit (no test yet — round-trip test exercises this in Task 11)**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
git add packages/desk_sdui_annotation/lib/src/ir/codec/json_encoder.dart
git commit -m "feat(annotation): add JsonIrEncoder"
```

---

## Task 10: JSON decoder

Mirrors the encoder. Each `$type` discriminator dispatches to a node
constructor.

**Files:**
- Create: `packages/desk_sdui_annotation/lib/src/ir/codec/json_decoder.dart`

- [ ] **Step 1: Implement decoder**

Create `packages/desk_sdui_annotation/lib/src/ir/codec/json_decoder.dart`:

```dart
import '../arith_op.dart';
import '../compare_op.dart';
import '../ir_expression.dart';
import '../ir_node.dart';
import '../logic_op.dart';

class JsonIrDecoder {
  const JsonIrDecoder();

  IrNode decode(Map<String, Object?> map) => _decodeNode(map);

  IrNode _decodeNode(Map<String, Object?> map) {
    final type = map[r'$type'] as String?;
    if (type == null) {
      throw FormatException('IR node missing \$type discriminator: $map');
    }
    return switch (type) {
      'literal' => LiteralNode(map['value']),
      'const' => throw UnimplementedError(
          'ConstNode JSON decoding not supported in Phase 1; '
          'lower without const-folding for .uib output.',
        ),
      'ref' => RefNode(
          (map['path']! as List).cast<String>(),
          reactive: map['reactive'] as bool? ?? false,
        ),
      'event' => EventNode(
          (map['target']! as List).cast<String>(),
          args: _decodeNamedArgs(map['args']),
        ),
      'widget' => WidgetNode(
          name: map['name']! as String,
          args: _decodeNamedArgs(map['args']),
          key: _decodeOptional(map['key']),
          reactiveSignals: ((map['reactiveSignals'] as List?) ?? const [])
              .cast<String>()
              .toSet(),
        ),
      'builtin' => BuiltinWidgetNode(
          name: map['name']! as String,
          args: _decodeNamedArgs(map['args']),
          key: _decodeOptional(map['key']),
        ),
      'list' => ListNode(
          ((map['children']! as List).cast<Map<String, Object?>>())
              .map(_decodeNode)
              .toList(),
        ),
      'map' => MapNode(
          {
            for (final entry
                in (map['entries']! as List).cast<List<Object?>>())
              _decodeNode(entry[0]! as Map<String, Object?>):
                  _decodeNode(entry[1]! as Map<String, Object?>),
          },
        ),
      'record' => RecordNode(
          positional: ((map['positional'] as List?) ?? const [])
              .cast<Map<String, Object?>>()
              .map(_decodeNode)
              .toList(),
          named: _decodeNamedArgs(map['named']),
        ),
      'cond' => ConditionalNode(
          condition: _decodeNode(map['condition']! as Map<String, Object?>),
          thenBranch: _decodeNode(map['then']! as Map<String, Object?>),
          elseBranch: _decodeOptional(map['else']),
        ),
      'for' => _decodeFor(map),
      'spread' => SpreadNode(
          _decodeNode(map['source']! as Map<String, Object?>),
        ),
      'cmp' => CompareOpNode(
          op: CompareOp.values.byName(map['op']! as String),
          left: _decodeNode(map['left']! as Map<String, Object?>),
          right: _decodeNode(map['right']! as Map<String, Object?>),
        ),
      'arith' => ArithOpNode(
          op: ArithOp.values.byName(map['op']! as String),
          left: _decodeNode(map['left']! as Map<String, Object?>),
          right: _decodeNode(map['right']! as Map<String, Object?>),
        ),
      'logic' => LogicOpNode(
          op: LogicOp.values.byName(map['op']! as String),
          left: _decodeNode(map['left']! as Map<String, Object?>),
          right: _decodeNode(map['right']! as Map<String, Object?>),
        ),
      'not' => NotOpNode(
          _decodeNode(map['operand']! as Map<String, Object?>),
        ),
      'coalesce' => CoalesceOpNode(
          left: _decodeNode(map['left']! as Map<String, Object?>),
          right: _decodeNode(map['right']! as Map<String, Object?>),
        ),
      'member' => MemberAccessNode(
          target: _decodeNode(map['target']! as Map<String, Object?>),
          name: map['name']! as String,
        ),
      'index' => IndexAccessNode(
          target: _decodeNode(map['target']! as Map<String, Object?>),
          key: _decodeNode(map['key']! as Map<String, Object?>),
        ),
      'length' => LengthOfNode(
          _decodeNode(map['target']! as Map<String, Object?>),
        ),
      'isnull' => IsNullCheckNode(
          _decodeNode(map['operand']! as Map<String, Object?>),
        ),
      'interp' => StringInterpNode(
          (map['parts']! as List).map<Object>((p) {
            if (p is String) return p;
            return _decodeNode(p! as Map<String, Object?>);
          }).toList(),
        ),
      _ => throw FormatException('Unknown IR node type: $type'),
    };
  }

  IrNode _decodeFor(Map<String, Object?> map) {
    final source = _decodeNode(map['source']! as Map<String, Object?>);
    final body = _decodeNode(map['body']! as Map<String, Object?>);
    final variable = map['variable'] as String?;
    final variables = (map['variables'] as List?)?.cast<String>();
    if (variable != null) {
      return ForNode(variable: variable, source: source, body: body);
    }
    if (variables != null) {
      return ForNode.destructured(
        variables: variables,
        source: source,
        body: body,
      );
    }
    throw FormatException(
      'ForNode requires either "variable" or "variables": $map',
    );
  }

  Map<String, IrNode> _decodeNamedArgs(Object? raw) {
    if (raw == null) return const {};
    final map = raw as Map<String, Object?>;
    return map.map((k, v) =>
        MapEntry(k, _decodeNode(v! as Map<String, Object?>)));
  }

  IrNode? _decodeOptional(Object? raw) {
    if (raw == null) return null;
    return _decodeNode(raw as Map<String, Object?>);
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
cd packages/desk_sdui_annotation
dart analyze lib/src/ir/codec/json_decoder.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
git add packages/desk_sdui_annotation/lib/src/ir/codec/json_decoder.dart
git commit -m "feat(annotation): add JsonIrDecoder"
```

---

## Task 11: `JsonIrCodec` public API + round-trip test (TDD)

The public surface plus a round-trip test that exercises every node type.

**Files:**
- Create: `packages/desk_sdui_annotation/lib/src/ir/codec/json_ir_codec.dart`
- Create: `packages/desk_sdui_annotation/test/ir/codec/json_ir_codec_round_trip_test.dart`

- [ ] **Step 1: Write the failing round-trip test**

Create `packages/desk_sdui_annotation/test/ir/codec/json_ir_codec_round_trip_test.dart`:

```dart
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:test/test.dart';

void main() {
  const codec = JsonIrCodec();

  void roundTrip(IrNode node) {
    final encoded = codec.encode(node);
    final decoded = codec.decode(encoded);
    expect(decoded, equals(node), reason: 'round-trip failed for $node');
  }

  group('JsonIrCodec round-trip', () {
    test('LiteralNode (bool/int/double/String/null)', () {
      roundTrip(const LiteralNode(true));
      roundTrip(const LiteralNode(42));
      roundTrip(const LiteralNode(3.14));
      roundTrip(const LiteralNode('hello'));
      roundTrip(const LiteralNode(null));
    });

    test('RefNode', () {
      roundTrip(const RefNode(['data', 'title']));
      roundTrip(const RefNode(['controller', 'flag'], reactive: true));
    });

    test('EventNode without args', () {
      roundTrip(const EventNode(['controller', 'foo']));
    });

    test('EventNode with args', () {
      roundTrip(const EventNode(
        ['controller', 'removeItem'],
        args: {'arg0': RefNode(['item', 'id'])},
      ));
    });

    test('WidgetNode', () {
      roundTrip(const WidgetNode(
        name: 'Text',
        args: {'data': LiteralNode('hi')},
      ));
      roundTrip(const WidgetNode(
        name: 'ItemTile',
        args: {'item': RefNode(['item'])},
        key: RefNode(['item', 'id']),
        reactiveSignals: {'controller.flag'},
      ));
    });

    test('BuiltinWidgetNode', () {
      roundTrip(const BuiltinWidgetNode(
        name: 'SizedBox',
        args: {'height': LiteralNode(8)},
      ));
    });

    test('ListNode and SpreadNode', () {
      roundTrip(const ListNode([
        LiteralNode(1),
        LiteralNode(2),
        SpreadNode(RefNode(['xs'])),
      ]));
    });

    test('MapNode', () {
      roundTrip(const MapNode({
        LiteralNode('a'): LiteralNode(1),
        LiteralNode('b'): LiteralNode(2),
      }));
    });

    test('RecordNode', () {
      roundTrip(const RecordNode(
        positional: [LiteralNode(1), LiteralNode(2)],
        named: {'foo': LiteralNode('bar')},
      ));
    });

    test('ConditionalNode', () {
      roundTrip(const ConditionalNode(
        condition: LiteralNode(true),
        thenBranch: LiteralNode('y'),
        elseBranch: LiteralNode('n'),
      ));
      roundTrip(const ConditionalNode(
        condition: LiteralNode(false),
        thenBranch: LiteralNode('y'),
      ));
    });

    test('ForNode (single variable)', () {
      roundTrip(const ForNode(
        variable: 'item',
        source: RefNode(['xs']),
        body: LiteralNode('x'),
      ));
    });

    test('ForNode (destructured)', () {
      roundTrip(const ForNode.destructured(
        variables: ['i', 'item'],
        source: RefNode(['xs']),
        body: LiteralNode('x'),
      ));
    });

    test('CompareOpNode', () {
      for (final op in CompareOp.values) {
        roundTrip(CompareOpNode(
          op: op,
          left: const LiteralNode(1),
          right: const LiteralNode(2),
        ));
      }
    });

    test('ArithOpNode', () {
      for (final op in ArithOp.values) {
        roundTrip(ArithOpNode(
          op: op,
          left: const LiteralNode(1),
          right: const LiteralNode(2),
        ));
      }
    });

    test('LogicOpNode', () {
      for (final op in LogicOp.values) {
        roundTrip(LogicOpNode(
          op: op,
          left: const LiteralNode(true),
          right: const LiteralNode(false),
        ));
      }
    });

    test('NotOpNode', () {
      roundTrip(const NotOpNode(LiteralNode(true)));
    });

    test('CoalesceOpNode', () {
      roundTrip(const CoalesceOpNode(
        left: RefNode(['x']),
        right: LiteralNode('default'),
      ));
    });

    test('MemberAccessNode', () {
      roundTrip(const MemberAccessNode(
        target: RefNode(['data']),
        name: 'title',
      ));
    });

    test('IndexAccessNode', () {
      roundTrip(const IndexAccessNode(
        target: RefNode(['xs']),
        key: LiteralNode(0),
      ));
    });

    test('LengthOfNode', () {
      roundTrip(const LengthOfNode(RefNode(['xs'])));
    });

    test('IsNullCheckNode', () {
      roundTrip(const IsNullCheckNode(RefNode(['a'])));
    });

    test('StringInterpNode', () {
      roundTrip(const StringInterpNode([
        'hello ',
        RefNode(['name']),
        '!',
      ]));
    });

    test('encode rejects non-scalar LiteralNode value', () {
      expect(
        () => codec.encode(const LiteralNode(<String>['not a scalar'])),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('decode rejects unknown \$type', () {
      expect(
        () => codec.decode({r'$type': 'bogus'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('decode rejects missing \$type', () {
      expect(
        () => codec.decode({'value': 1}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('JsonIrCodec.encodeTree / decodeTree', () {
    test('round-trips an IrTree', () {
      const tree = IrTree(
        name: 'cart',
        version: 1,
        root: WidgetNode(
          name: 'Column',
          args: {
            'children': ListNode([
              WidgetNode(
                name: 'Text',
                args: {'data': LiteralNode('hi')},
              ),
            ]),
          },
        ),
      );
      final encoded = codec.encodeTree(tree);
      final decoded = codec.decodeTree(encoded);
      expect(decoded, equals(tree));
    });

    test('decodeTree rejects future schema version', () {
      const futureTree = {
        'name': 'x',
        'version': 9999,
        'root': {r'$type': 'literal', 'value': null},
      };
      expect(
        () => codec.decodeTree(futureTree),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd packages/desk_sdui_annotation
dart test test/ir/codec/json_ir_codec_round_trip_test.dart
```

Expected: FAIL — `JsonIrCodec` not found.

- [ ] **Step 3: Implement `JsonIrCodec`**

Create `packages/desk_sdui_annotation/lib/src/ir/codec/json_ir_codec.dart`:

```dart
import '../ir_node.dart';
import '../ir_tree.dart';
import 'json_decoder.dart';
import 'json_encoder.dart';

/// Public codec API. Wraps [JsonIrEncoder] and [JsonIrDecoder] and adds
/// `IrTree`-level encoding with version checks.
class JsonIrCodec {
  const JsonIrCodec();

  static const _encoder = JsonIrEncoder();
  static const _decoder = JsonIrDecoder();

  /// Encode a single IR node to a JSON-serializable map.
  Map<String, Object?> encode(IrNode node) => _encoder.encode(node);

  /// Decode a single IR node from a JSON-deserialized map.
  IrNode decode(Map<String, Object?> map) => _decoder.decode(map);

  /// Encode a full screen tree (with version + name).
  Map<String, Object?> encodeTree(IrTree tree) => {
        'name': tree.name,
        'version': tree.version,
        'root': _encoder.encode(tree.root),
      };

  /// Decode a full screen tree. Throws [FormatException] if the version is
  /// newer than [currentIrVersion] (forward compatibility is opt-in only).
  IrTree decodeTree(Map<String, Object?> map) {
    final name = map['name']! as String;
    final version = map['version']! as int;
    if (version > currentIrVersion) {
      throw FormatException(
        'IR version $version is newer than runtime supports '
        '($currentIrVersion). Upgrade desk_sdui or republish with an '
        'older schema.',
      );
    }
    final root = _decoder.decode(map['root']! as Map<String, Object?>);
    return IrTree(name: name, version: version, root: root);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/ir/codec/json_ir_codec_round_trip_test.dart
```

Expected: PASS — every group green.

- [ ] **Step 5: Run full package test suite**

```bash
dart test
```

Expected: all tests in `desk_sdui_annotation` pass.

- [ ] **Step 6: Run analyzer on full package**

```bash
dart analyze
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
git add packages/desk_sdui_annotation/lib/src/ir/codec/json_ir_codec.dart packages/desk_sdui_annotation/test/ir/codec/json_ir_codec_round_trip_test.dart
git commit -m "feat(annotation): add JsonIrCodec with full round-trip coverage"
```

---

## Task 12: Scaffold `desk_sdui` (runtime) skeleton

Empty Flutter package — exists so dependency edges and CI matrix work. No
substantive code yet; that's Phase 2.

**Files:**
- Create: `packages/desk_sdui/pubspec.yaml`
- Create: `packages/desk_sdui/analysis_options.yaml`
- Create: `packages/desk_sdui/CHANGELOG.md`
- Create: `packages/desk_sdui/README.md`
- Create: `packages/desk_sdui/lib/desk_sdui.dart`
- Create: `packages/desk_sdui/test/desk_sdui_test.dart`

- [ ] **Step 1: Write `pubspec.yaml`**

Create `packages/desk_sdui/pubspec.yaml`:

```yaml
name: desk_sdui
description: Server-driven UI runtime for Flutter.
version: 0.0.1-dev
publish_to: none

environment:
  sdk: ">=3.5.0 <4.0.0"
  flutter: ">=3.24.0"

dependencies:
  flutter:
    sdk: flutter
  desk_sdui_annotation:
    path: ../desk_sdui_annotation
  meta: ^1.16.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  test: ^1.25.0
  very_good_analysis: ^7.0.0
```

- [ ] **Step 2: Write `analysis_options.yaml`**

Create `packages/desk_sdui/analysis_options.yaml`:

```yaml
include: ../../analysis_options.yaml
```

- [ ] **Step 3: Write `CHANGELOG.md`**

Create `packages/desk_sdui/CHANGELOG.md`:

```markdown
## 0.0.1-dev

- Initial scaffold. Empty placeholder; runtime lands in Phase 2.
```

- [ ] **Step 4: Write `README.md`**

Create `packages/desk_sdui/README.md`:

```markdown
# desk_sdui

Runtime that renders the desk_sdui node tree into a Flutter widget tree.

## Status

Phase 1 — empty scaffold. Runtime implementation lands in Phase 2.
```

- [ ] **Step 5: Write empty public export**

Create `packages/desk_sdui/lib/desk_sdui.dart`:

```dart
/// Server-driven UI runtime for Flutter.
library;

// Phase 2 will add: Runtime, SduiScreen, IrLoader, RemoteIrFetcher,
// AssetBundleIrFetcher, and the resolver.
```

- [ ] **Step 6: Write a single trivial test so CI has something to run**

Create `packages/desk_sdui/test/desk_sdui_test.dart`:

```dart
import 'package:test/test.dart';

void main() {
  test('placeholder until Phase 2', () {
    expect(1 + 1, 2);
  });
}
```

- [ ] **Step 7: Bootstrap melos to wire deps**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
melos bootstrap
```

Expected: bootstrap succeeds; `desk_sdui` package picks up `desk_sdui_annotation` via path.

- [ ] **Step 8: Run analyzer and tests**

```bash
melos run analyze
melos run test
```

Expected: both green.

- [ ] **Step 9: Commit**

```bash
git add packages/desk_sdui/
git commit -m "chore(runtime): scaffold desk_sdui package (empty in Phase 1)"
```

---

## Task 13: Scaffold `desk_sdui_generator` skeleton

Empty pure-Dart package — same shape as Task 12 but with generator
dependencies declared. No substantive code yet; that's Phase 3.

**Files:**
- Create: `packages/desk_sdui_generator/pubspec.yaml`
- Create: `packages/desk_sdui_generator/analysis_options.yaml`
- Create: `packages/desk_sdui_generator/CHANGELOG.md`
- Create: `packages/desk_sdui_generator/README.md`
- Create: `packages/desk_sdui_generator/lib/desk_sdui_generator.dart`
- Create: `packages/desk_sdui_generator/test/desk_sdui_generator_test.dart`

- [ ] **Step 1: Write `pubspec.yaml`**

Create `packages/desk_sdui_generator/pubspec.yaml`:

```yaml
name: desk_sdui_generator
description: build_runner codegen and analyzer plugin for desk_sdui.
version: 0.0.1-dev
publish_to: none

environment:
  sdk: ">=3.5.0 <4.0.0"

dependencies:
  analyzer: ^7.2.0
  build: ^2.5.0
  build_runner: ^2.15.0
  source_gen: ^3.0.0
  meta: ^1.16.0
  desk_sdui_annotation:
    path: ../desk_sdui_annotation

dev_dependencies:
  test: ^1.25.0
  very_good_analysis: ^7.0.0
```

- [ ] **Step 2: Write `analysis_options.yaml`**

Create `packages/desk_sdui_generator/analysis_options.yaml`:

```yaml
include: ../../analysis_options.yaml
```

- [ ] **Step 3: Write `CHANGELOG.md`**

Create `packages/desk_sdui_generator/CHANGELOG.md`:

```markdown
## 0.0.1-dev

- Initial scaffold. Empty placeholder; codegen lands in Phase 3.
```

- [ ] **Step 4: Write `README.md`**

Create `packages/desk_sdui_generator/README.md`:

```markdown
# desk_sdui_generator

`build_runner` codegen and analyzer plugin for desk_sdui. Walks `@Screen`
function bodies and emits a typed `.sdui.json` payload + bindings.

## Status

Phase 1 — empty scaffold. Codegen and analyzer plugin land in Phase 3.

## Constraints

- AOT-compiled builders required (`build_runner --force-aot`).
- Must NOT use `dart:mirrors` (incompatible with AOT builders).
```

- [ ] **Step 5: Write empty public export**

Create `packages/desk_sdui_generator/lib/desk_sdui_generator.dart`:

```dart
/// build_runner codegen and analyzer plugin for desk_sdui.
library;

// Phase 3 will add: screenBuilder, registryBuilder, analyzer plugin.
```

- [ ] **Step 6: Write a single trivial test**

Create `packages/desk_sdui_generator/test/desk_sdui_generator_test.dart`:

```dart
import 'package:test/test.dart';

void main() {
  test('placeholder until Phase 3', () {
    expect(1 + 1, 2);
  });
}
```

- [ ] **Step 7: Bootstrap and verify**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
melos bootstrap
melos run analyze
melos run test
```

Expected: bootstrap succeeds; analyze and test both green for all three packages.

- [ ] **Step 8: Commit**

```bash
git add packages/desk_sdui_generator/
git commit -m "chore(generator): scaffold desk_sdui_generator package (empty in Phase 1)"
```

---

## Task 14: GitHub Actions CI

CI runs analyze + format-check + test for the whole workspace on push and
PR. Pinned to known-good Dart and Flutter versions.

**Files:**
- Create: `.github/workflows/ci.yaml`

- [ ] **Step 1: Write the workflow**

Create `.github/workflows/ci.yaml`:

```yaml
name: ci

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  FLUTTER_VERSION: '3.27.0'
  DART_VERSION: '3.6.0'
  MELOS_VERSION: '6.2.0'

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable

      - name: Activate melos
        run: dart pub global activate melos ${{ env.MELOS_VERSION }}

      - name: Bootstrap workspace
        run: melos bootstrap

      - name: Verify formatting
        run: melos run format

      - name: Analyze
        run: melos run analyze

      - name: Test
        run: melos run test
```

- [ ] **Step 2: Commit**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
git add .github/workflows/ci.yaml
git commit -m "chore(ci): add GitHub Actions workflow (analyze, format, test)"
```

---

## Task 15: Final verification

End-to-end check that the whole Phase 1 deliverable works.

- [ ] **Step 1: Run full melos workflow locally**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
melos clean
melos bootstrap
melos run format
melos run analyze
melos run test
```

Expected: all four steps succeed with no errors.

- [ ] **Step 2: Verify the public surface**

```bash
cd packages/desk_sdui_annotation
dart doc --dry-run
```

Expected: dartdoc validates without warnings on the public API.

- [ ] **Step 3: Inspect commit history**

```bash
cd ~/Workspace/dart_desk_workspace/desk_sdui
git log --oneline
```

Expected: ~14 commits, each focused on a single concern.

- [ ] **Step 4: Confirm package layout matches spec**

```bash
find packages -type f -name "*.dart" -not -path "*/.dart_tool/*" | sort
```

Expected output (excluding test files):

```
packages/desk_sdui/lib/desk_sdui.dart
packages/desk_sdui_annotation/lib/desk_sdui_annotation.dart
packages/desk_sdui_annotation/lib/src/annotations.dart
packages/desk_sdui_annotation/lib/src/ir/arith_op.dart
packages/desk_sdui_annotation/lib/src/ir/codec/json_decoder.dart
packages/desk_sdui_annotation/lib/src/ir/codec/json_encoder.dart
packages/desk_sdui_annotation/lib/src/ir/codec/json_ir_codec.dart
packages/desk_sdui_annotation/lib/src/ir/compare_op.dart
packages/desk_sdui_annotation/lib/src/ir/ir_expression.dart
packages/desk_sdui_annotation/lib/src/ir/ir_node.dart
packages/desk_sdui_annotation/lib/src/ir/ir_tree.dart
packages/desk_sdui_annotation/lib/src/ir/logic_op.dart
packages/desk_sdui_generator/lib/desk_sdui_generator.dart
```

(Plus test files under each package's `test/` dir.)

- [ ] **Step 5: Push to remote (optional — only if a remote has been configured)**

If you've set up a GitHub repo for `desk_sdui`:

```bash
git remote add origin git@github.com:<owner>/desk_sdui.git
git push -u origin main
```

CI runs and should pass on the first push.

---

## Phase 1 Done When

- ✅ All 14 tasks above committed
- ✅ `melos run analyze` passes
- ✅ `melos run format` passes (no diff)
- ✅ `melos run test` passes (every test in every package)
- ✅ The `desk_sdui_annotation` package has @Screen + complete node hierarchy + JSON codec
- ✅ Round-trip codec test exercises every node type
- ✅ The other two packages compile and have placeholder tests
- ✅ CI workflow runs analyze + format + test
- ✅ `find packages -name "*.dart"` matches the layout in Task 15 step 4

After Phase 1 is verified, the next plan (`.plans/desk-sdui-2-runtime.md`)
fills in `desk_sdui` — the resolver, expression evaluator, built-in widget
registrations, fetchers, and `SduiScreen`.
