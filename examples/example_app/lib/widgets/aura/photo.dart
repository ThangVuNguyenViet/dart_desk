import 'package:dart_desk/dart_desk.dart';
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

  /// Returns the best available URL from [reference], falling back to
  /// [fallbackUrl]. Uses [ImageReference.url] which resolves publicUrl →
  /// externalUrl → defaultAssetResolver in that priority order.
  String? get _url => reference?.url ?? fallbackUrl;

  @override
  Widget build(BuildContext context) {
    final url = _url;
    final child = url == null
        ? Container(color: const Color(0xFFECE3D0))
        : Image.network(url, fit: BoxFit.cover, width: width, height: height);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(fit: StackFit.passthrough, children: [
        SizedBox(width: width, height: height, child: child),
        if (overlay != null) Positioned.fill(child: overlay!),
      ]),
    );
  }
}
