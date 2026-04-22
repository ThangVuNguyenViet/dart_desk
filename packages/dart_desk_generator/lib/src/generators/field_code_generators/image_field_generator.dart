import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'field_code_generator.dart';

class ImageFieldGenerator implements FieldCodeGenerator {
  @override
  String get fieldConfigName => 'DeskImage';

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

    return '''DeskImageField(
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
