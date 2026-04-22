import 'package:flutter/material.dart';

class AuraWordmark extends StatelessWidget {
  final Color color;
  final double size;
  final bool showSub;

  const AuraWordmark({
    super.key,
    required this.color,
    this.size = 18,
    this.showSub = true,
  });

  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.titleLarge?.fontFamily;
    final body = Theme.of(context).textTheme.bodyMedium?.fontFamily;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Aura',
          style: TextStyle(
            fontFamily: headline, color: color, fontSize: size,
            fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, letterSpacing: 0.4, height: 1,
          ),
        ),
        if (showSub) ...[
          const SizedBox(height: 3),
          Text('GASTRONOMY',
            style: TextStyle(
              fontFamily: body, color: color.withValues(alpha: 0.7), fontSize: size * 0.42,
              fontWeight: FontWeight.w600, letterSpacing: 2, height: 1,
            ),
          ),
        ],
      ],
    );
  }
}
