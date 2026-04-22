import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'kiosk_product.cms.g.dart';
part 'kiosk_product.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@CmsConfig(title: 'Kiosk product', description: 'Tile in the kiosk grid')
class KioskProduct with KioskProductMappable implements Serializable<KioskProduct> {
  @CmsStringFieldConfig(description: 'Name', option: CmsStringOption())
  final String name;

  @CmsNumberFieldConfig(description: 'Price', option: CmsNumberOption(min: 0))
  final num price;

  @CmsImageFieldConfig(description: 'Photo', option: CmsImageOption(hotspot: true))
  final ImageReference? image;

  @CmsDropdownFieldConfig<String>(description: 'Category', option: KioskCategoryOption())
  final String category;

  const KioskProduct({required this.name, required this.price, this.image, required this.category});

  static KioskProduct defaultValue = const KioskProduct(name: 'Orecchiette', price: 24, category: 'Signature');

  static KioskProduct $fromMap(Map<String, dynamic> map) => KioskProductMapper.fromMap(map);
}

class KioskCategoryOption extends CmsDropdownOption<String> {
  const KioskCategoryOption({super.hidden});
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
