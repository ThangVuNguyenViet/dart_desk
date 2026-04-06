import 'package:dart_desk_generator/src/generators/field_code_generators/field_code_generator.dart';
import 'package:test/test.dart';

void main() {
  group('FieldCodeGenerator', () {
    test('abstract class cannot be instantiated directly', () {
      expect(() => FieldCodeGenerator(), throwsA(isA<TypeError>()));
    });
  });
}
