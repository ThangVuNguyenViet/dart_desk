import 'dart:async';
import 'dart:collection';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_desk_annotation/dart_desk_annotation_generator.dart';
import 'package:source_gen/source_gen.dart';

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

  /// Get inner source from ElementAnnotation using async utils.dart approach
  static Future<String?> _getInnerSourceFromElementAnnotation(
    FieldElement fieldElement,
    ElementAnnotation annotation,
    String? displayName,
  ) async {
    final innerNode = await getResolvedAnnotationNode(
      fieldElement,
      annotation.computeConstantValue()!.type!,
      'inner',
    );
    if (innerNode != null) {
      return innerNode.toSource();
    }
    return null;
  }

  static final _fieldConfigs = {
    'CmsTextFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          final optional = config?.getField('optional')?.toBoolValue() ?? false;

          String? resolvedOption = optionSource;
          if (optional && resolvedOption == null) {
            resolvedOption = 'CmsTextOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'CmsTextOption(',
                'CmsTextOption(optional: true, ',
              );
            }
          }

          return '''CmsTextField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'CmsStringFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
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
        },
    'CmsNumberFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          final optional = config?.getField('optional')?.toBoolValue() ?? false;

          String? resolvedOption = optionSource;
          if (optional && resolvedOption == null) {
            resolvedOption = 'CmsNumberOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'CmsNumberOption(',
                'CmsNumberOption(optional: true, ',
              );
            }
          }

          return '''CmsNumberField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'CmsBooleanFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          return '''CmsBooleanField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'CmsCheckboxFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

          return '''CmsCheckboxField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'CmsDateFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          final optional = config?.getField('optional')?.toBoolValue() ?? false;

          String? resolvedOption = optionSource;
          if (optional && resolvedOption == null) {
            resolvedOption = 'CmsDateOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'CmsDateOption(',
                'CmsDateOption(optional: true, ',
              );
            }
          }

          return '''CmsDateField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'CmsDateTimeFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          final optional = config?.getField('optional')?.toBoolValue() ?? false;

          String? resolvedOption = optionSource;
          if (optional && resolvedOption == null) {
            resolvedOption = 'CmsDateTimeOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'CmsDateTimeOption(',
                'CmsDateTimeOption(optional: true, ',
              );
            }
          }

          return '''CmsDateTimeField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'CmsUrlFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          final optional = config?.getField('optional')?.toBoolValue() ?? false;

          String? resolvedOption = optionSource;
          if (optional && resolvedOption == null) {
            resolvedOption = 'CmsUrlOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'CmsUrlOption(',
                'CmsUrlOption(optional: true, ',
              );
            }
          }

          return '''CmsUrlField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'CmsSlugFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

          return '''CmsSlugField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'CmsImageFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

          return '''CmsImageField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'CmsFileFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          final optional = config?.getField('optional')?.toBoolValue() ?? false;

          String? resolvedOption = optionSource;
          if (optional && resolvedOption == null) {
            resolvedOption = 'CmsFileOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'CmsFileOption(',
                'CmsFileOption(optional: true, ',
              );
            }
          }

          return '''CmsFileField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'CmsArrayFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

          // Extract T from CmsArrayFieldConfig<T>
          final configType = config?.type;
          String? genericType;
          ClassElement? genericClassElement;

          if (configType is InterfaceType &&
              configType.typeArguments.isNotEmpty) {
            final T = configType.typeArguments[0];
            genericType = T.getDisplayString(withNullability: false);
            if (T is InterfaceType && T.element is ClassElement) {
              genericClassElement = T.element as ClassElement;
            }
          }

          if (genericType == null) {
            throw InvalidGenerationSourceError(
              'Could not extract type parameter from CmsArrayFieldConfig. '
              'Use explicit type: @CmsArrayFieldConfig<String>() instead of @CmsArrayFieldConfig().',
              element: field,
            );
          }

          String inferredFieldCode;

          if (innerSource != null) {
            // Use explicit inner config
            inferredFieldCode = innerSource
                .replaceAll('FieldConfig', 'Field')
                .replaceFirst('(', "(name: 'item', title: 'Item', ");
          } else {
            // Infer based on genericType
            const primitiveTypes = {
              'String': 'CmsStringField',
              'num': 'CmsNumberField',
              'int': 'CmsNumberField',
              'double': 'CmsNumberField',
              'bool': 'CmsBooleanField',
              'DateTime': 'CmsDateTimeField',
            };

            if (primitiveTypes.containsKey(genericType)) {
              final fieldClass = primitiveTypes[genericType]!;
              inferredFieldCode =
                  "$fieldClass(name: 'item', title: '${_titleCase(genericType)}')";
            } else {
              if (genericClassElement != null && discoveryQueue != null) {
                discoveryQueue.add(genericClassElement);
              }
              // Assume it's a CMS object and follow the fields list naming convention
              final typeName = genericType;
              final fieldsListName =
                  '${typeName[0].toLowerCase()}${typeName.substring(1)}Fields';

              inferredFieldCode =
                  '''CmsObjectField(
    name: 'item',
    title: '${_titleCase(typeName)}',
    option: CmsObjectOption(children: [ColumnFields(children: $fieldsListName)]),
  )''';
            }
          }

          return '''CmsArrayField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    innerField: $inferredFieldCode,
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'CmsBlockFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          return '''CmsBlockField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'CmsReferenceFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          return '''CmsReferenceField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'CmsCrossDatasetReferenceFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          return '''CmsCrossDatasetReferenceField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'CmsGeopointFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          return '''CmsGeopointField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'CmsColorFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
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
    'CmsDropdownFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

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
    'CmsMultiDropdownFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

          // Extract the generic type from CmsMultiDropdownFieldConfig<T>
          final configType = config?.type?.toString() ?? '';
          final genericTypeMatch = RegExp(
            r'CmsMultiDropdownFieldConfig<(.+?)>',
          ).firstMatch(configType);
          final genericType = genericTypeMatch?.group(1) ?? 'dynamic';

          return '''CmsMultiDropdownField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'CmsObjectFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

          // If no explicit option, try to auto-resolve from the field's type
          String? resolvedOption = optionSource;
          if (resolvedOption == null) {
            final fieldType = field.type;
            final typeElement = fieldType is InterfaceType
                ? fieldType.element
                : null;
            if (typeElement is ClassElement) {
              final typeName = typeElement.displayName;
              // Assume any non-primitive class used with @CmsObjectFieldConfig follows the convention
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

    final topLevelClassName = element.name;
    if (topLevelClassName == null) {
      throw InvalidGenerationSourceError('Class has no name', element: element);
    }

    // Queue for classes to process, starting with the annotated class.
    final discoveryQueue = Queue<ClassElement>()..add(element);
    // Set to keep track of processed classes to avoid duplicates and loops.
    final processedClasses = <String>{topLevelClassName};
    // List to hold the generated source code for each class's field list.
    final generatedFieldLists = <String>[];

    while (discoveryQueue.isNotEmpty) {
      final currentElement = discoveryQueue.removeFirst();
      final className = currentElement.name;
      if (className == null) {
        throw InvalidGenerationSourceError(
          'Class has no name',
          element: currentElement,
        );
      }

      // Generate field configurations and discover new nested classes.
      final (fieldConfigs, newlyDiscovered) = await _generateFieldList(
        currentElement,
      );

      // Add newly discovered classes to the queue if they haven't been processed.
      for (final discovered in newlyDiscovered) {
        final discoveredName = discovered.name;
        if (discoveredName != null &&
            !processedClasses.contains(discoveredName)) {
          discoveryQueue.add(discovered);
          processedClasses.add(discoveredName);
        }
      }

      if (fieldConfigs.isNotEmpty) {
        final fieldsListName =
            '${className[0].toLowerCase()}${className.substring(1)}Fields';
        generatedFieldLists.add('''
/// Generated CmsField list for $className
final $fieldsListName = [
  ${fieldConfigs.join(',\n  ')},
];
''');
      }
    }

    if (generatedFieldLists.isEmpty) return '';

    // Extract CmsConfig annotation parameters for the top-level class.
    final title = annotation.read('title').stringValue;
    final description = annotation.read('description').stringValue;
    final id = annotation.peek('id')?.stringValue;

    final topLevelFieldsListName =
        '${topLevelClassName[0].toLowerCase()}${topLevelClassName.substring(1)}Fields';
    final typeSpecName =
        '${topLevelClassName[0].toLowerCase()}${topLevelClassName.substring(1)}TypeSpec';

    final idField = id != null
        ? "name: '$id',"
        : "name: '${topLevelClassName[0].toLowerCase()}${topLevelClassName.substring(1)}',";

    final documentTypeSpec =
        '''
/// Generated document type spec for $topLevelClassName.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final $typeSpecName = DocumentTypeSpec<$topLevelClassName>(
  $idField
  title: '${title.replaceAll("'", "\\'")}',
  description: '${description.replaceAll("'", "\\'")}',
  fields: $topLevelFieldsListName,
  defaultValue: $topLevelClassName.defaultValue,
);
''';

    // Combine all generated field lists and the final DocumentTypeSpec.
    return '${generatedFieldLists.join('\n')}\n$documentTypeSpec\n';
  }

  /// Generates the list of CmsField strings for a given [ClassElement] and
  /// discovers nested classes that also need to be processed.
  Future<(List<String> fieldConfigs, List<ClassElement> discoveredClasses)>
  _generateFieldList(ClassElement element) async {
    final fields = element.fields.where(
      (f) => !f.isStatic && f.name != 'defaultValue',
    );
    final fieldConfigs = <String>[];
    final discoveredClasses = <ClassElement>[];

    for (final field in fields) {
      String? configCode;
      final annotations = field.metadata.annotations;
      for (final annotation in annotations) {
        final annotationValue = annotation.computeConstantValue();
        if (annotationValue == null) continue;

        final annotationType = annotationValue.type;
        if (annotationType == null) continue;

        final displayName = annotationType.element?.displayName;

        if (displayName == null || !_fieldConfigs.containsKey(displayName)) {
          continue;
        }

        final optionSource = await _getOptionSourceFromElementAnnotation(
          field,
          annotation,
          displayName,
        );
        final innerSource = await _getInnerSourceFromElementAnnotation(
          field,
          annotation,
          displayName,
        );

        configCode = _fieldConfigs[displayName]?.call(
          field,
          annotationValue,
          optionSource: optionSource,
          innerSource: innerSource,
          discoveryQueue: discoveredClasses,
        );

        if (configCode != null) break;
      }

      if (configCode != null) {
        fieldConfigs.add(configCode);
      }
    }

    return (fieldConfigs, discoveredClasses);
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
          (word) => word.isEmpty
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
