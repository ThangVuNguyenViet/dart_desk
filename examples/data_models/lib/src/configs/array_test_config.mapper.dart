// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'array_test_config.dart';

class ArrayTestConfigMapper extends ClassMapperBase<ArrayTestConfig> {
  ArrayTestConfigMapper._();

  static ArrayTestConfigMapper? _instance;
  static ArrayTestConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ArrayTestConfigMapper._());
      HeroConfigMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ArrayTestConfig';

  static List<String> _$tags(ArrayTestConfig v) => v.tags;
  static const Field<ArrayTestConfig, List<String>> _f$tags = Field(
    'tags',
    _$tags,
  );
  static List<HeroConfig> _$heroes(ArrayTestConfig v) => v.heroes;
  static const Field<ArrayTestConfig, List<HeroConfig>> _f$heroes = Field(
    'heroes',
    _$heroes,
  );
  static List<String> _$gallery(ArrayTestConfig v) => v.gallery;
  static const Field<ArrayTestConfig, List<String>> _f$gallery = Field(
    'gallery',
    _$gallery,
  );

  @override
  final MappableFields<ArrayTestConfig> fields = const {
    #tags: _f$tags,
    #heroes: _f$heroes,
    #gallery: _f$gallery,
  };

  static ArrayTestConfig _instantiate(DecodingData data) {
    return ArrayTestConfig(
      tags: data.dec(_f$tags),
      heroes: data.dec(_f$heroes),
      gallery: data.dec(_f$gallery),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ArrayTestConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ArrayTestConfig>(map);
  }

  static ArrayTestConfig fromJson(String json) {
    return ensureInitialized().decodeJson<ArrayTestConfig>(json);
  }
}

mixin ArrayTestConfigMappable {
  String toJson() {
    return ArrayTestConfigMapper.ensureInitialized()
        .encodeJson<ArrayTestConfig>(this as ArrayTestConfig);
  }

  Map<String, dynamic> toMap() {
    return ArrayTestConfigMapper.ensureInitialized().encodeMap<ArrayTestConfig>(
      this as ArrayTestConfig,
    );
  }

  ArrayTestConfigCopyWith<ArrayTestConfig, ArrayTestConfig, ArrayTestConfig>
  get copyWith =>
      _ArrayTestConfigCopyWithImpl<ArrayTestConfig, ArrayTestConfig>(
        this as ArrayTestConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ArrayTestConfigMapper.ensureInitialized().stringifyValue(
      this as ArrayTestConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return ArrayTestConfigMapper.ensureInitialized().equalsValue(
      this as ArrayTestConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return ArrayTestConfigMapper.ensureInitialized().hashValue(
      this as ArrayTestConfig,
    );
  }
}

extension ArrayTestConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ArrayTestConfig, $Out> {
  ArrayTestConfigCopyWith<$R, ArrayTestConfig, $Out> get $asArrayTestConfig =>
      $base.as((v, t, t2) => _ArrayTestConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ArrayTestConfigCopyWith<$R, $In extends ArrayTestConfig, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags;
  ListCopyWith<$R, HeroConfig, HeroConfigCopyWith<$R, HeroConfig, HeroConfig>>
  get heroes;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get gallery;
  $R call({
    List<String>? tags,
    List<HeroConfig>? heroes,
    List<String>? gallery,
  });
  ArrayTestConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ArrayTestConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ArrayTestConfig, $Out>
    implements ArrayTestConfigCopyWith<$R, ArrayTestConfig, $Out> {
  _ArrayTestConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ArrayTestConfig> $mapper =
      ArrayTestConfigMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags =>
      ListCopyWith(
        $value.tags,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(tags: v),
      );
  @override
  ListCopyWith<$R, HeroConfig, HeroConfigCopyWith<$R, HeroConfig, HeroConfig>>
  get heroes => ListCopyWith(
    $value.heroes,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(heroes: v),
  );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get gallery =>
      ListCopyWith(
        $value.gallery,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(gallery: v),
      );
  @override
  $R call({
    List<String>? tags,
    List<HeroConfig>? heroes,
    List<String>? gallery,
  }) => $apply(
    FieldCopyWithData({
      if (tags != null) #tags: tags,
      if (heroes != null) #heroes: heroes,
      if (gallery != null) #gallery: gallery,
    }),
  );
  @override
  ArrayTestConfig $make(CopyWithData data) => ArrayTestConfig(
    tags: data.get(#tags, or: $value.tags),
    heroes: data.get(#heroes, or: $value.heroes),
    gallery: data.get(#gallery, or: $value.gallery),
  );

  @override
  ArrayTestConfigCopyWith<$R2, ArrayTestConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ArrayTestConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

