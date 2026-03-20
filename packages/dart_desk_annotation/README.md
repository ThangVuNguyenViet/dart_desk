# dart_desk_annotation

Annotations for Flutter CMS code generation.

This package contains the annotations used to mark classes for code generation
in the Flutter CMS system. It has minimal dependencies and can be used as a
compile-time dependency.

## Usage

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

@CmsConfig(
  title: 'My Config',
  description: 'A configuration for my CMS',
)
class MyConfig {
  // Your configuration fields
}
```
