import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/aura/aura_tab_bar.dart';
import '../widgets/aura/aura_theme.dart';
import '../widgets/aura/aura_tokens.dart';
import '../widgets/aura/aura_wordmark.dart';
import '../widgets/aura/mobile_frame.dart';
import '../widgets/aura/photo.dart';

class RewardsScreen extends StatelessWidget {
  final RewardsConfig config;
  final BrandTheme theme;

  const RewardsScreen({super.key, required this.config, required this.theme});

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

    final pts = config.currentUserPoints.toDouble();
    final sortedTiers = List<LoyaltyTier>.from(config.tiers)
      ..sort((a, b) => a.threshold.compareTo(b.threshold));

    // Current tier: highest threshold <= pts
    LoyaltyTier currentTier = sortedTiers.first;
    for (final t in sortedTiers) {
      if (t.threshold.toDouble() <= pts) currentTier = t;
    }

    // Next tier: first threshold > pts
    LoyaltyTier? nextTier;
    for (final t in sortedTiers) {
      if (t.threshold.toDouble() > pts) {
        nextTier = t;
        break;
      }
    }

    final progressPct = nextTier != null
        ? (pts / nextTier.threshold.toDouble()).clamp(0.0, 1.0)
        : 1.0;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(top: 56, bottom: 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AuraWordmark(color: scheme.onSurface, size: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${pts.toInt()} pts',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Loyalty hero card
              Container(
                margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: tokens.greenDark,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2E1E1B14),
                      offset: Offset(0, 12),
                      blurRadius: 32,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Program name + tier
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MEMBER · ${currentTier.name.toUpperCase()} TIER',
                              style: TextStyle(
                                fontSize: 10.5,
                                letterSpacing: 2.5,
                                fontWeight: FontWeight.w700,
                                color: cream.withValues(alpha: 0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Jules Okafor',
                              style: TextStyle(
                                fontFamily: serifFont,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: cream,
                              ),
                            ),
                          ],
                        ),
                        ),
                        AuraWordmark(
                          color: cream,
                          size: 16,
                          showSub: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Points display
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${pts.toInt()}',
                            style: TextStyle(
                              fontFamily: serifFont,
                              fontSize: 68,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -2,
                              height: 1,
                              color: cream,
                            ),
                          ),
                          TextSpan(
                            text: ' pts',
                            style: TextStyle(
                              fontFamily: serifFont,
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: cream.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (nextTier != null)
                      Text(
                        '${(nextTier.threshold.toDouble() - pts).toInt()} points until ${nextTier.name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cream.withValues(alpha: 0.75),
                        ),
                      ),
                    const SizedBox(height: 18),
                    // Progress bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: cream.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progressPct,
                        child: Container(
                          decoration: BoxDecoration(
                            color: scheme.secondary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Tier labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int i = 0; i < sortedTiers.length; i++)
                          Text(
                            sortedTiers[i].name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: cream.withValues(
                                alpha: i == 0
                                    ? 0.9
                                    : i == 1
                                        ? 0.6
                                        : 0.4,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
                child: Row(
                  children: _buildStats(serifFont, tokens),
                ),
              ),

              // Coupons section header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${config.coupons.length} AVAILABLE',
                            style: TextStyle(
                              fontSize: 10.5,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w700,
                              color: scheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your coupons',
                            style: TextStyle(
                              fontFamily: serifFont,
                              fontSize: 22,
                              fontStyle: FontStyle.italic,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'History',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Coupon stack
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    for (int i = 0; i < config.coupons.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      _CouponCard(
                        coupon: config.coupons[i],
                        serifFont: serifFont,
                        tokens: tokens,
                        scheme: scheme,
                        cream: cream,
                      ),
                    ],
                  ],
                ),
              ),

              // Fineprint
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Points expire after 12 months of inactivity. '
                            'Rewards have no cash value. ',
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.mute,
                        ),
                      ),
                      TextSpan(
                        text: 'Terms',
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // TabBar
        const AuraTabBar(active: 'rewards'),
      ],
    );
  }

  List<Widget> _buildStats(String serifFont, AuraTokens tokens) {
    final stats = [
      ['14', 'visits'],
      ['\$624', 'this year'],
      ['3', 'saved dishes'],
    ];
    final widgets = <Widget>[];
    for (int i = 0; i < stats.length; i++) {
      if (i > 0) widgets.add(const SizedBox(width: 10));
      widgets.add(Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.creamWarm,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stats[i][0],
                style: TextStyle(
                  fontFamily: serifFont,
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stats[i][1],
                style: TextStyle(
                  fontSize: 11,
                  color: tokens.inkSoft,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ));
    }
    return widgets;
  }
}

class _CouponCard extends StatelessWidget {
  final Coupon coupon;
  final String serifFont;
  final AuraTokens tokens;
  final ColorScheme scheme;
  final Color cream;

  const _CouponCard({
    required this.coupon,
    required this.serifFont,
    required this.tokens,
    required this.scheme,
    required this.cream,
  });

  @override
  Widget build(BuildContext context) {
    final expiry = DateFormat('MMM d').format(coupon.expiresAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.line.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1E1B14),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 165,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 108,
              child: Photo(
                reference: coupon.image,
                width: 108,
                height: 165,
                radius: 0,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      coupon.title,
                      style: TextStyle(
                        fontFamily: serifFont,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.2,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (coupon.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        coupon.tags.join(' · '),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: tokens.inkSoft,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.creamWarm,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            coupon.code,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Text(
                          '· Expires $expiry',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: tokens.mute,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (coupon.discountPercent < 100)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${coupon.discountPercent.toInt()}% off',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: scheme.secondary,
                              ),
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
      ),
    );
  }
}
