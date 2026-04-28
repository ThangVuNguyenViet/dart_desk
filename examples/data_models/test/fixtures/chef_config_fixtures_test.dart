// Round-trip contract for every ChefConfig fixture variant.
//
// The variants exist for screen/widget goldens — if any variant fails to
// `dart_mappable` round-trip, every consumer that serializes through the
// editor will silently break. This test catches that at unit level.
import 'package:data_models/example_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChefConfigFixtures', () {
    final variants = <String, ChefConfig Function()>{
      'showcase': ChefConfigFixtures.showcase,
      'empty': ChefConfigFixtures.empty,
      'allFieldsPopulated': ChefConfigFixtures.allFieldsPopulated,
      'withValidationError': ChefConfigFixtures.withValidationError,
    };

    for (final entry in variants.entries) {
      test('${entry.key} round-trips through dart_mappable', () {
        final original = entry.value();
        final restored = ChefConfigMapper.fromMap(original.toMap());
        expect(restored.toMap(), original.toMap());
      });
    }

    test('empty has minimal required fields, no optionals', () {
      final empty = ChefConfigFixtures.empty();
      expect(empty.headline, isEmpty);
      expect(empty.pullQuote, isEmpty);
      expect(empty.curatedDishes, isEmpty);
      expect(empty.refreshCadence, isEmpty);
      expect(empty.intro, isNull);
    });

    test('allFieldsPopulated sets every optional', () {
      final populated = ChefConfigFixtures.allFieldsPopulated();
      expect(populated.intro, isNotNull);
    });

    test('withValidationError leaves a required field empty', () {
      final invalid = ChefConfigFixtures.withValidationError();
      // Headline is required; an empty string fails non-blank validation.
      expect(invalid.headline, isEmpty);
    });
  });
}
