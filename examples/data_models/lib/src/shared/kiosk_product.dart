import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../primitives/aura_enums.dart';

part 'kiosk_product.desk.dart';
part 'kiosk_product.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@DeskModel(title: 'Kiosk product', description: 'Tile in the kiosk grid')
class KioskProduct with KioskProductMappable implements Serializable<KioskProduct> {
  @DeskString(description: 'Name', option: DeskStringOption())
  final String name;

  @DeskNumber(description: 'Price', option: DeskNumberOption(min: 0))
  final num price;

  @DeskImage(description: 'Photo', option: DeskImageOption(hotspot: true))
  final ImageReference? image;

  @DeskDropdown<String>(description: 'Category', option: KioskCategoryOption())
  final String category;

  const KioskProduct({required this.name, required this.price, this.image, required this.category});

  static KioskProduct defaultValue = const KioskProduct(name: 'Orecchiette', price: 24, category: 'Signature');

  static KioskProduct $fromMap(Map<String, dynamic> map) => KioskProductMapper.fromMap(map);
}

class KioskCategoryOption extends DeskDropdownOption<String> {
  const KioskCategoryOption({super.visibleWhen});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get defaultValue => 'Signature';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final c in kioskCategories) DropdownOption(value: c, label: c),
      ];
  @override
  String? get placeholder => 'Category';
}
