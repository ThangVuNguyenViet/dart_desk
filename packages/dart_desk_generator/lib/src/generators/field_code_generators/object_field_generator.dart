import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import 'field_code_generator.dart';

class ObjectFieldGenerator implements FieldCodeGenerator {
  @override
  String get fieldConfigName => 'CmsObjectFieldConfig';

  @override
  List<Type> get supportedTypes => [];

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

    String? resolvedOption = optionSource;
    if (resolvedOption == null) {
      final fieldType = field.type;
      final typeElement = fieldType is InterfaceType ? fieldType.element : null;
      if (typeElement is ClassElement) {
        final typeName = typeElement.displayName;
        const primitives = {
          'String',
          'int',
          'num',
          'double',
          'bool',
          'DateTime',
        };
        if (!primitives.contains(typeName)) {
          if (discoveryQueue != null) {
            discoveryQueue.add(typeElement);
          }
          final fieldsListName =
              '${typeName[0].toLowerCase()}${typeName.substring(1)}Fields';
          resolvedOption =
              'CmsObjectOption(children: [ColumnFields(children: $fieldsListName)])';
        }
      }
    }

    // For non-primitive object types, require a static $fromMap method.
    String? fromMapCode;
    final fieldType = field.type;
    final typeElement = fieldType is InterfaceType ? fieldType.element : null;
    if (typeElement is ClassElement) {
      final typeName = typeElement.displayName;
      const primitives = {'String', 'int', 'num', 'double', 'bool', 'DateTime'};
      if (!primitives.contains(typeName)) {
        final hasFromMap = typeElement.methods.any(
          (m) => m.isStatic && m.name == r'$fromMap',
        );
        if (!hasFromMap) {
          throw InvalidGenerationSourceError(
            '$typeName is used as a CmsObjectField type but does '
            'not have a static \$fromMap method. Add:\n\n'
            '  static $typeName \$fromMap(Map<String, dynamic> map) => '
            '${typeName}Mapper.fromMap(map);\n',
            element: field,
          );
        }
        fromMapCode = 'fromMap: $typeName.\$fromMap,';
      }
    }

    return '''CmsObjectField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${fromMapCode ?? ''}
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
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
