// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'featured_dish.dart';

class FeaturedDishMapper extends ClassMapperBase<FeaturedDish> {
  FeaturedDishMapper._();

  static FeaturedDishMapper? _instance;
  static FeaturedDishMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FeaturedDishMapper._());
      MapperContainer.globals.useAll([ImageReferenceMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'FeaturedDish';

  static String _$name(FeaturedDish v) => v.name;
  static const Field<FeaturedDish, String> _f$name = Field('name', _$name);
  static num _$price(FeaturedDish v) => v.price;
  static const Field<FeaturedDish, num> _f$price = Field('price', _$price);
  static String _$tag(FeaturedDish v) => v.tag;
  static const Field<FeaturedDish, String> _f$tag = Field('tag', _$tag);
  static ImageReference? _$image(FeaturedDish v) => v.image;
  static const Field<FeaturedDish, ImageReference> _f$image = Field(
    'image',
    _$image,
    opt: true,
  );

  @override
  final MappableFields<FeaturedDish> fields = const {
    #name: _f$name,
    #price: _f$price,
    #tag: _f$tag,
    #image: _f$image,
  };

  static FeaturedDish _instantiate(DecodingData data) {
    return FeaturedDish(
      name: data.dec(_f$name),
      price: data.dec(_f$price),
      tag: data.dec(_f$tag),
      image: data.dec(_f$image),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FeaturedDish fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FeaturedDish>(map);
  }

  static FeaturedDish fromJson(String json) {
    return ensureInitialized().decodeJson<FeaturedDish>(json);
  }
}

mixin FeaturedDishMappable {
  String toJson() {
    return FeaturedDishMapper.ensureInitialized().encodeJson<FeaturedDish>(
      this as FeaturedDish,
    );
  }

  Map<String, dynamic> toMap() {
    return FeaturedDishMapper.ensureInitialized().encodeMap<FeaturedDish>(
      this as FeaturedDish,
    );
  }

  FeaturedDishCopyWith<FeaturedDish, FeaturedDish, FeaturedDish> get copyWith =>
      _FeaturedDishCopyWithImpl<FeaturedDish, FeaturedDish>(
        this as FeaturedDish,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FeaturedDishMapper.ensureInitialized().stringifyValue(
      this as FeaturedDish,
    );
  }

  @override
  bool operator ==(Object other) {
    return FeaturedDishMapper.ensureInitialized().equalsValue(
      this as FeaturedDish,
      other,
    );
  }

  @override
  int get hashCode {
    return FeaturedDishMapper.ensureInitialized().hashValue(
      this as FeaturedDish,
    );
  }
}

extension FeaturedDishValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FeaturedDish, $Out> {
  FeaturedDishCopyWith<$R, FeaturedDish, $Out> get $asFeaturedDish =>
      $base.as((v, t, t2) => _FeaturedDishCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FeaturedDishCopyWith<$R, $In extends FeaturedDish, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? name, num? price, String? tag, ImageReference? image});
  FeaturedDishCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _FeaturedDishCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FeaturedDish, $Out>
    implements FeaturedDishCopyWith<$R, FeaturedDish, $Out> {
  _FeaturedDishCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FeaturedDish> $mapper =
      FeaturedDishMapper.ensureInitialized();
  @override
  $R call({String? name, num? price, String? tag, Object? image = $none}) =>
      $apply(
        FieldCopyWithData({
          if (name != null) #name: name,
          if (price != null) #price: price,
          if (tag != null) #tag: tag,
          if (image != $none) #image: image,
        }),
      );
  @override
  FeaturedDish $make(CopyWithData data) => FeaturedDish(
    name: data.get(#name, or: $value.name),
    price: data.get(#price, or: $value.price),
    tag: data.get(#tag, or: $value.tag),
    image: data.get(#image, or: $value.image),
  );

  @override
  FeaturedDishCopyWith<$R2, FeaturedDish, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FeaturedDishCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

