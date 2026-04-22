import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import '../utils.dart';
import 'field_code_generator.dart';

class ArrayFieldGenerator implements FieldCodeGenerator {
  @override
  String get fieldConfigName => 'DeskArray';

  @override
  List<Type> get supportedTypes => [List];

  static const _arrayPrimitiveFields = {
    'String': 'DeskStringField',
    'num': 'DeskNumberField',
    'int': 'DeskNumberField',
    'double': 'DeskNumberField',
    'bool': 'DeskBooleanField',
    'DateTime': 'DeskDateTimeField',
  };

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

    final configType = config?.type;
    String? genericType;
    ClassElement? genericClassElement;

    if (configType is InterfaceType && configType.typeArguments.isNotEmpty) {
      final T = configType.typeArguments[0];
      genericType = _displayType(T);
      genericClassElement = _classElementFromType(T);
    }

    if (genericType == null || genericType == 'dynamic') {
      final itemType = _arrayItemDartType(field);
      genericType = _displayType(itemType) ?? genericType;
      genericClassElement =
          _classElementFromType(itemType) ?? genericClassElement;
    }

    if (genericType == null) {
      throw InvalidGenerationSourceError(
        'Could not extract type parameter from DeskArray. '
        'Use explicit type: @DeskArray<String>() instead of @DeskArray().',
        element: field,
      );
    }

    String inferredFieldCode;

    if (innerSource != null) {
      inferredFieldCode = _explicitInnerFieldCode(
        config?.getField('inner'),
        innerSource,
      );
    } else {
      if (_arrayPrimitiveFields.containsKey(genericType)) {
        final fieldClass = _arrayPrimitiveFields[genericType]!;
        inferredFieldCode =
            "$fieldClass(name: 'item', title: '${_titleCase(genericType)}')";
      } else {
        if (genericClassElement != null && discoveryQueue != null) {
          discoveryQueue.add(genericClassElement);
        }
        final typeName = genericType;
        final fieldsListName =
            '${typeName[0].toLowerCase()}${typeName.substring(1)}Fields';

        inferredFieldCode =
            '''DeskObjectField(
    name: 'item',
    title: '${_titleCase(typeName)}',
    option: DeskObjectOption(children: [ColumnFields(children: $fieldsListName)]),
  )''';
      }
    }

    // For non-primitive array item types, require a static $fromMap method.
    final isPrimitive = _arrayPrimitiveFields.containsKey(genericType);
    String? fromMapCode;
    if (!isPrimitive && genericClassElement != null) {
      final hasFromMap = genericClassElement.methods.any(
        (m) => m.isStatic && m.name == r'$fromMap',
      );
      if (!hasFromMap) {
        throw InvalidGenerationSourceError(
          '$genericType is used as a DeskArrayField item type but does '
          'not have a static \$fromMap method. Add:\n\n'
          '  static $genericType \$fromMap(Map<String, dynamic> map) => '
          '${genericType}Mapper.fromMap(map);\n',
          element: field,
        );
      }
      fromMapCode = 'fromMap: $genericType.\$fromMap,';
    }

    return '''DeskArrayField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    innerField: $inferredFieldCode,
    ${fromMapCode ?? ''}
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
  }

  static String _explicitInnerFieldCode(
    DartObject? innerConfig,
    String source,
  ) {
    final configType =
        innerConfig?.type?.element?.displayName ??
        _innerConfigTypeFromSource(source);
    if (!configType.endsWith('FieldConfig')) {
      throw InvalidGenerationSourceError(
        'DeskArray.inner must be a DeskFieldConfig.',
      );
    }

    final fieldClass = configType.replaceFirst('FieldConfig', 'Field');
    final name =
        _namedArgumentSource(source, 'name') ??
        _singleQuoted(innerConfig?.read('name')?.toStringValue() ?? 'item');
    final title =
        _namedArgumentSource(source, 'title') ??
        _singleQuoted(innerConfig?.read('title')?.toStringValue() ?? 'Item');
    final description =
        _namedArgumentSource(source, 'description') ??
        switch (innerConfig?.read('description')?.toStringValue()) {
          final value? => _singleQuoted(value),
          null => null,
        };
    final optionalSource = _namedArgumentSource(source, 'optional');
    final optional =
        optionalSource == 'true' ||
        (innerConfig?.getFieldOrNull('optional')?.toBoolValue() ?? false);

    var optionSource = _namedArgumentSource(source, 'option');
    final optionType = _optionalOptionTypes[configType];
    if (optional && optionType != null) {
      if (optionSource == null) {
        optionSource = '$optionType(optional: true)';
      } else if (!optionSource.contains('optional')) {
        optionSource = optionSource.replaceFirst(
          '$optionType(',
          '$optionType(optional: true, ',
        );
      }
    }

    final args = [
      'name: $name',
      'title: $title',
      if (description != null) 'description: $description',
      if (optionSource != null) 'option: $optionSource',
    ];

    return '$fieldClass(${args.join(', ')})';
  }

  static String? _namedArgumentSource(String source, String name) {
    for (final arg in _splitTopLevelArguments(source)) {
      final prefix = '$name:';
      if (arg.startsWith(prefix)) {
        return arg.substring(prefix.length).trim();
      }
    }
    return null;
  }

  static List<String> _splitTopLevelArguments(String source) {
    final start = source.indexOf('(');
    final end = source.lastIndexOf(')');
    if (start < 0 || end <= start) return const [];

    final argsSource = source.substring(start + 1, end);
    final args = <String>[];
    var depth = 0;
    var inSingleQuote = false;
    var inDoubleQuote = false;
    var escaped = false;
    var segmentStart = 0;

    for (var i = 0; i < argsSource.length; i++) {
      final char = argsSource[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (char == '\\') {
        escaped = true;
        continue;
      }

      if (!inDoubleQuote && char == "'") {
        inSingleQuote = !inSingleQuote;
        continue;
      }

      if (!inSingleQuote && char == '"') {
        inDoubleQuote = !inDoubleQuote;
        continue;
      }

      if (inSingleQuote || inDoubleQuote) continue;

      if (char == '(' || char == '[' || char == '{') {
        depth++;
      } else if (char == ')' || char == ']' || char == '}') {
        depth--;
      } else if (char == ',' && depth == 0) {
        final arg = argsSource.substring(segmentStart, i).trim();
        if (arg.isNotEmpty) args.add(arg);
        segmentStart = i + 1;
      }
    }

    final lastArg = argsSource.substring(segmentStart).trim();
    if (lastArg.isNotEmpty) args.add(lastArg);
    return args;
  }

  static String _innerConfigTypeFromSource(String source) {
    final parenIndex = source.indexOf('(');
    final expression = parenIndex == -1
        ? source
        : source.substring(0, parenIndex);
    return expression
        .trim()
        .replaceFirst('const ', '')
        .replaceFirst('new ', '');
  }

  static String _singleQuoted(String value) {
    return "'${value.replaceAll('\\', r'\\').replaceAll("'", r"\'")}'";
  }

  static String? _displayType(DartType? type) {
    if (type == null) return null;
    final displayType = type.getDisplayString();
    return displayType.endsWith('?')
        ? displayType.substring(0, displayType.length - 1)
        : displayType;
  }

  static ClassElement? _classElementFromType(DartType? type) {
    if (type is InterfaceType && type.element is ClassElement) {
      return type.element as ClassElement;
    }
    return null;
  }

  static DartType? _arrayItemDartType(FieldElement field) {
    final fieldType = field.type;
    if (fieldType is InterfaceType && fieldType.typeArguments.isNotEmpty) {
      return fieldType.typeArguments.first;
    }
    return null;
  }

  static const _optionalOptionTypes = {
    'DeskText': 'DeskTextOption',
    'DeskString': 'DeskStringOption',
    'DeskNumber': 'DeskNumberOption',
    'DeskDate': 'DeskDateOption',
    'DeskDateTime': 'DeskDateTimeOption',
    'DeskUrl': 'DeskUrlOption',
    'DeskFile': 'DeskFileOption',
    'DeskColor': 'DeskColorOption',
  };

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
