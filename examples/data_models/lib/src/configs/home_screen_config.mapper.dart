// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'home_screen_config.dart';

class HomeScreenConfigMapper extends ClassMapperBase<HomeScreenConfig> {
  HomeScreenConfigMapper._();

  static HomeScreenConfigMapper? _instance;
  static HomeScreenConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HomeScreenConfigMapper._());
      MapperContainer.globals.useAll([ColorMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'HomeScreenConfig';

  static String _$heroTitle(HomeScreenConfig v) => v.heroTitle;
  static const Field<HomeScreenConfig, String> _f$heroTitle = Field(
    'heroTitle',
    _$heroTitle,
  );
  static String _$heroSubtitle(HomeScreenConfig v) => v.heroSubtitle;
  static const Field<HomeScreenConfig, String> _f$heroSubtitle = Field(
    'heroSubtitle',
    _$heroSubtitle,
  );
  static String _$backgroundImageUrl(HomeScreenConfig v) =>
      v.backgroundImageUrl;
  static const Field<HomeScreenConfig, String> _f$backgroundImageUrl = Field(
    'backgroundImageUrl',
    _$backgroundImageUrl,
  );
  static bool _$enableDarkOverlay(HomeScreenConfig v) => v.enableDarkOverlay;
  static const Field<HomeScreenConfig, bool> _f$enableDarkOverlay = Field(
    'enableDarkOverlay',
    _$enableDarkOverlay,
  );
  static Color _$primaryColor(HomeScreenConfig v) => v.primaryColor;
  static const Field<HomeScreenConfig, Color> _f$primaryColor = Field(
    'primaryColor',
    _$primaryColor,
  );
  static Color _$accentColor(HomeScreenConfig v) => v.accentColor;
  static const Field<HomeScreenConfig, Color> _f$accentColor = Field(
    'accentColor',
    _$accentColor,
  );
  static List<String> _$featuredItems(HomeScreenConfig v) => v.featuredItems;
  static const Field<HomeScreenConfig, List<String>> _f$featuredItems = Field(
    'featuredItems',
    _$featuredItems,
  );
  static int _$maxFeaturedItems(HomeScreenConfig v) => v.maxFeaturedItems;
  static const Field<HomeScreenConfig, int> _f$maxFeaturedItems = Field(
    'maxFeaturedItems',
    _$maxFeaturedItems,
  );
  static double _$heroOverlayOpacity(HomeScreenConfig v) =>
      v.heroOverlayOpacity;
  static const Field<HomeScreenConfig, double> _f$heroOverlayOpacity = Field(
    'heroOverlayOpacity',
    _$heroOverlayOpacity,
  );
  static bool _$showPromotionalBanner(HomeScreenConfig v) =>
      v.showPromotionalBanner;
  static const Field<HomeScreenConfig, bool> _f$showPromotionalBanner = Field(
    'showPromotionalBanner',
    _$showPromotionalBanner,
  );
  static String _$bannerHeadline(HomeScreenConfig v) => v.bannerHeadline;
  static const Field<HomeScreenConfig, String> _f$bannerHeadline = Field(
    'bannerHeadline',
    _$bannerHeadline,
  );
  static String _$bannerBody(HomeScreenConfig v) => v.bannerBody;
  static const Field<HomeScreenConfig, String> _f$bannerBody = Field(
    'bannerBody',
    _$bannerBody,
  );
  static DateTime? _$promoStartDate(HomeScreenConfig v) => v.promoStartDate;
  static const Field<HomeScreenConfig, DateTime> _f$promoStartDate = Field(
    'promoStartDate',
    _$promoStartDate,
    opt: true,
  );
  static DateTime? _$promoEndDate(HomeScreenConfig v) => v.promoEndDate;
  static const Field<HomeScreenConfig, DateTime> _f$promoEndDate = Field(
    'promoEndDate',
    _$promoEndDate,
    opt: true,
  );
  static DateTime _$lastUpdated(HomeScreenConfig v) => v.lastUpdated;
  static const Field<HomeScreenConfig, DateTime> _f$lastUpdated = Field(
    'lastUpdated',
    _$lastUpdated,
  );
  static String? _$externalLink(HomeScreenConfig v) => v.externalLink;
  static const Field<HomeScreenConfig, String> _f$externalLink = Field(
    'externalLink',
    _$externalLink,
    opt: true,
  );
  static String? _$downloadableResource(HomeScreenConfig v) =>
      v.downloadableResource;
  static const Field<HomeScreenConfig, String> _f$downloadableResource = Field(
    'downloadableResource',
    _$downloadableResource,
    opt: true,
  );
  static String? _$footerLogoUrl(HomeScreenConfig v) => v.footerLogoUrl;
  static const Field<HomeScreenConfig, String> _f$footerLogoUrl = Field(
    'footerLogoUrl',
    _$footerLogoUrl,
    opt: true,
  );
  static String _$primaryButtonLabel(HomeScreenConfig v) =>
      v.primaryButtonLabel;
  static const Field<HomeScreenConfig, String> _f$primaryButtonLabel = Field(
    'primaryButtonLabel',
    _$primaryButtonLabel,
  );
  static String? _$primaryButtonUrl(HomeScreenConfig v) => v.primaryButtonUrl;
  static const Field<HomeScreenConfig, String> _f$primaryButtonUrl = Field(
    'primaryButtonUrl',
    _$primaryButtonUrl,
    opt: true,
  );
  static String _$secondaryButtonLabel(HomeScreenConfig v) =>
      v.secondaryButtonLabel;
  static const Field<HomeScreenConfig, String> _f$secondaryButtonLabel = Field(
    'secondaryButtonLabel',
    _$secondaryButtonLabel,
  );
  static String _$layoutStyle(HomeScreenConfig v) => v.layoutStyle;
  static const Field<HomeScreenConfig, String> _f$layoutStyle = Field(
    'layoutStyle',
    _$layoutStyle,
  );
  static double _$contentPadding(HomeScreenConfig v) => v.contentPadding;
  static const Field<HomeScreenConfig, double> _f$contentPadding = Field(
    'contentPadding',
    _$contentPadding,
  );
  static int _$gridColumns(HomeScreenConfig v) => v.gridColumns;
  static const Field<HomeScreenConfig, int> _f$gridColumns = Field(
    'gridColumns',
    _$gridColumns,
  );
  static bool _$showFooter(HomeScreenConfig v) => v.showFooter;
  static const Field<HomeScreenConfig, bool> _f$showFooter = Field(
    'showFooter',
    _$showFooter,
  );
  static String? _$metaTitle(HomeScreenConfig v) => v.metaTitle;
  static const Field<HomeScreenConfig, String> _f$metaTitle = Field(
    'metaTitle',
    _$metaTitle,
    opt: true,
  );
  static String? _$metaDescription(HomeScreenConfig v) => v.metaDescription;
  static const Field<HomeScreenConfig, String> _f$metaDescription = Field(
    'metaDescription',
    _$metaDescription,
    opt: true,
  );

  @override
  final MappableFields<HomeScreenConfig> fields = const {
    #heroTitle: _f$heroTitle,
    #heroSubtitle: _f$heroSubtitle,
    #backgroundImageUrl: _f$backgroundImageUrl,
    #enableDarkOverlay: _f$enableDarkOverlay,
    #primaryColor: _f$primaryColor,
    #accentColor: _f$accentColor,
    #featuredItems: _f$featuredItems,
    #maxFeaturedItems: _f$maxFeaturedItems,
    #heroOverlayOpacity: _f$heroOverlayOpacity,
    #showPromotionalBanner: _f$showPromotionalBanner,
    #bannerHeadline: _f$bannerHeadline,
    #bannerBody: _f$bannerBody,
    #promoStartDate: _f$promoStartDate,
    #promoEndDate: _f$promoEndDate,
    #lastUpdated: _f$lastUpdated,
    #externalLink: _f$externalLink,
    #downloadableResource: _f$downloadableResource,
    #footerLogoUrl: _f$footerLogoUrl,
    #primaryButtonLabel: _f$primaryButtonLabel,
    #primaryButtonUrl: _f$primaryButtonUrl,
    #secondaryButtonLabel: _f$secondaryButtonLabel,
    #layoutStyle: _f$layoutStyle,
    #contentPadding: _f$contentPadding,
    #gridColumns: _f$gridColumns,
    #showFooter: _f$showFooter,
    #metaTitle: _f$metaTitle,
    #metaDescription: _f$metaDescription,
  };

  static HomeScreenConfig _instantiate(DecodingData data) {
    return HomeScreenConfig(
      heroTitle: data.dec(_f$heroTitle),
      heroSubtitle: data.dec(_f$heroSubtitle),
      backgroundImageUrl: data.dec(_f$backgroundImageUrl),
      enableDarkOverlay: data.dec(_f$enableDarkOverlay),
      primaryColor: data.dec(_f$primaryColor),
      accentColor: data.dec(_f$accentColor),
      featuredItems: data.dec(_f$featuredItems),
      maxFeaturedItems: data.dec(_f$maxFeaturedItems),
      heroOverlayOpacity: data.dec(_f$heroOverlayOpacity),
      showPromotionalBanner: data.dec(_f$showPromotionalBanner),
      bannerHeadline: data.dec(_f$bannerHeadline),
      bannerBody: data.dec(_f$bannerBody),
      promoStartDate: data.dec(_f$promoStartDate),
      promoEndDate: data.dec(_f$promoEndDate),
      lastUpdated: data.dec(_f$lastUpdated),
      externalLink: data.dec(_f$externalLink),
      downloadableResource: data.dec(_f$downloadableResource),
      footerLogoUrl: data.dec(_f$footerLogoUrl),
      primaryButtonLabel: data.dec(_f$primaryButtonLabel),
      primaryButtonUrl: data.dec(_f$primaryButtonUrl),
      secondaryButtonLabel: data.dec(_f$secondaryButtonLabel),
      layoutStyle: data.dec(_f$layoutStyle),
      contentPadding: data.dec(_f$contentPadding),
      gridColumns: data.dec(_f$gridColumns),
      showFooter: data.dec(_f$showFooter),
      metaTitle: data.dec(_f$metaTitle),
      metaDescription: data.dec(_f$metaDescription),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static HomeScreenConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HomeScreenConfig>(map);
  }

  static HomeScreenConfig fromJson(String json) {
    return ensureInitialized().decodeJson<HomeScreenConfig>(json);
  }
}

mixin HomeScreenConfigMappable {
  String toJson() {
    return HomeScreenConfigMapper.ensureInitialized()
        .encodeJson<HomeScreenConfig>(this as HomeScreenConfig);
  }

  Map<String, dynamic> toMap() {
    return HomeScreenConfigMapper.ensureInitialized()
        .encodeMap<HomeScreenConfig>(this as HomeScreenConfig);
  }

  HomeScreenConfigCopyWith<HomeScreenConfig, HomeScreenConfig, HomeScreenConfig>
  get copyWith =>
      _HomeScreenConfigCopyWithImpl<HomeScreenConfig, HomeScreenConfig>(
        this as HomeScreenConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HomeScreenConfigMapper.ensureInitialized().stringifyValue(
      this as HomeScreenConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return HomeScreenConfigMapper.ensureInitialized().equalsValue(
      this as HomeScreenConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return HomeScreenConfigMapper.ensureInitialized().hashValue(
      this as HomeScreenConfig,
    );
  }
}

extension HomeScreenConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HomeScreenConfig, $Out> {
  HomeScreenConfigCopyWith<$R, HomeScreenConfig, $Out>
  get $asHomeScreenConfig =>
      $base.as((v, t, t2) => _HomeScreenConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HomeScreenConfigCopyWith<$R, $In extends HomeScreenConfig, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get featuredItems;
  $R call({
    String? heroTitle,
    String? heroSubtitle,
    String? backgroundImageUrl,
    bool? enableDarkOverlay,
    Color? primaryColor,
    Color? accentColor,
    List<String>? featuredItems,
    int? maxFeaturedItems,
    double? heroOverlayOpacity,
    bool? showPromotionalBanner,
    String? bannerHeadline,
    String? bannerBody,
    DateTime? promoStartDate,
    DateTime? promoEndDate,
    DateTime? lastUpdated,
    String? externalLink,
    String? downloadableResource,
    String? footerLogoUrl,
    String? primaryButtonLabel,
    String? primaryButtonUrl,
    String? secondaryButtonLabel,
    String? layoutStyle,
    double? contentPadding,
    int? gridColumns,
    bool? showFooter,
    String? metaTitle,
    String? metaDescription,
  });
  HomeScreenConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _HomeScreenConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HomeScreenConfig, $Out>
    implements HomeScreenConfigCopyWith<$R, HomeScreenConfig, $Out> {
  _HomeScreenConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HomeScreenConfig> $mapper =
      HomeScreenConfigMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get featuredItems => ListCopyWith(
    $value.featuredItems,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(featuredItems: v),
  );
  @override
  $R call({
    String? heroTitle,
    String? heroSubtitle,
    String? backgroundImageUrl,
    bool? enableDarkOverlay,
    Color? primaryColor,
    Color? accentColor,
    List<String>? featuredItems,
    int? maxFeaturedItems,
    double? heroOverlayOpacity,
    bool? showPromotionalBanner,
    String? bannerHeadline,
    String? bannerBody,
    Object? promoStartDate = $none,
    Object? promoEndDate = $none,
    DateTime? lastUpdated,
    Object? externalLink = $none,
    Object? downloadableResource = $none,
    Object? footerLogoUrl = $none,
    String? primaryButtonLabel,
    Object? primaryButtonUrl = $none,
    String? secondaryButtonLabel,
    String? layoutStyle,
    double? contentPadding,
    int? gridColumns,
    bool? showFooter,
    Object? metaTitle = $none,
    Object? metaDescription = $none,
  }) => $apply(
    FieldCopyWithData({
      if (heroTitle != null) #heroTitle: heroTitle,
      if (heroSubtitle != null) #heroSubtitle: heroSubtitle,
      if (backgroundImageUrl != null) #backgroundImageUrl: backgroundImageUrl,
      if (enableDarkOverlay != null) #enableDarkOverlay: enableDarkOverlay,
      if (primaryColor != null) #primaryColor: primaryColor,
      if (accentColor != null) #accentColor: accentColor,
      if (featuredItems != null) #featuredItems: featuredItems,
      if (maxFeaturedItems != null) #maxFeaturedItems: maxFeaturedItems,
      if (heroOverlayOpacity != null) #heroOverlayOpacity: heroOverlayOpacity,
      if (showPromotionalBanner != null)
        #showPromotionalBanner: showPromotionalBanner,
      if (bannerHeadline != null) #bannerHeadline: bannerHeadline,
      if (bannerBody != null) #bannerBody: bannerBody,
      if (promoStartDate != $none) #promoStartDate: promoStartDate,
      if (promoEndDate != $none) #promoEndDate: promoEndDate,
      if (lastUpdated != null) #lastUpdated: lastUpdated,
      if (externalLink != $none) #externalLink: externalLink,
      if (downloadableResource != $none)
        #downloadableResource: downloadableResource,
      if (footerLogoUrl != $none) #footerLogoUrl: footerLogoUrl,
      if (primaryButtonLabel != null) #primaryButtonLabel: primaryButtonLabel,
      if (primaryButtonUrl != $none) #primaryButtonUrl: primaryButtonUrl,
      if (secondaryButtonLabel != null)
        #secondaryButtonLabel: secondaryButtonLabel,
      if (layoutStyle != null) #layoutStyle: layoutStyle,
      if (contentPadding != null) #contentPadding: contentPadding,
      if (gridColumns != null) #gridColumns: gridColumns,
      if (showFooter != null) #showFooter: showFooter,
      if (metaTitle != $none) #metaTitle: metaTitle,
      if (metaDescription != $none) #metaDescription: metaDescription,
    }),
  );
  @override
  HomeScreenConfig $make(CopyWithData data) => HomeScreenConfig(
    heroTitle: data.get(#heroTitle, or: $value.heroTitle),
    heroSubtitle: data.get(#heroSubtitle, or: $value.heroSubtitle),
    backgroundImageUrl: data.get(
      #backgroundImageUrl,
      or: $value.backgroundImageUrl,
    ),
    enableDarkOverlay: data.get(
      #enableDarkOverlay,
      or: $value.enableDarkOverlay,
    ),
    primaryColor: data.get(#primaryColor, or: $value.primaryColor),
    accentColor: data.get(#accentColor, or: $value.accentColor),
    featuredItems: data.get(#featuredItems, or: $value.featuredItems),
    maxFeaturedItems: data.get(#maxFeaturedItems, or: $value.maxFeaturedItems),
    heroOverlayOpacity: data.get(
      #heroOverlayOpacity,
      or: $value.heroOverlayOpacity,
    ),
    showPromotionalBanner: data.get(
      #showPromotionalBanner,
      or: $value.showPromotionalBanner,
    ),
    bannerHeadline: data.get(#bannerHeadline, or: $value.bannerHeadline),
    bannerBody: data.get(#bannerBody, or: $value.bannerBody),
    promoStartDate: data.get(#promoStartDate, or: $value.promoStartDate),
    promoEndDate: data.get(#promoEndDate, or: $value.promoEndDate),
    lastUpdated: data.get(#lastUpdated, or: $value.lastUpdated),
    externalLink: data.get(#externalLink, or: $value.externalLink),
    downloadableResource: data.get(
      #downloadableResource,
      or: $value.downloadableResource,
    ),
    footerLogoUrl: data.get(#footerLogoUrl, or: $value.footerLogoUrl),
    primaryButtonLabel: data.get(
      #primaryButtonLabel,
      or: $value.primaryButtonLabel,
    ),
    primaryButtonUrl: data.get(#primaryButtonUrl, or: $value.primaryButtonUrl),
    secondaryButtonLabel: data.get(
      #secondaryButtonLabel,
      or: $value.secondaryButtonLabel,
    ),
    layoutStyle: data.get(#layoutStyle, or: $value.layoutStyle),
    contentPadding: data.get(#contentPadding, or: $value.contentPadding),
    gridColumns: data.get(#gridColumns, or: $value.gridColumns),
    showFooter: data.get(#showFooter, or: $value.showFooter),
    metaTitle: data.get(#metaTitle, or: $value.metaTitle),
    metaDescription: data.get(#metaDescription, or: $value.metaDescription),
  );

  @override
  HomeScreenConfigCopyWith<$R2, HomeScreenConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _HomeScreenConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

