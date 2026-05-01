import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../configs/brand_theme.dart' show BrandThemeColorMapper;

part 'loyalty_tier.desk.dart';
part 'loyalty_tier.mapper.dart';

@MappableClass(includeCustomMappers: [BrandThemeColorMapper()])
@DeskModel(title: 'Loyalty tier', description: 'A tier in the rewards program')
class LoyaltyTier with LoyaltyTierMappable implements Serializable<LoyaltyTier> {
  @DeskString(description: 'Tier name', option: DeskStringOption())
  final String name;

  @DeskNumber(description: 'Points threshold', option: DeskNumberOption(min: 0))
  final num threshold;

  @DeskColor(description: 'Tier color', option: DeskColorOption())
  final Color tierColor;

  @DeskBlock(option: DeskBlockOption())
  final Object? perks;

  const LoyaltyTier({
    required this.name,
    required this.threshold,
    required this.tierColor,
    this.perks,
  });

  static LoyaltyTier initialValue = const LoyaltyTier(
    name: 'Cedar',
    threshold: 0,
    tierColor: Color(0xFF6B4E2E),
  );

  static LoyaltyTier $fromMap(Map<String, dynamic> map) => LoyaltyTierMapper.fromMap(map);
}
