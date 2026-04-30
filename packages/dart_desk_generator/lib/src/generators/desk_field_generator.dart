import 'dart:async';
import 'dart:collection';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_desk_annotation/dart_desk_annotation_generator.dart';
import 'package:source_gen/source_gen.dart';

import 'field_code_generators/array_field_generator.dart';
import 'field_code_generators/boolean_field_generator.dart';
import 'field_code_generators/checkbox_field_generator.dart';
import 'field_code_generators/color_field_generator.dart';
import 'field_code_generators/date_field_generator.dart';
import 'field_code_generators/datetime_field_generator.dart';
import 'field_code_generators/dropdown_field_generator.dart';
import 'field_code_generators/file_field_generator.dart';
import 'field_code_generators/image_field_generator.dart';
import 'field_code_generators/number_field_generator.dart';
import 'field_code_generators/object_field_generator.dart';
import 'field_code_generators/reference_field_generator.dart';
import 'field_code_generators/slug_field_generator.dart';
import 'field_code_generators/string_field_generator.dart';
import 'field_code_generators/url_field_generator.dart';
import 'optional_resolver.dart';
import 'field_code_registry.dart'
    as registry
    show
        BlockFieldGenerator,
        CrossDatasetReferenceFieldGenerator,
        GeopointFieldGenerator;
import 'field_code_registry.dart'
    hide
        BlockFieldGenerator,
        CrossDatasetReferenceFieldGenerator,
        GeopointFieldGenerator;
import 'type_inference_engine.dart';
import 'utils.dart';

const _primitiveTypes = {'String', 'int', 'num', 'double', 'bool', 'DateTime'};

/// Generates DeskField lists from classes annotated with @DeskModel.
/// This generator processes the @DeskFieldConfig annotations on fields to create
/// corresponding DeskField instances for runtime use.
class DeskFieldGenerator extends GeneratorForAnnotation<DeskModel> {
  static final _registry = FieldCodeRegistry();
  static final _inferenceEngine = TypeInferenceEngine(_registry);

  static void _registerDefaults() {
    _registry.register(StringFieldGenerator());
    _registry.register(NumberFieldGenerator());
    _registry.register(BooleanFieldGenerator());
    _registry.register(CheckboxFieldGenerator());
    _registry.register(DateFieldGenerator());
    _registry.register(DateTimeFieldGenerator());
    _registry.register(UrlFieldGenerator());
    _registry.register(SlugFieldGenerator());
    _registry.register(ImageFieldGenerator());
    _registry.register(FileFieldGenerator());
    _registry.register(ColorFieldGenerator());
    _registry.register(ArrayFieldGenerator());
    _registry.register(registry.BlockFieldGenerator());
    _registry.register(ReferenceFieldGenerator());
    _registry.register(registry.CrossDatasetReferenceFieldGenerator());
    _registry.register(registry.GeopointFieldGenerator());
    _registry.register(DropdownFieldGenerator());
    _registry.register(MultiDropdownFieldGenerator());
    _registry.register(ObjectFieldGenerator());
    _inferenceEngine.buildDefaults();
  }

  static bool _initialized = false;

  static void ensureInitialized() {
    if (!_initialized) {
      _registerDefaults();
      _initialized = true;
    }
  }

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

  static const _arrayPrimitiveFields = {
    'String': 'DeskStringField',
    'num': 'DeskNumberField',
    'int': 'DeskNumberField',
    'double': 'DeskNumberField',
    'bool': 'DeskBooleanField',
    'DateTime': 'DeskDateTimeField',
  };

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

  static String? _displayType(DartType? type) {
    if (type == null) return null;
    final displayType = type.getDisplayString();
    return displayType.endsWith('?')
        ? displayType.substring(0, displayType.length - 1)
        : displayType;
  }

  static DartType? _arrayItemDartType(FieldElement field) {
    final fieldType = field.type;
    if (fieldType is InterfaceType && fieldType.typeArguments.isNotEmpty) {
      return fieldType.typeArguments.first;
    }
    return null;
  }

  static ClassElement? _classElementFromType(DartType? type) {
    if (type is InterfaceType && type.element is ClassElement) {
      return type.element as ClassElement;
    }
    return null;
  }

  static String _singleQuoted(String value) {
    return "'${value.replaceAll('\\', r'\\').replaceAll("'", r"\'")}'";
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

  static String? _namedArgumentSource(String source, String name) {
    for (final arg in _splitTopLevelArguments(source)) {
      final prefix = '$name:';
      if (arg.startsWith(prefix)) {
        return arg.substring(prefix.length).trim();
      }
    }
    return null;
  }

  static String? _fieldConfigKeyForDisplayName(String? displayName) {
    if (displayName == null) return null;
    if (_fieldConfigs.containsKey(displayName)) return displayName;

    final genericStart = displayName.indexOf('<');
    if (genericStart == -1) return null;

    final rawDisplayName = displayName.substring(0, genericStart);
    return _fieldConfigs.containsKey(rawDisplayName) ? rawDisplayName : null;
  }

  static String? _fieldConfigKeyFor(DartType annotationType) {
    return _fieldConfigKeyForDisplayName(
      annotationType.element?.displayName ?? _displayType(annotationType),
    );
  }

  static String? _fieldConfigKeyForAnnotation(ElementAnnotation annotation) {
    final element = annotation.element;
    if (element is ConstructorElement) {
      return _fieldConfigKeyForDisplayName(
        element.enclosingElement.displayName,
      );
    }
    return _fieldConfigKeyForDisplayName(element?.displayName);
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

  static String _explicitInnerFieldCode(
    DartObject? innerConfig,
    String source,
  ) {
    // coverage:ignore-start
    // Constant-value fallback paths are exercised through build_test output
    // assertions, but VM coverage does not consistently attribute source_gen
    // constant-reader branches in generated builders.
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
    // coverage:ignore-end

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

  static String? _inferredFieldCodeFor(
    FieldElement field,
    List<ClassElement> discoveryQueue,
  ) {
    // coverage:ignore-start
    // Covered by generated output tests for discovered nested classes. The
    // source_gen builder isolates do not reliably mark this private helper.
    final fieldName = field.name;
    if (fieldName == null) return null;

    final fieldType = field.type;
    final typeName = _displayType(fieldType);
    if (typeName == null) return null;

    if (fieldType is InterfaceType &&
        fieldType.element.displayName == 'List' &&
        fieldType.typeArguments.isNotEmpty) {
      final itemType = fieldType.typeArguments.first;
      final itemTypeName = _displayType(itemType);
      if (itemTypeName == null) return null;

      String inferredFieldCode;
      if (_arrayPrimitiveFields.containsKey(itemTypeName)) {
        final fieldClass = _arrayPrimitiveFields[itemTypeName]!;
        inferredFieldCode =
            "$fieldClass(name: 'item', title: '${_titleCase(itemTypeName)}')";
      } else if (_isImageReferenceType(itemTypeName)) {
        inferredFieldCode = "DeskImageField(name: 'item', title: 'Item')";
      } else {
        final itemClassElement = _classElementFromType(itemType);
        if (itemClassElement != null) {
          discoveryQueue.add(itemClassElement);
        }
        final fieldsListName =
            '${itemTypeName[0].toLowerCase()}${itemTypeName.substring(1)}Fields';
        inferredFieldCode =
            '''DeskObjectField(
    name: 'item',
    title: '${_titleCase(itemTypeName)}',
    option: DeskObjectOption(children: [ColumnFields(children: $fieldsListName)]),
  )''';
      }

      // For non-primitive array item types, require a static $fromMap method.
      final isPrimitive =
          _arrayPrimitiveFields.containsKey(itemTypeName) ||
          _isImageReferenceType(itemTypeName);
      String? fromMapCode;
      if (!isPrimitive) {
        final itemClassElement = _classElementFromType(itemType);
        if (itemClassElement != null) {
          final hasFromMap = itemClassElement.methods.any(
            (m) => m.isStatic && m.name == r'$fromMap',
          );
          if (!hasFromMap) {
            throw InvalidGenerationSourceError(
              '$itemTypeName is used as a DeskArrayField item type but does '
              'not have a static \$fromMap method. Add:\n\n'
              '  static $itemTypeName \$fromMap(Map<String, dynamic> map) => '
              '${itemTypeName}Mapper.fromMap(map);\n',
              element: field,
            );
          }
        }
        fromMapCode = 'fromMap: $itemTypeName.\$fromMap,';
      }

      return '''DeskArrayField<$itemTypeName>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    innerField: $inferredFieldCode,
    ${fromMapCode ?? ''}
  )''';
    }

    final primitiveFieldClass = _arrayPrimitiveFields[typeName];
    if (primitiveFieldClass != null) {
      return "$primitiveFieldClass(name: '$fieldName', title: '${_titleCase(fieldName)}')";
    }

    if (typeName == 'Uri') {
      return "DeskUrlField(name: '$fieldName', title: '${_titleCase(fieldName)}')";
    }

    if (_isImageReferenceType(typeName)) {
      return "DeskImageField(name: '$fieldName', title: '${_titleCase(fieldName)}')";
    }

    if (typeName == 'Object' || typeName == 'dynamic') {
      return null;
    }

    final typeElement = _classElementFromType(fieldType);
    if (typeElement == null) return null;

    discoveryQueue.add(typeElement);
    final fieldsListName =
        '${typeName[0].toLowerCase()}${typeName.substring(1)}Fields';
    return '''DeskObjectField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    option: DeskObjectOption(children: [ColumnFields(children: $fieldsListName)]),
  )''';
  } // coverage:ignore-end

  static bool _isImageReferenceType(String typeName) {
    return typeName == 'ImageReference' || typeName == 'ImageRef';
  }

  // coverage:ignore-start
  // Field config closures are verified through build_test output assertions for
  // every supported config. VM coverage attribution is inconsistent for these
  // static closure literals when executed inside source_gen builders.
  static final _fieldConfigs = {
    'DeskText':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
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
            resolvedOption = 'DeskTextOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'DeskTextOption(',
                'DeskTextOption(optional: true, ',
              );
            }
          }

          return '''DeskTextField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'DeskString':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          final _optionalSrc = _namedArgumentSource(
            annotationSource ?? '',
            'optional',
          );
          final optional = resolveOptional(
            field: field,
            configOptional: _optionalSrc == 'true'
                ? true
                : _optionalSrc == 'false'
                ? false
                : null,
            optionalSource: _optionalSrc,
          );

          String? resolvedOption = optionSource;
          if (optional && resolvedOption == null) {
            resolvedOption = 'DeskStringOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'DeskStringOption(',
                'DeskStringOption(optional: true, ',
              );
            }
          }

          return '''DeskStringField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'DeskNumber':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
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
            resolvedOption = 'DeskNumberOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'DeskNumberOption(',
                'DeskNumberOption(optional: true, ',
              );
            }
          }

          return '''DeskNumberField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'DeskBoolean':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          return '''DeskBooleanField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'DeskCheckbox':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

          return '''DeskCheckboxField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'DeskDate':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
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
            resolvedOption = 'DeskDateOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'DeskDateOption(',
                'DeskDateOption(optional: true, ',
              );
            }
          }

          return '''DeskDateField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'DeskDateTime':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
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
        },
    'DeskUrl':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
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
            resolvedOption = 'DeskUrlOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'DeskUrlOption(',
                'DeskUrlOption(optional: true, ',
              );
            }
          }

          return '''DeskUrlField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'DeskSlugFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

          return '''DeskSlugField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'DeskImage':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

          return '''DeskImageField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'DeskFile':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
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
            resolvedOption = 'DeskFileOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'DeskFileOption(',
                'DeskFileOption(optional: true, ',
              );
            }
          }

          return '''DeskFileField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'DeskArray':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

          // Extract T from DeskArray<T>. If the annotation uses
          // inference (common when `inner` is provided), fall back to List<T>.
          final configType = config?.type;
          String? genericType;
          ClassElement? genericClassElement;

          if (configType is InterfaceType &&
              configType.typeArguments.isNotEmpty) {
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
              config?.getFieldOrNull('inner'),
              innerSource,
            );
          } else {
            // Infer based on genericType
            if (_arrayPrimitiveFields.containsKey(genericType)) {
              final fieldClass = _arrayPrimitiveFields[genericType]!;
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
        },
    'DeskBlock':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          return '''DeskBlockField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'DeskReferenceFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          return '''DeskReferenceField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'DeskCrossDatasetReferenceFieldConfig':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          return '''DeskCrossDatasetReferenceField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'DeskGeopoint':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }
          return '''DeskGeopointField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'DeskColor':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
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
            resolvedOption = 'DeskColorOption(optional: true)';
          } else if (optional && resolvedOption != null) {
            if (!resolvedOption.contains('optional')) {
              resolvedOption = resolvedOption.replaceFirst(
                'DeskColorOption(',
                'DeskColorOption(optional: true, ',
              );
            }
          }

          return '''DeskColorField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
    'DeskDropdown':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

          // Extract the generic type from DeskDropdown<T>
          final configType = config?.type?.toString() ?? '';
          final genericTypeMatch = RegExp(
            r'DeskDropdown<(.+?)>',
          ).firstMatch(configType);
          final genericType =
              genericTypeMatch?.group(1) ??
              _displayType(field.type) ??
              'dynamic';

          // For non-primitive dropdown types, require a static $fromMap method.
          String? fromMapCode;
          final dropdownClassElement = _classElementFromType(field.type);
          if (!_primitiveTypes.contains(genericType) &&
              dropdownClassElement != null) {
            final hasFromMap = dropdownClassElement.methods.any(
              (m) => m.isStatic && m.name == r'$fromMap',
            );
            if (!hasFromMap) {
              throw InvalidGenerationSourceError(
                '$genericType is used as a DeskDropdownField type but does '
                'not have a static \$fromMap method. Add:\n\n'
                '  static $genericType \$fromMap(Map<String, dynamic> map) => '
                '${genericType}Mapper.fromMap(map);\n',
                element: field,
              );
            }
            fromMapCode = 'fromMap: $genericType.\$fromMap,';
          }

          return '''DeskDropdownField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${fromMapCode ?? ''}
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'DeskMultiDropdown':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
          List<ClassElement>? discoveryQueue,
        }) {
          final fieldName = field.name;
          if (fieldName == null) {
            throw InvalidGenerationSourceError(
              'Field has no name',
              element: field,
            );
          }

          // Extract the generic type from DeskMultiDropdown<T>
          final configType = config?.type?.toString() ?? '';
          final genericTypeMatch = RegExp(
            r'DeskMultiDropdown<(.+?)>',
          ).firstMatch(configType);
          final genericType =
              genericTypeMatch?.group(1) ??
              _displayType(_arrayItemDartType(field)) ??
              'dynamic';

          // For non-primitive multi-dropdown types, require a static $fromMap method.
          String? multiFromMapCode;
          final multiDropdownClassElement = _classElementFromType(
            _arrayItemDartType(field),
          );
          if (!_primitiveTypes.contains(genericType) &&
              multiDropdownClassElement != null) {
            final hasFromMap = multiDropdownClassElement.methods.any(
              (m) => m.isStatic && m.name == r'$fromMap',
            );
            if (!hasFromMap) {
              throw InvalidGenerationSourceError(
                '$genericType is used as a DeskMultiDropdownField type but does '
                'not have a static \$fromMap method. Add:\n\n'
                '  static $genericType \$fromMap(Map<String, dynamic> map) => '
                '${genericType}Mapper.fromMap(map);\n',
                element: field,
              );
            }
            multiFromMapCode = 'fromMap: $genericType.\$fromMap,';
          }

          return '''DeskMultiDropdownField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${multiFromMapCode ?? ''}
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
        },
    'DeskObject':
        (
          FieldElement field,
          DartObject? config, {
          String? optionSource,
          String? innerSource,
          String? annotationSource,
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
              // Assume any non-primitive class used with @DeskObject follows the convention
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
                    'DeskObjectOption(children: [ColumnFields(children: $fieldsListName)])';
              }
            }
          }

          // For non-primitive object types, require a static $fromMap method.
          String? objFromMapCode;
          {
            final fieldType = field.type;
            final typeElement = fieldType is InterfaceType
                ? fieldType.element
                : null;
            if (typeElement is ClassElement) {
              final typeName = typeElement.displayName;
              if (!_primitiveTypes.contains(typeName)) {
                final hasFromMap = typeElement.methods.any(
                  (m) => m.isStatic && m.name == r'$fromMap',
                );
                if (!hasFromMap) {
                  throw InvalidGenerationSourceError(
                    '$typeName is used as a DeskObjectField type but does '
                    'not have a static \$fromMap method. Add:\n\n'
                    '  static $typeName \$fromMap(Map<String, dynamic> map) => '
                    '${typeName}Mapper.fromMap(map);\n',
                    element: field,
                  );
                }
                objFromMapCode = 'fromMap: $typeName.\$fromMap,';
              }
            }
          }

          return '''DeskObjectField(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${objFromMapCode ?? ''}
    ${resolvedOption != null ? 'option: $resolvedOption,' : ''}
  )''';
        },
  };
  // coverage:ignore-end

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    ensureInitialized();

    // Set the node resolver for utils
    nodeResolver = buildStep.resolver;
    if (element is! ClassElement) {
      // coverage:ignore-start
      throw InvalidGenerationSourceError(
        '`@DeskModel` can only be used on classes.',
        element: element,
      );
      // coverage:ignore-end
    }

    final topLevelClassName = element.name;
    if (topLevelClassName == null) {
      // coverage:ignore-start
      throw InvalidGenerationSourceError('Class has no name', element: element);
      // coverage:ignore-end
    }

    // Queue for classes to process, starting with the annotated class.
    final discoveryQueue = Queue<ClassElement>()..add(element);
    // Set to keep track of processed classes to avoid duplicates and loops.
    final processedClasses = <String>{topLevelClassName};
    // List to hold the generated source code for each class's field list.
    final generatedFieldLists = <String>[];

    // Always infer unannotated fields. The distinction is that:
    // - Top-level @DeskModel class: included in DocumentTypeSpec
    // - Discovered nested classes (from arrays/references): only provide fields list, no spec
    while (discoveryQueue.isNotEmpty) {
      final currentElement = discoveryQueue.removeFirst();
      final className = currentElement.name;
      if (className == null) {
        // coverage:ignore-start
        throw InvalidGenerationSourceError(
          'Class has no name',
          element: currentElement,
        );
        // coverage:ignore-end
      }

      // Generate field configurations and discover new nested classes.
      // Always infer unannotated fields for both top-level and nested classes.
      final (fieldConfigs, newlyDiscovered) = await _generateFieldList(
        currentElement,
        inferUnannotatedFields: true,
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

      // Skip emitting field lists for discovered classes that have their own
      // @DeskModel annotation — their own generator invocation will handle them.
      final isTopLevel = currentElement == element;
      final hasDeskModel =
          !isTopLevel &&
          currentElement.metadata.annotations.any(
            (a) => a.element?.enclosingElement?.displayName == 'DeskModel',
          );

      if (fieldConfigs.isNotEmpty && !hasDeskModel) {
        final fieldsListName =
            '${className[0].toLowerCase()}${className.substring(1)}Fields';
        generatedFieldLists.add('''
/// Generated DeskField list for $className
final $fieldsListName = [
  ${fieldConfigs.join(',\n  ')},
];
''');
      }
    }

    if (generatedFieldLists.isEmpty) return '';

    // Extract DeskModel annotation parameters for the top-level class.
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
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
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

  /// Generates the list of DeskField strings for a given [ClassElement] and
  /// discovers nested classes that also need to be processed.
  Future<(List<String> fieldConfigs, List<ClassElement> discoveredClasses)>
  _generateFieldList(
    ClassElement element, {
    bool inferUnannotatedFields = false,
  }) async {
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
        final annotationType = annotationValue?.type;

        final displayName = annotationType != null
            ? _fieldConfigKeyFor(annotationType)
            : _fieldConfigKeyForAnnotation(annotation);
        final sourceDisplayName = _fieldConfigKeyForDisplayName(
          _innerConfigTypeFromSource(
            annotation.toSource().replaceFirst('@', ''),
          ),
        );
        final fieldConfigName = displayName ?? sourceDisplayName;

        if (fieldConfigName == null) {
          continue;
        }

        String? optionSource;
        String? innerSource;
        if (annotationType != null) {
          optionSource = await _getOptionSourceFromElementAnnotation(
            field,
            annotation,
            fieldConfigName,
          );
          innerSource = await _getInnerSourceFromElementAnnotation(
            field,
            annotation,
            fieldConfigName,
          );
        }
        optionSource ??= _namedArgumentSource(annotation.toSource(), 'option');
        innerSource ??= _namedArgumentSource(annotation.toSource(), 'inner');

        configCode = _fieldConfigs[fieldConfigName]?.call(
          field,
          annotationValue,
          optionSource: optionSource,
          innerSource: innerSource,
          annotationSource: annotation.toSource(),
          discoveryQueue: discoveredClasses,
        );

        if (configCode != null) break;
      }

      if (configCode != null) {
        fieldConfigs.add(configCode);
      } else if (inferUnannotatedFields) {
        final inferredCode = _inferredFieldCodeFor(field, discoveredClasses);
        if (inferredCode != null) {
          fieldConfigs.add(inferredCode);
        }
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
}
