import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

/// Preview of the food ordering app storefront — dark, moody, editorial.
/// Designed to feel like a high-end restaurant's own app, not a generic template.
class StorefrontPreview extends StatelessWidget {
  final StorefrontConfig config;
  const StorefrontPreview({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        children: [
          // Full-bleed hero image or dark texture
          Positioned.fill(
            child: _HeroBackground(config: config),
          ),
          // Content overlay
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                // Top bar
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        children: [
                          _LogoBadge(config: config),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: config.accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Open Now',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main title block — pushed low, big and dramatic
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thin accent line
                        Container(
                          width: 32,
                          height: 2,
                          color: config.accentColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          config.restaurantName,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.05,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          config.tagline,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Welcome message — understated
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        config.welcomeMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.65,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),

                // Hours strip
                if (config.showHours)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: config.accentColor.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            config.operatingHours,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // CTA button — full width, punchy
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: config.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      child: Text(config.ctaLabel),
                    ),
                  ),
                ),

                // Secondary link
                if (config.orderUrl != null)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'View full menu →',
                          style: TextStyle(
                            fontSize: 13,
                            color: config.accentColor.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Bottom breathing room
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  final StorefrontConfig config;
  const _HeroBackground({required this.config});

  @override
  Widget build(BuildContext context) {
    final hasImage = config.heroImage != null;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasImage)
          Image.network(
            config.heroImage!.url!,
            fit: BoxFit.cover,
          )
        else
          // Dark textured fallback — no gradient, just atmosphere
          Container(color: const Color(0xFF111111)),
        // Heavy scrim — content lives on top
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.3, 0.7, 1.0],
              colors: [
                const Color(0xFF111111).withValues(alpha: hasImage ? 0.4 : 1.0),
                const Color(0xFF111111).withValues(alpha: hasImage ? 0.55 : 1.0),
                const Color(0xFF111111).withValues(alpha: hasImage ? 0.85 : 1.0),
                const Color(0xFF111111),
              ],
            ),
          ),
        ),
        // Subtle noise texture via stacked semi-transparent shapes
        if (hasImage)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(color: const Color(0xFF111111)),
          ),
      ],
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final StorefrontConfig config;
  const _LogoBadge({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
        image: config.logo != null
            ? DecorationImage(
                image: NetworkImage(config.logo!.url!),
                fit: BoxFit.cover,
              )
            : null,
        color: config.logo == null
            ? Colors.white.withValues(alpha: 0.06)
            : null,
      ),
      child: config.logo == null
          ? Icon(Icons.restaurant, color: config.accentColor, size: 18)
          : null,
    );
  }
}
