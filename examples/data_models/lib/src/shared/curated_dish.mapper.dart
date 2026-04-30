// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'curated_dish.dart';

class CuratedDishMapper extends ClassMapperBase<CuratedDish> {
  CuratedDishMapper._();

  static CuratedDishMapper? _instance;
  static CuratedDishMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CuratedDishMapper._());
      MapperContainer.globals.useAll([ImageReferenceMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'CuratedDish';

  static String _$numberLabel(CuratedDish v) => v.numberLabel;
  static const Field<CuratedDish, String> _f$numberLabel = Field(
    'numberLabel',
    _$numberLabel,
  );
  static String _$name(CuratedDish v) => v.name;
  static const Field<CuratedDish, String> _f$name = Field('name', _$name);
  static num _$price(CuratedDish v) => v.price;
  static const Field<CuratedDish, num> _f$price = Field('price', _$price);
  static num? _$discountedPrice(CuratedDish v) => v.discountedPrice;
  static const Field<CuratedDish, num> _f$discountedPrice = Field(
    'discountedPrice',
    _$discountedPrice,
    opt: true,
  );
  static bool? _$isSeasonal(CuratedDish v) => v.isSeasonal;
  static const Field<CuratedDish, bool> _f$isSeasonal = Field(
    'isSeasonal',
    _$isSeasonal,
    opt: true,
  );
  static ImageReference? _$image(CuratedDish v) => v.image;
  static const Field<CuratedDish, ImageReference> _f$image = Field(
    'image',
    _$image,
    opt: true,
  );
  static Object? _$description(CuratedDish v) => v.description;
  static const Field<CuratedDish, Object> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );

  @override
  final MappableFields<CuratedDish> fields = const {
    #numberLabel: _f$numberLabel,
    #name: _f$name,
    #price: _f$price,
    #discountedPrice: _f$discountedPrice,
    #isSeasonal: _f$isSeasonal,
    #image: _f$image,
    #description: _f$description,
  };

  static CuratedDish _instantiate(DecodingData data) {
    return CuratedDish(
      numberLabel: data.dec(_f$numberLabel),
      name: data.dec(_f$name),
      price: data.dec(_f$price),
      discountedPrice: data.dec(_f$discountedPrice),
      isSeasonal: data.dec(_f$isSeasonal),
      image: data.dec(_f$image),
      description: data.dec(_f$description),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CuratedDish fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CuratedDish>(map);
  }

  static CuratedDish fromJson(String json) {
    return ensureInitialized().decodeJson<CuratedDish>(json);
  }
}

mixin CuratedDishMappable {
  String toJson() {
    return CuratedDishMapper.ensureInitialized().encodeJson<CuratedDish>(
      this as CuratedDish,
    );
  }

  Map<String, dynamic> toMap() {
    return CuratedDishMapper.ensureInitialized().encodeMap<CuratedDish>(
      this as CuratedDish,
    );
  }

  CuratedDishCopyWith<CuratedDish, CuratedDish, CuratedDish> get copyWith =>
      _CuratedDishCopyWithImpl<CuratedDish, CuratedDish>(
        this as CuratedDish,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CuratedDishMapper.ensureInitialized().stringifyValue(
      this as CuratedDish,
    );
  }

  @override
  bool operator ==(Object other) {
    return CuratedDishMapper.ensureInitialized().equalsValue(
      this as CuratedDish,
      other,
    );
  }

  @override
  int get hashCode {
    return CuratedDishMapper.ensureInitialized().hashValue(this as CuratedDish);
  }
}

extension CuratedDishValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CuratedDish, $Out> {
  CuratedDishCopyWith<$R, CuratedDish, $Out> get $asCuratedDish =>
      $base.as((v, t, t2) => _CuratedDishCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CuratedDishCopyWith<$R, $In extends CuratedDish, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? numberLabel,
    String? name,
    num? price,
    num? discountedPrice,
    bool? isSeasonal,
    ImageReference? image,
    Object? description,
  });
  CuratedDishCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CuratedDishCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CuratedDish, $Out>
    implements CuratedDishCopyWith<$R, CuratedDish, $Out> {
  _CuratedDishCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CuratedDish> $mapper =
      CuratedDishMapper.ensureInitialized();
  @override
  $R call({
    String? numberLabel,
    String? name,
    num? price,
    Object? discountedPrice = $none,
    Object? isSeasonal = $none,
    Object? image = $none,
    Object? description = $none,
  }) => $apply(
    FieldCopyWithData({
      if (numberLabel != null) #numberLabel: numberLabel,
      if (name != null) #name: name,
      if (price != null) #price: price,
      if (discountedPrice != $none) #discountedPrice: discountedPrice,
      if (isSeasonal != $none) #isSeasonal: isSeasonal,
      if (image != $none) #image: image,
      if (description != $none) #description: description,
    }),
  );
  @override
  CuratedDish $make(CopyWithData data) => CuratedDish(
    numberLabel: data.get(#numberLabel, or: $value.numberLabel),
    name: data.get(#name, or: $value.name),
    price: data.get(#price, or: $value.price),
    discountedPrice: data.get(#discountedPrice, or: $value.discountedPrice),
    isSeasonal: data.get(#isSeasonal, or: $value.isSeasonal),
    image: data.get(#image, or: $value.image),
    description: data.get(#description, or: $value.description),
  );

  @override
  CuratedDishCopyWith<$R2, CuratedDish, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CuratedDishCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

