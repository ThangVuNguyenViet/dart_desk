import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/image_types.dart';
import 'aspect_ratio_preview.dart';
import 'crop_overlay_painter.dart';
import 'hotspot_painter.dart';

class ImageHotspotEditor extends StatefulWidget {
  final String imageUrl;
  final Hotspot? initialHotspot;
  final CropRect? initialCrop;
  final ValueChanged<({Hotspot? hotspot, CropRect? crop})> onChanged;

  const ImageHotspotEditor({
    super.key,
    required this.imageUrl,
    this.initialHotspot,
    this.initialCrop,
    required this.onChanged,
  });

  @override
  State<ImageHotspotEditor> createState() => _ImageHotspotEditorState();
}

class _ImageHotspotEditorState extends State<ImageHotspotEditor>
    with SignalsMixin {
  late final _crop = createSignal(
    widget.initialCrop ??
        const CropRect(top: 0, bottom: 0, left: 0, right: 0),
  );
  late final _hotspot = createSignal(
    widget.initialHotspot ??
        const Hotspot(x: 0.5, y: 0.5, width: 0.3, height: 0.3),
  );

  // Track which element is being dragged
  String? _dragTarget;

  // Track the image's actual aspect ratio once loaded
  late final _imageAspectRatio = createSignal<double?>(null);

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  void _loadImageDimensions() {
    final imageStream =
        NetworkImage(widget.imageUrl).resolve(ImageConfiguration.empty);
    imageStream.addListener(ImageStreamListener((info, _) {
      if (mounted) {
        _imageAspectRatio.value =
            info.image.width.toDouble() / info.image.height.toDouble();
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final aspectRatio = _imageAspectRatio.watch(context);

    return Column(
      key: const ValueKey('hotspot_editor'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Edit Hotspot & Crop',
            style: theme.textTheme.h4,
          ),
        ),

        // Image with overlays
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: AspectRatio(
            aspectRatio: aspectRatio ?? 16 / 9,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanStart: (details) =>
                      _onPanStart(details, constraints.biggest),
                  onPanUpdate: (details) =>
                      _onPanUpdate(details, constraints.biggest),
                  onPanEnd: (_) => _dragTarget = null,
                  child: Stack(
                    children: [
                      // Base image
                      Positioned.fill(
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Crop overlay
                      Positioned.fill(
                        child: Watch(
                          (context) => CustomPaint(
                            painter: CropOverlayPainter(
                              crop: _crop.value,
                              imageSize: constraints.biggest,
                            ),
                          ),
                        ),
                      ),
                      // Hotspot overlay
                      Positioned.fill(
                        child: Watch(
                          (context) => CustomPaint(
                            painter:
                                HotspotPainter(hotspot: _hotspot.value),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Aspect ratio previews
        Watch(
          (context) => AspectRatioPreviewStrip(
            imageUrl: widget.imageUrl,
            hotspot: _hotspot.value,
            crop: _crop.value,
          ),
        ),

        const SizedBox(height: 16),

        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ShadButton.outline(
              key: const ValueKey('reset_button'),
              onPressed: _reset,
              size: ShadButtonSize.sm,
              child: const Text('Reset'),
            ),
            const SizedBox(width: 8),
            ShadButton(
              key: const ValueKey('done_button'),
              onPressed: _done,
              size: ShadButtonSize.sm,
              child: const Text('Done'),
            ),
          ],
        ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details, Size size) {
    final pos = details.localPosition;
    final h = _hotspot.value;
    final c = _crop.value;

    // Check hotspot cardinal handles first (resize)
    final center = Offset(h.x * size.width, h.y * size.height);
    final rx = h.width * size.width / 2;
    final ry = h.height * size.height / 2;

    final topHandle = Offset(center.dx, center.dy - ry);
    final bottomHandle = Offset(center.dx, center.dy + ry);
    final leftHandle = Offset(center.dx - rx, center.dy);
    final rightHandle = Offset(center.dx + rx, center.dy);

    if ((pos - topHandle).distance < 15) {
      _dragTarget = 'hotspot_top';
      return;
    }
    if ((pos - bottomHandle).distance < 15) {
      _dragTarget = 'hotspot_bottom';
      return;
    }
    if ((pos - leftHandle).distance < 15) {
      _dragTarget = 'hotspot_left';
      return;
    }
    if ((pos - rightHandle).distance < 15) {
      _dragTarget = 'hotspot_right';
      return;
    }

    // Check if near hotspot center (drag to move)
    if ((pos - center).distance < 20) {
      _dragTarget = 'hotspot';
      return;
    }

    // Check crop edge handles
    final topY = c.top * size.height;
    final bottomY = size.height - c.bottom * size.height;
    final leftX = c.left * size.width;
    final rightX = size.width - c.right * size.width;

    if ((pos.dy - topY).abs() < 15 &&
        pos.dx > leftX &&
        pos.dx < rightX) {
      _dragTarget = 'crop_top';
    } else if ((pos.dy - bottomY).abs() < 15 &&
        pos.dx > leftX &&
        pos.dx < rightX) {
      _dragTarget = 'crop_bottom';
    } else if ((pos.dx - leftX).abs() < 15 &&
        pos.dy > topY &&
        pos.dy < bottomY) {
      _dragTarget = 'crop_left';
    } else if ((pos.dx - rightX).abs() < 15 &&
        pos.dy > topY &&
        pos.dy < bottomY) {
      _dragTarget = 'crop_right';
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    final pos = details.localPosition;
    switch (_dragTarget) {
      case 'hotspot':
        _hotspot.value = _hotspot.value.copyWith(
          x: (pos.dx / size.width).clamp(0.0, 1.0),
          y: (pos.dy / size.height).clamp(0.0, 1.0),
        );
      case 'hotspot_top':
        final center = _hotspot.value.y * size.height;
        final newRy = (center - pos.dy).clamp(10.0, center);
        _hotspot.value = _hotspot.value.copyWith(
          height: (newRy * 2 / size.height).clamp(0.05, 1.0),
        );
      case 'hotspot_bottom':
        final center = _hotspot.value.y * size.height;
        final newRy = (pos.dy - center).clamp(10.0, size.height - center);
        _hotspot.value = _hotspot.value.copyWith(
          height: (newRy * 2 / size.height).clamp(0.05, 1.0),
        );
      case 'hotspot_left':
        final center = _hotspot.value.x * size.width;
        final newRx = (center - pos.dx).clamp(10.0, center);
        _hotspot.value = _hotspot.value.copyWith(
          width: (newRx * 2 / size.width).clamp(0.05, 1.0),
        );
      case 'hotspot_right':
        final center = _hotspot.value.x * size.width;
        final newRx = (pos.dx - center).clamp(10.0, size.width - center);
        _hotspot.value = _hotspot.value.copyWith(
          width: (newRx * 2 / size.width).clamp(0.05, 1.0),
        );
      case 'crop_top':
        _crop.value = CropRect(
          top: (pos.dy / size.height)
              .clamp(0.0, 1.0 - _crop.value.bottom - 0.1),
          bottom: _crop.value.bottom,
          left: _crop.value.left,
          right: _crop.value.right,
        );
      case 'crop_bottom':
        _crop.value = CropRect(
          top: _crop.value.top,
          bottom: (1.0 - pos.dy / size.height)
              .clamp(0.0, 1.0 - _crop.value.top - 0.1),
          left: _crop.value.left,
          right: _crop.value.right,
        );
      case 'crop_left':
        _crop.value = CropRect(
          top: _crop.value.top,
          bottom: _crop.value.bottom,
          left: (pos.dx / size.width)
              .clamp(0.0, 1.0 - _crop.value.right - 0.1),
          right: _crop.value.right,
        );
      case 'crop_right':
        _crop.value = CropRect(
          top: _crop.value.top,
          bottom: _crop.value.bottom,
          left: _crop.value.left,
          right: (1.0 - pos.dx / size.width)
              .clamp(0.0, 1.0 - _crop.value.left - 0.1),
        );
    }
  }

  void _reset() {
    _crop.value = const CropRect(top: 0, bottom: 0, left: 0, right: 0);
    _hotspot.value =
        const Hotspot(x: 0.5, y: 0.5, width: 0.3, height: 0.3);
  }

  void _done() {
    widget.onChanged((hotspot: _hotspot.value, crop: _crop.value));
  }
}
