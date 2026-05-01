import '../configs/kiosk_config.dart';

class KioskConfigFixtures {
  /// The demo-quality fixture used by showcase apps and happy-path tests.
  static KioskConfig showcase() => KioskConfig.initialValue;

  /// Required fields at minimum, optionals null/empty.
  static KioskConfig empty() => const KioskConfig(
    bannerHeadline: '',
    bannerSubtitle: '',
    promoBadge: '',
    gridProducts: [],
    sidebarTableLabel: '',
    sidebarSampleOrder: [],
    footerNote: '',
  );

  /// Every field set, including optionals. Functionally equivalent to
  /// [showcase] — KioskConfig's only optional (`bannerImage`) is already
  /// populated by the default value. Kept for API uniformity.
  static KioskConfig allFieldsPopulated() => showcase();

  /// Showcase data with `bannerHeadline` cleared so non-blank validation fires.
  static KioskConfig withValidationError() => KioskConfig(
    bannerImage: showcase().bannerImage,
    bannerHeadline: '',
    bannerSubtitle: showcase().bannerSubtitle,
    promoBadge: showcase().promoBadge,
    gridProducts: showcase().gridProducts,
    sidebarTableLabel: showcase().sidebarTableLabel,
    sidebarSampleOrder: showcase().sidebarSampleOrder,
    footerNote: showcase().footerNote,
  );
}
