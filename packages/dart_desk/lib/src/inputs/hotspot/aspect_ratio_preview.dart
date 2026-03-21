import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/models/image_types.dart';

/// Shows a row of small preview thumbnails at different aspect ratios,
/// cropped respecting the hotspot center.
class AspectRatioPreviewStrip extends StatelessWidget {
  final String imageUrl;
  final Hotspot? hotspot;
  final CropRect? crop;

  const AspectRatioPreviewStrip({
    super.key,
    required this.imageUrl,
    this.hotspot,
    this.crop,
  });

  static const _ratios = [
    (label: '16:9', width: 16.0, height: 9.0),
    (label: '4:3', width: 4.0, height: 3.0),
    (label: '1:1', width: 1.0, height: 1.0),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      children: _ratios.map((ratio) {
        final aspectRatio = ratio.width / ratio.height;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80 / aspectRatio,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    alignment: hotspot != null
                        ? Alignment(
                            (hotspot!.x - 0.5) * 2,
                            (hotspot!.y - 0.5) * 2,
                          )
                        : Alignment.center,
                    child: Image.network(imageUrl),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ratio.label,
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
