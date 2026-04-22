// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'loyalty_tier.dart';

class LoyaltyTierMapper extends ClassMapperBase<LoyaltyTier> {
  LoyaltyTierMapper._();

  static LoyaltyTierMapper? _instance;
  static LoyaltyTierMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LoyaltyTierMapper._());
      MapperContainer.globals.useAll([BrandThemeColorMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'LoyaltyTier';

  static String _$name(LoyaltyTier v) => v.name;
  static const Field<LoyaltyTier, String> _f$name = Field('name', _$name);
  static num _$threshold(LoyaltyTier v) => v.threshold;
  static const Field<LoyaltyTier, num> _f$threshold = Field(
    'threshold',
    _$threshold,
  );
  static Color _$tierColor(LoyaltyTier v) => v.tierColor;
  static const Field<LoyaltyTier, Color> _f$tierColor = Field(
    'tierColor',
    _$tierColor,
  );
  static Object? _$perks(LoyaltyTier v) => v.perks;
  static const Field<LoyaltyTier, Object> _f$perks = Field(
    'perks',
    _$perks,
    opt: true,
  );

  @override
  final MappableFields<LoyaltyTier> fields = const {
    #name: _f$name,
    #threshold: _f$threshold,
    #tierColor: _f$tierColor,
    #perks: _f$perks,
  };

  static LoyaltyTier _instantiate(DecodingData data) {
    return LoyaltyTier(
      name: data.dec(_f$name),
      threshold: data.dec(_f$threshold),
      tierColor: data.dec(_f$tierColor),
      perks: data.dec(_f$perks),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LoyaltyTier fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LoyaltyTier>(map);
  }

  static LoyaltyTier fromJson(String json) {
    return ensureInitialized().decodeJson<LoyaltyTier>(json);
  }
}

mixin LoyaltyTierMappable {
  String toJson() {
    return LoyaltyTierMapper.ensureInitialized().encodeJson<LoyaltyTier>(
      this as LoyaltyTier,
    );
  }

  Map<String, dynamic> toMap() {
    return LoyaltyTierMapper.ensureInitialized().encodeMap<LoyaltyTier>(
      this as LoyaltyTier,
    );
  }

  LoyaltyTierCopyWith<LoyaltyTier, LoyaltyTier, LoyaltyTier> get copyWith =>
      _LoyaltyTierCopyWithImpl<LoyaltyTier, LoyaltyTier>(
        this as LoyaltyTier,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LoyaltyTierMapper.ensureInitialized().stringifyValue(
      this as LoyaltyTier,
    );
  }

  @override
  bool operator ==(Object other) {
    return LoyaltyTierMapper.ensureInitialized().equalsValue(
      this as LoyaltyTier,
      other,
    );
  }

  @override
  int get hashCode {
    return LoyaltyTierMapper.ensureInitialized().hashValue(this as LoyaltyTier);
  }
}

extension LoyaltyTierValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LoyaltyTier, $Out> {
  LoyaltyTierCopyWith<$R, LoyaltyTier, $Out> get $asLoyaltyTier =>
      $base.as((v, t, t2) => _LoyaltyTierCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LoyaltyTierCopyWith<$R, $In extends LoyaltyTier, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? name, num? threshold, Color? tierColor, Object? perks});
  LoyaltyTierCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LoyaltyTierCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LoyaltyTier, $Out>
    implements LoyaltyTierCopyWith<$R, LoyaltyTier, $Out> {
  _LoyaltyTierCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LoyaltyTier> $mapper =
      LoyaltyTierMapper.ensureInitialized();
  @override
  $R call({
    String? name,
    num? threshold,
    Color? tierColor,
    Object? perks = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (threshold != null) #threshold: threshold,
      if (tierColor != null) #tierColor: tierColor,
      if (perks != $none) #perks: perks,
    }),
  );
  @override
  LoyaltyTier $make(CopyWithData data) => LoyaltyTier(
    name: data.get(#name, or: $value.name),
    threshold: data.get(#threshold, or: $value.threshold),
    tierColor: data.get(#tierColor, or: $value.tierColor),
    perks: data.get(#perks, or: $value.perks),
  );

  @override
  LoyaltyTierCopyWith<$R2, LoyaltyTier, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LoyaltyTierCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

