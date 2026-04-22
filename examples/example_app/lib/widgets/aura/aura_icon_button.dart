import 'package:flutter/material.dart';

import 'aura_tokens.dart';

class AuraIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  const AuraIconButton({super.key, required this.icon, this.onPressed, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final tokens = AuraTokens.of(context);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size / 2),
        side: BorderSide(color: tokens.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onPressed ?? () {},
        child: SizedBox(
          width: size, height: size,
          child: Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}
