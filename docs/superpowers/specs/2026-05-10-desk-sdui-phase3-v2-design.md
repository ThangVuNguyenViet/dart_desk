# desk_sdui Phase 3 v2 — Codegen-driven auto-registration

**Date:** 2026-05-10
**Supersedes:** Phase 3 codegen as defined in `2026-05-10-desk-sdui-design.md` (the registry / builtin-widgets sections only — IR shape, runtime walk, and lowering passes from Phase 1–2 are unchanged).

## The mistake we're fixing

Phase 3 v1 hand-wrote `builtin_widgets.dart` against a curated subset of Flutter widgets and types. Phase 4 porting surfaced four failure modes:

1. **Silent compiler holes** — emitted IR for symbols not registered (`BoxDecoration`, `Color`, `Icons.*`).
2. **Subset drawn for codegen, not authors** — pervasive Flutter-isms like `.toUpperCase()`, `.first`, `Colors.grey[300]` excluded by default.
3. **Codegen/runtime drift** — codegen emitted refs that runtime had no resolver for.
4. **Hand-maintained registry** — no mechanical guarantee that everything codegen emits is registered at runtime.

Root cause: the registry was hand-curated. The fix is to **derive the registry from `@Screen` usage at codegen time**.

## The shift

> The registry is no longer a hand-written file. It is the *union of every external symbol that any `@Screen` in the app uses*, computed by codegen, emitted as registration code that runs at app startup.

Concretely: `dart run build_runner build` walks each `@Screen` AST, classifies every external reference into a registration kind, and emits a Dart file per screen plus a unioned setup file. The runtime registry at boot is *exactly* the set of operations the app's `@Screen`s reference. Nothing more, nothing less.

## Architecture

### Symbol kinds

Every external reference in a `@Screen` body falls into one of these kinds:

| Kind | Example | Registered as |
|---|---|---|
| **Widget constructor** | `Padding(padding: ..., child: ...)` | `WidgetBuilder` keyed by qualified name |
| **Static constant** | `Icons.menu`, `Colors.red`, `CrossAxisAlignment.start` | `Constant` keyed by `'Icons.menu'` |
| **Method** | `data.title.toUpperCase()`, `n.toStringAsFixed(2)` | `MethodHandler` keyed by `'String.toUpperCase'` (receiver-type-keyed) |
| **Subscript** | `Colors.grey[300]`, `map['key']` | `SubscriptHandler` keyed by receiver type |
| **Constructor of value type** | `EdgeInsets.all(8)`, `BoxDecoration(...)` | `ValueBuilder` keyed by qualified constructor name |
| **Top-level function** | `min(a, b)` (rare) | `FunctionHandler` keyed by qualified name |

### Per-screen codegen output

Today, `chef.dart` produces:
- `chef.sdui.g.dart` — binding partial (registers `chefBinding`)
- `chef.sdui.json` — wire payload

Under v2, it produces the same two files, but `chef.sdui.g.dart` now also exposes a **registration callback** that registers every external symbol chef references:

```dart
// chef.sdui.g.dart  (auto-generated, v2 shape)
part of 'chef.dart';

final chefBinding = ScreenBinding(
  name: 'chef',
  ir: _chefIr, // unchanged
  inputs: [/* ... */],
);

void registerChefDependencies(Runtime rt) {
  // Widgets
  rt.registerWidget('Padding', (a) => Padding(
    padding: a['padding'] as EdgeInsetsGeometry,
    child: a['child'] as Widget?,
  ));
  rt.registerWidget('Column', (a) => Column(
    crossAxisAlignment: a['crossAxisAlignment'] as CrossAxisAlignment? ?? CrossAxisAlignment.center,
    children: (a['children'] as List).cast<Widget>(),
  ));
  // Constants
  rt.registerConstant('CrossAxisAlignment.start', CrossAxisAlignment.start);
  rt.registerConstant('Colors.white', Colors.white);
  // Methods
  rt.registerMethod('String.toUpperCase', (recv, _) => (recv as String).toUpperCase());
  // Value-type constructors
  rt.registerValueBuilder('EdgeInsets.all', (a) => EdgeInsets.all(a[0] as double));
  // ... one entry per external reference chef makes
}
```

### App-level union

The registry generator (existing) reads every `*.sdui.g.dart` in the package and emits a single setup file:

```dart
// desk_sdui_setup.g.dart  (auto-generated)
import 'package:foo/screens/chef.dart' show chefBinding, registerChefDependencies;
import 'package:foo/screens/cart.dart' show cartBinding, registerCartDependencies;
// ...

void registerAllScreens(Runtime rt) {
  rt.registerScreen(chefBinding);
  rt.registerScreen(cartBinding);
  registerChefDependencies(rt);
  registerCartDependencies(rt);
}
```

When the app boots and calls `registerAllScreens(runtime)`, the registry is now exactly the union of every operation any `@Screen` uses.

### Runtime API additions

The `Runtime` class gains four new register-* methods (replacing the hand-written `builtinWidgets`):

```dart
class Runtime {
  void registerWidget(String name, WidgetBuilder builder);
  void registerConstant(String name, Object? value);
  void registerMethod(String name, MethodHandler handler);
  void registerSubscript(String name, SubscriptHandler handler);
  void registerValueBuilder(String name, ValueBuilder builder);
  void registerFunction(String name, FunctionHandler handler);
}

typedef WidgetBuilder = Widget Function(Map<String, Object?> args);
typedef MethodHandler = Object? Function(Object? receiver, List<Object?> args);
typedef SubscriptHandler = Object? Function(Object? receiver, Object? key);
typedef ValueBuilder = Object? Function(List<Object?> args);
typedef FunctionHandler = Object? Function(List<Object?> args);
```

Existing `builtinWidgets.dart` is **deleted**. The runtime ships with no pre-registered operations — everything comes from the auto-generated setup.

### IR shape changes

The IR has a `WidgetNode` and a `RefNode` already. Two new node kinds are needed (or existing nodes are extended) to support the new registration kinds cleanly:

- **`MethodCallNode(receiver, name, args)`** — wraps method invocations. Already exists in some form via `MemberAccessNode`; extended to carry a method-handler key resolved at codegen.
- **`ValueCtorNode(name, args)`** — for value-type constructors (`EdgeInsets.all(8)`). Currently lowered to `WidgetNode` which is wrong (it's a value, not a widget). Adds a sibling node.

Wire format: existing `.sdui.json` shape unchanged for `WidgetNode`; new `MethodCallNode` and `ValueCtorNode` get their own type discriminators.

### Network-pre-registration

Network-delivered `.sdui.json` can only invoke names already in the registry. To register operations that no in-binary `@Screen` uses, authors add an annotation:

```dart
@RegisterForSdui([
  PageView,
  RefreshIndicator,
  // any widget you want network screens to be able to use
])
class SduiCoverage {} // empty class, just a registration anchor
```

Codegen treats `@RegisterForSdui` as a list of widget types to register exactly as if some `@Screen` referenced them. The annotation is the explicit way to say "I commit to supporting this widget across app versions; reviewers can audit which widgets are network-reachable."

### Denylist analyzer rule

A new lint `sdui_no_side_effects_in_screen` forbids `@Screen` bodies from referencing identifiers in any of these libraries:

- `dart:io` (File, Directory, Process, Socket, HttpClient, Platform, Stdin/Stdout)
- `dart:isolate` (Isolate, ReceivePort, SendPort)
- `dart:ffi`
- `dart:mirrors`

The rule fires at the `@Screen` body's reference site. Apple-policy posture remains: even though codegen would happily auto-register `File.readAsStringSync` if asked, the analyzer rule prevents it from ever being asked.

The denylist is small and stable — these libraries are the canonical "would do something Apple cares about" surface. Adding `@Screen`-allowed exceptions (e.g. a specific safe `dart:io` constant) is explicit per-symbol via a configuration file under `desk_sdui_generator/`.

## Out of scope (still v2 deferred)

- **Closure shapes** — the existing 5-shape closure whitelist stays. Auto-registration handles widget/method/constant references; closure bodies are a separate lowering concern.
- **Const folding for `BoxDecoration` / `LinearGradient`** — auto-registration registers the constructors as `ValueBuilder`s, but const-fold at codegen time still has gaps. They get registered correctly; they just can't be `const`-evaluated at codegen yet, which means slightly larger payloads. Acceptable for v2.
- **Generic-parameter-aware registration** — `List<T>.map<R>(...)` registers as `Iterable.map` with erased types. Type args travel through the IR but aren't part of the registration key. Future work if it bites.
- **Method invocations through receivers of static type `dynamic`** — these can't be reliably registered. Codegen errors with "method receiver must have a static type."

## Cost model

Per-frame cost is unchanged. The registry is bigger (proportional to total in-binary `@Screen` complexity) but lookup is still O(1) hash-map.

App startup pays a one-time cost to register every operation. For a project with ~50 screens averaging ~30 external symbols each, that's ~1500 hash-map insertions in `main()` — sub-millisecond, well below frame budget. Negligible.

Binary size: each registered operation adds a closure literal and a string key. ~100 bytes per entry × 1500 entries = ~150KB. Comparable to the hand-written `builtin_widgets.dart` it replaces, possibly larger but in the same order.

## Apple §3.3.2 posture

Stronger than v1.

The setup file is a **complete, static manifest** of every operation the app supports. A reviewer reading `desk_sdui_setup.g.dart` sees:

- Every widget the app can ever construct from server-delivered data
- Every constant the app can resolve
- Every method the app can dispatch
- Every value type the app can build

Anything not in that file cannot be invoked, period. There is no interpreter, no `eval`, no dynamic resolution. The only paths to extending the registry are:

1. Use the symbol in a new `@Screen` and ship a new app build (Apple-reviewed).
2. Add to `@RegisterForSdui` and ship a new app build (Apple-reviewed).

Server-delivered `.sdui.json` cannot extend the registry. By construction.

## Migration from v1

Phase 3 v1 + the Phase 4 chef port are real progress. v2 reuses:

- IR shape (Phase 1) — unchanged
- Runtime walker (Phase 2) — unchanged except for the new `registerX` methods
- Lowering passes (Phase 3 v1 expression/widget/closure lowerers) — mostly reused; the widget lowerer's job changes from "look up name in builtin_widgets" to "emit an entry in the per-screen registration list"
- Existing `@Screen` and `@RegisterForSdui` annotations — `@Screen` unchanged; `@RegisterForSdui` is new
- chef port — re-codegens cleanly under v2 with no source change

Phase 3 v1 commit `c690fda` (the runtime fix-ups) — partially superseded. The `ref_resolver.dart` extensions for `Icons.*` etc. become unnecessary because those refs are now per-screen-registered constants, not runtime-resolved string lookups.

## Done When (v2 acceptance)

1. `desk_sdui_setup.g.dart` is fully auto-generated from `@Screen` and `@RegisterForSdui` usage.
2. `builtin_widgets.dart` is deleted.
3. chef + 5 home variants from foodtech port to `@Screen` and codegen successfully **without any hand-edited registration files**. (Pixel parity is still a separate goal — v2 acceptance is "compiles + renders without missing-symbol errors," not byte-identical screenshots.)
4. The denylist analyzer rule fires on `@Screen` bodies that reference `dart:io` etc.
5. A network-only screen test demonstrates that delivering a `.sdui.json` referencing a `@RegisterForSdui`-only widget renders correctly.

## Open questions resolved by this design

- **Q: Network screens reference widgets no in-binary screen uses — how do they get registered?**
  A: `@RegisterForSdui([Widget1, Widget2, ...])` annotation. Explicit, auditable, ships with the app build.

- **Q: How do we prevent server payloads from invoking `File.read`?**
  A: The denylist analyzer rule prevents `@Screen` (and `@RegisterForSdui`) authors from referencing `dart:io`. Codegen never registers what it never sees.

- **Q: What about `Icons.*`, `Colors.*` — is every member of these classes registered?**
  A: No. Only the specific members chef references (`Icons.menu`, `Colors.white`, etc.). `Icons.somethingChefDoesntUse` would not be in the registry; a server payload referencing it would fail with a missing-symbol error at decode time. To pre-register a wider set, use `@RegisterForSdui`.

- **Q: How does the registration emitter handle generic types like `List<Product>.map`?**
  A: The handler is registered against the erased receiver type (`Iterable.map`); type args travel as IR data and are passed through dynamic. Loss of static-type guarantee for the mapped result, but the operation works. Acceptable.

- **Q: What if two screens reference the same widget (`Padding`)? Do we emit two registrations?**
  A: Each per-screen `.sdui.g.dart` emits its own registration. The setup file calls all of them. Re-registration of the same name is idempotent (last-writer-wins, same closure shape). Negligible cost. We *could* dedupe at the setup-emit level, but YAGNI for v2.
