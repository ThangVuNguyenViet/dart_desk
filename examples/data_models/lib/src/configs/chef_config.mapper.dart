// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'chef_config.dart';

class ChefConfigMapper extends SubClassMapperBase<ChefConfig> {
  ChefConfigMapper._();

  static ChefConfigMapper? _instance;
  static ChefConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChefConfigMapper._());
      DeskContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([ImageReferenceMapper()]);
      ChefProfileMapper.ensureInitialized();
      CuratedDishMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ChefConfig';

  static String _$headline(ChefConfig v) => v.headline;
  static const Field<ChefConfig, String> _f$headline = Field(
    'headline',
    _$headline,
  );
  static Object? _$intro(ChefConfig v) => v.intro;
  static const Field<ChefConfig, Object> _f$intro = Field(
    'intro',
    _$intro,
    opt: true,
  );
  static ChefProfile _$chef(ChefConfig v) => v.chef;
  static const Field<ChefConfig, ChefProfile> _f$chef = Field('chef', _$chef);
  static String _$pullQuote(ChefConfig v) => v.pullQuote;
  static const Field<ChefConfig, String> _f$pullQuote = Field(
    'pullQuote',
    _$pullQuote,
  );
  static List<CuratedDish> _$curatedDishes(ChefConfig v) => v.curatedDishes;
  static const Field<ChefConfig, List<CuratedDish>> _f$curatedDishes = Field(
    'curatedDishes',
    _$curatedDishes,
  );
  static String _$refreshCadence(ChefConfig v) => v.refreshCadence;
  static const Field<ChefConfig, String> _f$refreshCadence = Field(
    'refreshCadence',
    _$refreshCadence,
  );
  static DateTime _$publishFrom(ChefConfig v) => v.publishFrom;
  static const Field<ChefConfig, DateTime> _f$publishFrom = Field(
    'publishFrom',
    _$publishFrom,
  );

  @override
  final MappableFields<ChefConfig> fields = const {
    #headline: _f$headline,
    #intro: _f$intro,
    #chef: _f$chef,
    #pullQuote: _f$pullQuote,
    #curatedDishes: _f$curatedDishes,
    #refreshCadence: _f$refreshCadence,
    #publishFrom: _f$publishFrom,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'chefConfig';
  @override
  late final ClassMapperBase superMapper =
      DeskContentMapper.ensureInitialized();

  static ChefConfig _instantiate(DecodingData data) {
    return ChefConfig(
      headline: data.dec(_f$headline),
      intro: data.dec(_f$intro),
      chef: data.dec(_f$chef),
      pullQuote: data.dec(_f$pullQuote),
      curatedDishes: data.dec(_f$curatedDishes),
      refreshCadence: data.dec(_f$refreshCadence),
      publishFrom: data.dec(_f$publishFrom),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ChefConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChefConfig>(map);
  }

  static ChefConfig fromJson(String json) {
    return ensureInitialized().decodeJson<ChefConfig>(json);
  }
}

mixin ChefConfigMappable {
  String toJson() {
    return ChefConfigMapper.ensureInitialized().encodeJson<ChefConfig>(
      this as ChefConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return ChefConfigMapper.ensureInitialized().encodeMap<ChefConfig>(
      this as ChefConfig,
    );
  }

  ChefConfigCopyWith<ChefConfig, ChefConfig, ChefConfig> get copyWith =>
      _ChefConfigCopyWithImpl<ChefConfig, ChefConfig>(
        this as ChefConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ChefConfigMapper.ensureInitialized().stringifyValue(
      this as ChefConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return ChefConfigMapper.ensureInitialized().equalsValue(
      this as ChefConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return ChefConfigMapper.ensureInitialized().hashValue(this as ChefConfig);
  }
}

extension ChefConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ChefConfig, $Out> {
  ChefConfigCopyWith<$R, ChefConfig, $Out> get $asChefConfig =>
      $base.as((v, t, t2) => _ChefConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ChefConfigCopyWith<$R, $In extends ChefConfig, $Out>
    implements DeskContentCopyWith<$R, $In, $Out> {
  ChefProfileCopyWith<$R, ChefProfile, ChefProfile> get chef;
  ListCopyWith<
    $R,
    CuratedDish,
    CuratedDishCopyWith<$R, CuratedDish, CuratedDish>
  >
  get curatedDishes;
  @override
  $R call({
    String? headline,
    Object? intro,
    ChefProfile? chef,
    String? pullQuote,
    List<CuratedDish>? curatedDishes,
    String? refreshCadence,
    DateTime? publishFrom,
  });
  ChefConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ChefConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ChefConfig, $Out>
    implements ChefConfigCopyWith<$R, ChefConfig, $Out> {
  _ChefConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ChefConfig> $mapper =
      ChefConfigMapper.ensureInitialized();
  @override
  ChefProfileCopyWith<$R, ChefProfile, ChefProfile> get chef =>
      $value.chef.copyWith.$chain((v) => call(chef: v));
  @override
  ListCopyWith<
    $R,
    CuratedDish,
    CuratedDishCopyWith<$R, CuratedDish, CuratedDish>
  >
  get curatedDishes => ListCopyWith(
    $value.curatedDishes,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(curatedDishes: v),
  );
  @override
  $R call({
    String? headline,
    Object? intro = $none,
    ChefProfile? chef,
    String? pullQuote,
    List<CuratedDish>? curatedDishes,
    String? refreshCadence,
    DateTime? publishFrom,
  }) => $apply(
    FieldCopyWithData({
      if (headline != null) #headline: headline,
      if (intro != $none) #intro: intro,
      if (chef != null) #chef: chef,
      if (pullQuote != null) #pullQuote: pullQuote,
      if (curatedDishes != null) #curatedDishes: curatedDishes,
      if (refreshCadence != null) #refreshCadence: refreshCadence,
      if (publishFrom != null) #publishFrom: publishFrom,
    }),
  );
  @override
  ChefConfig $make(CopyWithData data) => ChefConfig(
    headline: data.get(#headline, or: $value.headline),
    intro: data.get(#intro, or: $value.intro),
    chef: data.get(#chef, or: $value.chef),
    pullQuote: data.get(#pullQuote, or: $value.pullQuote),
    curatedDishes: data.get(#curatedDishes, or: $value.curatedDishes),
    refreshCadence: data.get(#refreshCadence, or: $value.refreshCadence),
    publishFrom: data.get(#publishFrom, or: $value.publishFrom),
  );

  @override
  ChefConfigCopyWith<$R2, ChefConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ChefConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

