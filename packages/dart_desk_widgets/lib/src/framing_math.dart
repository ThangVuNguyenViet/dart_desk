import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/widgets.dart';

class FramingDefaults {
  static const defaultCrop = CropRect(top: 0, bottom: 0, left: 0, right: 0);
  static const defaultHotspot = Hotspot(
    x: 0.5,
    y: 0.5,
    width: 0.3,
    height: 0.3,
  );
}

class FrameGeometry {
  /// The rect, in the box's local coordinate space, where the child widget
  /// should be laid out. May extend outside the box; caller clips.
  final Rect childRect;

  const FrameGeometry({required this.childRect});
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

  static FrameGeometry frameGeometry({
    required Size boxSize,
    required Size sourceSize,
    required CropRect crop,
    required Hotspot hotspot,
    required BoxFit fit,
  }) {
    final visibleW = sourceSize.width * (1.0 - crop.left - crop.right);
    final visibleH = sourceSize.height * (1.0 - crop.top - crop.bottom);
    if (visibleW <= 0 ||
        visibleH <= 0 ||
        boxSize.width <= 0 ||
        boxSize.height <= 0) {
      return FrameGeometry(
        childRect: Rect.fromLTWH(0, 0, boxSize.width, boxSize.height),
      );
    }

    final double scale;
    switch (fit) {
      case BoxFit.cover:
        scale = (boxSize.width / visibleW) > (boxSize.height / visibleH)
            ? boxSize.width / visibleW
            : boxSize.height / visibleH;
        break;
      case BoxFit.contain:
        scale = (boxSize.width / visibleW) < (boxSize.height / visibleH)
            ? boxSize.width / visibleW
            : boxSize.height / visibleH;
        break;
      default:
        scale = boxSize.width / visibleW;
    }

    final childW = sourceSize.width * scale;
    final childH = sourceSize.height * scale;

    final clamped = clampHotspotToCrop(hotspot, crop);
    final hotspotX = clamped.x * childW;
    final hotspotY = clamped.y * childH;

    double left = boxSize.width / 2 - hotspotX;
    double top = boxSize.height / 2 - hotspotY;

    final cropLeftPx = crop.left * childW;
    final cropTopPx = crop.top * childH;
    final cropRightPx = crop.right * childW;
    final cropBottomPx = crop.bottom * childH;

    if (fit == BoxFit.cover) {
      final maxLeft = -cropLeftPx;
      final minLeft = boxSize.width + cropRightPx - childW;
      if (minLeft >= maxLeft) {
        left = (maxLeft + minLeft) / 2;
      } else {
        left = left.clamp(minLeft, maxLeft).toDouble();
      }

      final maxTop = -cropTopPx;
      final minTop = boxSize.height + cropBottomPx - childH;
      if (minTop >= maxTop) {
        top = (maxTop + minTop) / 2;
      } else {
        top = top.clamp(minTop, maxTop).toDouble();
      }
    } else if (fit == BoxFit.contain) {
      left =
          (boxSize.width - (childW - cropLeftPx - cropRightPx)) / 2 -
              cropLeftPx;
      top =
          (boxSize.height - (childH - cropTopPx - cropBottomPx)) / 2 -
              cropTopPx;
    }

    return FrameGeometry(
      childRect: Rect.fromLTWH(left, top, childW, childH),
    );
  }
}
