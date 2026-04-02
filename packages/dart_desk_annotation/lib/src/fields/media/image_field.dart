import '../base/field.dart';
import '../../models/image_ref.dart'; // exports ImageReference (and deprecated ImageRef typedef)

enum CmsMediaType { image, svg, lottie, video }

class CmsImageOption extends CmsOption {
  final bool hotspot;
  final List<CmsMediaType>? acceptedTypes; // null = all types (default)

  const CmsImageOption({
    required this.hotspot,
    this.acceptedTypes,
    super.hidden,
  });
}

class CmsImageField extends CmsField {
  const CmsImageField({
    required super.name,
    required super.title,
    super.description,
    CmsImageOption? super.option,
  });

  @override
  CmsImageOption? get option => super.option as CmsImageOption?;
}

class CmsImageFieldConfig extends CmsFieldConfig {
  const CmsImageFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsImageOption? super.option,
  });

  @override
  List<Type> get supportedFieldTypes => [Object, ImageReference];
}
