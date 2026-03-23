# dart_desk_generator

A code generator for the [Dart Desk](https://github.com/vietthangvunguyen/dart_desk) CMS framework. Generates CMS field configuration and document type code from annotations at build time using `build_runner`.

## Installation

Add `dart_desk_generator` and `build_runner` to your `dev_dependencies`, along with `dart_desk_annotation` in your regular dependencies:

```yaml
dependencies:
  dart_desk_annotation: ^0.1.0

dev_dependencies:
  dart_desk_generator: ^0.1.0
  build_runner: ^2.13.1
```

## Usage

### 1. Annotate your models

Use annotations from [`dart_desk_annotation`](https://pub.dev/packages/dart_desk_annotation) to mark your classes for code generation:

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

@CmsConfig(
  title: 'Blog Post',
  description: 'A blog post document type',
)
class BlogPost {
  final String title;
  final String body;

  BlogPost({required this.title, required this.body});
}
```

### 2. Run the code generator

```sh
dart run build_runner build
```

Or to watch for changes during development:

```sh
dart run build_runner watch
```

### 3. Optional: configure via build.yaml

You can customize builder behavior in a `build.yaml` file at the root of your package:

```yaml
targets:
  $default:
    builders:
      dart_desk_generator|cmsBuilder:
        enabled: true
```

## Available Annotations

See the [`dart_desk_annotation`](https://pub.dev/packages/dart_desk_annotation) package for the full list of available annotations, including field types for strings, numbers, booleans, dates, images, arrays, and more.

## Additional Information

- Source code: https://github.com/vietthangvunguyen/dart_desk
- Issue tracker: https://github.com/vietthangvunguyen/dart_desk/issues
