// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'coupon.dart';

class CouponMapper extends ClassMapperBase<Coupon> {
  CouponMapper._();

  static CouponMapper? _instance;
  static CouponMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CouponMapper._());
      MapperContainer.globals.useAll([ImageReferenceMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'Coupon';

  static String _$title(Coupon v) => v.title;
  static const Field<Coupon, String> _f$title = Field('title', _$title);
  static String _$code(Coupon v) => v.code;
  static const Field<Coupon, String> _f$code = Field('code', _$code);
  static num _$discountPercent(Coupon v) => v.discountPercent;
  static const Field<Coupon, num> _f$discountPercent = Field(
    'discountPercent',
    _$discountPercent,
  );
  static DateTime _$expiresAt(Coupon v) => v.expiresAt;
  static const Field<Coupon, DateTime> _f$expiresAt = Field(
    'expiresAt',
    _$expiresAt,
  );
  static ImageReference? _$image(Coupon v) => v.image;
  static const Field<Coupon, ImageReference> _f$image = Field(
    'image',
    _$image,
    opt: true,
  );
  static List<String> _$tags(Coupon v) => v.tags;
  static const Field<Coupon, List<String>> _f$tags = Field('tags', _$tags);

  @override
  final MappableFields<Coupon> fields = const {
    #title: _f$title,
    #code: _f$code,
    #discountPercent: _f$discountPercent,
    #expiresAt: _f$expiresAt,
    #image: _f$image,
    #tags: _f$tags,
  };

  static Coupon _instantiate(DecodingData data) {
    return Coupon(
      title: data.dec(_f$title),
      code: data.dec(_f$code),
      discountPercent: data.dec(_f$discountPercent),
      expiresAt: data.dec(_f$expiresAt),
      image: data.dec(_f$image),
      tags: data.dec(_f$tags),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Coupon fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Coupon>(map);
  }

  static Coupon fromJson(String json) {
    return ensureInitialized().decodeJson<Coupon>(json);
  }
}

mixin CouponMappable {
  String toJson() {
    return CouponMapper.ensureInitialized().encodeJson<Coupon>(this as Coupon);
  }

  Map<String, dynamic> toMap() {
    return CouponMapper.ensureInitialized().encodeMap<Coupon>(this as Coupon);
  }

  CouponCopyWith<Coupon, Coupon, Coupon> get copyWith =>
      _CouponCopyWithImpl<Coupon, Coupon>(this as Coupon, $identity, $identity);
  @override
  String toString() {
    return CouponMapper.ensureInitialized().stringifyValue(this as Coupon);
  }

  @override
  bool operator ==(Object other) {
    return CouponMapper.ensureInitialized().equalsValue(this as Coupon, other);
  }

  @override
  int get hashCode {
    return CouponMapper.ensureInitialized().hashValue(this as Coupon);
  }
}

extension CouponValueCopy<$R, $Out> on ObjectCopyWith<$R, Coupon, $Out> {
  CouponCopyWith<$R, Coupon, $Out> get $asCoupon =>
      $base.as((v, t, t2) => _CouponCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CouponCopyWith<$R, $In extends Coupon, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags;
  $R call({
    String? title,
    String? code,
    num? discountPercent,
    DateTime? expiresAt,
    ImageReference? image,
    List<String>? tags,
  });
  CouponCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CouponCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Coupon, $Out>
    implements CouponCopyWith<$R, Coupon, $Out> {
  _CouponCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Coupon> $mapper = CouponMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags =>
      ListCopyWith(
        $value.tags,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(tags: v),
      );
  @override
  $R call({
    String? title,
    String? code,
    num? discountPercent,
    DateTime? expiresAt,
    Object? image = $none,
    List<String>? tags,
  }) => $apply(
    FieldCopyWithData({
      if (title != null) #title: title,
      if (code != null) #code: code,
      if (discountPercent != null) #discountPercent: discountPercent,
      if (expiresAt != null) #expiresAt: expiresAt,
      if (image != $none) #image: image,
      if (tags != null) #tags: tags,
    }),
  );
  @override
  Coupon $make(CopyWithData data) => Coupon(
    title: data.get(#title, or: $value.title),
    code: data.get(#code, or: $value.code),
    discountPercent: data.get(#discountPercent, or: $value.discountPercent),
    expiresAt: data.get(#expiresAt, or: $value.expiresAt),
    image: data.get(#image, or: $value.image),
    tags: data.get(#tags, or: $value.tags),
  );

  @override
  CouponCopyWith<$R2, Coupon, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CouponCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

