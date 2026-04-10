// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'promotion_campaign.dart';

class PromotionCampaignMapper extends SubClassMapperBase<PromotionCampaign> {
  PromotionCampaignMapper._();

  static PromotionCampaignMapper? _instance;
  static PromotionCampaignMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PromotionCampaignMapper._());
      CmsContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([
        PromotionColorMapper(),
        ImageReferenceMapper(),
      ]);
    }
    return _instance!;
  }

  @override
  final String id = 'PromotionCampaign';

  static String _$title(PromotionCampaign v) => v.title;
  static const Field<PromotionCampaign, String> _f$title = Field(
    'title',
    _$title,
  );
  static String _$promoCode(PromotionCampaign v) => v.promoCode;
  static const Field<PromotionCampaign, String> _f$promoCode = Field(
    'promoCode',
    _$promoCode,
  );
  static String _$termsAndConditions(PromotionCampaign v) =>
      v.termsAndConditions;
  static const Field<PromotionCampaign, String> _f$termsAndConditions = Field(
    'termsAndConditions',
    _$termsAndConditions,
  );
  static num _$discountPercent(PromotionCampaign v) => v.discountPercent;
  static const Field<PromotionCampaign, num> _f$discountPercent = Field(
    'discountPercent',
    _$discountPercent,
  );
  static String _$discountType(PromotionCampaign v) => v.discountType;
  static const Field<PromotionCampaign, String> _f$discountType = Field(
    'discountType',
    _$discountType,
  );
  static List<String> _$applicableCategories(PromotionCampaign v) =>
      v.applicableCategories;
  static const Field<PromotionCampaign, List<String>> _f$applicableCategories =
      Field('applicableCategories', _$applicableCategories);
  static bool _$isActive(PromotionCampaign v) => v.isActive;
  static const Field<PromotionCampaign, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
  );
  static DateTime? _$validFrom(PromotionCampaign v) => v.validFrom;
  static const Field<PromotionCampaign, DateTime> _f$validFrom = Field(
    'validFrom',
    _$validFrom,
    opt: true,
  );
  static DateTime? _$startsAt(PromotionCampaign v) => v.startsAt;
  static const Field<PromotionCampaign, DateTime> _f$startsAt = Field(
    'startsAt',
    _$startsAt,
    opt: true,
  );
  static DateTime? _$endsAt(PromotionCampaign v) => v.endsAt;
  static const Field<PromotionCampaign, DateTime> _f$endsAt = Field(
    'endsAt',
    _$endsAt,
    opt: true,
  );
  static Uri? _$landingPageUrl(PromotionCampaign v) => v.landingPageUrl;
  static const Field<PromotionCampaign, Uri> _f$landingPageUrl = Field(
    'landingPageUrl',
    _$landingPageUrl,
    opt: true,
  );
  static ImageReference? _$bannerImage(PromotionCampaign v) => v.bannerImage;
  static const Field<PromotionCampaign, ImageReference> _f$bannerImage = Field(
    'bannerImage',
    _$bannerImage,
    opt: true,
  );
  static String? _$termsDocument(PromotionCampaign v) => v.termsDocument;
  static const Field<PromotionCampaign, String> _f$termsDocument = Field(
    'termsDocument',
    _$termsDocument,
    opt: true,
  );
  static Object? _$promoContent(PromotionCampaign v) => v.promoContent;
  static const Field<PromotionCampaign, Object> _f$promoContent = Field(
    'promoContent',
    _$promoContent,
    opt: true,
  );

  @override
  final MappableFields<PromotionCampaign> fields = const {
    #title: _f$title,
    #promoCode: _f$promoCode,
    #termsAndConditions: _f$termsAndConditions,
    #discountPercent: _f$discountPercent,
    #discountType: _f$discountType,
    #applicableCategories: _f$applicableCategories,
    #isActive: _f$isActive,
    #validFrom: _f$validFrom,
    #startsAt: _f$startsAt,
    #endsAt: _f$endsAt,
    #landingPageUrl: _f$landingPageUrl,
    #bannerImage: _f$bannerImage,
    #termsDocument: _f$termsDocument,
    #promoContent: _f$promoContent,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'promotionCampaign';
  @override
  late final ClassMapperBase superMapper = CmsContentMapper.ensureInitialized();

  static PromotionCampaign _instantiate(DecodingData data) {
    return PromotionCampaign(
      title: data.dec(_f$title),
      promoCode: data.dec(_f$promoCode),
      termsAndConditions: data.dec(_f$termsAndConditions),
      discountPercent: data.dec(_f$discountPercent),
      discountType: data.dec(_f$discountType),
      applicableCategories: data.dec(_f$applicableCategories),
      isActive: data.dec(_f$isActive),
      validFrom: data.dec(_f$validFrom),
      startsAt: data.dec(_f$startsAt),
      endsAt: data.dec(_f$endsAt),
      landingPageUrl: data.dec(_f$landingPageUrl),
      bannerImage: data.dec(_f$bannerImage),
      termsDocument: data.dec(_f$termsDocument),
      promoContent: data.dec(_f$promoContent),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PromotionCampaign fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PromotionCampaign>(map);
  }

  static PromotionCampaign fromJson(String json) {
    return ensureInitialized().decodeJson<PromotionCampaign>(json);
  }
}

mixin PromotionCampaignMappable {
  String toJson() {
    return PromotionCampaignMapper.ensureInitialized()
        .encodeJson<PromotionCampaign>(this as PromotionCampaign);
  }

  Map<String, dynamic> toMap() {
    return PromotionCampaignMapper.ensureInitialized()
        .encodeMap<PromotionCampaign>(this as PromotionCampaign);
  }

  PromotionCampaignCopyWith<
    PromotionCampaign,
    PromotionCampaign,
    PromotionCampaign
  >
  get copyWith =>
      _PromotionCampaignCopyWithImpl<PromotionCampaign, PromotionCampaign>(
        this as PromotionCampaign,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PromotionCampaignMapper.ensureInitialized().stringifyValue(
      this as PromotionCampaign,
    );
  }

  @override
  bool operator ==(Object other) {
    return PromotionCampaignMapper.ensureInitialized().equalsValue(
      this as PromotionCampaign,
      other,
    );
  }

  @override
  int get hashCode {
    return PromotionCampaignMapper.ensureInitialized().hashValue(
      this as PromotionCampaign,
    );
  }
}

extension PromotionCampaignValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PromotionCampaign, $Out> {
  PromotionCampaignCopyWith<$R, PromotionCampaign, $Out>
  get $asPromotionCampaign => $base.as(
    (v, t, t2) => _PromotionCampaignCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class PromotionCampaignCopyWith<
  $R,
  $In extends PromotionCampaign,
  $Out
>
    implements CmsContentCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get applicableCategories;
  @override
  $R call({
    String? title,
    String? promoCode,
    String? termsAndConditions,
    num? discountPercent,
    String? discountType,
    List<String>? applicableCategories,
    bool? isActive,
    DateTime? validFrom,
    DateTime? startsAt,
    DateTime? endsAt,
    Uri? landingPageUrl,
    ImageReference? bannerImage,
    String? termsDocument,
    Object? promoContent,
  });
  PromotionCampaignCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PromotionCampaignCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PromotionCampaign, $Out>
    implements PromotionCampaignCopyWith<$R, PromotionCampaign, $Out> {
  _PromotionCampaignCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PromotionCampaign> $mapper =
      PromotionCampaignMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get applicableCategories => ListCopyWith(
    $value.applicableCategories,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(applicableCategories: v),
  );
  @override
  $R call({
    String? title,
    String? promoCode,
    String? termsAndConditions,
    num? discountPercent,
    String? discountType,
    List<String>? applicableCategories,
    bool? isActive,
    Object? validFrom = $none,
    Object? startsAt = $none,
    Object? endsAt = $none,
    Object? landingPageUrl = $none,
    Object? bannerImage = $none,
    Object? termsDocument = $none,
    Object? promoContent = $none,
  }) => $apply(
    FieldCopyWithData({
      if (title != null) #title: title,
      if (promoCode != null) #promoCode: promoCode,
      if (termsAndConditions != null) #termsAndConditions: termsAndConditions,
      if (discountPercent != null) #discountPercent: discountPercent,
      if (discountType != null) #discountType: discountType,
      if (applicableCategories != null)
        #applicableCategories: applicableCategories,
      if (isActive != null) #isActive: isActive,
      if (validFrom != $none) #validFrom: validFrom,
      if (startsAt != $none) #startsAt: startsAt,
      if (endsAt != $none) #endsAt: endsAt,
      if (landingPageUrl != $none) #landingPageUrl: landingPageUrl,
      if (bannerImage != $none) #bannerImage: bannerImage,
      if (termsDocument != $none) #termsDocument: termsDocument,
      if (promoContent != $none) #promoContent: promoContent,
    }),
  );
  @override
  PromotionCampaign $make(CopyWithData data) => PromotionCampaign(
    title: data.get(#title, or: $value.title),
    promoCode: data.get(#promoCode, or: $value.promoCode),
    termsAndConditions: data.get(
      #termsAndConditions,
      or: $value.termsAndConditions,
    ),
    discountPercent: data.get(#discountPercent, or: $value.discountPercent),
    discountType: data.get(#discountType, or: $value.discountType),
    applicableCategories: data.get(
      #applicableCategories,
      or: $value.applicableCategories,
    ),
    isActive: data.get(#isActive, or: $value.isActive),
    validFrom: data.get(#validFrom, or: $value.validFrom),
    startsAt: data.get(#startsAt, or: $value.startsAt),
    endsAt: data.get(#endsAt, or: $value.endsAt),
    landingPageUrl: data.get(#landingPageUrl, or: $value.landingPageUrl),
    bannerImage: data.get(#bannerImage, or: $value.bannerImage),
    termsDocument: data.get(#termsDocument, or: $value.termsDocument),
    promoContent: data.get(#promoContent, or: $value.promoContent),
  );

  @override
  PromotionCampaignCopyWith<$R2, PromotionCampaign, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PromotionCampaignCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

