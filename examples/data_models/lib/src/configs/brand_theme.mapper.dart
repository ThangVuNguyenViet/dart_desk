// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'brand_theme.dart';

class BrandThemeMapper extends SubClassMapperBase<BrandTheme> {
  BrandThemeMapper._();

  static BrandThemeMapper? _instance;
  static BrandThemeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BrandThemeMapper._());
      DeskContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([
        BrandThemeColorMapper(),
        ImageReferenceMapper(),
      ]);
    }
    return _instance!;
  }

  @override
  final String id = 'BrandTheme';

  static String _$name(BrandTheme v) => v.name;
  static const Field<BrandTheme, String> _f$name = Field('name', _$name);
  static Color _$primaryColor(BrandTheme v) => v.primaryColor;
  static const Field<BrandTheme, Color> _f$primaryColor = Field(
    'primaryColor',
    _$primaryColor,
  );
  static Color _$surfaceColor(BrandTheme v) => v.surfaceColor;
  static const Field<BrandTheme, Color> _f$surfaceColor = Field(
    'surfaceColor',
    _$surfaceColor,
  );
  static Color _$accentColor(BrandTheme v) => v.accentColor;
  static const Field<BrandTheme, Color> _f$accentColor = Field(
    'accentColor',
    _$accentColor,
  );
  static Color _$inkColor(BrandTheme v) => v.inkColor;
  static const Field<BrandTheme, Color> _f$inkColor = Field(
    'inkColor',
    _$inkColor,
  );
  static String _$headlineFont(BrandTheme v) => v.headlineFont;
  static const Field<BrandTheme, String> _f$headlineFont = Field(
    'headlineFont',
    _$headlineFont,
  );
  static String _$bodyFont(BrandTheme v) => v.bodyFont;
  static const Field<BrandTheme, String> _f$bodyFont = Field(
    'bodyFont',
    _$bodyFont,
  );
  static num _$cornerRadius(BrandTheme v) => v.cornerRadius;
  static const Field<BrandTheme, num> _f$cornerRadius = Field(
    'cornerRadius',
    _$cornerRadius,
  );
  static ImageReference? _$logo(BrandTheme v) => v.logo;
  static const Field<BrandTheme, ImageReference> _f$logo = Field(
    'logo',
    _$logo,
    opt: true,
  );
  static String? _$brandGuidelinesPdf(BrandTheme v) => v.brandGuidelinesPdf;
  static const Field<BrandTheme, String> _f$brandGuidelinesPdf = Field(
    'brandGuidelinesPdf',
    _$brandGuidelinesPdf,
    opt: true,
  );

  @override
  final MappableFields<BrandTheme> fields = const {
    #name: _f$name,
    #primaryColor: _f$primaryColor,
    #surfaceColor: _f$surfaceColor,
    #accentColor: _f$accentColor,
    #inkColor: _f$inkColor,
    #headlineFont: _f$headlineFont,
    #bodyFont: _f$bodyFont,
    #cornerRadius: _f$cornerRadius,
    #logo: _f$logo,
    #brandGuidelinesPdf: _f$brandGuidelinesPdf,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'brandTheme';
  @override
  late final ClassMapperBase superMapper =
      DeskContentMapper.ensureInitialized();

  static BrandTheme _instantiate(DecodingData data) {
    return BrandTheme(
      name: data.dec(_f$name),
      primaryColor: data.dec(_f$primaryColor),
      surfaceColor: data.dec(_f$surfaceColor),
      accentColor: data.dec(_f$accentColor),
      inkColor: data.dec(_f$inkColor),
      headlineFont: data.dec(_f$headlineFont),
      bodyFont: data.dec(_f$bodyFont),
      cornerRadius: data.dec(_f$cornerRadius),
      logo: data.dec(_f$logo),
      brandGuidelinesPdf: data.dec(_f$brandGuidelinesPdf),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static BrandTheme fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BrandTheme>(map);
  }

  static BrandTheme fromJson(String json) {
    return ensureInitialized().decodeJson<BrandTheme>(json);
  }
}

mixin BrandThemeMappable {
  String toJson() {
    return BrandThemeMapper.ensureInitialized().encodeJson<BrandTheme>(
      this as BrandTheme,
    );
  }

  Map<String, dynamic> toMap() {
    return BrandThemeMapper.ensureInitialized().encodeMap<BrandTheme>(
      this as BrandTheme,
    );
  }

  BrandThemeCopyWith<BrandTheme, BrandTheme, BrandTheme> get copyWith =>
      _BrandThemeCopyWithImpl<BrandTheme, BrandTheme>(
        this as BrandTheme,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return BrandThemeMapper.ensureInitialized().stringifyValue(
      this as BrandTheme,
    );
  }

  @override
  bool operator ==(Object other) {
    return BrandThemeMapper.ensureInitialized().equalsValue(
      this as BrandTheme,
      other,
    );
  }

  @override
  int get hashCode {
    return BrandThemeMapper.ensureInitialized().hashValue(this as BrandTheme);
  }
}

extension BrandThemeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BrandTheme, $Out> {
  BrandThemeCopyWith<$R, BrandTheme, $Out> get $asBrandTheme =>
      $base.as((v, t, t2) => _BrandThemeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BrandThemeCopyWith<$R, $In extends BrandTheme, $Out>
    implements DeskContentCopyWith<$R, $In, $Out> {
  @override
  $R call({
    String? name,
    Color? primaryColor,
    Color? surfaceColor,
    Color? accentColor,
    Color? inkColor,
    String? headlineFont,
    String? bodyFont,
    num? cornerRadius,
    ImageReference? logo,
    String? brandGuidelinesPdf,
  });
  BrandThemeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BrandThemeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BrandTheme, $Out>
    implements BrandThemeCopyWith<$R, BrandTheme, $Out> {
  _BrandThemeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BrandTheme> $mapper =
      BrandThemeMapper.ensureInitialized();
  @override
  $R call({
    String? name,
    Color? primaryColor,
    Color? surfaceColor,
    Color? accentColor,
    Color? inkColor,
    String? headlineFont,
    String? bodyFont,
    num? cornerRadius,
    Object? logo = $none,
    Object? brandGuidelinesPdf = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (primaryColor != null) #primaryColor: primaryColor,
      if (surfaceColor != null) #surfaceColor: surfaceColor,
      if (accentColor != null) #accentColor: accentColor,
      if (inkColor != null) #inkColor: inkColor,
      if (headlineFont != null) #headlineFont: headlineFont,
      if (bodyFont != null) #bodyFont: bodyFont,
      if (cornerRadius != null) #cornerRadius: cornerRadius,
      if (logo != $none) #logo: logo,
      if (brandGuidelinesPdf != $none) #brandGuidelinesPdf: brandGuidelinesPdf,
    }),
  );
  @override
  BrandTheme $make(CopyWithData data) => BrandTheme(
    name: data.get(#name, or: $value.name),
    primaryColor: data.get(#primaryColor, or: $value.primaryColor),
    surfaceColor: data.get(#surfaceColor, or: $value.surfaceColor),
    accentColor: data.get(#accentColor, or: $value.accentColor),
    inkColor: data.get(#inkColor, or: $value.inkColor),
    headlineFont: data.get(#headlineFont, or: $value.headlineFont),
    bodyFont: data.get(#bodyFont, or: $value.bodyFont),
    cornerRadius: data.get(#cornerRadius, or: $value.cornerRadius),
    logo: data.get(#logo, or: $value.logo),
    brandGuidelinesPdf: data.get(
      #brandGuidelinesPdf,
      or: $value.brandGuidelinesPdf,
    ),
  );

  @override
  BrandThemeCopyWith<$R2, BrandTheme, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BrandThemeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

