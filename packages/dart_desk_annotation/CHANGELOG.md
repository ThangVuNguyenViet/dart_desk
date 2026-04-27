## 0.2.0

> **Breaking**: `Cms*` prefix renamed to `Desk*` across all annotations and types. Run a workspace-wide find/replace from `Cms` to `Desk` on imports and identifiers from this package.

- Add conditional field visibility (`visibleWhen`) and dropdown search support
- Add `DeskUuid` field type and UUID model support
- Refine image/media field annotations for the unified image input pipeline

## 0.1.1

- Add `DeskMultiDropdown` annotation and `DeskMultiDropdownOption`
- Add `innerField` to `DeskArrayField` for typed array item inference
- Add `DeskObject` with `$fromMap` contract for nested object types
- Simplify `DeskArrayOption` API
- Remove deprecated fields from `DeskData`

## 0.1.0

- Initial release
- Field annotations for primitive, complex, and media types
- Validator support via `DeskValidator`
- CMS data model configuration annotations
