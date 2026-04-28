// Round-trip contract for every document-type fixture variant.
//
// If a variant fails to `dart_mappable` round-trip, every consumer that
// serializes through the editor will silently break. Cheap unit-level guard.
import 'package:data_models/example_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeConfigFixtures', () {
    final variants = <String, HomeConfig Function()>{
      'showcase': HomeConfigFixtures.showcase,
      'empty': HomeConfigFixtures.empty,
      'allFieldsPopulated': HomeConfigFixtures.allFieldsPopulated,
      'withValidationError': HomeConfigFixtures.withValidationError,
    };
    for (final entry in variants.entries) {
      test('${entry.key} round-trips', () {
        final original = entry.value();
        expect(HomeConfigMapper.fromMap(original.toMap()).toMap(), original.toMap());
      });
    }
    test('empty has minimal required fields', () {
      final e = HomeConfigFixtures.empty();
      expect(e.heroEyebrow, isEmpty);
      expect(e.heroHeadline, isEmpty);
      expect(e.featuredDishes, isEmpty);
      expect(e.heroImage, isNull);
    });
    test('withValidationError clears heroHeadline', () {
      expect(HomeConfigFixtures.withValidationError().heroHeadline, isEmpty);
    });
  });

  group('KioskConfigFixtures', () {
    final variants = <String, KioskConfig Function()>{
      'showcase': KioskConfigFixtures.showcase,
      'empty': KioskConfigFixtures.empty,
      'allFieldsPopulated': KioskConfigFixtures.allFieldsPopulated,
      'withValidationError': KioskConfigFixtures.withValidationError,
    };
    for (final entry in variants.entries) {
      test('${entry.key} round-trips', () {
        final original = entry.value();
        expect(KioskConfigMapper.fromMap(original.toMap()).toMap(), original.toMap());
      });
    }
    test('empty has minimal required fields', () {
      final e = KioskConfigFixtures.empty();
      expect(e.bannerHeadline, isEmpty);
      expect(e.gridProducts, isEmpty);
      expect(e.bannerImage, isNull);
    });
    test('withValidationError clears bannerHeadline', () {
      expect(KioskConfigFixtures.withValidationError().bannerHeadline, isEmpty);
    });
  });

  group('MenuConfigFixtures', () {
    final variants = <String, MenuConfig Function()>{
      'showcase': MenuConfigFixtures.showcase,
      'empty': MenuConfigFixtures.empty,
      'allFieldsPopulated': MenuConfigFixtures.allFieldsPopulated,
      'withValidationError': MenuConfigFixtures.withValidationError,
    };
    for (final entry in variants.entries) {
      test('${entry.key} round-trips', () {
        final original = entry.value();
        expect(MenuConfigMapper.fromMap(original.toMap()).toMap(), original.toMap());
      });
    }
    test('empty has minimal required fields', () {
      final e = MenuConfigFixtures.empty();
      expect(e.categories, isEmpty);
      expect(e.items, isEmpty);
      expect(e.location, isNull);
    });
    test('withValidationError clears categories (minSelected: 1)', () {
      expect(MenuConfigFixtures.withValidationError().categories, isEmpty);
    });
  });

  group('RewardsConfigFixtures', () {
    final variants = <String, RewardsConfig Function()>{
      'showcase': RewardsConfigFixtures.showcase,
      'empty': RewardsConfigFixtures.empty,
      'allFieldsPopulated': RewardsConfigFixtures.allFieldsPopulated,
      'withValidationError': RewardsConfigFixtures.withValidationError,
    };
    for (final entry in variants.entries) {
      test('${entry.key} round-trips', () {
        final original = entry.value();
        expect(RewardsConfigMapper.fromMap(original.toMap()).toMap(), original.toMap());
      });
    }
    test('empty has minimal required fields', () {
      final e = RewardsConfigFixtures.empty();
      expect(e.programName, isEmpty);
      expect(e.tiers, isEmpty);
      expect(e.fineprint, isNull);
    });
    test('allFieldsPopulated sets fineprint', () {
      expect(RewardsConfigFixtures.allFieldsPopulated().fineprint, isNotNull);
    });
    test('withValidationError clears programName', () {
      expect(RewardsConfigFixtures.withValidationError().programName, isEmpty);
    });
  });

  group('BrandThemeFixtures', () {
    final variants = <String, BrandTheme Function()>{
      'showcase': BrandThemeFixtures.showcase,
      'empty': BrandThemeFixtures.empty,
      'allFieldsPopulated': BrandThemeFixtures.allFieldsPopulated,
      'withValidationError': BrandThemeFixtures.withValidationError,
    };
    for (final entry in variants.entries) {
      test('${entry.key} round-trips', () {
        final original = entry.value();
        expect(BrandThemeMapper.fromMap(original.toMap()).toMap(), original.toMap());
      });
    }
    test('empty has minimal required fields', () {
      final e = BrandThemeFixtures.empty();
      expect(e.name, isEmpty);
      expect(e.logo, isNull);
      expect(e.brandGuidelinesPdf, isNull);
    });
    test('allFieldsPopulated sets logo + brandGuidelinesPdf', () {
      final p = BrandThemeFixtures.allFieldsPopulated();
      expect(p.logo, isNotNull);
      expect(p.brandGuidelinesPdf, isNotNull);
    });
    test('withValidationError clears name', () {
      expect(BrandThemeFixtures.withValidationError().name, isEmpty);
    });
  });
}
