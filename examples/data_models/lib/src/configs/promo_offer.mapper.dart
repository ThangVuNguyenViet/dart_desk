// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'promo_offer.dart';

class PromoOfferMapper extends ClassMapperBase<PromoOffer> {
  PromoOfferMapper._();

  static PromoOfferMapper? _instance;
  static PromoOfferMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PromoOfferMapper._());
      MapperContainer.globals.useAll([ColorMapper(), ImageReferenceMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'PromoOffer';

  static String _$title(PromoOffer v) => v.title;
  static const Field<PromoOffer, String> _f$title = Field('title', _$title);
  static String _$description(PromoOffer v) => v.description;
  static const Field<PromoOffer, String> _f$description = Field(
    'description',
    _$description,
  );
  static ImageReference? _$bannerImage(PromoOffer v) => v.bannerImage;
  static const Field<PromoOffer, ImageReference> _f$bannerImage = Field(
    'bannerImage',
    _$bannerImage,
    opt: true,
  );
  static String _$promoCode(PromoOffer v) => v.promoCode;
  static const Field<PromoOffer, String> _f$promoCode = Field(
    'promoCode',
    _$promoCode,
  );
  static num _$discountPercent(PromoOffer v) => v.discountPercent;
  static const Field<PromoOffer, num> _f$discountPercent = Field(
    'discountPercent',
    _$discountPercent,
  );
  static DateTime _$validFrom(PromoOffer v) => v.validFrom;
  static const Field<PromoOffer, DateTime> _f$validFrom = Field(
    'validFrom',
    _$validFrom,
  );
  static DateTime _$validUntil(PromoOffer v) => v.validUntil;
  static const Field<PromoOffer, DateTime> _f$validUntil = Field(
    'validUntil',
    _$validUntil,
  );
  static Color _$bannerColor(PromoOffer v) => v.bannerColor;
  static const Field<PromoOffer, Color> _f$bannerColor = Field(
    'bannerColor',
    _$bannerColor,
  );
  static Color _$textColor(PromoOffer v) => v.textColor;
  static const Field<PromoOffer, Color> _f$textColor = Field(
    'textColor',
    _$textColor,
  );
  static String _$priority(PromoOffer v) => v.priority;
  static const Field<PromoOffer, String> _f$priority = Field(
    'priority',
    _$priority,
  );
  static String? _$termsUrl(PromoOffer v) => v.termsUrl;
  static const Field<PromoOffer, String> _f$termsUrl = Field(
    'termsUrl',
    _$termsUrl,
    opt: true,
  );
  static bool _$active(PromoOffer v) => v.active;
  static const Field<PromoOffer, bool> _f$active = Field('active', _$active);

  @override
  final MappableFields<PromoOffer> fields = const {
    #title: _f$title,
    #description: _f$description,
    #bannerImage: _f$bannerImage,
    #promoCode: _f$promoCode,
    #discountPercent: _f$discountPercent,
    #validFrom: _f$validFrom,
    #validUntil: _f$validUntil,
    #bannerColor: _f$bannerColor,
    #textColor: _f$textColor,
    #priority: _f$priority,
    #termsUrl: _f$termsUrl,
    #active: _f$active,
  };

  static PromoOffer _instantiate(DecodingData data) {
    return PromoOffer(
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      bannerImage: data.dec(_f$bannerImage),
      promoCode: data.dec(_f$promoCode),
      discountPercent: data.dec(_f$discountPercent),
      validFrom: data.dec(_f$validFrom),
      validUntil: data.dec(_f$validUntil),
      bannerColor: data.dec(_f$bannerColor),
      textColor: data.dec(_f$textColor),
      priority: data.dec(_f$priority),
      termsUrl: data.dec(_f$termsUrl),
      active: data.dec(_f$active),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PromoOffer fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PromoOffer>(map);
  }

  static PromoOffer fromJson(String json) {
    return ensureInitialized().decodeJson<PromoOffer>(json);
  }
}

mixin PromoOfferMappable {
  String toJson() {
    return PromoOfferMapper.ensureInitialized().encodeJson<PromoOffer>(
      this as PromoOffer,
    );
  }

  Map<String, dynamic> toMap() {
    return PromoOfferMapper.ensureInitialized().encodeMap<PromoOffer>(
      this as PromoOffer,
    );
  }

  PromoOfferCopyWith<PromoOffer, PromoOffer, PromoOffer> get copyWith =>
      _PromoOfferCopyWithImpl<PromoOffer, PromoOffer>(
        this as PromoOffer,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PromoOfferMapper.ensureInitialized().stringifyValue(
      this as PromoOffer,
    );
  }

  @override
  bool operator ==(Object other) {
    return PromoOfferMapper.ensureInitialized().equalsValue(
      this as PromoOffer,
      other,
    );
  }

  @override
  int get hashCode {
    return PromoOfferMapper.ensureInitialized().hashValue(this as PromoOffer);
  }
}

extension PromoOfferValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PromoOffer, $Out> {
  PromoOfferCopyWith<$R, PromoOffer, $Out> get $asPromoOffer =>
      $base.as((v, t, t2) => _PromoOfferCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PromoOfferCopyWith<$R, $In extends PromoOffer, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? title,
    String? description,
    ImageReference? bannerImage,
    String? promoCode,
    num? discountPercent,
    DateTime? validFrom,
    DateTime? validUntil,
    Color? bannerColor,
    Color? textColor,
    String? priority,
    String? termsUrl,
    bool? active,
  });
  PromoOfferCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PromoOfferCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PromoOffer, $Out>
    implements PromoOfferCopyWith<$R, PromoOffer, $Out> {
  _PromoOfferCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PromoOffer> $mapper =
      PromoOfferMapper.ensureInitialized();
  @override
  $R call({
    String? title,
    String? description,
    Object? bannerImage = $none,
    String? promoCode,
    num? discountPercent,
    DateTime? validFrom,
    DateTime? validUntil,
    Color? bannerColor,
    Color? textColor,
    String? priority,
    Object? termsUrl = $none,
    bool? active,
  }) => $apply(
    FieldCopyWithData({
      if (title != null) #title: title,
      if (description != null) #description: description,
      if (bannerImage != $none) #bannerImage: bannerImage,
      if (promoCode != null) #promoCode: promoCode,
      if (discountPercent != null) #discountPercent: discountPercent,
      if (validFrom != null) #validFrom: validFrom,
      if (validUntil != null) #validUntil: validUntil,
      if (bannerColor != null) #bannerColor: bannerColor,
      if (textColor != null) #textColor: textColor,
      if (priority != null) #priority: priority,
      if (termsUrl != $none) #termsUrl: termsUrl,
      if (active != null) #active: active,
    }),
  );
  @override
  PromoOffer $make(CopyWithData data) => PromoOffer(
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    bannerImage: data.get(#bannerImage, or: $value.bannerImage),
    promoCode: data.get(#promoCode, or: $value.promoCode),
    discountPercent: data.get(#discountPercent, or: $value.discountPercent),
    validFrom: data.get(#validFrom, or: $value.validFrom),
    validUntil: data.get(#validUntil, or: $value.validUntil),
    bannerColor: data.get(#bannerColor, or: $value.bannerColor),
    textColor: data.get(#textColor, or: $value.textColor),
    priority: data.get(#priority, or: $value.priority),
    termsUrl: data.get(#termsUrl, or: $value.termsUrl),
    active: data.get(#active, or: $value.active),
  );

  @override
  PromoOfferCopyWith<$R2, PromoOffer, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PromoOfferCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

