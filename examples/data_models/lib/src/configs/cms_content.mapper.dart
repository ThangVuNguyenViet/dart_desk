// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cms_content.dart';

class CmsContentMapper extends ClassMapperBase<CmsContent> {
  CmsContentMapper._();

  static CmsContentMapper? _instance;
  static CmsContentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CmsContentMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CmsContent';

  @override
  final MappableFields<CmsContent> fields = const {};

  static CmsContent _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('CmsContent');
  }

  @override
  final Function instantiate = _instantiate;

  static CmsContent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CmsContent>(map);
  }

  static CmsContent fromJson(String json) {
    return ensureInitialized().decodeJson<CmsContent>(json);
  }
}

mixin CmsContentMappable {
  String toJson();
  Map<String, dynamic> toMap();
  CmsContentCopyWith<CmsContent, CmsContent, CmsContent> get copyWith;
}

abstract class CmsContentCopyWith<$R, $In extends CmsContent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  CmsContentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

