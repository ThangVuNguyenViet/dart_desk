import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';

part 'kiosk_config.cms.g.dart';
part 'kiosk_config.mapper.dart';

@CmsConfig(
  title: 'Kiosk Screen',
  description: 'Desktop 3-panel kiosk layout with product grid and order sidebar',
)
@MappableClass(ignoreNull: false, includeCustomMappers: [KioskColorMapper(), ImageReferenceMapper()])
class KioskConfig with KioskConfigMappable, Serializable<KioskConfig> {
  @CmsStringFieldConfig(
    description: 'Restaurant name shown in the nav drawer',
    option: CmsStringOption(),
  )
  final String restaurantName;

  @CmsStringFieldConfig(
    description: 'Banner headline text',
    option: CmsStringOption(),
  )
  final String bannerTitle;

  @CmsTextFieldConfig(
    description: 'Banner description text below the headline',
    option: CmsTextOption(rows: 2),
  )
  final String bannerSubtitle;

  @CmsImageFieldConfig(
    description: 'Banner background image',
    option: CmsImageOption(hotspot: false),
  )
  final ImageReference? bannerImage;

  @CmsMultiDropdownFieldConfig<String>(
    description: 'Products to display in the kiosk grid',
    option: KioskProductsDropdownOption(),
  )
  final List<String> products;

  const KioskConfig({
    required this.restaurantName,
    required this.bannerTitle,
    required this.bannerSubtitle,
    this.bannerImage,
    required this.products,
  });

  static KioskConfig defaultValue = KioskConfig(
    restaurantName: 'Aura Kiosk',
    bannerTitle: 'New Year Specials',
    bannerSubtitle:
        'Curated flavors to welcome the dawn of a new season. Experience artisanal culinary craftsmanship.',
    bannerImage: null,
    products: ['truffle_risotto', 'heritage_scallops', 'cherry_duck', 'valrhona_fondant'],
  );
}

class KioskColorMapper extends SimpleMapper<Color> {
  const KioskColorMapper();

  @override
  Color decode(Object value) {
    if (value is String) {
      final hex = value.replaceFirst('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    }
    throw Exception('Cannot decode Color from $value');
  }

  @override
  Object? encode(Color self) =>
      '#${self.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

class KioskProductsDropdownOption extends CmsMultiDropdownOption<String> {
  const KioskProductsDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues =>
      ['truffle_risotto', 'heritage_scallops', 'cherry_duck', 'valrhona_fondant'];

  @override
  int? get maxSelected => 4;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final p in kioskProducts)
          DropdownOption(value: p.key, label: '${p.name} (\$${p.price.toStringAsFixed(2)})'),
      ]);

  @override
  String? get placeholder => 'Select products';
}
