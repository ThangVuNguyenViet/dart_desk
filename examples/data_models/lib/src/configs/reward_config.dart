import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';

part 'reward_config.cms.g.dart';
part 'reward_config.mapper.dart';

@CmsConfig(
  title: 'Reward Screen',
  description: 'Mobile loyalty rewards with points card and coupon list',
)
@MappableClass(ignoreNull: false, includeCustomMappers: [RewardColorMapper()])
class RewardConfig with RewardConfigMappable, Serializable<RewardConfig> {
  @CmsStringFieldConfig(
    description: 'Brand name shown in the header',
    option: CmsStringOption(),
  )
  final String brandName;

  @CmsNumberFieldConfig(
    description: 'Current loyalty points balance',
    option: CmsNumberOption(min: 0, max: 100000),
  )
  final num pointsBalance;

  @CmsNumberFieldConfig(
    description: 'Points needed for the next reward',
    option: CmsNumberOption(min: 0, max: 100000),
  )
  final num nextRewardThreshold;

  @CmsStringFieldConfig(
    description: 'Label for the next reward (e.g. Festive Tasting Menu)',
    option: CmsStringOption(),
  )
  final String rewardLabel;

  @CmsMultiDropdownFieldConfig<String>(
    description: 'Coupons to display in the rewards screen',
    option: CouponsDropdownOption(),
  )
  final List<String> coupons;

  const RewardConfig({
    required this.brandName,
    required this.pointsBalance,
    required this.nextRewardThreshold,
    required this.rewardLabel,
    required this.coupons,
  });

  static RewardConfig defaultValue = RewardConfig(
    brandName: 'Aura Gastronomy',
    pointsBalance: 2450,
    nextRewardThreshold: 3000,
    rewardLabel: 'Festive Tasting Menu',
    coupons: ['festive_mains', 'free_drink', 'dessert_platter'],
  );
}

class RewardColorMapper extends SimpleMapper<Color> {
  const RewardColorMapper();

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

class CouponsDropdownOption extends CmsMultiDropdownOption<String> {
  const CouponsDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues =>
      ['festive_mains', 'free_drink', 'dessert_platter'];

  @override
  int? get maxSelected => 3;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final c in seedCoupons)
          DropdownOption(value: c.key, label: c.title),
      ]);

  @override
  String? get placeholder => 'Select coupons';
}
