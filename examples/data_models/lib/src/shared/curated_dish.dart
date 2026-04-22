import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'curated_dish.cms.g.dart';
part 'curated_dish.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@CmsConfig(title: 'Curated dish', description: 'Entry in the Chef\'s Choice list')
class CuratedDish with CuratedDishMappable implements Serializable<CuratedDish> {
  @CmsStringFieldConfig(description: 'Order number (e.g. "01")', option: CmsStringOption())
  final String numberLabel;

  @CmsStringFieldConfig(description: 'Dish name', option: CmsStringOption())
  final String name;

  @CmsNumberFieldConfig(description: 'Price', option: CmsNumberOption(min: 0))
  final num price;

  @CmsImageFieldConfig(description: 'Photo', option: CmsImageOption(hotspot: true))
  final ImageReference? image;

  @CmsBlockFieldConfig(option: CmsBlockOption())
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
