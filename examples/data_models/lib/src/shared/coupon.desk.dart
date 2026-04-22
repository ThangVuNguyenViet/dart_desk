// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'coupon.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for Coupon
final couponFields = [
  DeskStringField(name: 'title', title: 'Title', option: DeskStringOption()),
  DeskStringField(name: 'code', title: 'Code', option: DeskStringOption()),
  DeskNumberField(
    name: 'discountPercent',
    title: 'Discount Percent',
    option: DeskNumberOption(min: 0, max: 100),
  ),
  DeskDateTimeField(
    name: 'expiresAt',
    title: 'Expires At',
    option: DeskDateTimeOption(),
  ),
  DeskImageField(
    name: 'image',
    title: 'Image',
    option: DeskImageOption(hotspot: false),
  ),
  DeskMultiDropdownField<String>(
    name: 'tags',
    title: 'Tags',

    option: CouponTagsOption(),
  ),
];

/// Generated document type spec for Coupon.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final couponTypeSpec = DocumentTypeSpec<Coupon>(
  name: 'coupon',
  title: 'Coupon',
  description: 'Reward redeemable by the guest',
  fields: couponFields,
  defaultValue: Coupon.defaultValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class CouponDeskModel {
  CouponDeskModel({
    required this.title,
    required this.code,
    required this.discountPercent,
    required this.expiresAt,
    required this.image,
    required this.tags,
  });

  final DeskData<String> title;

  final DeskData<String> code;

  final DeskData<num> discountPercent;

  final DeskData<DateTime> expiresAt;

  final DeskData<ImageReference?> image;

  final DeskData<List<String>> tags;
}
