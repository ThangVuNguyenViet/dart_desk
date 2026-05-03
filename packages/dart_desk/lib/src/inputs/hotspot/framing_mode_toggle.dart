import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'framing_controller.dart';

class FramingModeToggle extends StatelessWidget {
  final FramingMode mode;
  final ValueChanged<FramingMode> onChanged;

  const FramingModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegmentButton(
            key: const ValueKey('framing_mode_crop'),
            icon: LucideIcons.crop,
            label: 'Crop',
            selected: mode == FramingMode.crop,
            onPressed: () => onChanged(FramingMode.crop),
          ),
          _SegmentButton(
            key: const ValueKey('framing_mode_focus'),
            icon: LucideIcons.crosshair,
            label: 'Focus',
            selected: mode == FramingMode.focus,
            onPressed: () => onChanged(FramingMode.focus),
          ),
          _SegmentButton(
            key: const ValueKey('framing_mode_transform'),
            icon: LucideIcons.move,
            label: 'Transform',
            selected: mode == FramingMode.transform,
            onPressed: () => onChanged(FramingMode.transform),
          ),
          _SegmentButton(
            key: const ValueKey('framing_mode_preview'),
            icon: LucideIcons.eye,
            label: 'Preview',
            selected: mode == FramingMode.preview,
            onPressed: () => onChanged(FramingMode.preview),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _SegmentButton({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: selected ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.background : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected
                  ? theme.colorScheme.foreground
                  : theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.small.copyWith(
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                color: selected
                    ? theme.colorScheme.foreground
                    : theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
