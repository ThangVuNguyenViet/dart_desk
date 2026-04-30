import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_desk_generator/src/generators/optional_resolver.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

Future<FieldElement> _resolveField(String fieldDecl) async {
  final source = '''
class Holder {
  $fieldDecl
}
''';
  final library = await resolveSource(
    'library tester;\n$source',
    (resolver) async => (await resolver.findLibraryByName('tester'))!,
  );
  final cls = library.getClass('Holder')!;
  return cls.fields.firstWhere((f) => f.name != null && f.name!.isNotEmpty);
}

void main() {
  group('resolveOptional', () {
    test('nullable field, no annotation source -> true', () async {
      final field = await _resolveField('final String? title;');
      expect(
        resolveOptional(field: field, configOptional: null, optionalSource: null),
        isTrue,
      );
    });

    test('nullable field, annotation optional: false -> false', () async {
      final field = await _resolveField('final String? title;');
      expect(
        resolveOptional(field: field, configOptional: false, optionalSource: 'false'),
        isFalse,
      );
    });

    test('nullable field, annotation optional: true -> true', () async {
      final field = await _resolveField('final String? title;');
      expect(
        resolveOptional(field: field, configOptional: true, optionalSource: 'true'),
        isTrue,
      );
    });

    test('non-nullable field, no annotation source -> false', () async {
      final field = await _resolveField('final String title;');
      expect(
        resolveOptional(field: field, configOptional: null, optionalSource: null),
        isFalse,
      );
    });

    test('non-nullable field, annotation optional: false -> false', () async {
      final field = await _resolveField('final String title;');
      expect(
        resolveOptional(field: field, configOptional: false, optionalSource: 'false'),
        isFalse,
      );
    });

    test('non-nullable field, annotation optional: true -> throws', () async {
      final field = await _resolveField('final String title;');
      expect(
        () => resolveOptional(field: field, configOptional: true, optionalSource: 'true'),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });
  });
}
