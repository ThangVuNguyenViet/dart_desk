# Type-Safe CmsArrayField Design

**Date:** 2026-03-31
**Status:** Draft

## Problem

`CmsArrayFieldConfig` and `CmsArrayField` use `dynamic` throughout their builder/editor typedefs. When `option` is null, the default editor only works for `String`, but the type system doesn't enforce this. Developers can write `CmsArrayFieldConfig<MyModel>()` without an option and only discover the problem at runtime.

## Solution

Make the array field classes generic (`CmsArrayOption<T>`, `CmsArrayField<T>`) so builder/editor callbacks receive typed `T` instead of `dynamic`. Add generator-level validation that fails `build_runner` when a non-primitive `T` is used without providing an option.

Primitive types that get default editors: `String`, `num`, `int`, `double`, `bool`.

## Changes

### 1. Annotation classes (`dart_desk_annotation` — `array_field.dart`)

Make typedefs, option, field, and config generic on `T`:

- `CmsArrayFieldItemBuilder<T>` — `Widget Function(BuildContext context, T value)`
- `CmsArrayFieldItemEditor<T>` — `Widget Function(BuildContext context, T value, ValueChanged<T>? onChanged)`
- `CmsArrayOption<T> extends CmsOption` — `itemBuilder` returns `CmsArrayFieldItemBuilder<T>`, `itemEditor` returns `CmsArrayFieldItemEditor<T>?`
- `CmsArrayField<T> extends CmsField` — `option` typed as `CmsArrayOption<T>?`
- `CmsArrayFieldConfig<T>` — `option` typed as `CmsArrayOption<T>?` (already generic, just tighten the option type)

### 2. Generator validation (`dart_desk_generator` — `cms_field_generator.dart`)

In the `CmsArrayFieldConfig` handler:

1. Extract `T` from `CmsArrayFieldConfig<T>` using the same regex pattern as `CmsDropdownFieldConfig`
2. Define primitive set: `{'String', 'num', 'int', 'double', 'bool'}`
3. If `T` is not in the primitive set and `optionSource` is null, throw `InvalidGenerationSourceError` with a clear message telling the developer to provide a `CmsArrayOption<T>` subclass
4. Emit `CmsArrayField<T>(...)` with the generic type parameter (currently emits untyped `CmsArrayField`)

### 3. Input widget (`dart_desk` — `array_input.dart`)

Update `_buildInlineEditor` to provide default editors by checking the field's generic type at runtime:

- `CmsArrayField<String>` — `ShadInputFormField` (current default, unchanged)
- `CmsArrayField<int>`, `CmsArrayField<num>`, `CmsArrayField<double>` — `ShadInputFormField` with `keyboardType: TextInputType.number`, parsing via `num.tryParse`
- `CmsArrayField<bool>` — `ShadCheckbox`
- Fallback — `Text('No editor available')` (unreachable if generator validation works)

The `_items` list and `_editingValue` remain `dynamic` internally since `CmsArrayInput` receives `CmsArrayField` (erased). The type safety lives in the option's builder/editor signatures.

### 4. Test document types

Update `TestStringArrayOption` to extend `CmsArrayOption<String>` and use typed builder/editor signatures.

### 5. Generator export barrel

`dart_desk_annotation_generator.dart` deliberately excludes Flutter-dependent files (including `array_field.dart`). The generator accesses `CmsArrayFieldConfig` through annotation metadata, not direct import, so no change needed to the barrel.

## Usage

```dart
// Primitive — no option needed
@CmsArrayFieldConfig<String>()
final List<String> tags;

@CmsArrayFieldConfig<int>()
final List<int> scores;

// Custom type — option required
@CmsArrayFieldConfig<MyModel>(option: MyModelArrayOption())
final List<MyModel> items;

// Custom type without option — build_runner error:
// SEVERE: CmsArrayFieldConfig<MyModel> requires an option with itemBuilder
// and itemEditor because MyModel is not a primitive type.
@CmsArrayFieldConfig<MyModel>()  // ❌ fails at code-gen time
final List<MyModel> items;
```

## Scope

- No changes to `CmsForm`, `CmsFieldInputRegistry`, or the field dispatch logic
- No changes to other field types
- No new files created
- Files modified: `array_field.dart` (annotation), `cms_field_generator.dart` (generator), `array_input.dart` (widget), `test_document_types.dart` (tests)
