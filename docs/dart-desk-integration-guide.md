# Dart Desk Integration Guide

Instructions for integrating Dart Desk into an existing Flutter app.

> **TODO:** The dart_desk packages (`dart_desk`, `dart_desk_annotation`, `dart_desk_generator`) have not been published to pub.dev yet. Use git-based dependencies for now:
>
> ```yaml
> dart_desk:
>   git:
>     url: https://github.com/ThangVuNguyenViet/dart_desk.git
>     path: packages/dart_desk
> dart_desk_annotation:
>   git:
>     url: https://github.com/ThangVuNguyenViet/dart_desk.git
>     path: packages/dart_desk_annotation
> dart_desk_generator:
>   git:
>     url: https://github.com/ThangVuNguyenViet/dart_desk.git
>     path: packages/dart_desk_generator
> ```

## Architecture

Integration follows a three-package pattern:

```
dart_desk_app  →  your_app  →  data_models
```

| Package | Purpose |
|---------|---------|
| **data_models** | Shared `@CmsConfig` annotated data classes. Both the app and the dart_desk app depend on this. |
| **your_app** | The real Flutter app. Imports data_models for its data classes. Exposes screen/widget classes that the dart_desk app uses for preview. |
| **dart_desk_app** | Standalone Dart Desk studio. Imports data_models (for generated DocumentTypeSpecs) and your_app (for preview widgets). Calls `typeSpec.build(builder: ...)` to supply the preview widget. Provides mock dependencies the real app normally supplies. |

Dependencies flow in one direction: `dart_desk_app → your_app → data_models`. Never reverse this.

---

## Step 1: Create the data_models package

This package holds annotated data classes shared by both apps.

### pubspec.yaml

```yaml
name: data_models
publish_to: none

environment:
  sdk: ^3.8.0

dependencies:
  flutter:
    sdk: flutter
  dart_desk_annotation: # from pub.dev or path
  dart_mappable: ^4.6.1

dev_dependencies:
  build_runner: ^2.13.1
  dart_mappable_builder: ^4.6.1
  dart_desk_generator: # from pub.dev or path
```

> **Note:** data_models does not depend on your_app. The preview builder is supplied in dart_desk_app, keeping data_models free of app-level dependencies.

### Define a data model

Create a file like `lib/src/configs/my_config.dart`:

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'my_config.cms.g.dart';
part 'my_config.mapper.dart';

@CmsConfig(
  title: 'My Screen',
  description: 'Configuration for the my screen',
)
@MappableClass(ignoreNull: false)
class MyConfig with MyConfigMappable, Serializable<MyConfig> {
  @CmsStringFieldConfig(
    description: 'Main heading text',
    option: CmsStringOption(),
  )
  final String title;

  @CmsImageFieldConfig(
    description: 'Hero banner image',
    option: CmsImageOption(hotspot: false),
  )
  final String imageUrl;

  @CmsBooleanFieldConfig(
    description: 'Show the feature section',
    option: CmsBooleanOption(),
  )
  final bool showFeatures;

  // ... more fields

  const MyConfig({
    required this.title,
    required this.imageUrl,
    required this.showFeatures,
  });

  /// Default values used by the dart_desk editor and preview.
  static MyConfig defaultValue = MyConfig(
    title: 'Welcome',
    imageUrl: '',
    showFeatures: true,
  );
}
```

### Export the models

In `lib/data_models.dart`:

```dart
library;

export 'src/configs/my_config.dart';
```

### Run code generation

```bash
cd data_models
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `my_config.cms.g.dart` — `myConfigFields` list and `myConfigTypeSpec` (DocumentTypeSpec)
- `my_config.mapper.dart` — serialization from dart_mappable

---

## Step 2: Set up your app

Your app is a normal Flutter app. It depends on data_models for shared data classes.

### pubspec.yaml

```yaml
name: your_app
publish_to: none

dependencies:
  flutter:
    sdk: flutter
  data_models:
    path: ../data_models
  # your other dependencies (bloc, riverpod, etc.)
```

### Expose screen widgets

The dart_desk app imports your screen widgets for preview. Make sure they are importable:

```dart
// lib/screens/my_screen.dart
import 'package:data_models/data_models.dart';
import 'package:flutter/material.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key, required this.config});
  final MyConfig config;

  @override
  Widget build(BuildContext context) {
    // Your real app UI
  }
}
```

---

## API Key

> **TODO:** API key authentication is not yet implemented. Once available, you will need an API key to connect the dart_desk_app to the backend. This section will be updated with the configuration details (e.g. how to pass the key to `DartDeskApp`).

## Step 3: Create the dart_desk_app

### pubspec.yaml

```yaml
name: dart_desk_app
publish_to: none

dependencies:
  flutter:
    sdk: flutter
  dart_desk:        # the dart_desk package
  your_app:
    path: ../your_app
  data_models:
    path: ../data_models
  shadcn_ui: ^0.52.1
  dart_mappable: ^4.6.1
  serverpod_flutter: ^3.3.1
  dart_desk_be_client: # path to serverpod client
```

### main.dart

```dart
import 'dart:convert';
import 'package:dart_desk/studio.dart';
import 'package:data_models/data_models.dart';
import 'package:your_app/screens/my_screen.dart';
import 'package:flutter/material.dart';

final _myDocumentType = myConfigTypeSpec.build(
  builder: (data) {
    final merged = {...MyConfig.defaultValue.toMap(), ...data};
    return MyScreen(config: MyConfigMapper.fromMap(merged));
  },
);

void main() {
  runApp(const MyDartDeskApp());
}

class MyDartDeskApp extends StatelessWidget {
  const MyDartDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DartDeskApp(
      serverUrl: 'http://localhost:8080/',
      config: DartDeskConfig(
        documentTypes: [_myDocumentType],
        documentTypeDecorations: [
          DocumentTypeDecoration(
            documentType: _myDocumentType,
            icon: Icons.phone_android,
          ),
        ],
        title: 'My App CMS',
        subtitle: 'Content Management',
        icon: Icons.dashboard,
      ),
    );
  }
}
```

### Mock dependencies for preview

Your app's widgets may depend on providers (BlocProvider, RepositoryProvider, etc.) that aren't available inside the dart_desk studio. You need to wrap the preview with mocks.

The builder passed to `typeSpec.build(builder: ...)` returns your app's raw widget. If that widget expects an ancestor provider, the dart_desk app must supply it.

**Option A: Wrap in main.dart** — if the dependency is app-wide:

```dart
return DartDeskApp(
  serverUrl: 'http://localhost:8080/',
  config: DartDeskConfig(
    documentTypes: [_myDocumentType],
    // ...
  ),
  // Wrap the entire studio with mock providers
  builder: (context, child) => MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(create: (_) => MockAuthBloc()),
      // ... other mock providers your screens need
    ],
    child: child,
  ),
);
```

**Option B: Wrap in the builder** — if only specific screens need it:

```dart
// In dart_desk_app, main.dart
final _myDocumentType = myConfigTypeSpec.build(
  builder: (data) {
    final merged = {...MyConfig.defaultValue.toMap(), ...data};
    final myConfig = MyConfigMapper.fromMap(merged);
    // Wrap with mocks this specific screen needs
    return RepositoryProvider<MyRepo>.value(
      value: MockMyRepo(),
      child: MyScreen(config: myConfig),
    );
  },
);
```

Use whichever approach keeps things simplest. App-wide mocks in main.dart is usually cleaner.

---

## Available field types

Use these annotations on data_models fields:

| Annotation | Dart type | CMS input |
|---|---|---|
| `@CmsStringFieldConfig` | `String` | Single-line text |
| `@CmsTextFieldConfig` | `String` | Multi-line text |
| `@CmsNumberFieldConfig` | `int` / `double` | Number with min/max |
| `@CmsBooleanFieldConfig` | `bool` | Toggle switch |
| `@CmsCheckboxFieldConfig` | `bool` | Checkbox with label |
| `@CmsDateFieldConfig` | `DateTime?` | Date picker |
| `@CmsDateTimeFieldConfig` | `DateTime` | Date + time picker |
| `@CmsImageFieldConfig` | `String` | Image picker (URL) |
| `@CmsFileFieldConfig` | `String?` | File upload |
| `@CmsUrlFieldConfig` | `String?` | URL input |
| `@CmsColorFieldConfig` | `Color` | Color picker |
| `@CmsDropdownFieldConfig<T>` | `T` | Dropdown select |
| `@CmsArrayFieldConfig<T>` | `List<T>` | Repeatable list |
| `@CmsObjectFieldConfig` | Custom class | Nested object |
| `@CmsBlockFieldConfig` | Custom | Block editor |
| `@CmsGeopointFieldConfig` | Custom | Geo coordinates |

Each annotation accepts:
- `description` — Help text shown in the dart_desk editor
- `option` — Type-specific configuration (e.g., `CmsNumberOption(min: 0, max: 100)`)

---

## Custom field options

For dropdowns and arrays, you typically create custom option classes:

```dart
// Custom dropdown
class MyDropdownOption extends CmsDropdownOption<String> {
  const MyDropdownOption();

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?> get defaultValue => 'option_a';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
    DropdownOption(value: 'option_a', label: 'Option A'),
    DropdownOption(value: 'option_b', label: 'Option B'),
  ];
}

// Custom array with item builder/editor
class MyArrayOption extends CmsArrayOption {
  const MyArrayOption();

  @override
  CmsArrayFieldItemBuilder get itemBuilder =>
    (context, value) => Text(value as String);

  @override
  CmsArrayFieldItemEditor get itemEditor =>
    (context, value, onChanged) => ShadInputFormField(
      onChanged: onChanged,
    );
}
```

---

## Custom type mappers

For non-primitive types (like `Color`), provide a mapper:

```dart
@MappableClass(includeCustomMappers: [ColorMapper()])
class MyConfig ...

class ColorMapper extends SimpleMapper<Color> {
  const ColorMapper();

  @override
  Color decode(Object value) {
    if (value is String) {
      final hex = value.replaceFirst('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    }
    throw Exception('Cannot decode Color from $value');
  }

  @override
  Object? encode(Color self) =>
    '#${self.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}
```

---

## Deployment configuration

Create a `dart_desk.yaml` in your dart_desk_app project root. This is used by `dart_desk_cli` for deployment.

```yaml
project_slug: my-project
server: https://api.dartdesk.dev
```

| Field | Required | Description |
|-------|----------|-------------|
| `project_slug` | Yes | URL-safe project identifier for deployment (e.g. `my-project`) |
| `server` | No | Dart Desk server URL. Defaults to `https://api.dartdesk.dev` |

### Deploy with the CLI

```bash
# Install the CLI
dart pub global activate dart_desk_cli

# Log in to your server
dart_desk login

# Deploy the studio
dart_desk deploy

# View deployments
dart_desk deployments
```

---

## Workspace layout

Recommended directory structure:

```
workspace/
├── your_app/           # The real Flutter app
│   ├── lib/
│   │   ├── screens/    # Widgets exposed for preview
│   │   └── ...
│   └── pubspec.yaml
├── data_models/        # Shared annotated data classes
│   ├── lib/
│   │   └── src/configs/
│   │       ├── my_config.dart
│   │       ├── my_config.cms.g.dart   (generated)
│   │       └── my_config.mapper.dart  (generated)
│   └── pubspec.yaml
└── dart_desk_app/      # Dart Desk studio
    ├── lib/
    │   └── main.dart
    ├── dart_desk.yaml   # Deployment config (slug + server)
    └── pubspec.yaml
```

---

## Checklist

- [ ] Create data_models package with `dart_desk_annotation` and `dart_desk_generator` dependencies
- [ ] Define data classes with `@CmsConfig` and field annotations
- [ ] Add `defaultValue` static field to each config class
- [ ] Call `typeSpec.build(builder: ...)` in dart_desk_app, importing the screen widget there
- [ ] Run `dart run build_runner build` in data_models
- [ ] Create dart_desk_app with dependencies on `dart_desk`, `your_app`, and `data_models`
- [ ] Register document types in `DartDeskConfig`
- [ ] Add mock providers for any dependencies your app widgets expect
- [ ] Add `dart_desk.yaml` with `project_slug` and `server` to dart_desk_app root
- [ ] Verify preview renders correctly in the dart_desk studio
