import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'curated_dish.desk.dart';
part 'curated_dish.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@DeskModel(title: 'Curated dish', description: 'Entry in the Chef\'s Choice list')
class CuratedDish with CuratedDishMappable implements Serializable<CuratedDish> {
  @DeskString(description: 'Order number (e.g. "01")', option: DeskStringOption())
  final String numberLabel;

  @DeskString(description: 'Dish name', option: DeskStringOption())
  final String name;

  @DeskNumber(description: 'Price', option: DeskNumberOption(min: 0))
  final num price;

  @DeskImage(description: 'Photo', option: DeskImageOption(hotspot: true))
  final ImageReference? image;

  @DeskBlock(option: DeskBlockOption())
  final Object? description;

  const CuratedDish({
    required this.numberLabel,
    required this.name,
    required this.price,
    this.image,
    this.description,
  });

  static CuratedDish defaultValue = const CuratedDish(numberLabel: '01', name: 'Pea Tendril Agnolotti', price: 26);

  static CuratedDish $fromMap(Map<String, dynamic> map) => CuratedDishMapper.fromMap(map);
}
