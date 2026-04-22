import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/aura_assets.dart';
import '../seed/aura_copy.dart';
import '../shared/coupon.dart';
import '../shared/loyalty_tier.dart';
import 'brand_theme.dart' show BrandThemeColorMapper;
import 'desk_content.dart';

part 'rewards_config.desk.dart';
part 'rewards_config.mapper.dart';

@DeskModel(title: 'Rewards screen', description: 'Mobile loyalty card + coupons')
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'rewardsConfig',
  includeCustomMappers: [ImageReferenceMapper(), BrandThemeColorMapper()],
)
class RewardsConfig extends DeskContent with RewardsConfigMappable, Serializable<RewardsConfig> {
  @DeskString(description: 'Program name', option: DeskStringOption())
  final String programName;

  @DeskArray<LoyaltyTier>(description: 'Tiers')
  final List<LoyaltyTier> tiers;

  @DeskNumber(description: 'Current user points (demo)', option: DeskNumberOption(min: 0))
  final num currentUserPoints;

  @DeskArray<Coupon>(description: 'Available coupons')
  final List<Coupon> coupons;

  @DeskUrl(description: 'Terms URL', option: DeskUrlOption())
  final String termsUrl;

  @DeskBlock(option: DeskBlockOption())
  final Object? fineprint;

  const RewardsConfig({
    required this.programName,
    required this.tiers,
    required this.currentUserPoints,
    required this.coupons,
    required this.termsUrl,
    this.fineprint,
  });

  static RewardsConfig defaultValue = RewardsConfig(
    programName: AuraCopy.rewardsProgram,
    tiers: const [
      LoyaltyTier(name: 'Cedar',   threshold: 0,    tierColor: Color(0xFF6B4E2E)),
      LoyaltyTier(name: 'Oakwood', threshold: 500,  tierColor: Color(0xFF496455)),
      LoyaltyTier(name: 'Aurelia', threshold: 1500, tierColor: Color(0xFFC67A4A)),
    ],
    currentUserPoints: 412,
    coupons: [
      Coupon(
        title: 'House wine by the glass',
        code: 'AURA-WINE',
        discountPercent: 100,
        expiresAt: DateTime(2026, 6, 30),
        image: const ImageReference(externalUrl: AuraAssets.wine),
        tags: const ['Drinks'],
      ),
      Coupon(
        title: 'Olive oil cake on the house',
        code: 'AURA-CAKE',
        discountPercent: 100,
        expiresAt: DateTime(2026, 5, 31),
        image: const ImageReference(externalUrl: AuraAssets.dish5),
        tags: const ['Dessert'],
      ),
      Coupon(
        title: 'Birthday prix fixe',
        code: 'AURA-BDAY',
        discountPercent: 25,
        expiresAt: DateTime(2026, 12, 31),
        image: const ImageReference(externalUrl: AuraAssets.heroDusk),
        tags: const ['Birthday', 'Food'],
      ),
    ],
    termsUrl: AuraCopy.rewardsTerms,
  );
}
