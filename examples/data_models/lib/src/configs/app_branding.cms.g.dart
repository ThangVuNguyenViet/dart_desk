// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'app_branding.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for AppBranding
final appBrandingFields = [
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
    name: 'surfaceColor',
    title: 'Surface Color',
    option: CmsColorOption(),
  ),
  CmsColorField(
    name: 'errorColor',
    title: 'Error Color',
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
  CmsBooleanField(
    name: 'allowThemeToggle',
    title: 'Allow Theme Toggle',
    option: CmsBooleanOption(),
  ),
  CmsBooleanField(
    name: 'useMaterial3',
    title: 'Use Material3',
    option: CmsBooleanOption(),
  ),
];

/// Generated document type spec for AppBranding.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final appBrandingTypeSpec = DocumentTypeSpec<AppBranding>(
  name: 'appBranding',
  title: 'App Branding',
  description: 'Brand identity with colors, logos, and theme configuration',
  fields: appBrandingFields,
  defaultValue: AppBranding.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class AppBrandingCmsConfig {
  AppBrandingCmsConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.errorColor,
    required this.logoLight,
    required this.logoDark,
    required this.appIcon,
    required this.themeMode,
    required this.allowThemeToggle,
    required this.useMaterial3,
  });

  final CmsData<Color> primaryColor;

  final CmsData<Color> secondaryColor;

  final CmsData<Color> surfaceColor;

  final CmsData<Color> errorColor;

  final CmsData<ImageReference?> logoLight;

  final CmsData<ImageReference?> logoDark;

  final CmsData<ImageReference?> appIcon;

  final CmsData<String> themeMode;

  final CmsData<bool> allowThemeToggle;

  final CmsData<bool> useMaterial3;
}
