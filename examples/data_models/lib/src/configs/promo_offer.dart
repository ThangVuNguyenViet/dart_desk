import 'dart:async';

import 'package:dart_desk/dart_desk.dart'
    show ImageReferenceMapper, ImageReference;
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

part 'promo_offer.cms.g.dart';
part 'promo_offer.mapper.dart';

@CmsConfig(
  title: 'Promo Offer',
  description: 'Time-limited promotional offers and discount banners',
)
@MappableClass(
  ignoreNull: false,
  includeCustomMappers: [ColorMapper(), ImageReferenceMapper()],
)
class PromoOffer with PromoOfferMappable, Serializable<PromoOffer> {
  @CmsStringFieldConfig(
    description: 'Headline title of the promotional offer',
    option: CmsStringOption(),
  )
  final String title;

  @CmsTextFieldConfig(
    description: 'Short description of the offer shown on the banner',
    option: CmsTextOption(rows: 2),
  )
  final String description;

  @CmsImageFieldConfig(
    description: 'Banner image for the promotional offer',
    option: CmsImageOption(hotspot: false),
  )
  final ImageReference? bannerImage;

  @CmsStringFieldConfig(
    description: 'Promotional code customers enter at checkout',
    option: CmsStringOption(),
  )
  final String promoCode;

  @CmsNumberFieldConfig(
    description: 'Discount percentage applied with this promo code',
    option: CmsNumberOption(min: 0, max: 100),
  )
  final num discountPercent;

  @CmsDateTimeFieldConfig(
    description: 'Date and time when the promotion starts',
    option: CmsDateTimeOption(),
  )
  final DateTime validFrom;

  @CmsDateTimeFieldConfig(
    description: 'Date and time when the promotion expires',
    option: CmsDateTimeOption(),
  )
  final DateTime validUntil;

  @CmsColorFieldConfig(
    description: 'Background color of the promotional banner',
    option: CmsColorOption(),
  )
  final Color bannerColor;

  @CmsColorFieldConfig(
    description: 'Text color used on the promotional banner',
    option: CmsColorOption(),
  )
  final Color textColor;

  @CmsDropdownFieldConfig<String>(
    description: 'Display priority of this offer relative to others',
    option: PromoPriorityDropdownOption(),
  )
  final String priority;

  @CmsUrlFieldConfig(
    description: 'URL to the full terms and conditions for this offer',
    option: CmsUrlOption(),
  )
  final String? termsUrl;

  @CmsBooleanFieldConfig(
    description: 'Whether this promotion is currently active',
    option: CmsBooleanOption(),
  )
  final bool active;

  const PromoOffer({
    required this.title,
    required this.description,
    this.bannerImage,
    required this.promoCode,
    required this.discountPercent,
    required this.validFrom,
    required this.validUntil,
    required this.bannerColor,
    required this.textColor,
    required this.priority,
    this.termsUrl,
    required this.active,
  });

  static PromoOffer defaultValue = PromoOffer(
    title: 'Weekend Special',
    description:
        'Enjoy 20% off your entire order every weekend. Use code WEEKEND20 at checkout.',
    bannerImage: null,
    promoCode: 'WEEKEND20',
    discountPercent: 20,
    validFrom: DateTime(2025, 1, 1),
    validUntil: DateTime(2025, 12, 31),
    bannerColor: const Color(0xFFD4451A),
    textColor: const Color(0xFFFFFFFF),
    priority: 'high',
    termsUrl: null,
    active: true,
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

class PromoPriorityDropdownOption extends CmsDropdownOption<String> {
  const PromoPriorityDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'normal';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        DropdownOption(value: 'low', label: 'Low'),
        DropdownOption(value: 'normal', label: 'Normal'),
        DropdownOption(value: 'high', label: 'High'),
      ]);

  @override
  String? get placeholder => 'Select a priority';
}
