import 'dart:async';
import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:example_app/screens/homes_creen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

part 'home_screen_config.cms.g.dart';
part 'home_screen_config.mapper.dart';

@CmsConfig(
  title: 'Home Screen',
  description:
      'Configuration for the mobile app home screen with hero section, features, and actions',
)
@MappableClass(ignoreNull: false, includeCustomMappers: [ColorMapper()])
class HomeScreenConfig
    with HomeScreenConfigMappable, Serializable<HomeScreenConfig> {
  // Hero Section
  @CmsStringFieldConfig(
    description: 'Title text displayed prominently in the hero section',
    option: CmsStringOption(),
  )
  final String heroTitle;

  @CmsTextFieldConfig(
    description: 'Descriptive text shown below the hero title',
    option: CmsTextOption(rows: 3),
  )
  final String heroSubtitle;

  @CmsImageFieldConfig(
    description: 'Background image for the hero section',
    option: CmsImageOption(hotspot: false),
  )
  final String backgroundImageUrl;

  @CmsBooleanFieldConfig(
    description: 'Enable dark overlay on background image',
    option: CmsBooleanOption(),
  )
  final bool enableDarkOverlay;

  @CmsColorFieldConfig(
    description: 'Primary theme color used throughout the screen',
    option: CmsColorOption(),
  )
  final Color primaryColor;

  // Content Configuration
  @CmsArrayFieldConfig<String>(
    description: 'List of features to highlight on the home screen',
    option: FeaturedItemsArrayOption(),
  )
  final List<String> featuredItems;

  @CmsNumberFieldConfig(
    description: 'Maximum number of items to display in featured section',
    option: CmsNumberOption(min: 0, max: 10),
  )
  final int maxFeaturedItems;

  @CmsDateTimeFieldConfig(
    description: 'Last updated timestamp for the configuration',
    option: CmsDateTimeOption(),
  )
  final DateTime lastUpdated;

  @CmsUrlFieldConfig(
    description: 'External link for more information',
    option: CmsUrlOption(),
  )
  final String? externalLink;

  @CmsBooleanFieldConfig(
    description: 'Show promotional banner at the top',
    option: CmsBooleanOption(),
  )
  final bool showPromotionalBanner;

  // Action Buttons - simplified as strings for now
  @CmsStringFieldConfig(
    description: 'Label text for the primary action button',
    option: CmsStringOption(),
  )
  final String primaryButtonLabel;

  @CmsStringFieldConfig(
    description: 'Label text for the secondary action button',
    option: CmsStringOption(),
  )
  final String secondaryButtonLabel;

  // Layout Configuration
  @CmsDropdownFieldConfig<String>(
    description: 'Layout style for the content area',
    option: LayoutStyleDropdownOption(),
  )
  final String layoutStyle;

  @CmsNumberFieldConfig(
    description: 'Padding around the main content area in pixels',
    option: CmsNumberOption(min: 8.0, max: 32.0),
  )
  final double contentPadding;

  const HomeScreenConfig({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.backgroundImageUrl,
    required this.enableDarkOverlay,
    required this.primaryColor,
    required this.featuredItems,
    required this.maxFeaturedItems,
    required this.lastUpdated,
    this.externalLink,
    required this.showPromotionalBanner,
    required this.primaryButtonLabel,
    required this.secondaryButtonLabel,
    required this.layoutStyle,
    required this.contentPadding,
  });

  static HomeScreenConfig defaultValue = HomeScreenConfig(
    heroTitle: 'Welcome to Our App',
    heroSubtitle:
        'Discover amazing features and capabilities that will enhance your daily workflow and productivity.',
    backgroundImageUrl: '',
    enableDarkOverlay: true,
    primaryColor: Colors.deepPurple,
    featuredItems: [
      'Advanced Analytics',
      'Real-time Collaboration',
      'Cloud Synchronization',
      'Smart Notifications',
      'Cross-platform Support',
    ],
    maxFeaturedItems: 4,
    lastUpdated: DateTime.now(),
    externalLink: 'https://example.com/learn-more',
    showPromotionalBanner: true,
    primaryButtonLabel: 'Get Started',
    secondaryButtonLabel: 'Learn More',
    layoutStyle: 'grid',
    contentPadding: 16.0,
  );

  static Widget configBuilder(Map<String, dynamic> config) {
    final mergedConfig = {...defaultValue.toMap(), ...config};

    // Normalize fields that may be stored as JSON strings instead of Lists
    final featuredItems = mergedConfig['featuredItems'];
    if (featuredItems is String) {
      try {
        mergedConfig['featuredItems'] = jsonDecode(featuredItems);
      } catch (_) {
        mergedConfig['featuredItems'] = <String>[];
      }
    }

    final homeScreenConfig = HomeScreenConfigMapper.fromMap(mergedConfig);
    return HomeScreen(config: homeScreenConfig);
  }

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

class LayoutStyleDropdownOption extends CmsDropdownOption<String> {
  const LayoutStyleDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue async {
    return (await options).firstOrNull?.value;
  }

  @override
  FutureOr<List<DropdownOption<String>>> get options => Future.value([
    DropdownOption(value: 'grid', label: 'Grid Layout'),
    DropdownOption(value: 'list', label: 'List Layout'),
    DropdownOption(value: 'masonry', label: 'Masonry Layout'),
  ]);

  @override
  String? get placeholder => 'Select a layout style';
}

class FeaturedItemsArrayOption extends CmsArrayOption {
  const FeaturedItemsArrayOption({super.hidden});

  @override
  CmsArrayFieldItemBuilder get itemBuilder =>
      (BuildContext context, dynamic value) {
        return Text(value as String);
      };

  @override
  CmsArrayFieldItemEditor get itemEditor =>
      (BuildContext context, dynamic value, ValueChanged<dynamic>? onChanged) {
        return FeaturedItemEditor(
          initialValue: value as String? ?? '',
          onChanged: onChanged,
        );
      };
}

class FeaturedItemEditor extends StatefulWidget {
  final String initialValue;
  final ValueChanged<dynamic>? onChanged;

  const FeaturedItemEditor({
    super.key,
    required this.initialValue,
    this.onChanged,
  });

  @override
  State<FeaturedItemEditor> createState() => _FeaturedItemEditorState();
}

class _FeaturedItemEditorState extends State<FeaturedItemEditor> {
  @override
  Widget build(BuildContext context) {
    return ShadInputFormField(
      minLines: 1,
      maxLines: 3,
      onChanged: widget.onChanged,
      label: Text('Item Title', style: ShadTheme.of(context).textTheme.list),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
