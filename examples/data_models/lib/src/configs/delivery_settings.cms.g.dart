// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'delivery_settings.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for DeliverySettings
final deliverySettingsFields = [
  CmsStringField(
    name: 'zoneName',
    title: 'Zone Name',
    option: CmsStringOption(),
  ),
  CmsTextField(
    name: 'zoneDescription',
    title: 'Zone Description',
    option: CmsTextOption(rows: 2),
  ),
  CmsNumberField(
    name: 'minimumOrder',
    title: 'Minimum Order',
    option: CmsNumberOption(min: 0, max: 999),
  ),
  CmsNumberField(
    name: 'deliveryFee',
    title: 'Delivery Fee',
    option: CmsNumberOption(min: 0, max: 99),
  ),
  CmsNumberField(
    name: 'freeDeliveryThreshold',
    title: 'Free Delivery Threshold',
    option: CmsNumberOption(min: 0, max: 999),
  ),
  CmsNumberField(
    name: 'estimatedMinutes',
    title: 'Estimated Minutes',
    option: CmsNumberOption(min: 5, max: 120),
  ),
  CmsStringField(
    name: 'serviceHours',
    title: 'Service Hours',
    option: CmsStringOption(),
  ),
  CmsBooleanField(name: 'active', title: 'Active', option: CmsBooleanOption()),
  CmsUrlField(name: 'contactUrl', title: 'Contact Url', option: CmsUrlOption()),
  CmsDropdownField<String>(
    name: 'deliveryType',
    title: 'Delivery Type',
    option: DeliveryTypeDropdownOption(),
  ),
];

/// Generated document type spec for DeliverySettings.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final deliverySettingsTypeSpec = DocumentTypeSpec<DeliverySettings>(
  name: 'deliverySettings',
  title: 'Delivery Settings',
  description: 'Delivery zones, fees, and ordering configuration',
  fields: deliverySettingsFields,
  defaultValue: DeliverySettings.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class DeliverySettingsCmsConfig {
  DeliverySettingsCmsConfig({
    required this.zoneName,
    required this.zoneDescription,
    required this.minimumOrder,
    required this.deliveryFee,
    required this.freeDeliveryThreshold,
    required this.estimatedMinutes,
    required this.serviceHours,
    required this.active,
    required this.contactUrl,
    required this.deliveryType,
  });

  final CmsData<String> zoneName;

  final CmsData<String> zoneDescription;

  final CmsData<num> minimumOrder;

  final CmsData<num> deliveryFee;

  final CmsData<num> freeDeliveryThreshold;

  final CmsData<num> estimatedMinutes;

  final CmsData<String> serviceHours;

  final CmsData<bool> active;

  final CmsData<String?> contactUrl;

  final CmsData<String> deliveryType;
}
