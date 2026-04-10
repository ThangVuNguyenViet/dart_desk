// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_item.dart';

class NutritionInfoMapper extends ClassMapperBase<NutritionInfo> {
  NutritionInfoMapper._();

  static NutritionInfoMapper? _instance;
  static NutritionInfoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = NutritionInfoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'NutritionInfo';

  static num _$protein(NutritionInfo v) => v.protein;
  static const Field<NutritionInfo, num> _f$protein = Field(
    'protein',
    _$protein,
  );
  static num _$carbs(NutritionInfo v) => v.carbs;
  static const Field<NutritionInfo, num> _f$carbs = Field('carbs', _$carbs);
  static num _$fat(NutritionInfo v) => v.fat;
  static const Field<NutritionInfo, num> _f$fat = Field('fat', _$fat);

  @override
  final MappableFields<NutritionInfo> fields = const {
    #protein: _f$protein,
    #carbs: _f$carbs,
    #fat: _f$fat,
  };

  static NutritionInfo _instantiate(DecodingData data) {
    return NutritionInfo(
      protein: data.dec(_f$protein),
      carbs: data.dec(_f$carbs),
      fat: data.dec(_f$fat),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static NutritionInfo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<NutritionInfo>(map);
  }

  static NutritionInfo fromJson(String json) {
    return ensureInitialized().decodeJson<NutritionInfo>(json);
  }
}

mixin NutritionInfoMappable {
  String toJson() {
    return NutritionInfoMapper.ensureInitialized().encodeJson<NutritionInfo>(
      this as NutritionInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return NutritionInfoMapper.ensureInitialized().encodeMap<NutritionInfo>(
      this as NutritionInfo,
    );
  }

  NutritionInfoCopyWith<NutritionInfo, NutritionInfo, NutritionInfo>
  get copyWith => _NutritionInfoCopyWithImpl<NutritionInfo, NutritionInfo>(
    this as NutritionInfo,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return NutritionInfoMapper.ensureInitialized().stringifyValue(
      this as NutritionInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    return NutritionInfoMapper.ensureInitialized().equalsValue(
      this as NutritionInfo,
      other,
    );
  }

  @override
  int get hashCode {
    return NutritionInfoMapper.ensureInitialized().hashValue(
      this as NutritionInfo,
    );
  }
}

extension NutritionInfoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, NutritionInfo, $Out> {
  NutritionInfoCopyWith<$R, NutritionInfo, $Out> get $asNutritionInfo =>
      $base.as((v, t, t2) => _NutritionInfoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class NutritionInfoCopyWith<$R, $In extends NutritionInfo, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({num? protein, num? carbs, num? fat});
  NutritionInfoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _NutritionInfoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, NutritionInfo, $Out>
    implements NutritionInfoCopyWith<$R, NutritionInfo, $Out> {
  _NutritionInfoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<NutritionInfo> $mapper =
      NutritionInfoMapper.ensureInitialized();
  @override
  $R call({num? protein, num? carbs, num? fat}) => $apply(
    FieldCopyWithData({
      if (protein != null) #protein: protein,
      if (carbs != null) #carbs: carbs,
      if (fat != null) #fat: fat,
    }),
  );
  @override
  NutritionInfo $make(CopyWithData data) => NutritionInfo(
    protein: data.get(#protein, or: $value.protein),
    carbs: data.get(#carbs, or: $value.carbs),
    fat: data.get(#fat, or: $value.fat),
  );

  @override
  NutritionInfoCopyWith<$R2, NutritionInfo, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _NutritionInfoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MenuItemVariantMapper extends ClassMapperBase<MenuItemVariant> {
  MenuItemVariantMapper._();

  static MenuItemVariantMapper? _instance;
  static MenuItemVariantMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuItemVariantMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MenuItemVariant';

  static String _$label(MenuItemVariant v) => v.label;
  static const Field<MenuItemVariant, String> _f$label = Field(
    'label',
    _$label,
  );
  static num _$price(MenuItemVariant v) => v.price;
  static const Field<MenuItemVariant, num> _f$price = Field('price', _$price);

  @override
  final MappableFields<MenuItemVariant> fields = const {
    #label: _f$label,
    #price: _f$price,
  };

  static MenuItemVariant _instantiate(DecodingData data) {
    return MenuItemVariant(
      label: data.dec(_f$label),
      price: data.dec(_f$price),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MenuItemVariant fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuItemVariant>(map);
  }

  static MenuItemVariant fromJson(String json) {
    return ensureInitialized().decodeJson<MenuItemVariant>(json);
  }
}

mixin MenuItemVariantMappable {
  String toJson() {
    return MenuItemVariantMapper.ensureInitialized()
        .encodeJson<MenuItemVariant>(this as MenuItemVariant);
  }

  Map<String, dynamic> toMap() {
    return MenuItemVariantMapper.ensureInitialized().encodeMap<MenuItemVariant>(
      this as MenuItemVariant,
    );
  }

  MenuItemVariantCopyWith<MenuItemVariant, MenuItemVariant, MenuItemVariant>
  get copyWith =>
      _MenuItemVariantCopyWithImpl<MenuItemVariant, MenuItemVariant>(
        this as MenuItemVariant,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MenuItemVariantMapper.ensureInitialized().stringifyValue(
      this as MenuItemVariant,
    );
  }

  @override
  bool operator ==(Object other) {
    return MenuItemVariantMapper.ensureInitialized().equalsValue(
      this as MenuItemVariant,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuItemVariantMapper.ensureInitialized().hashValue(
      this as MenuItemVariant,
    );
  }
}

extension MenuItemVariantValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MenuItemVariant, $Out> {
  MenuItemVariantCopyWith<$R, MenuItemVariant, $Out> get $asMenuItemVariant =>
      $base.as((v, t, t2) => _MenuItemVariantCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuItemVariantCopyWith<$R, $In extends MenuItemVariant, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? label, num? price});
  MenuItemVariantCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MenuItemVariantCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuItemVariant, $Out>
    implements MenuItemVariantCopyWith<$R, MenuItemVariant, $Out> {
  _MenuItemVariantCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuItemVariant> $mapper =
      MenuItemVariantMapper.ensureInitialized();
  @override
  $R call({String? label, num? price}) => $apply(
    FieldCopyWithData({
      if (label != null) #label: label,
      if (price != null) #price: price,
    }),
  );
  @override
  MenuItemVariant $make(CopyWithData data) => MenuItemVariant(
    label: data.get(#label, or: $value.label),
    price: data.get(#price, or: $value.price),
  );

  @override
  MenuItemVariantCopyWith<$R2, MenuItemVariant, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MenuItemVariantCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MenuItemMapper extends SubClassMapperBase<MenuItem> {
  MenuItemMapper._();

  static MenuItemMapper? _instance;
  static MenuItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuItemMapper._());
      CmsContentMapper.ensureInitialized().addSubMapper(_instance!);
      MapperContainer.globals.useAll([
        MenuItemColorMapper(),
        ImageReferenceMapper(),
      ]);
      NutritionInfoMapper.ensureInitialized();
      MenuItemVariantMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MenuItem';

  static String _$name(MenuItem v) => v.name;
  static const Field<MenuItem, String> _f$name = Field('name', _$name);
  static String _$sku(MenuItem v) => v.sku;
  static const Field<MenuItem, String> _f$sku = Field('sku', _$sku);
  static Object? _$description(MenuItem v) => v.description;
  static const Field<MenuItem, Object> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static num _$price(MenuItem v) => v.price;
  static const Field<MenuItem, num> _f$price = Field('price', _$price);
  static num _$calories(MenuItem v) => v.calories;
  static const Field<MenuItem, num> _f$calories = Field('calories', _$calories);
  static bool _$isAvailable(MenuItem v) => v.isAvailable;
  static const Field<MenuItem, bool> _f$isAvailable = Field(
    'isAvailable',
    _$isAvailable,
  );
  static bool _$isVegetarian(MenuItem v) => v.isVegetarian;
  static const Field<MenuItem, bool> _f$isVegetarian = Field(
    'isVegetarian',
    _$isVegetarian,
  );
  static bool _$isGlutenFree(MenuItem v) => v.isGlutenFree;
  static const Field<MenuItem, bool> _f$isGlutenFree = Field(
    'isGlutenFree',
    _$isGlutenFree,
  );
  static String _$category(MenuItem v) => v.category;
  static const Field<MenuItem, String> _f$category = Field(
    'category',
    _$category,
  );
  static List<String> _$allergens(MenuItem v) => v.allergens;
  static const Field<MenuItem, List<String>> _f$allergens = Field(
    'allergens',
    _$allergens,
  );
  static List<String> _$tags(MenuItem v) => v.tags;
  static const Field<MenuItem, List<String>> _f$tags = Field('tags', _$tags);
  static ImageReference? _$photo(MenuItem v) => v.photo;
  static const Field<MenuItem, ImageReference> _f$photo = Field(
    'photo',
    _$photo,
    opt: true,
  );
  static NutritionInfo _$nutritionInfo(MenuItem v) => v.nutritionInfo;
  static const Field<MenuItem, NutritionInfo> _f$nutritionInfo = Field(
    'nutritionInfo',
    _$nutritionInfo,
  );
  static List<MenuItemVariant> _$variants(MenuItem v) => v.variants;
  static const Field<MenuItem, List<MenuItemVariant>> _f$variants = Field(
    'variants',
    _$variants,
  );

  @override
  final MappableFields<MenuItem> fields = const {
    #name: _f$name,
    #sku: _f$sku,
    #description: _f$description,
    #price: _f$price,
    #calories: _f$calories,
    #isAvailable: _f$isAvailable,
    #isVegetarian: _f$isVegetarian,
    #isGlutenFree: _f$isGlutenFree,
    #category: _f$category,
    #allergens: _f$allergens,
    #tags: _f$tags,
    #photo: _f$photo,
    #nutritionInfo: _f$nutritionInfo,
    #variants: _f$variants,
  };

  @override
  final String discriminatorKey = 'documentType';
  @override
  final dynamic discriminatorValue = 'menuItem';
  @override
  late final ClassMapperBase superMapper = CmsContentMapper.ensureInitialized();

  static MenuItem _instantiate(DecodingData data) {
    return MenuItem(
      name: data.dec(_f$name),
      sku: data.dec(_f$sku),
      description: data.dec(_f$description),
      price: data.dec(_f$price),
      calories: data.dec(_f$calories),
      isAvailable: data.dec(_f$isAvailable),
      isVegetarian: data.dec(_f$isVegetarian),
      isGlutenFree: data.dec(_f$isGlutenFree),
      category: data.dec(_f$category),
      allergens: data.dec(_f$allergens),
      tags: data.dec(_f$tags),
      photo: data.dec(_f$photo),
      nutritionInfo: data.dec(_f$nutritionInfo),
      variants: data.dec(_f$variants),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MenuItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuItem>(map);
  }

  static MenuItem fromJson(String json) {
    return ensureInitialized().decodeJson<MenuItem>(json);
  }
}

mixin MenuItemMappable {
  String toJson() {
    return MenuItemMapper.ensureInitialized().encodeJson<MenuItem>(
      this as MenuItem,
    );
  }

  Map<String, dynamic> toMap() {
    return MenuItemMapper.ensureInitialized().encodeMap<MenuItem>(
      this as MenuItem,
    );
  }

  MenuItemCopyWith<MenuItem, MenuItem, MenuItem> get copyWith =>
      _MenuItemCopyWithImpl<MenuItem, MenuItem>(
        this as MenuItem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MenuItemMapper.ensureInitialized().stringifyValue(this as MenuItem);
  }

  @override
  bool operator ==(Object other) {
    return MenuItemMapper.ensureInitialized().equalsValue(
      this as MenuItem,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuItemMapper.ensureInitialized().hashValue(this as MenuItem);
  }
}

extension MenuItemValueCopy<$R, $Out> on ObjectCopyWith<$R, MenuItem, $Out> {
  MenuItemCopyWith<$R, MenuItem, $Out> get $asMenuItem =>
      $base.as((v, t, t2) => _MenuItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuItemCopyWith<$R, $In extends MenuItem, $Out>
    implements CmsContentCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get allergens;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags;
  NutritionInfoCopyWith<$R, NutritionInfo, NutritionInfo> get nutritionInfo;
  ListCopyWith<
    $R,
    MenuItemVariant,
    MenuItemVariantCopyWith<$R, MenuItemVariant, MenuItemVariant>
  >
  get variants;
  @override
  $R call({
    String? name,
    String? sku,
    Object? description,
    num? price,
    num? calories,
    bool? isAvailable,
    bool? isVegetarian,
    bool? isGlutenFree,
    String? category,
    List<String>? allergens,
    List<String>? tags,
    ImageReference? photo,
    NutritionInfo? nutritionInfo,
    List<MenuItemVariant>? variants,
  });
  MenuItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MenuItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuItem, $Out>
    implements MenuItemCopyWith<$R, MenuItem, $Out> {
  _MenuItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuItem> $mapper =
      MenuItemMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get allergens =>
      ListCopyWith(
        $value.allergens,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(allergens: v),
      );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags =>
      ListCopyWith(
        $value.tags,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(tags: v),
      );
  @override
  NutritionInfoCopyWith<$R, NutritionInfo, NutritionInfo> get nutritionInfo =>
      $value.nutritionInfo.copyWith.$chain((v) => call(nutritionInfo: v));
  @override
  ListCopyWith<
    $R,
    MenuItemVariant,
    MenuItemVariantCopyWith<$R, MenuItemVariant, MenuItemVariant>
  >
  get variants => ListCopyWith(
    $value.variants,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(variants: v),
  );
  @override
  $R call({
    String? name,
    String? sku,
    Object? description = $none,
    num? price,
    num? calories,
    bool? isAvailable,
    bool? isVegetarian,
    bool? isGlutenFree,
    String? category,
    List<String>? allergens,
    List<String>? tags,
    Object? photo = $none,
    NutritionInfo? nutritionInfo,
    List<MenuItemVariant>? variants,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (sku != null) #sku: sku,
      if (description != $none) #description: description,
      if (price != null) #price: price,
      if (calories != null) #calories: calories,
      if (isAvailable != null) #isAvailable: isAvailable,
      if (isVegetarian != null) #isVegetarian: isVegetarian,
      if (isGlutenFree != null) #isGlutenFree: isGlutenFree,
      if (category != null) #category: category,
      if (allergens != null) #allergens: allergens,
      if (tags != null) #tags: tags,
      if (photo != $none) #photo: photo,
      if (nutritionInfo != null) #nutritionInfo: nutritionInfo,
      if (variants != null) #variants: variants,
    }),
  );
  @override
  MenuItem $make(CopyWithData data) => MenuItem(
    name: data.get(#name, or: $value.name),
    sku: data.get(#sku, or: $value.sku),
    description: data.get(#description, or: $value.description),
    price: data.get(#price, or: $value.price),
    calories: data.get(#calories, or: $value.calories),
    isAvailable: data.get(#isAvailable, or: $value.isAvailable),
    isVegetarian: data.get(#isVegetarian, or: $value.isVegetarian),
    isGlutenFree: data.get(#isGlutenFree, or: $value.isGlutenFree),
    category: data.get(#category, or: $value.category),
    allergens: data.get(#allergens, or: $value.allergens),
    tags: data.get(#tags, or: $value.tags),
    photo: data.get(#photo, or: $value.photo),
    nutritionInfo: data.get(#nutritionInfo, or: $value.nutritionInfo),
    variants: data.get(#variants, or: $value.variants),
  );

  @override
  MenuItemCopyWith<$R2, MenuItem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MenuItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

