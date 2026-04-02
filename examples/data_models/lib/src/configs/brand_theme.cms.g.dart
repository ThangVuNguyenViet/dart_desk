// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'brand_theme.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for BrandTheme
final brandThemeFields = [
  CmsColorField(
    name: 'primaryColor',
    title: 'Primary Color',
    option: CmsColorOption(),
  ),
  CmsColorField(
    name: 'surfaceColor',
    title: 'Surface Color',
    option: CmsColorOption(),
  ),
  CmsColorField(
    name: 'textColor',
    title: 'Text Color',
    option: CmsColorOption(),
  ),
  CmsStringField(
    name: 'headlineFont',
    title: 'Headline Font',
    option: CmsStringOption(),
  ),
  CmsStringField(
    name: 'bodyFont',
    title: 'Body Font',
    option: CmsStringOption(),
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
];

/// Generated document type spec for BrandTheme.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final brandThemeTypeSpec = DocumentTypeSpec<BrandTheme>(
  name: 'brandTheme',
  title: 'Brand Theme',
  description:
      'Global brand colors, typography, and styling for the Aura Gastronomy app',
  fields: brandThemeFields,
  defaultValue: BrandTheme.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class BrandThemeCmsConfig {
  BrandThemeCmsConfig({
    required this.primaryColor,
    required this.surfaceColor,
    required this.textColor,
    required this.headlineFont,
    required this.bodyFont,
    required this.cornerRadius,
    required this.themeMode,
  });

  final CmsData<Color> primaryColor;

  final CmsData<Color> surfaceColor;

  final CmsData<Color> textColor;

  final CmsData<String> headlineFont;

  final CmsData<String> bodyFont;

  final CmsData<num> cornerRadius;

  final CmsData<String> themeMode;
}
