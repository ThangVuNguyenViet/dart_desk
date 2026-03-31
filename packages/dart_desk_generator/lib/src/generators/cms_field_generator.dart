import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dart_desk_annotation/dart_desk_annotation_generator.dart';

import 'utils.dart';

/// Extension to provide safe field access similar to widgetbook's readOrNull pattern
extension DartObjectExtension on DartObject {
  /// Safely gets a field value, returning null if the field doesn't exist
  DartObject? getFieldOrNull(String fieldName) {
    try {
      return getField(fieldName);
    } catch (e) {
      return null;
    }
  }
}

/// Generates CmsField lists from classes annotated with @CmsConfig.
/// This generator processes the @CmsFieldConfig annotations on fields to create
/// corresponding CmsField instances for runtime use.
class CmsFieldGenerator extends GeneratorForAnnotation<CmsConfig> {
  /// Get option source from ElementAnnotation using async utils.dart approach
  static Future<String?> _getOptionSourceFromElementAnnotation(
    FieldElement fieldElement,
    ElementAnnotation annotation,
    String? displayName,
  ) async {
    // Use the proper async utils.dart method to get the option field directly
    final optionNode = await getResolvedAnnotationNode(
      fieldElement,
      annotation.computeConstantValue()!.type!,
      'option',
    );

    // If we got the option node, return its source representation
    if (optionNode != null) {
      return optionNode.toSource();
    }
    return null;
  }

  static final _fieldConfigs = {
    'CmsTextFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;

      return '''CmsTextField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsStringFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      return '''CmsStringField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsNumberFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      return '''CmsNumberField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsBooleanFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      return '''CmsBooleanField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsCheckboxFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;

      return '''CmsCheckboxField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsDateFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      return '''CmsDateField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsDateTimeFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      return '''CmsDateTimeField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsUrlFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      return '''CmsUrlField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsSlugFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;

      return '''CmsSlugField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsImageFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;

      return '''CmsImageField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsFileFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      return '''CmsFileField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsArrayFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;

      // Extract T from CmsArrayFieldConfig<T>
      final configType = config?.type?.toString() ?? '';
      final genericTypeMatch = RegExp(
        r'CmsArrayFieldConfig<(.+?)>',
      ).firstMatch(configType);
      final genericType = genericTypeMatch?.group(1);
      if (genericType == null) {
        throw InvalidGenerationSourceError(
          'Could not extract type parameter from CmsArrayFieldConfig. '
          'Use explicit type: @CmsArrayFieldConfig<String>() instead of @CmsArrayFieldConfig().',
          element: field,
        );
      }

      // Validate: non-primitive T requires option
      const primitiveTypes = {'String', 'num', 'int', 'double', 'bool'};
      if (!primitiveTypes.contains(genericType) && optionSource == null) {
        throw InvalidGenerationSourceError(
          'CmsArrayFieldConfig<$genericType> requires an option with '
          'itemBuilder and itemEditor because $genericType is not a '
          'primitive type. Provide a CmsArrayOption<$genericType> subclass.',
          element: field,
        );
      }

      return '''CmsArrayField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsBlockFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      return '''CmsBlockField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsReferenceFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      return '''CmsReferenceField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsCrossDatasetReferenceFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      return '''CmsCrossDatasetReferenceField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsGeopointFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      return '''CmsGeopointField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsColorFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;
      final optional = config?.getField('optional')?.toBoolValue() ?? false;

      String? resolvedOption = optionSource;
      if (optional && resolvedOption == null) {
        resolvedOption = 'CmsColorOption(optional: true)';
      } else if (optional && resolvedOption != null) {
        if (!resolvedOption.contains('optional')) {
          resolvedOption = resolvedOption.replaceFirst(
            'CmsColorOption(',
            'CmsColorOption(optional: true, ',
          );
        }
      }

      return '''CmsColorField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
    },
    'CmsDropdownFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;

      // Extract the generic type from CmsDropdownFieldConfig<T>
      final configType = config?.type?.toString() ?? '';
      final genericTypeMatch = RegExp(
        r'CmsDropdownFieldConfig<(.+?)>',
      ).firstMatch(configType);
      final genericType = genericTypeMatch?.group(1) ?? 'dynamic';

      return '''CmsDropdownField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
    'CmsObjectFieldConfig': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;

      // If no explicit option, try to auto-resolve from the field's type
      String? resolvedOption = optionSource;
      if (resolvedOption == null) {
        final fieldType = field.type;
        final typeElement =
            fieldType is InterfaceType ? fieldType.element : null;
        // Check if the type class has @CmsConfig annotation
        if (typeElement != null &&
            typeElement.metadata.annotations.any((m) =>
                m.computeConstantValue()?.type?.element?.displayName ==
                'CmsConfig')) {
          final typeName = typeElement.displayName;
          final fieldsListName =
              '${typeName[0].toLowerCase()}${typeName.substring(1)}Fields';
          resolvedOption =
              'CmsObjectOption(children: [ColumnFields(children: $fieldsListName)])';
        }
      }

      return '''CmsObjectField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
    },
  };

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    // Set the node resolver for utils
    nodeResolver = buildStep.resolver;
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@CmsConfig` can only be used on classes.',
        element: element,
      );
    }

    final className = element.name;
    if (className == null) {
      throw InvalidGenerationSourceError(
        'Class name is null.',
        element: element,
      );
    }

    // Extract CmsConfig annotation parameters
    final title = annotation.read('title').stringValue;
    final description = annotation.read('description').stringValue;
    final id = annotation.peek('id')?.stringValue;

    final fieldsListName =
        '${className.substring(0, 1).toLowerCase()}${className.substring(1)}Fields';
    final typeSpecName =
        '${className.substring(0, 1).toLowerCase()}${className.substring(1)}TypeSpec';

    final fields = element.fields.where(
      (f) => !f.isStatic && f.name != 'defaultValue',
    );
    final fieldConfigs = <String>[];

    for (final field in fields) {
      String? configCode;

      // Check for field-specific annotations
      for (final annotation in field.metadata.annotations) {
        final annotationType = annotation.computeConstantValue()?.type;
        final displayName = annotationType?.element?.displayName;

        // Get the option field directly from annotation using the async utils.dart approach
        final optionSource = await _getOptionSourceFromElementAnnotation(
          field,
          annotation,
          displayName,
        );

        configCode = _fieldConfigs[displayName]?.call(
          field,
          annotation.computeConstantValue(),
          optionSource,
        );
        if (configCode != null) break;
      }

      if (configCode != null) {
        fieldConfigs.add(configCode);
      }
    }

    if (fieldConfigs.isEmpty) return '';

    final idField =
        id != null
            ? "name: '$id',"
            : "name: '${className.substring(0, 1).toLowerCase()}${className.substring(1)}',";

    return '''
/// Generated CmsField list for $className
final $fieldsListName = [
  ${fieldConfigs.join(',\n  ')},
];

/// Generated document type spec for $className.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final $typeSpecName = DocumentTypeSpec<$className>(
  $idField
  title: '$title',
  description: '$description',
  fields: $fieldsListName,
  defaultValue: $className.defaultValue,
);\n''';
  }

  /// Converts snake_case or camelCase to Title Case
  static String _titleCase(String input) {
    if (input.isEmpty) return input;

    // Split by underscores and spaces
    final words = input.split(RegExp(r'[_\s]'));

    // Convert camelCase to separate words
    final finalWords = <String>[];
    for (final word in words) {
      if (word.isEmpty) continue;
      final camelCaseWords = word
          .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
          .trim()
          .split(' ');
      finalWords.addAll(camelCaseWords);
    }

    // Capitalize each word
    return finalWords
        .map(
          (word) =>
              word.isEmpty
                  ? ''
                  : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  /// Gets a Type from a string name
  String getAnnotationName(String configType) {
    return configType;
  }
}
