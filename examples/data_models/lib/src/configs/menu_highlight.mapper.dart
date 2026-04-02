// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_highlight.dart';

class MenuHighlightMapper extends ClassMapperBase<MenuHighlight> {
  MenuHighlightMapper._();

  static MenuHighlightMapper? _instance;
  static MenuHighlightMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuHighlightMapper._());
      MapperContainer.globals.useAll([ImageReferenceMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'MenuHighlight';

  static String _$itemName(MenuHighlight v) => v.itemName;
  static const Field<MenuHighlight, String> _f$itemName = Field(
    'itemName',
    _$itemName,
  );
  static String _$description(MenuHighlight v) => v.description;
  static const Field<MenuHighlight, String> _f$description = Field(
    'description',
    _$description,
  );
  static ImageReference? _$photo(MenuHighlight v) => v.photo;
  static const Field<MenuHighlight, ImageReference> _f$photo = Field(
    'photo',
    _$photo,
    opt: true,
  );
  static num _$price(MenuHighlight v) => v.price;
  static const Field<MenuHighlight, num> _f$price = Field('price', _$price);
  static String? _$badge(MenuHighlight v) => v.badge;
  static const Field<MenuHighlight, String> _f$badge = Field(
    'badge',
    _$badge,
    opt: true,
  );
  static String _$category(MenuHighlight v) => v.category;
  static const Field<MenuHighlight, String> _f$category = Field(
    'category',
    _$category,
  );
  static int _$sortOrder(MenuHighlight v) => v.sortOrder;
  static const Field<MenuHighlight, int> _f$sortOrder = Field(
    'sortOrder',
    _$sortOrder,
  );
  static bool _$available(MenuHighlight v) => v.available;
  static const Field<MenuHighlight, bool> _f$available = Field(
    'available',
    _$available,
  );
  static num _$calories(MenuHighlight v) => v.calories;
  static const Field<MenuHighlight, num> _f$calories = Field(
    'calories',
    _$calories,
  );
  static String? _$allergens(MenuHighlight v) => v.allergens;
  static const Field<MenuHighlight, String> _f$allergens = Field(
    'allergens',
    _$allergens,
    opt: true,
  );

  @override
  final MappableFields<MenuHighlight> fields = const {
    #itemName: _f$itemName,
    #description: _f$description,
    #photo: _f$photo,
    #price: _f$price,
    #badge: _f$badge,
    #category: _f$category,
    #sortOrder: _f$sortOrder,
    #available: _f$available,
    #calories: _f$calories,
    #allergens: _f$allergens,
  };

  static MenuHighlight _instantiate(DecodingData data) {
    return MenuHighlight(
      itemName: data.dec(_f$itemName),
      description: data.dec(_f$description),
      photo: data.dec(_f$photo),
      price: data.dec(_f$price),
      badge: data.dec(_f$badge),
      category: data.dec(_f$category),
      sortOrder: data.dec(_f$sortOrder),
      available: data.dec(_f$available),
      calories: data.dec(_f$calories),
      allergens: data.dec(_f$allergens),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MenuHighlight fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuHighlight>(map);
  }

  static MenuHighlight fromJson(String json) {
    return ensureInitialized().decodeJson<MenuHighlight>(json);
  }
}

mixin MenuHighlightMappable {
  String toJson() {
    return MenuHighlightMapper.ensureInitialized().encodeJson<MenuHighlight>(
      this as MenuHighlight,
    );
  }

  Map<String, dynamic> toMap() {
    return MenuHighlightMapper.ensureInitialized().encodeMap<MenuHighlight>(
      this as MenuHighlight,
    );
  }

  MenuHighlightCopyWith<MenuHighlight, MenuHighlight, MenuHighlight>
  get copyWith => _MenuHighlightCopyWithImpl<MenuHighlight, MenuHighlight>(
    this as MenuHighlight,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return MenuHighlightMapper.ensureInitialized().stringifyValue(
      this as MenuHighlight,
    );
  }

  @override
  bool operator ==(Object other) {
    return MenuHighlightMapper.ensureInitialized().equalsValue(
      this as MenuHighlight,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuHighlightMapper.ensureInitialized().hashValue(
      this as MenuHighlight,
    );
  }
}

extension MenuHighlightValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MenuHighlight, $Out> {
  MenuHighlightCopyWith<$R, MenuHighlight, $Out> get $asMenuHighlight =>
      $base.as((v, t, t2) => _MenuHighlightCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuHighlightCopyWith<$R, $In extends MenuHighlight, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? itemName,
    String? description,
    ImageReference? photo,
    num? price,
    String? badge,
    String? category,
    int? sortOrder,
    bool? available,
    num? calories,
    String? allergens,
  });
  MenuHighlightCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MenuHighlightCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuHighlight, $Out>
    implements MenuHighlightCopyWith<$R, MenuHighlight, $Out> {
  _MenuHighlightCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuHighlight> $mapper =
      MenuHighlightMapper.ensureInitialized();
  @override
  $R call({
    String? itemName,
    String? description,
    Object? photo = $none,
    num? price,
    Object? badge = $none,
    String? category,
    int? sortOrder,
    bool? available,
    num? calories,
    Object? allergens = $none,
  }) => $apply(
    FieldCopyWithData({
      if (itemName != null) #itemName: itemName,
      if (description != null) #description: description,
      if (photo != $none) #photo: photo,
      if (price != null) #price: price,
      if (badge != $none) #badge: badge,
      if (category != null) #category: category,
      if (sortOrder != null) #sortOrder: sortOrder,
      if (available != null) #available: available,
      if (calories != null) #calories: calories,
      if (allergens != $none) #allergens: allergens,
    }),
  );
  @override
  MenuHighlight $make(CopyWithData data) => MenuHighlight(
    itemName: data.get(#itemName, or: $value.itemName),
    description: data.get(#description, or: $value.description),
    photo: data.get(#photo, or: $value.photo),
    price: data.get(#price, or: $value.price),
    badge: data.get(#badge, or: $value.badge),
    category: data.get(#category, or: $value.category),
    sortOrder: data.get(#sortOrder, or: $value.sortOrder),
    available: data.get(#available, or: $value.available),
    calories: data.get(#calories, or: $value.calories),
    allergens: data.get(#allergens, or: $value.allergens),
  );

  @override
  MenuHighlightCopyWith<$R2, MenuHighlight, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MenuHighlightCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

