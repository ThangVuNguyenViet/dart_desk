import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/material.dart';

/// Image with rounded corners, `BoxFit.cover`, and an optional overlay.
/// Accepts a [dart_desk] [ImageReference] or a fallback URL.
class Photo extends StatelessWidget {
  final ImageReference? reference;
  final String? fallbackUrl;
  final double? width;
  final double? height;
  final double radius;
  final Widget? overlay;

  const Photo({
    super.key,
    this.reference,
    this.fallbackUrl,
    this.width,
    this.height,
    this.radius = 14,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final child = reference != null
        ? DeskImageView(reference!)
        : fallbackUrl != null
        ? Image.network(fallbackUrl!, fit: BoxFit.cover)
        : const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          SizedBox(width: width, height: height, child: child),
          if (overlay != null) Positioned.fill(child: overlay!),
        ],
      ),
    );
  }
}
