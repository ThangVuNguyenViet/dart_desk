// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'order_line.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for OrderLine
final orderLineFields = [
  DeskStringField(
    name: 'itemName',
    title: 'Item Name',
    option: DeskStringOption(),
  ),
  DeskNumberField(name: 'qty', title: 'Qty', option: DeskNumberOption(min: 1)),
  DeskNumberField(
    name: 'price',
    title: 'Price',
    option: DeskNumberOption(min: 0),
  ),
];

/// Generated document type spec for OrderLine.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final orderLineTypeSpec = DocumentTypeSpec<OrderLine>(
  name: 'orderLine',
  title: 'Order line',
  description: 'Single line in the kiosk order sidebar',
  fields: orderLineFields,
  initialValue: OrderLine.initialValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class OrderLineDeskModel {
  OrderLineDeskModel({
    required this.itemName,
    required this.qty,
    required this.price,
  });

  final DeskData<String> itemName;

  final DeskData<num> qty;

  final DeskData<num> price;
}
