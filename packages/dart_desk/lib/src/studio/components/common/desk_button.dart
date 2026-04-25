import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Reusable button wrapping ShadButton with loading state support.
class DeskButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final ShadButtonVariant variant;
  final ShadButtonSize size;

  const DeskButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.variant = ShadButtonVariant.primary,
    this.size = ShadButtonSize.sm,
  });

  @override
  Widget build(BuildContext context) {
    return ShadButton.raw(
      variant: variant,
      size: size,
      onPressed: loading ? null : onPressed,
      leading: loading
          ? SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ShadTheme.of(context).colorScheme.primaryForeground,
              ),
            )
          : null,
      child: Text(text),
    );
  }
}
