import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import '../optional_resolver.dart';
import 'field_code_generator.dart';

class DateTimeFieldGenerator implements FieldCodeGenerator {
  @override
  String get fieldConfigName => 'DeskDateTime';

  @override
  List<Type> get supportedTypes => [DateTime];

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
    final optional = resolveOptional(
      field: field,
      configOptional: config?.getField('optional')?.toBoolValue(),
      optionalSource: null,
    );

    String? resolvedOption = optionSource;
    if (optional && resolvedOption == null) {
      resolvedOption = 'DeskDateTimeOption(optional: true)';
    } else if (optional && resolvedOption != null) {
      if (!resolvedOption.contains('optional')) {
        resolvedOption = resolvedOption.replaceFirst(
          'DeskDateTimeOption(',
          'DeskDateTimeOption(optional: true, ',
        );
      }
    }

    return '''DeskDateTimeField(
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
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
