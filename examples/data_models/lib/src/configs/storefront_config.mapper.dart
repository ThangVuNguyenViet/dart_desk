// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'storefront_config.dart';

class StorefrontConfigMapper extends ClassMapperBase<StorefrontConfig> {
  StorefrontConfigMapper._();

  static StorefrontConfigMapper? _instance;
  static StorefrontConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StorefrontConfigMapper._());
      MapperContainer.globals.useAll([
        StorefrontColorMapper(),
        ImageReferenceMapper(),
      ]);
    }
    return _instance!;
  }

  @override
  final String id = 'StorefrontConfig';

  static String _$restaurantName(StorefrontConfig v) => v.restaurantName;
  static const Field<StorefrontConfig, String> _f$restaurantName = Field(
    'restaurantName',
    _$restaurantName,
  );
  static String _$tagline(StorefrontConfig v) => v.tagline;
  static const Field<StorefrontConfig, String> _f$tagline = Field(
    'tagline',
    _$tagline,
  );
  static ImageReference? _$heroImage(StorefrontConfig v) => v.heroImage;
  static const Field<StorefrontConfig, ImageReference> _f$heroImage = Field(
    'heroImage',
    _$heroImage,
    opt: true,
  );
  static ImageReference? _$logo(StorefrontConfig v) => v.logo;
  static const Field<StorefrontConfig, ImageReference> _f$logo = Field(
    'logo',
    _$logo,
    opt: true,
  );
  static Color _$primaryColor(StorefrontConfig v) => v.primaryColor;
  static const Field<StorefrontConfig, Color> _f$primaryColor = Field(
    'primaryColor',
    _$primaryColor,
  );
  static Color _$accentColor(StorefrontConfig v) => v.accentColor;
  static const Field<StorefrontConfig, Color> _f$accentColor = Field(
    'accentColor',
    _$accentColor,
  );
  static String _$welcomeMessage(StorefrontConfig v) => v.welcomeMessage;
  static const Field<StorefrontConfig, String> _f$welcomeMessage = Field(
    'welcomeMessage',
    _$welcomeMessage,
  );
  static String _$operatingHours(StorefrontConfig v) => v.operatingHours;
  static const Field<StorefrontConfig, String> _f$operatingHours = Field(
    'operatingHours',
    _$operatingHours,
  );
  static String? _$orderUrl(StorefrontConfig v) => v.orderUrl;
  static const Field<StorefrontConfig, String> _f$orderUrl = Field(
    'orderUrl',
    _$orderUrl,
    opt: true,
  );
  static bool _$showHours(StorefrontConfig v) => v.showHours;
  static const Field<StorefrontConfig, bool> _f$showHours = Field(
    'showHours',
    _$showHours,
  );
  static String _$ctaLabel(StorefrontConfig v) => v.ctaLabel;
  static const Field<StorefrontConfig, String> _f$ctaLabel = Field(
    'ctaLabel',
    _$ctaLabel,
  );

  @override
  final MappableFields<StorefrontConfig> fields = const {
    #restaurantName: _f$restaurantName,
    #tagline: _f$tagline,
    #heroImage: _f$heroImage,
    #logo: _f$logo,
    #primaryColor: _f$primaryColor,
    #accentColor: _f$accentColor,
    #welcomeMessage: _f$welcomeMessage,
    #operatingHours: _f$operatingHours,
    #orderUrl: _f$orderUrl,
    #showHours: _f$showHours,
    #ctaLabel: _f$ctaLabel,
  };

  static StorefrontConfig _instantiate(DecodingData data) {
    return StorefrontConfig(
      restaurantName: data.dec(_f$restaurantName),
      tagline: data.dec(_f$tagline),
      heroImage: data.dec(_f$heroImage),
      logo: data.dec(_f$logo),
      primaryColor: data.dec(_f$primaryColor),
      accentColor: data.dec(_f$accentColor),
      welcomeMessage: data.dec(_f$welcomeMessage),
      operatingHours: data.dec(_f$operatingHours),
      orderUrl: data.dec(_f$orderUrl),
      showHours: data.dec(_f$showHours),
      ctaLabel: data.dec(_f$ctaLabel),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static StorefrontConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StorefrontConfig>(map);
  }

  static StorefrontConfig fromJson(String json) {
    return ensureInitialized().decodeJson<StorefrontConfig>(json);
  }
}

mixin StorefrontConfigMappable {
  String toJson() {
    return StorefrontConfigMapper.ensureInitialized()
        .encodeJson<StorefrontConfig>(this as StorefrontConfig);
  }

  Map<String, dynamic> toMap() {
    return StorefrontConfigMapper.ensureInitialized()
        .encodeMap<StorefrontConfig>(this as StorefrontConfig);
  }

  StorefrontConfigCopyWith<StorefrontConfig, StorefrontConfig, StorefrontConfig>
  get copyWith =>
      _StorefrontConfigCopyWithImpl<StorefrontConfig, StorefrontConfig>(
        this as StorefrontConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return StorefrontConfigMapper.ensureInitialized().stringifyValue(
      this as StorefrontConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return StorefrontConfigMapper.ensureInitialized().equalsValue(
      this as StorefrontConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return StorefrontConfigMapper.ensureInitialized().hashValue(
      this as StorefrontConfig,
    );
  }
}

extension StorefrontConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StorefrontConfig, $Out> {
  StorefrontConfigCopyWith<$R, StorefrontConfig, $Out>
  get $asStorefrontConfig =>
      $base.as((v, t, t2) => _StorefrontConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class StorefrontConfigCopyWith<$R, $In extends StorefrontConfig, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? restaurantName,
    String? tagline,
    ImageReference? heroImage,
    ImageReference? logo,
    Color? primaryColor,
    Color? accentColor,
    String? welcomeMessage,
    String? operatingHours,
    String? orderUrl,
    bool? showHours,
    String? ctaLabel,
  });
  StorefrontConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _StorefrontConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StorefrontConfig, $Out>
    implements StorefrontConfigCopyWith<$R, StorefrontConfig, $Out> {
  _StorefrontConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StorefrontConfig> $mapper =
      StorefrontConfigMapper.ensureInitialized();
  @override
  $R call({
    String? restaurantName,
    String? tagline,
    Object? heroImage = $none,
    Object? logo = $none,
    Color? primaryColor,
    Color? accentColor,
    String? welcomeMessage,
    String? operatingHours,
    Object? orderUrl = $none,
    bool? showHours,
    String? ctaLabel,
  }) => $apply(
    FieldCopyWithData({
      if (restaurantName != null) #restaurantName: restaurantName,
      if (tagline != null) #tagline: tagline,
      if (heroImage != $none) #heroImage: heroImage,
      if (logo != $none) #logo: logo,
      if (primaryColor != null) #primaryColor: primaryColor,
      if (accentColor != null) #accentColor: accentColor,
      if (welcomeMessage != null) #welcomeMessage: welcomeMessage,
      if (operatingHours != null) #operatingHours: operatingHours,
      if (orderUrl != $none) #orderUrl: orderUrl,
      if (showHours != null) #showHours: showHours,
      if (ctaLabel != null) #ctaLabel: ctaLabel,
    }),
  );
  @override
  StorefrontConfig $make(CopyWithData data) => StorefrontConfig(
    restaurantName: data.get(#restaurantName, or: $value.restaurantName),
    tagline: data.get(#tagline, or: $value.tagline),
    heroImage: data.get(#heroImage, or: $value.heroImage),
    logo: data.get(#logo, or: $value.logo),
    primaryColor: data.get(#primaryColor, or: $value.primaryColor),
    accentColor: data.get(#accentColor, or: $value.accentColor),
    welcomeMessage: data.get(#welcomeMessage, or: $value.welcomeMessage),
    operatingHours: data.get(#operatingHours, or: $value.operatingHours),
    orderUrl: data.get(#orderUrl, or: $value.orderUrl),
    showHours: data.get(#showHours, or: $value.showHours),
    ctaLabel: data.get(#ctaLabel, or: $value.ctaLabel),
  );

  @override
  StorefrontConfigCopyWith<$R2, StorefrontConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _StorefrontConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

