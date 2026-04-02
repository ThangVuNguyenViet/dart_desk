import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

const _primary = Color(0xFF496455);
const _surface = Color(0xFFFAF9F7);
const _onSurface = Color(0xFF2F3331);
const _onSurfaceVariant = Color(0xFF5C605D);
const _primaryContainer = Color(0xFFD5E5DB);
const _surfaceContainer = Color(0xFFEDEEEB);
const _surfaceContainerHighest = Color(0xFFE0E3E0);
const _outline = Color(0xFF777C79);
const _outlineVariant = Color(0xFFAFB3B0);
const _error = Color(0xFF9F403D);
const _primaryDim = Color(0xFF3E5849);
const _tertiaryFixedDim = Color(0xFFEBE4DB);
const _onTertiaryFixedVariant = Color(0xFF69665F);

class RewardPreview extends StatelessWidget {
  const RewardPreview({super.key, required this.config});

  final RewardConfig config;

  @override
  Widget build(BuildContext context) {
    final coupons = config.coupons
        .map((key) => lookupCoupon(key))
        .whereType<SeedCoupon>()
        .toList();

    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 80, bottom: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Loyalty card
                  _LoyaltyCard(config: config),
                  const SizedBox(height: 48),
                  // Active coupons header
                  _CouponsHeader(count: coupons.length),
                  const SizedBox(height: 24),
                  // Coupons list
                  _CouponList(coupons: coupons),
                  const SizedBox(height: 64),
                  // Editorial pull quote
                  const _EditorialQuote(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Fixed top app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopAppBar(profileAvatarUrl: profileAvatarUrl),
          ),
          // Fixed bottom nav bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const _BottomNavBar(),
          ),
        ],
      ),
    );
  }
}

// ─── Top App Bar ──────────────────────────────────────────────────────────────

class _TopAppBar extends StatelessWidget {
  const _TopAppBar({required this.profileAvatarUrl});

  final String profileAvatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: _surface.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(Icons.menu, color: _primary, size: 24),
          const SizedBox(width: 16),
          Text(
            'Aura Gastronomy',
            style: const TextStyle(
              fontFamily: 'serif',
              fontStyle: FontStyle.italic,
              fontSize: 22,
              color: _primary,
              letterSpacing: -0.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(profileAvatarUrl),
            backgroundColor: _surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}

// ─── Loyalty Card ─────────────────────────────────────────────────────────────

class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({required this.config});

  final RewardConfig config;

  @override
  Widget build(BuildContext context) {
    final remaining = config.nextRewardThreshold - config.pointsBalance;
    final progress = (config.pointsBalance / config.nextRewardThreshold)
        .clamp(0.0, 1.0)
        .toDouble();

    return Container(
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -64,
              right: -64,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -48,
              left: -48,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    'SEASONAL LOYALTY',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Header
                  const Text(
                    'Holiday Rewards',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Points row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Left: points balance
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${config.pointsBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -1.0,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AURA POINTS',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Right: next reward
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'NEXT REWARD',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${config.nextRewardThreshold.toStringAsFixed(0)} pts',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: _primaryDim,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: _primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryContainer.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Remaining text
                  Text(
                    '${remaining.toStringAsFixed(0)} points until your ${config.rewardLabel}',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Coupons Header ───────────────────────────────────────────────────────────

class _CouponsHeader extends StatelessWidget {
  const _CouponsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Active Coupons',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            color: _primary,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _surfaceContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$count Available',
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w500,
              color: _onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Coupon List ──────────────────────────────────────────────────────────────

class _CouponList extends StatelessWidget {
  const _CouponList({required this.coupons});

  final List<SeedCoupon> coupons;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < coupons.length; i++) ...[
          if (i > 0) const SizedBox(height: 24),
          _CouponCard(coupon: coupons[i]),
        ],
      ],
    );
  }
}

// ─── Coupon Card ──────────────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon});

  final SeedCoupon coupon;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: coupon.locked ? const Color(0xFFF3F4F1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: coupon.locked
              ? _outlineVariant.withOpacity(0.2)
              : _outlineVariant.withOpacity(0.3),
          width: 2,
          // Note: Flutter doesn't have native dashed borders, using solid with low alpha
        ),
        boxShadow: coupon.locked
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: content + icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        color: _onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coupon.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Icon container
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: coupon.locked
                      ? _surfaceContainerHighest
                      : _primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  coupon.icon,
                  size: 24,
                  color: coupon.locked ? _outline : const Color(0xFF3D5749),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Divider
          Divider(
            color: coupon.locked
                ? _outlineVariant.withOpacity(0.1)
                : _surfaceContainer,
            height: 1,
          ),
          const SizedBox(height: 16),
          // Bottom row: condition + button
          Row(
            children: [
              // Condition
              Expanded(
                child: coupon.locked
                    ? Text(
                        coupon.condition,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: _outline,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Condition',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: _outline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            coupon.condition,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _onSurface,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 16),
              // Button
              coupon.locked
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: _surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'LOCKED',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                          color: _outline,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'APPLY',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );

    if (coupon.locked) {
      return Opacity(opacity: 0.6, child: card);
    }
    return card;
  }
}

// ─── Editorial Quote ──────────────────────────────────────────────────────────

class _EditorialQuote extends StatelessWidget {
  const _EditorialQuote();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          '"Crafting moments of taste,\nrewarded by your presence."',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'serif',
            fontStyle: FontStyle.italic,
            fontSize: 20,
            color: _primary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Nav Bar ───────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(icon: Icons.home, label: 'Home', isActive: false),
          _NavItem(
              icon: Icons.restaurant_menu, label: 'Menu', isActive: false),
          _NavItem(
              icon: Icons.shopping_cart, label: 'Cart', isActive: true),
          _NavItem(icon: Icons.person, label: 'Profile', isActive: false),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _onSurfaceVariant, size: 24),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
