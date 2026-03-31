# Type-Safe CmsArrayField Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `CmsArrayField` generic so builder/editor callbacks are typed, and fail at code-gen time when a non-primitive type is used without an option.

**Architecture:** Add type parameter `T` to `CmsArrayOption`, `CmsArrayField`, and their typedefs. Update the code generator's `CmsArrayFieldConfig` handler to extract `T`, validate primitiveness, and emit typed `CmsArrayField<T>`. Update `array_input.dart` to dispatch default editors per primitive type.

**Tech Stack:** Dart, Flutter, source_gen, build_runner, shadcn_ui

---

## File Map

- **Modify:** `packages/dart_desk_annotation/lib/src/fields/complex/array_field.dart` — add `<T>` to typedefs, option, field, config
- **Modify:** `packages/dart_desk_generator/lib/src/generators/cms_field_generator.dart` — extract generic type, validate, emit typed field
- **Modify:** `packages/dart_desk/lib/src/inputs/array_input.dart` — type-dispatch default editors for primitives
- **Modify:** `packages/dart_desk/lib/src/testing/test_document_types.dart` — update `TestStringArrayOption` to `CmsArrayOption<String>`
- **Modify:** `packages/dart_desk/test/inputs/array_input_test.dart` — update field declarations with `<String>`, add numeric/bool default editor tests

---

### Task 1: Make annotation classes generic

**Files:**
- Modify: `packages/dart_desk_annotation/lib/src/fields/complex/array_field.dart`

- [ ] **Step 1: Update typedefs to be generic**

Replace the entire file content with:

```dart
import 'package:flutter/material.dart';

import '../base/field.dart';

typedef CmsArrayFieldItemBuilder<T> =
    Widget Function(BuildContext context, T value);
typedef CmsArrayFieldItemEditor<T> =
    Widget Function(
      BuildContext context,
      T value,
      ValueChanged<T>? onChanged,
    );

abstract class CmsArrayOption<T> extends CmsOption {
  const CmsArrayOption({super.hidden});

  CmsArrayFieldItemBuilder<T> get itemBuilder;

  /// Override to provide a custom editor widget for array items.
  /// When null, a default editor will be used for primitive types
  /// (String, num, int, double, bool).
  CmsArrayFieldItemEditor<T>? get itemEditor => null;
}

class CmsArrayField<T> extends CmsField {
  const CmsArrayField({
    required super.name,
    required super.title,
    super.description,
    CmsArrayOption<T>? super.option,
  });

  @override
  CmsArrayOption<T>? get option => super.option as CmsArrayOption<T>?;
}

class CmsArrayFieldConfig<T extends Object?> extends CmsFieldConfig {
  const CmsArrayFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsArrayOption<T>? super.option,
  });

  @override
  List<Type> get supportedFieldTypes => [List];
}
```

- [ ] **Step 2: Verify annotation package analyzes cleanly**

Run:
```bash
cd packages/dart_desk_annotation && dart analyze lib/src/fields/complex/array_field.dart
```
Expected: No errors. There may be warnings about unused imports in downstream code — that's expected and fixed in later tasks.

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk_annotation/lib/src/fields/complex/array_field.dart
git commit -m "feat: make CmsArrayOption, CmsArrayField, and typedefs generic on T"
```

---

### Task 2: Update test document types to use typed option

**Files:**
- Modify: `packages/dart_desk/lib/src/testing/test_document_types.dart`
- Modify: `packages/dart_desk/test/inputs/array_input_test.dart`

- [ ] **Step 1: Update TestStringArrayOption**

In `packages/dart_desk/lib/src/testing/test_document_types.dart`, change:

```dart
class TestStringArrayOption extends CmsArrayOption {
  const TestStringArrayOption();

  @override
  CmsArrayFieldItemBuilder get itemBuilder =>
      (context, value) => Text(value?.toString() ?? '');
}
```

to:

```dart
class TestStringArrayOption extends CmsArrayOption<String> {
  const TestStringArrayOption();

  @override
  CmsArrayFieldItemBuilder<String> get itemBuilder =>
      (context, value) => Text(value);
}
```

- [ ] **Step 2: Update CmsArrayField usage in allFieldsDocumentType**

In the same file, change:

```dart
    CmsArrayField(
      name: 'array_field',
      title: 'Array Field',
      description: 'A list of string items',
      option: TestStringArrayOption(),
    ),
```

to:

```dart
    CmsArrayField<String>(
      name: 'array_field',
      title: 'Array Field',
      description: 'A list of string items',
      option: TestStringArrayOption(),
    ),
```

- [ ] **Step 3: Update test file field declarations**

In `packages/dart_desk/test/inputs/array_input_test.dart`, change:

```dart
  final field = CmsArrayField(
    name: 'tags',
    title: 'Tags',
    option: TestStringArrayOption(),
  );
```

to:

```dart
  final field = CmsArrayField<String>(
    name: 'tags',
    title: 'Tags',
    option: TestStringArrayOption(),
  );
```

And the hidden field test — change:

```dart
      final hiddenField = CmsArrayField(
        name: 'hidden',
        title: 'Hidden',
        option: TestStringArrayOption(),
      );
```

to:

```dart
      final hiddenField = CmsArrayField<String>(
        name: 'hidden',
        title: 'Hidden',
        option: TestStringArrayOption(),
      );
```

- [ ] **Step 4: Run existing array input tests**

Run:
```bash
cd packages/dart_desk && flutter test test/inputs/array_input_test.dart
```
Expected: All 4 tests pass.

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk/lib/src/testing/test_document_types.dart packages/dart_desk/test/inputs/array_input_test.dart
git commit -m "refactor: update TestStringArrayOption and field declarations to use typed generics"
```

---

### Task 3: Add default primitive editors to array_input.dart

**Files:**
- Modify: `packages/dart_desk/lib/src/inputs/array_input.dart`
- Modify: `packages/dart_desk/test/inputs/array_input_test.dart`

- [ ] **Step 1: Write tests for default number and bool editors**

Add these tests at the end of the `group('CmsArrayInput', () {` block in `test/inputs/array_input_test.dart`:

```dart
    testWidgets('default number editor parses input as num', (tester) async {
      List? received;
      final numField = CmsArrayField<int>(
        name: 'scores',
        title: 'Scores',
      );

      await tester.pumpWidget(buildInputApp(
        CmsArrayInput(
          field: numField,
          data: CmsData(value: List<int>.from([10]), path: 'scores'),
          onChanged: (v) => received = v,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap Add
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Enter a number
      await tester.enterText(
        find.byType(ShadInputFormField).last,
        '42',
      );
      await tester.pump();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(received, isNotNull);
      expect(received, contains(10));
      expect(received, contains(42));
    });

    testWidgets('default bool editor toggles value', (tester) async {
      List? received;
      final boolField = CmsArrayField<bool>(
        name: 'flags',
        title: 'Flags',
      );

      await tester.pumpWidget(buildInputApp(
        CmsArrayInput(
          field: boolField,
          data: CmsData(value: List<bool>.from([true]), path: 'flags'),
          onChanged: (v) => received = v,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap Add
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // The default bool editor should show a checkbox — tap it to set true
      await tester.tap(find.byType(ShadCheckbox).last);
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(received, isNotNull);
      expect(received, contains(true));
    });

    testWidgets('default string editor works without option', (tester) async {
      List? received;
      final stringField = CmsArrayField<String>(
        name: 'labels',
        title: 'Labels',
      );

      await tester.pumpWidget(buildInputApp(
        CmsArrayInput(
          field: stringField,
          data: CmsData(value: List<String>.from([]), path: 'labels'),
          onChanged: (v) => received = v,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap Add
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(
        find.byType(ShadInputFormField).last,
        'hello',
      );
      await tester.pump();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(received, isNotNull);
      expect(received, contains('hello'));
    });
```

- [ ] **Step 2: Run tests to verify they fail**

Run:
```bash
cd packages/dart_desk && flutter test test/inputs/array_input_test.dart
```
Expected: The new tests fail — the number test produces a String instead of int, the bool test can't find `ShadCheckbox`, the string-without-option test hits the null `option!.itemBuilder` call on line 278.

- [ ] **Step 3: Update _buildInlineEditor with type-dispatched default editors**

In `packages/dart_desk/lib/src/inputs/array_input.dart`, replace the `_buildInlineEditor` method (lines 219-250) with:

```dart
  Widget _buildInlineEditor(
    BuildContext context,
    ShadThemeData theme, {
    required bool isNew,
  }) {
    final editStyle = widget.editStyle;
    if (editStyle is! InlineEditStyles) {
      return const SizedBox.shrink();
    }

    final itemEditor = widget.field.option?.itemEditor;
    if (itemEditor != null) {
      return itemEditor(context, _editingValue, (value) {
        setState(() {
          _editingValue = value;
        });
      });
    }

    // Default editors for primitive types
    final field = widget.field;
    if (field is CmsArrayField<bool>) {
      return ShadCheckbox(
        value: _editingValue as bool? ?? false,
        onChanged: (value) {
          setState(() {
            _editingValue = value;
          });
        },
      );
    }

    if (field is CmsArrayField<int>) {
      return ShadInputFormField(
        key: const ValueKey('array_item_editor'),
        initialValue: _editingValue?.toString() ?? '',
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            _editingValue = int.tryParse(value);
          });
        },
        onSubmitted: (_) => _saveItem(),
        placeholder: const Text('Enter number...'),
      );
    }

    if (field is CmsArrayField<num> || field is CmsArrayField<double>) {
      return ShadInputFormField(
        key: const ValueKey('array_item_editor'),
        initialValue: _editingValue?.toString() ?? '',
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            _editingValue = num.tryParse(value);
          });
        },
        onSubmitted: (_) => _saveItem(),
        placeholder: const Text('Enter number...'),
      );
    }

    // Default: String editor (also used for CmsArrayField<String>)
    return ShadInputFormField(
      key: const ValueKey('array_item_editor'),
      initialValue: _editingValue?.toString() ?? '',
      onChanged: (value) {
        setState(() {
          _editingValue = value;
        });
      },
      onSubmitted: (_) => _saveItem(),
      placeholder: const Text('Enter value...'),
    );
  }
```

- [ ] **Step 4: Update _buildItemRow to handle null option**

In the same file, line 278 currently does `widget.field.option!.itemBuilder(context, _items[index])` which crashes when option is null. Replace the `Expanded` widget in `_buildItemRow` (lines 277-279):

```dart
            Expanded(
              child: widget.field.option?.itemBuilder(context, _items[index])
                  ?? Text(_items[index]?.toString() ?? ''),
            ),
```

- [ ] **Step 5: Run tests to verify they pass**

Run:
```bash
cd packages/dart_desk && flutter test test/inputs/array_input_test.dart
```
Expected: All 7 tests pass (4 existing + 3 new).

- [ ] **Step 6: Commit**

```bash
git add packages/dart_desk/lib/src/inputs/array_input.dart packages/dart_desk/test/inputs/array_input_test.dart
git commit -m "feat: add type-dispatched default editors for primitive array types"
```

---

### Task 4: Add generator validation and typed output

**Files:**
- Modify: `packages/dart_desk_generator/lib/src/generators/cms_field_generator.dart`

- [ ] **Step 1: Update the CmsArrayFieldConfig handler**

In `cms_field_generator.dart`, replace the `'CmsArrayFieldConfig'` entry in `_fieldConfigs` (lines 184-196) with:

```dart
    'CmsArrayFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;

      // Extract T from CmsArrayFieldConfig<T>
      final configType = config?.type?.toString() ?? '';
      final genericTypeMatch = RegExp(
        r'CmsArrayFieldConfig<(.+?)>',
      ).firstMatch(configType);
      final genericType = genericTypeMatch?.group(1) ?? 'dynamic';

      // Validate: non-primitive T requires option
      const primitiveTypes = {'String', 'num', 'int', 'double', 'bool'};
      if (!primitiveTypes.contains(genericType) && optionSource == null) {
        throw InvalidGenerationSourceError(
          'CmsArrayFieldConfig<$genericType> requires an option with '
          'itemBuilder and itemEditor because $genericType is not a '
          'primitive type. Provide a CmsArrayOption<$genericType> subclass.',
          element: field,
        );
      }

      return '''CmsArrayField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
```

- [ ] **Step 2: Verify generator package analyzes cleanly**

Run:
```bash
cd packages/dart_desk_generator && dart analyze lib/src/generators/cms_field_generator.dart
```
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk_generator/lib/src/generators/cms_field_generator.dart
git commit -m "feat: add generator validation for non-primitive CmsArrayFieldConfig without option"
```

---

### Task 5: Run full test suite and verify

**Files:** None (verification only)

- [ ] **Step 1: Run dart_desk widget tests**

Run:
```bash
cd packages/dart_desk && flutter test
```
Expected: All tests pass. If any tests reference `CmsArrayField` without a type parameter and fail, update them to include `<String>` (or the appropriate type).

- [ ] **Step 2: Run annotation package analysis**

Run:
```bash
cd packages/dart_desk_annotation && dart analyze
```
Expected: No errors.

- [ ] **Step 3: Run generator package analysis**

Run:
```bash
cd packages/dart_desk_generator && dart analyze
```
Expected: No errors.

- [ ] **Step 4: Commit if any fixes were needed**

Only if test/analysis failures required fixes:
```bash
git add -A
git commit -m "fix: resolve type parameter issues found during full test suite"
```
