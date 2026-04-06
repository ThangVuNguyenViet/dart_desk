import 'package:analyzer/dart/element/type.dart';

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

  Map<Type, List<FieldCodeGenerator>> get typeToGenerators =>
      Map.unmodifiable(_byType);
}
