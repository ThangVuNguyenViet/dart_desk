import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';
import 'cms_content.dart';

part 'restaurant_profile.cms.g.dart';
part 'restaurant_profile.mapper.dart';

// ── Nested types ──────────────────────────────────────────────────────────

@MappableClass()
class Address with AddressMappable {
  final String street;
  final String city;
  final String state;
  final String zipCode;

  const Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  static Address defaultValue = const Address(
    street: '123 Culinary Ave',
    city: 'San Francisco',
    state: 'CA',
    zipCode: '94102',
  );

  static Address $fromMap(Map<String, dynamic> map) =>
      AddressMapper.fromMap(map);
}

@MappableClass()
class ContactInfo with ContactInfoMappable {
  final String phone;
  final String email;

  const ContactInfo({required this.phone, required this.email});

  static ContactInfo defaultValue = const ContactInfo(
    phone: '(415) 555-0192',
    email: 'hello@auragastronomy.com',
  );

  static ContactInfo $fromMap(Map<String, dynamic> map) =>
      ContactInfoMapper.fromMap(map);
}

@MappableClass()
@CmsConfig(
  title: 'Operating Hour',
  description: 'A single day operating schedule',
)
class OperatingHour
    with OperatingHourMappable
    implements Serializable<OperatingHour> {
  @CmsDropdownFieldConfig<String>(
    description: 'Day of the week',
    option: DayOfWeekDropdownOption(),
  )
  final String day;

  @CmsStringFieldConfig(
    description: 'Opening time (e.g. 09:00)',
    option: CmsStringOption(),
  )
  final String openTime;

  @CmsStringFieldConfig(
    description: 'Closing time (e.g. 22:00)',
    option: CmsStringOption(),
  )
  final String closeTime;

  @CmsBooleanFieldConfig(description: 'Is the restaurant closed on this day?')
  final bool isClosed;

  const OperatingHour({
    required this.day,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  static OperatingHour defaultValue = const OperatingHour(
    day: 'Monday',
    openTime: '09:00',
    closeTime: '22:00',
    isClosed: false,
  );

  static OperatingHour $fromMap(Map<String, dynamic> map) =>
      OperatingHourMapper.fromMap(map);
}

// ── Main config ───────────────────────────────────────────────────────────

@CmsConfig(
  title: 'Restaurant Profile',
  description: 'Store identity, location, hours, and contact information',
)
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'restaurantProfile',
  includeCustomMappers: [
    UriMapper(),
    RestaurantProfileColorMapper(),
    ImageReferenceMapper(),
  ],
)
class RestaurantProfile extends CmsContent
    with RestaurantProfileMappable, Serializable<RestaurantProfile> {
  @CmsStringFieldConfig(
    description: 'Restaurant display name',
    option: CmsStringOption(),
  )
  final String name;

  @CmsStringFieldConfig(
    description: 'URL-safe identifier',
    option: CmsStringOption(),
  )
  final String slug;

  @CmsTextFieldConfig(
    description: 'About us description',
    option: CmsTextOption(rows: 4),
  )
  final String description;

  @CmsBooleanFieldConfig(description: 'Is this store currently active?')
  final bool isActive;

  @CmsCheckboxFieldConfig(
    description: 'Does this location accept online orders?',
    option: CmsCheckboxOption(label: 'Accepts online orders'),
  )
  final bool acceptsOnlineOrders;

  @CmsDropdownFieldConfig<String>(
    description: 'Primary cuisine type',
    option: CuisineTypeDropdownOption(),
  )
  final String cuisineType;

  @CmsMultiDropdownFieldConfig<String>(
    description: 'Accepted payment methods',
    option: PaymentMethodsDropdownOption(),
  )
  final List<String> paymentMethods;

  @CmsUrlFieldConfig(
    description: 'Restaurant website',
    option: CmsUrlOption(optional: true),
  )
  final Uri? website;

  @CmsUrlFieldConfig(
    description: 'Online ordering link',
    option: CmsUrlOption(optional: true),
  )
  final Uri? orderingUrl;

  @CmsDateFieldConfig(
    description: 'Established date',
    option: CmsDateOption(optional: true),
  )
  final DateTime? openingSince;

  @CmsImageFieldConfig(
    description: 'Square logo',
    option: CmsImageOption(hotspot: false),
  )
  final ImageReference? logo;

  @CmsImageFieldConfig(
    description: 'Cover photo / hero banner',
    option: CmsImageOption(hotspot: true),
  )
  final ImageReference? coverPhoto;

  @CmsFileFieldConfig(
    description: 'Downloadable PDF menu',
    option: CmsFileOption(optional: true),
  )
  final String? pdfMenu;

  @CmsObjectFieldConfig(description: 'Street address')
  final Address address;

  @CmsObjectFieldConfig(description: 'Contact information')
  final ContactInfo contactInfo;

  @CmsArrayFieldConfig<OperatingHour>(description: 'Weekly operating hours')
  final List<OperatingHour> operatingHours;

  const RestaurantProfile({
    required this.name,
    required this.slug,
    required this.description,
    required this.isActive,
    required this.acceptsOnlineOrders,
    required this.cuisineType,
    required this.paymentMethods,
    this.website,
    this.orderingUrl,
    this.openingSince,
    this.logo,
    this.coverPhoto,
    this.pdfMenu,
    required this.address,
    required this.contactInfo,
    required this.operatingHours,
  });

  static RestaurantProfile defaultValue = RestaurantProfile(
    name: 'Aura Gastronomy',
    slug: 'aura-gastronomy',
    description:
        'A modern fine dining experience blending seasonal ingredients with innovative techniques. '
        'Our menu celebrates the art of culinary craft.',
    isActive: true,
    acceptsOnlineOrders: true,
    cuisineType: 'Mediterranean',
    paymentMethods: ['Credit Card', 'Apple Pay', 'Google Pay'],
    website: Uri.parse('https://auragastronomy.com'),
    orderingUrl: Uri.parse('https://order.auragastronomy.com'),
    openingSince: DateTime(2019, 6, 15),
    logo: null,
    coverPhoto: null,
    pdfMenu: null,
    address: Address.defaultValue,
    contactInfo: ContactInfo.defaultValue,
    operatingHours: [
      const OperatingHour(
        day: 'Monday',
        openTime: '11:00',
        closeTime: '22:00',
        isClosed: false,
      ),
      const OperatingHour(
        day: 'Tuesday',
        openTime: '11:00',
        closeTime: '22:00',
        isClosed: false,
      ),
      const OperatingHour(
        day: 'Wednesday',
        openTime: '11:00',
        closeTime: '22:00',
        isClosed: false,
      ),
      const OperatingHour(
        day: 'Thursday',
        openTime: '11:00',
        closeTime: '23:00',
        isClosed: false,
      ),
      const OperatingHour(
        day: 'Friday',
        openTime: '11:00',
        closeTime: '23:00',
        isClosed: false,
      ),
      const OperatingHour(
        day: 'Saturday',
        openTime: '10:00',
        closeTime: '23:00',
        isClosed: false,
      ),
      const OperatingHour(
        day: 'Sunday',
        openTime: '10:00',
        closeTime: '21:00',
        isClosed: false,
      ),
    ],
  );
}

class UriMapper extends SimpleMapper<Uri> {
  const UriMapper();

  @override
  Uri decode(Object value) => Uri.parse(value as String);

  @override
  Object? encode(Uri self) => self.toString();
}

class RestaurantProfileColorMapper extends SimpleMapper<Color> {
  const RestaurantProfileColorMapper();

  @override
  Color decode(Object value) {
    if (value is String) {
      final hex = value.replaceFirst('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    }
    throw Exception('Cannot decode Color from $value');
  }

  @override
  Object? encode(Color self) =>
      '#${self.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

class CuisineTypeDropdownOption extends CmsDropdownOption<String> {
  const CuisineTypeDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'Mediterranean';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
    for (final c in cuisineTypes) DropdownOption(value: c, label: c),
  ];

  @override
  String? get placeholder => 'Select cuisine type';
}

class PaymentMethodsDropdownOption extends CmsMultiDropdownOption<String> {
  const PaymentMethodsDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues => ['Credit Card', 'Apple Pay', 'Google Pay'];

  @override
  int? get maxSelected => null;

  @override
  int? get minSelected => 1;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
    for (final p in paymentMethods) DropdownOption(value: p, label: p),
  ];

  @override
  String? get placeholder => 'Select payment methods';
}

class DayOfWeekDropdownOption extends CmsDropdownOption<String> {
  const DayOfWeekDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'Monday';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
    for (final d in daysOfWeek) DropdownOption(value: d, label: d),
  ];

  @override
  String? get placeholder => 'Select day';
}
