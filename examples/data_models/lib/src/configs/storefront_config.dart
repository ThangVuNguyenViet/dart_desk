import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'storefront_config.cms.g.dart';
part 'storefront_config.mapper.dart';

@CmsConfig(
  title: 'Storefront Config',
  description: 'Restaurant app home screen branding and display settings',
)
@MappableClass(
  ignoreNull: false,
  includeCustomMappers: [StorefrontColorMapper(), ImageReferenceMapper()],
)
class StorefrontConfig
    with StorefrontConfigMappable, Serializable<StorefrontConfig> {
  @CmsStringFieldConfig(
    description: 'Name of the restaurant',
    option: CmsStringOption(),
  )
  final String restaurantName;

  @CmsTextFieldConfig(
    description: 'Short tagline shown beneath the restaurant name',
    option: CmsTextOption(rows: 2),
  )
  final String tagline;

  @CmsImageFieldConfig(
    description: 'Full-width hero image for the home screen',
    option: CmsImageOption(hotspot: true),
  )
  final ImageReference? heroImage;

  @CmsImageFieldConfig(
    description: 'Restaurant logo displayed in the header',
    option: CmsImageOption(hotspot: false),
  )
  final ImageReference? logo;

  @CmsColorFieldConfig(
    description: 'Primary brand color used for buttons and highlights',
    option: CmsColorOption(),
  )
  final Color primaryColor;

  @CmsColorFieldConfig(
    description: 'Accent color used for secondary UI elements',
    option: CmsColorOption(),
  )
  final Color accentColor;

  @CmsTextFieldConfig(
    description: 'Welcome message displayed on the home screen',
    option: CmsTextOption(rows: 3),
  )
  final String welcomeMessage;

  @CmsStringFieldConfig(
    description: 'Operating hours shown to customers (e.g. Mon–Fri 11am–10pm)',
    option: CmsStringOption(),
  )
  final String operatingHours;

  @CmsUrlFieldConfig(
    description: 'External URL for online ordering',
    option: CmsUrlOption(),
  )
  final String? orderUrl;

  @CmsBooleanFieldConfig(
    description: 'Show operating hours on the home screen',
    option: CmsBooleanOption(),
  )
  final bool showHours;

  @CmsStringFieldConfig(
    description: 'Label text for the primary call-to-action button',
    option: CmsStringOption(),
  )
  final String ctaLabel;

  const StorefrontConfig({
    required this.restaurantName,
    required this.tagline,
    this.heroImage,
    this.logo,
    required this.primaryColor,
    required this.accentColor,
    required this.welcomeMessage,
    required this.operatingHours,
    this.orderUrl,
    required this.showHours,
    required this.ctaLabel,
  });

  static StorefrontConfig defaultValue = StorefrontConfig(
    restaurantName: "Bella's Kitchen",
    tagline: 'Fresh ingredients, made with love',
    heroImage: null,
    logo: null,
    primaryColor: const Color(0xFFD4451A),
    accentColor: const Color(0xFFF9A825),
    welcomeMessage:
        'Welcome to Bella\'s Kitchen! Enjoy authentic Italian dishes crafted from locally sourced, seasonal ingredients.',
    operatingHours: 'Mon–Sun 11:00 am – 10:00 pm',
    orderUrl: null,
    showHours: true,
    ctaLabel: 'Order Now',
  );
}

class StorefrontColorMapper extends SimpleMapper<Color> {
  const StorefrontColorMapper();

  @override
  Color decode(Object value) {
    if (value is String) {
      final hexColor = value.replaceFirst('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
    }
    throw Exception('Cannot decode Color from $value');
  }

  @override
  Object? encode(Color self) {
    return '#${self.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}
