# DeskConditionContext Design

**Status:** Draft
**Date:** 2026-04-29
**Repo:** `dart_desk`

## Problem

`DeskCondition.evaluate(Map<String, dynamic> data)` only sees the document's
data map. It can't read document metadata (e.g. `isDefault`) or any runtime
state (viewmodels, repositories, services). This blocks use cases like
"hide a field on default documents" — the kind of conditional UI Sanity
expresses naturally with a function callback receiving `{document, parent,
value, currentUser}`.

We can't match Sanity's function-callback shape: dart_desk conditions are
const-constructible classes consumed by `dart_desk_generator` at build time.
But we can match Sanity's *context shape* — pass everything a condition
might need into `evaluate` as a structured object.

## Goals

- Conditions can read the current `DeskDocument` (incl. `isDefault`).
- Conditions can read runtime services (viewmodels, repositories, …) without
  importing dart_desk's DI container.
- Schema packages (e.g. `hg_kiosk_data_models`) stay minimal — they depend
  only on `dart_desk_annotation`, never on the heavy `dart_desk` runtime.
- Conditions remain declarative at the field's definition site (no
  app-boot-time registries, no string-keyed indirection).
- No new global mutable state introduced for conditions; the existing GetIt
  container is treated as a `dart_desk` implementation detail and never
  leaks into consumer code.

## Non-Goals

- Replacing the const-class shape of `DeskCondition` with function callbacks.
- Adding `parent` / `value` / `currentUser` to context. YAGNI — we have
  almost no nested object schemas, no role-based UI, and current built-ins
  don't need the field's own value. The context is a const data class;
  these can be added later without breaking changes.

## Design

### Public API (in `dart_desk_annotation`)

```dart
// dart_desk_annotation/lib/src/data/desk_document.dart
//   (RELOCATED from dart_desk/lib/src/data/models/desk_document.dart;
//    file content unchanged. dart_desk re-exports for backward compat.)
class DeskDocument { ... }

// dart_desk_annotation/lib/src/fields/base/desk_condition_context.dart
abstract class DeskConditionContext {
  const DeskConditionContext();

  /// The document currently being edited, including its metadata
  /// (id, documentType, title, isDefault, activeVersionData, …).
  /// Null in non-document contexts (e.g. tests).
  DeskDocument? get document;

  /// Look up a runtime service by type — viewmodels, repositories,
  /// or anything else registered by the host application.
  /// Throws if [T] is not registered.
  T read<T extends Object>();
}

// dart_desk_annotation/lib/src/fields/base/field.dart  (modified)
abstract class DeskCondition {
  const DeskCondition();
  bool evaluate(DeskConditionContext ctx);
}
```

Built-in conditions migrate their signatures to read from
`ctx.document?.activeVersionData`:

```dart
class FieldEquals extends DeskCondition {
  final String field;
  final Object? value;
  const FieldEquals(this.field, this.value);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      ctx.document?.activeVersionData?[field] == value;
}
// Same shape for FieldNotEquals, FieldNotNull, FieldIsNull.
// AllConditions / AnyCondition forward ctx to their children.
```

### Internal implementation (in `dart_desk`)

```dart
// dart_desk/lib/src/studio/internal/get_it_condition_context.dart
//   (not exported from package:dart_desk)
class _GetItConditionContext extends DeskConditionContext {
  const _GetItConditionContext();

  @override
  DeskDocument? get document =>
      GetIt.I<DeskDocumentViewModel>().selectedDocument.value.value;

  @override
  T read<T extends Object>() => GetIt.I<T>();
}
```

`DeskForm` constructs this once per render and passes it to every condition:

```dart
// dart_desk/lib/src/studio/components/forms/desk_form.dart
const _ctx = _GetItConditionContext();
final visible = field.option?.condition?.evaluate(_ctx) ?? true;
```

GetIt remains internal. Swapping to a different DI container later is a
local change in `dart_desk`; consumer code never references GetIt.

### Backward compatibility

- `dart_desk` re-exports `DeskDocument` from its previous location so
  existing imports (`package:dart_desk/...`) continue to work.
- `DeskCondition.evaluate` signature changes from
  `bool evaluate(Map<String, dynamic> data)` to
  `bool evaluate(DeskConditionContext ctx)`. This is a breaking change for
  any third-party `DeskCondition` subclasses. Mitigation: built-ins migrate
  in the same patch; the change is mechanical (read from
  `ctx.document?.activeVersionData` instead of `data`); third-party
  conditions outside this monorepo are not believed to exist.
- Annotation grammar is unchanged: `@DeskOption(condition: const X())`
  continues to work; `X.evaluate` simply has a new signature.

## Consumer-side example (HG kiosk)

```dart
// hg_kiosk_data_models — depends only on dart_desk_annotation
class HideWhenDefaultDocument extends DeskCondition {
  const HideWhenDefaultDocument();
  @override
  bool evaluate(DeskConditionContext ctx) =>
      ctx.document?.isDefault != true;
}

class DeviceGroupsDropdownOption extends DeskMultiDropdownOption<DeviceGroup> {
  const DeviceGroupsDropdownOption()
      : super(condition: const HideWhenDefaultDocument());
  // ... existing options() / placeholder / etc.
}
```

A future condition that needs runtime state (e.g. a viewmodel) lives
wherever the heavy types are importable (typically `dart_desk_app`):

```dart
// dart_desk_app or another package that imports dart_desk
class ShowWhenMenuLoaded extends DeskCondition {
  const ShowWhenMenuLoaded();
  @override
  bool evaluate(DeskConditionContext ctx) =>
      ctx.read<MenuConfigCubit>().state.isLoaded;
}
```

## Testing strategy

- **Unit tests for built-ins.** Each migrated built-in
  (`FieldEquals`, `FieldNotEquals`, `FieldNotNull`, `FieldIsNull`,
  `AllConditions`, `AnyCondition`) gets a test that constructs a fake
  `DeskConditionContext` (a test-only subclass returning a stub
  `DeskDocument`) and asserts `evaluate` returns the expected bool.
- **Unit test for `_GetItConditionContext`.** Register a fake
  `DeskDocumentViewModel` with GetIt; verify `document` returns the
  selected document and `read<T>()` resolves a registered service.
- **Widget test for `DeskForm`.** Render a form with a field carrying a
  condition that depends on `ctx.document?.isDefault`; verify visibility
  flips when the selected document's `isDefault` flag flips.

## Patch surface in `dart_desk` repo

1. **`dart_desk_annotation`**
   - Move `DeskDocument` here from `dart_desk`.
   - Add `DeskConditionContext` abstract class.
   - Change `DeskCondition.evaluate` signature.
   - Update built-in `DeskCondition` subclasses (`FieldEquals`,
     `FieldNotEquals`, `FieldNotNull`, `FieldIsNull`, `AllConditions`,
     `AnyCondition`) to the new signature.
2. **`dart_desk`**
   - Delete the relocated `DeskDocument` source; add a re-export shim.
   - Add internal `_GetItConditionContext`.
   - Update `DeskForm` (and any other call sites of
     `DeskCondition.evaluate`) to construct and pass the context.
   - Migrate any in-repo conditions that subclass `DeskCondition` directly.

## Out of scope (this spec)

- HG-side `HideWhenDefaultDocument` and its wiring into
  `DeviceGroupsDropdownOption`. Lives in `hg_kiosk_data_models` once the
  dart_desk patch ships; tracked separately.
- Adding `parent`, `value`, or `currentUser` to context. Add when needed.
