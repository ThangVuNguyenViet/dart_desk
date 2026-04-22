import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'menu_item_entry.cms.g.dart';
part 'menu_item_entry.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@CmsConfig(title: 'Menu item', description: 'Row in the menu browse list')
class MenuItemEntry with MenuItemEntryMappable implements Serializable<MenuItemEntry> {
  @CmsStringFieldConfig(description: 'Name', option: CmsStringOption())
  final String name;

  @CmsNumberFieldConfig(description: 'Price', option: CmsNumberOption(min: 0))
  final num price;

  @CmsTextFieldConfig(description: 'Short description', option: CmsTextOption())
  final String shortDescription;

  @CmsImageFieldConfig(description: 'Photo', option: CmsImageOption(hotspot: true))
  final ImageReference? image;

  @CmsMultiDropdownFieldConfig<String>(description: 'Tags', option: MenuItemTagsOption())
  final List<String> tags;

  @CmsCheckboxFieldConfig(description: 'Available', option: CmsCheckboxOption(label: 'Available'))
  final bool isAvailable;

  const MenuItemEntry({
    required this.name,
    required this.price,
    required this.shortDescription,
    this.image,
    required this.tags,
    required this.isAvailable,
  });

  static MenuItemEntry defaultValue = const MenuItemEntry(
    name: 'Orecchiette \'Nduja',
    price: 24,
    shortDescription: 'House-made orecchiette, spicy \'nduja, pecorino.',
    tags: ["Chef's Pick"],
    isAvailable: true,
  );

  static MenuItemEntry $fromMap(Map<String, dynamic> map) => MenuItemEntryMapper.fromMap(map);
}

class MenuItemTagsOption extends CmsMultiDropdownOption<String> {
  const MenuItemTagsOption({super.hidden});
  @override
  List<String>? get defaultValues => const [];
  @override
  int? get maxSelected => null;
  @override
  int? get minSelected => null;
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final t in menuFilterTags) DropdownOption(value: t, label: t),
      ];
  @override
  String? get placeholder => 'Tags';
}
