import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/image_types.dart';
import 'aspect_ratio_preview.dart';
import 'crop_overlay_painter.dart';
import 'framing_controller.dart';
import 'framing_math.dart';
import 'framing_mode_toggle.dart';
import 'hotspot_painter.dart';

class ImageHotspotEditor extends StatefulWidget {
  final String imageUrl;
  final Hotspot? initialHotspot;
  final CropRect? initialCrop;
  final FramingMode initialMode;
  final ValueChanged<FramingMode>? onModeChanged;
  final ValueChanged<({Hotspot? hotspot, CropRect? crop})> onChanged;

  const ImageHotspotEditor({
    super.key,
    required this.imageUrl,
    this.initialHotspot,
    this.initialCrop,
    this.initialMode = FramingMode.focus,
    this.onModeChanged,
    required this.onChanged,
  });

  @override
  State<ImageHotspotEditor> createState() => _ImageHotspotEditorState();
}

class _ImageHotspotEditorState extends State<ImageHotspotEditor>
    with SignalsMixin {
  late final _draft = createSignal(
    FramingDraft.initial(
      crop: widget.initialCrop,
      hotspot: widget.initialHotspot,
      mode: widget.initialMode,
    ),
  );
  late final _loadFailed = createSignal<bool>(false);

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
    final imageStream = NetworkImage(
      widget.imageUrl,
    ).resolve(ImageConfiguration.empty);
    imageStream.addListener(
      ImageStreamListener((info, _) {
        if (mounted) {
          _imageAspectRatio.value =
              info.image.width.toDouble() / info.image.height.toDouble();
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final aspectRatio = _imageAspectRatio.watch(context);
    final draft = _draft.watch(context);
    final loadFailed = _loadFailed.watch(context);

    return Column(
      key: const ValueKey('hotspot_editor'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Edit Framing', style: theme.textTheme.h4),
        const SizedBox(height: 12),
        FramingModeToggle(
          mode: draft.mode,
          onChanged: (mode) {
            _draft.value = draft.copyWith(mode: mode);
            widget.onModeChanged?.call(mode);
          },
        ),
        const SizedBox(height: 12),

        if (loadFailed)
          _ErrorState(
            onRetry: () => _loadFailed.value = false,
            onClose: () => Navigator.of(context).pop(),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: AspectRatio(
              aspectRatio: aspectRatio ?? 16 / 9,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanStart: draft.mode == FramingMode.preview
                        ? null
                        : (details) =>
                              _onPanStart(details, constraints.biggest),
                    onPanUpdate: draft.mode == FramingMode.preview
                        ? null
                        : (details) =>
                              _onPanUpdate(details, constraints.biggest),
                    onPanEnd: (_) => _dragTarget = null,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  _loadFailed.value = true;
                                }
                              });
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        if (draft.mode != FramingMode.focus)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: CropOverlayPainter(
                                crop: draft.crop,
                                imageSize: constraints.biggest,
                              ),
                            ),
                          ),
                        if (draft.mode != FramingMode.crop)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: HotspotPainter(hotspot: draft.hotspot),
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

        AspectRatioPreviewStrip(
          imageUrl: widget.imageUrl,
          hotspot: draft.hotspot,
          crop: draft.crop,
          readOnly: draft.mode == FramingMode.preview,
        ),

        const SizedBox(height: 16),

        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            ShadButton.outline(
              key: const ValueKey('reset_focus_button'),
              onPressed: () => _draft.value = draft.resetFocus(),
              size: ShadButtonSize.sm,
              child: const Text('Reset focus'),
            ),
            ShadButton.outline(
              key: const ValueKey('reset_crop_button'),
              onPressed: () => _draft.value = draft.resetCrop(),
              size: ShadButtonSize.sm,
              child: const Text('Reset crop'),
            ),
            ShadButton.outline(
              key: const ValueKey('reset_all_button'),
              onPressed: () => _draft.value = draft.resetAll(),
              size: ShadButtonSize.sm,
              child: const Text('Reset all'),
            ),
            ShadButton.outline(
              key: const ValueKey('cancel_button'),
              onPressed: () => Navigator.of(context).pop(),
              size: ShadButtonSize.sm,
              child: const Text('Cancel'),
            ),
            ShadButton(
              key: const ValueKey('apply_button'),
              onPressed: _apply,
              size: ShadButtonSize.sm,
              child: const Text('Apply'),
            ),
          ],
        ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details, Size size) {
    final pos = details.localPosition;
    final draft = _draft.value;
    final h = draft.hotspot;
    final c = draft.crop;

    if (draft.mode == FramingMode.focus) {
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

      if ((pos - center).distance < 20) {
        _dragTarget = 'hotspot';
      }
      return;
    }

    if (draft.mode == FramingMode.crop) {
      final topY = c.top * size.height;
      final bottomY = size.height - c.bottom * size.height;
      final leftX = c.left * size.width;
      final rightX = size.width - c.right * size.width;

      if ((pos.dy - topY).abs() < 15 && pos.dx > leftX && pos.dx < rightX) {
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
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    final pos = details.localPosition;
    final draft = _draft.value;
    switch (_dragTarget) {
      case 'hotspot':
        _draft.value = draft.copyWith(
          hotspot: draft.hotspot.copyWith(
            x: (pos.dx / size.width).clamp(
              draft.crop.left,
              1.0 - draft.crop.right,
            ),
            y: (pos.dy / size.height).clamp(
              draft.crop.top,
              1.0 - draft.crop.bottom,
            ),
          ),
        );
        break;
      case 'hotspot_top':
        final center = draft.hotspot.y * size.height;
        final newRy = (center - pos.dy).clamp(10.0, center);
        _draft.value = draft.copyWith(
          hotspot: draft.hotspot.copyWith(
            height: (newRy * 2 / size.height).clamp(0.05, 1.0),
          ),
        );
        break;
      case 'hotspot_bottom':
        final center = draft.hotspot.y * size.height;
        final newRy = (pos.dy - center).clamp(10.0, size.height - center);
        _draft.value = draft.copyWith(
          hotspot: draft.hotspot.copyWith(
            height: (newRy * 2 / size.height).clamp(0.05, 1.0),
          ),
        );
        break;
      case 'hotspot_left':
        final center = draft.hotspot.x * size.width;
        final newRx = (center - pos.dx).clamp(10.0, center);
        _draft.value = draft.copyWith(
          hotspot: draft.hotspot.copyWith(
            width: (newRx * 2 / size.width).clamp(0.05, 1.0),
          ),
        );
        break;
      case 'hotspot_right':
        final center = draft.hotspot.x * size.width;
        final newRx = (pos.dx - center).clamp(10.0, size.width - center);
        _draft.value = draft.copyWith(
          hotspot: draft.hotspot.copyWith(
            width: (newRx * 2 / size.width).clamp(0.05, 1.0),
          ),
        );
        break;
      case 'crop_top':
        _draft.value = draft.copyWith(
          crop: CropRect(
            top: (pos.dy / size.height).clamp(
              0.0,
              1.0 - draft.crop.bottom - 0.1,
            ),
            bottom: draft.crop.bottom,
            left: draft.crop.left,
            right: draft.crop.right,
          ),
        );
        break;
      case 'crop_bottom':
        _draft.value = draft.copyWith(
          crop: CropRect(
            top: draft.crop.top,
            bottom: (1.0 - pos.dy / size.height).clamp(
              0.0,
              1.0 - draft.crop.top - 0.1,
            ),
            left: draft.crop.left,
            right: draft.crop.right,
          ),
        );
        break;
      case 'crop_left':
        _draft.value = draft.copyWith(
          crop: CropRect(
            top: draft.crop.top,
            bottom: draft.crop.bottom,
            left: (pos.dx / size.width).clamp(
              0.0,
              1.0 - draft.crop.right - 0.1,
            ),
            right: draft.crop.right,
          ),
        );
        break;
      case 'crop_right':
        _draft.value = draft.copyWith(
          crop: CropRect(
            top: draft.crop.top,
            bottom: draft.crop.bottom,
            left: draft.crop.left,
            right: (1.0 - pos.dx / size.width).clamp(
              0.0,
              1.0 - draft.crop.left - 0.1,
            ),
          ),
        );
        break;
    }
  }

  void _apply() {
    final draft = _draft.value;
    widget.onChanged((hotspot: draft.hotspot, crop: draft.crop));
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const _ErrorState({required this.onRetry, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: ShadTheme.of(context).colorScheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(child: Text('Could not load image')),
          ShadButton.outline(
            key: const ValueKey('retry_image_button'),
            onPressed: onRetry,
            size: ShadButtonSize.sm,
            child: const Text('Retry'),
          ),
          const SizedBox(width: 8),
          ShadButton.outline(
            key: const ValueKey('close_error_button'),
            onPressed: onClose,
            size: ShadButtonSize.sm,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
