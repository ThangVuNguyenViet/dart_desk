import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/aura_enums.dart';
import 'cms_content.dart';

part 'brand_theme.cms.g.dart';
part 'brand_theme.mapper.dart';

@CmsConfig(
  title: 'Brand Theme',
  description: 'Colors and typography shared across every Aura screen.',
)
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'brandTheme',
  includeCustomMappers: [BrandThemeColorMapper(), ImageReferenceMapper()],
)
class BrandTheme extends CmsContent
    with BrandThemeMappable, Serializable<BrandTheme> {
  @CmsStringFieldConfig(description: 'Theme name', option: CmsStringOption())
  final String name;

  @CmsColorFieldConfig(
    description: 'Primary — buttons, accents, dark surfaces',
    option: CmsColorOption(),
  )
  final Color primaryColor;

  @CmsColorFieldConfig(
    description: 'Surface — page backgrounds',
    option: CmsColorOption(),
  )
  final Color surfaceColor;

  @CmsColorFieldConfig(
    description: 'Accent — prices, tags, warm highlights',
    option: CmsColorOption(),
  )
  final Color accentColor;

  @CmsColorFieldConfig(
    description: 'Ink — body text and headlines',
    option: CmsColorOption(),
  )
  final Color inkColor;

  @CmsDropdownFieldConfig<String>(
    description: 'Headline font',
    option: HeadlineFontDropdownOption(),
  )
  final String headlineFont;

  @CmsDropdownFieldConfig<String>(
    description: 'Body font',
    option: BodyFontDropdownOption(),
  )
  final String bodyFont;

  @CmsNumberFieldConfig(
    description: 'Corner radius in px',
    option: CmsNumberOption(min: 0, max: 24),
  )
  final num cornerRadius;

  @CmsImageFieldConfig(
    description: 'Logo (square)',
    option: CmsImageOption(hotspot: false),
  )
  final ImageReference? logo;

  const BrandTheme({
    required this.name,
    required this.primaryColor,
    required this.surfaceColor,
    required this.accentColor,
    required this.inkColor,
    required this.headlineFont,
    required this.bodyFont,
    required this.cornerRadius,
    this.logo,
  });

  static BrandTheme defaultValue = const BrandTheme(
    name: 'Aura Gastronomy',
    primaryColor: Color(0xFF496455),
    surfaceColor: Color(0xFFF6F1E7),
    accentColor: Color(0xFFC67A4A),
    inkColor: Color(0xFF1E1B14),
    headlineFont: 'Noto Serif',
    bodyFont: 'Manrope',
    cornerRadius: 16,
    logo: null,
  );
}

class BrandThemeColorMapper extends SimpleMapper<Color> {
  const BrandThemeColorMapper();

  @override
  Color decode(Object value) {
    if (value is String) {
      final hex = value.replaceFirst('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    }
    throw Exception('Cannot decode Color from $value');
  }

  @override
  Object? encode(Color self) =>
      '#${self.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

class HeadlineFontDropdownOption extends CmsDropdownOption<String> {
  const HeadlineFontDropdownOption({super.hidden});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get defaultValue => 'Noto Serif';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final f in headlineFonts) DropdownOption(value: f, label: f),
      ];
  @override
  String? get placeholder => 'Headline font';
}

class BodyFontDropdownOption extends CmsDropdownOption<String> {
  const BodyFontDropdownOption({super.hidden});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get defaultValue => 'Manrope';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final f in bodyFonts) DropdownOption(value: f, label: f),
      ];
  @override
  String? get placeholder => 'Body font';
}
