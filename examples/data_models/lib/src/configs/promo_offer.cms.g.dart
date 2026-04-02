// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'promo_offer.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for PromoOffer
final promoOfferFields = [
  CmsStringField(name: 'title', title: 'Title', option: CmsStringOption()),
  CmsTextField(
    name: 'description',
    title: 'Description',
    option: CmsTextOption(rows: 2),
  ),
  CmsImageField(
    name: 'bannerImage',
    title: 'Banner Image',
    option: CmsImageOption(hotspot: false),
  ),
  CmsStringField(
    name: 'promoCode',
    title: 'Promo Code',
    option: CmsStringOption(),
  ),
  CmsNumberField(
    name: 'discountPercent',
    title: 'Discount Percent',
    option: CmsNumberOption(min: 0, max: 100),
  ),
  CmsDateTimeField(
    name: 'validFrom',
    title: 'Valid From',
    option: CmsDateTimeOption(),
  ),
  CmsDateTimeField(
    name: 'validUntil',
    title: 'Valid Until',
    option: CmsDateTimeOption(),
  ),
  CmsColorField(
    name: 'bannerColor',
    title: 'Banner Color',
    option: CmsColorOption(),
  ),
  CmsColorField(
    name: 'textColor',
    title: 'Text Color',
    option: CmsColorOption(),
  ),
  CmsDropdownField<String>(
    name: 'priority',
    title: 'Priority',
    option: PromoPriorityDropdownOption(),
  ),
  CmsUrlField(name: 'termsUrl', title: 'Terms Url', option: CmsUrlOption()),
  CmsBooleanField(name: 'active', title: 'Active', option: CmsBooleanOption()),
];

/// Generated document type spec for PromoOffer.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final promoOfferTypeSpec = DocumentTypeSpec<PromoOffer>(
  name: 'promoOffer',
  title: 'Promo Offer',
  description: 'Time-limited promotional offers and discount banners',
  fields: promoOfferFields,
  defaultValue: PromoOffer.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class PromoOfferCmsConfig {
  PromoOfferCmsConfig({
    required this.title,
    required this.description,
    required this.bannerImage,
    required this.promoCode,
    required this.discountPercent,
    required this.validFrom,
    required this.validUntil,
    required this.bannerColor,
    required this.textColor,
    required this.priority,
    required this.termsUrl,
    required this.active,
  });

  final CmsData<String> title;

  final CmsData<String> description;

  final CmsData<ImageReference?> bannerImage;

  final CmsData<String> promoCode;

  final CmsData<num> discountPercent;

  final CmsData<DateTime> validFrom;

  final CmsData<DateTime> validUntil;

  final CmsData<Color> bannerColor;

  final CmsData<Color> textColor;

  final CmsData<String> priority;

  final CmsData<String?> termsUrl;

  final CmsData<bool> active;
}
