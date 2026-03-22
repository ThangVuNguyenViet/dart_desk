# Design: DocumentTypeSpec — Remove Circular Dependency

**Date:** 2026-03-23
**Status:** Approved

## Problem

The current three-package architecture has a circular dependency:

```
data_models → your_app   (configBuilder uses app screen widgets)
your_app    → data_models (data classes)
```

`data_models` has a `configBuilder` static method on each `@CmsConfig` class that imports and returns a screen widget from `your_app`. This was done so the generated `DocumentType` could include the preview builder. But it makes `data_models` depend on `your_app`, creating a cycle.

## Goal

- `data_models` must not depend on `your_app`
- The preview builder must still be required (compile-time enforcement — cannot forget to supply it)
- `cms_app`, which already depends on both packages, supplies the builder

## Design

### New class: `DocumentTypeSpec<T>`

Added to `dart_desk_annotation` so `data_models` can use it without importing `dart_desk`.

Note: `dart_desk_annotation` already depends on `package:flutter/widgets.dart` (via `DocumentType`), so `DocumentTypeSpec.build()` returning a `Widget` function does not introduce any new Flutter dependency.

```dart
class DocumentTypeSpec<T extends Serializable<dynamic>> {
  final String name;
  final String title;
  final String description;
  final List<CmsField> fields;
  final T? defaultValue; // nullable to match DocumentType<T>.defaultValue

  const DocumentTypeSpec({
    required this.name,
    required this.title,
    required this.description,
    required this.fields,
    this.defaultValue,
  });

  DocumentType<T> build({
    required Widget Function(Map<String, dynamic>) builder,
  }) {
    return DocumentType<T>(
      name: name,
      title: title,
      description: description,
      fields: fields,
      builder: builder,
      defaultValue: defaultValue,
    );
  }
}
```

The `T extends Serializable<dynamic>` bound matches the existing `DocumentType<T>` constraint.
`defaultValue` is nullable and optional, matching the existing `DocumentType<T>.defaultValue` field.

### Generator change

The generator (`dart_desk_generator`, `CmsFieldGenerator`) stops emitting `DocumentType` and instead emits `DocumentTypeSpec`. The generated variable is renamed from `*DocumentType` to `*TypeSpec`.

The `CmsConfigGenerator` (which emits the `*CmsConfig` wrapper class) is unaffected.

**Before:**
```dart
final homeScreenConfigDocumentType = DocumentType<HomeScreenConfig>(
  name: 'homeScreenConfig',
  title: 'Home Screen',
  description: '...',
  fields: homeScreenConfigFields,
  builder: HomeScreenConfig.configBuilder,  // ← app widget import
  defaultValue: HomeScreenConfig.defaultValue,
);
```

**After:**
```dart
final homeScreenConfigTypeSpec = DocumentTypeSpec<HomeScreenConfig>(
  name: 'homeScreenConfig',
  title: 'Home Screen',
  description: '...',
  fields: homeScreenConfigFields,
  defaultValue: HomeScreenConfig.defaultValue,
);
```

### Model class change

`configBuilder` static method is removed from `@CmsConfig` annotated classes. All screen widget imports are removed. The model becomes a pure data class (no widget imports beyond what `dart_desk_annotation` itself brings via Flutter).

### cms_app usage

`cms_app` calls `.build(builder: ...)` to produce the final `DocumentType`. The builder carries any field normalization logic that was previously in `configBuilder` (e.g. JSON string → List normalization for array fields).

```dart
// cms_app/lib/document_types.dart
import 'package:data_models/data_models.dart';
import 'package:example_app/screens/home_screen.dart';
import 'dart:convert';

final homeScreenConfigDocumentType = homeScreenConfigTypeSpec.build(
  builder: (data) {
    final merged = {...HomeScreenConfig.defaultValue.toMap(), ...data};

    // Normalize fields that may be stored as JSON strings instead of Lists
    final featuredItems = merged['featuredItems'];
    if (featuredItems is String) {
      try {
        merged['featuredItems'] = jsonDecode(featuredItems);
      } catch (_) {
        merged['featuredItems'] = <String>[];
      }
    }

    return HomeScreen(config: HomeScreenConfigMapper.fromMap(merged));
  },
);
```

This is then passed to `DartDeskConfig` as before.

## Dependency graph after

```
cms_app  →  your_app    (for screen widgets in builders)
cms_app  →  data_models (for typeSpecs + model classes)
your_app →  data_models (for model data classes)
```

No circular dependency. `data_models` has no dependency on `your_app`.

## Migration

This is currently an internal examples-only change — there are no external consumers of the generated API. No deprecation aliases are needed. The rename from `*DocumentType` to `*TypeSpec` is a clean break.

## Files to change

| File | Change |
|------|--------|
| `packages/dart_desk_annotation/lib/src/config.dart` | Add `DocumentTypeSpec<T>` class |
| `packages/dart_desk_annotation/lib/dart_desk_annotation.dart` | Export `DocumentTypeSpec` |
| `packages/dart_desk_generator/lib/src/generators/cms_field_generator.dart` | Emit `DocumentTypeSpec` + rename variable to `*TypeSpec`, remove builder emission |
| `examples/data_models/lib/src/configs/home_screen_config.dart` | Remove `configBuilder` static method and `example_app` import |
| `examples/data_models/lib/src/configs/home_screen_config.cms.g.dart` | Regenerate — will rename `homeScreenConfigDocumentType` to `homeScreenConfigTypeSpec` |
| `examples/data_models/pubspec.yaml` | Remove `example_app` dependency |
| `examples/cms_app/lib/main.dart` | Add builder inline, call `.build(builder: ...)`, update reference from `homeScreenConfigDocumentType` to result of `.build()` |
| `examples/cms_app/pubspec.yaml` | Add `example_app` as a direct dependency (it was previously only a transitive dep via data_models) |
| `docs/dart-desk-integration-guide.md` | Update code examples to reflect new pattern |
