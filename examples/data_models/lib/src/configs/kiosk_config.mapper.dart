// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'kiosk_config.dart';

class KioskConfigMapper extends SubClassMapperBase<KioskConfig> {
  KioskConfigMapper._();

  static KioskConfigMapper? _instance;
  static KioskConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = KioskConfigMapper._());
      DeskContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([ImageReferenceMapper()]);
      KioskProductMapper.ensureInitialized();
      OrderLineMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'KioskConfig';

  static ImageReference? _$bannerImage(KioskConfig v) => v.bannerImage;
  static const Field<KioskConfig, ImageReference> _f$bannerImage = Field(
    'bannerImage',
    _$bannerImage,
    opt: true,
  );
  static String _$bannerHeadline(KioskConfig v) => v.bannerHeadline;
  static const Field<KioskConfig, String> _f$bannerHeadline = Field(
    'bannerHeadline',
    _$bannerHeadline,
  );
  static String _$bannerSubtitle(KioskConfig v) => v.bannerSubtitle;
  static const Field<KioskConfig, String> _f$bannerSubtitle = Field(
    'bannerSubtitle',
    _$bannerSubtitle,
  );
  static String _$promoBadge(KioskConfig v) => v.promoBadge;
  static const Field<KioskConfig, String> _f$promoBadge = Field(
    'promoBadge',
    _$promoBadge,
  );
  static List<KioskProduct> _$gridProducts(KioskConfig v) => v.gridProducts;
  static const Field<KioskConfig, List<KioskProduct>> _f$gridProducts = Field(
    'gridProducts',
    _$gridProducts,
  );
  static String _$sidebarTableLabel(KioskConfig v) => v.sidebarTableLabel;
  static const Field<KioskConfig, String> _f$sidebarTableLabel = Field(
    'sidebarTableLabel',
    _$sidebarTableLabel,
  );
  static List<OrderLine> _$sidebarSampleOrder(KioskConfig v) =>
      v.sidebarSampleOrder;
  static const Field<KioskConfig, List<OrderLine>> _f$sidebarSampleOrder =
      Field('sidebarSampleOrder', _$sidebarSampleOrder);
  static String _$footerNote(KioskConfig v) => v.footerNote;
  static const Field<KioskConfig, String> _f$footerNote = Field(
    'footerNote',
    _$footerNote,
  );

  @override
  final MappableFields<KioskConfig> fields = const {
    #bannerImage: _f$bannerImage,
    #bannerHeadline: _f$bannerHeadline,
    #bannerSubtitle: _f$bannerSubtitle,
    #promoBadge: _f$promoBadge,
    #gridProducts: _f$gridProducts,
    #sidebarTableLabel: _f$sidebarTableLabel,
    #sidebarSampleOrder: _f$sidebarSampleOrder,
    #footerNote: _f$footerNote,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'kioskConfig';
  @override
  late final ClassMapperBase superMapper =
      DeskContentMapper.ensureInitialized();

  static KioskConfig _instantiate(DecodingData data) {
    return KioskConfig(
      bannerImage: data.dec(_f$bannerImage),
      bannerHeadline: data.dec(_f$bannerHeadline),
      bannerSubtitle: data.dec(_f$bannerSubtitle),
      promoBadge: data.dec(_f$promoBadge),
      gridProducts: data.dec(_f$gridProducts),
      sidebarTableLabel: data.dec(_f$sidebarTableLabel),
      sidebarSampleOrder: data.dec(_f$sidebarSampleOrder),
      footerNote: data.dec(_f$footerNote),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static KioskConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<KioskConfig>(map);
  }

  static KioskConfig fromJson(String json) {
    return ensureInitialized().decodeJson<KioskConfig>(json);
  }
}

mixin KioskConfigMappable {
  String toJson() {
    return KioskConfigMapper.ensureInitialized().encodeJson<KioskConfig>(
      this as KioskConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return KioskConfigMapper.ensureInitialized().encodeMap<KioskConfig>(
      this as KioskConfig,
    );
  }

  KioskConfigCopyWith<KioskConfig, KioskConfig, KioskConfig> get copyWith =>
      _KioskConfigCopyWithImpl<KioskConfig, KioskConfig>(
        this as KioskConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return KioskConfigMapper.ensureInitialized().stringifyValue(
      this as KioskConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return KioskConfigMapper.ensureInitialized().equalsValue(
      this as KioskConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return KioskConfigMapper.ensureInitialized().hashValue(this as KioskConfig);
  }
}

extension KioskConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, KioskConfig, $Out> {
  KioskConfigCopyWith<$R, KioskConfig, $Out> get $asKioskConfig =>
      $base.as((v, t, t2) => _KioskConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class KioskConfigCopyWith<$R, $In extends KioskConfig, $Out>
    implements DeskContentCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    KioskProduct,
    KioskProductCopyWith<$R, KioskProduct, KioskProduct>
  >
  get gridProducts;
  ListCopyWith<$R, OrderLine, OrderLineCopyWith<$R, OrderLine, OrderLine>>
  get sidebarSampleOrder;
  @override
  $R call({
    ImageReference? bannerImage,
    String? bannerHeadline,
    String? bannerSubtitle,
    String? promoBadge,
    List<KioskProduct>? gridProducts,
    String? sidebarTableLabel,
    List<OrderLine>? sidebarSampleOrder,
    String? footerNote,
  });
  KioskConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _KioskConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, KioskConfig, $Out>
    implements KioskConfigCopyWith<$R, KioskConfig, $Out> {
  _KioskConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<KioskConfig> $mapper =
      KioskConfigMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    KioskProduct,
    KioskProductCopyWith<$R, KioskProduct, KioskProduct>
  >
  get gridProducts => ListCopyWith(
    $value.gridProducts,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(gridProducts: v),
  );
  @override
  ListCopyWith<$R, OrderLine, OrderLineCopyWith<$R, OrderLine, OrderLine>>
  get sidebarSampleOrder => ListCopyWith(
    $value.sidebarSampleOrder,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(sidebarSampleOrder: v),
  );
  @override
  $R call({
    Object? bannerImage = $none,
    String? bannerHeadline,
    String? bannerSubtitle,
    String? promoBadge,
    List<KioskProduct>? gridProducts,
    String? sidebarTableLabel,
    List<OrderLine>? sidebarSampleOrder,
    String? footerNote,
  }) => $apply(
    FieldCopyWithData({
      if (bannerImage != $none) #bannerImage: bannerImage,
      if (bannerHeadline != null) #bannerHeadline: bannerHeadline,
      if (bannerSubtitle != null) #bannerSubtitle: bannerSubtitle,
      if (promoBadge != null) #promoBadge: promoBadge,
      if (gridProducts != null) #gridProducts: gridProducts,
      if (sidebarTableLabel != null) #sidebarTableLabel: sidebarTableLabel,
      if (sidebarSampleOrder != null) #sidebarSampleOrder: sidebarSampleOrder,
      if (footerNote != null) #footerNote: footerNote,
    }),
  );
  @override
  KioskConfig $make(CopyWithData data) => KioskConfig(
    bannerImage: data.get(#bannerImage, or: $value.bannerImage),
    bannerHeadline: data.get(#bannerHeadline, or: $value.bannerHeadline),
    bannerSubtitle: data.get(#bannerSubtitle, or: $value.bannerSubtitle),
    promoBadge: data.get(#promoBadge, or: $value.promoBadge),
    gridProducts: data.get(#gridProducts, or: $value.gridProducts),
    sidebarTableLabel: data.get(
      #sidebarTableLabel,
      or: $value.sidebarTableLabel,
    ),
    sidebarSampleOrder: data.get(
      #sidebarSampleOrder,
      or: $value.sidebarSampleOrder,
    ),
    footerNote: data.get(#footerNote, or: $value.footerNote),
  );

  @override
  KioskConfigCopyWith<$R2, KioskConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _KioskConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

