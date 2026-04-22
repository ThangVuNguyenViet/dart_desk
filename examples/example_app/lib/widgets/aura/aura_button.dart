import 'package:flutter/material.dart';

enum AuraButtonStyle { solid, dark, ghost }

class AuraButton extends StatelessWidget {
  final String label;
  final AuraButtonStyle style;
  final VoidCallback? onPressed;
  final bool showArrow;

  const AuraButton({
    super.key,
    required this.label,
    this.style = AuraButtonStyle.solid,
    this.onPressed,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, border) = switch (style) {
      AuraButtonStyle.solid => (scheme.primary, scheme.surface, null),
      AuraButtonStyle.dark  => (scheme.surface, scheme.onSurface, null),
      AuraButtonStyle.ghost => (Colors.transparent, scheme.surface, Border.all(color: scheme.surface.withValues(alpha: 0.45))),
    };
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: border?.top ?? BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: TextStyle(color: fg, fontSize: 14.5, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
            if (showArrow) ...[
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward, size: 14, color: fg),
            ],
          ]),
        ),
      ),
    );
  }
}
