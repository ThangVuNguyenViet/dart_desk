# Multi-Select Dropdown Field Design

**Date:** 2026-03-22
**Status:** Approved

## Goal

Add a `CmsMultiDropdownField<T>` that supports selecting multiple values using `ShadSelect<T>.multiple()`, separate from the existing single-select `CmsDropdownField<T>`.

## Design Decisions

- **Separate field type** (not a config on existing dropdown) because the value types differ: `T?` (single) vs `List<T>` (multi).
- **Data storage:** `List<T>` in the document data map. Converted to `Set<T>` at the widget boundary for `ShadSelect.multiple()`.
- **`minSelected` / `maxSelected`:** Both nullable (no constraints by default). When set, enforced at the widget level.

## Changes

### 1. Annotation Package (`dart_desk_annotation`)

**File:** `lib/src/fields/complex/dropdown_field.dart`

Add after existing classes:

```dart
abstract class CmsMultiDropdownOption<T> extends CmsOption {
  FutureOr<List<DropdownOption<T>>> options(BuildContext context);
  List<T>? get defaultValues;
  String? get placeholder;
  int? get minSelected;
  int? get maxSelected;
}

class CmsMultiDropdownSimpleOption<T> extends CmsMultiDropdownOption<T> {
  final List<DropdownOption<T>> _options;

  @override
  FutureOr<List<DropdownOption<T>>> options(BuildContext context) => _options;

  @override
  final List<T>? defaultValues;
  @override
  final String? placeholder;
  @override
  final int? minSelected;
  @override
  final int? maxSelected;

  const CmsMultiDropdownSimpleOption({
    super.hidden,
    required List<DropdownOption<T>> options,
    this.defaultValues,
    this.placeholder,
    this.minSelected,
    this.maxSelected,
  }) : _options = options;
}

class CmsMultiDropdownField<T> extends CmsField {
  const CmsMultiDropdownField({
    required super.name,
    required super.title,
    super.description,
    required CmsMultiDropdownOption<T> super.option,
  });

  @override
  CmsMultiDropdownOption<T> get option =>
      super.option as CmsMultiDropdownOption<T>;
}
```

Reuses existing `DropdownOption<T>` class.

**File:** `lib/dart_desk_annotation.dart` — already exports `dropdown_field.dart`, no change needed.

### 2. Widget Package (`dart_desk`)

**New file:** `lib/src/inputs/multi_dropdown_input.dart`

```dart
class CmsMultiDropdownInput<T> extends StatelessWidget
```

- Same async/sync options resolution pattern as `CmsDropdownInput`
- Delegates to `_CmsMultiDropdownInput<T>` (stateful)

```dart
class _CmsMultiDropdownInput<T> extends StatefulWidget
```

Widget behavior:
- Uses `ShadSelect<T>.multiple()`
- `allowDeselection: true` (unless `minSelected` would be violated)
- `closeOnSelect: false`
- `selectedOptionsBuilder`: shows comma-joined labels of selected options
- Controller initialized from `List<T>` data → `Set<T>`
- `onChanged` receives `Set<T>`, calls back with `List<T>`
- `minSelected` enforcement: `allowDeselection` is rebuilt dynamically via `setState` — set to `false` when current selection count equals `minSelected`. If incoming data violates `minSelected` (e.g., `[]` with `minSelected: 1`), allow it — the widget doesn't auto-correct, it just prevents further deselection once at minimum.
- `maxSelected` enforcement: In `onChanged`, if a new selection would exceed `maxSelected`, ignore the addition (don't update controller). `ShadSelect.multiple` has no built-in max, so this is handled in the `onChanged` callback.
- `didUpdateWidget`: When `data` changes externally, update the controller to match (same pattern as single-select).

**File:** `lib/dart_desk.dart` — add export for `multi_dropdown_input.dart`.

### 3. CmsForm Field Routing

**File:** `lib/src/studio/components/forms/cms_form.dart`

Add case after `CmsDropdownField` (line ~108):

```dart
case CmsMultiDropdownField<dynamic>():
  return (_, data, onChanged) => CmsMultiDropdownInput(
        field: field as CmsMultiDropdownField,
        data: data,
        onChanged: (value) => onChanged(field.name, value),
      );
```

Note: `FieldInputBuilder` typedef is `Widget Function(CmsField?, CmsData?, OnFieldChanged)` — 3 params, no context. `OnFieldChanged` is non-nullable. The raw type cast (`CmsMultiDropdownField` without type param) is intentional, matching existing `CmsDropdownField` pattern.

### 4. Test Document Types Update

**File:** `lib/src/testing/test_document_types.dart`

- Change `TestDocumentRefDropdownOption` from extending `CmsDropdownOption<String>` to extending `CmsMultiDropdownOption<String>`
- Update overrides: `defaultValue` → `defaultValues`, add `minSelected`/`maxSelected` (null)
- Change the `document_ref_dropdown` field from `CmsDropdownField` to `CmsMultiDropdownField`
- Update seed data: `'document_ref_dropdown': null` → `'document_ref_dropdown': []` (empty list)
- Update preview line to handle `List` display

### 5. Test Updates

**Files to update:**
- `test/studio/editor_preview_widget_test.dart` — update the 3 `document_ref_dropdown` preview tests (lines ~383-431) to seed `List<String>` values instead of `String`. Preview text changes from `preview:document_ref_dropdown: 2 (Test Document Beta)` to `preview:document_ref_dropdown: [2] (Test Document Beta)` format (comma-joined titles for multiple).
- `test/studio/context_aware_dropdown_test.dart` — only the `_ContextAwareDropdownOption` class and tests in the "Context-aware CmsDropdownOption" group (4 tests) need updating to use `CmsMultiDropdownOption`. The "Simplified documentsContainer" group (5 tests) and "CmsDocumentListView" group (3 tests) are unaffected — they don't use the dropdown option class.

**New test file:** `test/inputs/multi_dropdown_input_test.dart`
- Static options render correctly
- Multi-select: selecting multiple options works
- `minSelected` / `maxSelected` enforcement
- Empty options shows "No options available"
- Async options load correctly
- `didUpdateWidget`: controller updates when data changes externally

### 6. QA Test Plan Update

**File:** `tests/qa/tests/16_context_aware_dropdown_e2e.md`

Update TC-16-01 through TC-16-04 to verify multi-select behavior instead of single-select.

## Data Flow

```
data['tags'] (List<T>) → Set<T> (ShadSelect controller) → Set<T> (onChanged) → List<T> (callback to data map)
```

## Files Modified

| File | Change |
|------|--------|
| `packages/dart_desk_annotation/lib/src/fields/complex/dropdown_field.dart` | Add `CmsMultiDropdownOption`, `CmsMultiDropdownSimpleOption`, `CmsMultiDropdownField` |
| `packages/dart_desk/lib/src/inputs/multi_dropdown_input.dart` | New file: `CmsMultiDropdownInput` widget |
| `packages/dart_desk/lib/dart_desk.dart` | Export new input |
| `packages/dart_desk/lib/src/studio/components/forms/cms_form.dart` | Add routing case |
| `packages/dart_desk/lib/src/testing/test_document_types.dart` | Update to use multi-dropdown |
| `packages/dart_desk/test/inputs/multi_dropdown_input_test.dart` | New test file |
| `packages/dart_desk/test/studio/editor_preview_widget_test.dart` | Update preview tests |
| `packages/dart_desk/test/studio/context_aware_dropdown_test.dart` | Update context-aware tests |
| `packages/dart_desk/tests/qa/tests/16_context_aware_dropdown_e2e.md` | Update E2E test plan |
