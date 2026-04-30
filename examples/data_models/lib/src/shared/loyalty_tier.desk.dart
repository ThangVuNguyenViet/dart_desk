// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'loyalty_tier.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for LoyaltyTier
final loyaltyTierFields = [
  DeskStringField(name: 'name', title: 'Name', option: DeskStringOption()),
  DeskNumberField(
    name: 'threshold',
    title: 'Threshold',
    option: DeskNumberOption(min: 0),
  ),
  DeskColorField(
    name: 'tierColor',
    title: 'Tier Color',
    option: DeskColorOption(),
  ),
  DeskBlockField(
    name: 'perks',
    title: 'Perks',
    option: DeskBlockOption(optional: true),
  ),
];

/// Generated document type spec for LoyaltyTier.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final loyaltyTierTypeSpec = DocumentTypeSpec<LoyaltyTier>(
  name: 'loyaltyTier',
  title: 'Loyalty tier',
  description: 'A tier in the rewards program',
  fields: loyaltyTierFields,
  defaultValue: LoyaltyTier.defaultValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class LoyaltyTierDeskModel {
  LoyaltyTierDeskModel({
    required this.name,
    required this.threshold,
    required this.tierColor,
    required this.perks,
  });

  final DeskData<String> name;

  final DeskData<num> threshold;

  final DeskData<Color> tierColor;

  final DeskData<Object?> perks;
}
