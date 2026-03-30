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
    return Wrap(
      spacing: 8,
      children: [
        _ModeButton(
          key: const ValueKey('framing_mode_crop'),
          label: 'Crop',
          selected: mode == FramingMode.crop,
          onPressed: () => onChanged(FramingMode.crop),
        ),
        _ModeButton(
          key: const ValueKey('framing_mode_focus'),
          label: 'Focus',
          selected: mode == FramingMode.focus,
          onPressed: () => onChanged(FramingMode.focus),
        ),
        _ModeButton(
          key: const ValueKey('framing_mode_preview'),
          label: 'Preview',
          selected: mode == FramingMode.preview,
          onPressed: () => onChanged(FramingMode.preview),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _ModeButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return ShadButton(onPressed: null, child: Text(label));
    }

    return ShadButton.outline(onPressed: onPressed, child: Text(label));
  }
}
