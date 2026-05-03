import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/image_types.dart';
import 'aspect_ratio_preview.dart';
import 'crop_overlay_painter.dart';
import 'framing_controller.dart';
import 'framing_mode_toggle.dart';
import 'hotspot_painter.dart';

class ImageHotspotEditor extends StatefulWidget {
  final String imageUrl;
  final Hotspot? initialHotspot;
  final CropRect? initialCrop;
  final FramingMode initialMode;
  final double? initialScale;
  final Offset? initialOffset;
  final ValueChanged<FramingMode>? onModeChanged;
  final ValueChanged<
    ({Hotspot? hotspot, CropRect? crop, double? scale, Offset? offset})
  >
  onChanged;
  final ValueChanged<
    ({Hotspot? hotspot, CropRect? crop, double? scale, Offset? offset})
  >?
  onLiveChange;
  final VoidCallback? onCancel;

  const ImageHotspotEditor({
    super.key,
    required this.imageUrl,
    this.initialHotspot,
    this.initialCrop,
    this.initialMode = FramingMode.focus,
    this.initialScale,
    this.initialOffset,
    this.onModeChanged,
    required this.onChanged,
    this.onLiveChange,
    this.onCancel,
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
      scale: widget.initialScale,
      offset: widget.initialOffset,
    ),
  );
  late final _loadFailed = createSignal<bool>(false);

  late final _liveEffect = createEffect(() {
    final d = _draft.value;
    widget.onLiveChange?.call((
      hotspot: d.hotspot,
      crop: d.crop,
      scale: d.scale,
      offset: d.offset,
    ));
  });

  // Track which element is being dragged
  String? _dragTarget;

  // Track the image's actual aspect ratio once loaded
  late final _imageAspectRatio = createSignal<double?>(null);

  @override
  void initState() {
    super.initState();
    _liveEffect; // registers the effect; auto-disposed by SignalsMixin
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

    return ShadCard(
      key: const ValueKey('hotspot_editor'),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row: title + mode toggle
          Row(
            children: [
              Expanded(child: Text('Edit Framing', style: theme.textTheme.h4)),
              FramingModeToggle(
                mode: draft.mode,
                onChanged: (mode) {
                  _draft.value = draft.copyWith(mode: mode);
                  widget.onModeChanged?.call(mode);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Image canvas
          if (loadFailed)
            _ErrorState(
              onRetry: () => _loadFailed.value = false,
              onClose: () => Navigator.of(context).pop(),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: AspectRatio(
                    aspectRatio: aspectRatio ?? 16 / 9,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return MouseRegion(
                          cursor: draft.mode == FramingMode.preview
                              ? SystemMouseCursors.basic
                              : draft.mode == FramingMode.transform
                              ? SystemMouseCursors.move
                              : SystemMouseCursors.grab,
                          child: Listener(
                            onPointerSignal: draft.mode == FramingMode.transform
                                ? (event) {
                                    if (event is PointerScrollEvent) {
                                      final cur = _draft.value.scale ?? 1.0;
                                      final next =
                                          (cur *
                                                  (1.0 -
                                                      event.scrollDelta.dy *
                                                          0.001))
                                              .clamp(0.1, 10.0);
                                      _draft.value = _draft.value.copyWith(
                                        scale: next.toDouble(),
                                      );
                                    }
                                  }
                                : null,
                            child: GestureDetector(
                              onPanStart: draft.mode == FramingMode.preview
                                  ? null
                                  : (details) => _onPanStart(
                                      details,
                                      constraints.biggest,
                                    ),
                              onPanUpdate: draft.mode == FramingMode.preview
                                  ? null
                                  : (details) => _onPanUpdate(
                                      details,
                                      constraints.biggest,
                                    ),
                              onPanEnd: (_) => _dragTarget = null,
                              child: Stack(
                                children: [
                                  if (draft.mode == FramingMode.transform)
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _CheckerboardPainter(),
                                      ),
                                    ),
                                  Positioned.fill(
                                    child: draft.mode == FramingMode.transform
                                        ? Transform.translate(
                                            offset: Offset(
                                              (draft.offset?.dx ?? 0) *
                                                  constraints.biggest.width,
                                              (draft.offset?.dy ?? 0) *
                                                  constraints.biggest.height,
                                            ),
                                            child: Transform.scale(
                                              scale: draft.scale ?? 1.0,
                                              child: Image.network(
                                                widget.imageUrl,
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                            (_) {
                                                              if (mounted) {
                                                                _loadFailed
                                                                        .value =
                                                                    true;
                                                              }
                                                            },
                                                          );
                                                      return const SizedBox.shrink();
                                                    },
                                              ),
                                            ),
                                          )
                                        : Image.network(
                                            widget.imageUrl,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback((
                                                        _,
                                                      ) {
                                                        if (mounted) {
                                                          _loadFailed.value =
                                                              true;
                                                        }
                                                      });
                                                  return const SizedBox.shrink();
                                                },
                                          ),
                                  ),
                                  if (draft.mode != FramingMode.focus &&
                                      draft.mode != FramingMode.transform)
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: CropOverlayPainter(
                                          crop: draft.crop,
                                          imageSize: constraints.biggest,
                                        ),
                                      ),
                                    ),
                                  if (draft.mode != FramingMode.crop &&
                                      draft.mode != FramingMode.transform)
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: HotspotPainter(
                                          hotspot: draft.hotspot,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Preview strip
          AspectRatioPreviewStrip(
            imageUrl: widget.imageUrl,
            hotspot: draft.hotspot,
            crop: draft.crop,
            readOnly: draft.mode == FramingMode.preview,
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Actions
          Wrap(
            spacing: 4,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              // Reset actions — ghost for low visual weight
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShadButton.ghost(
                    key: const ValueKey('reset_focus_button'),
                    onPressed: () => _draft.value = draft.resetFocus(),
                    size: ShadButtonSize.sm,
                    child: const Text('Reset focus'),
                  ),
                  ShadButton.ghost(
                    key: const ValueKey('reset_crop_button'),
                    onPressed: () => _draft.value = draft.resetCrop(),
                    size: ShadButtonSize.sm,
                    child: const Text('Reset crop'),
                  ),
                  ShadButton.ghost(
                    key: const ValueKey('reset_transform_button'),
                    onPressed: () => _draft.value = draft.resetTransform(),
                    size: ShadButtonSize.sm,
                    child: const Text('Reset transform'),
                  ),
                  ShadButton.ghost(
                    key: const ValueKey('reset_all_button'),
                    onPressed: () => _draft.value = draft.resetAll(),
                    size: ShadButtonSize.sm,
                    child: const Text('Reset all'),
                  ),
                ],
              ),
              // Primary actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShadButton.outline(
                    key: const ValueKey('cancel_button'),
                    onPressed: () {
                      widget.onCancel?.call();
                      Navigator.of(context).pop();
                    },
                    size: ShadButtonSize.sm,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ShadButton(
                    key: const ValueKey('apply_button'),
                    onPressed: _apply,
                    size: ShadButtonSize.sm,
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details, Size size) {
    final pos = details.localPosition;
    final draft = _draft.value;
    final h = draft.hotspot;
    final c = draft.crop;

    if (draft.mode == FramingMode.transform) {
      _dragTarget = 'transform';
      return;
    }

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
      case 'transform':
        final cur = draft.offset ?? Offset.zero;
        final next = Offset(
          cur.dx + details.delta.dx / size.width,
          cur.dy + details.delta.dy / size.height,
        );
        _draft.value = draft.copyWith(
          offset: Offset(next.dx.clamp(-2.0, 2.0), next.dy.clamp(-2.0, 2.0)),
        );
        break;
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
    widget.onChanged((
      hotspot: draft.hotspot,
      crop: draft.crop,
      scale: draft.scale,
      offset: draft.offset,
    ));
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tile = 8.0;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF2F2F2),
    );
    final dark = Paint()..color = const Color(0xFFE2E2E2);
    for (double y = 0; y < size.height; y += tile) {
      for (double x = ((y ~/ tile) % 2) * tile; x < size.width; x += tile * 2) {
        canvas.drawRect(Rect.fromLTWH(x, y, tile, tile), dark);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const _ErrorState({required this.onRetry, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.imageOff,
            size: 32,
            color: theme.colorScheme.mutedForeground,
          ),
          const SizedBox(height: 8),
          Text(
            'Could not load image',
            style: theme.textTheme.p.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShadButton.outline(
                key: const ValueKey('retry_image_button'),
                onPressed: onRetry,
                size: ShadButtonSize.sm,
                child: const Text('Retry'),
              ),
              const SizedBox(width: 8),
              ShadButton.ghost(
                key: const ValueKey('close_error_button'),
                onPressed: onClose,
                size: ShadButtonSize.sm,
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
