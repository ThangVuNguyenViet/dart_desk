import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/widgets.dart';

import 'framing_math.dart';

/// Layout wrapper that frames [child] according to [ref.crop] and
/// [ref.hotspot]. The child must fill its allocated box (BoxFit.fill
/// semantics) — DeskFrame owns the geometry.
class DeskFrame extends StatelessWidget {
  const DeskFrame({
    super.key,
    required this.ref,
    this.fit = BoxFit.cover,
    required this.child,
  });

  final ImageReference ref;
  final BoxFit fit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
        );

        final sourceSize = (ref.width != null && ref.height != null)
            ? Size(ref.width!.toDouble(), ref.height!.toDouble())
            : boxSize;

        final geom = FramingMath.frameGeometry(
          boxSize: boxSize,
          sourceSize: sourceSize,
          crop: ref.crop ?? FramingDefaults.defaultCrop,
          hotspot: ref.hotspot ?? FramingDefaults.defaultHotspot,
          fit: fit,
        );

        return ClipRect(
          child: SizedBox(
            width: boxSize.width,
            height: boxSize.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: geom.childRect.left,
                  top: geom.childRect.top,
                  width: geom.childRect.width,
                  height: geom.childRect.height,
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
