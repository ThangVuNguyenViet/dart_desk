import 'dart:async';

import 'package:dart_desk/dart_desk.dart'
    show ImageUrl, ImageUrlMapper, ImageReference;
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'app_branding.cms.g.dart';
part 'app_branding.mapper.dart';

@CmsConfig(
  title: 'App Branding',
  description: 'Brand identity with colors, logos, and theme configuration',
)
@MappableClass(
  ignoreNull: false,
  includeCustomMappers: [ColorMapper(), ImageUrlMapper()],
)
class AppBranding with AppBrandingMappable, Serializable<AppBranding> {
  @CmsColorFieldConfig(
    description: 'Primary brand color',
    option: CmsColorOption(),
  )
  final Color primaryColor;

  @CmsColorFieldConfig(
    description: 'Secondary brand color',
    option: CmsColorOption(),
  )
  final Color secondaryColor;

  @CmsColorFieldConfig(
    description: 'Surface/background color',
    option: CmsColorOption(),
  )
  final Color surfaceColor;

  @CmsColorFieldConfig(
    description: 'Error/danger color',
    option: CmsColorOption(),
  )
  final Color errorColor;

  @CmsImageFieldConfig(
    description: 'Primary logo (light backgrounds)',
    option: CmsImageOption(hotspot: false),
  )
  final ImageReference? logoLight;

  @CmsImageFieldConfig(
    description: 'Primary logo (dark backgrounds)',
    option: CmsImageOption(hotspot: false),
  )
  final ImageReference? logoDark;

  @CmsImageFieldConfig(
    description: 'App icon / favicon',
    option: CmsImageOption(hotspot: false),
  )
  final ImageReference? appIcon;

  @CmsDropdownFieldConfig<String>(
    description: 'Default theme mode',
    option: ThemeModeDropdownOption(),
  )
  final String themeMode;

  @CmsBooleanFieldConfig(
    description: 'Allow users to switch themes',
    option: CmsBooleanOption(),
  )
  final bool allowThemeToggle;

  @CmsBooleanFieldConfig(
    description: 'Use Material 3 design',
    option: CmsBooleanOption(),
  )
  final bool useMaterial3;

  const AppBranding({
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.errorColor,
    this.logoLight,
    this.logoDark,
    this.appIcon,
    required this.themeMode,
    required this.allowThemeToggle,
    required this.useMaterial3,
  });

  static AppBranding defaultValue = AppBranding(
    primaryColor: Colors.deepPurple,
    secondaryColor: Colors.teal,
    surfaceColor: Colors.white,
    errorColor: Colors.red,
    logoLight: null,
    logoDark: null,
    appIcon: null,
    themeMode: 'system',
    allowThemeToggle: true,
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
