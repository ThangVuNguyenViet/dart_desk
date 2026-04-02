// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'reward_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for RewardConfig
final rewardConfigFields = [
  CmsStringField(
    name: 'brandName',
    title: 'Brand Name',
    option: CmsStringOption(),
  ),
  CmsNumberField(
    name: 'pointsBalance',
    title: 'Points Balance',
    option: CmsNumberOption(min: 0, max: 100000),
  ),
  CmsNumberField(
    name: 'nextRewardThreshold',
    title: 'Next Reward Threshold',
    option: CmsNumberOption(min: 0, max: 100000),
  ),
  CmsStringField(
    name: 'rewardLabel',
    title: 'Reward Label',
    option: CmsStringOption(),
  ),
  CmsMultiDropdownField<String>(
    name: 'coupons',
    title: 'Coupons',
    option: CouponsDropdownOption(),
  ),
];

/// Generated document type spec for RewardConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final rewardConfigTypeSpec = DocumentTypeSpec<RewardConfig>(
  name: 'rewardConfig',
  title: 'Reward Screen',
  description: 'Mobile loyalty rewards with points card and coupon list',
  fields: rewardConfigFields,
  defaultValue: RewardConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class RewardConfigCmsConfig {
  RewardConfigCmsConfig({
    required this.brandName,
    required this.pointsBalance,
    required this.nextRewardThreshold,
    required this.rewardLabel,
    required this.coupons,
  });

  final CmsData<String> brandName;

  final CmsData<num> pointsBalance;

  final CmsData<num> nextRewardThreshold;

  final CmsData<String> rewardLabel;

  final CmsData<List<String>> coupons;
}
