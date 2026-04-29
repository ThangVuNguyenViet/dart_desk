import '../configs/menu_config.dart';

class MenuConfigFixtures {
  /// The demo-quality fixture used by showcase apps and happy-path tests.
  static MenuConfig showcase() => MenuConfig.defaultValue;

  /// Required fields at minimum, optionals null/empty.
  static MenuConfig empty() => const MenuConfig(
    categories: [],
    filterTags: [],
    items: [],
    storeHours: [],
  );

  /// Every field set, including optionals. Functionally equivalent to
  /// [showcase] — MenuConfig's only optional (`location`) is already populated
  /// by the default value. Kept for API uniformity.
  static MenuConfig allFieldsPopulated() => showcase();

  /// Showcase data with `categories` cleared so the `minSelected: 1`
  /// constraint fires.
  static MenuConfig withValidationError() => MenuConfig(
    categories: const [],
    filterTags: showcase().filterTags,
    items: showcase().items,
    location: showcase().location,
    storeHours: showcase().storeHours,
  );
}
