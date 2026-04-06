import 'package:analyzer/dart/element/type.dart';

import 'field_code_registry.dart';
import 'field_code_generators/field_code_generator.dart';

class TypeInferenceEngine {
  final FieldCodeRegistry _registry;
  final Map<Type, FieldCodeGenerator> _defaults = {};

  TypeInferenceEngine(this._registry);

  void buildDefaults() {
    for (final entry in _registry.typeToGenerators.entries) {
      if (entry.value.isNotEmpty) {
        _defaults[entry.key] = entry.value.first;
      }
    }
  }

  FieldCodeGenerator? infer(DartType fieldType) {
    final typeName = fieldType.getDisplayString();

    final effectiveType = typeName.endsWith('?')
        ? typeName.substring(0, typeName.length - 1)
        : typeName;

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

    if (fieldType is InterfaceType && fieldType.element.displayName == 'List') {
      return _defaults[List];
    }

    return null;
  }

  FieldCodeGenerator? inferFromTypeName(String typeName) {
    final effectiveType = typeName.endsWith('?')
        ? typeName.substring(0, typeName.length - 1)
        : typeName;

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

    if (effectiveType.startsWith('List')) {
      return _defaults[List];
    }

    return null;
  }
}
