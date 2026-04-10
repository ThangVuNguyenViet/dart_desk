# Unified Array Field Inputs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor `CmsArrayField` to support any field type by introducing a template `innerField` and reusing the global input registry.

**Architecture:** 
1. Update `CmsArrayFieldConfig` (annotation) and `CmsArrayField` (runtime) to store an `innerField`.
2. Update `CmsFieldGenerator` to infer this `innerField` for primitives and `@CmsConfig` objects.
3. Refactor `CmsArrayInput` to resolve its item editor via the `CmsFieldInputRegistry`.
4. Clean up legacy `itemEditor` logic from `CmsArrayOption`.

**Tech Stack:** Dart (Annotation & Generator), Flutter (UI)

---

### Task 1: Refactor Annotation and Runtime Models

**Files:**
- Modify: `packages/dart_desk_annotation/lib/src/fields/complex/array_field.dart`

- [ ] **Step 1: Update `CmsArrayOption` to be concrete and remove legacy editor methods.**
Remove `abstract` keyword. Remove `itemEditor` and `buildItemEditor`. Add default fallback to `buildItem`.

```dart
class CmsArrayOption<T> extends CmsOption {
  const CmsArrayOption({super.hidden, this.itemBuilder});

  final CmsArrayFieldItemBuilder<T>? itemBuilder;

  Widget buildItem(BuildContext context, T value) {
    return itemBuilder?.call(context, value) ?? Text(value.toString());
  }

  T fromDynamic(dynamic value) => value as T;
}
```

- [ ] **Step 2: Update `CmsArrayField` to store `innerField`.**
Add `final CmsField innerField;` to `CmsArrayField`. Update constructor to require it.

```dart
class CmsArrayField<T> extends CmsField {
  const CmsArrayField({
    required super.name,
    required super.title,
    super.description,
    required this.innerField,
    CmsArrayOption<T>? super.option,
  });

  final CmsField innerField;
  // ... rest of class unchanged
}
```

- [ ] **Step 3: Update `CmsArrayFieldConfig` to include `inner` config.**
Add `final CmsFieldConfig? inner;` to `CmsArrayFieldConfig`.

```dart
class CmsArrayFieldConfig<T> extends CmsFieldConfig {
  const CmsArrayFieldConfig({
    super.name,
    super.title,
    super.description,
    this.inner,
    CmsArrayOption<T>? super.option,
  });

  final CmsFieldConfig? inner;
  // ... rest of class unchanged
}
```

- [ ] **Step 4: Commit changes.**

```bash
git add packages/dart_desk_annotation/lib/src/fields/complex/array_field.dart
git commit -m "refactor(annotation): add innerField to CmsArrayField and simplify CmsArrayOption"
```

---

### Task 2: Update Generator Logic

**Files:**
- Modify: `packages/dart_desk_generator/lib/src/generators/cms_field_generator.dart`

- [ ] **Step 1: Refactor `CmsArrayFieldConfig` generator logic.**
Update the handler for `CmsArrayFieldConfig` in `_fieldConfigs` map to infer `innerField`.

```dart
    'CmsArrayFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      final configType = config?.type?.toString() ?? '';
      final genericTypeMatch = RegExp(r'CmsArrayFieldConfig<(.+?)>').firstMatch(configType);
      final genericType = genericTypeMatch?.group(1);

      // Handle 'inner' override if present...
      // Handle primitive inference (String, int, etc.)...
      // Handle @CmsConfig object inference...

      return '''CmsArrayField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    innerField: $inferredFieldCode,
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
```

- [ ] **Step 2: Commit generator changes.**

```bash
git add packages/dart_desk_generator/lib/src/generators/cms_field_generator.dart
git commit -m "feat(generator): implement automatic innerField inference for CmsArrayField"
```

---

### Task 3: Refactor CmsArrayInput UI

**Files:**
- Modify: `packages/dart_desk/lib/src/inputs/array_input.dart`

- [ ] **Step 1: Replace hardcoded primitive editors with Registry-based editor.**
Update `_buildInlineEditor` to use `CmsFieldInputRegistry.getBuilder(widget.field.innerField)`.

```dart
  Widget _buildInlineEditor(BuildContext context, ShadThemeData theme, {required bool isNew}) {
    // 1. Check for legacy option-based editor (if we decided to keep it, but spec says remove)
    // 2. Use Registry for innerField
    final builder = CmsFieldInputRegistry.getBuilder(widget.field.innerField);
    if (builder != null) {
      return builder(
        widget.field.innerField,
        CmsData(value: _editingValue, path: '${widget.field.name}.[${_editingIndex}]'),
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
git commit -m "feat(ui): refactor CmsArrayInput to use global registry for items"
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
