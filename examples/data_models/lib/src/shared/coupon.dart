import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'coupon.cms.g.dart';
part 'coupon.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@CmsConfig(title: 'Coupon', description: 'Reward redeemable by the guest')
class Coupon with CouponMappable implements Serializable<Coupon> {
  @CmsStringFieldConfig(description: 'Title', option: CmsStringOption())
  final String title;

  @CmsStringFieldConfig(description: 'Code', option: CmsStringOption())
  final String code;

  @CmsNumberFieldConfig(description: 'Discount %', option: CmsNumberOption(min: 0, max: 100))
  final num discountPercent;

  @CmsDateTimeFieldConfig(description: 'Expires at', option: CmsDateTimeOption())
  final DateTime expiresAt;

  @CmsImageFieldConfig(description: 'Artwork', option: CmsImageOption(hotspot: false))
  final ImageReference? image;

  @CmsMultiDropdownFieldConfig<String>(description: 'Tags', option: CouponTagsOption())
  final List<String> tags;

  const Coupon({
    required this.title,
    required this.code,
    required this.discountPercent,
    required this.expiresAt,
    this.image,
    required this.tags,
  });

  static Coupon defaultValue = Coupon(
    title: 'House wine by the glass',
    code: 'AURA-WINE',
    discountPercent: 100,
    expiresAt: DateTime(2026, 6, 30),
    tags: const ['Drinks'],
  );

  static Coupon $fromMap(Map<String, dynamic> map) => CouponMapper.fromMap(map);
}

class CouponTagsOption extends CmsMultiDropdownOption<String> {
  const CouponTagsOption({super.hidden});
  @override
  List<String>? get defaultValues => const [];
  @override
  int? get maxSelected => null;
  @override
  int? get minSelected => null;
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final t in couponTags) DropdownOption(value: t, label: t),
      ];
  @override
  String? get placeholder => 'Tags';
}
