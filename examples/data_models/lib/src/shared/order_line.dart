import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'order_line.desk.dart';
part 'order_line.mapper.dart';

@MappableClass()
@DeskModel(title: 'Order line', description: 'Single line in the kiosk order sidebar')
class OrderLine with OrderLineMappable implements Serializable<OrderLine> {
  @DeskString(description: 'Item name', option: DeskStringOption())
  final String itemName;

  @DeskNumber(description: 'Qty', option: DeskNumberOption(min: 1))
  final num qty;

  @DeskNumber(description: 'Unit price', option: DeskNumberOption(min: 0))
  final num price;

  const OrderLine({required this.itemName, required this.qty, required this.price});

  static OrderLine defaultValue = const OrderLine(itemName: 'Olive Oil Cake', qty: 1, price: 11);

  static OrderLine $fromMap(Map<String, dynamic> map) => OrderLineMapper.fromMap(map);
}
