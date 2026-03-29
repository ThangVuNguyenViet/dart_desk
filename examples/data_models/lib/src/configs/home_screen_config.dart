import 'dart:async';

import 'package:dart_desk/dart_desk.dart' show ImageUrl, ImageUrlMapper;
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

part 'home_screen_config.cms.g.dart';
part 'home_screen_config.mapper.dart';

@CmsConfig(
  title: 'Home Screen',
  description:
      'Configuration for the mobile app home screen with hero section, features, and actions',
)
@MappableClass(ignoreNull: false, includeCustomMappers: [ColorMapper(), ImageUrlMapper()])
class HomeScreenConfig
    with HomeScreenConfigMappable, Serializable<HomeScreenConfig> {
  // ── Hero Section ──────────────────────────────────────────────────────
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
  final ImageUrl? backgroundImage;

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

  @CmsColorFieldConfig(
    description: 'Accent color for highlights, badges, and secondary elements',
    option: CmsColorOption(),
  )
  final Color accentColor;

  // ── Content Configuration ─────────────────────────────────────────────
  @CmsArrayFieldConfig<String>(
    description: 'List of features to highlight on the home screen',
    option: FeaturedItemsArrayOption(),
  )
  final List<String> featuredItems;

  @CmsNumberFieldConfig(
    description: 'Maximum number of items to display in featured section',
    option: CmsNumberOption(min: 1, max: 10),
  )
  final int maxFeaturedItems;

  @CmsNumberFieldConfig(
    description: 'Opacity of the hero overlay (0.0 fully transparent, 1.0 fully opaque)',
    option: CmsNumberOption(min: 0.0, max: 1.0),
  )
  final double heroOverlayOpacity;

  // ── Promotional Banner ────────────────────────────────────────────────
  @CmsCheckboxFieldConfig(
    description: 'Show promotional banner at the top of the page',
    option: CmsCheckboxOption(label: 'Enable promotional banner'),
  )
  final bool showPromotionalBanner;

  @CmsStringFieldConfig(
    description: 'Headline text for the promotional banner',
    option: CmsStringOption(),
  )
  final String bannerHeadline;

  @CmsTextFieldConfig(
    description: 'Body text for the promotional banner',
    option: CmsTextOption(rows: 2),
  )
  final String bannerBody;

  // ── Dates & Scheduling ────────────────────────────────────────────────
  @CmsDateFieldConfig(
    description: 'Date when the promotional banner starts showing',
    option: CmsDateOption(),
  )
  final DateTime? promoStartDate;

  @CmsDateFieldConfig(
    description: 'Date when the promotional banner stops showing',
    option: CmsDateOption(),
  )
  final DateTime? promoEndDate;

  @CmsDateTimeFieldConfig(
    description: 'Last updated timestamp for the configuration',
    option: CmsDateTimeOption(),
  )
  final DateTime lastUpdated;

  // ── Links & Media ─────────────────────────────────────────────────────
  @CmsUrlFieldConfig(
    description: 'External link for more information',
    option: CmsUrlOption(),
  )
  final String? externalLink;

  @CmsFileFieldConfig(
    description: 'Downloadable resource file (PDF, guide, etc.)',
    option: CmsFileOption(),
  )
  final String? downloadableResource;

  @CmsImageFieldConfig(
    description: 'Logo image shown in the footer',
    option: CmsImageOption(hotspot: false),
  )
  final ImageUrl? footerLogo;

  // ── Action Buttons ────────────────────────────────────────────────────
  @CmsStringFieldConfig(
    description: 'Label text for the primary action button',
    option: CmsStringOption(),
  )
  final String primaryButtonLabel;

  @CmsUrlFieldConfig(
    description: 'URL the primary button navigates to',
    option: CmsUrlOption(),
  )
  final String? primaryButtonUrl;

  @CmsStringFieldConfig(
    description: 'Label text for the secondary action button',
    option: CmsStringOption(),
  )
  final String secondaryButtonLabel;

  // ── Layout Configuration ──────────────────────────────────────────────
  @CmsDropdownFieldConfig<String>(
    description: 'Layout style for the content area',
    option: LayoutStyleDropdownOption(),
  )
  final String layoutStyle;

  @CmsNumberFieldConfig(
    description: 'Padding around the main content area in pixels',
    option: CmsNumberOption(min: 8.0, max: 48.0),
  )
  final double contentPadding;

  @CmsNumberFieldConfig(
    description: 'Number of columns in grid layout',
    option: CmsNumberOption(min: 1, max: 4),
  )
  final int gridColumns;

  @CmsCheckboxFieldConfig(
    description: 'Show the footer information section',
    option: CmsCheckboxOption(label: 'Show footer section'),
  )
  final bool showFooter;

  // ── SEO / Metadata ────────────────────────────────────────────────────
  @CmsStringFieldConfig(
    description: 'SEO meta title for search engines',
    option: CmsStringOption(),
  )
  final String? metaTitle;

  @CmsTextFieldConfig(
    description: 'SEO meta description for search engines',
    option: CmsTextOption(rows: 2),
  )
  final String? metaDescription;

  const HomeScreenConfig({
    required this.heroTitle,
    required this.heroSubtitle,
    this.backgroundImage,
    required this.enableDarkOverlay,
    required this.primaryColor,
    required this.accentColor,
    required this.featuredItems,
    required this.maxFeaturedItems,
    required this.heroOverlayOpacity,
    required this.showPromotionalBanner,
    required this.bannerHeadline,
    required this.bannerBody,
    this.promoStartDate,
    this.promoEndDate,
    required this.lastUpdated,
    this.externalLink,
    this.downloadableResource,
    this.footerLogo,
    required this.primaryButtonLabel,
    this.primaryButtonUrl,
    required this.secondaryButtonLabel,
    required this.layoutStyle,
    required this.contentPadding,
    required this.gridColumns,
    required this.showFooter,
    this.metaTitle,
    this.metaDescription,
  });

  static HomeScreenConfig defaultValue = HomeScreenConfig(
    heroTitle: 'Welcome to Our App',
    heroSubtitle:
        'Discover amazing features and capabilities that will enhance your daily workflow and productivity.',
    backgroundImage: null,
    enableDarkOverlay: true,
    primaryColor: Colors.deepPurple,
    accentColor: Colors.amber,
    featuredItems: [
      'Advanced Analytics',
      'Real-time Collaboration',
      'Cloud Synchronization',
      'Smart Notifications',
      'Cross-platform Support',
    ],
    maxFeaturedItems: 4,
    heroOverlayOpacity: 0.5,
    showPromotionalBanner: true,
    bannerHeadline: 'New Release Available',
    bannerBody:
        'Version 2.0 is here with improved performance and new features.',
    promoStartDate: null,
    promoEndDate: null,
    lastUpdated: DateTime.now(),
    externalLink: 'https://example.com/learn-more',
    downloadableResource: null,
    footerLogo: null,
    primaryButtonLabel: 'Get Started',
    primaryButtonUrl: null,
    secondaryButtonLabel: 'Learn More',
    layoutStyle: 'grid',
    contentPadding: 16.0,
    gridColumns: 2,
    showFooter: true,
    metaTitle: null,
    metaDescription: null,
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

class LayoutStyleDropdownOption extends CmsDropdownOption<String> {
  const LayoutStyleDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'grid';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => Future.value([
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
