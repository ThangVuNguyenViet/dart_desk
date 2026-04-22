import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'chef_profile.cms.g.dart';
part 'chef_profile.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@CmsConfig(title: 'Chef profile', description: 'Head chef bio block')
class ChefProfile with ChefProfileMappable implements Serializable<ChefProfile> {
  @CmsStringFieldConfig(description: 'Name', option: CmsStringOption())
  final String name;

  @CmsStringFieldConfig(description: 'Role', option: CmsStringOption())
  final String role;

  @CmsImageFieldConfig(description: 'Portrait', option: CmsImageOption(hotspot: true))
  final ImageReference? portrait;

  @CmsTextFieldConfig(description: 'Bio', option: CmsTextOption())
  final String bio;

  const ChefProfile({required this.name, required this.role, this.portrait, required this.bio});

  static ChefProfile defaultValue = const ChefProfile(
    name: 'Marco Vespucci',
    role: 'Head Chef · Aura Tribeca',
    bio: 'Twelve years between Milan and Brooklyn. Cooks seasonally, apologizes rarely.',
  );

  static ChefProfile $fromMap(Map<String, dynamic> map) => ChefProfileMapper.fromMap(map);
}
