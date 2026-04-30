import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../primitives/aura_enums.dart';

part 'menu_item_entry.desk.dart';
part 'menu_item_entry.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@DeskModel(title: 'Menu item', description: 'Row in the menu browse list')
class MenuItemEntry with MenuItemEntryMappable implements Serializable<MenuItemEntry> {
  @DeskString(description: 'Name', option: DeskStringOption())
  final String name;

  @DeskNumber(description: 'Price', option: DeskNumberOption(min: 0))
  final num price;

  @DeskText(description: 'Short description', option: DeskTextOption())
  final String shortDescription;

  @DeskImage(description: 'Photo', option: DeskImageOption(hotspot: true))
  final ImageReference? image;

  @DeskMultiDropdown<String>(description: 'Tags', option: MenuItemTagsOption())
  final List<String> tags;

  @DeskCheckbox(description: 'Available', option: DeskCheckboxOption(label: 'Available'))
  final bool? isAvailable;

  const MenuItemEntry({
    required this.name,
    required this.price,
    required this.shortDescription,
    this.image,
    required this.tags,
    this.isAvailable,
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

class MenuItemTagsOption extends DeskMultiDropdownOption<String> {
  const MenuItemTagsOption({super.visibleWhen});
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
