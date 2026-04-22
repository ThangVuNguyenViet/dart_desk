import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

import '../widgets/aura/aura_button.dart';
import '../widgets/aura/aura_tab_bar.dart';
import '../widgets/aura/aura_theme.dart';
import '../widgets/aura/aura_tokens.dart';
import '../widgets/aura/aura_wordmark.dart';
import '../widgets/aura/mobile_frame.dart';
import '../widgets/aura/photo.dart';

class HomeScreen extends StatelessWidget {
  final HomeConfig config;
  final BrandTheme theme;

  const HomeScreen({super.key, required this.config, required this.theme});

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
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- HERO ---
              SizedBox(
                height: 540,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Photo(
                      reference: config.heroImage,
                      height: 540,
                      radius: 0,
                    ),
                    // Gradient scrim
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.18, 0.55, 1.0],
                          colors: [
                            Color(0x591E1B14),
                            Colors.transparent,
                            Colors.transparent,
                            Color(0xBF1E1B14),
                          ],
                        ),
                      ),
                    ),
                    // Top chrome
                    Positioned(
                      top: 58,
                      left: 24,
                      right: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AuraWordmark(color: cream, size: 15, showSub: false),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cream.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: cream.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 11,
                                  color: cream,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  config.locationLabel,
                                  style: TextStyle(
                                    color: cream,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Hero copy
                    Positioned(
                      bottom: 28,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.heroEyebrow,
                            style: TextStyle(
                              color: cream,
                              fontSize: 10.5,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            config.heroHeadline,
                            style: TextStyle(
                              fontFamily: serifFont,
                              color: cream,
                              fontSize: 44,
                              height: 1.02,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              AuraButton(
                                label: config.primaryCta.label,
                                style: AuraButtonStyle.dark,
                                showArrow: false,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: cream.withValues(alpha: 0.45),
                                  ),
                                ),
                                child: Text(
                                  config.secondaryCta.label,
                                  style: TextStyle(
                                    color: cream,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
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

              // --- BELOW FOLD ---
              Container(
                color: cream,
                padding: const EdgeInsets.only(bottom: 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome strip
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: tokens.creamWarm,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'J',
                              style: TextStyle(
                                fontFamily: serifFont,
                                fontStyle: FontStyle.italic,
                                color: scheme.primary,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config.welcomeGreeting,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: tokens.mute,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '412 points — one tier to Oakwood',
                                  style: TextStyle(
                                    fontFamily: serifFont,
                                    fontSize: 17,
                                    fontStyle: FontStyle.italic,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: scheme.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),

                    // Featured section header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'THIS WEEK',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  letterSpacing: 2.5,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                config.featuredSectionTitle,
                                style: TextStyle(
                                  fontFamily: serifFont,
                                  fontSize: 24,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                          ),
                          Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Featured carousel
                    SizedBox(
                      height: 320,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                        itemCount: config.featuredDishes.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, i) {
                          final dish = config.featuredDishes[i];
                          return SizedBox(
                            width: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Photo(
                                      reference: dish.image,
                                      width: 200,
                                      height: 240,
                                      radius: 20,
                                    ),
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cream.withValues(alpha: 0.92),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          dish.tag.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.w700,
                                            color: scheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dish.name,
                                        style: TextStyle(
                                          fontFamily: serifFont,
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: -0.1,
                                          height: 1.15,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '\$${dish.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontFamily: serifFont,
                                          fontSize: 13,
                                          color: scheme.secondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Store card
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 26, 20, 0),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: tokens.greenDark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: cream.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'A',
                              style: TextStyle(
                                fontFamily: serifFont,
                                fontStyle: FontStyle.italic,
                                fontSize: 24,
                                color: cream,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config.storeCallout.venueName,
                                  style: TextStyle(
                                    fontFamily: serifFont,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: cream,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${config.storeCallout.hoursLabel} · ${config.storeCallout.distanceLabel}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: cream.withValues(alpha: 0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: cream.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              config.storeCallout.directionsLabel,
                              style: TextStyle(
                                color: cream,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // TabBar
        const AuraTabBar(active: 'home'),
      ],
    );
  }
}
