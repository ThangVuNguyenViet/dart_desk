// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'chef_profile.dart';

class ChefProfileMapper extends ClassMapperBase<ChefProfile> {
  ChefProfileMapper._();

  static ChefProfileMapper? _instance;
  static ChefProfileMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChefProfileMapper._());
      MapperContainer.globals.useAll([ImageReferenceMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'ChefProfile';

  static String _$name(ChefProfile v) => v.name;
  static const Field<ChefProfile, String> _f$name = Field('name', _$name);
  static String _$role(ChefProfile v) => v.role;
  static const Field<ChefProfile, String> _f$role = Field('role', _$role);
  static ImageReference? _$portrait(ChefProfile v) => v.portrait;
  static const Field<ChefProfile, ImageReference> _f$portrait = Field(
    'portrait',
    _$portrait,
    opt: true,
  );
  static String _$bio(ChefProfile v) => v.bio;
  static const Field<ChefProfile, String> _f$bio = Field('bio', _$bio);
  static String? _$cv(ChefProfile v) => v.cv;
  static const Field<ChefProfile, String> _f$cv = Field('cv', _$cv, opt: true);

  @override
  final MappableFields<ChefProfile> fields = const {
    #name: _f$name,
    #role: _f$role,
    #portrait: _f$portrait,
    #bio: _f$bio,
    #cv: _f$cv,
  };

  static ChefProfile _instantiate(DecodingData data) {
    return ChefProfile(
      name: data.dec(_f$name),
      role: data.dec(_f$role),
      portrait: data.dec(_f$portrait),
      bio: data.dec(_f$bio),
      cv: data.dec(_f$cv),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ChefProfile fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChefProfile>(map);
  }

  static ChefProfile fromJson(String json) {
    return ensureInitialized().decodeJson<ChefProfile>(json);
  }
}

mixin ChefProfileMappable {
  String toJson() {
    return ChefProfileMapper.ensureInitialized().encodeJson<ChefProfile>(
      this as ChefProfile,
    );
  }

  Map<String, dynamic> toMap() {
    return ChefProfileMapper.ensureInitialized().encodeMap<ChefProfile>(
      this as ChefProfile,
    );
  }

  ChefProfileCopyWith<ChefProfile, ChefProfile, ChefProfile> get copyWith =>
      _ChefProfileCopyWithImpl<ChefProfile, ChefProfile>(
        this as ChefProfile,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ChefProfileMapper.ensureInitialized().stringifyValue(
      this as ChefProfile,
    );
  }

  @override
  bool operator ==(Object other) {
    return ChefProfileMapper.ensureInitialized().equalsValue(
      this as ChefProfile,
      other,
    );
  }

  @override
  int get hashCode {
    return ChefProfileMapper.ensureInitialized().hashValue(this as ChefProfile);
  }
}

extension ChefProfileValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ChefProfile, $Out> {
  ChefProfileCopyWith<$R, ChefProfile, $Out> get $asChefProfile =>
      $base.as((v, t, t2) => _ChefProfileCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ChefProfileCopyWith<$R, $In extends ChefProfile, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? name,
    String? role,
    ImageReference? portrait,
    String? bio,
    String? cv,
  });
  ChefProfileCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ChefProfileCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ChefProfile, $Out>
    implements ChefProfileCopyWith<$R, ChefProfile, $Out> {
  _ChefProfileCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ChefProfile> $mapper =
      ChefProfileMapper.ensureInitialized();
  @override
  $R call({
    String? name,
    String? role,
    Object? portrait = $none,
    String? bio,
    Object? cv = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (role != null) #role: role,
      if (portrait != $none) #portrait: portrait,
      if (bio != null) #bio: bio,
      if (cv != $none) #cv: cv,
    }),
  );
  @override
  ChefProfile $make(CopyWithData data) => ChefProfile(
    name: data.get(#name, or: $value.name),
    role: data.get(#role, or: $value.role),
    portrait: data.get(#portrait, or: $value.portrait),
    bio: data.get(#bio, or: $value.bio),
    cv: data.get(#cv, or: $value.cv),
  );

  @override
  ChefProfileCopyWith<$R2, ChefProfile, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ChefProfileCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

