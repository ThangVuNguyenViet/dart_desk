# CMS Field Generator Refactor Design

**Date**: 2026-04-06
**Status**: Pending Review

## 1. Overview

Refactor the monolithic `desk_field_generator.dart` (1221 lines) into a modular architecture, and add auto-detection capability that infers the appropriate `DeskField` from the Dart field type and its `supportedFieldTypes`.

## 2. Motivation

- **Single giant file**: The `_fieldConfigs` map contains 20+ field generators as closures, making it hard to maintain, test, and add new field types
- **Redundant annotations**: Users must annotate every field even when the type uniquely determines the field (e.g., `String` → `DeskStringField`)
- **Unused `supportedFieldTypes`**: The annotation classes already define `supportedFieldTypes` but the generator doesn't leverage it for auto-detection

## 3. Goals

1. Modularize field generators into separate files (one class per file)
2. Implement type inference engine that auto-detects field type from Dart type
3. Maintain full backward compatibility with existing explicit annotations
4. Apply auto-detection to both top-level and nested discovered classes

## 4. Architecture

### 4.1 Directory Structure

```
packages/dart_desk_generator/lib/src/generators/
├── desk_field_generator.dart       # Main orchestrator (~300 lines)
├── field_code_registry.dart       # Maps field types → generators
├── type_inference_engine.dart     # Auto-detect logic
└── field_code_generators/
    ├── field_code_generator.dart  # Abstract base class
    ├── text_field_generator.dart
    ├── string_field_generator.dart
    ├── number_field_generator.dart
    ├── boolean_field_generator.dart
    ├── checkbox_field_generator.dart
    ├── date_field_generator.dart
    ├── datetime_field_generator.dart
    ├── url_field_generator.dart
    ├── slug_field_generator.dart
    ├── image_field_generator.dart
    ├── file_field_generator.dart
    ├── color_field_generator.dart
    ├── array_field_generator.dart
    ├── block_field_generator.dart
    ├── reference_field_generator.dart
    ├── cross_dataset_reference_field_generator.dart
    ├── geopoint_field_generator.dart
    ├── dropdown_field_generator.dart
    ├── multi_dropdown_field_generator.dart
    └── object_field_generator.dart
```

### 4.2 Core Interfaces

```dart
/// Base class for all field code generators
abstract class FieldCodeGenerator {
  /// The annotation name, e.g., 'DeskString'
  String get fieldConfigName;
  
  /// Dart types this generator supports (from supportedFieldTypes)
  List<Type> get supportedTypes;
  
  /// Generate the DeskField code
  String generate(
    FieldElement field,
    DartObject? config, {
    String? optionSource,
    String? innerSource,
    List<ClassElement>? discoveryQueue,
  });
}
```

```dart
/// Registry that maps field config names to generators
class FieldCodeRegistry {
  final Map<String, FieldCodeGenerator> _byConfigName = {};
  final Map<Type, List<FieldCodeGenerator>> _byType = {};
  
  void register(FieldCodeGenerator generator);
  
  FieldCodeGenerator? getByConfigName(String name);
  
  /// Returns generators for a given Dart type
  List<FieldCodeGenerator> getByType(Type type);
}
```

```dart
/// Auto-detection engine using supportedFieldTypes
class TypeInferenceEngine {
  final FieldCodeRegistry _registry;
  
  /// Maps: Dart type → default generator (first registered wins)
  final Map<Type, FieldCodeGenerator> _defaults = {};
  
  void buildDefaults() {
    for (final entry in _registry._byType.entries) {
      if (entry.value.isNotEmpty) {
        _defaults[entry.key] = entry.value.first;
      }
    }
  }
  
  /// For List<T>, multiple generators may exist:
  /// - DeskArrayField supports List<T>
  /// - DeskMultiDropdownField supports List<T>
  /// Default to DeskArrayField (first registered)
  FieldCodeGenerator? infer(DartType fieldType);
}
```

### 4.3 Main Generator Orchestrator

The refactored `DeskFieldGenerator` delegates to:

1. `FieldCodeRegistry` - for explicit annotation resolution
2. `TypeInferenceEngine` - for unannotated field auto-detection

```dart
class DeskFieldGenerator extends GeneratorForAnnotation<DeskModel> {
  final _registry = FieldCodeRegistry();
  final _inferenceEngine = TypeInferenceEngine();
  
  DeskFieldGenerator() {
    // Register all field generators
    _registry.register(StringFieldGenerator());
    _registry.register(NumberFieldGenerator());
    // ... register all others
    _inferenceEngine.buildDefaults();
  }
  
  Future<String> generateForAnnotatedElement(...) async {
    // Existing logic with modifications:
    // - For annotated fields: use _registry.getByConfigName()
    // - For unannotated fields: use _inferenceEngine.infer()
  }
}
```

## 5. Type Inference Rules

| Dart Type | Default Generator | Notes |
|-----------|-------------------|-------|
| `String` | `DeskStringField` | |
| `num`/`int`/`double` | `DeskNumberField` | |
| `bool` | `DeskBooleanField` | |
| `DateTime` | `DeskDateTimeField` | |
| `Uri` | `DeskUrlField` | |
| `ImageReference` / `ImageRef` | `DeskImageField` | |
| `List<T>` | `DeskArrayField` | Default when multiple candidates exist |
| Class types (non-primitive) | `DeskObjectField` | Also adds to discovery queue |

## 6. Backward Compatibility

- All existing `@DeskText`, `@DeskString` annotations continue to work
- Auto-detection only applies to **unannotated fields**
- Generated code remains identical for annotated fields

```dart
// Explicit annotation (supported forever)
@DeskString(optional: true)
final String name;

// Auto-detection (new)
final String name; // → DeskStringField automatically
```

## 7. Implementation Phases

### Phase 1: Modularization (no behavior change)

1. Create `field_code_generator.dart` abstract base
2. Create individual generator files with classes implementing the base
3. Create `field_code_registry.dart` to hold the map
4. Refactor `desk_field_generator.dart` to use registry

### Phase 2: Type Inference Engine

1. Create `type_inference_engine.dart`
2. Add logic to scan `supportedFieldTypes` from annotation classes
3. Wire inference into `_generateFieldList()` for unannotated fields

### Phase 3: Testing

1. Add tests for each field code generator
2. Add tests for type inference engine
3. Add integration tests for auto-detection

## 8. Testing Strategy

- Unit tests for each `FieldCodeGenerator` subclass
- Unit tests for `TypeInferenceEngine` inference rules
- Integration tests verifying generated output matches current behavior
- Test files live in `packages/dart_desk_generator/test/field_code_generators/`

### 8.1 Test Structure

```
packages/dart_desk_generator/test/
├── field_code_generators/
│   ├── field_code_generator_test.dart      # Base class tests
│   ├── field_code_registry_test.dart       # Registry tests
│   ├── type_inference_engine_test.dart     # Inference tests
│   ├── string_field_generator_test.dart
│   ├── number_field_generator_test.dart
│   ├── boolean_field_generator_test.dart
│   ├── array_field_generator_test.dart
│   ├── dropdown_field_generator_test.dart
│   └── object_field_generator_test.dart
└── desk_field_generator_test.dart           # Integration tests (existing)
```

### 8.2 Test Coverage Requirements

**FieldCodeGenerator Tests:**
- `generate()` produces correct output for all field types
- Option merging works correctly (explicit + optional flag)
- Inner config handling for array/object fields
- Discovery queue population

**TypeInferenceEngine Tests:**
- `infer(String)` returns `StringFieldGenerator`
- `infer(int)` returns `NumberFieldGenerator`  
- `infer(List<String>)` returns `ArrayFieldGenerator` (default)
- `infer(List<String>)` when both Array and MultiDropdown registered → Array wins
- `infer(UnknownType)` returns null
- Handles nullable types (`String?` → same as `String`)

**Integration Tests:**
- Full `@DeskModel` generation with mixed annotated + unannotated fields
- Nested class discovery with auto-detected fields
- Generated output matches existing test expectations

### 8.3 Test Example

```dart
group('TypeInferenceEngine', () {
  late TypeInferenceEngine engine;
  
  setUp(() {
    final registry = FieldCodeRegistry();
    registry.register(StringFieldGenerator());
    registry.register(NumberFieldGenerator());
    registry.register(ArrayFieldGenerator());
    registry.register(MultiDropdownFieldGenerator());
    engine = TypeInferenceEngine(registry);
    engine.buildDefaults();
  });
  
  test('infers String type as DeskStringField', () {
    final mockType = _createDartType('String');
    final generator = engine.infer(mockType);
    expect(generator.fieldConfigName, 'DeskString');
  });
  
  test('List<T> defaults to ArrayField when multiple candidates', () {
    final mockListType = _createListDartType('String');
    final generator = engine.infer(mockListType);
    expect(generator.fieldConfigName, 'DeskArray');
  });
});
```

## 9. Open Questions

1. Should we deprecate explicit annotations in favor of auto-detection? → **No, kept for backward compatibility**
2. Should auto-detection apply to nested discovered classes? → **Yes**
3. How to handle the `List<T>` ambiguity? → **Default to DeskArrayField**
