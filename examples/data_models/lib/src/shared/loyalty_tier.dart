import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../configs/brand_theme.dart' show BrandThemeColorMapper;

part 'loyalty_tier.cms.g.dart';
part 'loyalty_tier.mapper.dart';

@MappableClass(includeCustomMappers: [BrandThemeColorMapper()])
@CmsConfig(title: 'Loyalty tier', description: 'A tier in the rewards program')
class LoyaltyTier with LoyaltyTierMappable implements Serializable<LoyaltyTier> {
  @CmsStringFieldConfig(description: 'Tier name', option: CmsStringOption())
  final String name;

  @CmsNumberFieldConfig(description: 'Points threshold', option: CmsNumberOption(min: 0))
  final num threshold;

  @CmsColorFieldConfig(description: 'Tier color', option: CmsColorOption())
  final Color tierColor;

  @CmsBlockFieldConfig(option: CmsBlockOption())
  final Object? perks;

  const LoyaltyTier({
    required this.name,
    required this.threshold,
    required this.tierColor,
    this.perks,
  });

  static LoyaltyTier defaultValue = const LoyaltyTier(
    name: 'Cedar',
    threshold: 0,
    tierColor: Color(0xFF6B4E2E),
  );

  static LoyaltyTier $fromMap(Map<String, dynamic> map) => LoyaltyTierMapper.fromMap(map);
}
