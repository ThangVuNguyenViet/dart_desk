// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'restaurant_profile.dart';

class AddressMapper extends ClassMapperBase<Address> {
  AddressMapper._();

  static AddressMapper? _instance;
  static AddressMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AddressMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Address';

  static String _$street(Address v) => v.street;
  static const Field<Address, String> _f$street = Field('street', _$street);
  static String _$city(Address v) => v.city;
  static const Field<Address, String> _f$city = Field('city', _$city);
  static String _$state(Address v) => v.state;
  static const Field<Address, String> _f$state = Field('state', _$state);
  static String _$zipCode(Address v) => v.zipCode;
  static const Field<Address, String> _f$zipCode = Field('zipCode', _$zipCode);

  @override
  final MappableFields<Address> fields = const {
    #street: _f$street,
    #city: _f$city,
    #state: _f$state,
    #zipCode: _f$zipCode,
  };

  static Address _instantiate(DecodingData data) {
    return Address(
      street: data.dec(_f$street),
      city: data.dec(_f$city),
      state: data.dec(_f$state),
      zipCode: data.dec(_f$zipCode),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Address fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Address>(map);
  }

  static Address fromJson(String json) {
    return ensureInitialized().decodeJson<Address>(json);
  }
}

mixin AddressMappable {
  String toJson() {
    return AddressMapper.ensureInitialized().encodeJson<Address>(
      this as Address,
    );
  }

  Map<String, dynamic> toMap() {
    return AddressMapper.ensureInitialized().encodeMap<Address>(
      this as Address,
    );
  }

  AddressCopyWith<Address, Address, Address> get copyWith =>
      _AddressCopyWithImpl<Address, Address>(
        this as Address,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AddressMapper.ensureInitialized().stringifyValue(this as Address);
  }

  @override
  bool operator ==(Object other) {
    return AddressMapper.ensureInitialized().equalsValue(
      this as Address,
      other,
    );
  }

  @override
  int get hashCode {
    return AddressMapper.ensureInitialized().hashValue(this as Address);
  }
}

extension AddressValueCopy<$R, $Out> on ObjectCopyWith<$R, Address, $Out> {
  AddressCopyWith<$R, Address, $Out> get $asAddress =>
      $base.as((v, t, t2) => _AddressCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AddressCopyWith<$R, $In extends Address, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? street, String? city, String? state, String? zipCode});
  AddressCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AddressCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Address, $Out>
    implements AddressCopyWith<$R, Address, $Out> {
  _AddressCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Address> $mapper =
      AddressMapper.ensureInitialized();
  @override
  $R call({String? street, String? city, String? state, String? zipCode}) =>
      $apply(
        FieldCopyWithData({
          if (street != null) #street: street,
          if (city != null) #city: city,
          if (state != null) #state: state,
          if (zipCode != null) #zipCode: zipCode,
        }),
      );
  @override
  Address $make(CopyWithData data) => Address(
    street: data.get(#street, or: $value.street),
    city: data.get(#city, or: $value.city),
    state: data.get(#state, or: $value.state),
    zipCode: data.get(#zipCode, or: $value.zipCode),
  );

  @override
  AddressCopyWith<$R2, Address, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AddressCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ContactInfoMapper extends ClassMapperBase<ContactInfo> {
  ContactInfoMapper._();

  static ContactInfoMapper? _instance;
  static ContactInfoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ContactInfoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ContactInfo';

  static String _$phone(ContactInfo v) => v.phone;
  static const Field<ContactInfo, String> _f$phone = Field('phone', _$phone);
  static String _$email(ContactInfo v) => v.email;
  static const Field<ContactInfo, String> _f$email = Field('email', _$email);

  @override
  final MappableFields<ContactInfo> fields = const {
    #phone: _f$phone,
    #email: _f$email,
  };

  static ContactInfo _instantiate(DecodingData data) {
    return ContactInfo(phone: data.dec(_f$phone), email: data.dec(_f$email));
  }

  @override
  final Function instantiate = _instantiate;

  static ContactInfo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ContactInfo>(map);
  }

  static ContactInfo fromJson(String json) {
    return ensureInitialized().decodeJson<ContactInfo>(json);
  }
}

mixin ContactInfoMappable {
  String toJson() {
    return ContactInfoMapper.ensureInitialized().encodeJson<ContactInfo>(
      this as ContactInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return ContactInfoMapper.ensureInitialized().encodeMap<ContactInfo>(
      this as ContactInfo,
    );
  }

  ContactInfoCopyWith<ContactInfo, ContactInfo, ContactInfo> get copyWith =>
      _ContactInfoCopyWithImpl<ContactInfo, ContactInfo>(
        this as ContactInfo,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ContactInfoMapper.ensureInitialized().stringifyValue(
      this as ContactInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    return ContactInfoMapper.ensureInitialized().equalsValue(
      this as ContactInfo,
      other,
    );
  }

  @override
  int get hashCode {
    return ContactInfoMapper.ensureInitialized().hashValue(this as ContactInfo);
  }
}

extension ContactInfoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ContactInfo, $Out> {
  ContactInfoCopyWith<$R, ContactInfo, $Out> get $asContactInfo =>
      $base.as((v, t, t2) => _ContactInfoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ContactInfoCopyWith<$R, $In extends ContactInfo, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? phone, String? email});
  ContactInfoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ContactInfoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ContactInfo, $Out>
    implements ContactInfoCopyWith<$R, ContactInfo, $Out> {
  _ContactInfoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ContactInfo> $mapper =
      ContactInfoMapper.ensureInitialized();
  @override
  $R call({String? phone, String? email}) => $apply(
    FieldCopyWithData({
      if (phone != null) #phone: phone,
      if (email != null) #email: email,
    }),
  );
  @override
  ContactInfo $make(CopyWithData data) => ContactInfo(
    phone: data.get(#phone, or: $value.phone),
    email: data.get(#email, or: $value.email),
  );

  @override
  ContactInfoCopyWith<$R2, ContactInfo, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ContactInfoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class OperatingHourMapper extends ClassMapperBase<OperatingHour> {
  OperatingHourMapper._();

  static OperatingHourMapper? _instance;
  static OperatingHourMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OperatingHourMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'OperatingHour';

  static String _$day(OperatingHour v) => v.day;
  static const Field<OperatingHour, String> _f$day = Field('day', _$day);
  static String _$openTime(OperatingHour v) => v.openTime;
  static const Field<OperatingHour, String> _f$openTime = Field(
    'openTime',
    _$openTime,
  );
  static String _$closeTime(OperatingHour v) => v.closeTime;
  static const Field<OperatingHour, String> _f$closeTime = Field(
    'closeTime',
    _$closeTime,
  );
  static bool _$isClosed(OperatingHour v) => v.isClosed;
  static const Field<OperatingHour, bool> _f$isClosed = Field(
    'isClosed',
    _$isClosed,
  );

  @override
  final MappableFields<OperatingHour> fields = const {
    #day: _f$day,
    #openTime: _f$openTime,
    #closeTime: _f$closeTime,
    #isClosed: _f$isClosed,
  };

  static OperatingHour _instantiate(DecodingData data) {
    return OperatingHour(
      day: data.dec(_f$day),
      openTime: data.dec(_f$openTime),
      closeTime: data.dec(_f$closeTime),
      isClosed: data.dec(_f$isClosed),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OperatingHour fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OperatingHour>(map);
  }

  static OperatingHour fromJson(String json) {
    return ensureInitialized().decodeJson<OperatingHour>(json);
  }
}

mixin OperatingHourMappable {
  String toJson() {
    return OperatingHourMapper.ensureInitialized().encodeJson<OperatingHour>(
      this as OperatingHour,
    );
  }

  Map<String, dynamic> toMap() {
    return OperatingHourMapper.ensureInitialized().encodeMap<OperatingHour>(
      this as OperatingHour,
    );
  }

  OperatingHourCopyWith<OperatingHour, OperatingHour, OperatingHour>
  get copyWith => _OperatingHourCopyWithImpl<OperatingHour, OperatingHour>(
    this as OperatingHour,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return OperatingHourMapper.ensureInitialized().stringifyValue(
      this as OperatingHour,
    );
  }

  @override
  bool operator ==(Object other) {
    return OperatingHourMapper.ensureInitialized().equalsValue(
      this as OperatingHour,
      other,
    );
  }

  @override
  int get hashCode {
    return OperatingHourMapper.ensureInitialized().hashValue(
      this as OperatingHour,
    );
  }
}

extension OperatingHourValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OperatingHour, $Out> {
  OperatingHourCopyWith<$R, OperatingHour, $Out> get $asOperatingHour =>
      $base.as((v, t, t2) => _OperatingHourCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OperatingHourCopyWith<$R, $In extends OperatingHour, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? day, String? openTime, String? closeTime, bool? isClosed});
  OperatingHourCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OperatingHourCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OperatingHour, $Out>
    implements OperatingHourCopyWith<$R, OperatingHour, $Out> {
  _OperatingHourCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OperatingHour> $mapper =
      OperatingHourMapper.ensureInitialized();
  @override
  $R call({String? day, String? openTime, String? closeTime, bool? isClosed}) =>
      $apply(
        FieldCopyWithData({
          if (day != null) #day: day,
          if (openTime != null) #openTime: openTime,
          if (closeTime != null) #closeTime: closeTime,
          if (isClosed != null) #isClosed: isClosed,
        }),
      );
  @override
  OperatingHour $make(CopyWithData data) => OperatingHour(
    day: data.get(#day, or: $value.day),
    openTime: data.get(#openTime, or: $value.openTime),
    closeTime: data.get(#closeTime, or: $value.closeTime),
    isClosed: data.get(#isClosed, or: $value.isClosed),
  );

  @override
  OperatingHourCopyWith<$R2, OperatingHour, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OperatingHourCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RestaurantProfileMapper extends SubClassMapperBase<RestaurantProfile> {
  RestaurantProfileMapper._();

  static RestaurantProfileMapper? _instance;
  static RestaurantProfileMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RestaurantProfileMapper._());
      CmsContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([
        UriMapper(),
        RestaurantProfileColorMapper(),
        ImageReferenceMapper(),
      ]);
      AddressMapper.ensureInitialized();
      ContactInfoMapper.ensureInitialized();
      OperatingHourMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'RestaurantProfile';

  static String _$name(RestaurantProfile v) => v.name;
  static const Field<RestaurantProfile, String> _f$name = Field('name', _$name);
  static String _$slug(RestaurantProfile v) => v.slug;
  static const Field<RestaurantProfile, String> _f$slug = Field('slug', _$slug);
  static String _$description(RestaurantProfile v) => v.description;
  static const Field<RestaurantProfile, String> _f$description = Field(
    'description',
    _$description,
  );
  static bool _$isActive(RestaurantProfile v) => v.isActive;
  static const Field<RestaurantProfile, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
  );
  static bool _$acceptsOnlineOrders(RestaurantProfile v) =>
      v.acceptsOnlineOrders;
  static const Field<RestaurantProfile, bool> _f$acceptsOnlineOrders = Field(
    'acceptsOnlineOrders',
    _$acceptsOnlineOrders,
  );
  static String _$cuisineType(RestaurantProfile v) => v.cuisineType;
  static const Field<RestaurantProfile, String> _f$cuisineType = Field(
    'cuisineType',
    _$cuisineType,
  );
  static List<String> _$paymentMethods(RestaurantProfile v) => v.paymentMethods;
  static const Field<RestaurantProfile, List<String>> _f$paymentMethods = Field(
    'paymentMethods',
    _$paymentMethods,
  );
  static Uri? _$website(RestaurantProfile v) => v.website;
  static const Field<RestaurantProfile, Uri> _f$website = Field(
    'website',
    _$website,
    opt: true,
  );
  static Uri? _$orderingUrl(RestaurantProfile v) => v.orderingUrl;
  static const Field<RestaurantProfile, Uri> _f$orderingUrl = Field(
    'orderingUrl',
    _$orderingUrl,
    opt: true,
  );
  static DateTime? _$openingSince(RestaurantProfile v) => v.openingSince;
  static const Field<RestaurantProfile, DateTime> _f$openingSince = Field(
    'openingSince',
    _$openingSince,
    opt: true,
  );
  static ImageReference? _$logo(RestaurantProfile v) => v.logo;
  static const Field<RestaurantProfile, ImageReference> _f$logo = Field(
    'logo',
    _$logo,
    opt: true,
  );
  static ImageReference? _$coverPhoto(RestaurantProfile v) => v.coverPhoto;
  static const Field<RestaurantProfile, ImageReference> _f$coverPhoto = Field(
    'coverPhoto',
    _$coverPhoto,
    opt: true,
  );
  static String? _$pdfMenu(RestaurantProfile v) => v.pdfMenu;
  static const Field<RestaurantProfile, String> _f$pdfMenu = Field(
    'pdfMenu',
    _$pdfMenu,
    opt: true,
  );
  static Address _$address(RestaurantProfile v) => v.address;
  static const Field<RestaurantProfile, Address> _f$address = Field(
    'address',
    _$address,
  );
  static ContactInfo _$contactInfo(RestaurantProfile v) => v.contactInfo;
  static const Field<RestaurantProfile, ContactInfo> _f$contactInfo = Field(
    'contactInfo',
    _$contactInfo,
  );
  static List<OperatingHour> _$operatingHours(RestaurantProfile v) =>
      v.operatingHours;
  static const Field<RestaurantProfile, List<OperatingHour>> _f$operatingHours =
      Field('operatingHours', _$operatingHours);

  @override
  final MappableFields<RestaurantProfile> fields = const {
    #name: _f$name,
    #slug: _f$slug,
    #description: _f$description,
    #isActive: _f$isActive,
    #acceptsOnlineOrders: _f$acceptsOnlineOrders,
    #cuisineType: _f$cuisineType,
    #paymentMethods: _f$paymentMethods,
    #website: _f$website,
    #orderingUrl: _f$orderingUrl,
    #openingSince: _f$openingSince,
    #logo: _f$logo,
    #coverPhoto: _f$coverPhoto,
    #pdfMenu: _f$pdfMenu,
    #address: _f$address,
    #contactInfo: _f$contactInfo,
    #operatingHours: _f$operatingHours,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'restaurantProfile';
  @override
  late final ClassMapperBase superMapper = CmsContentMapper.ensureInitialized();

  static RestaurantProfile _instantiate(DecodingData data) {
    return RestaurantProfile(
      name: data.dec(_f$name),
      slug: data.dec(_f$slug),
      description: data.dec(_f$description),
      isActive: data.dec(_f$isActive),
      acceptsOnlineOrders: data.dec(_f$acceptsOnlineOrders),
      cuisineType: data.dec(_f$cuisineType),
      paymentMethods: data.dec(_f$paymentMethods),
      website: data.dec(_f$website),
      orderingUrl: data.dec(_f$orderingUrl),
      openingSince: data.dec(_f$openingSince),
      logo: data.dec(_f$logo),
      coverPhoto: data.dec(_f$coverPhoto),
      pdfMenu: data.dec(_f$pdfMenu),
      address: data.dec(_f$address),
      contactInfo: data.dec(_f$contactInfo),
      operatingHours: data.dec(_f$operatingHours),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RestaurantProfile fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RestaurantProfile>(map);
  }

  static RestaurantProfile fromJson(String json) {
    return ensureInitialized().decodeJson<RestaurantProfile>(json);
  }
}

mixin RestaurantProfileMappable {
  String toJson() {
    return RestaurantProfileMapper.ensureInitialized()
        .encodeJson<RestaurantProfile>(this as RestaurantProfile);
  }

  Map<String, dynamic> toMap() {
    return RestaurantProfileMapper.ensureInitialized()
        .encodeMap<RestaurantProfile>(this as RestaurantProfile);
  }

  RestaurantProfileCopyWith<
    RestaurantProfile,
    RestaurantProfile,
    RestaurantProfile
  >
  get copyWith =>
      _RestaurantProfileCopyWithImpl<RestaurantProfile, RestaurantProfile>(
        this as RestaurantProfile,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return RestaurantProfileMapper.ensureInitialized().stringifyValue(
      this as RestaurantProfile,
    );
  }

  @override
  bool operator ==(Object other) {
    return RestaurantProfileMapper.ensureInitialized().equalsValue(
      this as RestaurantProfile,
      other,
    );
  }

  @override
  int get hashCode {
    return RestaurantProfileMapper.ensureInitialized().hashValue(
      this as RestaurantProfile,
    );
  }
}

extension RestaurantProfileValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RestaurantProfile, $Out> {
  RestaurantProfileCopyWith<$R, RestaurantProfile, $Out>
  get $asRestaurantProfile => $base.as(
    (v, t, t2) => _RestaurantProfileCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class RestaurantProfileCopyWith<
  $R,
  $In extends RestaurantProfile,
  $Out
>
    implements CmsContentCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get paymentMethods;
  AddressCopyWith<$R, Address, Address> get address;
  ContactInfoCopyWith<$R, ContactInfo, ContactInfo> get contactInfo;
  ListCopyWith<
    $R,
    OperatingHour,
    OperatingHourCopyWith<$R, OperatingHour, OperatingHour>
  >
  get operatingHours;
  @override
  $R call({
    String? name,
    String? slug,
    String? description,
    bool? isActive,
    bool? acceptsOnlineOrders,
    String? cuisineType,
    List<String>? paymentMethods,
    Uri? website,
    Uri? orderingUrl,
    DateTime? openingSince,
    ImageReference? logo,
    ImageReference? coverPhoto,
    String? pdfMenu,
    Address? address,
    ContactInfo? contactInfo,
    List<OperatingHour>? operatingHours,
  });
  RestaurantProfileCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _RestaurantProfileCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RestaurantProfile, $Out>
    implements RestaurantProfileCopyWith<$R, RestaurantProfile, $Out> {
  _RestaurantProfileCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RestaurantProfile> $mapper =
      RestaurantProfileMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get paymentMethods => ListCopyWith(
    $value.paymentMethods,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(paymentMethods: v),
  );
  @override
  AddressCopyWith<$R, Address, Address> get address =>
      $value.address.copyWith.$chain((v) => call(address: v));
  @override
  ContactInfoCopyWith<$R, ContactInfo, ContactInfo> get contactInfo =>
      $value.contactInfo.copyWith.$chain((v) => call(contactInfo: v));
  @override
  ListCopyWith<
    $R,
    OperatingHour,
    OperatingHourCopyWith<$R, OperatingHour, OperatingHour>
  >
  get operatingHours => ListCopyWith(
    $value.operatingHours,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(operatingHours: v),
  );
  @override
  $R call({
    String? name,
    String? slug,
    String? description,
    bool? isActive,
    bool? acceptsOnlineOrders,
    String? cuisineType,
    List<String>? paymentMethods,
    Object? website = $none,
    Object? orderingUrl = $none,
    Object? openingSince = $none,
    Object? logo = $none,
    Object? coverPhoto = $none,
    Object? pdfMenu = $none,
    Address? address,
    ContactInfo? contactInfo,
    List<OperatingHour>? operatingHours,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (slug != null) #slug: slug,
      if (description != null) #description: description,
      if (isActive != null) #isActive: isActive,
      if (acceptsOnlineOrders != null)
        #acceptsOnlineOrders: acceptsOnlineOrders,
      if (cuisineType != null) #cuisineType: cuisineType,
      if (paymentMethods != null) #paymentMethods: paymentMethods,
      if (website != $none) #website: website,
      if (orderingUrl != $none) #orderingUrl: orderingUrl,
      if (openingSince != $none) #openingSince: openingSince,
      if (logo != $none) #logo: logo,
      if (coverPhoto != $none) #coverPhoto: coverPhoto,
      if (pdfMenu != $none) #pdfMenu: pdfMenu,
      if (address != null) #address: address,
      if (contactInfo != null) #contactInfo: contactInfo,
      if (operatingHours != null) #operatingHours: operatingHours,
    }),
  );
  @override
  RestaurantProfile $make(CopyWithData data) => RestaurantProfile(
    name: data.get(#name, or: $value.name),
    slug: data.get(#slug, or: $value.slug),
    description: data.get(#description, or: $value.description),
    isActive: data.get(#isActive, or: $value.isActive),
    acceptsOnlineOrders: data.get(
      #acceptsOnlineOrders,
      or: $value.acceptsOnlineOrders,
    ),
    cuisineType: data.get(#cuisineType, or: $value.cuisineType),
    paymentMethods: data.get(#paymentMethods, or: $value.paymentMethods),
    website: data.get(#website, or: $value.website),
    orderingUrl: data.get(#orderingUrl, or: $value.orderingUrl),
    openingSince: data.get(#openingSince, or: $value.openingSince),
    logo: data.get(#logo, or: $value.logo),
    coverPhoto: data.get(#coverPhoto, or: $value.coverPhoto),
    pdfMenu: data.get(#pdfMenu, or: $value.pdfMenu),
    address: data.get(#address, or: $value.address),
    contactInfo: data.get(#contactInfo, or: $value.contactInfo),
    operatingHours: data.get(#operatingHours, or: $value.operatingHours),
  );

  @override
  RestaurantProfileCopyWith<$R2, RestaurantProfile, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RestaurantProfileCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

