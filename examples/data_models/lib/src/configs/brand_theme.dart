import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import 'cms_content.dart';

part 'brand_theme.cms.g.dart';
part 'brand_theme.mapper.dart';

@CmsConfig(
  title: 'Brand Theme',
  description: 'Global brand colors, typography, and styling for the Aura Gastronomy app',
)
@MappableClass(ignoreNull: false, discriminatorValue: 'brandTheme', includeCustomMappers: [BrandThemeColorMapper()])
class BrandTheme extends CmsContent with BrandThemeMappable, Serializable<BrandTheme> {
  @CmsColorFieldConfig(
    description: 'Primary brand color used for buttons, nav, and accents',
    option: CmsColorOption(),
  )
  final Color primaryColor;

  @CmsColorFieldConfig(
    description: 'Surface/background color for the app',
    option: CmsColorOption(),
  )
  final Color surfaceColor;

  @CmsColorFieldConfig(
    description: 'Primary text color',
    option: CmsColorOption(),
  )
  final Color textColor;

  @CmsStringFieldConfig(
    description: 'Font family for headlines (e.g. Noto Serif)',
    option: CmsStringOption(),
  )
  final String headlineFont;

  @CmsStringFieldConfig(
    description: 'Font family for body text (e.g. Manrope)',
    option: CmsStringOption(),
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

  const BrandTheme({
    required this.primaryColor,
    required this.surfaceColor,
    required this.textColor,
    required this.headlineFont,
    required this.bodyFont,
    required this.cornerRadius,
    required this.themeMode,
  });

  static BrandTheme defaultValue = BrandTheme(
    primaryColor: const Color(0xFF496455),
    surfaceColor: const Color(0xFFFAF9F7),
    textColor: const Color(0xFF2F3331),
    headlineFont: 'Noto Serif',
    bodyFont: 'Manrope',
    cornerRadius: 8,
    themeMode: 'light',
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
