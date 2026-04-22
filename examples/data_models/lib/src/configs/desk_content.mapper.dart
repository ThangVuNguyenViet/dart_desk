// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'desk_content.dart';

class DeskContentMapper extends ClassMapperBase<DeskContent> {
  DeskContentMapper._();

  static DeskContentMapper? _instance;
  static DeskContentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DeskContentMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DeskContent';

  @override
  final MappableFields<DeskContent> fields = const {};

  static DeskContent _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('DeskContent');
  }

  @override
  final Function instantiate = _instantiate;

  static DeskContent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DeskContent>(map);
  }

  static DeskContent fromJson(String json) {
    return ensureInitialized().decodeJson<DeskContent>(json);
  }
}

mixin DeskContentMappable {
  String toJson();
  Map<String, dynamic> toMap();
  DeskContentCopyWith<DeskContent, DeskContent, DeskContent> get copyWith;
}

abstract class DeskContentCopyWith<$R, $In extends DeskContent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  DeskContentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

