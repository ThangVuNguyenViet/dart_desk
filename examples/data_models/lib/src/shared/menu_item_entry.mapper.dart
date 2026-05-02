// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_item_entry.dart';

class MenuItemEntryMapper extends ClassMapperBase<MenuItemEntry> {
  MenuItemEntryMapper._();

  static MenuItemEntryMapper? _instance;
  static MenuItemEntryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuItemEntryMapper._());
      MapperContainer.globals.useAll([ImageReferenceMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'MenuItemEntry';

  static String _$name(MenuItemEntry v) => v.name;
  static const Field<MenuItemEntry, String> _f$name = Field('name', _$name);
  static num _$price(MenuItemEntry v) => v.price;
  static const Field<MenuItemEntry, num> _f$price = Field('price', _$price);
  static String _$shortDescription(MenuItemEntry v) => v.shortDescription;
  static const Field<MenuItemEntry, String> _f$shortDescription = Field(
    'shortDescription',
    _$shortDescription,
  );
  static ImageReference? _$image(MenuItemEntry v) => v.image;
  static const Field<MenuItemEntry, ImageReference> _f$image = Field(
    'image',
    _$image,
    opt: true,
  );
  static List<String> _$tags(MenuItemEntry v) => v.tags;
  static const Field<MenuItemEntry, List<String>> _f$tags = Field(
    'tags',
    _$tags,
  );
  static bool? _$isAvailable(MenuItemEntry v) => v.isAvailable;
  static const Field<MenuItemEntry, bool> _f$isAvailable = Field(
    'isAvailable',
    _$isAvailable,
    opt: true,
  );

  @override
  final MappableFields<MenuItemEntry> fields = const {
    #name: _f$name,
    #price: _f$price,
    #shortDescription: _f$shortDescription,
    #image: _f$image,
    #tags: _f$tags,
    #isAvailable: _f$isAvailable,
  };

  static MenuItemEntry _instantiate(DecodingData data) {
    return MenuItemEntry(
      name: data.dec(_f$name),
      price: data.dec(_f$price),
      shortDescription: data.dec(_f$shortDescription),
      image: data.dec(_f$image),
      tags: data.dec(_f$tags),
      isAvailable: data.dec(_f$isAvailable),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MenuItemEntry fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuItemEntry>(map);
  }

  static MenuItemEntry fromJson(String json) {
    return ensureInitialized().decodeJson<MenuItemEntry>(json);
  }
}

mixin MenuItemEntryMappable {
  String toJson() {
    return MenuItemEntryMapper.ensureInitialized().encodeJson<MenuItemEntry>(
      this as MenuItemEntry,
    );
  }

  Map<String, dynamic> toMap() {
    return MenuItemEntryMapper.ensureInitialized().encodeMap<MenuItemEntry>(
      this as MenuItemEntry,
    );
  }

  MenuItemEntryCopyWith<MenuItemEntry, MenuItemEntry, MenuItemEntry>
  get copyWith => _MenuItemEntryCopyWithImpl<MenuItemEntry, MenuItemEntry>(
    this as MenuItemEntry,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return MenuItemEntryMapper.ensureInitialized().stringifyValue(
      this as MenuItemEntry,
    );
  }

  @override
  bool operator ==(Object other) {
    return MenuItemEntryMapper.ensureInitialized().equalsValue(
      this as MenuItemEntry,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuItemEntryMapper.ensureInitialized().hashValue(
      this as MenuItemEntry,
    );
  }
}

extension MenuItemEntryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MenuItemEntry, $Out> {
  MenuItemEntryCopyWith<$R, MenuItemEntry, $Out> get $asMenuItemEntry =>
      $base.as((v, t, t2) => _MenuItemEntryCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuItemEntryCopyWith<$R, $In extends MenuItemEntry, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags;
  $R call({
    String? name,
    num? price,
    String? shortDescription,
    ImageReference? image,
    List<String>? tags,
    bool? isAvailable,
  });
  MenuItemEntryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MenuItemEntryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuItemEntry, $Out>
    implements MenuItemEntryCopyWith<$R, MenuItemEntry, $Out> {
  _MenuItemEntryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuItemEntry> $mapper =
      MenuItemEntryMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags =>
      ListCopyWith(
        $value.tags,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(tags: v),
      );
  @override
  $R call({
    String? name,
    num? price,
    String? shortDescription,
    Object? image = $none,
    List<String>? tags,
    Object? isAvailable = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (price != null) #price: price,
      if (shortDescription != null) #shortDescription: shortDescription,
      if (image != $none) #image: image,
      if (tags != null) #tags: tags,
      if (isAvailable != $none) #isAvailable: isAvailable,
    }),
  );
  @override
  MenuItemEntry $make(CopyWithData data) => MenuItemEntry(
    name: data.get(#name, or: $value.name),
    price: data.get(#price, or: $value.price),
    shortDescription: data.get(#shortDescription, or: $value.shortDescription),
    image: data.get(#image, or: $value.image),
    tags: data.get(#tags, or: $value.tags),
    isAvailable: data.get(#isAvailable, or: $value.isAvailable),
  );

  @override
  MenuItemEntryCopyWith<$R2, MenuItemEntry, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MenuItemEntryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

