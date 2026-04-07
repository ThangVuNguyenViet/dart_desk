// Core imports
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'array_test_config.cms.g.dart';
part 'array_test_config.mapper.dart';

// --- Placeholder Definitions ---
// These classes would typically be defined elsewhere in the project,
// e.g., in a dedicated 'models' directory. For this example,
// they are included here to make the config file self-contained.

/// Represents a reference to an image, likely with a URL.
@MappableClass()
class ImageReference with ImageReferenceMappable {
  final String url;
  const ImageReference({required this.url});

  // Add a default value if needed by List<ImageReference> fields later
  static ImageReference? defaultValue = const ImageReference(url: '');
}

/// Represents a CMS-configured Hero object.
@MappableClass()
@CmsConfig(
  title: 'Hero Configuration',
  description: 'Configuration for the hero section',
) // Annotated as a CMS Config
class HeroConfig with HeroConfigMappable implements Serializable<HeroConfig> {
  final String title;
  final ImageReference? heroImage; // Uses the placeholder ImageReference

  const HeroConfig({required this.title, this.heroImage});

  // Default value for the HeroConfig
  static HeroConfig? defaultValue = const HeroConfig(title: '');
}

/// An un-annotated class to test auto-discovery in CmsArrayField.
/// The prompt requires it to be NOT annotated with @CmsConfig.
class SampleConfig {
  final String name;
  final ImageReference? image; // Uses the placeholder ImageReference

  const SampleConfig({required this.name, this.image});

  // Default value for SampleConfig, important if List<SampleConfig> is used
  static SampleConfig? defaultValue = const SampleConfig(name: '');
}

// --- Main Configuration Class ---

/// The main configuration class for array field testing.
@CmsConfig(
  title: 'Array Test Configuration',
  description: 'Configuration for testing array fields in CMS',
)
@MappableClass()
class ArrayTestConfig
    with ArrayTestConfigMappable
    implements Serializable<ArrayTestConfig> {
  /// A list of primitive strings.
  final List<String> primitiveStrings;

  /// A list of CMS-configured Hero objects.
  @CmsArrayFieldConfig<HeroConfig>()
  final List<HeroConfig> cmsObjectList;

  /// A list of un-annotated objects, expected to be auto-discovered.
  @CmsArrayFieldConfig<SampleConfig>()
  final List<SampleConfig> unannotatedObjectList;

  /// A list of strings, but with an explicit CmsImageFieldConfig as the inner field.
  /// This overrides the default inference for primitive strings.
  @CmsArrayFieldConfig(
    inner: CmsImageFieldConfig(), // Explicitly specify inner field type
  )
  final List<String> stringListWithImageInner;

  const ArrayTestConfig({
    required this.primitiveStrings,
    required this.cmsObjectList,
    required this.unannotatedObjectList,
    required this.stringListWithImageInner,
  });

  // Default value for the main configuration class
  static ArrayTestConfig? defaultValue = const ArrayTestConfig(
    primitiveStrings: [],
    cmsObjectList: [],
    unannotatedObjectList: [],
    stringListWithImageInner: [],
  );
}
