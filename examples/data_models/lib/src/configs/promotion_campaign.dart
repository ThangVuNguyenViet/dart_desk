import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';
import 'cms_content.dart';

part 'promotion_campaign.cms.g.dart';
part 'promotion_campaign.mapper.dart';

@CmsConfig(
  title: 'Promotion Campaign',
  description:
      'Time-bound marketing campaigns with discounts, banners, and promo codes',
)
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'promotionCampaign',
  includeCustomMappers: [PromotionColorMapper(), ImageReferenceMapper()],
)
class PromotionCampaign extends CmsContent
    with PromotionCampaignMappable, Serializable<PromotionCampaign> {
  @CmsStringFieldConfig(
    description: 'Campaign title',
    option: CmsStringOption(),
  )
  final String title;

  @CmsStringFieldConfig(
    description: 'Promo code (e.g. SUMMER20)',
    option: CmsStringOption(),
  )
  final String promoCode;

  @CmsTextFieldConfig(
    description: 'Terms and conditions',
    option: CmsTextOption(rows: 3),
  )
  final String termsAndConditions;

  @CmsNumberFieldConfig(
    description: 'Discount percentage',
    option: CmsNumberOption(min: 0, max: 100),
  )
  final num discountPercent;

  @CmsDropdownFieldConfig<String>(
    description: 'Type of discount',
    option: DiscountTypeDropdownOption(),
  )
  final String discountType;

  @CmsMultiDropdownFieldConfig<String>(
    description: 'Menu categories this promotion applies to',
    option: ApplicableCategoriesDropdownOption(),
  )
  final List<String> applicableCategories;

  @CmsBooleanFieldConfig(description: 'Is this campaign currently active?')
  final bool isActive;

  @CmsDateFieldConfig(
    description: 'Date from which the promo code is valid',
    option: CmsDateOption(optional: true),
  )
  final DateTime? validFrom;

  @CmsDateTimeFieldConfig(
    description: 'Exact start time of the campaign',
    option: CmsDateTimeOption(optional: true),
  )
  final DateTime? startsAt;

  @CmsDateTimeFieldConfig(
    description: 'Exact end time of the campaign',
    option: CmsDateTimeOption(optional: true),
  )
  final DateTime? endsAt;

  @CmsUrlFieldConfig(
    description: 'External landing page for the campaign',
    option: CmsUrlOption(optional: true),
  )
  final Uri? landingPageUrl;

  @CmsImageFieldConfig(
    description: 'Promotional banner image',
    option: CmsImageOption(hotspot: true),
  )
  final ImageReference? bannerImage;

  @CmsFileFieldConfig(
    description: 'Terms and conditions PDF',
    option: CmsFileOption(optional: true),
  )
  final String? termsDocument;

  @CmsBlockFieldConfig(option: CmsBlockOption())
  final Object? promoContent;

  const PromotionCampaign({
    required this.title,
    required this.promoCode,
    required this.termsAndConditions,
    required this.discountPercent,
    required this.discountType,
    required this.applicableCategories,
    required this.isActive,
    this.validFrom,
    this.startsAt,
    this.endsAt,
    this.landingPageUrl,
    this.bannerImage,
    this.termsDocument,
    this.promoContent,
  });

  static PromotionCampaign defaultValue = PromotionCampaign(
    title: 'Summer Festival',
    promoCode: 'SUMMER20',
    termsAndConditions:
        'Valid for dine-in and takeaway orders. Cannot be combined with other offers. '
        'Management reserves the right to modify or cancel this promotion.',
    discountPercent: 20,
    discountType: 'Percentage',
    applicableCategories: ['Main', 'Appetizer'],
    isActive: true,
    validFrom: DateTime(2026, 6, 1),
    startsAt: DateTime(2026, 6, 1, 10, 0),
    endsAt: DateTime(2026, 8, 31, 23, 59),
    landingPageUrl: Uri.parse('https://auragastronomy.com/summer'),
    bannerImage: null,
    termsDocument: null,
    promoContent: null,
  );
}

class PromotionColorMapper extends SimpleMapper<Color> {
  const PromotionColorMapper();

  @override
  Color decode(Object value) {
    if (value is String) {
      final hex = value.replaceFirst('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    }
    throw Exception('Cannot decode Color from $value');
  }

  @override
  Object? encode(Color self) =>
      '#${self.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

class DiscountTypeDropdownOption extends CmsDropdownOption<String> {
  const DiscountTypeDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'Percentage';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
    for (final d in discountTypes) DropdownOption(value: d, label: d),
  ];

  @override
  String? get placeholder => 'Select discount type';
}

class ApplicableCategoriesDropdownOption
    extends CmsMultiDropdownOption<String> {
  const ApplicableCategoriesDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues => ['Main', 'Appetizer'];

  @override
  int? get maxSelected => null;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
    DropdownOption(value: 'All', label: 'All Categories'),
    for (final c in menuCategories) DropdownOption(value: c, label: c),
  ];

  @override
  String? get placeholder => 'Select applicable categories';
}
