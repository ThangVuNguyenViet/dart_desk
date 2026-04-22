// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'home_config.dart';

class HomeConfigMapper extends SubClassMapperBase<HomeConfig> {
  HomeConfigMapper._();

  static HomeConfigMapper? _instance;
  static HomeConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HomeConfigMapper._());
      DeskContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([ImageReferenceMapper()]);
      CtaActionMapper.ensureInitialized();
      FeaturedDishMapper.ensureInitialized();
      StoreCalloutMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'HomeConfig';

  static ImageReference? _$heroImage(HomeConfig v) => v.heroImage;
  static const Field<HomeConfig, ImageReference> _f$heroImage = Field(
    'heroImage',
    _$heroImage,
    opt: true,
  );
  static String _$heroEyebrow(HomeConfig v) => v.heroEyebrow;
  static const Field<HomeConfig, String> _f$heroEyebrow = Field(
    'heroEyebrow',
    _$heroEyebrow,
  );
  static String _$heroHeadline(HomeConfig v) => v.heroHeadline;
  static const Field<HomeConfig, String> _f$heroHeadline = Field(
    'heroHeadline',
    _$heroHeadline,
  );
  static CtaAction _$primaryCta(HomeConfig v) => v.primaryCta;
  static const Field<HomeConfig, CtaAction> _f$primaryCta = Field(
    'primaryCta',
    _$primaryCta,
  );
  static CtaAction _$secondaryCta(HomeConfig v) => v.secondaryCta;
  static const Field<HomeConfig, CtaAction> _f$secondaryCta = Field(
    'secondaryCta',
    _$secondaryCta,
  );
  static String _$locationLabel(HomeConfig v) => v.locationLabel;
  static const Field<HomeConfig, String> _f$locationLabel = Field(
    'locationLabel',
    _$locationLabel,
  );
  static String _$welcomeGreeting(HomeConfig v) => v.welcomeGreeting;
  static const Field<HomeConfig, String> _f$welcomeGreeting = Field(
    'welcomeGreeting',
    _$welcomeGreeting,
  );
  static String _$featuredSectionTitle(HomeConfig v) => v.featuredSectionTitle;
  static const Field<HomeConfig, String> _f$featuredSectionTitle = Field(
    'featuredSectionTitle',
    _$featuredSectionTitle,
  );
  static List<FeaturedDish> _$featuredDishes(HomeConfig v) => v.featuredDishes;
  static const Field<HomeConfig, List<FeaturedDish>> _f$featuredDishes = Field(
    'featuredDishes',
    _$featuredDishes,
  );
  static StoreCallout _$storeCallout(HomeConfig v) => v.storeCallout;
  static const Field<HomeConfig, StoreCallout> _f$storeCallout = Field(
    'storeCallout',
    _$storeCallout,
  );

  @override
  final MappableFields<HomeConfig> fields = const {
    #heroImage: _f$heroImage,
    #heroEyebrow: _f$heroEyebrow,
    #heroHeadline: _f$heroHeadline,
    #primaryCta: _f$primaryCta,
    #secondaryCta: _f$secondaryCta,
    #locationLabel: _f$locationLabel,
    #welcomeGreeting: _f$welcomeGreeting,
    #featuredSectionTitle: _f$featuredSectionTitle,
    #featuredDishes: _f$featuredDishes,
    #storeCallout: _f$storeCallout,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'homeConfig';
  @override
  late final ClassMapperBase superMapper =
      DeskContentMapper.ensureInitialized();

  static HomeConfig _instantiate(DecodingData data) {
    return HomeConfig(
      heroImage: data.dec(_f$heroImage),
      heroEyebrow: data.dec(_f$heroEyebrow),
      heroHeadline: data.dec(_f$heroHeadline),
      primaryCta: data.dec(_f$primaryCta),
      secondaryCta: data.dec(_f$secondaryCta),
      locationLabel: data.dec(_f$locationLabel),
      welcomeGreeting: data.dec(_f$welcomeGreeting),
      featuredSectionTitle: data.dec(_f$featuredSectionTitle),
      featuredDishes: data.dec(_f$featuredDishes),
      storeCallout: data.dec(_f$storeCallout),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static HomeConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HomeConfig>(map);
  }

  static HomeConfig fromJson(String json) {
    return ensureInitialized().decodeJson<HomeConfig>(json);
  }
}

mixin HomeConfigMappable {
  String toJson() {
    return HomeConfigMapper.ensureInitialized().encodeJson<HomeConfig>(
      this as HomeConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return HomeConfigMapper.ensureInitialized().encodeMap<HomeConfig>(
      this as HomeConfig,
    );
  }

  HomeConfigCopyWith<HomeConfig, HomeConfig, HomeConfig> get copyWith =>
      _HomeConfigCopyWithImpl<HomeConfig, HomeConfig>(
        this as HomeConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HomeConfigMapper.ensureInitialized().stringifyValue(
      this as HomeConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return HomeConfigMapper.ensureInitialized().equalsValue(
      this as HomeConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return HomeConfigMapper.ensureInitialized().hashValue(this as HomeConfig);
  }
}

extension HomeConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HomeConfig, $Out> {
  HomeConfigCopyWith<$R, HomeConfig, $Out> get $asHomeConfig =>
      $base.as((v, t, t2) => _HomeConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HomeConfigCopyWith<$R, $In extends HomeConfig, $Out>
    implements DeskContentCopyWith<$R, $In, $Out> {
  CtaActionCopyWith<$R, CtaAction, CtaAction> get primaryCta;
  CtaActionCopyWith<$R, CtaAction, CtaAction> get secondaryCta;
  ListCopyWith<
    $R,
    FeaturedDish,
    FeaturedDishCopyWith<$R, FeaturedDish, FeaturedDish>
  >
  get featuredDishes;
  StoreCalloutCopyWith<$R, StoreCallout, StoreCallout> get storeCallout;
  @override
  $R call({
    ImageReference? heroImage,
    String? heroEyebrow,
    String? heroHeadline,
    CtaAction? primaryCta,
    CtaAction? secondaryCta,
    String? locationLabel,
    String? welcomeGreeting,
    String? featuredSectionTitle,
    List<FeaturedDish>? featuredDishes,
    StoreCallout? storeCallout,
  });
  HomeConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _HomeConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HomeConfig, $Out>
    implements HomeConfigCopyWith<$R, HomeConfig, $Out> {
  _HomeConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HomeConfig> $mapper =
      HomeConfigMapper.ensureInitialized();
  @override
  CtaActionCopyWith<$R, CtaAction, CtaAction> get primaryCta =>
      $value.primaryCta.copyWith.$chain((v) => call(primaryCta: v));
  @override
  CtaActionCopyWith<$R, CtaAction, CtaAction> get secondaryCta =>
      $value.secondaryCta.copyWith.$chain((v) => call(secondaryCta: v));
  @override
  ListCopyWith<
    $R,
    FeaturedDish,
    FeaturedDishCopyWith<$R, FeaturedDish, FeaturedDish>
  >
  get featuredDishes => ListCopyWith(
    $value.featuredDishes,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(featuredDishes: v),
  );
  @override
  StoreCalloutCopyWith<$R, StoreCallout, StoreCallout> get storeCallout =>
      $value.storeCallout.copyWith.$chain((v) => call(storeCallout: v));
  @override
  $R call({
    Object? heroImage = $none,
    String? heroEyebrow,
    String? heroHeadline,
    CtaAction? primaryCta,
    CtaAction? secondaryCta,
    String? locationLabel,
    String? welcomeGreeting,
    String? featuredSectionTitle,
    List<FeaturedDish>? featuredDishes,
    StoreCallout? storeCallout,
  }) => $apply(
    FieldCopyWithData({
      if (heroImage != $none) #heroImage: heroImage,
      if (heroEyebrow != null) #heroEyebrow: heroEyebrow,
      if (heroHeadline != null) #heroHeadline: heroHeadline,
      if (primaryCta != null) #primaryCta: primaryCta,
      if (secondaryCta != null) #secondaryCta: secondaryCta,
      if (locationLabel != null) #locationLabel: locationLabel,
      if (welcomeGreeting != null) #welcomeGreeting: welcomeGreeting,
      if (featuredSectionTitle != null)
        #featuredSectionTitle: featuredSectionTitle,
      if (featuredDishes != null) #featuredDishes: featuredDishes,
      if (storeCallout != null) #storeCallout: storeCallout,
    }),
  );
  @override
  HomeConfig $make(CopyWithData data) => HomeConfig(
    heroImage: data.get(#heroImage, or: $value.heroImage),
    heroEyebrow: data.get(#heroEyebrow, or: $value.heroEyebrow),
    heroHeadline: data.get(#heroHeadline, or: $value.heroHeadline),
    primaryCta: data.get(#primaryCta, or: $value.primaryCta),
    secondaryCta: data.get(#secondaryCta, or: $value.secondaryCta),
    locationLabel: data.get(#locationLabel, or: $value.locationLabel),
    welcomeGreeting: data.get(#welcomeGreeting, or: $value.welcomeGreeting),
    featuredSectionTitle: data.get(
      #featuredSectionTitle,
      or: $value.featuredSectionTitle,
    ),
    featuredDishes: data.get(#featuredDishes, or: $value.featuredDishes),
    storeCallout: data.get(#storeCallout, or: $value.storeCallout),
  );

  @override
  HomeConfigCopyWith<$R2, HomeConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _HomeConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

