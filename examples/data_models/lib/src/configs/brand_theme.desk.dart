// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'brand_theme.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for BrandTheme
final brandThemeFields = [
  DeskStringField(name: 'name', title: 'Name', option: DeskStringOption()),
  DeskColorField(
    name: 'primaryColor',
    title: 'Primary Color',
    option: DeskColorOption(),
  ),
  DeskColorField(
    name: 'surfaceColor',
    title: 'Surface Color',
    option: DeskColorOption(),
  ),
  DeskColorField(
    name: 'accentColor',
    title: 'Accent Color',
    option: DeskColorOption(),
  ),
  DeskColorField(
    name: 'inkColor',
    title: 'Ink Color',
    option: DeskColorOption(),
  ),
  DeskDropdownField<String>(
    name: 'headlineFont',
    title: 'Headline Font',

    option: HeadlineFontDropdownOption(),
  ),
  DeskDropdownField<String>(
    name: 'bodyFont',
    title: 'Body Font',

    option: BodyFontDropdownOption(),
  ),
  DeskNumberField(
    name: 'cornerRadius',
    title: 'Corner Radius',
    option: DeskNumberOption(min: 0, max: 24),
  ),
  DeskImageField(
    name: 'logo',
    title: 'Logo',
    option: DeskImageOption(optional: true, hotspot: false),
  ),
  DeskFileField(
    name: 'brandGuidelinesPdf',
    title: 'Brand Guidelines Pdf',
    option: DeskFileOption(optional: true),
  ),
];

/// Generated document type spec for BrandTheme.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final brandThemeTypeSpec = DocumentTypeSpec<BrandTheme>(
  name: 'brandTheme',
  title: 'Brand Theme',
  description: 'Colors and typography shared across every Aura screen.',
  fields: brandThemeFields,
  initialValue: BrandTheme.initialValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class BrandThemeDeskModel {
  BrandThemeDeskModel({
    required this.name,
    required this.primaryColor,
    required this.surfaceColor,
    required this.accentColor,
    required this.inkColor,
    required this.headlineFont,
    required this.bodyFont,
    required this.cornerRadius,
    required this.logo,
    required this.brandGuidelinesPdf,
  });

  final DeskData<String> name;

  final DeskData<Color> primaryColor;

  final DeskData<Color> surfaceColor;

  final DeskData<Color> accentColor;

  final DeskData<Color> inkColor;

  final DeskData<String> headlineFont;

  final DeskData<String> bodyFont;

  final DeskData<num> cornerRadius;

  final DeskData<ImageReference?> logo;

  final DeskData<String?> brandGuidelinesPdf;
}
