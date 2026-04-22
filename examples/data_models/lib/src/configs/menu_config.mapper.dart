// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_config.dart';

class MenuConfigMapper extends SubClassMapperBase<MenuConfig> {
  MenuConfigMapper._();

  static MenuConfigMapper? _instance;
  static MenuConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuConfigMapper._());
      CmsContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([ImageReferenceMapper()]);
      MenuItemEntryMapper.ensureInitialized();
      StoreHoursEntryMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MenuConfig';

  static List<String> _$categories(MenuConfig v) => v.categories;
  static const Field<MenuConfig, List<String>> _f$categories = Field(
    'categories',
    _$categories,
  );
  static List<String> _$filterTags(MenuConfig v) => v.filterTags;
  static const Field<MenuConfig, List<String>> _f$filterTags = Field(
    'filterTags',
    _$filterTags,
  );
  static List<MenuItemEntry> _$items(MenuConfig v) => v.items;
  static const Field<MenuConfig, List<MenuItemEntry>> _f$items = Field(
    'items',
    _$items,
  );
  static Map<String, double>? _$location(MenuConfig v) => v.location;
  static const Field<MenuConfig, Map<String, double>> _f$location = Field(
    'location',
    _$location,
    opt: true,
  );
  static List<StoreHoursEntry> _$storeHours(MenuConfig v) => v.storeHours;
  static const Field<MenuConfig, List<StoreHoursEntry>> _f$storeHours = Field(
    'storeHours',
    _$storeHours,
  );

  @override
  final MappableFields<MenuConfig> fields = const {
    #categories: _f$categories,
    #filterTags: _f$filterTags,
    #items: _f$items,
    #location: _f$location,
    #storeHours: _f$storeHours,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'menuConfig';
  @override
  late final ClassMapperBase superMapper = CmsContentMapper.ensureInitialized();

  static MenuConfig _instantiate(DecodingData data) {
    return MenuConfig(
      categories: data.dec(_f$categories),
      filterTags: data.dec(_f$filterTags),
      items: data.dec(_f$items),
      location: data.dec(_f$location),
      storeHours: data.dec(_f$storeHours),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MenuConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuConfig>(map);
  }

  static MenuConfig fromJson(String json) {
    return ensureInitialized().decodeJson<MenuConfig>(json);
  }
}

mixin MenuConfigMappable {
  String toJson() {
    return MenuConfigMapper.ensureInitialized().encodeJson<MenuConfig>(
      this as MenuConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return MenuConfigMapper.ensureInitialized().encodeMap<MenuConfig>(
      this as MenuConfig,
    );
  }

  MenuConfigCopyWith<MenuConfig, MenuConfig, MenuConfig> get copyWith =>
      _MenuConfigCopyWithImpl<MenuConfig, MenuConfig>(
        this as MenuConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MenuConfigMapper.ensureInitialized().stringifyValue(
      this as MenuConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return MenuConfigMapper.ensureInitialized().equalsValue(
      this as MenuConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuConfigMapper.ensureInitialized().hashValue(this as MenuConfig);
  }
}

extension MenuConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MenuConfig, $Out> {
  MenuConfigCopyWith<$R, MenuConfig, $Out> get $asMenuConfig =>
      $base.as((v, t, t2) => _MenuConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuConfigCopyWith<$R, $In extends MenuConfig, $Out>
    implements CmsContentCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get categories;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get filterTags;
  ListCopyWith<
    $R,
    MenuItemEntry,
    MenuItemEntryCopyWith<$R, MenuItemEntry, MenuItemEntry>
  >
  get items;
  MapCopyWith<$R, String, double, ObjectCopyWith<$R, double, double>>?
  get location;
  ListCopyWith<
    $R,
    StoreHoursEntry,
    StoreHoursEntryCopyWith<$R, StoreHoursEntry, StoreHoursEntry>
  >
  get storeHours;
  @override
  $R call({
    List<String>? categories,
    List<String>? filterTags,
    List<MenuItemEntry>? items,
    Map<String, double>? location,
    List<StoreHoursEntry>? storeHours,
  });
  MenuConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MenuConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuConfig, $Out>
    implements MenuConfigCopyWith<$R, MenuConfig, $Out> {
  _MenuConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuConfig> $mapper =
      MenuConfigMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get categories =>
      ListCopyWith(
        $value.categories,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(categories: v),
      );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get filterTags =>
      ListCopyWith(
        $value.filterTags,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(filterTags: v),
      );
  @override
  ListCopyWith<
    $R,
    MenuItemEntry,
    MenuItemEntryCopyWith<$R, MenuItemEntry, MenuItemEntry>
  >
  get items => ListCopyWith(
    $value.items,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(items: v),
  );
  @override
  MapCopyWith<$R, String, double, ObjectCopyWith<$R, double, double>>?
  get location => $value.location != null
      ? MapCopyWith(
          $value.location!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(location: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    StoreHoursEntry,
    StoreHoursEntryCopyWith<$R, StoreHoursEntry, StoreHoursEntry>
  >
  get storeHours => ListCopyWith(
    $value.storeHours,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(storeHours: v),
  );
  @override
  $R call({
    List<String>? categories,
    List<String>? filterTags,
    List<MenuItemEntry>? items,
    Object? location = $none,
    List<StoreHoursEntry>? storeHours,
  }) => $apply(
    FieldCopyWithData({
      if (categories != null) #categories: categories,
      if (filterTags != null) #filterTags: filterTags,
      if (items != null) #items: items,
      if (location != $none) #location: location,
      if (storeHours != null) #storeHours: storeHours,
    }),
  );
  @override
  MenuConfig $make(CopyWithData data) => MenuConfig(
    categories: data.get(#categories, or: $value.categories),
    filterTags: data.get(#filterTags, or: $value.filterTags),
    items: data.get(#items, or: $value.items),
    location: data.get(#location, or: $value.location),
    storeHours: data.get(#storeHours, or: $value.storeHours),
  );

  @override
  MenuConfigCopyWith<$R2, MenuConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MenuConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

