// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'rewards_config.dart';

class RewardsConfigMapper extends SubClassMapperBase<RewardsConfig> {
  RewardsConfigMapper._();

  static RewardsConfigMapper? _instance;
  static RewardsConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RewardsConfigMapper._());
      CmsContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([
        ImageReferenceMapper(),
        BrandThemeColorMapper(),
      ]);
      LoyaltyTierMapper.ensureInitialized();
      CouponMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'RewardsConfig';

  static String _$programName(RewardsConfig v) => v.programName;
  static const Field<RewardsConfig, String> _f$programName = Field(
    'programName',
    _$programName,
  );
  static List<LoyaltyTier> _$tiers(RewardsConfig v) => v.tiers;
  static const Field<RewardsConfig, List<LoyaltyTier>> _f$tiers = Field(
    'tiers',
    _$tiers,
  );
  static num _$currentUserPoints(RewardsConfig v) => v.currentUserPoints;
  static const Field<RewardsConfig, num> _f$currentUserPoints = Field(
    'currentUserPoints',
    _$currentUserPoints,
  );
  static List<Coupon> _$coupons(RewardsConfig v) => v.coupons;
  static const Field<RewardsConfig, List<Coupon>> _f$coupons = Field(
    'coupons',
    _$coupons,
  );
  static String _$termsUrl(RewardsConfig v) => v.termsUrl;
  static const Field<RewardsConfig, String> _f$termsUrl = Field(
    'termsUrl',
    _$termsUrl,
  );
  static Object? _$fineprint(RewardsConfig v) => v.fineprint;
  static const Field<RewardsConfig, Object> _f$fineprint = Field(
    'fineprint',
    _$fineprint,
    opt: true,
  );

  @override
  final MappableFields<RewardsConfig> fields = const {
    #programName: _f$programName,
    #tiers: _f$tiers,
    #currentUserPoints: _f$currentUserPoints,
    #coupons: _f$coupons,
    #termsUrl: _f$termsUrl,
    #fineprint: _f$fineprint,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'rewardsConfig';
  @override
  late final ClassMapperBase superMapper = CmsContentMapper.ensureInitialized();

  static RewardsConfig _instantiate(DecodingData data) {
    return RewardsConfig(
      programName: data.dec(_f$programName),
      tiers: data.dec(_f$tiers),
      currentUserPoints: data.dec(_f$currentUserPoints),
      coupons: data.dec(_f$coupons),
      termsUrl: data.dec(_f$termsUrl),
      fineprint: data.dec(_f$fineprint),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RewardsConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RewardsConfig>(map);
  }

  static RewardsConfig fromJson(String json) {
    return ensureInitialized().decodeJson<RewardsConfig>(json);
  }
}

mixin RewardsConfigMappable {
  String toJson() {
    return RewardsConfigMapper.ensureInitialized().encodeJson<RewardsConfig>(
      this as RewardsConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return RewardsConfigMapper.ensureInitialized().encodeMap<RewardsConfig>(
      this as RewardsConfig,
    );
  }

  RewardsConfigCopyWith<RewardsConfig, RewardsConfig, RewardsConfig>
  get copyWith => _RewardsConfigCopyWithImpl<RewardsConfig, RewardsConfig>(
    this as RewardsConfig,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return RewardsConfigMapper.ensureInitialized().stringifyValue(
      this as RewardsConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return RewardsConfigMapper.ensureInitialized().equalsValue(
      this as RewardsConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return RewardsConfigMapper.ensureInitialized().hashValue(
      this as RewardsConfig,
    );
  }
}

extension RewardsConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RewardsConfig, $Out> {
  RewardsConfigCopyWith<$R, RewardsConfig, $Out> get $asRewardsConfig =>
      $base.as((v, t, t2) => _RewardsConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RewardsConfigCopyWith<$R, $In extends RewardsConfig, $Out>
    implements CmsContentCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    LoyaltyTier,
    LoyaltyTierCopyWith<$R, LoyaltyTier, LoyaltyTier>
  >
  get tiers;
  ListCopyWith<$R, Coupon, CouponCopyWith<$R, Coupon, Coupon>> get coupons;
  @override
  $R call({
    String? programName,
    List<LoyaltyTier>? tiers,
    num? currentUserPoints,
    List<Coupon>? coupons,
    String? termsUrl,
    Object? fineprint,
  });
  RewardsConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RewardsConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RewardsConfig, $Out>
    implements RewardsConfigCopyWith<$R, RewardsConfig, $Out> {
  _RewardsConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RewardsConfig> $mapper =
      RewardsConfigMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    LoyaltyTier,
    LoyaltyTierCopyWith<$R, LoyaltyTier, LoyaltyTier>
  >
  get tiers => ListCopyWith(
    $value.tiers,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(tiers: v),
  );
  @override
  ListCopyWith<$R, Coupon, CouponCopyWith<$R, Coupon, Coupon>> get coupons =>
      ListCopyWith(
        $value.coupons,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(coupons: v),
      );
  @override
  $R call({
    String? programName,
    List<LoyaltyTier>? tiers,
    num? currentUserPoints,
    List<Coupon>? coupons,
    String? termsUrl,
    Object? fineprint = $none,
  }) => $apply(
    FieldCopyWithData({
      if (programName != null) #programName: programName,
      if (tiers != null) #tiers: tiers,
      if (currentUserPoints != null) #currentUserPoints: currentUserPoints,
      if (coupons != null) #coupons: coupons,
      if (termsUrl != null) #termsUrl: termsUrl,
      if (fineprint != $none) #fineprint: fineprint,
    }),
  );
  @override
  RewardsConfig $make(CopyWithData data) => RewardsConfig(
    programName: data.get(#programName, or: $value.programName),
    tiers: data.get(#tiers, or: $value.tiers),
    currentUserPoints: data.get(
      #currentUserPoints,
      or: $value.currentUserPoints,
    ),
    coupons: data.get(#coupons, or: $value.coupons),
    termsUrl: data.get(#termsUrl, or: $value.termsUrl),
    fineprint: data.get(#fineprint, or: $value.fineprint),
  );

  @override
  RewardsConfigCopyWith<$R2, RewardsConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RewardsConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

