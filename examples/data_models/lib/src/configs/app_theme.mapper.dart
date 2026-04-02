// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'app_theme.dart';

class AppThemeMapper extends ClassMapperBase<AppTheme> {
  AppThemeMapper._();

  static AppThemeMapper? _instance;
  static AppThemeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppThemeMapper._());
      MapperContainer.globals.useAll([ColorMapper(), ImageUrlMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'AppTheme';

  static Color _$primaryColor(AppTheme v) => v.primaryColor;
  static const Field<AppTheme, Color> _f$primaryColor = Field(
    'primaryColor',
    _$primaryColor,
  );
  static Color _$secondaryColor(AppTheme v) => v.secondaryColor;
  static const Field<AppTheme, Color> _f$secondaryColor = Field(
    'secondaryColor',
    _$secondaryColor,
  );
  static Color _$backgroundColor(AppTheme v) => v.backgroundColor;
  static const Field<AppTheme, Color> _f$backgroundColor = Field(
    'backgroundColor',
    _$backgroundColor,
  );
  static Color _$textColor(AppTheme v) => v.textColor;
  static const Field<AppTheme, Color> _f$textColor = Field(
    'textColor',
    _$textColor,
  );
  static ImageUrl? _$logoLight(AppTheme v) => v.logoLight;
  static const Field<AppTheme, ImageUrl> _f$logoLight = Field(
    'logoLight',
    _$logoLight,
    opt: true,
  );
  static ImageUrl? _$logoDark(AppTheme v) => v.logoDark;
  static const Field<AppTheme, ImageUrl> _f$logoDark = Field(
    'logoDark',
    _$logoDark,
    opt: true,
  );
  static ImageUrl? _$appIcon(AppTheme v) => v.appIcon;
  static const Field<AppTheme, ImageUrl> _f$appIcon = Field(
    'appIcon',
    _$appIcon,
    opt: true,
  );
  static String _$themeMode(AppTheme v) => v.themeMode;
  static const Field<AppTheme, String> _f$themeMode = Field(
    'themeMode',
    _$themeMode,
  );
  static num _$cornerRadius(AppTheme v) => v.cornerRadius;
  static const Field<AppTheme, num> _f$cornerRadius = Field(
    'cornerRadius',
    _$cornerRadius,
  );
  static bool _$useMaterial3(AppTheme v) => v.useMaterial3;
  static const Field<AppTheme, bool> _f$useMaterial3 = Field(
    'useMaterial3',
    _$useMaterial3,
  );

  @override
  final MappableFields<AppTheme> fields = const {
    #primaryColor: _f$primaryColor,
    #secondaryColor: _f$secondaryColor,
    #backgroundColor: _f$backgroundColor,
    #textColor: _f$textColor,
    #logoLight: _f$logoLight,
    #logoDark: _f$logoDark,
    #appIcon: _f$appIcon,
    #themeMode: _f$themeMode,
    #cornerRadius: _f$cornerRadius,
    #useMaterial3: _f$useMaterial3,
  };

  static AppTheme _instantiate(DecodingData data) {
    return AppTheme(
      primaryColor: data.dec(_f$primaryColor),
      secondaryColor: data.dec(_f$secondaryColor),
      backgroundColor: data.dec(_f$backgroundColor),
      textColor: data.dec(_f$textColor),
      logoLight: data.dec(_f$logoLight),
      logoDark: data.dec(_f$logoDark),
      appIcon: data.dec(_f$appIcon),
      themeMode: data.dec(_f$themeMode),
      cornerRadius: data.dec(_f$cornerRadius),
      useMaterial3: data.dec(_f$useMaterial3),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AppTheme fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AppTheme>(map);
  }

  static AppTheme fromJson(String json) {
    return ensureInitialized().decodeJson<AppTheme>(json);
  }
}

mixin AppThemeMappable {
  String toJson() {
    return AppThemeMapper.ensureInitialized().encodeJson<AppTheme>(
      this as AppTheme,
    );
  }

  Map<String, dynamic> toMap() {
    return AppThemeMapper.ensureInitialized().encodeMap<AppTheme>(
      this as AppTheme,
    );
  }

  AppThemeCopyWith<AppTheme, AppTheme, AppTheme> get copyWith =>
      _AppThemeCopyWithImpl<AppTheme, AppTheme>(
        this as AppTheme,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AppThemeMapper.ensureInitialized().stringifyValue(this as AppTheme);
  }

  @override
  bool operator ==(Object other) {
    return AppThemeMapper.ensureInitialized().equalsValue(
      this as AppTheme,
      other,
    );
  }

  @override
  int get hashCode {
    return AppThemeMapper.ensureInitialized().hashValue(this as AppTheme);
  }
}

extension AppThemeValueCopy<$R, $Out> on ObjectCopyWith<$R, AppTheme, $Out> {
  AppThemeCopyWith<$R, AppTheme, $Out> get $asAppTheme =>
      $base.as((v, t, t2) => _AppThemeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AppThemeCopyWith<$R, $In extends AppTheme, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? textColor,
    ImageUrl? logoLight,
    ImageUrl? logoDark,
    ImageUrl? appIcon,
    String? themeMode,
    num? cornerRadius,
    bool? useMaterial3,
  });
  AppThemeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AppThemeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AppTheme, $Out>
    implements AppThemeCopyWith<$R, AppTheme, $Out> {
  _AppThemeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AppTheme> $mapper =
      AppThemeMapper.ensureInitialized();
  @override
  $R call({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? textColor,
    Object? logoLight = $none,
    Object? logoDark = $none,
    Object? appIcon = $none,
    String? themeMode,
    num? cornerRadius,
    bool? useMaterial3,
  }) => $apply(
    FieldCopyWithData({
      if (primaryColor != null) #primaryColor: primaryColor,
      if (secondaryColor != null) #secondaryColor: secondaryColor,
      if (backgroundColor != null) #backgroundColor: backgroundColor,
      if (textColor != null) #textColor: textColor,
      if (logoLight != $none) #logoLight: logoLight,
      if (logoDark != $none) #logoDark: logoDark,
      if (appIcon != $none) #appIcon: appIcon,
      if (themeMode != null) #themeMode: themeMode,
      if (cornerRadius != null) #cornerRadius: cornerRadius,
      if (useMaterial3 != null) #useMaterial3: useMaterial3,
    }),
  );
  @override
  AppTheme $make(CopyWithData data) => AppTheme(
    primaryColor: data.get(#primaryColor, or: $value.primaryColor),
    secondaryColor: data.get(#secondaryColor, or: $value.secondaryColor),
    backgroundColor: data.get(#backgroundColor, or: $value.backgroundColor),
    textColor: data.get(#textColor, or: $value.textColor),
    logoLight: data.get(#logoLight, or: $value.logoLight),
    logoDark: data.get(#logoDark, or: $value.logoDark),
    appIcon: data.get(#appIcon, or: $value.appIcon),
    themeMode: data.get(#themeMode, or: $value.themeMode),
    cornerRadius: data.get(#cornerRadius, or: $value.cornerRadius),
    useMaterial3: data.get(#useMaterial3, or: $value.useMaterial3),
  );

  @override
  AppThemeCopyWith<$R2, AppTheme, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AppThemeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

