import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

import '../primitives/aura_assets.dart';
import '../primitives/aura_copy.dart';
import '../shared/kiosk_product.dart';
import '../shared/order_line.dart';
import 'desk_content.dart';

part 'kiosk_config.desk.dart';
part 'kiosk_config.mapper.dart';

@DeskModel(title: 'Kiosk screen', description: 'Tablet landscape in-store terminal')
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'kioskConfig',
  includeCustomMappers: [ImageReferenceMapper()],
)
class KioskConfig extends DeskContent with KioskConfigMappable, Serializable<KioskConfig> {
  @DeskImage(description: 'Banner image', option: DeskImageOption(hotspot: true))
  final ImageReference? bannerImage;

  @DeskString(description: 'Banner headline', option: DeskStringOption())
  final String bannerHeadline;

  @DeskText(description: 'Banner subtitle', option: DeskTextOption())
  final String bannerSubtitle;

  @DeskString(description: 'Promo badge', option: DeskStringOption())
  final String promoBadge;

  @DeskArray<KioskProduct>(description: 'Grid products')
  final List<KioskProduct> gridProducts;

  @DeskString(description: 'Table label', option: DeskStringOption())
  final String sidebarTableLabel;

  @DeskArray<OrderLine>(description: 'Sample order lines')
  final List<OrderLine> sidebarSampleOrder;

  @DeskText(description: 'Footer note', option: DeskTextOption())
  final String footerNote;

  const KioskConfig({
    this.bannerImage,
    required this.bannerHeadline,
    required this.bannerSubtitle,
    required this.promoBadge,
    required this.gridProducts,
    required this.sidebarTableLabel,
    required this.sidebarSampleOrder,
    required this.footerNote,
  });

  static KioskConfig initialValue = KioskConfig(
    bannerImage: const ImageReference(externalUrl: AuraAssets.heroPlating),
    bannerHeadline: AuraCopy.kioskBannerHeadline,
    bannerSubtitle: AuraCopy.kioskBannerSubtitle,
    promoBadge: AuraCopy.kioskPromoBadge,
    gridProducts: const [
      KioskProduct(name: 'Signature Pasta',    price: 26, image: ImageReference(externalUrl: AuraAssets.dish10), category: 'Signature'),
      KioskProduct(name: 'Spring Crudo',       price: 21, image: ImageReference(externalUrl: AuraAssets.dish2),  category: 'Starter'),
      KioskProduct(name: 'Natural Wine Flight', price: 28, image: ImageReference(externalUrl: AuraAssets.wine),   category: 'Drink'),
      KioskProduct(name: 'Olive Oil Cake',     price: 11, image: ImageReference(externalUrl: AuraAssets.dish5),  category: 'Sweet'),
      KioskProduct(name: 'Charred Brassicas',  price: 16, image: ImageReference(externalUrl: AuraAssets.dish6),  category: 'Signature'),
      KioskProduct(name: 'Citrus & Fennel',    price: 15, image: ImageReference(externalUrl: AuraAssets.citrus), category: 'Starter'),
    ],
    sidebarTableLabel: AuraCopy.kioskTableLabel,
    sidebarSampleOrder: const [
      OrderLine(itemName: 'Signature Pasta',    qty: 2, price: 26),
      OrderLine(itemName: 'Natural Wine Flight', qty: 1, price: 28),
      OrderLine(itemName: 'Olive Oil Cake',     qty: 1, price: 11),
    ],
    footerNote: AuraCopy.kioskFooter,
  );
}
