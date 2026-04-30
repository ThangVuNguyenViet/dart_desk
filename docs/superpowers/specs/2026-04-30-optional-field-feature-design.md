# Optional Field Feature — Design

## Goal

Make `DeskOption.optional` a first-class, fully-wired feature: every input
renders an opt-in toggle that nulls the field's value, and the code generator
infers `optional` from Dart-field nullability so users don't have to repeat
themselves.

## Background

`DeskOption.optional` already exists in the base annotation
(`packages/dart_desk_annotation/lib/src/fields/base/field.dart`). Today only
two inputs — `datetime_input.dart` and `file_input.dart` — actually wire it
up to a checkbox + `OptionalFieldWrapper` and emit `null` on toggle off. The
remaining 15 inputs ignore the flag.

The generator currently resolves `optional` from the literal annotation only;
it does not look at Dart-field nullability. So `String? title` annotated with
`@DeskString()` produces `optional: false` even though the type clearly
allows null.

A `Clear` button was recently added (`document_editor.dart:77`) that sets
`editedData.value = {}`. Every input then receives `null` for its field; this
already converges with the new optional-toggle semantics — no special-case
needed.

## Architecture

Two layers, two repos:

1. **Generator** (`packages/dart_desk_generator`) — translate field
   nullability into `optional`.
2. **Runtime inputs** (`packages/dart_desk`) — render an opt-in checkbox
   header plus dimmed body wrapper for every input that supports null.

### Data-vs-UI contract

`editedData[fieldName] == null` is the canonical "absent" state.

| Field type             | UI when value is null                  |
|------------------------|----------------------------------------|
| optional, scalar/object| toggle off, body dimmed                |
| optional, bool         | tri-state checkbox shows indeterminate |
| non-optional           | input shows empty/default editor       |

Required-field validation already exists at save time (or needs to as a
separate concern); this feature inherits whatever validation is there and
does not add new rules.

## Generator changes

**Files:** `packages/dart_desk_generator/lib/src/generators/utils.dart`,
`desk_field_generator.dart`, every
`field_code_generators/*_field_generator.dart`.

### Resolution rules

| Dart type      | Annotation `optional`     | Result                       |
|----------------|---------------------------|------------------------------|
| `String?`      | unset                     | `optional: true` injected    |
| `String?`      | `false` (explicit)        | `optional: false` (override) |
| `String?`      | `true`                    | `optional: true`             |
| `String`       | unset                     | `optional: false`            |
| `String`       | `false`                   | `optional: false`            |
| `String`       | `true`                    | **build error**              |

### New helper in `utils.dart`

```dart
/// Resolves the effective `optional` flag for a field.
///
/// Returns true when the Dart field is nullable, unless the annotation
/// explicitly sets `optional: false`. Throws InvalidGenerationSourceError
/// when a non-nullable field is annotated `optional: true`.
bool resolveOptional({
  required FieldElement field,
  required ConstantReader? config,
  required String? optionalSource, // raw source from annotation, if any
});
```

`isNullable` already exists on `DartType` in this file (`utils.dart:164`).

### Per-generator integration

Every `*_field_generator.dart` has a block of the form:

```dart
final optionalSource = _namedArgumentSource(source, 'optional');
final optional = optionalSource == 'true' ||
    (innerConfig?.getFieldOrNull('optional')?.toBoolValue() ?? false);
```

Replace with `resolveOptional(field: ..., config: ..., optionalSource: ...)`.
The downstream `_optionalOptionTypes` lookup that injects `optional: true`
into the option literal works unchanged with the new resolved value.

### Build error message

```
Field `Article.title` is non-nullable but its @DeskString annotation sets
optional: true. Optional fields can be null at runtime; either change the
field type to `String?` or remove `optional: true`.
```

Emitted via `InvalidGenerationSourceError` with `element: field`.

### `@DeskArray` / `@DeskObject` nesting

Array/object inner-config nullability resolution stays scoped to the inner
field config. Outer optionality follows the outer field's own type
(`List<X>?`).

## Runtime / inputs

### New shared widget

`packages/dart_desk/lib/src/inputs/optional_field_header.dart`:

```dart
class OptionalFieldHeader extends StatelessWidget {
  final String title;
  final bool isOptional;
  final bool isEnabled; // value != null
  final ValueChanged<bool> onToggle;

  const OptionalFieldHeader({
    super.key,
    required this.title,
    required this.isOptional,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      children: [
        Text(title, style: theme.textTheme.small),
        if (isOptional) ...[
          const Spacer(),
          ShadCheckbox(
            value: isEnabled,
            onChanged: onToggle,
          ),
        ],
      ],
    );
  }
}
```

Existing `OptionalFieldWrapper` (dim + ignore-pointer body) is unchanged.

### Per-input integration pattern

```dart
@override
Widget build(BuildContext context) {
  if (widget.field.option.hidden) return const SizedBox.shrink();
  final isOptional = widget.field.option.optional;
  final isEnabled = !isOptional || _value != null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      OptionalFieldHeader(
        title: widget.field.title,
        isOptional: isOptional,
        isEnabled: isEnabled,
        onToggle: _handleOptionalToggle,
      ),
      const SizedBox(height: 8),
      OptionalFieldWrapper(
        isEnabled: isEnabled,
        child: _buildBody(context),
      ),
    ],
  );
}

void _handleOptionalToggle(bool enabled) {
  if (!enabled) {
    setState(() {
      _lastValue = _value;
      _value = null;
    });
    widget.onChanged?.call(null);
  } else {
    final restored = _lastValue ?? _defaultValue;
    setState(() => _value = restored);
    widget.onChanged?.call(restored);
  }
}
```

Toggle off keeps the previous value in widget-local state so toggle-on can
restore it. External value changes (Clear, Discard, version switch) do not
clear `_lastValue`, only the visible `_value`.

### Inputs to migrate

15 inputs gain the optional header + wrapper:

`string_input`, `text_input`, `number_input`, `url_input`, `color_input`,
`date_input`, `datetime_input`, `dropdown_input`, `multi_dropdown_input`,
`geopoint_input`, `image_input`, `file_input`, `array_input`, `block_input`,
`object_input`.

`datetime_input` and `file_input` already follow the shape; convert them to
use `OptionalFieldHeader` for consistency.

### Boolean / checkbox tri-state

`boolean_input.dart` and `checkbox_input.dart` do not get a separate
optional-toggle checkbox. When `optional: true`, render a tri-state checkbox:
`null → false → true → null` on tap.

`shadcn_ui`'s `ShadCheckbox` supports tri-state via `value: bool?`. If the
pinned version doesn't, drop in a small custom widget that cycles via tap
(no design change to spec).

When `optional: false`, behavior is unchanged: two-state.

### Clear interaction

`Clear` already sets `editedData = {}`. Each input then sees its prop value
go to null. Because `isEnabled` is derived from the current value:
- optional fields render checkbox unchecked + dimmed body;
- bool fields with `optional: true` render the indeterminate state;
- non-optional fields render their empty/default editor.

No code change needed in `_clearDocument`. Each input must, however, handle
external value-prop changes correctly in `didUpdateWidget` (audit during
migration; many inputs do this already).

## Testing

### Generator tests

New cases in `packages/dart_desk_generator/test/`:
- `String?` field, no override → generated `option` contains
  `optional: true`.
- `String?` field with `DeskStringOption(optional: false)` → respects
  override.
- `String` field with `DeskStringOption(optional: true)` →
  `InvalidGenerationSourceError` with the exact message above.
- `List<String>?` with `@DeskArray` → outer `optional: true` injected;
  inner element config untouched.
- Existing non-null + no `optional` → unchanged output (regression guard).

### Input rendering — Gallery goldens

18 of 19 input golden tests already use `flutter_test_goldens.Gallery` with
`ColumnSceneLayout`. Add Gallery items per migrated input:
- `optional: true, value: <non-null>` — checkbox checked, body active.
- `optional: true, value: null` — checkbox unchecked, body dimmed.

`string_input_golden_test.dart` already has the "optional / disabled" item;
replicate that across the rest.

For `boolean_input_golden_test.dart` and `checkbox_input_golden_test.dart`:
add `optional: true` items rendering each tri-state value — `null`, `false`,
`true`.

Goldens regenerate via Docker (`scripts/regenerate-goldens.sh`) as today.

### Input interaction — widget tests

Per migrated input, in the existing `*_input_test.dart` (non-golden):
- Toggle off → `onChanged(null)` fired exactly once.
- Toggle on after toggle off → restores last value, `onChanged(lastValue)`
  fired.
- External value flip to null → checkbox reflects it without firing
  `onChanged`.

Boolean/checkbox tri-state:
- `null → false → true → null` cycle on tap, each step fires `onChanged`
  with the right value.

### Studio-level

No required additions to `studio_screens_golden_test.dart`. If
`examples/data_models/` gains nullable fields, the existing chef-preview
golden will naturally show optional toggles end-to-end.

### Out of scope

`image_hotspot_editor_golden_test.dart` uses raw `matchesGoldenFile`, not
Gallery. Migrating it is unrelated cleanup; track separately.

## Migration order

1. Generator: `resolveOptional` helper, per-generator wire-up, build-error
   case, generator tests. Land first so generated code can drive optional
   on existing schemas.
2. Runtime: `OptionalFieldHeader` widget, migrate inputs in
   alphabetical order, refactor `datetime_input` / `file_input` to use the
   shared header.
3. Boolean tri-state: own commit so the cycle UX is reviewable in
   isolation.
4. Tests: gallery golden additions and interaction-test additions land
   alongside the input each covers (TDD-friendly).
5. Showcase: add at least one nullable field per relevant type to
   `examples/data_models/` so reviewers see the feature working through
   codegen → studio → goldens.
