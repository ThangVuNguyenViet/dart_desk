// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'order_line.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for OrderLine
final orderLineFields = [
  CmsStringField(
    name: 'itemName',
    title: 'Item Name',
    option: CmsStringOption(),
  ),
  CmsNumberField(name: 'qty', title: 'Qty', option: CmsNumberOption(min: 1)),
  CmsNumberField(
    name: 'price',
    title: 'Price',
    option: CmsNumberOption(min: 0),
  ),
];

/// Generated document type spec for OrderLine.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final orderLineTypeSpec = DocumentTypeSpec<OrderLine>(
  name: 'orderLine',
  title: 'Order line',
  description: 'Single line in the kiosk order sidebar',
  fields: orderLineFields,
  defaultValue: OrderLine.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class OrderLineCmsConfig {
  OrderLineCmsConfig({
    required this.itemName,
    required this.qty,
    required this.price,
  });

  final CmsData<String> itemName;

  final CmsData<num> qty;

  final CmsData<num> price;
}
