// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'app_theme.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for AppTheme
final appThemeFields = [
  CmsColorField(
    name: 'primaryColor',
    title: 'Primary Color',
    option: CmsColorOption(),
  ),
  CmsColorField(
    name: 'secondaryColor',
    title: 'Secondary Color',
    option: CmsColorOption(),
  ),
  CmsColorField(
    name: 'backgroundColor',
    title: 'Background Color',
    option: CmsColorOption(),
  ),
  CmsColorField(
    name: 'textColor',
    title: 'Text Color',
    option: CmsColorOption(),
  ),
  CmsImageField(
    name: 'logoLight',
    title: 'Logo Light',
    option: CmsImageOption(hotspot: false),
  ),
  CmsImageField(
    name: 'logoDark',
    title: 'Logo Dark',
    option: CmsImageOption(hotspot: false),
  ),
  CmsImageField(
    name: 'appIcon',
    title: 'App Icon',
    option: CmsImageOption(hotspot: false),
  ),
  CmsDropdownField<String>(
    name: 'themeMode',
    title: 'Theme Mode',
    option: ThemeModeDropdownOption(),
  ),
  CmsNumberField(
    name: 'cornerRadius',
    title: 'Corner Radius',
    option: CmsNumberOption(min: 0, max: 32),
  ),
  CmsBooleanField(
    name: 'useMaterial3',
    title: 'Use Material3',
    option: CmsBooleanOption(),
  ),
];

/// Generated document type spec for AppTheme.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final appThemeTypeSpec = DocumentTypeSpec<AppTheme>(
  name: 'appTheme',
  title: 'App Theme',
  description:
      'Brand visual identity including colors, logos, and design system settings',
  fields: appThemeFields,
  defaultValue: AppTheme.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class AppThemeCmsConfig {
  AppThemeCmsConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.logoLight,
    required this.logoDark,
    required this.appIcon,
    required this.themeMode,
    required this.cornerRadius,
    required this.useMaterial3,
  });

  final CmsData<Color> primaryColor;

  final CmsData<Color> secondaryColor;

  final CmsData<Color> backgroundColor;

  final CmsData<Color> textColor;

  final CmsData<ImageUrl?> logoLight;

  final CmsData<ImageUrl?> logoDark;

  final CmsData<ImageUrl?> appIcon;

  final CmsData<String> themeMode;

  final CmsData<num> cornerRadius;

  final CmsData<bool> useMaterial3;
}
