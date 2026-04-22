// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'coupon.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for Coupon
final couponFields = [
  CmsStringField(name: 'title', title: 'Title', option: CmsStringOption()),
  CmsStringField(name: 'code', title: 'Code', option: CmsStringOption()),
  CmsNumberField(
    name: 'discountPercent',
    title: 'Discount Percent',
    option: CmsNumberOption(min: 0, max: 100),
  ),
  CmsDateTimeField(
    name: 'expiresAt',
    title: 'Expires At',
    option: CmsDateTimeOption(),
  ),
  CmsImageField(
    name: 'image',
    title: 'Image',
    option: CmsImageOption(hotspot: false),
  ),
  CmsMultiDropdownField<String>(
    name: 'tags',
    title: 'Tags',

    option: CouponTagsOption(),
  ),
];

/// Generated document type spec for Coupon.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final couponTypeSpec = DocumentTypeSpec<Coupon>(
  name: 'coupon',
  title: 'Coupon',
  description: 'Reward redeemable by the guest',
  fields: couponFields,
  defaultValue: Coupon.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class CouponCmsConfig {
  CouponCmsConfig({
    required this.title,
    required this.code,
    required this.discountPercent,
    required this.expiresAt,
    required this.image,
    required this.tags,
  });

  final CmsData<String> title;

  final CmsData<String> code;

  final CmsData<num> discountPercent;

  final CmsData<DateTime> expiresAt;

  final CmsData<ImageReference?> image;

  final CmsData<List<String>> tags;
}
