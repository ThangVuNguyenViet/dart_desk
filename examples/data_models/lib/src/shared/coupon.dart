import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'coupon.desk.dart';
part 'coupon.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@DeskModel(title: 'Coupon', description: 'Reward redeemable by the guest')
class Coupon with CouponMappable implements Serializable<Coupon> {
  @DeskString(description: 'Title', option: DeskStringOption())
  final String title;

  @DeskString(description: 'Code', option: DeskStringOption())
  final String code;

  @DeskNumber(description: 'Discount %', option: DeskNumberOption(min: 0, max: 100))
  final num discountPercent;

  @DeskDateTime(description: 'Expires at', option: DeskDateTimeOption())
  final DateTime expiresAt;

  @DeskImage(description: 'Artwork', option: DeskImageOption(hotspot: false))
  final ImageReference? image;

  @DeskMultiDropdown<String>(description: 'Tags', option: CouponTagsOption())
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

class CouponTagsOption extends DeskMultiDropdownOption<String> {
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
