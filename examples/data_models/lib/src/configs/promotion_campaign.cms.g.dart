// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'promotion_campaign.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for PromotionCampaign
final promotionCampaignFields = [
  CmsStringField(name: 'title', title: 'Title', option: CmsStringOption()),
  CmsStringField(
    name: 'promoCode',
    title: 'Promo Code',
    option: CmsStringOption(),
  ),
  CmsTextField(
    name: 'termsAndConditions',
    title: 'Terms And Conditions',
    option: CmsTextOption(rows: 3),
  ),
  CmsNumberField(
    name: 'discountPercent',
    title: 'Discount Percent',
    option: CmsNumberOption(min: 0, max: 100),
  ),
  CmsDropdownField<String>(
    name: 'discountType',
    title: 'Discount Type',

    option: DiscountTypeDropdownOption(),
  ),
  CmsMultiDropdownField<String>(
    name: 'applicableCategories',
    title: 'Applicable Categories',

    option: ApplicableCategoriesDropdownOption(),
  ),
  CmsBooleanField(name: 'isActive', title: 'Is Active'),
  CmsDateField(
    name: 'validFrom',
    title: 'Valid From',
    option: CmsDateOption(optional: true),
  ),
  CmsDateTimeField(
    name: 'startsAt',
    title: 'Starts At',
    option: CmsDateTimeOption(optional: true),
  ),
  CmsDateTimeField(
    name: 'endsAt',
    title: 'Ends At',
    option: CmsDateTimeOption(optional: true),
  ),
  CmsUrlField(
    name: 'landingPageUrl',
    title: 'Landing Page Url',
    option: CmsUrlOption(optional: true),
  ),
  CmsImageField(
    name: 'bannerImage',
    title: 'Banner Image',
    option: CmsImageOption(hotspot: true),
  ),
  CmsFileField(
    name: 'termsDocument',
    title: 'Terms Document',
    option: CmsFileOption(optional: true),
  ),
  CmsBlockField(
    name: 'promoContent',
    title: 'Promo Content',
    option: CmsBlockOption(),
  ),
];

/// Generated document type spec for PromotionCampaign.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final promotionCampaignTypeSpec = DocumentTypeSpec<PromotionCampaign>(
  name: 'promotionCampaign',
  title: 'Promotion Campaign',
  description:
      'Time-bound marketing campaigns with discounts, banners, and promo codes',
  fields: promotionCampaignFields,
  defaultValue: PromotionCampaign.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class PromotionCampaignCmsConfig {
  PromotionCampaignCmsConfig({
    required this.title,
    required this.promoCode,
    required this.termsAndConditions,
    required this.discountPercent,
    required this.discountType,
    required this.applicableCategories,
    required this.isActive,
    required this.validFrom,
    required this.startsAt,
    required this.endsAt,
    required this.landingPageUrl,
    required this.bannerImage,
    required this.termsDocument,
    required this.promoContent,
  });

  final CmsData<String> title;

  final CmsData<String> promoCode;

  final CmsData<String> termsAndConditions;

  final CmsData<num> discountPercent;

  final CmsData<String> discountType;

  final CmsData<List<String>> applicableCategories;

  final CmsData<bool> isActive;

  final CmsData<DateTime?> validFrom;

  final CmsData<DateTime?> startsAt;

  final CmsData<DateTime?> endsAt;

  final CmsData<Uri?> landingPageUrl;

  final CmsData<ImageReference?> bannerImage;

  final CmsData<String?> termsDocument;

  final CmsData<Object?> promoContent;
}
