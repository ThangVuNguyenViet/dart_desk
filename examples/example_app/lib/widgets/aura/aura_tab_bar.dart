import 'package:flutter/material.dart';

import 'aura_tokens.dart';

class AuraTabItem {
  final String id;
  final String label;
  final IconData icon;
  const AuraTabItem(this.id, this.label, this.icon);
}

class AuraTabBar extends StatelessWidget {
  final String active;
  const AuraTabBar({super.key, required this.active});

  static const items = [
    AuraTabItem('home',    'Home',    Icons.home_outlined),
    AuraTabItem('menu',    'Menu',    Icons.menu),
    AuraTabItem('rewards', 'Rewards', Icons.star_outline),
    AuraTabItem('account', 'Account', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = AuraTokens.of(context);
    return Positioned(
      left: 12, right: 12, bottom: 28,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(38),
          border: Border.all(color: scheme.onSurface.withValues(alpha: 0.06)),
          boxShadow: const [
            BoxShadow(color: Color(0x1E1B1433), offset: Offset(0, 12), blurRadius: 30),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final it in items)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(it.icon, size: 22,
                    color: it.id == active ? scheme.onSurface : tokens.mute),
                  const SizedBox(height: 4),
                  Text(it.label, style: TextStyle(
                    fontSize: 10,
                    fontWeight: it.id == active ? FontWeight.w700 : FontWeight.w500,
                    color: it.id == active ? scheme.onSurface : tokens.mute,
                    letterSpacing: 0.3,
                  )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
