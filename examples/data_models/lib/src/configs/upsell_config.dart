import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';

part 'upsell_config.cms.g.dart';
part 'upsell_config.mapper.dart';

@CmsConfig(
  title: 'Upsell Screen',
  description: 'Mobile Chefs Choice curated item list with editorial pull-quote',
)
@MappableClass(ignoreNull: false, includeCustomMappers: [UpsellColorMapper()])
class UpsellConfig with UpsellConfigMappable, Serializable<UpsellConfig> {
  @CmsStringFieldConfig(
    description: 'Section title (e.g. Chefs Choice)',
    option: CmsStringOption(),
  )
  final String sectionTitle;

  @CmsTextFieldConfig(
    description: 'Subtitle text below the section title',
    option: CmsTextOption(rows: 2),
  )
  final String sectionSubtitle;

  @CmsTextFieldConfig(
    description: 'Pull-quote text displayed between product items',
    option: CmsTextOption(rows: 3),
  )
  final String quoteText;

  @CmsStringFieldConfig(
    description: 'Attribution name for the pull-quote',
    option: CmsStringOption(),
  )
  final String chefName;

  @CmsMultiDropdownFieldConfig<String>(
    description: 'Chef choice products to feature',
    option: UpsellProductsDropdownOption(),
  )
  final List<String> products;

  const UpsellConfig({
    required this.sectionTitle,
    required this.sectionSubtitle,
    required this.quoteText,
    required this.chefName,
    required this.products,
  });

  static UpsellConfig defaultValue = UpsellConfig(
    sectionTitle: "Chef's Choice",
    sectionSubtitle:
        'Hand-selected seasonal masterpieces defined by precision and local ingredients.',
    quoteText:
        'Cuisine is the bridge between nature and culture. Every selection here tells a story of the harvest.',
    chefName: 'Executive Chef Elara',
    products: ['wagyu_burger', 'linguine_vongole', 'hokkaido_scallops', 'dry_aged_ribeye'],
  );
}

class UpsellColorMapper extends SimpleMapper<Color> {
  const UpsellColorMapper();

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

class UpsellProductsDropdownOption extends CmsMultiDropdownOption<String> {
  const UpsellProductsDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues =>
      ['wagyu_burger', 'linguine_vongole', 'hokkaido_scallops', 'dry_aged_ribeye'];

  @override
  int? get maxSelected => 4;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final p in upsellProducts)
          DropdownOption(value: p.key, label: '${p.name} (\$${p.price.toStringAsFixed(2)})'),
      ]);

  @override
  String? get placeholder => "Select chef's picks";
}
