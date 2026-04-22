// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'kiosk_product.dart';

class KioskProductMapper extends ClassMapperBase<KioskProduct> {
  KioskProductMapper._();

  static KioskProductMapper? _instance;
  static KioskProductMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = KioskProductMapper._());
      MapperContainer.globals.useAll([ImageReferenceMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'KioskProduct';

  static String _$name(KioskProduct v) => v.name;
  static const Field<KioskProduct, String> _f$name = Field('name', _$name);
  static num _$price(KioskProduct v) => v.price;
  static const Field<KioskProduct, num> _f$price = Field('price', _$price);
  static ImageReference? _$image(KioskProduct v) => v.image;
  static const Field<KioskProduct, ImageReference> _f$image = Field(
    'image',
    _$image,
    opt: true,
  );
  static String _$category(KioskProduct v) => v.category;
  static const Field<KioskProduct, String> _f$category = Field(
    'category',
    _$category,
  );

  @override
  final MappableFields<KioskProduct> fields = const {
    #name: _f$name,
    #price: _f$price,
    #image: _f$image,
    #category: _f$category,
  };

  static KioskProduct _instantiate(DecodingData data) {
    return KioskProduct(
      name: data.dec(_f$name),
      price: data.dec(_f$price),
      image: data.dec(_f$image),
      category: data.dec(_f$category),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static KioskProduct fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<KioskProduct>(map);
  }

  static KioskProduct fromJson(String json) {
    return ensureInitialized().decodeJson<KioskProduct>(json);
  }
}

mixin KioskProductMappable {
  String toJson() {
    return KioskProductMapper.ensureInitialized().encodeJson<KioskProduct>(
      this as KioskProduct,
    );
  }

  Map<String, dynamic> toMap() {
    return KioskProductMapper.ensureInitialized().encodeMap<KioskProduct>(
      this as KioskProduct,
    );
  }

  KioskProductCopyWith<KioskProduct, KioskProduct, KioskProduct> get copyWith =>
      _KioskProductCopyWithImpl<KioskProduct, KioskProduct>(
        this as KioskProduct,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return KioskProductMapper.ensureInitialized().stringifyValue(
      this as KioskProduct,
    );
  }

  @override
  bool operator ==(Object other) {
    return KioskProductMapper.ensureInitialized().equalsValue(
      this as KioskProduct,
      other,
    );
  }

  @override
  int get hashCode {
    return KioskProductMapper.ensureInitialized().hashValue(
      this as KioskProduct,
    );
  }
}

extension KioskProductValueCopy<$R, $Out>
    on ObjectCopyWith<$R, KioskProduct, $Out> {
  KioskProductCopyWith<$R, KioskProduct, $Out> get $asKioskProduct =>
      $base.as((v, t, t2) => _KioskProductCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class KioskProductCopyWith<$R, $In extends KioskProduct, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? name, num? price, ImageReference? image, String? category});
  KioskProductCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _KioskProductCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, KioskProduct, $Out>
    implements KioskProductCopyWith<$R, KioskProduct, $Out> {
  _KioskProductCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<KioskProduct> $mapper =
      KioskProductMapper.ensureInitialized();
  @override
  $R call({
    String? name,
    num? price,
    Object? image = $none,
    String? category,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (price != null) #price: price,
      if (image != $none) #image: image,
      if (category != null) #category: category,
    }),
  );
  @override
  KioskProduct $make(CopyWithData data) => KioskProduct(
    name: data.get(#name, or: $value.name),
    price: data.get(#price, or: $value.price),
    image: data.get(#image, or: $value.image),
    category: data.get(#category, or: $value.category),
  );

  @override
  KioskProductCopyWith<$R2, KioskProduct, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _KioskProductCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

