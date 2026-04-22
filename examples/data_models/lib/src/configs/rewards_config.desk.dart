// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'rewards_config.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for RewardsConfig
final rewardsConfigFields = [
  DeskStringField(
    name: 'programName',
    title: 'Program Name',
    option: DeskStringOption(),
  ),
  DeskArrayField<LoyaltyTier>(
    name: 'tiers',
    title: 'Tiers',
    innerField: DeskObjectField(
      name: 'item',
      title: 'Loyalty Tier',
      option: DeskObjectOption(
        children: [ColumnFields(children: loyaltyTierFields)],
      ),
    ),
    fromMap: LoyaltyTier.$fromMap,
  ),
  DeskNumberField(
    name: 'currentUserPoints',
    title: 'Current User Points',
    option: DeskNumberOption(min: 0),
  ),
  DeskArrayField<Coupon>(
    name: 'coupons',
    title: 'Coupons',
    innerField: DeskObjectField(
      name: 'item',
      title: 'Coupon',
      option: DeskObjectOption(
        children: [ColumnFields(children: couponFields)],
      ),
    ),
    fromMap: Coupon.$fromMap,
  ),
  DeskUrlField(name: 'termsUrl', title: 'Terms Url', option: DeskUrlOption()),
  DeskBlockField(
    name: 'fineprint',
    title: 'Fineprint',
    option: DeskBlockOption(),
  ),
];

/// Generated document type spec for RewardsConfig.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final rewardsConfigTypeSpec = DocumentTypeSpec<RewardsConfig>(
  name: 'rewardsConfig',
  title: 'Rewards screen',
  description: 'Mobile loyalty card + coupons',
  fields: rewardsConfigFields,
  defaultValue: RewardsConfig.defaultValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class RewardsConfigDeskModel {
  RewardsConfigDeskModel({
    required this.programName,
    required this.tiers,
    required this.currentUserPoints,
    required this.coupons,
    required this.termsUrl,
    required this.fineprint,
  });

  final DeskData<String> programName;

  final DeskData<List<LoyaltyTier>> tiers;

  final DeskData<num> currentUserPoints;

  final DeskData<List<Coupon>> coupons;

  final DeskData<String> termsUrl;

  final DeskData<Object?> fineprint;
}
