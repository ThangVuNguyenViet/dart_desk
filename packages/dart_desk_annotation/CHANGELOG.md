## 0.3.1

 - **FIX**(image_input): deep-equal DeskData.value to stop rebuild churn (#31).
 - **FIX**(dart_desk): editor footer alignment, clear-to-null, rename defaultValue → initialValue (#16).
 - **FEAT**(image_input): scale slider in Edit Framing transform mode (#39).
 - **FEAT**: image transform (scale + offset) + slide-over Edit Framing (#35).
 - **FEAT**(dart_desk): DeskContext cross-document lookup for builders (#17).
 - **FEAT**: DeskConditionContext for runtime-aware field conditions (#14).

## 0.3.0

> **Breaking**: `defaultValue` renamed to `initialValue` on `DeskField` and subclasses (#16). Find/replace `defaultValue:` → `initialValue:` on annotation usages.

 - **FEAT**: add `scale`, `offset`, `hotspot`, `crop` to `ImageReference` for the image transform pipeline (#35).
 - **FEAT**: `DeskConditionContext` for runtime-aware field visibility (#14).
 - **FEAT**: nullability-driven optional field semantics (#15).
 - **FEAT**(dart_desk): DeskContext cross-document lookup for builders (#17).
 - **FIX**(image_input): deep-equal `DeskData.value` to stop rebuild churn (#31).
 - **FIX**(dart_desk): editor footer alignment, clear-to-null, rename defaultValue → initialValue (#16).

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
