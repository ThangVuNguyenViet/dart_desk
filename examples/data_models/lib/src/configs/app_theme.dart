import 'dart:async';

import 'package:dart_desk/dart_desk.dart' show ImageUrl, ImageUrlMapper;
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

part 'app_theme.cms.g.dart';
part 'app_theme.mapper.dart';

@CmsConfig(
  title: 'App Theme',
  description:
      'Brand visual identity including colors, logos, and design system settings',
)
@MappableClass(
  ignoreNull: false,
  includeCustomMappers: [ColorMapper(), ImageUrlMapper()],
)
class AppTheme with AppThemeMappable, Serializable<AppTheme> {
  @CmsColorFieldConfig(
    description: 'Primary brand color used for key UI elements and CTAs',
    option: CmsColorOption(),
  )
  final Color primaryColor;

  @CmsColorFieldConfig(
    description: 'Secondary brand color for supporting UI elements',
    option: CmsColorOption(),
  )
  final Color secondaryColor;

  @CmsColorFieldConfig(
    description: 'Main background color of the app',
    option: CmsColorOption(),
  )
  final Color backgroundColor;

  @CmsColorFieldConfig(
    description: 'Default text color used throughout the app',
    option: CmsColorOption(),
  )
  final Color textColor;

  @CmsImageFieldConfig(
    description: 'Logo variant for use on light backgrounds',
    option: CmsImageOption(hotspot: false),
  )
  final ImageUrl? logoLight;

  @CmsImageFieldConfig(
    description: 'Logo variant for use on dark backgrounds',
    option: CmsImageOption(hotspot: false),
  )
  final ImageUrl? logoDark;

  @CmsImageFieldConfig(
    description: 'App icon used on the device home screen',
    option: CmsImageOption(hotspot: false),
  )
  final ImageUrl? appIcon;

  @CmsDropdownFieldConfig<String>(
    description: 'Default theme mode for the app',
    option: ThemeModeDropdownOption(),
  )
  final String themeMode;

  @CmsNumberFieldConfig(
    description: 'Corner radius applied to cards and buttons (in dp)',
    option: CmsNumberOption(min: 0, max: 32),
  )
  final num cornerRadius;

  @CmsBooleanFieldConfig(
    description: 'Use Material 3 design system',
    option: CmsBooleanOption(),
  )
  final bool useMaterial3;

  const AppTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    this.logoLight,
    this.logoDark,
    this.appIcon,
    required this.themeMode,
    required this.cornerRadius,
    required this.useMaterial3,
  });

  static AppTheme defaultValue = AppTheme(
    primaryColor: const Color(0xFFD4451A),
    secondaryColor: const Color(0xFFF9A825),
    backgroundColor: const Color(0xFFFFF8F0),
    textColor: const Color(0xFF1A1A1A),
    logoLight: null,
    logoDark: null,
    appIcon: null,
    themeMode: 'system',
    cornerRadius: 8,
    useMaterial3: true,
  );
}

class ColorMapper extends SimpleMapper<Color> {
  const ColorMapper();

  @override
  Color decode(Object value) {
    if (value is String) {
      final hexColor = value.replaceFirst('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
    }
    throw Exception('Cannot decode Color from $value');
  }

  @override
  Object? encode(Color self) {
    return '#${self.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}

class ThemeModeDropdownOption extends CmsDropdownOption<String> {
  const ThemeModeDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'system';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        DropdownOption(value: 'light', label: 'Light'),
        DropdownOption(value: 'dark', label: 'Dark'),
        DropdownOption(value: 'system', label: 'System'),
      ]);

  @override
  String? get placeholder => 'Select a theme mode';
}
