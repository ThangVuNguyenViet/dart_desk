// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'kiosk_config.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for KioskConfig
final kioskConfigFields = [
  DeskImageField(
    name: 'bannerImage',
    title: 'Banner Image',
    option: DeskImageOption(optional: true, hotspot: true),
  ),
  DeskStringField(
    name: 'bannerHeadline',
    title: 'Banner Headline',
    option: DeskStringOption(),
  ),
  DeskTextField(
    name: 'bannerSubtitle',
    title: 'Banner Subtitle',
    option: DeskTextOption(),
  ),
  DeskStringField(
    name: 'promoBadge',
    title: 'Promo Badge',
    option: DeskStringOption(),
  ),
  DeskArrayField<KioskProduct>(
    name: 'gridProducts',
    title: 'Grid Products',
    innerField: DeskObjectField(
      name: 'item',
      title: 'Kiosk Product',
      option: DeskObjectOption(
        children: [ColumnFields(children: kioskProductFields)],
      ),
    ),
    fromMap: KioskProduct.$fromMap,
  ),
  DeskStringField(
    name: 'sidebarTableLabel',
    title: 'Sidebar Table Label',
    option: DeskStringOption(),
  ),
  DeskArrayField<OrderLine>(
    name: 'sidebarSampleOrder',
    title: 'Sidebar Sample Order',
    innerField: DeskObjectField(
      name: 'item',
      title: 'Order Line',
      option: DeskObjectOption(
        children: [ColumnFields(children: orderLineFields)],
      ),
    ),
    fromMap: OrderLine.$fromMap,
  ),
  DeskTextField(
    name: 'footerNote',
    title: 'Footer Note',
    option: DeskTextOption(),
  ),
];

/// Generated document type spec for KioskConfig.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final kioskConfigTypeSpec = DocumentTypeSpec<KioskConfig>(
  name: 'kioskConfig',
  title: 'Kiosk screen',
  description: 'Tablet landscape in-store terminal',
  fields: kioskConfigFields,
  initialValue: KioskConfig.initialValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class KioskConfigDeskModel {
  KioskConfigDeskModel({
    required this.bannerImage,
    required this.bannerHeadline,
    required this.bannerSubtitle,
    required this.promoBadge,
    required this.gridProducts,
    required this.sidebarTableLabel,
    required this.sidebarSampleOrder,
    required this.footerNote,
  });

  final DeskData<ImageReference?> bannerImage;

  final DeskData<String> bannerHeadline;

  final DeskData<String> bannerSubtitle;

  final DeskData<String> promoBadge;

  final DeskData<List<KioskProduct>> gridProducts;

  final DeskData<String> sidebarTableLabel;

  final DeskData<List<OrderLine>> sidebarSampleOrder;

  final DeskData<String> footerNote;
}
