import 'package:flutter/material.dart';

/// 1194×834 landscape iPad-style frame for the Kiosk screen.
class TabletFrame extends StatelessWidget {
  final Widget child;
  const TabletFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 1194, height: 834,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x2E000000), offset: Offset(0, 40), blurRadius: 80),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
