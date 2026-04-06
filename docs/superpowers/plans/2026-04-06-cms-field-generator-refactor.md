# CMS Field Generator Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the monolithic cms_field_generator.dart (1221 lines) into modular architecture with one class per file, and add auto-detection capability that infers CmsField from Dart field types using supportedFieldTypes.

**Architecture:** Split the giant generator into: (1) Abstract base FieldCodeGenerator class, (2) Individual generator classes (one per field type), (3) FieldCodeRegistry to map config names to generators, (4) TypeInferenceEngine for auto-detection. The main CmsFieldGenerator delegates to these components.

**Tech Stack:** Dart, source_gen, analyzer package

---

## Phase 1: Abstract Base Class

### Task 1: Create FieldCodeGenerator abstract base class

**Files:**
- Create: `packages/dart_desk_generator/lib/src/generators/field_code_generators/field_code_generator.dart`

- [ ] **Step 1: Write the failing test**

```dart
// packages/dart_desk_generator/test/field_code_generators/field_code_generator_test.dart
import 'package:dart_desk_generator/src/generators/field_code_generators/field_code_generator.dart';
import 'package:test/test.dart';

void main() {
  group('FieldCodeGenerator', () {
    test('abstract class cannot be instantiated', () {
      expect(
        () => FieldCodeGenerator(),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test packages/dart_desk_generator/test/field_code_generators/field_code_generator_test.dart`
Expected: FAIL - "Cannot construct an instance of FieldCodeGenerator"

- [ ] **Step 3: Write minimal implementation**

```dart
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';

abstract class FieldCodeGenerator {
  String get fieldConfigName;
  
  List<Type> get supportedTypes;
  
  String generate(
    FieldElement field,
    DartObject? config, {
    String? optionSource,
    String? innerSource,
    List<ClassElement>? discoveryQueue,
  });
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test packages/dart_desk_generator/test/field_code_generators/field_code_generator_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk_generator/lib/src/generators/field_code_generators/field_code_generator.dart packages/dart_desk_generator/test/field_code_generators/field_code_generator_test.dart
git commit -m "feat: add abstract FieldCodeGenerator base class"
```

---

## Phase 2: Individual Field Generators

### Task 2: Create StringFieldGenerator

**Files:**
- Create: `packages/dart_desk_generator/lib/src/generators/field_code_generators/string_field_generator.dart`
- Test: `packages/dart_desk_generator/test/field_code_generators/string_field_generator_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:dart_desk_generator/src/generators/field_code_generators/string_field_generator.dart';
import 'package:test/test.dart';

void main() {
  group('StringFieldGenerator', () {
    test('has correct fieldConfigName', () {
      final generator = StringFieldGenerator();
      expect(generator.fieldConfigName, 'CmsStringFieldConfig');
    });
    
    test('has supportedTypes containing String', () {
      final generator = StringFieldGenerator();
      expect(generator.supportedTypes, contains(String));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test packages/dart_desk_generator/test/field_code_generators/string_field_generator_test.dart`
Expected: FAIL - "StringFieldGenerator not defined"

- [ ] **Step 3: Write minimal implementation**

```dart
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'field_code_generator.dart';

class StringFieldGenerator implements FieldCodeGenerator {
  @override
  String get fieldConfigName => 'CmsStringFieldConfig';
  
  @override
  List<Type> get supportedTypes => [String];
  
  @override
  String generate(
    FieldElement field,
    DartObject? config, {
    String? optionSource,
    String? innerSource,
    List<ClassElement>? discoveryQueue,
  }) {
    final fieldName = field.name;
    if (fieldName == null) {
      throw InvalidGenerationSourceError('Field has no name', element: field);
    }
    final optional = config?.getField('optional')?.toBoolValue() ?? false;
    
    String? resolvedOption = optionSource;
    if (optional && resolvedOption == null) {
      resolvedOption = 'CmsStringOption(optional: true)';
    } else if (optional && resolvedOption != null) {
      if (!resolvedOption.contains('optional')) {
        resolvedOption = resolvedOption.replaceFirst(
          'CmsStringOption(',
          'CmsStringOption(optional: true, ',
        );
      }
    }
    
    return '''CmsStringField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
  }
  
  static String _titleCase(String input) {
    if (input.isEmpty) return input;
    final words = input.split(RegExp(r'[_\s]'));
    final finalWords = <String>[];
    for (final word in words) {
      if (word.isEmpty) continue;
      final camelCaseWords = word
          .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
          .trim()
          .split(' ');
      finalWords.addAll(camelCaseWords);
    }
    return finalWords
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test packages/dart_desk_generator/test/field_code_generators/string_field_generator_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk_generator/lib/src/generators/field_code_generators/string_field_generator.dart packages/dart_desk_generator/test/field_code_generators/string_field_generator_test.dart
git commit -m "feat: add StringFieldGenerator"
```

### Task 3: Create NumberFieldGenerator

**Files:**
- Create: `packages/dart_desk_generator/lib/src/generators/field_code_generators/number_field_generator.dart`
- Test: `packages/dart_desk_generator/test/field_code_generators/number_field_generator_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:dart_desk_generator/src/generators/field_code_generators/number_field_generator.dart';
import 'package:test/test.dart';

void main() {
  group('NumberFieldGenerator', () {
    test('has correct fieldConfigName', () {
      final generator = NumberFieldGenerator();
      expect(generator.fieldConfigName, 'CmsNumberFieldConfig');
    });
    
    test('has supportedTypes containing num, int, double', () {
      final generator = NumberFieldGenerator();
      expect(generator.supportedTypes, containsAll([num, int, double]));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test packages/dart_desk_generator/test/field_code_generators/number_field_generator_test.dart`
Expected: FAIL - "NumberFieldGenerator not defined"

- [ ] **Step 3: Write minimal implementation**

```dart
// Based on _fieldConfigs['CmsNumberFieldConfig'] closure from cms_field_generator.dart
// Similar pattern to StringFieldGenerator
// Extract: num, int, double → CmsNumberField
```

- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit**

### Task 4: Create BooleanFieldGenerator

**Files:**
- Create: `packages/dart_desk_generator/lib/src/generators/field_code_generators/boolean_field_generator.dart`
- Test: `packages/dart_desk_generator/test/field_code_generators/boolean_field_generator_test.dart`

### Task 5: Create ArrayFieldGenerator

**Files:**
- Create: `packages/dart_desk_generator/lib/src/generators/field_code_generators/array_field_generator.dart`
- Test: `packages/dart_desk_generator/test/field_code_generators/array_field_generator_test.dart`

### Task 6: Create remaining field generators (12 more)

Create generators for: TextField, CheckboxField, DateField, DateTimeField, UrlField, SlugField, ImageField, FileField, ColorField, BlockField, ReferenceField, CrossDatasetReferenceField, GeopointField, DropdownField, MultiDropdownField, ObjectField

**Files:**
- Create: `packages/dart_desk_generator/lib/src/generators/field_code_generators/*.dart` (one per field type)
- Test: `packages/dart_desk_generator/test/field_code_generators/*_test.dart`

---

## Phase 3: FieldCodeRegistry

### Task 7: Create FieldCodeRegistry

**Files:**
- Create: `packages/dart_desk_generator/lib/src/generators/field_code_registry.dart`
- Test: `packages/dart_desk_generator/test/field_code_registry_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:dart_desk_generator/src/generators/field_code_registry.dart';
import 'package:dart_desk_generator/src/generators/field_code_generators/string_field_generator.dart';
import 'package:test/test.dart';

void main() {
  group('FieldCodeRegistry', () {
    test('register and getByConfigName', () {
      final registry = FieldCodeRegistry();
      final generator = StringFieldGenerator();
      registry.register(generator);
      
      expect(registry.getByConfigName('CmsStringFieldConfig'), generator);
    });
    
    test('getByType returns generators for type', () {
      final registry = FieldCodeRegistry();
      registry.register(StringFieldGenerator());
      
      final generators = registry.getByType(String);
      expect(generators, isNotEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Write minimal implementation**

```dart
import 'field_code_generators/field_code_generator.dart';

class FieldCodeRegistry {
  final Map<String, FieldCodeGenerator> _byConfigName = {};
  final Map<Type, List<FieldCodeGenerator>> _byType = {};
  
  void register(FieldCodeGenerator generator) {
    _byConfigName[generator.fieldConfigName] = generator;
    for (final type in generator.supportedTypes) {
      _byType.putIfAbsent(type, () => []).add(generator);
    }
  }
  
  FieldCodeGenerator? getByConfigName(String name) => _byConfigName[name];
  
  List<FieldCodeGenerator> getByType(Type type) => _byType[type] ?? [];
}
```

- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit**

---

## Phase 4: TypeInferenceEngine

### Task 8: Create TypeInferenceEngine

**Files:**
- Create: `packages/dart_desk_generator/lib/src/generators/type_inference_engine.dart`
- Test: `packages/dart_desk_generator/test/type_inference_engine_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:dart_desk_generator/src/generators/type_inference_engine.dart';
import 'package:dart_desk_generator/src/generators/field_code_registry.dart';
import 'package:dart_desk_generator/src/generators/field_code_generators/string_field_generator.dart';
import 'package:dart_desk_generator/src/generators/field_code_generators/array_field_generator.dart';
import 'package:test/test.dart';

void main() {
  group('TypeInferenceEngine', () {
    test('infers String type as StringFieldGenerator', () {
      final registry = FieldCodeRegistry();
      registry.register(StringFieldGenerator());
      final engine = TypeInferenceEngine(registry);
      engine.buildDefaults();
      
      // Note: Will need mock DartType - test structure will differ
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Write implementation**

```dart
import 'package:analyzer/dart/element/type.dart';
import 'field_code_registry.dart';
import 'field_code_generators/field_code_generator.dart';

class TypeInferenceEngine {
  final FieldCodeRegistry _registry;
  final Map<Type, FieldCodeGenerator> _defaults = {};
  
  TypeInferenceEngine(this._registry);
  
  void buildDefaults() {
    for (final entry in _registry._byType.entries) {
      if (entry.value.isNotEmpty) {
        _defaults[entry.key] = entry.value.first;
      }
    }
  }
  
  /// Infers the appropriate generator for a DartType.
  /// For List<T>, defaults to first registered (CmsArrayField).
  FieldCodeGenerator? infer(DartType fieldType) {
    final typeName = fieldType.getDisplayString();
    
    // Handle nullable types
    final effectiveType = typeName.endsWith('?') 
        ? typeName.substring(0, typeName.length - 1) 
        : typeName;
    
    // Map string type names to Type objects
    final typeMapping = {
      'String': String,
      'int': int,
      'num': num,
      'double': double,
      'bool': bool,
      'DateTime': DateTime,
      'Uri': Uri,
    };
    
    final dartType = typeMapping[effectiveType];
    if (dartType != null) {
      return _defaults[dartType];
    }
    
    // Handle List<T>
    if (fieldType is InterfaceType && fieldType.element.displayName == 'List') {
      return _defaults[List];
    }
    
    // For class types (non-primitive), return ObjectFieldGenerator
    // This is handled separately
    return null;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit**

---

## Phase 5: Integrate into CmsFieldGenerator

### Task 9: Refactor CmsFieldGenerator to use registry

**Files:**
- Modify: `packages/dart_desk_generator/lib/src/generators/cms_field_generator.dart`
- Test: `packages/dart_desk_generator/test/cms_field_generator_test.dart` (existing, ensure passes)

- [ ] **Step 1: Add imports for new components**

```dart
import 'field_code_registry.dart';
import 'type_inference_engine.dart';
import 'field_code_generators/string_field_generator.dart';
// ... import all other generators
```

- [ ] **Step 2: Add registry and inference engine as class fields**

- [ ] **Step 3: Replace _fieldConfigs usage with registry**
- Replace the static Map with registry.register() calls in constructor

- [ ] **Step 4: Add auto-detection for unannotated fields**
- In _generateFieldList, after checking for explicit annotations, use inference engine for unannotated fields

- [ ] **Step 5: Run existing tests to verify no regression**

Run: `dart test packages/dart_desk_generator/test/cms_field_generator_test.dart`
Expected: PASS (all existing tests)

- [ ] **Step 6: Commit**

---

## Phase 6: End-to-End Testing

### Task 10: Add integration tests for auto-detection

**Files:**
- Add tests to: `packages/dart_desk_generator/test/cms_field_generator_test.dart`

- [ ] **Step 1: Write test for auto-detected String field**

```dart
test('auto-detects String field without annotation', () async {
  await _testCmsBuilder(
    _fixture('''
@CmsConfig(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final String name;
  
  const AutoDetectConfig({required this.name});
  
  static AutoDetectConfig? defaultValue;
}
'''),
    contains('CmsStringField('),
  );
});
```

- [ ] **Step 2: Write test for auto-detected List field (defaults to Array)**

- [ ] **Step 3: Write test for mixed annotated + unannotated fields**

- [ ] **Step 4: Run all tests**

Run: `dart test packages/dart_desk_generator/test/`
Expected: All PASS

- [ ] **Step 5: Commit**

---

## Summary

| Phase | Tasks | Focus |
|-------|-------|-------|
| 1 | Task 1 | Abstract base class |
| 2 | Tasks 2-6 | 16 individual field generators |
| 3 | Task 7 | Registry |
| 4 | Task 8 | Type inference engine |
| 5 | Task 9 | Main generator integration |
| 6 | Task 10 | End-to-end tests |

**Plan complete and saved to `docs/superpowers/plans/2026-04-06-cms-field-generator-refactor.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
