import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Wraps any input widget with an optional enable/disable checkbox.
/// When [isOptional] is false the wrapper is transparent — it just renders [child].
/// When [isOptional] is true it adds a [ShadCheckbox] at the trailing edge of the
/// input row and dims / blocks the input when unchecked.
class OptionalFieldWrapper extends StatelessWidget {
  final bool isOptional;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final Widget child;

  const OptionalFieldWrapper({
    super.key,
    required this.isOptional,
    required this.isEnabled,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOptional) return child;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: IgnorePointer(
            ignoring: !isEnabled,
            child: AnimatedOpacity(
              opacity: isEnabled ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: child,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ShadCheckbox(
          value: isEnabled,
          onChanged: onToggle,
        ),
      ],
    );
  }
}
