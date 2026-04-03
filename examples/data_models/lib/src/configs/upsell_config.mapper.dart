// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'upsell_config.dart';

class UpsellConfigMapper extends SubClassMapperBase<UpsellConfig> {
  UpsellConfigMapper._();

  static UpsellConfigMapper? _instance;
  static UpsellConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UpsellConfigMapper._());
      CmsContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([UpsellColorMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'UpsellConfig';

  static String _$sectionTitle(UpsellConfig v) => v.sectionTitle;
  static const Field<UpsellConfig, String> _f$sectionTitle = Field(
    'sectionTitle',
    _$sectionTitle,
  );
  static String _$sectionSubtitle(UpsellConfig v) => v.sectionSubtitle;
  static const Field<UpsellConfig, String> _f$sectionSubtitle = Field(
    'sectionSubtitle',
    _$sectionSubtitle,
  );
  static String _$quoteText(UpsellConfig v) => v.quoteText;
  static const Field<UpsellConfig, String> _f$quoteText = Field(
    'quoteText',
    _$quoteText,
  );
  static String _$chefName(UpsellConfig v) => v.chefName;
  static const Field<UpsellConfig, String> _f$chefName = Field(
    'chefName',
    _$chefName,
  );
  static List<String> _$products(UpsellConfig v) => v.products;
  static const Field<UpsellConfig, List<String>> _f$products = Field(
    'products',
    _$products,
  );

  @override
  final MappableFields<UpsellConfig> fields = const {
    #sectionTitle: _f$sectionTitle,
    #sectionSubtitle: _f$sectionSubtitle,
    #quoteText: _f$quoteText,
    #chefName: _f$chefName,
    #products: _f$products,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'upsellConfig';
  @override
  late final ClassMapperBase superMapper = CmsContentMapper.ensureInitialized();

  static UpsellConfig _instantiate(DecodingData data) {
    return UpsellConfig(
      sectionTitle: data.dec(_f$sectionTitle),
      sectionSubtitle: data.dec(_f$sectionSubtitle),
      quoteText: data.dec(_f$quoteText),
      chefName: data.dec(_f$chefName),
      products: data.dec(_f$products),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UpsellConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UpsellConfig>(map);
  }

  static UpsellConfig fromJson(String json) {
    return ensureInitialized().decodeJson<UpsellConfig>(json);
  }
}

mixin UpsellConfigMappable {
  String toJson() {
    return UpsellConfigMapper.ensureInitialized().encodeJson<UpsellConfig>(
      this as UpsellConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return UpsellConfigMapper.ensureInitialized().encodeMap<UpsellConfig>(
      this as UpsellConfig,
    );
  }

  UpsellConfigCopyWith<UpsellConfig, UpsellConfig, UpsellConfig> get copyWith =>
      _UpsellConfigCopyWithImpl<UpsellConfig, UpsellConfig>(
        this as UpsellConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UpsellConfigMapper.ensureInitialized().stringifyValue(
      this as UpsellConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return UpsellConfigMapper.ensureInitialized().equalsValue(
      this as UpsellConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return UpsellConfigMapper.ensureInitialized().hashValue(
      this as UpsellConfig,
    );
  }
}

extension UpsellConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UpsellConfig, $Out> {
  UpsellConfigCopyWith<$R, UpsellConfig, $Out> get $asUpsellConfig =>
      $base.as((v, t, t2) => _UpsellConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UpsellConfigCopyWith<$R, $In extends UpsellConfig, $Out>
    implements CmsContentCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get products;
  @override
  $R call({
    String? sectionTitle,
    String? sectionSubtitle,
    String? quoteText,
    String? chefName,
    List<String>? products,
  });
  UpsellConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UpsellConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UpsellConfig, $Out>
    implements UpsellConfigCopyWith<$R, UpsellConfig, $Out> {
  _UpsellConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UpsellConfig> $mapper =
      UpsellConfigMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get products =>
      ListCopyWith(
        $value.products,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(products: v),
      );
  @override
  $R call({
    String? sectionTitle,
    String? sectionSubtitle,
    String? quoteText,
    String? chefName,
    List<String>? products,
  }) => $apply(
    FieldCopyWithData({
      if (sectionTitle != null) #sectionTitle: sectionTitle,
      if (sectionSubtitle != null) #sectionSubtitle: sectionSubtitle,
      if (quoteText != null) #quoteText: quoteText,
      if (chefName != null) #chefName: chefName,
      if (products != null) #products: products,
    }),
  );
  @override
  UpsellConfig $make(CopyWithData data) => UpsellConfig(
    sectionTitle: data.get(#sectionTitle, or: $value.sectionTitle),
    sectionSubtitle: data.get(#sectionSubtitle, or: $value.sectionSubtitle),
    quoteText: data.get(#quoteText, or: $value.quoteText),
    chefName: data.get(#chefName, or: $value.chefName),
    products: data.get(#products, or: $value.products),
  );

  @override
  UpsellConfigCopyWith<$R2, UpsellConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UpsellConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

