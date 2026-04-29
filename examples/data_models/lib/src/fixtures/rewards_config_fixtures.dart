import '../configs/rewards_config.dart';

class RewardsConfigFixtures {
  /// The demo-quality fixture used by showcase apps and happy-path tests.
  static RewardsConfig showcase() => RewardsConfig.defaultValue;

  /// Required fields at minimum, optionals null/empty.
  static RewardsConfig empty() => const RewardsConfig(
    programName: '',
    tiers: [],
    currentUserPoints: 0,
    coupons: [],
    termsUrl: '',
  );

  /// Every field set, including the optional `fineprint` block that the
  /// showcase value leaves null.
  static RewardsConfig allFieldsPopulated() => RewardsConfig(
    programName: showcase().programName,
    tiers: showcase().tiers,
    currentUserPoints: showcase().currentUserPoints,
    coupons: showcase().coupons,
    enabled: showcase().enabled,
    termsUrl: showcase().termsUrl,
    fineprint: const [
      {
        'type': 'paragraph',
        'children': [
          {'text': 'Standard terms apply. See terms URL for full details.'},
        ],
      },
    ],
  );

  /// Showcase data with `programName` cleared so non-blank validation fires.
  static RewardsConfig withValidationError() => RewardsConfig(
    programName: '',
    tiers: showcase().tiers,
    currentUserPoints: showcase().currentUserPoints,
    coupons: showcase().coupons,
    enabled: showcase().enabled,
    termsUrl: showcase().termsUrl,
    fineprint: showcase().fineprint,
  );
}
