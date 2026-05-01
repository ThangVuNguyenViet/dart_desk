import 'package:dart_desk/src/extensions/object_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ObjectExtensions', () {
    group('let', () {
      test('returns block result when value is non-null', () {
        const String value = 'hello';
        final result = (value as String?).let((v) => v.length, initialValue: 0);
        expect(result, 5);
      });

      test('returns initialValue when value is null', () {
        const String? value = null;
        final result = value.let((v) => v.length, initialValue: 0);
        expect(result, 0);
      });
    });

    group('letOrNull', () {
      test('returns block result when value is non-null', () {
        const String value = 'hello';
        final result = (value as String?).letOrNull((v) => v.length);
        expect(result, 5);
      });

      test('returns null when value is null', () {
        const String? value = null;
        final result = value.letOrNull((v) => v.length);
        expect(result, isNull);
      });
    });
  });
}
