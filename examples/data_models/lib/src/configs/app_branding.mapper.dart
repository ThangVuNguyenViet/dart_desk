// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'app_branding.dart';

class AppBrandingMapper extends ClassMapperBase<AppBranding> {
  AppBrandingMapper._();

  static AppBrandingMapper? _instance;
  static AppBrandingMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppBrandingMapper._());
      MapperContainer.globals.useAll([ColorMapper(), ImageUrlMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'AppBranding';

  static Color _$primaryColor(AppBranding v) => v.primaryColor;
  static const Field<AppBranding, Color> _f$primaryColor = Field(
    'primaryColor',
    _$primaryColor,
  );
  static Color _$secondaryColor(AppBranding v) => v.secondaryColor;
  static const Field<AppBranding, Color> _f$secondaryColor = Field(
    'secondaryColor',
    _$secondaryColor,
  );
  static Color _$surfaceColor(AppBranding v) => v.surfaceColor;
  static const Field<AppBranding, Color> _f$surfaceColor = Field(
    'surfaceColor',
    _$surfaceColor,
  );
  static Color _$errorColor(AppBranding v) => v.errorColor;
  static const Field<AppBranding, Color> _f$errorColor = Field(
    'errorColor',
    _$errorColor,
  );
  static ImageReference? _$logoLight(AppBranding v) => v.logoLight;
  static const Field<AppBranding, ImageReference> _f$logoLight = Field(
    'logoLight',
    _$logoLight,
    opt: true,
  );
  static ImageReference? _$logoDark(AppBranding v) => v.logoDark;
  static const Field<AppBranding, ImageReference> _f$logoDark = Field(
    'logoDark',
    _$logoDark,
    opt: true,
  );
  static ImageReference? _$appIcon(AppBranding v) => v.appIcon;
  static const Field<AppBranding, ImageReference> _f$appIcon = Field(
    'appIcon',
    _$appIcon,
    opt: true,
  );
  static String _$themeMode(AppBranding v) => v.themeMode;
  static const Field<AppBranding, String> _f$themeMode = Field(
    'themeMode',
    _$themeMode,
  );
  static bool _$allowThemeToggle(AppBranding v) => v.allowThemeToggle;
  static const Field<AppBranding, bool> _f$allowThemeToggle = Field(
    'allowThemeToggle',
    _$allowThemeToggle,
  );
  static bool _$useMaterial3(AppBranding v) => v.useMaterial3;
  static const Field<AppBranding, bool> _f$useMaterial3 = Field(
    'useMaterial3',
    _$useMaterial3,
  );

  @override
  final MappableFields<AppBranding> fields = const {
    #primaryColor: _f$primaryColor,
    #secondaryColor: _f$secondaryColor,
    #surfaceColor: _f$surfaceColor,
    #errorColor: _f$errorColor,
    #logoLight: _f$logoLight,
    #logoDark: _f$logoDark,
    #appIcon: _f$appIcon,
    #themeMode: _f$themeMode,
    #allowThemeToggle: _f$allowThemeToggle,
    #useMaterial3: _f$useMaterial3,
  };

  static AppBranding _instantiate(DecodingData data) {
    return AppBranding(
      primaryColor: data.dec(_f$primaryColor),
      secondaryColor: data.dec(_f$secondaryColor),
      surfaceColor: data.dec(_f$surfaceColor),
      errorColor: data.dec(_f$errorColor),
      logoLight: data.dec(_f$logoLight),
      logoDark: data.dec(_f$logoDark),
      appIcon: data.dec(_f$appIcon),
      themeMode: data.dec(_f$themeMode),
      allowThemeToggle: data.dec(_f$allowThemeToggle),
      useMaterial3: data.dec(_f$useMaterial3),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AppBranding fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AppBranding>(map);
  }

  static AppBranding fromJson(String json) {
    return ensureInitialized().decodeJson<AppBranding>(json);
  }
}

mixin AppBrandingMappable {
  String toJson() {
    return AppBrandingMapper.ensureInitialized().encodeJson<AppBranding>(
      this as AppBranding,
    );
  }

  Map<String, dynamic> toMap() {
    return AppBrandingMapper.ensureInitialized().encodeMap<AppBranding>(
      this as AppBranding,
    );
  }

  AppBrandingCopyWith<AppBranding, AppBranding, AppBranding> get copyWith =>
      _AppBrandingCopyWithImpl<AppBranding, AppBranding>(
        this as AppBranding,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AppBrandingMapper.ensureInitialized().stringifyValue(
      this as AppBranding,
    );
  }

  @override
  bool operator ==(Object other) {
    return AppBrandingMapper.ensureInitialized().equalsValue(
      this as AppBranding,
      other,
    );
  }

  @override
  int get hashCode {
    return AppBrandingMapper.ensureInitialized().hashValue(this as AppBranding);
  }
}

extension AppBrandingValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AppBranding, $Out> {
  AppBrandingCopyWith<$R, AppBranding, $Out> get $asAppBranding =>
      $base.as((v, t, t2) => _AppBrandingCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AppBrandingCopyWith<$R, $In extends AppBranding, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    Color? primaryColor,
    Color? secondaryColor,
    Color? surfaceColor,
    Color? errorColor,
    ImageReference? logoLight,
    ImageReference? logoDark,
    ImageReference? appIcon,
    String? themeMode,
    bool? allowThemeToggle,
    bool? useMaterial3,
  });
  AppBrandingCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AppBrandingCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AppBranding, $Out>
    implements AppBrandingCopyWith<$R, AppBranding, $Out> {
  _AppBrandingCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AppBranding> $mapper =
      AppBrandingMapper.ensureInitialized();
  @override
  $R call({
    Color? primaryColor,
    Color? secondaryColor,
    Color? surfaceColor,
    Color? errorColor,
    Object? logoLight = $none,
    Object? logoDark = $none,
    Object? appIcon = $none,
    String? themeMode,
    bool? allowThemeToggle,
    bool? useMaterial3,
  }) => $apply(
    FieldCopyWithData({
      if (primaryColor != null) #primaryColor: primaryColor,
      if (secondaryColor != null) #secondaryColor: secondaryColor,
      if (surfaceColor != null) #surfaceColor: surfaceColor,
      if (errorColor != null) #errorColor: errorColor,
      if (logoLight != $none) #logoLight: logoLight,
      if (logoDark != $none) #logoDark: logoDark,
      if (appIcon != $none) #appIcon: appIcon,
      if (themeMode != null) #themeMode: themeMode,
      if (allowThemeToggle != null) #allowThemeToggle: allowThemeToggle,
      if (useMaterial3 != null) #useMaterial3: useMaterial3,
    }),
  );
  @override
  AppBranding $make(CopyWithData data) => AppBranding(
    primaryColor: data.get(#primaryColor, or: $value.primaryColor),
    secondaryColor: data.get(#secondaryColor, or: $value.secondaryColor),
    surfaceColor: data.get(#surfaceColor, or: $value.surfaceColor),
    errorColor: data.get(#errorColor, or: $value.errorColor),
    logoLight: data.get(#logoLight, or: $value.logoLight),
    logoDark: data.get(#logoDark, or: $value.logoDark),
    appIcon: data.get(#appIcon, or: $value.appIcon),
    themeMode: data.get(#themeMode, or: $value.themeMode),
    allowThemeToggle: data.get(#allowThemeToggle, or: $value.allowThemeToggle),
    useMaterial3: data.get(#useMaterial3, or: $value.useMaterial3),
  );

  @override
  AppBrandingCopyWith<$R2, AppBranding, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AppBrandingCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

