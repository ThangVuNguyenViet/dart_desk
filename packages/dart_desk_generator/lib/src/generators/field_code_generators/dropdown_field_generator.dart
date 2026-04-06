import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import 'field_code_generator.dart';

class DropdownFieldGenerator implements FieldCodeGenerator {
  @override
  String get fieldConfigName => 'CmsDropdownFieldConfig';

  @override
  List<Type> get supportedTypes => [String];

  static String? _displayType(DartType? type) {
    if (type == null) return null;
    final displayType = type.getDisplayString();
    return displayType.endsWith('?')
        ? displayType.substring(0, displayType.length - 1)
        : displayType;
  }

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

    final configType = config?.type?.toString() ?? '';
    final genericTypeMatch = RegExp(
      r'CmsDropdownFieldConfig<(.+?)>',
    ).firstMatch(configType);
    final genericType =
        genericTypeMatch?.group(1) ?? _displayType(field.type) ?? 'dynamic';

    return '''CmsDropdownField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
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

class MultiDropdownFieldGenerator implements FieldCodeGenerator {
  @override
  String get fieldConfigName => 'CmsMultiDropdownFieldConfig';

  @override
  List<Type> get supportedTypes => [List];

  static DartType? _arrayItemDartType(FieldElement field) {
    final fieldType = field.type;
    if (fieldType is InterfaceType && fieldType.typeArguments.isNotEmpty) {
      return fieldType.typeArguments.first;
    }
    return null;
  }

  static String? _displayType(DartType? type) {
    if (type == null) return null;
    final displayType = type.getDisplayString();
    return displayType.endsWith('?')
        ? displayType.substring(0, displayType.length - 1)
        : displayType;
  }

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

    final configType = config?.type?.toString() ?? '';
    final genericTypeMatch = RegExp(
      r'CmsMultiDropdownFieldConfig<(.+?)>',
    ).firstMatch(configType);
    final genericType =
        genericTypeMatch?.group(1) ??
        _displayType(_arrayItemDartType(field)) ??
        'dynamic';

    return '''CmsMultiDropdownField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
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
