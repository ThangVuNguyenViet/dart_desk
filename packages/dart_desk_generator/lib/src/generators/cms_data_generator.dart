import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:dart_desk_annotation/dart_desk_annotation_generator.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:source_gen/source_gen.dart';

/// Generates CmsConfig wrapper classes from classes annotated with @CmsConfig.
///
/// For each @CmsConfig annotated class, generates:
/// - A new class with suffix 'CmsConfig'
/// - All fields wrapped in `CmsData<T>`
/// - Constructor with all fields as required named parameters
/// - Nested @CmsConfig classes get their own CmsConfig suffix in the generic type
///
/// Example:
/// ```dart
/// @CmsConfig()
/// class HomeScreenConfig {
///   final String title;
///   final HomeScreenButtonConfig buttonConfig;
/// }
///
/// // Generates:
/// class HomeScreenConfigCmsConfig {
///   HomeScreenConfigCmsConfig({
///     required this.title,
///     required this.buttonConfig,
///   });
///
///   final CmsData<String> title;
///   final CmsData<HomeScreenButtonConfigCmsConfig> buttonConfig;
/// }
/// ```
class CmsConfigGenerator extends GeneratorForAnnotation<CmsConfig> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // 1. Validate that the annotated element is a class
    if (element is! ClassElement) {
      // coverage:ignore-start
      throw InvalidGenerationSourceError(
        '`@CmsConfig` can only be used on classes.',
        element: element,
      );
      // coverage:ignore-end
    }

    final className = element.name;
    final generatedClassName = '${className}CmsConfig';

    // 2. Transform each field to CmsData<T>
    final typeChecker = TypeChecker.typeNamed(CmsConfig);
    final fields = element.fields
        .where((field) => !field.isStatic && field.name != 'defaultValue')
        .map((field) {
          final fieldType = field.type.getDisplayString();
          final fieldElement = field.type.element;

          // Determine the CmsData generic type
          // Strip trailing '?' for nullability — we'll re-add it after the suffix
          final isNullable = fieldType.endsWith('?');
          final baseType = isNullable
              ? fieldType.substring(0, fieldType.length - 1)
              : fieldType;
          final nullSuffix = isNullable ? '?' : '';
          String cmsDataType;
          if (fieldElement is ClassElement &&
              typeChecker.hasAnnotationOfExact(fieldElement)) {
            // If the field's type also has @CmsConfig, append CmsConfig suffix
            cmsDataType = 'CmsData<${baseType}CmsConfig$nullSuffix>';
          } else {
            // Otherwise, use the field type as-is
            cmsDataType = 'CmsData<$fieldType>';
          }

          return Field(
            (b) => b
              ..name = field.name
              ..modifier = FieldModifier.final$
              ..type = refer(cmsDataType),
          );
        });

    // 3. Generate constructor with all fields as required named parameters
    final constructor = Constructor(
      (b) => b
        ..optionalParameters.addAll(
          element.fields
              .where((field) => !field.isStatic && field.name != 'defaultValue')
              .map((field) {
                final fieldName = field.displayName;
                return Parameter(
                  (b) => b
                    ..name = fieldName
                    ..toThis = true
                    ..named = true
                    ..required = true,
                );
              }),
        ),
    );

    // 4. Build the generated class
    final generatedClass = Class(
      (b) => b
        ..name = generatedClassName
        ..fields.addAll(fields)
        ..constructors.add(constructor),
    );

    // 5. Emit and format the code
    final emitter = DartEmitter();
    return DartFormatter(
      languageVersion: Version(3, 7, 0),
    ).format('${generatedClass.accept(emitter)}');
  }
}
