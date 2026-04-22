import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

import '../widgets/aura/aura_icon_button.dart';
import '../widgets/aura/aura_tab_bar.dart';
import '../widgets/aura/aura_theme.dart';
import '../widgets/aura/aura_tokens.dart';
import '../widgets/aura/mobile_frame.dart';
import '../widgets/aura/photo.dart';

class ChefScreen extends StatelessWidget {
  final ChefConfig config;
  final BrandTheme theme;

  const ChefScreen({super.key, required this.config, required this.theme});

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

    return Stack(
      children: [
        // Scrollable content
        SingleChildScrollView(
          padding: const EdgeInsets.only(top: 102, bottom: 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title block
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.headline,
                      style: TextStyle(
                        fontFamily: serifFont,
                        fontSize: 40,
                        height: 1.02,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      config.chef.bio,
                      style: TextStyle(
                        fontFamily: serifFont,
                        fontSize: 13.5,
                        color: tokens.inkSoft,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),

              // Pull-quote card
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 26),
                decoration: BoxDecoration(
                  color: tokens.greenDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Decorative quote glyph
                    Positioned(
                      top: 8,
                      left: 22,
                      child: Text(
                        '“',
                        style: TextStyle(
                          fontFamily: serifFont,
                          fontSize: 120,
                          fontStyle: FontStyle.italic,
                          color: cream.withValues(alpha: 0.12),
                          height: 1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.pullQuote,
                            style: TextStyle(
                              fontFamily: serifFont,
                              fontSize: 22,
                              height: 1.28,
                              fontStyle: FontStyle.italic,
                              color: cream,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            color: cream.withValues(alpha: 0.15),
                            height: 1,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: Photo(
                                  reference: config.chef.portrait,
                                  width: 52,
                                  height: 52,
                                  radius: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      config.chef.name,
                                      style: TextStyle(
                                        fontFamily: serifFont,
                                        fontSize: 15,
                                        fontStyle: FontStyle.italic,
                                        color: cream,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      config.chef.role.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: cream.withValues(alpha: 0.7),
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cream.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 14,
                                  color: cream,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Curated dish list
              for (int i = 0; i < config.curatedDishes.length; i++) ...[
                _DishRow(
                  dish: config.curatedDishes[i],
                  serifFont: serifFont,
                  tokens: tokens,
                  scheme: scheme,
                  cream: cream,
                  isLast: i == config.curatedDishes.length - 1,
                ),
              ],

              // Outro
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 34, 24, 0),
                child: Text(
                  '— ${config.refreshCadence} —',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: serifFont,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: tokens.inkSoft,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Sticky header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.6, 1.0],
                colors: [
                  cream.withValues(alpha: 0.98),
                  cream.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AuraIconButton(icon: Icons.arrow_back_ios_new),
                Text(
                  "CHEF'S CHOICE",
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2,
                    textBaseline: TextBaseline.alphabetic,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                AuraIconButton(icon: Icons.bookmark_outline),
              ],
            ),
          ),
        ),

        // TabBar
        const AuraTabBar(active: 'menu'),
      ],
    );
  }
}

class _DishRow extends StatelessWidget {
  final CuratedDish dish;
  final String serifFont;
  final AuraTokens tokens;
  final ColorScheme scheme;
  final Color cream;
  final bool isLast;

  const _DishRow({
    required this.dish,
    required this.serifFont,
    required this.tokens,
    required this.scheme,
    required this.cream,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final descText = _extractPlainText(dish.description);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        isLast ? 0 : 26,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with number badge
          Stack(
            children: [
              Photo(
                reference: dish.image,
                width: 118,
                height: 150,
                radius: 14,
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cream.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    dish.numberLabel,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          dish.name,
                          style: TextStyle(
                            fontFamily: serifFont,
                            fontSize: 19,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -0.2,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${dish.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: serifFont,
                          fontSize: 16,
                          color: scheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  if (descText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      descText,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: tokens.inkSoft,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+ Add to order',
                          style: TextStyle(
                            color: scheme.surface,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Text(
                        'single serving',
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.mute,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Flatten block content (Portable Text / rich text JSON) to a plain string.
/// Returns null if block is null or empty.
String? _extractPlainText(Object? block) {
  if (block == null) return null;
  try {
    if (block is List) {
      final buffer = StringBuffer();
      for (final node in block) {
        if (node is Map) {
          final children = node['children'];
          if (children is List) {
            for (final child in children) {
              if (child is Map) {
                final text = child['text'];
                if (text is String && text.isNotEmpty) {
                  buffer.write(text);
                }
              }
            }
          }
          buffer.write(' ');
        }
      }
      final result = buffer.toString().trim();
      return result.isEmpty ? null : result;
    }
  } catch (_) {}
  return null;
}
