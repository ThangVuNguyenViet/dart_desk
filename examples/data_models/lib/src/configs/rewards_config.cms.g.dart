// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'rewards_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for RewardsConfig
final rewardsConfigFields = [
  CmsStringField(
    name: 'programName',
    title: 'Program Name',
    option: CmsStringOption(),
  ),
  CmsArrayField<LoyaltyTier>(
    name: 'tiers',
    title: 'Tiers',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Loyalty Tier',
      option: CmsObjectOption(
        children: [ColumnFields(children: loyaltyTierFields)],
      ),
    ),
    fromMap: LoyaltyTier.$fromMap,
  ),
  CmsNumberField(
    name: 'currentUserPoints',
    title: 'Current User Points',
    option: CmsNumberOption(min: 0),
  ),
  CmsArrayField<Coupon>(
    name: 'coupons',
    title: 'Coupons',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Coupon',
      option: CmsObjectOption(children: [ColumnFields(children: couponFields)]),
    ),
    fromMap: Coupon.$fromMap,
  ),
  CmsUrlField(name: 'termsUrl', title: 'Terms Url', option: CmsUrlOption()),
  CmsBlockField(
    name: 'fineprint',
    title: 'Fineprint',
    option: CmsBlockOption(),
  ),
];

/// Generated document type spec for RewardsConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final rewardsConfigTypeSpec = DocumentTypeSpec<RewardsConfig>(
  name: 'rewardsConfig',
  title: 'Rewards screen',
  description: 'Mobile loyalty card + coupons',
  fields: rewardsConfigFields,
  defaultValue: RewardsConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class RewardsConfigCmsConfig {
  RewardsConfigCmsConfig({
    required this.programName,
    required this.tiers,
    required this.currentUserPoints,
    required this.coupons,
    required this.termsUrl,
    required this.fineprint,
  });

  final CmsData<String> programName;

  final CmsData<List<LoyaltyTier>> tiers;

  final CmsData<num> currentUserPoints;

  final CmsData<List<Coupon>> coupons;

  final CmsData<String> termsUrl;

  final CmsData<Object?> fineprint;
}
