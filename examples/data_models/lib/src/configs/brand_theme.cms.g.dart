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
    name: 'surfaceColor',
    title: 'Surface Color',
    option: CmsColorOption(),
  ),
  CmsColorField(
    name: 'accentColor',
    title: 'Accent Color',
    option: CmsColorOption(),
  ),
  CmsColorField(name: 'inkColor', title: 'Ink Color', option: CmsColorOption()),
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
  description: 'Colors and typography shared across every Aura screen.',
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
    required this.surfaceColor,
    required this.accentColor,
    required this.inkColor,
    required this.headlineFont,
    required this.bodyFont,
    required this.cornerRadius,
    required this.logo,
  });

  final CmsData<String> name;

  final CmsData<Color> primaryColor;

  final CmsData<Color> surfaceColor;

  final CmsData<Color> accentColor;

  final CmsData<Color> inkColor;

  final CmsData<String> headlineFont;

  final CmsData<String> bodyFont;

  final CmsData<num> cornerRadius;

  final CmsData<ImageReference?> logo;
}
