// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'store_hours_entry.dart';

class StoreHoursEntryMapper extends ClassMapperBase<StoreHoursEntry> {
  StoreHoursEntryMapper._();

  static StoreHoursEntryMapper? _instance;
  static StoreHoursEntryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StoreHoursEntryMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'StoreHoursEntry';

  static String _$day(StoreHoursEntry v) => v.day;
  static const Field<StoreHoursEntry, String> _f$day = Field('day', _$day);
  static String _$openTime(StoreHoursEntry v) => v.openTime;
  static const Field<StoreHoursEntry, String> _f$openTime = Field(
    'openTime',
    _$openTime,
  );
  static String _$closeTime(StoreHoursEntry v) => v.closeTime;
  static const Field<StoreHoursEntry, String> _f$closeTime = Field(
    'closeTime',
    _$closeTime,
  );

  @override
  final MappableFields<StoreHoursEntry> fields = const {
    #day: _f$day,
    #openTime: _f$openTime,
    #closeTime: _f$closeTime,
  };

  static StoreHoursEntry _instantiate(DecodingData data) {
    return StoreHoursEntry(
      day: data.dec(_f$day),
      openTime: data.dec(_f$openTime),
      closeTime: data.dec(_f$closeTime),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static StoreHoursEntry fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StoreHoursEntry>(map);
  }

  static StoreHoursEntry fromJson(String json) {
    return ensureInitialized().decodeJson<StoreHoursEntry>(json);
  }
}

mixin StoreHoursEntryMappable {
  String toJson() {
    return StoreHoursEntryMapper.ensureInitialized()
        .encodeJson<StoreHoursEntry>(this as StoreHoursEntry);
  }

  Map<String, dynamic> toMap() {
    return StoreHoursEntryMapper.ensureInitialized().encodeMap<StoreHoursEntry>(
      this as StoreHoursEntry,
    );
  }

  StoreHoursEntryCopyWith<StoreHoursEntry, StoreHoursEntry, StoreHoursEntry>
  get copyWith =>
      _StoreHoursEntryCopyWithImpl<StoreHoursEntry, StoreHoursEntry>(
        this as StoreHoursEntry,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return StoreHoursEntryMapper.ensureInitialized().stringifyValue(
      this as StoreHoursEntry,
    );
  }

  @override
  bool operator ==(Object other) {
    return StoreHoursEntryMapper.ensureInitialized().equalsValue(
      this as StoreHoursEntry,
      other,
    );
  }

  @override
  int get hashCode {
    return StoreHoursEntryMapper.ensureInitialized().hashValue(
      this as StoreHoursEntry,
    );
  }
}

extension StoreHoursEntryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StoreHoursEntry, $Out> {
  StoreHoursEntryCopyWith<$R, StoreHoursEntry, $Out> get $asStoreHoursEntry =>
      $base.as((v, t, t2) => _StoreHoursEntryCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class StoreHoursEntryCopyWith<$R, $In extends StoreHoursEntry, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? day, String? openTime, String? closeTime});
  StoreHoursEntryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _StoreHoursEntryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StoreHoursEntry, $Out>
    implements StoreHoursEntryCopyWith<$R, StoreHoursEntry, $Out> {
  _StoreHoursEntryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StoreHoursEntry> $mapper =
      StoreHoursEntryMapper.ensureInitialized();
  @override
  $R call({String? day, String? openTime, String? closeTime}) => $apply(
    FieldCopyWithData({
      if (day != null) #day: day,
      if (openTime != null) #openTime: openTime,
      if (closeTime != null) #closeTime: closeTime,
    }),
  );
  @override
  StoreHoursEntry $make(CopyWithData data) => StoreHoursEntry(
    day: data.get(#day, or: $value.day),
    openTime: data.get(#openTime, or: $value.openTime),
    closeTime: data.get(#closeTime, or: $value.closeTime),
  );

  @override
  StoreHoursEntryCopyWith<$R2, StoreHoursEntry, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _StoreHoursEntryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

