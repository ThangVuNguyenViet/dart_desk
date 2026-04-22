import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:dart_desk_annotation/dart_desk_annotation_generator.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:source_gen/source_gen.dart';

/// Generates DeskModel wrapper classes from classes annotated with @DeskModel.
///
/// For each @DeskModel annotated class, generates:
/// - A new class with suffix 'DeskModel'
/// - All fields wrapped in `DeskData<T>`
/// - Constructor with all fields as required named parameters
/// - Nested @DeskModel classes get their own DeskModel suffix in the generic type
///
/// Example:
/// ```dart
/// @DeskModel()
/// class HomeScreenConfig {
///   final String title;
///   final HomeScreenButtonConfig buttonConfig;
/// }
///
/// // Generates:
/// class HomeScreenConfigDeskModel {
///   HomeScreenConfigDeskModel({
///     required this.title,
///     required this.buttonConfig,
///   });
///
///   final DeskData<String> title;
///   final DeskData<HomeScreenButtonConfigDeskModel> buttonConfig;
/// }
/// ```
class DeskConfigGenerator extends GeneratorForAnnotation<DeskModel> {
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
        '`@DeskModel` can only be used on classes.',
        element: element,
      );
      // coverage:ignore-end
    }

    final className = element.name;
    final generatedClassName = '${className}DeskModel';

    // 2. Transform each field to DeskData<T>
    final typeChecker = TypeChecker.typeNamed(DeskModel);
    final fields = element.fields
        .where((field) => !field.isStatic && field.name != 'defaultValue')
        .map((field) {
          final fieldType = field.type.getDisplayString();
          final fieldElement = field.type.element;

          // Determine the DeskData generic type
          // Strip trailing '?' for nullability — we'll re-add it after the suffix
          final isNullable = fieldType.endsWith('?');
          final baseType = isNullable
              ? fieldType.substring(0, fieldType.length - 1)
              : fieldType;
          final nullSuffix = isNullable ? '?' : '';
          String deskDataType;
          if (fieldElement is ClassElement &&
              typeChecker.hasAnnotationOfExact(fieldElement)) {
            // If the field's type also has @DeskModel, append DeskModel suffix
            deskDataType = 'DeskData<${baseType}DeskModel$nullSuffix>';
          } else {
            // Otherwise, use the field type as-is
            deskDataType = 'DeskData<$fieldType>';
          }

          return Field(
            (b) => b
              ..name = field.name
              ..modifier = FieldModifier.final$
              ..type = refer(deskDataType),
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
