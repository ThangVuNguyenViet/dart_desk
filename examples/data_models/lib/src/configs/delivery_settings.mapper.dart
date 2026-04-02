// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'delivery_settings.dart';

class DeliverySettingsMapper extends ClassMapperBase<DeliverySettings> {
  DeliverySettingsMapper._();

  static DeliverySettingsMapper? _instance;
  static DeliverySettingsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DeliverySettingsMapper._());
      MapperContainer.globals.useAll([ImageReferenceMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'DeliverySettings';

  static String _$zoneName(DeliverySettings v) => v.zoneName;
  static const Field<DeliverySettings, String> _f$zoneName = Field(
    'zoneName',
    _$zoneName,
  );
  static String _$zoneDescription(DeliverySettings v) => v.zoneDescription;
  static const Field<DeliverySettings, String> _f$zoneDescription = Field(
    'zoneDescription',
    _$zoneDescription,
  );
  static num _$minimumOrder(DeliverySettings v) => v.minimumOrder;
  static const Field<DeliverySettings, num> _f$minimumOrder = Field(
    'minimumOrder',
    _$minimumOrder,
  );
  static num _$deliveryFee(DeliverySettings v) => v.deliveryFee;
  static const Field<DeliverySettings, num> _f$deliveryFee = Field(
    'deliveryFee',
    _$deliveryFee,
  );
  static num _$freeDeliveryThreshold(DeliverySettings v) =>
      v.freeDeliveryThreshold;
  static const Field<DeliverySettings, num> _f$freeDeliveryThreshold = Field(
    'freeDeliveryThreshold',
    _$freeDeliveryThreshold,
  );
  static num _$estimatedMinutes(DeliverySettings v) => v.estimatedMinutes;
  static const Field<DeliverySettings, num> _f$estimatedMinutes = Field(
    'estimatedMinutes',
    _$estimatedMinutes,
  );
  static String _$serviceHours(DeliverySettings v) => v.serviceHours;
  static const Field<DeliverySettings, String> _f$serviceHours = Field(
    'serviceHours',
    _$serviceHours,
  );
  static bool _$active(DeliverySettings v) => v.active;
  static const Field<DeliverySettings, bool> _f$active = Field(
    'active',
    _$active,
  );
  static String? _$contactUrl(DeliverySettings v) => v.contactUrl;
  static const Field<DeliverySettings, String> _f$contactUrl = Field(
    'contactUrl',
    _$contactUrl,
    opt: true,
  );
  static String _$deliveryType(DeliverySettings v) => v.deliveryType;
  static const Field<DeliverySettings, String> _f$deliveryType = Field(
    'deliveryType',
    _$deliveryType,
  );

  @override
  final MappableFields<DeliverySettings> fields = const {
    #zoneName: _f$zoneName,
    #zoneDescription: _f$zoneDescription,
    #minimumOrder: _f$minimumOrder,
    #deliveryFee: _f$deliveryFee,
    #freeDeliveryThreshold: _f$freeDeliveryThreshold,
    #estimatedMinutes: _f$estimatedMinutes,
    #serviceHours: _f$serviceHours,
    #active: _f$active,
    #contactUrl: _f$contactUrl,
    #deliveryType: _f$deliveryType,
  };

  static DeliverySettings _instantiate(DecodingData data) {
    return DeliverySettings(
      zoneName: data.dec(_f$zoneName),
      zoneDescription: data.dec(_f$zoneDescription),
      minimumOrder: data.dec(_f$minimumOrder),
      deliveryFee: data.dec(_f$deliveryFee),
      freeDeliveryThreshold: data.dec(_f$freeDeliveryThreshold),
      estimatedMinutes: data.dec(_f$estimatedMinutes),
      serviceHours: data.dec(_f$serviceHours),
      active: data.dec(_f$active),
      contactUrl: data.dec(_f$contactUrl),
      deliveryType: data.dec(_f$deliveryType),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DeliverySettings fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DeliverySettings>(map);
  }

  static DeliverySettings fromJson(String json) {
    return ensureInitialized().decodeJson<DeliverySettings>(json);
  }
}

mixin DeliverySettingsMappable {
  String toJson() {
    return DeliverySettingsMapper.ensureInitialized()
        .encodeJson<DeliverySettings>(this as DeliverySettings);
  }

  Map<String, dynamic> toMap() {
    return DeliverySettingsMapper.ensureInitialized()
        .encodeMap<DeliverySettings>(this as DeliverySettings);
  }

  DeliverySettingsCopyWith<DeliverySettings, DeliverySettings, DeliverySettings>
  get copyWith =>
      _DeliverySettingsCopyWithImpl<DeliverySettings, DeliverySettings>(
        this as DeliverySettings,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DeliverySettingsMapper.ensureInitialized().stringifyValue(
      this as DeliverySettings,
    );
  }

  @override
  bool operator ==(Object other) {
    return DeliverySettingsMapper.ensureInitialized().equalsValue(
      this as DeliverySettings,
      other,
    );
  }

  @override
  int get hashCode {
    return DeliverySettingsMapper.ensureInitialized().hashValue(
      this as DeliverySettings,
    );
  }
}

extension DeliverySettingsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DeliverySettings, $Out> {
  DeliverySettingsCopyWith<$R, DeliverySettings, $Out>
  get $asDeliverySettings =>
      $base.as((v, t, t2) => _DeliverySettingsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DeliverySettingsCopyWith<$R, $In extends DeliverySettings, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? zoneName,
    String? zoneDescription,
    num? minimumOrder,
    num? deliveryFee,
    num? freeDeliveryThreshold,
    num? estimatedMinutes,
    String? serviceHours,
    bool? active,
    String? contactUrl,
    String? deliveryType,
  });
  DeliverySettingsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DeliverySettingsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DeliverySettings, $Out>
    implements DeliverySettingsCopyWith<$R, DeliverySettings, $Out> {
  _DeliverySettingsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DeliverySettings> $mapper =
      DeliverySettingsMapper.ensureInitialized();
  @override
  $R call({
    String? zoneName,
    String? zoneDescription,
    num? minimumOrder,
    num? deliveryFee,
    num? freeDeliveryThreshold,
    num? estimatedMinutes,
    String? serviceHours,
    bool? active,
    Object? contactUrl = $none,
    String? deliveryType,
  }) => $apply(
    FieldCopyWithData({
      if (zoneName != null) #zoneName: zoneName,
      if (zoneDescription != null) #zoneDescription: zoneDescription,
      if (minimumOrder != null) #minimumOrder: minimumOrder,
      if (deliveryFee != null) #deliveryFee: deliveryFee,
      if (freeDeliveryThreshold != null)
        #freeDeliveryThreshold: freeDeliveryThreshold,
      if (estimatedMinutes != null) #estimatedMinutes: estimatedMinutes,
      if (serviceHours != null) #serviceHours: serviceHours,
      if (active != null) #active: active,
      if (contactUrl != $none) #contactUrl: contactUrl,
      if (deliveryType != null) #deliveryType: deliveryType,
    }),
  );
  @override
  DeliverySettings $make(CopyWithData data) => DeliverySettings(
    zoneName: data.get(#zoneName, or: $value.zoneName),
    zoneDescription: data.get(#zoneDescription, or: $value.zoneDescription),
    minimumOrder: data.get(#minimumOrder, or: $value.minimumOrder),
    deliveryFee: data.get(#deliveryFee, or: $value.deliveryFee),
    freeDeliveryThreshold: data.get(
      #freeDeliveryThreshold,
      or: $value.freeDeliveryThreshold,
    ),
    estimatedMinutes: data.get(#estimatedMinutes, or: $value.estimatedMinutes),
    serviceHours: data.get(#serviceHours, or: $value.serviceHours),
    active: data.get(#active, or: $value.active),
    contactUrl: data.get(#contactUrl, or: $value.contactUrl),
    deliveryType: data.get(#deliveryType, or: $value.deliveryType),
  );

  @override
  DeliverySettingsCopyWith<$R2, DeliverySettings, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DeliverySettingsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

