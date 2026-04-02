// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'home_screen_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for HomeScreenConfig
final homeScreenConfigFields = [
  CmsStringField(
    name: 'heroTitle',
    title: 'Hero Title',
    option: CmsStringOption(),
  ),
  CmsTextField(
    name: 'heroSubtitle',
    title: 'Hero Subtitle',
    option: CmsTextOption(rows: 3),
  ),
  CmsImageField(
    name: 'backgroundImage',
    title: 'Background Image',
    option: CmsImageOption(hotspot: false),
  ),
  CmsBooleanField(
    name: 'enableDarkOverlay',
    title: 'Enable Dark Overlay',
    option: CmsBooleanOption(),
  ),
  CmsColorField(
    name: 'primaryColor',
    title: 'Primary Color',
    option: CmsColorOption(),
  ),
  CmsColorField(
    name: 'accentColor',
    title: 'Accent Color',
    option: CmsColorOption(),
  ),
  CmsArrayField<String>(
    name: 'featuredItems',
    title: 'Featured Items',
    option: FeaturedItemsArrayOption(),
  ),
  CmsNumberField(
    name: 'maxFeaturedItems',
    title: 'Max Featured Items',
    option: CmsNumberOption(min: 1, max: 10),
  ),
  CmsNumberField(
    name: 'heroOverlayOpacity',
    title: 'Hero Overlay Opacity',
    option: CmsNumberOption(min: 0.0, max: 1.0),
  ),
  CmsCheckboxField(
    name: 'showPromotionalBanner',
    title: 'Show Promotional Banner',
    option: CmsCheckboxOption(label: 'Enable promotional banner'),
  ),
  CmsStringField(
    name: 'bannerHeadline',
    title: 'Banner Headline',
    option: CmsStringOption(),
  ),
  CmsTextField(
    name: 'bannerBody',
    title: 'Banner Body',
    option: CmsTextOption(rows: 2),
  ),
  CmsDateField(
    name: 'promoStartDate',
    title: 'Promo Start Date',
    option: CmsDateOption(),
  ),
  CmsDateField(
    name: 'promoEndDate',
    title: 'Promo End Date',
    option: CmsDateOption(),
  ),
  CmsDateTimeField(
    name: 'lastUpdated',
    title: 'Last Updated',
    option: CmsDateTimeOption(),
  ),
  CmsUrlField(
    name: 'externalLink',
    title: 'External Link',
    option: CmsUrlOption(),
  ),
  CmsFileField(
    name: 'downloadableResource',
    title: 'Downloadable Resource',
    option: CmsFileOption(),
  ),
  CmsImageField(
    name: 'footerLogo',
    title: 'Footer Logo',
    option: CmsImageOption(hotspot: false),
  ),
  CmsStringField(
    name: 'primaryButtonLabel',
    title: 'Primary Button Label',
    option: CmsStringOption(),
  ),
  CmsUrlField(
    name: 'primaryButtonUrl',
    title: 'Primary Button Url',
    option: CmsUrlOption(),
  ),
  CmsStringField(
    name: 'secondaryButtonLabel',
    title: 'Secondary Button Label',
    option: CmsStringOption(),
  ),
  CmsDropdownField<String>(
    name: 'layoutStyle',
    title: 'Layout Style',
    option: LayoutStyleDropdownOption(),
  ),
  CmsNumberField(
    name: 'contentPadding',
    title: 'Content Padding',
    option: CmsNumberOption(min: 8.0, max: 48.0),
  ),
  CmsNumberField(
    name: 'gridColumns',
    title: 'Grid Columns',
    option: CmsNumberOption(min: 1, max: 4),
  ),
  CmsCheckboxField(
    name: 'showFooter',
    title: 'Show Footer',
    option: CmsCheckboxOption(label: 'Show footer section'),
  ),
  CmsStringField(
    name: 'metaTitle',
    title: 'Meta Title',
    option: CmsStringOption(),
  ),
  CmsTextField(
    name: 'metaDescription',
    title: 'Meta Description',
    option: CmsTextOption(rows: 2),
  ),
];

/// Generated document type spec for HomeScreenConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final homeScreenConfigTypeSpec = DocumentTypeSpec<HomeScreenConfig>(
  name: 'homeScreenConfig',
  title: 'Home Screen',
  description:
      'Configuration for the mobile app home screen with hero section, features, and actions',
  fields: homeScreenConfigFields,
  defaultValue: HomeScreenConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class HomeScreenConfigCmsConfig {
  HomeScreenConfigCmsConfig({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.backgroundImage,
    required this.enableDarkOverlay,
    required this.primaryColor,
    required this.accentColor,
    required this.featuredItems,
    required this.maxFeaturedItems,
    required this.heroOverlayOpacity,
    required this.showPromotionalBanner,
    required this.bannerHeadline,
    required this.bannerBody,
    required this.promoStartDate,
    required this.promoEndDate,
    required this.lastUpdated,
    required this.externalLink,
    required this.downloadableResource,
    required this.footerLogo,
    required this.primaryButtonLabel,
    required this.primaryButtonUrl,
    required this.secondaryButtonLabel,
    required this.layoutStyle,
    required this.contentPadding,
    required this.gridColumns,
    required this.showFooter,
    required this.metaTitle,
    required this.metaDescription,
  });

  final CmsData<String> heroTitle;

  final CmsData<String> heroSubtitle;

  final CmsData<ImageReference?> backgroundImage;

  final CmsData<bool> enableDarkOverlay;

  final CmsData<Color> primaryColor;

  final CmsData<Color> accentColor;

  final CmsData<List<String>> featuredItems;

  final CmsData<int> maxFeaturedItems;

  final CmsData<double> heroOverlayOpacity;

  final CmsData<bool> showPromotionalBanner;

  final CmsData<String> bannerHeadline;

  final CmsData<String> bannerBody;

  final CmsData<DateTime?> promoStartDate;

  final CmsData<DateTime?> promoEndDate;

  final CmsData<DateTime> lastUpdated;

  final CmsData<String?> externalLink;

  final CmsData<String?> downloadableResource;

  final CmsData<ImageReference?> footerLogo;

  final CmsData<String> primaryButtonLabel;

  final CmsData<String?> primaryButtonUrl;

  final CmsData<String> secondaryButtonLabel;

  final CmsData<String> layoutStyle;

  final CmsData<double> contentPadding;

  final CmsData<int> gridColumns;

  final CmsData<bool> showFooter;

  final CmsData<String?> metaTitle;

  final CmsData<String?> metaDescription;
}
