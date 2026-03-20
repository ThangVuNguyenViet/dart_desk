# Serverpod Serialization Reference

## Table of Contents
- [Auto-Generated Models](#auto-generated-models)
- [Custom Serialization](#custom-serialization)
- [Freezed Support](#freezed-support)
- [ProtocolSerialization](#protocolserialization)

## Auto-Generated Models

Models defined in YAML files are auto-serialized. No manual work needed:

```yaml
class: User
fields:
  name: String
  email: String
```

Generated classes include `toJson()`, `fromJson()`, and `copyWith()`.

## Custom Serialization

For classes not defined in YAML, implement three methods:

```dart
class ClassName {
  String name;
  ClassName(this.name);

  // 1. toJson
  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  // 2. fromJson factory
  factory ClassName.fromJson(Map<String, dynamic> json) {
    return ClassName(json['name'] as String);
  }

  // 3. copyWith (deep copy)
  ClassName copyWith({String? name}) {
    return ClassName(name: name ?? this.name);
  }
}
```

Register in `config/generator.yaml`:

```yaml
extraClasses:
  - package:my_project_shared/my_project_shared.dart:ClassName
```

### Shared Package Structure

Create a dedicated shared package for custom classes:

```
├── my_project_client
├── my_project_flutter
├── my_project_server
├── my_project_shared     # Custom serializable classes
```

Add as dependency to both server and client `pubspec.yaml`:

```yaml
dependencies:
  my_project_shared:
    path: ../my_project_shared
```

## Freezed Support

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'freezed_custom_class.freezed.dart';
part 'freezed_custom_class.g.dart';

@freezed
class FreezedCustomClass with _$FreezedCustomClass {
  const factory FreezedCustomClass({
    required String firstName,
    required String lastName,
    required int age,
  }) = _FreezedCustomClass;

  factory FreezedCustomClass.fromJson(Map<String, Object?> json) =>
      _$FreezedCustomClassFromJson(json);
}
```

## ProtocolSerialization

Omit sensitive fields from client transmission:

```dart
class CustomClass implements ProtocolSerialization {
  final String? value;
  final String? serverSideValue;

  // Sent to client (omits serverSideValue)
  Map<String, dynamic> toJsonForProtocol() {
    return {"value": value};
  }

  // Full serialization (database, internal)
  Map<String, dynamic> toJson() {
    return {
      "value": value,
      "serverSideValue": serverSideValue,
    };
  }
}
```

Client-side custom models don't need `ProtocolSerialization`.
