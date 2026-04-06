// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'array_test_config.dart';

class ImageReferenceMapper extends ClassMapperBase<ImageReference> {
  ImageReferenceMapper._();

  static ImageReferenceMapper? _instance;
  static ImageReferenceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ImageReferenceMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ImageReference';

  static String _$url(ImageReference v) => v.url;
  static const Field<ImageReference, String> _f$url = Field('url', _$url);

  @override
  final MappableFields<ImageReference> fields = const {#url: _f$url};

  static ImageReference _instantiate(DecodingData data) {
    return ImageReference(url: data.dec(_f$url));
  }

  @override
  final Function instantiate = _instantiate;

  static ImageReference fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ImageReference>(map);
  }

  static ImageReference fromJson(String json) {
    return ensureInitialized().decodeJson<ImageReference>(json);
  }
}

mixin ImageReferenceMappable {
  String toJson() {
    return ImageReferenceMapper.ensureInitialized().encodeJson<ImageReference>(
      this as ImageReference,
    );
  }

  Map<String, dynamic> toMap() {
    return ImageReferenceMapper.ensureInitialized().encodeMap<ImageReference>(
      this as ImageReference,
    );
  }

  ImageReferenceCopyWith<ImageReference, ImageReference, ImageReference>
  get copyWith => _ImageReferenceCopyWithImpl<ImageReference, ImageReference>(
    this as ImageReference,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ImageReferenceMapper.ensureInitialized().stringifyValue(
      this as ImageReference,
    );
  }

  @override
  bool operator ==(Object other) {
    return ImageReferenceMapper.ensureInitialized().equalsValue(
      this as ImageReference,
      other,
    );
  }

  @override
  int get hashCode {
    return ImageReferenceMapper.ensureInitialized().hashValue(
      this as ImageReference,
    );
  }
}

extension ImageReferenceValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ImageReference, $Out> {
  ImageReferenceCopyWith<$R, ImageReference, $Out> get $asImageReference =>
      $base.as((v, t, t2) => _ImageReferenceCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ImageReferenceCopyWith<$R, $In extends ImageReference, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? url});
  ImageReferenceCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ImageReferenceCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ImageReference, $Out>
    implements ImageReferenceCopyWith<$R, ImageReference, $Out> {
  _ImageReferenceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ImageReference> $mapper =
      ImageReferenceMapper.ensureInitialized();
  @override
  $R call({String? url}) =>
      $apply(FieldCopyWithData({if (url != null) #url: url}));
  @override
  ImageReference $make(CopyWithData data) =>
      ImageReference(url: data.get(#url, or: $value.url));

  @override
  ImageReferenceCopyWith<$R2, ImageReference, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ImageReferenceCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class HeroConfigMapper extends ClassMapperBase<HeroConfig> {
  HeroConfigMapper._();

  static HeroConfigMapper? _instance;
  static HeroConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HeroConfigMapper._());
      ImageReferenceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'HeroConfig';

  static String _$title(HeroConfig v) => v.title;
  static const Field<HeroConfig, String> _f$title = Field('title', _$title);
  static ImageReference? _$heroImage(HeroConfig v) => v.heroImage;
  static const Field<HeroConfig, ImageReference> _f$heroImage = Field(
    'heroImage',
    _$heroImage,
    opt: true,
  );

  @override
  final MappableFields<HeroConfig> fields = const {
    #title: _f$title,
    #heroImage: _f$heroImage,
  };

  static HeroConfig _instantiate(DecodingData data) {
    return HeroConfig(
      title: data.dec(_f$title),
      heroImage: data.dec(_f$heroImage),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static HeroConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HeroConfig>(map);
  }

  static HeroConfig fromJson(String json) {
    return ensureInitialized().decodeJson<HeroConfig>(json);
  }
}

mixin HeroConfigMappable {
  String toJson() {
    return HeroConfigMapper.ensureInitialized().encodeJson<HeroConfig>(
      this as HeroConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return HeroConfigMapper.ensureInitialized().encodeMap<HeroConfig>(
      this as HeroConfig,
    );
  }

  HeroConfigCopyWith<HeroConfig, HeroConfig, HeroConfig> get copyWith =>
      _HeroConfigCopyWithImpl<HeroConfig, HeroConfig>(
        this as HeroConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HeroConfigMapper.ensureInitialized().stringifyValue(
      this as HeroConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return HeroConfigMapper.ensureInitialized().equalsValue(
      this as HeroConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return HeroConfigMapper.ensureInitialized().hashValue(this as HeroConfig);
  }
}

extension HeroConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HeroConfig, $Out> {
  HeroConfigCopyWith<$R, HeroConfig, $Out> get $asHeroConfig =>
      $base.as((v, t, t2) => _HeroConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HeroConfigCopyWith<$R, $In extends HeroConfig, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ImageReferenceCopyWith<$R, ImageReference, ImageReference>? get heroImage;
  $R call({String? title, ImageReference? heroImage});
  HeroConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _HeroConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HeroConfig, $Out>
    implements HeroConfigCopyWith<$R, HeroConfig, $Out> {
  _HeroConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HeroConfig> $mapper =
      HeroConfigMapper.ensureInitialized();
  @override
  ImageReferenceCopyWith<$R, ImageReference, ImageReference>? get heroImage =>
      $value.heroImage?.copyWith.$chain((v) => call(heroImage: v));
  @override
  $R call({String? title, Object? heroImage = $none}) => $apply(
    FieldCopyWithData({
      if (title != null) #title: title,
      if (heroImage != $none) #heroImage: heroImage,
    }),
  );
  @override
  HeroConfig $make(CopyWithData data) => HeroConfig(
    title: data.get(#title, or: $value.title),
    heroImage: data.get(#heroImage, or: $value.heroImage),
  );

  @override
  HeroConfigCopyWith<$R2, HeroConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _HeroConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ArrayTestConfigMapper extends ClassMapperBase<ArrayTestConfig> {
  ArrayTestConfigMapper._();

  static ArrayTestConfigMapper? _instance;
  static ArrayTestConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ArrayTestConfigMapper._());
      HeroConfigMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ArrayTestConfig';

  static List<String> _$primitiveStrings(ArrayTestConfig v) =>
      v.primitiveStrings;
  static const Field<ArrayTestConfig, List<String>> _f$primitiveStrings = Field(
    'primitiveStrings',
    _$primitiveStrings,
  );
  static List<HeroConfig> _$cmsObjectList(ArrayTestConfig v) => v.cmsObjectList;
  static const Field<ArrayTestConfig, List<HeroConfig>> _f$cmsObjectList =
      Field('cmsObjectList', _$cmsObjectList);
  static List<SampleConfig> _$unannotatedObjectList(ArrayTestConfig v) =>
      v.unannotatedObjectList;
  static const Field<ArrayTestConfig, List<SampleConfig>>
  _f$unannotatedObjectList = Field(
    'unannotatedObjectList',
    _$unannotatedObjectList,
  );
  static List<String> _$stringListWithImageInner(ArrayTestConfig v) =>
      v.stringListWithImageInner;
  static const Field<ArrayTestConfig, List<String>>
  _f$stringListWithImageInner = Field(
    'stringListWithImageInner',
    _$stringListWithImageInner,
  );

  @override
  final MappableFields<ArrayTestConfig> fields = const {
    #primitiveStrings: _f$primitiveStrings,
    #cmsObjectList: _f$cmsObjectList,
    #unannotatedObjectList: _f$unannotatedObjectList,
    #stringListWithImageInner: _f$stringListWithImageInner,
  };

  static ArrayTestConfig _instantiate(DecodingData data) {
    return ArrayTestConfig(
      primitiveStrings: data.dec(_f$primitiveStrings),
      cmsObjectList: data.dec(_f$cmsObjectList),
      unannotatedObjectList: data.dec(_f$unannotatedObjectList),
      stringListWithImageInner: data.dec(_f$stringListWithImageInner),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ArrayTestConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ArrayTestConfig>(map);
  }

  static ArrayTestConfig fromJson(String json) {
    return ensureInitialized().decodeJson<ArrayTestConfig>(json);
  }
}

mixin ArrayTestConfigMappable {
  String toJson() {
    return ArrayTestConfigMapper.ensureInitialized()
        .encodeJson<ArrayTestConfig>(this as ArrayTestConfig);
  }

  Map<String, dynamic> toMap() {
    return ArrayTestConfigMapper.ensureInitialized().encodeMap<ArrayTestConfig>(
      this as ArrayTestConfig,
    );
  }

  ArrayTestConfigCopyWith<ArrayTestConfig, ArrayTestConfig, ArrayTestConfig>
  get copyWith =>
      _ArrayTestConfigCopyWithImpl<ArrayTestConfig, ArrayTestConfig>(
        this as ArrayTestConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ArrayTestConfigMapper.ensureInitialized().stringifyValue(
      this as ArrayTestConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return ArrayTestConfigMapper.ensureInitialized().equalsValue(
      this as ArrayTestConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return ArrayTestConfigMapper.ensureInitialized().hashValue(
      this as ArrayTestConfig,
    );
  }
}

extension ArrayTestConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ArrayTestConfig, $Out> {
  ArrayTestConfigCopyWith<$R, ArrayTestConfig, $Out> get $asArrayTestConfig =>
      $base.as((v, t, t2) => _ArrayTestConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ArrayTestConfigCopyWith<$R, $In extends ArrayTestConfig, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get primitiveStrings;
  ListCopyWith<$R, HeroConfig, HeroConfigCopyWith<$R, HeroConfig, HeroConfig>>
  get cmsObjectList;
  ListCopyWith<$R, SampleConfig, ObjectCopyWith<$R, SampleConfig, SampleConfig>>
  get unannotatedObjectList;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get stringListWithImageInner;
  $R call({
    List<String>? primitiveStrings,
    List<HeroConfig>? cmsObjectList,
    List<SampleConfig>? unannotatedObjectList,
    List<String>? stringListWithImageInner,
  });
  ArrayTestConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ArrayTestConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ArrayTestConfig, $Out>
    implements ArrayTestConfigCopyWith<$R, ArrayTestConfig, $Out> {
  _ArrayTestConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ArrayTestConfig> $mapper =
      ArrayTestConfigMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get primitiveStrings => ListCopyWith(
    $value.primitiveStrings,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(primitiveStrings: v),
  );
  @override
  ListCopyWith<$R, HeroConfig, HeroConfigCopyWith<$R, HeroConfig, HeroConfig>>
  get cmsObjectList => ListCopyWith(
    $value.cmsObjectList,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(cmsObjectList: v),
  );
  @override
  ListCopyWith<$R, SampleConfig, ObjectCopyWith<$R, SampleConfig, SampleConfig>>
  get unannotatedObjectList => ListCopyWith(
    $value.unannotatedObjectList,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(unannotatedObjectList: v),
  );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get stringListWithImageInner => ListCopyWith(
    $value.stringListWithImageInner,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(stringListWithImageInner: v),
  );
  @override
  $R call({
    List<String>? primitiveStrings,
    List<HeroConfig>? cmsObjectList,
    List<SampleConfig>? unannotatedObjectList,
    List<String>? stringListWithImageInner,
  }) => $apply(
    FieldCopyWithData({
      if (primitiveStrings != null) #primitiveStrings: primitiveStrings,
      if (cmsObjectList != null) #cmsObjectList: cmsObjectList,
      if (unannotatedObjectList != null)
        #unannotatedObjectList: unannotatedObjectList,
      if (stringListWithImageInner != null)
        #stringListWithImageInner: stringListWithImageInner,
    }),
  );
  @override
  ArrayTestConfig $make(CopyWithData data) => ArrayTestConfig(
    primitiveStrings: data.get(#primitiveStrings, or: $value.primitiveStrings),
    cmsObjectList: data.get(#cmsObjectList, or: $value.cmsObjectList),
    unannotatedObjectList: data.get(
      #unannotatedObjectList,
      or: $value.unannotatedObjectList,
    ),
    stringListWithImageInner: data.get(
      #stringListWithImageInner,
      or: $value.stringListWithImageInner,
    ),
  );

  @override
  ArrayTestConfigCopyWith<$R2, ArrayTestConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ArrayTestConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

