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
      CmsContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([BrandThemeColorMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'BrandTheme';

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
  static Color _$textColor(BrandTheme v) => v.textColor;
  static const Field<BrandTheme, Color> _f$textColor = Field(
    'textColor',
    _$textColor,
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
  static String _$themeMode(BrandTheme v) => v.themeMode;
  static const Field<BrandTheme, String> _f$themeMode = Field(
    'themeMode',
    _$themeMode,
  );

  @override
  final MappableFields<BrandTheme> fields = const {
    #primaryColor: _f$primaryColor,
    #surfaceColor: _f$surfaceColor,
    #textColor: _f$textColor,
    #headlineFont: _f$headlineFont,
    #bodyFont: _f$bodyFont,
    #cornerRadius: _f$cornerRadius,
    #themeMode: _f$themeMode,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'brandTheme';
  @override
  late final ClassMapperBase superMapper = CmsContentMapper.ensureInitialized();

  static BrandTheme _instantiate(DecodingData data) {
    return BrandTheme(
      primaryColor: data.dec(_f$primaryColor),
      surfaceColor: data.dec(_f$surfaceColor),
      textColor: data.dec(_f$textColor),
      headlineFont: data.dec(_f$headlineFont),
      bodyFont: data.dec(_f$bodyFont),
      cornerRadius: data.dec(_f$cornerRadius),
      themeMode: data.dec(_f$themeMode),
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
    implements CmsContentCopyWith<$R, $In, $Out> {
  @override
  $R call({
    Color? primaryColor,
    Color? surfaceColor,
    Color? textColor,
    String? headlineFont,
    String? bodyFont,
    num? cornerRadius,
    String? themeMode,
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
    Color? primaryColor,
    Color? surfaceColor,
    Color? textColor,
    String? headlineFont,
    String? bodyFont,
    num? cornerRadius,
    String? themeMode,
  }) => $apply(
    FieldCopyWithData({
      if (primaryColor != null) #primaryColor: primaryColor,
      if (surfaceColor != null) #surfaceColor: surfaceColor,
      if (textColor != null) #textColor: textColor,
      if (headlineFont != null) #headlineFont: headlineFont,
      if (bodyFont != null) #bodyFont: bodyFont,
      if (cornerRadius != null) #cornerRadius: cornerRadius,
      if (themeMode != null) #themeMode: themeMode,
    }),
  );
  @override
  BrandTheme $make(CopyWithData data) => BrandTheme(
    primaryColor: data.get(#primaryColor, or: $value.primaryColor),
    surfaceColor: data.get(#surfaceColor, or: $value.surfaceColor),
    textColor: data.get(#textColor, or: $value.textColor),
    headlineFont: data.get(#headlineFont, or: $value.headlineFont),
    bodyFont: data.get(#bodyFont, or: $value.bodyFont),
    cornerRadius: data.get(#cornerRadius, or: $value.cornerRadius),
    themeMode: data.get(#themeMode, or: $value.themeMode),
  );

  @override
  BrandThemeCopyWith<$R2, BrandTheme, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BrandThemeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

