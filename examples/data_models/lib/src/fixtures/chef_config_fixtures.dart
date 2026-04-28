import 'package:dart_desk/dart_desk.dart';

import '../configs/chef_config.dart';
import '../primitives/aura_assets.dart';
import '../shared/chef_profile.dart';
import '../shared/curated_dish.dart';

class ChefConfigFixtures {
  /// The demo-quality fixture used by showcase apps and happy-path tests.
  static ChefConfig showcase() => ChefConfig.defaultValue;

  /// Required fields at minimum, optionals null/empty.
  ///
  /// Used by editor screen goldens to pin the empty-defaults rendering.
  static ChefConfig empty() => ChefConfig(
    headline: '',
    chef: const ChefProfile(name: '', role: '', bio: ''),
    pullQuote: '',
    curatedDishes: const [],
    refreshCadence: '',
    publishFrom: DateTime(2026, 1, 1),
  );

  /// Every field set, including optionals (intro block, chef portrait/cv).
  ///
  /// Used by editor screen goldens to pin the maximal rendering.
  static ChefConfig allFieldsPopulated() => ChefConfig(
    headline: showcase().headline,
    intro: const [
      {
        'type': 'paragraph',
        'children': [
          {'text': 'A short intro block above the curated dishes.'},
        ],
      },
    ],
    chef: const ChefProfile(
      name: 'Marco Vespucci',
      role: 'Head Chef · Aura Tribeca',
      portrait: ImageReference(externalUrl: AuraAssets.chefAlt),
      bio: 'Twelve years between Milan and Brooklyn. Cooks seasonally, apologizes rarely.',
      cv: 'https://example.invalid/marco-vespucci-cv.pdf',
    ),
    pullQuote: showcase().pullQuote,
    curatedDishes: showcase().curatedDishes,
    refreshCadence: showcase().refreshCadence,
    publishFrom: showcase().publishFrom,
  );

  /// Showcase data with the `headline` cleared so a non-blank validator
  /// fires. Used by editor screen goldens to pin the error-state chrome.
  static ChefConfig withValidationError() => ChefConfig(
    headline: '',
    intro: showcase().intro,
    chef: showcase().chef,
    pullQuote: showcase().pullQuote,
    curatedDishes: showcase().curatedDishes,
    refreshCadence: showcase().refreshCadence,
    publishFrom: showcase().publishFrom,
  );
}
