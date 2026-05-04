## 0.3.2

 - **FIX**(annotation): split DeskContext so generator-safe barrel stays Flutter-free (#41).
 - **FIX**(dart_desk): editor footer alignment, clear-to-null, rename defaultValue → initialValue (#16).
 - **FEAT**: DeskConditionContext for runtime-aware field conditions (#14).

## 0.3.1

 - **FIX**(dart_desk): editor footer alignment, clear-to-null, rename defaultValue → initialValue (#16).
 - **FEAT**: DeskConditionContext for runtime-aware field conditions (#14).

## 0.3.0

> **Breaking**: tracks `dart_desk_annotation` 0.3.0. Generated output uses `initialValue` instead of `defaultValue`. Regenerate consumers (`dart run build_runner build`) after upgrading.

 - **FEAT**: nullability-driven `optional_resolver` — `T?` fields generate as optional automatically (#15).
 - **FEAT**: generator support for `DeskConditionContext` runtime conditions on field visibility (#14).
 - **FEAT**: refined per-type field code generators (string, number, color, date, datetime, file, url, boolean, checkbox) for `initialValue` and conditional metadata.
 - **FIX**(dart_desk): editor footer alignment, clear-to-null, rename defaultValue → initialValue (#16).
 - **CHORE**: bump `dart_desk_annotation` to `^0.3.0`.

## 0.2.0

> **Breaking**: `Cms*` prefix renamed to `Desk*` across generated outputs and recognized annotations. Regenerate consumers (`dart run build_runner build`) after upgrading.

- Bump `dart_desk_annotation` to `^0.2.0`
- Generator support for conditional field visibility and dropdown search
- Generator support for UUID models and the unified image input

## 0.1.2

- Pin dependency version: `dart_desk_annotation: ^0.1.1`

## 0.1.1

- Add `FieldCodeGenerator` architecture with string, array, dropdown, and object generators
- Add registry and inference engine for auto-detecting unannotated fields
- Add `DeskMultiDropdown` code generation support
- Auto-infer `innerField` for `DeskArrayField` using naming conventions
- Fix: deduplicate field lists for `@DeskModel`-annotated classes
- Fix: correctly handle unannotated fields in object array items
- Fix: update `build_test` to ^3.0.0 for Dart 3.8+ compatibility

## 0.1.0

- Initial release
- Code generation for CMS document types
- Field configuration generation from annotations
