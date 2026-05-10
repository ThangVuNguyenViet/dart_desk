# desk_sdui — server-driven UI for Flutter

**Status:** Design (draft for review)
**Date:** 2026-05-10
**Repo:** new sibling repo `dart_desk_workspace/desk_sdui/` (3 packages)

## Glossary

- **SDUI** — server-driven UI. Layout *description* ships from a server; rendering happens on the device.
- **IR** — intermediate representation. The typed Dart tree the codegen lowers `@Screen` source into; serialized as JSON (or later MessagePack) for the wire.
- **`@Screen`** — the only annotation; marks a function whose body is lowered to IR.
- **Lowering** — transforming the analyzer AST of a `@Screen` body into IR nodes.
- **Reactive scope** — the smallest IR subtree that contains all reads of a given `ValueListenable`; rebuilt independently when that listenable changes.

## Goal

Make it possible to author Flutter screens that ship as data, so the app can render different layouts per tenant — and swap them via a backend without rebuilding or republishing the binary. Authors write idiomatic Flutter (a Dart-subset), a build-time codegen lowers `@Screen` functions into a small IR, and the runtime renders that IR by composing native registered widgets and ViewModel methods.

Native widgets keep their full power (state, async, plugins, animations, gestures, platform channels). The IR only describes layout and binding — never code, never new behaviors.

## Non-goals

- Not a hot-code-push system. The IR cannot introduce a new verb at runtime.
- Not a general Dart runtime. No `await`, no `setState`, no class definitions, no closures over runtime state.
- Not a visual/no-code editor (that's a separate spec for the dart_desk Studio Layouts section).
- Not animations as a special concern — animated widgets are just registered widgets.
- Not state management — local UI state lifts to a host ViewModel.
- Not a server renderer. Rendering is on-device.

## Prior art and positioning

| System | Shape | Why we don't just use it |
|---|---|---|
| **flutter_eval** | Interpreted Dart subset, ~74 opcodes | Per-frame interpreter cost; Apple-policy grey area; introduces new verbs |
| **Shorebird** | AOT-compiled native code patches | Apple-policy grey area; whole-app patches; paid SaaS |
| **RFW (Remote Flutter Widgets)** | Data-only IR, official flutter.dev | No expressions, no codegen, hand-authored binary blobs |
| **Stac** | JSON-driven, ~90 widgets, single-vendor | Per-build regex variable resolution; JSON walked on hot path |
| **riverpod_generator** | Annotation-driven codegen for DI | Different problem (DI), but the **architectural pattern is directly transferable** — see Codegen section |

This package takes RFW's data-only render model + Stac's pre-registered-widget pattern + a Dart-authored frontend + Riverpod's codegen approach. Architectural guarantee: by construction, the runtime cannot introduce a new verb — every widget, fn, and ViewModel method is statically registered in the reviewed binary.

## Success criterion (v1)

All five `home_screen` variants from `foodtech_flutter_design_system` (`verticalBasic`, `verticalCategories`, `verticalImage`, `verticalRecentOrder`, `verticalScroll`) and `chef_screen.dart` from `examples/example_app` author cleanly as `@Screen` and render identically to the originals (verified via golden tests). Edit-save-reload cycle <1.5s. A misuse test suite confirms each forbidden construct produces a useful analyzer error.

## Architecture

### Package layout

Sibling repo, three packages, one-way dependency direction:

```
dart_desk_workspace/
└── desk_sdui/                              ← repo (sibling to dart_desk)
    └── packages/
        ├── desk_sdui_annotation/           ← pure Dart (no Flutter)
        │   └── lib/
        │       ├── desk_sdui_annotation.dart
        │       └── src/
        │           ├── annotations.dart    ← @Screen
        │           └── ir/                 ← IrNode + subclasses, JsonIrCodec
        ├── desk_sdui/                      ← runtime (Flutter)
        │   └── lib/
        │       ├── desk_sdui.dart
        │       └── src/
        │           ├── runtime.dart        ← Runtime, registries
        │           ├── sdui_screen.dart    ← SduiScreen widget
        │           ├── resolve.dart        ← tree walker
        │           ├── expression_eval.dart
        │           ├── builtins/           ← built-in widget/fn registrations
        │           └── loader/
        │               ├── ir_loader.dart
        │               ├── remote_ir_fetcher.dart
        │               └── asset_bundle_ir_fetcher.dart
        └── desk_sdui_generator/            ← build_runner codegen
            └── lib/src/
                ├── builder.dart
                ├── screen_lowering/
                │   ├── screen_generator.dart
                │   ├── ast_to_ir.dart
                │   ├── expression_lowerer.dart
                │   └── widget_lowerer.dart
                ├── registry/
                │   └── registry_generator.dart
                └── analyzer_plugin/
                    ├── plugin.dart
                    └── rules/
```

**Dependencies:**

- `desk_sdui_annotation` — `meta` only
- `desk_sdui` — `flutter`, `desk_sdui_annotation`. **Does not depend on any state-management package.** The reactive contract is `ValueListenable<T>` from the Flutter SDK.
- `desk_sdui_generator` — `analyzer`, `build`, `source_gen`, `build_runner: ^2.15.0`, `desk_sdui_annotation`. **Must not use `dart:mirrors`** (would prevent AOT-compiled builders).

### Three runtime phases

```
PHASE 1: LOAD  (once per blob, cacheable)
  fetch bytes from RemoteIrFetcher / AssetBundleIrFetcher / in-binary literal
  decode bytes → typed IR tree via JsonIrCodec
  cache by name + version hash

PHASE 2: RESOLVE  (per build)
  walk IR depth-first
  resolve $refs against input map (data, controller, theme, ...)
  resolve $events to bound methods
  evaluate expression nodes
  return Widget tree

PHASE 3: RENDER  (per frame, Flutter's job)
  Flutter framework reconciles widgets against element tree
  no resolver code runs at frame rate
```

Cost model:

- LOAD: ~0.5ms for a 5KB JSON blob, paid once per screen per session.
- RESOLVE: ~50-150µs for a typical 150-node screen. Reactive subtrees rebuild independently — a listenable change on a 10-node subtree resolves only those 10.
- RENDER: identical to a hand-written Flutter screen. Resolver does not run at frame rate.

**Build rate vs. frame rate.** The resolver runs during Flutter `build()` calls, not during layout/paint. A static screen at 60fps with no state changes runs zero resolver code per frame; Flutter reuses cached widgets. The resolver runs only when state changes trigger a rebuild — typically 0-10 times per second in normal operation, not 60.

**Overhead vs. hand-written Flutter.** For the same widget composition, our resolver adds ~50-100ns per `WidgetNode` (registry lookup + builder invocation) compared to direct Dart construction. For a 150-node IR that's ~10-30µs of overhead per build. Well under the 16ms frame budget; invisible in normal operation.

**Why this differs from flutter_eval.** flutter_eval's interpreter runs continuously — including inside animation callbacks invoked at 60Hz. Per-op interpreter cost compounds with per-frame work, eating frame budget. Our IR runs once per build then hands a widget tree to Flutter; animations tick natively in registered animated widgets without IR involvement.

### Turing-completeness boundary (load-bearing)

The IR is deliberately *not* Turing-complete. The system as a whole is — via registered Dart functions called from the IR. This split is intentional and load-bearing for performance, Apple-policy safety, and debuggability.

**The cost rule:**

> A build's total work must be `O(IR-tree-size + data-shape-size)`.

Every existing IR construct preserves this:

- `WidgetNode`/`RefNode`/`EventNode` — one op each, visited once
- `ConditionalNode` — single branch evaluated, not both
- `ForNode` over a list — N iterations where N = collection size (data-bounded)
- `CompareOp`/`ArithOp`/`LengthOf` — one op each

The **data shape** determines cost, not the **code shape**. The IR cannot make itself work harder than its own size plus the data it walks.

**What the rule excludes:**

- `WhileNode` — unbounded iteration breaks the bound (one IR node, runtime-state-driven op count)
- Recursion in IR — call depth is runtime-state-driven, not bounded by IR size
- Mutable locals — destroy const-folding, reactive-scope hoisting, and most future memoization opportunities

These would each add ~10-50× overhead for any computation that flows through them, because they let the IR run unbounded work in interpreter time. Anything you'd want them for is better expressed as a registered Dart function called from the IR — same expressiveness, native Dart speed, smaller debug surface, smaller Apple-policy surface.

**Where Turing-completeness lives:**

The system is fully Turing-complete because registered Dart functions can compute anything at native speed. The IR pays one cheap call per invocation; the function itself runs as normal Dart. Computation lives where it's free (Dart side); the IR only handles composition + binding.

This split is not a workaround for platform limits — it's the architecture that makes the runtime fast and safe. Re-litigating it loses both properties.

### Performance constraints (mandatory)

These rules are mandatory in the implementation; violating them brings back Stac's per-build cost.

1. **Never walk JSON or strings on the build path.** IR is loaded once, parsed once, cached as typed Dart objects.
2. **Expressions are AST nodes assembled by codegen, never strings parsed at runtime.** No regex on the build path.
3. **`$ref` paths are pre-split at parse time** into segment lists; per-build is just `Map.[]` walks.
4. **Reactive `$ref`s subscribe via `ListenableBuilder`** scoped to the smallest enclosing IR subtree, not the whole screen.
5. **Animations don't traverse the resolver.** Animated widgets (e.g., `AnimatedContainer`, `Hero`, `flutter_animate`, `rive`, `lottie`) are registered as leaves and tick internally with no IR awareness.
6. **Const-fold subtrees with no refs/events** at build time so they emit as `const` Dart literals (canonicalized; zero allocation per rebuild).

## IR shape

Closed set of typed Dart node classes. Adding a new node type requires explicit design — no ad-hoc growth.

```
IrNode (sealed base)
│
├── WidgetNode          name, args, key?
├── BuiltinWidgetNode   like WidgetNode but for SDK primitives we ship
│
├── LiteralNode         bool | num | String | null | Color | EdgeInsets | ...
├── ConstNode           const Dart literal subtree (canonicalized)
│
├── RefNode             path: List<String>, reactive: bool
├── EventNode           target: List<String>, args: Map<String, IrNode>?
│
├── ListNode            children
├── MapNode             entries
├── RecordNode          positional/named fields
│
├── ConditionalNode     condition, then, else?  (covers if/?:/&&/||/??)
├── ForNode             pattern, source, body
├── SpreadNode          source
│
└── ExpressionNode (sealed sub-hierarchy)
    ├── CompareOp       ==, !=, <, <=, >, >=
    ├── ArithOp         +, -, *, /, %
    ├── LogicOp         &&, ||
    ├── NotOp
    ├── CoalesceOp      a ?? b
    ├── MemberAccess    a.b
    ├── IndexAccess     a[k]
    ├── LengthOf        xs.length
    ├── IsNullCheck
    └── StringInterp    'hello $name!'
```

### Lowering rules — AST → IR

| Source pattern | IR |
|---|---|
| `Column(children: [...])` | `WidgetNode('Column', {'children': ListNode([...])})` |
| `data.title` | `RefNode(['data','title'])` |
| `controller.flag` (type `ValueListenable<bool>`) | `RefNode(['controller','flag'], reactive: true)` |
| `controller.method` (tear-off) | `EventNode(['controller','method'])` |
| `() => controller.removeItem(item.id)` | `EventNode(['controller','removeItem'], args: {'arg0': RefNode(['item','id'])})` |
| `data.items.length >= 50` | `CompareOp(>=, LengthOf(RefNode(['data','items'])), LiteralNode(50))` |
| `'$total items'` | `StringInterp([RefNode(['count']), ' items'])` |
| `if (cond) A` / `if (cond) A else B` | `ConditionalNode(cond, A, B?)` |
| `cond ? A : B` | `ConditionalNode(cond, A, B)` |
| `a ?? b` | `CoalesceOp(a, b)` |
| `for (final x in xs) child` | `ForNode('x', RefNode(['xs']), child)` |
| `for (final (i, x) in xs.indexed) child` | `ForNode(['i','x'], MemberAccess(xs, 'indexed'), child)` |
| `...somelist` | `SpreadNode(RefNode(['somelist']))` |
| `EdgeInsets.all(8)` and other recognized const constructors | `LiteralNode(<const>)` baked at build time |

### Closure whitelist

Inspired by `riverpod_generator`'s family-provider pattern: constrain to a small enumerable set of supported shapes; reject the rest with analyzer errors and fix-it suggestions.

| Closure shape | Lowering |
|---|---|
| `controller.foo` (tear-off) | `EventNode(['controller','foo'])` |
| `() => controller.foo()` | `EventNode(['controller','foo'])` |
| `() => controller.foo(literal)` | `EventNode(['controller','foo'], args: {arg0: LiteralNode(literal)})` |
| `() => controller.foo(item.id)` (closes over loop var) | `EventNode(['controller','foo'], args: {arg0: RefNode(['item','id'])})` |
| `(value) => controller.foo(value)` (callback arg passes through) | `EventNode(['controller','foo'], args: {arg0: RefNode(['_callback_arg_0'])})` |
| `(a) => controller.foo(transform(a))` (inline transform) | **Analyzer error**: "extract `transform` to a top-level pure fn or controller method" |
| Anything else | **Analyzer error**: "extract to a ViewModel method" |

### Forbidden constructs in `@Screen`

| Construct | Error |
|---|---|
| `await` | "async not supported in @Screen — move to a ViewModel method" |
| `setState` | "@Screen is stateless — lift state to a ViewModel" |
| `var x = ...` (mutable local) | "let / final only inside @Screen" |
| `try { } catch { }` | "no error handling in @Screen — handle errors in ViewModels" |
| `for (var i = 0; i < n; i++)` | "use `for (x in xs)` — counter loops not supported" |
| `while`, `do { } while` | "loops with side effects not supported" |
| Nested function definition | "extract to a top-level function or another @Screen" |
| Class instantiation of unregistered type | "type X is not a registered widget" |
| Method call on a non-listenable controller field that mutates state | "controller methods must be called as event handlers (`onTap: controller.foo`)" |

### Const-fold rule

After lowering, the lowerer walks the IR. Any subtree where every leaf is `LiteralNode`/`ConstNode` and contains no `RefNode`/`EventNode` is replaced with `ConstNode(constructedWidget)`. The `.sdui.g.dart` emits a `const` Dart literal for it; Dart canonicalizes; rebuilds reuse the instance.

`Theme.of(context)` and similar are **not** const-foldable — the `Theme` parameter is declared in the `@Screen` signature, so theme reads are `RefNode`s, not literals.

### Reactive scope hoisting

After const-folding, the lowerer does a second pass:

1. Find every `RefNode` with `reactive: true`.
2. Group by ref path (so two reads of `controller.showPromoCode` collapse to one subscription).
3. For each group, walk up to the nearest enclosing `WidgetNode`.
4. Add the joined ref path to that node's `listenablePaths: Set<String>`.

The runtime, when rendering a `WidgetNode` whose `listenablePaths` is non-empty, wraps it in `ListenableBuilder` subscribed to the matching `Listenable`s from `input['__reactive__']`. Only that subtree rebuilds when the listenable fires.

If a single listenable's reads span the whole screen, the lowerer emits a build-time warning suggesting refactor — not an error.

### Key inference rule

For a `ForNode`, the lowerer inspects the body's root widget. If no `key:` is provided and the loop variable's type has a recognizable identity field (`id`, `uuid`, or a `@KeyField`-annotated field), the lowerer **synthesizes** `key: ValueKey(item.id)`. Otherwise, the lowerer emits a build-time warning. Author can suppress with explicit `key: null` or `// sdui:no-key` comment.

## Authoring workflow

### Per-screen file

```dart
// lib/screens/cart.dart
import 'package:desk_sdui_annotation/desk_sdui_annotation.dart';
import 'package:flutter/material.dart';
import '../view_models/cart_screen_view_model.dart';
import '../models/cart_data.dart';

part 'cart.sdui.g.dart';

@Screen('cart')
Widget buildCart(CartData data, CartController controller) {
  return Column(children: [
    if (data.items.isEmpty)
      const Text('Cart is empty'),
    for (final item in data.items)
      ItemTile(
        key: ValueKey(item.id),
        item: item,
        onRemove: () => controller.removeItem(item.id),
      ),
    InkWell(
      onTap: controller.togglePromoCode,
      child: const Text('Have a promo code?'),
    ),
    if (controller.showPromoCode())
      PromoCodeField(onSubmit: controller.applyPromo),
  ]);
}
```

The developer doesn't register `ItemTile`, `PromoCodeField`, `Column`, `InkWell`, or `Text`. The developer doesn't register `controller.togglePromoCode`, `controller.removeItem`, or `controller.applyPromo` as actions. Codegen handles all of it from usage.

### Boot wiring

`desk_sdui_setup.dart` (handwritten):

```dart
import 'package:desk_sdui/desk_sdui.dart';
part 'desk_sdui_setup.sdui.g.dart';

final sduiRuntime = Runtime();
void initSdui() => _registerAll(sduiRuntime);
```

`desk_sdui_setup.sdui.g.dart` (generated — discovers every `@Screen` in the app):

```dart
part of 'desk_sdui_setup.dart';

void _registerAll(Runtime rt) {
  rt.registerScreen(cartBinding);
  rt.registerScreen(homeBasicBinding);
  // ... etc
}
```

Called once from `main()`:

```dart
void main() {
  initSdui();
  runApp(MyApp());
}
```

### Use a screen

```dart
class CartScreen extends StatelessWidget {
  Widget build(BuildContext ctx) =>
    SduiScreen(name: 'cart', runtime: sduiRuntime);
}
```

### Hot-reload loop

```
edit cart.dart → save → build_runner sees change (~500ms)
              → regenerates cart.sdui.g.dart (~200ms)
              → Flutter hot-reload picks it up (~100ms)
              → screen rebuilds with new IR
```

Total: ~1 second.

## Codegen design

### Two builders

Declared in `desk_sdui_generator/build.yaml`:

1. **`screenBuilder`** — runs per-file. For each `.dart` containing `@Screen`-annotated functions:
   - Parses via `package:analyzer`
   - Walks each `@Screen` function body, lowering AST → IR
   - Walks the parameter list, generates `InputBinding`s
   - Walks `controller.method` references, generates the `methods` map
   - Walks `ValueListenable<T>`-typed accesses, generates the `reactive` map
   - Emits `<file>.sdui.g.dart` (always) and `<file>.uib` (always — JSON wire form)

2. **`registryBuilder`** — runs once per package. Discovers every `@Screen` and emits `desk_sdui_setup.sdui.g.dart` with `_registerAll()`.

Both builders use `package:analyzer`'s diagnostic API for warnings/errors. AOT-compiled builders required (`build_runner --force-aot`), so generators must not use `dart:mirrors`.

### Auto-discovery rules

- Widget referenced in `@Screen` (e.g., `AppImage(...)`) → analyzer resolves the class, codegen synthesizes a builder binding from its constructor signature, registers under its class name.
- Top-level pure function called directly (e.g., `extractPlainText(block)`) → auto-registered under its name.
- ViewModel method referenced as `controller.foo` (tear-off) or `() => controller.foo(...)` (closure) → auto-registered as bound method.

**Escape hatch:** for widgets registered but not statically referenced (e.g., picked dynamically by name from tenant config), an optional `@SduiExpose('name')` annotation. Rare; not the daily path.

### Analyzer plugin

Activated via `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - desk_sdui_generator
```

v1 lint surface (5–7 rules):

- `sdui_no_async_in_screen`
- `sdui_no_set_state`
- `sdui_no_mutable_locals`
- `sdui_no_function_definition`
- `sdui_no_try_catch`
- `sdui_unsupported_loop`
- `sdui_unregistered_symbol`
- `sdui_missing_key_warning`

Plugin is pure analysis — does not run codegen. Codegen runs via `build_runner` (the source of truth for what compiles).

## Runtime API surface

### `Runtime`

```dart
final runtime = Runtime(
  fetcher: RemoteIrFetcher(endpoint: '...'),       // optional
  assetBundle: rootBundle,                          // optional
  errorBuilder: (ctx, error) => ...,                // optional
  loadingBuilder: (ctx) => ...,                     // optional
  logger: (level, msg) => ...,                      // optional
);

runtime.registerScreen(ScreenBinding binding);
runtime.registerWidget(String name, WidgetBuilder builder);
runtime.registerFn(String name, Function fn);
```

Resolution order for `Runtime.load(name)`:

1. `fetcher` (if set and online) — fetches `.uib` JSON from the configured endpoint
2. `assetBundle` (if set) — reads `<prefix>/<name>.uib` from the app's asset bundle
3. In-binary `ScreenBinding.ir` — the Dart literal compiled from `.sdui.g.dart`

Any source produces the same typed `IrTree`. The runtime caches by `(name, contentHash)`, where `contentHash` is the SHA-1 of the source bytes — invalidates automatically when the codegen regenerates or when the remote endpoint serves a new version.

### `SduiScreen`

```dart
class SduiScreen extends StatefulWidget {
  const SduiScreen({super.key, required this.name, required this.runtime});
  final String name;
  final Runtime runtime;
}
```

Mounting triggers Phase 1 (load); first build runs Phase 2 (resolve). Subsequent rebuilds run Phase 2 only on the affected reactive subtrees.

### Reactive contract

The runtime treats any `ValueListenable<T>` subscription (Flutter SDK type) as reactive. Concrete sources:

- `ValueNotifier<T>` (Flutter SDK)
- Any custom `ChangeNotifier` exposing a value
- Any third-party type that implements `ValueListenable<T>`
- `Animation<T>` (Flutter SDK — extends `Listenable`; see Animation pattern below)

The runtime imports no state-management package.

### Animation pattern

`AnimationController` cannot live inside `@Screen` — it needs a `TickerProvider` (vsync) and `dispose()`, neither of which fit a stateless top-level function. The canonical pattern: **the host `StatefulWidget` (the one mounting `SduiScreen`) owns the `AnimationController`, and exposes the resulting `Animation<T>` on the controller object the screen binds to**. Because `Animation<T>` extends `Listenable`, the runtime subscribes via `listenablePaths` and the `@Screen` reads `controller.fadeAnim.value` as a reactive ref.

```dart
// Host side — regular Flutter
class _CartScreenHostState extends State<CartScreenHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) =>
    SduiScreen(
      name: 'cart',
      runtime: sduiRuntime,
      inputs: {'data': widget.data, 'controller': widget.controller..fadeAnim = fadeAnim},
    );
}
```

```dart
// @Screen side — declarative read
@Screen('cart')
Widget buildCart(CartData data, CartController controller) {
  return Opacity(
    opacity: controller.fadeAnim.value,  // reactive — value changes drive rebuild
    child: ...
  );
}
```

Self-contained animated widgets (`AnimatedContainer`, `Hero`, `flutter_animate`, `rive`, `lottie`) remain available as registered widgets and tick natively without IR involvement.

## Risks and mitigations

| # | Risk | Mitigation |
|---|---|---|
| 1 | Codegen complexity for closures-with-args | Whitelist 5 supported shapes (above); analyzer error for the rest with fix-it suggestions; spike one real example before locking |
| 2 | Const-fold misses a hidden dependency | Const-fold only when every leaf is a true compile-time constant; `Theme.of`-style values are `RefNode`s by construction |
| 3 | Reactive-scope hoisting too wide | Build-time warning for wide-scoped listenables; document refactor patterns |
| 4 | Analyzer plugin breaks on SDK upgrade | Lean lint surface (5–7 rules); pin analyzer version; degraded fallback: errors surface in `build_runner` output |
| 5 | `.sdui.g.dart` files inflate binary | Acceptable for v1; v2 release-mode strip when remote-only |
| 6 | Cold-start latency for first remote screen | v1 blocks with `loadingBuilder`; v2 adds prefetch + bundled fallbacks |
| 7 | Migration risk for existing screens | Side-by-side golden snapshot tests against original Dart-only versions |
| 8 | Build-time slows with many `@Screen`s | AOT-compiled builders mandatory; defer further optimization |
| 9 | Apple-policy concern | Architectural argument documented (config-driven, no new verbs); same risk profile as Firebase Remote Config |
| 10 | Lowering subset too narrow | Tracer-bullet 6 real screens first; subset grows from real demand |

## Open questions (resolve during implementation)

| # | Question | Default |
|---|---|---|
| O1 | Closure args lowering: positional or named? | Named with synthesized keys (`{arg0, arg1}` keyed by analyzer-resolved param names) |
| O2 | Top-level helper functions: auto-registered? | Yes for pure functions; analyzer error for side-effecting |
| O3 | Loop variable destructuring (`(i, x) in xs.indexed`) | Supported in v1 |
| O4 | Generic widget types (`DropdownButton<String>`) | Supported; codegen synthesizes builder per concrete instantiation |
| O5 | IR version-bump policy | Strict semver; runtime refuses major-ahead blobs |
| O6 | Theme: parameter or `Theme.of(context)`? | Parameter — explicit, testable |
| O7 | Logging surface | Consumer-provided callback; default `print` |

## v1 deliverables (locked scope)

**Three packages:**

- `desk_sdui_annotation` — `@Screen`, IR node classes, `JsonIrCodec`
- `desk_sdui` — `Runtime`, `SduiScreen`, `RemoteIrFetcher`, `AssetBundleIrFetcher`, expression evaluator
- `desk_sdui_generator` — `screenBuilder`, `registryBuilder`, analyzer plugin (5-rule lint surface)

**End-to-end demonstration:**

- All 5 `home_screen` variants (foodtech) authored as `@Screen`
- `chef_screen.dart` (example_app) authored as `@Screen`
- All 6 side-by-side golden-tested against the originals

**Authoring loop:**

- `dart run build_runner watch --force-aot` regenerates on save
- Edit `@Screen` → see updated render in <1.5s via Flutter hot reload
- IDE flags forbidden constructs

**Validation criteria:**

1. All 6 named screens render identically to original Dart-only versions (golden parity)
2. Edit-save-reload <1.5s for a `@Screen` change
3. Misuse test suite confirms each forbidden construct produces a useful analyzer error
4. Perf benchmark: resolve cost <0.5ms per build for largest screen
5. README walks a new dev from "fresh checkout" to "first `@Screen` authored" in 15 minutes

**Explicit non-goals for v1:**

- No CMS Layouts UI in dart_desk Studio (separate spec)
- No CLI publish step (manual upload via curl is fine for the spike)
- No memoization beyond const-folding
- No prefetch / cache warming
- No binary wire format (JSON only)
- No isolate-decode
- No A/B testing or version pinning
- No multi-locale support (separate spec)
- No `@SduiExpose` for dynamic widget references (deferred until first real need)

## Constraints for implementation

- **build_runner ≥ 2.15.0**, AOT-compiled builders (`--force-aot`), no `dart:mirrors`
- Runtime depends on Flutter SDK only — no state-management or DI package
- Reactive contract is `ValueListenable<T>` (anything implementing it works)
- IR is parsed once into typed Dart objects; no JSON walked on the build path
- Authoring DSL is Dart-subset; analyzer plugin enforces the subset in IDE
- Class names should not contain "CMS" — the runtime is general-purpose
