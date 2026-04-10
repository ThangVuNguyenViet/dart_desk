// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'restaurant_profile.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for OperatingHour
final operatingHourFields = [
  CmsDropdownField<String>(
    name: 'day',
    title: 'Day',

    option: DayOfWeekDropdownOption(),
  ),
  CmsStringField(
    name: 'openTime',
    title: 'Open Time',
    option: CmsStringOption(),
  ),
  CmsStringField(
    name: 'closeTime',
    title: 'Close Time',
    option: CmsStringOption(),
  ),
  CmsBooleanField(name: 'isClosed', title: 'Is Closed'),
];

/// Generated document type spec for OperatingHour.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final operatingHourTypeSpec = DocumentTypeSpec<OperatingHour>(
  name: 'operatingHour',
  title: 'Operating Hour',
  description: 'A single day operating schedule',
  fields: operatingHourFields,
  defaultValue: OperatingHour.defaultValue,
);

/// Generated CmsField list for RestaurantProfile
final restaurantProfileFields = [
  CmsStringField(name: 'name', title: 'Name', option: CmsStringOption()),
  CmsStringField(name: 'slug', title: 'Slug', option: CmsStringOption()),
  CmsTextField(
    name: 'description',
    title: 'Description',
    option: CmsTextOption(rows: 4),
  ),
  CmsBooleanField(name: 'isActive', title: 'Is Active'),
  CmsCheckboxField(
    name: 'acceptsOnlineOrders',
    title: 'Accepts Online Orders',
    option: CmsCheckboxOption(label: 'Accepts online orders'),
  ),
  CmsDropdownField<String>(
    name: 'cuisineType',
    title: 'Cuisine Type',

    option: CuisineTypeDropdownOption(),
  ),
  CmsMultiDropdownField<String>(
    name: 'paymentMethods',
    title: 'Payment Methods',

    option: PaymentMethodsDropdownOption(),
  ),
  CmsUrlField(
    name: 'website',
    title: 'Website',
    option: CmsUrlOption(optional: true),
  ),
  CmsUrlField(
    name: 'orderingUrl',
    title: 'Ordering Url',
    option: CmsUrlOption(optional: true),
  ),
  CmsDateField(
    name: 'openingSince',
    title: 'Opening Since',
    option: CmsDateOption(optional: true),
  ),
  CmsImageField(
    name: 'logo',
    title: 'Logo',
    option: CmsImageOption(hotspot: false),
  ),
  CmsImageField(
    name: 'coverPhoto',
    title: 'Cover Photo',
    option: CmsImageOption(hotspot: true),
  ),
  CmsFileField(
    name: 'pdfMenu',
    title: 'Pdf Menu',
    option: CmsFileOption(optional: true),
  ),
  CmsObjectField(
    name: 'address',
    title: 'Address',
    fromMap: Address.$fromMap,
    option: CmsObjectOption(children: [ColumnFields(children: addressFields)]),
  ),
  CmsObjectField(
    name: 'contactInfo',
    title: 'Contact Info',
    fromMap: ContactInfo.$fromMap,
    option: CmsObjectOption(
      children: [ColumnFields(children: contactInfoFields)],
    ),
  ),
  CmsArrayField<OperatingHour>(
    name: 'operatingHours',
    title: 'Operating Hours',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Operating Hour',
      option: CmsObjectOption(
        children: [ColumnFields(children: operatingHourFields)],
      ),
    ),
    fromMap: OperatingHour.$fromMap,
  ),
];

/// Generated CmsField list for Address
final addressFields = [
  CmsStringField(name: 'street', title: 'Street'),
  CmsStringField(name: 'city', title: 'City'),
  CmsStringField(name: 'state', title: 'State'),
  CmsStringField(name: 'zipCode', title: 'Zip Code'),
];

/// Generated CmsField list for ContactInfo
final contactInfoFields = [
  CmsStringField(name: 'phone', title: 'Phone'),
  CmsStringField(name: 'email', title: 'Email'),
];

/// Generated document type spec for RestaurantProfile.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final restaurantProfileTypeSpec = DocumentTypeSpec<RestaurantProfile>(
  name: 'restaurantProfile',
  title: 'Restaurant Profile',
  description: 'Store identity, location, hours, and contact information',
  fields: restaurantProfileFields,
  defaultValue: RestaurantProfile.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class OperatingHourCmsConfig {
  OperatingHourCmsConfig({
    required this.day,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  final CmsData<String> day;

  final CmsData<String> openTime;

  final CmsData<String> closeTime;

  final CmsData<bool> isClosed;
}

class RestaurantProfileCmsConfig {
  RestaurantProfileCmsConfig({
    required this.name,
    required this.slug,
    required this.description,
    required this.isActive,
    required this.acceptsOnlineOrders,
    required this.cuisineType,
    required this.paymentMethods,
    required this.website,
    required this.orderingUrl,
    required this.openingSince,
    required this.logo,
    required this.coverPhoto,
    required this.pdfMenu,
    required this.address,
    required this.contactInfo,
    required this.operatingHours,
  });

  final CmsData<String> name;

  final CmsData<String> slug;

  final CmsData<String> description;

  final CmsData<bool> isActive;

  final CmsData<bool> acceptsOnlineOrders;

  final CmsData<String> cuisineType;

  final CmsData<List<String>> paymentMethods;

  final CmsData<Uri?> website;

  final CmsData<Uri?> orderingUrl;

  final CmsData<DateTime?> openingSince;

  final CmsData<ImageReference?> logo;

  final CmsData<ImageReference?> coverPhoto;

  final CmsData<String?> pdfMenu;

  final CmsData<Address> address;

  final CmsData<ContactInfo> contactInfo;

  final CmsData<List<OperatingHour>> operatingHours;
}
