import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';
import 'cms_content.dart';

part 'brand_theme.cms.g.dart';
part 'brand_theme.mapper.dart';

@CmsConfig(
  title: 'Brand Theme',
  description: 'Visual identity — colors, fonts, and logo for the app',
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
    description: 'Primary brand color used for buttons and accents',
    option: CmsColorOption(),
  )
  final Color primaryColor;

  @CmsColorFieldConfig(
    description: 'Secondary brand color for backgrounds and cards',
    option: CmsColorOption(),
  )
  final Color secondaryColor;

  @CmsColorFieldConfig(
    description: 'Accent color for highlights and badges',
    option: CmsColorOption(),
  )
  final Color accentColor;

  @CmsDropdownFieldConfig<String>(
    description: 'Font family for headlines',
    option: HeadlineFontDropdownOption(),
  )
  final String headlineFont;

  @CmsDropdownFieldConfig<String>(
    description: 'Font family for body text',
    option: BodyFontDropdownOption(),
  )
  final String bodyFont;

  @CmsNumberFieldConfig(
    description: 'Corner radius for cards and buttons in pixels',
    option: CmsNumberOption(min: 0, max: 24),
  )
  final num cornerRadius;

  @CmsDropdownFieldConfig<String>(
    description: 'App theme mode',
    option: ThemeModeDropdownOption(),
  )
  final String themeMode;

  @CmsImageFieldConfig(
    description: 'Brand logo',
    option: CmsImageOption(hotspot: false),
  )
  final ImageReference? logo;

  const BrandTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.headlineFont,
    required this.bodyFont,
    required this.cornerRadius,
    required this.themeMode,
    this.logo,
  });

  static BrandTheme defaultValue = BrandTheme(
    name: 'Aura Gastronomy',
    primaryColor: const Color(0xFF496455),
    secondaryColor: const Color(0xFFFAF9F7),
    accentColor: const Color(0xFFD4A574),
    headlineFont: 'Noto Serif',
    bodyFont: 'Manrope',
    cornerRadius: 8,
    themeMode: 'light',
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
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final f in headlineFonts) DropdownOption(value: f, label: f),
      ]);

  @override
  String? get placeholder => 'Select headline font';
}

class BodyFontDropdownOption extends CmsDropdownOption<String> {
  const BodyFontDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'Manrope';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final f in bodyFonts) DropdownOption(value: f, label: f),
      ]);

  @override
  String? get placeholder => 'Select body font';
}

class ThemeModeDropdownOption extends CmsDropdownOption<String> {
  const ThemeModeDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'light';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        DropdownOption(value: 'light', label: 'Light'),
        DropdownOption(value: 'dark', label: 'Dark'),
        DropdownOption(value: 'system', label: 'System'),
      ]);

  @override
  String? get placeholder => 'Select theme mode';
}
