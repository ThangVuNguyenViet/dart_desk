import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'hero_config.dart';

part 'array_test_config.cms.g.dart';
part 'array_test_config.mapper.dart';

@CmsConfig(
  title: 'Array Test Config',
  description: 'Testing unified array field inputs with objects and primitives',
)
@MappableClass()
class ArrayTestConfig with ArrayTestConfigMappable {
  @CmsArrayFieldConfig<String>()
  final List<String> tags;

  @CmsArrayFieldConfig<HeroConfig>()
  final List<HeroConfig> heroes;

  @CmsArrayFieldConfig<String>(
    inner: CmsImageFieldConfig(),
  )
  final List<String> gallery;

  const ArrayTestConfig({
    required this.tags,
    required this.heroes,
    required this.gallery,
  });

  static ArrayTestConfig defaultValue = const ArrayTestConfig(
    tags: ['test', 'unified'],
    heroes: [],
    gallery: [],
  );
}
