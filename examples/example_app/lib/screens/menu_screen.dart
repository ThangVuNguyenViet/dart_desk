import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

import '../widgets/aura/aura_tab_bar.dart';
import '../widgets/aura/aura_theme.dart';
import '../widgets/aura/aura_tokens.dart';
import '../widgets/aura/mobile_frame.dart';
import '../widgets/aura/photo.dart';

class MenuScreen extends StatelessWidget {
  final MenuConfig config;
  final BrandTheme theme;

  const MenuScreen({super.key, required this.config, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AuraTheme.wrap(
      theme,
      child: Builder(builder: (context) => MobileFrame(child: _body(context))),
    );
  }

  Widget _body(BuildContext context) {
    final tokens = AuraTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final serifFont = theme.headlineFont;
    final cream = theme.surfaceColor;

    // Active category = first one
    final activeCategory =
        config.categories.isNotEmpty ? config.categories.first : '';

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(top: 56, bottom: 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SPRING MENU · N°4',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'The menu',
                            style: TextStyle(
                              fontFamily: serifFont,
                              fontSize: 30,
                              fontStyle: FontStyle.italic,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: tokens.line),
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.search,
                        size: 16,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // Category tabs
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  itemCount: config.categories.length,
                  itemBuilder: (context, i) {
                    final cat = config.categories[i];
                    final isActive = cat == activeCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            cat,
                            style: TextStyle(
                              fontFamily: serifFont,
                              fontSize: 15.5,
                              fontStyle: FontStyle.italic,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color:
                                  isActive ? scheme.onSurface : tokens.mute,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            width: 40,
                            color: isActive
                                ? scheme.primary
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(color: tokens.line.withValues(alpha: 0.5), height: 1),

              // Filter chips
              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
                  itemCount: config.filterTags.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      // "Filters" chip
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: tokens.line),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_list,
                                size: 12,
                                color: scheme.onSurface,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Filters',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final tag = config.filterTags[i - 1];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: tokens.line),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Item count label
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
                child: Text(
                  '${config.items.length} dishes · $activeCategory',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: tokens.mute,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Menu items list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    for (final item in config.items)
                      _MenuRow(
                        item: item,
                        serifFont: serifFont,
                        tokens: tokens,
                        scheme: scheme,
                        cream: cream,
                      ),
                  ],
                ),
              ),

              // Footer card
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: tokens.greenDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visit us in Tribeca',
                      style: TextStyle(
                        fontFamily: serifFont,
                        fontSize: 17,
                        fontStyle: FontStyle.italic,
                        color: cream,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (config.location != null)
                      Text(
                        _formatCoords(config.location!),
                        style: TextStyle(
                          fontSize: 12,
                          color: cream.withValues(alpha: 0.7),
                        ),
                      ),
                    if (config.storeHours.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      for (final h in config.storeHours.take(2))
                        Text(
                          '${h.day}  ${h.openTime} – ${h.closeTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: cream.withValues(alpha: 0.75),
                          ),
                        ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: cream.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Directions',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cream,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // TabBar
        const AuraTabBar(active: 'menu'),
      ],
    );
  }

  String _formatCoords(Map<String, double> loc) {
    final lat = loc['lat'] ?? 0.0;
    final lng = loc['lng'] ?? 0.0;
    final latStr =
        '${lat.abs().toStringAsFixed(2)}°${lat >= 0 ? 'N' : 'S'}';
    final lngStr =
        '${lng.abs().toStringAsFixed(2)}°${lng >= 0 ? 'E' : 'W'}';
    return '$latStr, $lngStr';
  }
}

class _MenuRow extends StatelessWidget {
  final MenuItemEntry item;
  final String serifFont;
  final AuraTokens tokens;
  final ColorScheme scheme;
  final Color cream;

  const _MenuRow({
    required this.item,
    required this.serifFont,
    required this.tokens,
    required this.scheme,
    required this.cream,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: item.isAvailable ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: tokens.line.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Photo(
              reference: item.image,
              width: 76,
              height: 76,
              radius: 14,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontFamily: serifFont,
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -0.2,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: tokens.inkSoft,
                      height: 1.4,
                    ),
                  ),
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final tag in item.tags.take(2))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.5,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        if (!item.isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: tokens.mute.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SOLD OUT',
                              style: TextStyle(
                                fontSize: 9.5,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                                color: tokens.mute,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${item.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: serifFont,
                    fontSize: 17,
                    color: scheme.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: item.isAvailable ? scheme.primary : tokens.mute,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
