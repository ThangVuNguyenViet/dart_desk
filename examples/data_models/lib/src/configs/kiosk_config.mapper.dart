// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'kiosk_config.dart';

class KioskConfigMapper extends SubClassMapperBase<KioskConfig> {
  KioskConfigMapper._();

  static KioskConfigMapper? _instance;
  static KioskConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = KioskConfigMapper._());
      CmsContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([
        KioskColorMapper(),
        ImageReferenceMapper(),
      ]);
    }
    return _instance!;
  }

  @override
  final String id = 'KioskConfig';

  static String _$restaurantName(KioskConfig v) => v.restaurantName;
  static const Field<KioskConfig, String> _f$restaurantName = Field(
    'restaurantName',
    _$restaurantName,
  );
  static String _$bannerTitle(KioskConfig v) => v.bannerTitle;
  static const Field<KioskConfig, String> _f$bannerTitle = Field(
    'bannerTitle',
    _$bannerTitle,
  );
  static String _$bannerSubtitle(KioskConfig v) => v.bannerSubtitle;
  static const Field<KioskConfig, String> _f$bannerSubtitle = Field(
    'bannerSubtitle',
    _$bannerSubtitle,
  );
  static ImageReference? _$bannerImage(KioskConfig v) => v.bannerImage;
  static const Field<KioskConfig, ImageReference> _f$bannerImage = Field(
    'bannerImage',
    _$bannerImage,
    opt: true,
  );
  static List<String> _$products(KioskConfig v) => v.products;
  static const Field<KioskConfig, List<String>> _f$products = Field(
    'products',
    _$products,
  );

  @override
  final MappableFields<KioskConfig> fields = const {
    #restaurantName: _f$restaurantName,
    #bannerTitle: _f$bannerTitle,
    #bannerSubtitle: _f$bannerSubtitle,
    #bannerImage: _f$bannerImage,
    #products: _f$products,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'kioskConfig';
  @override
  late final ClassMapperBase superMapper = CmsContentMapper.ensureInitialized();

  static KioskConfig _instantiate(DecodingData data) {
    return KioskConfig(
      restaurantName: data.dec(_f$restaurantName),
      bannerTitle: data.dec(_f$bannerTitle),
      bannerSubtitle: data.dec(_f$bannerSubtitle),
      bannerImage: data.dec(_f$bannerImage),
      products: data.dec(_f$products),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static KioskConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<KioskConfig>(map);
  }

  static KioskConfig fromJson(String json) {
    return ensureInitialized().decodeJson<KioskConfig>(json);
  }
}

mixin KioskConfigMappable {
  String toJson() {
    return KioskConfigMapper.ensureInitialized().encodeJson<KioskConfig>(
      this as KioskConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return KioskConfigMapper.ensureInitialized().encodeMap<KioskConfig>(
      this as KioskConfig,
    );
  }

  KioskConfigCopyWith<KioskConfig, KioskConfig, KioskConfig> get copyWith =>
      _KioskConfigCopyWithImpl<KioskConfig, KioskConfig>(
        this as KioskConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return KioskConfigMapper.ensureInitialized().stringifyValue(
      this as KioskConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return KioskConfigMapper.ensureInitialized().equalsValue(
      this as KioskConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return KioskConfigMapper.ensureInitialized().hashValue(this as KioskConfig);
  }
}

extension KioskConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, KioskConfig, $Out> {
  KioskConfigCopyWith<$R, KioskConfig, $Out> get $asKioskConfig =>
      $base.as((v, t, t2) => _KioskConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class KioskConfigCopyWith<$R, $In extends KioskConfig, $Out>
    implements CmsContentCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get products;
  @override
  $R call({
    String? restaurantName,
    String? bannerTitle,
    String? bannerSubtitle,
    ImageReference? bannerImage,
    List<String>? products,
  });
  KioskConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _KioskConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, KioskConfig, $Out>
    implements KioskConfigCopyWith<$R, KioskConfig, $Out> {
  _KioskConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<KioskConfig> $mapper =
      KioskConfigMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get products =>
      ListCopyWith(
        $value.products,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(products: v),
      );
  @override
  $R call({
    String? restaurantName,
    String? bannerTitle,
    String? bannerSubtitle,
    Object? bannerImage = $none,
    List<String>? products,
  }) => $apply(
    FieldCopyWithData({
      if (restaurantName != null) #restaurantName: restaurantName,
      if (bannerTitle != null) #bannerTitle: bannerTitle,
      if (bannerSubtitle != null) #bannerSubtitle: bannerSubtitle,
      if (bannerImage != $none) #bannerImage: bannerImage,
      if (products != null) #products: products,
    }),
  );
  @override
  KioskConfig $make(CopyWithData data) => KioskConfig(
    restaurantName: data.get(#restaurantName, or: $value.restaurantName),
    bannerTitle: data.get(#bannerTitle, or: $value.bannerTitle),
    bannerSubtitle: data.get(#bannerSubtitle, or: $value.bannerSubtitle),
    bannerImage: data.get(#bannerImage, or: $value.bannerImage),
    products: data.get(#products, or: $value.products),
  );

  @override
  KioskConfigCopyWith<$R2, KioskConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _KioskConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

