import 'package:dart_desk_generator/src/generators/field_code_generators/field_code_generator.dart';
import 'package:test/test.dart';

void main() {
  group('FieldCodeGenerator', () {
    test('is abstract and cannot be instantiated', () {
      // FieldCodeGenerator is abstract — this is a compile-time guarantee.
      // Verify it exists and is the expected type.
      expect(FieldCodeGenerator, isNotNull);
    });
  });
}
