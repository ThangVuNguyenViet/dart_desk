import '../configs/home_config.dart';
import '../shared/cta_action.dart';
import '../shared/store_callout.dart';

class HomeConfigFixtures {
  /// The demo-quality fixture used by showcase apps and happy-path tests.
  static HomeConfig showcase() => HomeConfig.initialValue;

  /// Required fields at minimum, optionals null/empty.
  static HomeConfig empty() => const HomeConfig(
    heroEyebrow: '',
    heroHeadline: '',
    primaryCta: CtaAction(label: '', style: 'solid'),
    secondaryCta: CtaAction(label: '', style: 'ghost'),
    locationLabel: '',
    welcomeGreeting: '',
    featuredSectionTitle: '',
    featuredDishes: [],
    storeCallout: StoreCallout(
      venueName: '',
      hoursLabel: '',
      distanceLabel: '',
      directionsLabel: '',
    ),
  );

  /// Every field set, including optionals. Functionally equivalent to
  /// [showcase] — HomeConfig has only one optional field (`heroImage`) and the
  /// showcase value already populates it. Kept for API uniformity.
  static HomeConfig allFieldsPopulated() => showcase();

  /// Showcase data with `heroHeadline` cleared so non-blank validation fires.
  static HomeConfig withValidationError() => HomeConfig(
    heroImage: showcase().heroImage,
    heroEyebrow: showcase().heroEyebrow,
    heroHeadline: '',
    primaryCta: showcase().primaryCta,
    secondaryCta: showcase().secondaryCta,
    locationLabel: showcase().locationLabel,
    welcomeGreeting: showcase().welcomeGreeting,
    featuredSectionTitle: showcase().featuredSectionTitle,
    featuredDishes: showcase().featuredDishes,
    storeCallout: showcase().storeCallout,
  );
}
