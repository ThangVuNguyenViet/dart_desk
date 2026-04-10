import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/models/image_types.dart';
import 'framing_math.dart';

/// Shows a row of small preview thumbnails at different aspect ratios,
/// cropped respecting the hotspot center.
class AspectRatioPreviewStrip extends StatelessWidget {
  final String imageUrl;
  final Hotspot hotspot;
  final CropRect crop;
  final bool readOnly;

  const AspectRatioPreviewStrip({
    super.key,
    required this.imageUrl,
    required this.hotspot,
    required this.crop,
    this.readOnly = false,
  });

  static const _ratios = [
    (label: '16:9', desc: 'Hero', width: 16.0, height: 9.0),
    (label: '4:3', desc: 'Card', width: 4.0, height: 3.0),
    (label: '1:1', desc: 'Thumb', width: 1.0, height: 1.0),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final alignment = FramingMath.previewAlignment(
      crop: crop,
      hotspot: hotspot,
    );
    final visibleWidth = (1.0 - crop.left - crop.right).clamp(0.1, 1.0);
    final visibleHeight = (1.0 - crop.top - crop.bottom).clamp(0.1, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: theme.textTheme.small.copyWith(
            color: theme.colorScheme.mutedForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _ratios.map((ratio) {
            final aspectRatio = ratio.width / ratio.height;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80 / aspectRatio,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: theme.colorScheme.border,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        alignment: alignment,
                        child: SizedBox(
                          width: 80 / visibleWidth,
                          height: (80 / aspectRatio) / visibleHeight,
                          child: Image.network(imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ratio.label,
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.foreground,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    ratio.desc,
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
