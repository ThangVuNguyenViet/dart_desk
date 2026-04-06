import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_desk_generator/src/generators/utils.dart';
import 'package:test/test.dart';

void main() {
  group('generator utils', () {
    test('converts map and list values', () {
      expect(toMap<int>({'a': 1}), {'a': 1});
      expect(toMap<int>('not a map'), isEmpty);
      expect(toList<int>([1, 2]), [1, 2]);
      expect(toList<int>(1), [1]);
      expect(toList<int>('not an int'), isNull);
    });

    test('formats Prefix', () {
      expect(
        Prefix(1, 2, 3).toString(),
        'Prefix{offset: 1, delta: 2, prefix: 3}',
      );
    });

    test('validates build extension options', () {
      const defaults = {
        '.dart': ['.g.dart'],
      };

      expect(validatedBuildExtensionsFrom(null, defaults), defaults);
      expect(
        validatedBuildExtensionsFrom({
          'build_extensions': {
            '.dart': ['.cms.g.dart'],
          },
        }, defaults),
        {
          '.dart': ['.cms.g.dart'],
        },
      );
      expect(
        validatedBuildExtensionsFrom({
          'build_extensions': {'.dart': '.cms.g.dart'},
        }, defaults),
        {
          '.dart': ['.cms.g.dart'],
        },
      );

      expect(
        () =>
            validatedBuildExtensionsFrom({'build_extensions': 'bad'}, defaults),
        throwsArgumentError,
      );
      expect(
        () => validatedBuildExtensionsFrom({
          'build_extensions': {'bad': '.g.dart'},
        }, defaults),
        throwsArgumentError,
      );
      expect(
        () => validatedBuildExtensionsFrom({
          'build_extensions': {
            '.dart': [123],
          },
        }, defaults),
        throwsArgumentError,
      );
      expect(
        () => validatedBuildExtensionsFrom({'build_extensions': {}}, defaults),
        throwsArgumentError,
      );
    });

    test(
      'resolves annotation argument AST nodes from build elements',
      () async {
        final reader = TestReaderWriter(rootPackage: 'dart_desk_generator');
        await reader.testing.loadIsolateSources();

        await testBuilder(
          _AnnotationLookupBuilder(),
          {
            'dart_desk_generator|lib/input.dart': '''
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

const stringAlias = CmsStringFieldConfig(
  option: CmsStringOption(hidden: true),
);
const indirectStringAlias = stringAlias;

class TypeArgsAnnotation {
  const TypeArgsAnnotation(this.types);

  final List<Type> types;
}

class BaseAnnotation {
  const BaseAnnotation({this.label});

  final String? label;
}

class DerivedAnnotation extends BaseAnnotation {
  const DerivedAnnotation() : super(label: 'from-super');
}

class Example {
  @CmsStringFieldConfig(option: CmsStringOption(hidden: true))
  final String direct;

  @indirectStringAlias
  final String aliased;

  final String? nullableString;

  final dynamic dynamicValue;

  final T genericValue;

  const Example(
    this.direct,
    this.aliased, {
    @CmsStringFieldConfig(option: CmsStringOption(hidden: true))
    required this.nullableString,
    required this.dynamicValue,
    required this.genericValue,
  });
}

@CmsStringFieldConfig(option: CmsStringOption(hidden: true))
class AnnotatedClass {}

@TypeArgsAnnotation([String, int])
class TypeTarget {}

@DerivedAnnotation()
class SuperTarget {}

class RecordHolder {
  final ({@CmsStringFieldConfig(option: CmsStringOption(hidden: true)) String value})
  record;

  const RecordHolder(this.record);
}
''',
          },
          readerWriter: reader,
          generateFor: {'dart_desk_generator|lib/input.dart'},
          outputs: {
            'dart_desk_generator|lib/input.out': decodedMatches(
              contains(
                'CmsStringOption(hidden: true)|CmsStringOption(hidden: true)',
              ),
            ),
          },
        );
      },
    );
  });
}

class _AnnotationLookupBuilder implements Builder {
  @override
  final buildExtensions = const {
    '.dart': ['.out'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (buildStep.inputId.path != 'lib/input.dart') return;

    nodeResolver = buildStep.resolver;
    final library = await buildStep.resolver.libraryFor(buildStep.inputId);
    final example = library.getClass('Example')!;
    final direct = example.fields.firstWhere((field) => field.name == 'direct');
    final aliased = example.fields.firstWhere(
      (field) => field.name == 'aliased',
    );
    final annotationType = direct.metadata.annotations.first
        .computeConstantValue()!
        .type!;
    final annotatedClass = library.getClass('AnnotatedClass')!;
    final constructorParameter = example.constructors.first.formalParameters
        .firstWhere((parameter) => parameter.name == 'nullableString');
    final nullableString = example.fields.firstWhere(
      (field) => field.name == 'nullableString',
    );
    final dynamicValue = example.fields.firstWhere(
      (field) => field.name == 'dynamicValue',
    );
    final genericValue = example.fields.firstWhere(
      (field) => field.name == 'genericValue',
    );
    final typeTarget = library.getClass('TypeTarget')!;
    final superTarget = library.getClass('SuperTarget')!;

    final directNode = await getAnnotationNode(
      direct,
      annotationType,
      'option',
    );
    final directOption = await getResolvedAnnotationNode(
      direct,
      annotationType,
      'option',
    );
    final aliasedOption = await getResolvedAnnotationNode(
      aliased,
      annotationType,
      'option',
    );
    final classOption = await getResolvedAnnotationNode(
      annotatedClass,
      annotationType,
      'option',
    );
    final parameterOption = await getResolvedAnnotationNode(
      constructorParameter,
      annotationType,
      'option',
    );
    final firstArgument = await getResolvedAnnotationNode(
      direct,
      annotationType,
      0,
    );
    final types = typeTarget.metadata.annotations.first
        .computeConstantValue()!
        .getField('types')!
        .toTypeList()!;
    final derivedAnnotation = superTarget.metadata.annotations.first
        .computeConstantValue()!;
    final inheritedLabel = derivedAnnotation.read('label')!.toStringValue();
    final missingInheritedField = derivedAnnotation.read('missing');
    final nullLabel = derivedAnnotation.read('label')!.read('missing');

    await buildStep.writeAsString(
      buildStep.inputId.changeExtension('.out'),
      [
        directNode?.toSource() ?? 'unresolved',
        directOption!.toSource(),
        aliasedOption!.toSource(),
        classOption!.toSource(),
        parameterOption!.toSource(),
        firstArgument?.toSource() ?? 'no-positional-argument',
        nullableString.type.isNullable.toString(),
        dynamicValue.type.isNullableOrDynamic.toString(),
        genericValue.type.isNullableOrDynamic.toString(),
        types.map((type) => type.getDisplayString()).join(','),
        inheritedLabel,
        missingInheritedField?.toString() ?? 'missing',
        nullLabel?.toString() ?? 'null-read',
      ].join('|'),
    );
  }
}
