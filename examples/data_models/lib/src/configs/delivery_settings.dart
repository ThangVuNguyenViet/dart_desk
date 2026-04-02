import 'dart:async';

import 'package:dart_desk/dart_desk.dart' show ImageReferenceMapper;
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

part 'delivery_settings.cms.g.dart';
part 'delivery_settings.mapper.dart';

@CmsConfig(
  title: 'Delivery Settings',
  description: 'Delivery zones, fees, and ordering configuration',
)
@MappableClass(
  ignoreNull: false,
  includeCustomMappers: [ImageReferenceMapper()],
)
class DeliverySettings
    with DeliverySettingsMappable, Serializable<DeliverySettings> {
  @CmsStringFieldConfig(
    description: 'Name of the delivery zone (e.g. Downtown, Suburbs)',
    option: CmsStringOption(),
  )
  final String zoneName;

  @CmsTextFieldConfig(
    description: 'Description of the area covered by this delivery zone',
    option: CmsTextOption(rows: 2),
  )
  final String zoneDescription;

  @CmsNumberFieldConfig(
    description: 'Minimum order value required for delivery in this zone',
    option: CmsNumberOption(min: 0, max: 999),
  )
  final num minimumOrder;

  @CmsNumberFieldConfig(
    description: 'Flat delivery fee charged for orders in this zone',
    option: CmsNumberOption(min: 0, max: 99),
  )
  final num deliveryFee;

  @CmsNumberFieldConfig(
    description: 'Order value above which delivery is free',
    option: CmsNumberOption(min: 0, max: 999),
  )
  final num freeDeliveryThreshold;

  @CmsNumberFieldConfig(
    description: 'Estimated delivery time in minutes',
    option: CmsNumberOption(min: 5, max: 120),
  )
  final num estimatedMinutes;

  @CmsStringFieldConfig(
    description: 'Hours during which delivery is available (e.g. 11am–9pm)',
    option: CmsStringOption(),
  )
  final String serviceHours;

  @CmsBooleanFieldConfig(
    description: 'Whether delivery is currently active for this zone',
    option: CmsBooleanOption(),
  )
  final bool active;

  @CmsUrlFieldConfig(
    description: 'URL for customers to contact support about delivery',
    option: CmsUrlOption(),
  )
  final String? contactUrl;

  @CmsDropdownFieldConfig<String>(
    description: 'Type of fulfillment service offered in this zone',
    option: DeliveryTypeDropdownOption(),
  )
  final String deliveryType;

  const DeliverySettings({
    required this.zoneName,
    required this.zoneDescription,
    required this.minimumOrder,
    required this.deliveryFee,
    required this.freeDeliveryThreshold,
    required this.estimatedMinutes,
    required this.serviceHours,
    required this.active,
    this.contactUrl,
    required this.deliveryType,
  });

  static DeliverySettings defaultValue = DeliverySettings(
    zoneName: 'Downtown',
    zoneDescription:
        'Covers the central business district and surrounding neighbourhoods within a 5 km radius.',
    minimumOrder: 15,
    deliveryFee: 3.99,
    freeDeliveryThreshold: 40,
    estimatedMinutes: 30,
    serviceHours: 'Mon–Sun 11:00 am – 9:00 pm',
    active: true,
    contactUrl: null,
    deliveryType: 'delivery',
  );
}

class DeliveryTypeDropdownOption extends CmsDropdownOption<String> {
  const DeliveryTypeDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'delivery';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        DropdownOption(value: 'delivery', label: 'Delivery'),
        DropdownOption(value: 'pickup', label: 'Pickup'),
        DropdownOption(value: 'both', label: 'Delivery & Pickup'),
      ]);

  @override
  String? get placeholder => 'Select a service type';
}
