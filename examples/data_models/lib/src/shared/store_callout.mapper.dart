// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'store_callout.dart';

class StoreCalloutMapper extends ClassMapperBase<StoreCallout> {
  StoreCalloutMapper._();

  static StoreCalloutMapper? _instance;
  static StoreCalloutMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StoreCalloutMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'StoreCallout';

  static String _$venueName(StoreCallout v) => v.venueName;
  static const Field<StoreCallout, String> _f$venueName = Field(
    'venueName',
    _$venueName,
  );
  static String _$hoursLabel(StoreCallout v) => v.hoursLabel;
  static const Field<StoreCallout, String> _f$hoursLabel = Field(
    'hoursLabel',
    _$hoursLabel,
  );
  static String _$distanceLabel(StoreCallout v) => v.distanceLabel;
  static const Field<StoreCallout, String> _f$distanceLabel = Field(
    'distanceLabel',
    _$distanceLabel,
  );
  static String _$directionsLabel(StoreCallout v) => v.directionsLabel;
  static const Field<StoreCallout, String> _f$directionsLabel = Field(
    'directionsLabel',
    _$directionsLabel,
  );

  @override
  final MappableFields<StoreCallout> fields = const {
    #venueName: _f$venueName,
    #hoursLabel: _f$hoursLabel,
    #distanceLabel: _f$distanceLabel,
    #directionsLabel: _f$directionsLabel,
  };

  static StoreCallout _instantiate(DecodingData data) {
    return StoreCallout(
      venueName: data.dec(_f$venueName),
      hoursLabel: data.dec(_f$hoursLabel),
      distanceLabel: data.dec(_f$distanceLabel),
      directionsLabel: data.dec(_f$directionsLabel),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static StoreCallout fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StoreCallout>(map);
  }

  static StoreCallout fromJson(String json) {
    return ensureInitialized().decodeJson<StoreCallout>(json);
  }
}

mixin StoreCalloutMappable {
  String toJson() {
    return StoreCalloutMapper.ensureInitialized().encodeJson<StoreCallout>(
      this as StoreCallout,
    );
  }

  Map<String, dynamic> toMap() {
    return StoreCalloutMapper.ensureInitialized().encodeMap<StoreCallout>(
      this as StoreCallout,
    );
  }

  StoreCalloutCopyWith<StoreCallout, StoreCallout, StoreCallout> get copyWith =>
      _StoreCalloutCopyWithImpl<StoreCallout, StoreCallout>(
        this as StoreCallout,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return StoreCalloutMapper.ensureInitialized().stringifyValue(
      this as StoreCallout,
    );
  }

  @override
  bool operator ==(Object other) {
    return StoreCalloutMapper.ensureInitialized().equalsValue(
      this as StoreCallout,
      other,
    );
  }

  @override
  int get hashCode {
    return StoreCalloutMapper.ensureInitialized().hashValue(
      this as StoreCallout,
    );
  }
}

extension StoreCalloutValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StoreCallout, $Out> {
  StoreCalloutCopyWith<$R, StoreCallout, $Out> get $asStoreCallout =>
      $base.as((v, t, t2) => _StoreCalloutCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class StoreCalloutCopyWith<$R, $In extends StoreCallout, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? venueName,
    String? hoursLabel,
    String? distanceLabel,
    String? directionsLabel,
  });
  StoreCalloutCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _StoreCalloutCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StoreCallout, $Out>
    implements StoreCalloutCopyWith<$R, StoreCallout, $Out> {
  _StoreCalloutCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StoreCallout> $mapper =
      StoreCalloutMapper.ensureInitialized();
  @override
  $R call({
    String? venueName,
    String? hoursLabel,
    String? distanceLabel,
    String? directionsLabel,
  }) => $apply(
    FieldCopyWithData({
      if (venueName != null) #venueName: venueName,
      if (hoursLabel != null) #hoursLabel: hoursLabel,
      if (distanceLabel != null) #distanceLabel: distanceLabel,
      if (directionsLabel != null) #directionsLabel: directionsLabel,
    }),
  );
  @override
  StoreCallout $make(CopyWithData data) => StoreCallout(
    venueName: data.get(#venueName, or: $value.venueName),
    hoursLabel: data.get(#hoursLabel, or: $value.hoursLabel),
    distanceLabel: data.get(#distanceLabel, or: $value.distanceLabel),
    directionsLabel: data.get(#directionsLabel, or: $value.directionsLabel),
  );

  @override
  StoreCalloutCopyWith<$R2, StoreCallout, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _StoreCalloutCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

