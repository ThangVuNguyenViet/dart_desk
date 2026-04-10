## 0.1.2

- Pin dependency version: `dart_desk_annotation: ^0.1.1`

## 0.1.1

- Add `FieldCodeGenerator` architecture with string, array, dropdown, and object generators
- Add registry and inference engine for auto-detecting unannotated fields
- Add `CmsMultiDropdownFieldConfig` code generation support
- Auto-infer `innerField` for `CmsArrayField` using naming conventions
- Fix: deduplicate field lists for `@CmsConfig`-annotated classes
- Fix: correctly handle unannotated fields in object array items
- Fix: update `build_test` to ^3.0.0 for Dart 3.8+ compatibility

## 0.1.0

- Initial release
- Code generation for CMS document types
- Field configuration generation from annotations
