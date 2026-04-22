# Design Spec: Unified Array Field Inputs

**Date:** 2026-04-05
**Topic:** ArrayField default inputs should support all kinds of fields out of the box.

## Goal
Currently, `DeskArrayField` only supports primitive types (`String`, `num`, `int`, `double`, `bool`) in its default editor. We want it to support any `DeskField` (images, objects, colors, custom types, etc.) by reusing the existing `DeskFieldInputRegistry`.

## Architecture

### 1. Annotation & Runtime Models
We will introduce the concept of an `innerField` for every `DeskArrayField`. This field acts as a template for how a single item in the list should be edited.

- **`DeskArray<T>` (Annotation):**
  - Add an optional `inner` parameter of type `DeskFieldConfig?`.
  - If provided, this explicit config will be used for items.
  - If not, the generator will infer the correct field from `T`.

- **`DeskArrayField<T>` (Runtime):**
  - Add a required `innerField` parameter of type `DeskField`.
  - This field will be used by the UI to resolve the input builder.

- **`DeskArrayOption<T>` Refinement:**
  - **Remove** `itemEditor` and `buildItemEditor`. This logic is now handled by the `innerField`.
  - **Make Concrete:** Remove the `abstract` keyword so it can be used without subclassing for simple lists.
  - **Fallback Preview:** `buildItem` will fallback to `Text(value.toString())` if no custom item builder is provided.

### 2. Generator Logic (`DeskFieldGenerator`)
The generator will be enhanced to handle `DeskArray<T>` more intelligently:

1.  **Explicit Overrides:** If `inner` is set, generate its corresponding `DeskField`.
2.  **Primitive Inference:** If `T` is a primitive, generate `DeskStringField`, `DeskNumberField`, etc.
3.  **Object Inference:** If `T` is a class annotated with `@DeskModel`, generate a `DeskObjectField` using that class's generated fields list (e.g., `heroConfigFields`).
4.  **Error Handling:** Throw a descriptive error if `T` is not supported and no `inner` is provided.

**Example Generated Code (`heroConfigFields`):**
```dart
DeskArrayField<HeroConfig>(
  name: 'heroes',
  title: 'Heroes',
  innerField: DeskObjectField(
    name: 'item',
    title: 'Hero',
    option: DeskObjectOption(
      children: [ColumnFields(children: heroConfigFields)],
    ),
  ),
)
```

### 3. UI Logic (`DeskArrayInput`)
We will refactor `DeskArrayInput` to remove hardcoded primitive switches:

1.  **Item Editor:** Instead of checking for `T is String`, etc., it will call:
    ```dart
    final builder = DeskFieldInputRegistry.getBuilder(widget.field.innerField);
    return builder!(
      widget.field.innerField,
      DeskData(value: value, path: itemPath),
      (_, newValue) => onChanged(newValue),
    );
    ```
2.  **Item Preview:** Reuses `widget.field.option?.buildItem(...)` if available, otherwise falls back to `toString()`.

## Components
- `DeskArray` (Annotation)
- `DeskArrayField` (Runtime Field)
- `DeskArrayInput` (UI Widget)
- `DeskFieldGenerator` (Code Generation)

## Testing Strategy
1.  **Unit Tests:** Verify the generator produces correct `DeskArrayField` instances for primitives and complex objects.
2.  **UI Integration:** Create an example in `example_app` that uses a `List<HeroConfig>` and verify that the nested editors work correctly.
3.  **Manual Verification:** Ensure that images and colors work inside an array by using explicit `inner` overrides.

## Success Criteria
- [ ] `List<String>` works with a standard string input.
- [ ] `List<HeroConfig>` automatically renders a nested object form for each item.
- [ ] Custom fields registered in `DeskFieldInputRegistry` work as array items.
- [ ] Explicitly overriding an array's item field (e.g., using `DeskImage`) works as expected.
