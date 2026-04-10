// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'brand_theme.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for BrandTheme
final brandThemeFields = [
  CmsStringField(name: 'name', title: 'Name', option: CmsStringOption()),
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
    name: 'accentColor',
    title: 'Accent Color',
    option: CmsColorOption(),
  ),
  CmsDropdownField<String>(
    name: 'headlineFont',
    title: 'Headline Font',

    option: HeadlineFontDropdownOption(),
  ),
  CmsDropdownField<String>(
    name: 'bodyFont',
    title: 'Body Font',

    option: BodyFontDropdownOption(),
  ),
  CmsNumberField(
    name: 'cornerRadius',
    title: 'Corner Radius',
    option: CmsNumberOption(min: 0, max: 24),
  ),
  CmsDropdownField<String>(
    name: 'themeMode',
    title: 'Theme Mode',

    option: ThemeModeDropdownOption(),
  ),
  CmsImageField(
    name: 'logo',
    title: 'Logo',
    option: CmsImageOption(hotspot: false),
  ),
];

/// Generated document type spec for BrandTheme.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final brandThemeTypeSpec = DocumentTypeSpec<BrandTheme>(
  name: 'brandTheme',
  title: 'Brand Theme',
  description: 'Visual identity — colors, fonts, and logo for the app',
  fields: brandThemeFields,
  defaultValue: BrandTheme.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class BrandThemeCmsConfig {
  BrandThemeCmsConfig({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.headlineFont,
    required this.bodyFont,
    required this.cornerRadius,
    required this.themeMode,
    required this.logo,
  });

  final CmsData<String> name;

  final CmsData<Color> primaryColor;

  final CmsData<Color> secondaryColor;

  final CmsData<Color> accentColor;

  final CmsData<String> headlineFont;

  final CmsData<String> bodyFont;

  final CmsData<num> cornerRadius;

  final CmsData<String> themeMode;

  final CmsData<ImageReference?> logo;
}
