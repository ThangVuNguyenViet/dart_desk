// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'loyalty_tier.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for LoyaltyTier
final loyaltyTierFields = [
  CmsStringField(name: 'name', title: 'Name', option: CmsStringOption()),
  CmsNumberField(
    name: 'threshold',
    title: 'Threshold',
    option: CmsNumberOption(min: 0),
  ),
  CmsColorField(
    name: 'tierColor',
    title: 'Tier Color',
    option: CmsColorOption(),
  ),
  CmsBlockField(name: 'perks', title: 'Perks', option: CmsBlockOption()),
];

/// Generated document type spec for LoyaltyTier.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final loyaltyTierTypeSpec = DocumentTypeSpec<LoyaltyTier>(
  name: 'loyaltyTier',
  title: 'Loyalty tier',
  description: 'A tier in the rewards program',
  fields: loyaltyTierFields,
  defaultValue: LoyaltyTier.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class LoyaltyTierCmsConfig {
  LoyaltyTierCmsConfig({
    required this.name,
    required this.threshold,
    required this.tierColor,
    required this.perks,
  });

  final CmsData<String> name;

  final CmsData<num> threshold;

  final CmsData<Color> tierColor;

  final CmsData<Object?> perks;
}
