// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'kiosk_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for KioskConfig
final kioskConfigFields = [
  CmsImageField(
    name: 'bannerImage',
    title: 'Banner Image',
    option: CmsImageOption(hotspot: true),
  ),
  CmsStringField(
    name: 'bannerHeadline',
    title: 'Banner Headline',
    option: CmsStringOption(),
  ),
  CmsTextField(
    name: 'bannerSubtitle',
    title: 'Banner Subtitle',
    option: CmsTextOption(),
  ),
  CmsStringField(
    name: 'promoBadge',
    title: 'Promo Badge',
    option: CmsStringOption(),
  ),
  CmsArrayField<KioskProduct>(
    name: 'gridProducts',
    title: 'Grid Products',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Kiosk Product',
      option: CmsObjectOption(
        children: [ColumnFields(children: kioskProductFields)],
      ),
    ),
    fromMap: KioskProduct.$fromMap,
  ),
  CmsStringField(
    name: 'sidebarTableLabel',
    title: 'Sidebar Table Label',
    option: CmsStringOption(),
  ),
  CmsArrayField<OrderLine>(
    name: 'sidebarSampleOrder',
    title: 'Sidebar Sample Order',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Order Line',
      option: CmsObjectOption(
        children: [ColumnFields(children: orderLineFields)],
      ),
    ),
    fromMap: OrderLine.$fromMap,
  ),
  CmsTextField(
    name: 'footerNote',
    title: 'Footer Note',
    option: CmsTextOption(),
  ),
];

/// Generated document type spec for KioskConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final kioskConfigTypeSpec = DocumentTypeSpec<KioskConfig>(
  name: 'kioskConfig',
  title: 'Kiosk screen',
  description: 'Tablet landscape in-store terminal',
  fields: kioskConfigFields,
  defaultValue: KioskConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class KioskConfigCmsConfig {
  KioskConfigCmsConfig({
    required this.bannerImage,
    required this.bannerHeadline,
    required this.bannerSubtitle,
    required this.promoBadge,
    required this.gridProducts,
    required this.sidebarTableLabel,
    required this.sidebarSampleOrder,
    required this.footerNote,
  });

  final CmsData<ImageReference?> bannerImage;

  final CmsData<String> bannerHeadline;

  final CmsData<String> bannerSubtitle;

  final CmsData<String> promoBadge;

  final CmsData<List<KioskProduct>> gridProducts;

  final CmsData<String> sidebarTableLabel;

  final CmsData<List<OrderLine>> sidebarSampleOrder;

  final CmsData<String> footerNote;
}
