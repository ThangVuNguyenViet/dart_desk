// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'reward_config.dart';

class RewardConfigMapper extends SubClassMapperBase<RewardConfig> {
  RewardConfigMapper._();

  static RewardConfigMapper? _instance;
  static RewardConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RewardConfigMapper._());
      CmsContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([RewardColorMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'RewardConfig';

  static String _$brandName(RewardConfig v) => v.brandName;
  static const Field<RewardConfig, String> _f$brandName = Field(
    'brandName',
    _$brandName,
  );
  static num _$pointsBalance(RewardConfig v) => v.pointsBalance;
  static const Field<RewardConfig, num> _f$pointsBalance = Field(
    'pointsBalance',
    _$pointsBalance,
  );
  static num _$nextRewardThreshold(RewardConfig v) => v.nextRewardThreshold;
  static const Field<RewardConfig, num> _f$nextRewardThreshold = Field(
    'nextRewardThreshold',
    _$nextRewardThreshold,
  );
  static String _$rewardLabel(RewardConfig v) => v.rewardLabel;
  static const Field<RewardConfig, String> _f$rewardLabel = Field(
    'rewardLabel',
    _$rewardLabel,
  );
  static List<String> _$coupons(RewardConfig v) => v.coupons;
  static const Field<RewardConfig, List<String>> _f$coupons = Field(
    'coupons',
    _$coupons,
  );

  @override
  final MappableFields<RewardConfig> fields = const {
    #brandName: _f$brandName,
    #pointsBalance: _f$pointsBalance,
    #nextRewardThreshold: _f$nextRewardThreshold,
    #rewardLabel: _f$rewardLabel,
    #coupons: _f$coupons,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'rewardConfig';
  @override
  late final ClassMapperBase superMapper = CmsContentMapper.ensureInitialized();

  static RewardConfig _instantiate(DecodingData data) {
    return RewardConfig(
      brandName: data.dec(_f$brandName),
      pointsBalance: data.dec(_f$pointsBalance),
      nextRewardThreshold: data.dec(_f$nextRewardThreshold),
      rewardLabel: data.dec(_f$rewardLabel),
      coupons: data.dec(_f$coupons),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RewardConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RewardConfig>(map);
  }

  static RewardConfig fromJson(String json) {
    return ensureInitialized().decodeJson<RewardConfig>(json);
  }
}

mixin RewardConfigMappable {
  String toJson() {
    return RewardConfigMapper.ensureInitialized().encodeJson<RewardConfig>(
      this as RewardConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return RewardConfigMapper.ensureInitialized().encodeMap<RewardConfig>(
      this as RewardConfig,
    );
  }

  RewardConfigCopyWith<RewardConfig, RewardConfig, RewardConfig> get copyWith =>
      _RewardConfigCopyWithImpl<RewardConfig, RewardConfig>(
        this as RewardConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return RewardConfigMapper.ensureInitialized().stringifyValue(
      this as RewardConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return RewardConfigMapper.ensureInitialized().equalsValue(
      this as RewardConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return RewardConfigMapper.ensureInitialized().hashValue(
      this as RewardConfig,
    );
  }
}

extension RewardConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RewardConfig, $Out> {
  RewardConfigCopyWith<$R, RewardConfig, $Out> get $asRewardConfig =>
      $base.as((v, t, t2) => _RewardConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RewardConfigCopyWith<$R, $In extends RewardConfig, $Out>
    implements CmsContentCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get coupons;
  @override
  $R call({
    String? brandName,
    num? pointsBalance,
    num? nextRewardThreshold,
    String? rewardLabel,
    List<String>? coupons,
  });
  RewardConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RewardConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RewardConfig, $Out>
    implements RewardConfigCopyWith<$R, RewardConfig, $Out> {
  _RewardConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RewardConfig> $mapper =
      RewardConfigMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get coupons =>
      ListCopyWith(
        $value.coupons,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(coupons: v),
      );
  @override
  $R call({
    String? brandName,
    num? pointsBalance,
    num? nextRewardThreshold,
    String? rewardLabel,
    List<String>? coupons,
  }) => $apply(
    FieldCopyWithData({
      if (brandName != null) #brandName: brandName,
      if (pointsBalance != null) #pointsBalance: pointsBalance,
      if (nextRewardThreshold != null)
        #nextRewardThreshold: nextRewardThreshold,
      if (rewardLabel != null) #rewardLabel: rewardLabel,
      if (coupons != null) #coupons: coupons,
    }),
  );
  @override
  RewardConfig $make(CopyWithData data) => RewardConfig(
    brandName: data.get(#brandName, or: $value.brandName),
    pointsBalance: data.get(#pointsBalance, or: $value.pointsBalance),
    nextRewardThreshold: data.get(
      #nextRewardThreshold,
      or: $value.nextRewardThreshold,
    ),
    rewardLabel: data.get(#rewardLabel, or: $value.rewardLabel),
    coupons: data.get(#coupons, or: $value.coupons),
  );

  @override
  RewardConfigCopyWith<$R2, RewardConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RewardConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

