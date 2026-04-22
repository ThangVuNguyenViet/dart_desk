import 'package:flutter/material.dart';

/// 390×844 iOS-style phone frame — rounded corners, dynamic island,
/// status bar (9:41), home indicator. Matches the design artboard.
class MobileFrame extends StatelessWidget {
  final Widget child;
  final Color? background;
  final bool darkChrome;

  const MobileFrame({
    super.key,
    required this.child,
    this.background,
    this.darkChrome = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = background ?? scheme.surface;
    final chromeColor = darkChrome ? Colors.white : scheme.onSurface;

    return Container(
      width: 390,
      height: 844,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(48),
        boxShadow: const [
          BoxShadow(color: Color(0x2E000000), offset: Offset(0, 40), blurRadius: 80),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Positioned.fill(child: child),
        // Dynamic island
        Positioned(
          top: 11, left: 0, right: 0,
          child: Center(
            child: Container(
              width: 126, height: 37,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ),
        // Status bar
        Positioned(
          top: 21, left: 34, right: 34,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('9:41', style: TextStyle(color: chromeColor, fontSize: 17, fontWeight: FontWeight.w600)),
            Row(children: [
              Icon(Icons.signal_cellular_alt, size: 14, color: chromeColor),
              const SizedBox(width: 6),
              Icon(Icons.wifi, size: 14, color: chromeColor),
              const SizedBox(width: 6),
              Icon(Icons.battery_full, size: 14, color: chromeColor),
            ]),
          ]),
        ),
        // Home indicator
        Positioned(
          bottom: 8, left: 0, right: 0,
          child: Center(
            child: Container(
              width: 139, height: 5,
              decoration: BoxDecoration(
                color: (darkChrome ? Colors.white : Colors.black).withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
