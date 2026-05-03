import '../base/field.dart';
import '../../models/image_ref.dart'; // exports ImageReference (and deprecated ImageRef typedef)

enum DeskMediaType { image, svg, lottie, video }

class DeskImageOption extends DeskOption {
  final bool hotspot; // defaults to true — exposes the framing editor
  final List<DeskMediaType>? acceptedTypes; // null = all types (default)

  const DeskImageOption({
    this.hotspot = true,
    this.acceptedTypes,
    super.optional,
    super.visibleWhen,
  });
}

class DeskImageField extends DeskField {
  const DeskImageField({
    required super.name,
    required super.title,
    super.description,
    DeskImageOption? super.option,
  });

  @override
  DeskImageOption? get option => super.option as DeskImageOption?;
}

class DeskImage extends DeskFieldConfig {
  const DeskImage({
    super.name,
    super.title,
    super.description,
    DeskImageOption? super.option,
  });

  @override
  List<Type> get supportedFieldTypes => [Object, ImageReference];
}
