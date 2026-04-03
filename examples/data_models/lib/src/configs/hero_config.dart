import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';
import 'cms_content.dart';

part 'hero_config.cms.g.dart';
part 'hero_config.mapper.dart';

@CmsConfig(
  title: 'Hero Screen',
  description: 'Mobile home screen with hero image, categories, and featured products',
)
@MappableClass(ignoreNull: false, discriminatorValue: 'heroConfig', includeCustomMappers: [HeroColorMapper(), ImageReferenceMapper()])
class HeroConfig extends CmsContent with HeroConfigMappable, Serializable<HeroConfig> {
  @CmsStringFieldConfig(
    description: 'Main headline in the hero section',
    option: CmsStringOption(),
  )
  final String heroTitle;

  @CmsTextFieldConfig(
    description: 'Description text below the hero title',
    option: CmsTextOption(rows: 2),
  )
  final String heroSubtitle;

  @CmsImageFieldConfig(
    description: 'Background image for the hero section',
    option: CmsImageOption(hotspot: false),
  )
  final ImageReference? heroImage;

  @CmsStringFieldConfig(
    description: 'Call-to-action button label',
    option: CmsStringOption(),
  )
  final String ctaLabel;

  @CmsMultiDropdownFieldConfig<String>(
    description: 'Featured products to display in the grid',
    option: HeroProductsDropdownOption(),
  )
  final List<String> products;

  const HeroConfig({
    required this.heroTitle,
    required this.heroSubtitle,
    this.heroImage,
    required this.ctaLabel,
    required this.products,
  });

  static HeroConfig defaultValue = HeroConfig(
    heroTitle: 'The Festive Feast is Here',
    heroSubtitle: 'Limited Seasonal Selection',
    heroImage: null,
    ctaLabel: 'Explore the Menu',
    products: ['roasted_turkey', 'berry_tart', 'mulled_wine', 'glazed_ham'],
  );
}

class HeroColorMapper extends SimpleMapper<Color> {
  const HeroColorMapper();

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

class HeroProductsDropdownOption extends CmsMultiDropdownOption<String> {
  const HeroProductsDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues =>
      ['roasted_turkey', 'berry_tart', 'mulled_wine', 'glazed_ham'];

  @override
  int? get maxSelected => 4;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final p in heroProducts)
          DropdownOption(value: p.key, label: '${p.name} (\$${p.price.toStringAsFixed(2)})'),
      ]);

  @override
  String? get placeholder => 'Select featured products';
}
