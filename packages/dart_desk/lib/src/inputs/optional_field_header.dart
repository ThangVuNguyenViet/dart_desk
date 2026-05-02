import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Standard field title row used by every input that participates in the
/// optional-field toggle. Renders [title] on the left and, when [isOptional]
/// is true, a trailing [ShadCheckbox] whose value reflects [isEnabled].
///
/// The checkbox does not own its state. The host input controls [isEnabled]
/// (typically derived from `value != null`) and listens via [onToggle].
class OptionalFieldHeader extends StatelessWidget {
  final String title;
  final bool isOptional;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const OptionalFieldHeader({
    super.key,
    required this.title,
    required this.isOptional,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      children: [
        Text(title, style: theme.textTheme.small),
        if (isOptional) ...[
          const Spacer(),
          ShadCheckbox(
            value: isEnabled,
            onChanged: onToggle,
          ),
        ],
      ],
    );
  }
}
