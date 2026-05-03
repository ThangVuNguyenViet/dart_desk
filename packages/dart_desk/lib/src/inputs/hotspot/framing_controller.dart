import 'dart:ui';

import '../../data/models/image_types.dart';
import 'framing_math.dart';

enum FramingMode { crop, focus, transform, preview }

class FramingDraft {
  final CropRect crop;
  final Hotspot hotspot;
  final FramingMode mode;
  final double? scale;
  final Offset? offset;

  const FramingDraft({
    required this.crop,
    required this.hotspot,
    required this.mode,
    this.scale,
    this.offset,
  });

  factory FramingDraft.initial({
    CropRect? crop,
    Hotspot? hotspot,
    FramingMode mode = FramingMode.focus,
    double? scale,
    Offset? offset,
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
      scale: scale,
      offset: offset,
    );
  }

  FramingDraft copyWith({
    CropRect? crop,
    Hotspot? hotspot,
    FramingMode? mode,
    double? scale,
    Offset? offset,
  }) {
    final nextCrop = crop ?? this.crop;
    final nextHotspot = FramingMath.clampHotspotToCrop(
      hotspot ?? this.hotspot,
      nextCrop,
    );

    return FramingDraft(
      crop: nextCrop,
      hotspot: nextHotspot,
      mode: mode ?? this.mode,
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
    );
  }

  FramingDraft resetFocus() =>
      copyWith(hotspot: FramingDefaults.defaultHotspot);

  FramingDraft resetCrop() => copyWith(crop: FramingDefaults.defaultCrop);

  FramingDraft resetTransform() => FramingDraft(
    crop: crop,
    hotspot: hotspot,
    mode: mode,
    scale: null,
    offset: null,
  );

  FramingDraft resetAll() => FramingDraft.initial(mode: mode);
}
