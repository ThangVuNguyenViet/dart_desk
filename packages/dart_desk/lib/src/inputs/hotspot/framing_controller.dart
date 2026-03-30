import '../../data/models/image_types.dart';
import 'framing_math.dart';

enum FramingMode { crop, focus, preview }

class FramingDraft {
  final CropRect crop;
  final Hotspot hotspot;
  final FramingMode mode;

  const FramingDraft({
    required this.crop,
    required this.hotspot,
    required this.mode,
  });

  factory FramingDraft.initial({
    CropRect? crop,
    Hotspot? hotspot,
    FramingMode mode = FramingMode.focus,
  }) {
    final resolvedCrop = crop ?? FramingDefaults.defaultCrop;
    final resolvedHotspot = FramingMath.clampHotspotToCrop(
      hotspot ?? FramingDefaults.defaultHotspot,
      resolvedCrop,
    );
    return FramingDraft(
      crop: resolvedCrop,
      hotspot: resolvedHotspot,
      mode: mode,
    );
  }

  FramingDraft copyWith({CropRect? crop, Hotspot? hotspot, FramingMode? mode}) {
    final nextCrop = crop ?? this.crop;
    final nextHotspot = FramingMath.clampHotspotToCrop(
      hotspot ?? this.hotspot,
      nextCrop,
    );

    return FramingDraft(
      crop: nextCrop,
      hotspot: nextHotspot,
      mode: mode ?? this.mode,
    );
  }

  FramingDraft resetFocus() =>
      copyWith(hotspot: FramingDefaults.defaultHotspot);

  FramingDraft resetCrop() => copyWith(crop: FramingDefaults.defaultCrop);

  FramingDraft resetAll() => FramingDraft.initial(mode: mode);
}
