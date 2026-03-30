import 'package:flutter/material.dart';

import '../../data/models/image_types.dart';

class FramingDefaults {
  static const defaultCrop = CropRect(top: 0, bottom: 0, left: 0, right: 0);
  static const defaultHotspot = Hotspot(
    x: 0.5,
    y: 0.5,
    width: 0.3,
    height: 0.3,
  );
}

class FramingMath {
  static Hotspot clampHotspotToCrop(Hotspot hotspot, CropRect crop) {
    final minX = crop.left;
    final maxX = 1.0 - crop.right;
    final minY = crop.top;
    final maxY = 1.0 - crop.bottom;

    return hotspot.copyWith(
      x: hotspot.x.clamp(minX, maxX).toDouble(),
      y: hotspot.y.clamp(minY, maxY).toDouble(),
    );
  }

  static Alignment previewAlignment({
    required CropRect crop,
    required Hotspot hotspot,
  }) {
    final clamped = clampHotspotToCrop(hotspot, crop);
    final visibleCenterX = (crop.left + (1.0 - crop.right)) / 2;
    final visibleCenterY = (crop.top + (1.0 - crop.bottom)) / 2;

    return Alignment(
      ((clamped.x - visibleCenterX) * 2).clamp(-1.0, 1.0),
      ((clamped.y - visibleCenterY) * 2).clamp(-1.0, 1.0),
    );
  }
}
