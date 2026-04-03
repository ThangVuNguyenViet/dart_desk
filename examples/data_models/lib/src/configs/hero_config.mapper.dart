// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'hero_config.dart';

class HeroConfigMapper extends SubClassMapperBase<HeroConfig> {
  HeroConfigMapper._();

  static HeroConfigMapper? _instance;
  static HeroConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HeroConfigMapper._());
      CmsContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([
        HeroColorMapper(),
        ImageReferenceMapper(),
      ]);
    }
    return _instance!;
  }

  @override
  final String id = 'HeroConfig';

  static String _$heroTitle(HeroConfig v) => v.heroTitle;
  static const Field<HeroConfig, String> _f$heroTitle = Field(
    'heroTitle',
    _$heroTitle,
  );
  static String _$heroSubtitle(HeroConfig v) => v.heroSubtitle;
  static const Field<HeroConfig, String> _f$heroSubtitle = Field(
    'heroSubtitle',
    _$heroSubtitle,
  );
  static ImageReference? _$heroImage(HeroConfig v) => v.heroImage;
  static const Field<HeroConfig, ImageReference> _f$heroImage = Field(
    'heroImage',
    _$heroImage,
    opt: true,
  );
  static String _$ctaLabel(HeroConfig v) => v.ctaLabel;
  static const Field<HeroConfig, String> _f$ctaLabel = Field(
    'ctaLabel',
    _$ctaLabel,
  );
  static List<String> _$products(HeroConfig v) => v.products;
  static const Field<HeroConfig, List<String>> _f$products = Field(
    'products',
    _$products,
  );

  @override
  final MappableFields<HeroConfig> fields = const {
    #heroTitle: _f$heroTitle,
    #heroSubtitle: _f$heroSubtitle,
    #heroImage: _f$heroImage,
    #ctaLabel: _f$ctaLabel,
    #products: _f$products,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'heroConfig';
  @override
  late final ClassMapperBase superMapper = CmsContentMapper.ensureInitialized();

  static HeroConfig _instantiate(DecodingData data) {
    return HeroConfig(
      heroTitle: data.dec(_f$heroTitle),
      heroSubtitle: data.dec(_f$heroSubtitle),
      heroImage: data.dec(_f$heroImage),
      ctaLabel: data.dec(_f$ctaLabel),
      products: data.dec(_f$products),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static HeroConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HeroConfig>(map);
  }

  static HeroConfig fromJson(String json) {
    return ensureInitialized().decodeJson<HeroConfig>(json);
  }
}

mixin HeroConfigMappable {
  String toJson() {
    return HeroConfigMapper.ensureInitialized().encodeJson<HeroConfig>(
      this as HeroConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return HeroConfigMapper.ensureInitialized().encodeMap<HeroConfig>(
      this as HeroConfig,
    );
  }

  HeroConfigCopyWith<HeroConfig, HeroConfig, HeroConfig> get copyWith =>
      _HeroConfigCopyWithImpl<HeroConfig, HeroConfig>(
        this as HeroConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HeroConfigMapper.ensureInitialized().stringifyValue(
      this as HeroConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return HeroConfigMapper.ensureInitialized().equalsValue(
      this as HeroConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return HeroConfigMapper.ensureInitialized().hashValue(this as HeroConfig);
  }
}

extension HeroConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HeroConfig, $Out> {
  HeroConfigCopyWith<$R, HeroConfig, $Out> get $asHeroConfig =>
      $base.as((v, t, t2) => _HeroConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HeroConfigCopyWith<$R, $In extends HeroConfig, $Out>
    implements CmsContentCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get products;
  @override
  $R call({
    String? heroTitle,
    String? heroSubtitle,
    ImageReference? heroImage,
    String? ctaLabel,
    List<String>? products,
  });
  HeroConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _HeroConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HeroConfig, $Out>
    implements HeroConfigCopyWith<$R, HeroConfig, $Out> {
  _HeroConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HeroConfig> $mapper =
      HeroConfigMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get products =>
      ListCopyWith(
        $value.products,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(products: v),
      );
  @override
  $R call({
    String? heroTitle,
    String? heroSubtitle,
    Object? heroImage = $none,
    String? ctaLabel,
    List<String>? products,
  }) => $apply(
    FieldCopyWithData({
      if (heroTitle != null) #heroTitle: heroTitle,
      if (heroSubtitle != null) #heroSubtitle: heroSubtitle,
      if (heroImage != $none) #heroImage: heroImage,
      if (ctaLabel != null) #ctaLabel: ctaLabel,
      if (products != null) #products: products,
    }),
  );
  @override
  HeroConfig $make(CopyWithData data) => HeroConfig(
    heroTitle: data.get(#heroTitle, or: $value.heroTitle),
    heroSubtitle: data.get(#heroSubtitle, or: $value.heroSubtitle),
    heroImage: data.get(#heroImage, or: $value.heroImage),
    ctaLabel: data.get(#ctaLabel, or: $value.ctaLabel),
    products: data.get(#products, or: $value.products),
  );

  @override
  HeroConfigCopyWith<$R2, HeroConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _HeroConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

