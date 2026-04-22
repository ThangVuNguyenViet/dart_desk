// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order_line.dart';

class OrderLineMapper extends ClassMapperBase<OrderLine> {
  OrderLineMapper._();

  static OrderLineMapper? _instance;
  static OrderLineMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderLineMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'OrderLine';

  static String _$itemName(OrderLine v) => v.itemName;
  static const Field<OrderLine, String> _f$itemName = Field(
    'itemName',
    _$itemName,
  );
  static num _$qty(OrderLine v) => v.qty;
  static const Field<OrderLine, num> _f$qty = Field('qty', _$qty);
  static num _$price(OrderLine v) => v.price;
  static const Field<OrderLine, num> _f$price = Field('price', _$price);

  @override
  final MappableFields<OrderLine> fields = const {
    #itemName: _f$itemName,
    #qty: _f$qty,
    #price: _f$price,
  };

  static OrderLine _instantiate(DecodingData data) {
    return OrderLine(
      itemName: data.dec(_f$itemName),
      qty: data.dec(_f$qty),
      price: data.dec(_f$price),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrderLine fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrderLine>(map);
  }

  static OrderLine fromJson(String json) {
    return ensureInitialized().decodeJson<OrderLine>(json);
  }
}

mixin OrderLineMappable {
  String toJson() {
    return OrderLineMapper.ensureInitialized().encodeJson<OrderLine>(
      this as OrderLine,
    );
  }

  Map<String, dynamic> toMap() {
    return OrderLineMapper.ensureInitialized().encodeMap<OrderLine>(
      this as OrderLine,
    );
  }

  OrderLineCopyWith<OrderLine, OrderLine, OrderLine> get copyWith =>
      _OrderLineCopyWithImpl<OrderLine, OrderLine>(
        this as OrderLine,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OrderLineMapper.ensureInitialized().stringifyValue(
      this as OrderLine,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrderLineMapper.ensureInitialized().equalsValue(
      this as OrderLine,
      other,
    );
  }

  @override
  int get hashCode {
    return OrderLineMapper.ensureInitialized().hashValue(this as OrderLine);
  }
}

extension OrderLineValueCopy<$R, $Out> on ObjectCopyWith<$R, OrderLine, $Out> {
  OrderLineCopyWith<$R, OrderLine, $Out> get $asOrderLine =>
      $base.as((v, t, t2) => _OrderLineCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrderLineCopyWith<$R, $In extends OrderLine, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? itemName, num? qty, num? price});
  OrderLineCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OrderLineCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrderLine, $Out>
    implements OrderLineCopyWith<$R, OrderLine, $Out> {
  _OrderLineCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrderLine> $mapper =
      OrderLineMapper.ensureInitialized();
  @override
  $R call({String? itemName, num? qty, num? price}) => $apply(
    FieldCopyWithData({
      if (itemName != null) #itemName: itemName,
      if (qty != null) #qty: qty,
      if (price != null) #price: price,
    }),
  );
  @override
  OrderLine $make(CopyWithData data) => OrderLine(
    itemName: data.get(#itemName, or: $value.itemName),
    qty: data.get(#qty, or: $value.qty),
    price: data.get(#price, or: $value.price),
  );

  @override
  OrderLineCopyWith<$R2, OrderLine, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrderLineCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

