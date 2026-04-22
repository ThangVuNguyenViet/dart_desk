# Unified Array Field Inputs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor `DeskArrayField` to support any field type by introducing a template `innerField` and reusing the global input registry.

**Architecture:** 
1. Update `DeskArray` (annotation) and `DeskArrayField` (runtime) to store an `innerField`.
2. Update `DeskFieldGenerator` to infer this `innerField` for primitives and `@DeskModel` objects.
3. Refactor `DeskArrayInput` to resolve its item editor via the `DeskFieldInputRegistry`.
4. Clean up legacy `itemEditor` logic from `DeskArrayOption`.

**Tech Stack:** Dart (Annotation & Generator), Flutter (UI)

---

### Task 1: Refactor Annotation and Runtime Models

**Files:**
- Modify: `packages/dart_desk_annotation/lib/src/fields/complex/array_field.dart`

- [ ] **Step 1: Update `DeskArrayOption` to be concrete and remove legacy editor methods.**
Remove `abstract` keyword. Remove `itemEditor` and `buildItemEditor`. Add default fallback to `buildItem`.

```dart
class DeskArrayOption<T> extends DeskOption {
  const DeskArrayOption({super.hidden, this.itemBuilder});

  final DeskArrayFieldItemBuilder<T>? itemBuilder;

  Widget buildItem(BuildContext context, T value) {
    return itemBuilder?.call(context, value) ?? Text(value.toString());
  }

  T fromDynamic(dynamic value) => value as T;
}
```

- [ ] **Step 2: Update `DeskArrayField` to store `innerField`.**
Add `final DeskField innerField;` to `DeskArrayField`. Update constructor to require it.

```dart
class DeskArrayField<T> extends DeskField {
  const DeskArrayField({
    required super.name,
    required super.title,
    super.description,
    required this.innerField,
    DeskArrayOption<T>? super.option,
  });

  final DeskField innerField;
  // ... rest of class unchanged
}
```

- [ ] **Step 3: Update `DeskArray` to include `inner` config.**
Add `final DeskFieldConfig? inner;` to `DeskArray`.

```dart
class DeskArray<T> extends DeskFieldConfig {
  const DeskArray({
    super.name,
    super.title,
    super.description,
    this.inner,
    DeskArrayOption<T>? super.option,
  });

  final DeskFieldConfig? inner;
  // ... rest of class unchanged
}
```

- [ ] **Step 4: Commit changes.**

```bash
git add packages/dart_desk_annotation/lib/src/fields/complex/array_field.dart
git commit -m "refactor(annotation): add innerField to DeskArrayField and simplify DeskArrayOption"
```

---

### Task 2: Update Generator Logic

**Files:**
- Modify: `packages/dart_desk_generator/lib/src/generators/desk_field_generator.dart`

- [ ] **Step 1: Refactor `DeskArray` generator logic.**
Update the handler for `DeskArray` in `_fieldConfigs` map to infer `innerField`.

```dart
    'DeskArray': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      final configType = config?.type?.toString() ?? '';
      final genericTypeMatch = RegExp(r'DeskArray<(.+?)>').firstMatch(configType);
      final genericType = genericTypeMatch?.group(1);

      // Handle 'inner' override if present...
      // Handle primitive inference (String, int, etc.)...
      // Handle @DeskModel object inference...

      return '''DeskArrayField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    innerField: $inferredFieldCode,
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
```

- [ ] **Step 2: Commit generator changes.**

```bash
git add packages/dart_desk_generator/lib/src/generators/desk_field_generator.dart
git commit -m "feat(generator): implement automatic innerField inference for DeskArrayField"
```

---

### Task 3: Refactor DeskArrayInput UI

**Files:**
- Modify: `packages/dart_desk/lib/src/inputs/array_input.dart`

- [ ] **Step 1: Replace hardcoded primitive editors with Registry-based editor.**
Update `_buildInlineEditor` to use `DeskFieldInputRegistry.getBuilder(widget.field.innerField)`.

```dart
  Widget _buildInlineEditor(BuildContext context, ShadThemeData theme, {required bool isNew}) {
    // 1. Check for legacy option-based editor (if we decided to keep it, but spec says remove)
    // 2. Use Registry for innerField
    final builder = DeskFieldInputRegistry.getBuilder(widget.field.innerField);
    if (builder != null) {
      return builder(
        widget.field.innerField,
        DeskData(value: _editingValue, path: '${widget.field.name}.[${_editingIndex}]'),
        (_, newValue) => setState(() => _editingValue = newValue),
      );
    }
    return Text('No editor found for item type');
  }
```

- [ ] **Step 2: Update item preview logic.**
Ensure `_buildItemRow` uses the refined `option.buildItem` fallback.

- [ ] **Step 3: Commit UI changes.**

```bash
git add packages/dart_desk/lib/src/inputs/array_input.dart
git commit -m "feat(ui): refactor DeskArrayInput to use global registry for items"
```

---

### Task 4: Verification and Test Updates

**Files:**
- Modify: `packages/dart_desk/test/inputs/array_input_test.dart`
- Create: `examples/data_models/lib/src/configs/array_test_config.dart`

- [ ] **Step 1: Update existing array input tests to match new constructor.**
Fix compiler errors in tests.

- [ ] **Step 2: Create a verification config in `data_models` example.**
Create a config with `List<HeroConfig>` to verify inference.

- [ ] **Step 3: Run code generation in examples.**
Run `dart run build_runner build` in `examples/data_models`.

- [ ] **Step 4: Final verification in the app.**
Verify that the nested hero list renders its fields correctly.

- [ ] **Step 5: Commit verification changes.**

```bash
git add .
git commit -m "test: update array tests and verify with hero list example"
```
