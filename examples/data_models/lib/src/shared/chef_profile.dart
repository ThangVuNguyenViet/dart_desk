import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'chef_profile.desk.dart';
part 'chef_profile.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@DeskModel(title: 'Chef profile', description: 'Head chef bio block')
class ChefProfile with ChefProfileMappable implements Serializable<ChefProfile> {
  @DeskString(description: 'Name', option: DeskStringOption())
  final String name;

  @DeskString(description: 'Role', option: DeskStringOption())
  final String role;

  @DeskImage(description: 'Portrait', option: DeskImageOption(hotspot: true))
  final ImageReference? portrait;

  @DeskText(description: 'Bio', option: DeskTextOption())
  final String bio;

  const ChefProfile({required this.name, required this.role, this.portrait, required this.bio});

  static ChefProfile defaultValue = const ChefProfile(
    name: 'Marco Vespucci',
    role: 'Head Chef · Aura Tribeca',
    bio: 'Twelve years between Milan and Brooklyn. Cooks seasonally, apologizes rarely.',
  );

  static ChefProfile $fromMap(Map<String, dynamic> map) => ChefProfileMapper.fromMap(map);
}
