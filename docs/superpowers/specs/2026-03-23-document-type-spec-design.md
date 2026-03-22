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

```dart
class DocumentTypeSpec<T> {
  final String name;
  final String title;
  final String description;
  final List<CmsField> fields;
  final T defaultValue;

  const DocumentTypeSpec({
    required this.name,
    required this.title,
    required this.description,
    required this.fields,
    required this.defaultValue,
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

`build()` takes `builder` as a required named parameter. Missing it is a compile error.

### Generator change

The generator (`dart_desk_generator`) stops emitting `DocumentType` and instead emits `DocumentTypeSpec`. The generated variable is renamed from `*DocumentType` to `*TypeSpec`.

**Before (generates `DocumentType` with builder pointing to static method on the model):**
```dart
final homeScreenConfigDocumentType = DocumentType<HomeScreenConfig>(
  name: 'homeScreenConfig',
  title: 'Home Screen',
  description: '...',
  fields: homeScreenConfigFields,
  builder: HomeScreenConfig.configBuilder,  // ← imports app widget
  defaultValue: HomeScreenConfig.defaultValue,
);
```

**After (generates `DocumentTypeSpec`, no builder):**
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

`configBuilder` static method is removed from `@CmsConfig` annotated classes. The model becomes a pure data class with no widget imports.

**Before:**
```dart
@CmsConfig(title: 'Home Screen', description: '...')
class HomeScreenConfig with HomeScreenConfigMappable, Serializable<HomeScreenConfig> {
  // ...fields...

  static Widget configBuilder(Map<String, dynamic> config) {
    import 'package:your_app/screens/home_screen.dart'; // ← causes circular dep
    return HomeScreen(config: HomeScreenConfigMapper.fromMap(config));
  }
}
```

**After:**
```dart
@CmsConfig(title: 'Home Screen', description: '...')
class HomeScreenConfig with HomeScreenConfigMappable, Serializable<HomeScreenConfig> {
  // ...fields only, no configBuilder, no widget imports...
}
```

### cms_app usage

`cms_app` calls `.build(builder: ...)` to produce the final `DocumentType`:

```dart
// cms_app/lib/document_types.dart
import 'package:data_models/data_models.dart';
import 'package:your_app/screens/home_screen.dart';

final homeScreenConfigDocumentType = homeScreenConfigTypeSpec.build(
  builder: (data) => HomeScreen(
    config: HomeScreenConfigMapper.fromMap({
      ...HomeScreenConfig.defaultValue.toMap(),
      ...data,
    }),
  ),
);
```

This is then passed to `DartDeskConfig` as before.

## Dependency graph after

```
cms_app  →  your_app   (for screen widgets in builders)
cms_app  →  data_models (for typeSpecs + model classes)
your_app →  data_models (for model data classes)
```

No circular dependency. `data_models` has no dependency on `your_app`.

## Files to change

| File | Change |
|------|--------|
| `packages/dart_desk_annotation/lib/src/config.dart` | Add `DocumentTypeSpec<T>` class |
| `packages/dart_desk_annotation/lib/dart_desk_annotation.dart` | Export `DocumentTypeSpec` |
| `packages/dart_desk_generator/lib/src/generators/cms_field_generator.dart` | Emit `DocumentTypeSpec` + rename variable to `*TypeSpec` |
| `examples/data_models/lib/src/configs/home_screen_config.dart` | Remove `configBuilder` static method and `example_app` import |
| `examples/data_models/pubspec.yaml` | Remove `example_app` dependency |
| `examples/cms_app/lib/main.dart` | Add builder inline, call `.build(builder: ...)` |
| `docs/dart-desk-integration-guide.md` | Update code examples to reflect new pattern |

## Integration guide impact

The guide's data model example removes `configBuilder`. The cms_app `main.dart` example gains a builder call per document type.
