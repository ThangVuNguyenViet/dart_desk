// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'storefront_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for StorefrontConfig
final storefrontConfigFields = [
  CmsStringField(
    name: 'restaurantName',
    title: 'Restaurant Name',
    option: CmsStringOption(),
  ),
  CmsTextField(
    name: 'tagline',
    title: 'Tagline',
    option: CmsTextOption(rows: 2),
  ),
  CmsImageField(
    name: 'heroImage',
    title: 'Hero Image',
    option: CmsImageOption(hotspot: true),
  ),
  CmsImageField(
    name: 'logo',
    title: 'Logo',
    option: CmsImageOption(hotspot: false),
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
  CmsTextField(
    name: 'welcomeMessage',
    title: 'Welcome Message',
    option: CmsTextOption(rows: 3),
  ),
  CmsStringField(
    name: 'operatingHours',
    title: 'Operating Hours',
    option: CmsStringOption(),
  ),
  CmsUrlField(name: 'orderUrl', title: 'Order Url', option: CmsUrlOption()),
  CmsBooleanField(
    name: 'showHours',
    title: 'Show Hours',
    option: CmsBooleanOption(),
  ),
  CmsStringField(
    name: 'ctaLabel',
    title: 'Cta Label',
    option: CmsStringOption(),
  ),
];

/// Generated document type spec for StorefrontConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final storefrontConfigTypeSpec = DocumentTypeSpec<StorefrontConfig>(
  name: 'storefrontConfig',
  title: 'Storefront Config',
  description: 'Restaurant app home screen branding and display settings',
  fields: storefrontConfigFields,
  defaultValue: StorefrontConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class StorefrontConfigCmsConfig {
  StorefrontConfigCmsConfig({
    required this.restaurantName,
    required this.tagline,
    required this.heroImage,
    required this.logo,
    required this.primaryColor,
    required this.accentColor,
    required this.welcomeMessage,
    required this.operatingHours,
    required this.orderUrl,
    required this.showHours,
    required this.ctaLabel,
  });

  final CmsData<String> restaurantName;

  final CmsData<String> tagline;

  final CmsData<ImageReference?> heroImage;

  final CmsData<ImageReference?> logo;

  final CmsData<Color> primaryColor;

  final CmsData<Color> accentColor;

  final CmsData<String> welcomeMessage;

  final CmsData<String> operatingHours;

  final CmsData<String?> orderUrl;

  final CmsData<bool> showHours;

  final CmsData<String> ctaLabel;
}
