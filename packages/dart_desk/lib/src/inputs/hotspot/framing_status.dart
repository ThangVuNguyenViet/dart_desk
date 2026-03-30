import '../../data/models/image_reference.dart';
import 'framing_math.dart';

class FramingStatus {
  static String labelFor(ImageReference ref) {
    final crop = ref.crop;
    final hotspot = ref.hotspot;

    final hasCustomCrop = crop != null && crop != FramingDefaults.defaultCrop;
    final hasCustomFocus =
        hotspot != null && hotspot != FramingDefaults.defaultHotspot;

    if (hasCustomCrop) return 'Crop adjusted';
    if (hasCustomFocus) return 'Focus set';
    return 'Default framing';
  }
}
