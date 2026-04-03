import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

const _primary = Color(0xFF496455);
const _surface = Color(0xFFFAF9F7);
const _onSurface = Color(0xFF2F3331);
const _onSurfaceVariant = Color(0xFF5C605D);
const _surfaceContainer = Color(0xFFEDEEEB);
const _primaryContainer = Color(0xFFCCEAD6);
const _onPrimaryContainer = Color(0xFF3D5749);

class HeroScreen extends StatelessWidget {
  const HeroScreen({super.key, required this.config});

  final HeroConfig config;

  @override
  Widget build(BuildContext context) {
    final products = config.products
        .map((key) => lookupProduct(key, heroProducts))
        .whereType<SeedProduct>()
        .toList();

    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            slivers: [
              // Top app bar space
              SliverToBoxAdapter(child: SizedBox(height: 64)),
              // Hero section
              SliverToBoxAdapter(child: _HeroSection(config: config)),
              // Category pills
              SliverToBoxAdapter(child: _CategorySection()),
              // Featured Today
              SliverToBoxAdapter(child: _FeaturedSection(products: products)),
              // Pull quote
              SliverToBoxAdapter(child: _PullQuoteSection()),
              // Bottom nav space
              SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          // Fixed top app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopAppBar(profileAvatarUrl: profileAvatarUrl),
          ),
          // Fixed bottom nav bar
          Positioned(bottom: 0, left: 0, right: 0, child: _BottomNavBar()),
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
      color: _surface.withValues(alpha: 0.9),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(Icons.menu, color: _primary, size: 24),
          const SizedBox(width: 12),
          Text(
            'Aura Gastronomy',
            style: TextStyle(
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
            radius: 20,
            backgroundImage: NetworkImage(profileAvatarUrl),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.config});

  final HeroConfig config;

  @override
  Widget build(BuildContext context) {
    final imageUrl = config.heroImage?.url ?? heroBackgroundImageUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(imageUrl, fit: BoxFit.cover),
            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6],
                ),
              ),
            ),
            // Bottom content overlay
            Positioned(
              bottom: 40,
              left: 32,
              right: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.heroSubtitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    config.heroTitle,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _CtaButton(label: config.ctaLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}

// ─── Category Section ─────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CATEGORIES',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                    color: _onSurfaceVariant,
                  ),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 96,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _CategoryItem(
                  icon: Icons.restaurant_menu,
                  label: 'Starters',
                  isActive: false,
                ),
                const SizedBox(width: 16),
                _CategoryItem(
                  icon: Icons.dinner_dining,
                  label: 'Mains',
                  isActive: true,
                ),
                const SizedBox(width: 16),
                _CategoryItem(
                  icon: Icons.cake,
                  label: 'Festive Treats',
                  isActive: false,
                ),
                const SizedBox(width: 16),
                _CategoryItem(
                  icon: Icons.local_bar,
                  label: 'Drinks',
                  isActive: false,
                ),
                const SizedBox(width: 16),
                _CategoryItem(
                  icon: Icons.bakery_dining,
                  label: 'Bakery',
                  isActive: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isActive ? _primaryContainer : _surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? _onPrimaryContainer : _primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? _primary : _onSurface,
          ),
        ),
      ],
    );
  }
}

// ─── Featured Section ─────────────────────────────────────────────────────────

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection({required this.products});

  final List<SeedProduct> products;

  @override
  Widget build(BuildContext context) {
    // Build pairs for 2-column staggered grid
    final left = <SeedProduct>[];
    final right = <SeedProduct>[];
    for (var i = 0; i < products.length; i++) {
      if (i.isEven) {
        left.add(products[i]);
      } else {
        right.add(products[i]);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with accent bar
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(width: 3, height: 56, color: _primary),
              const SizedBox(width: 16),
              const Text(
                'Featured Today',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: _onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Staggered 2-column grid
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    children: [
                      for (final product in left) ...[
                        _ProductCard(product: product),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right column — offset by 24px top padding
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      for (final product in right) ...[
                        _ProductCard(product: product),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final SeedProduct product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with FAB overlay
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(product.imageUrl, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, size: 16, color: _onSurface),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          product.name,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: _onSurface,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 11,
            color: _onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─── Pull Quote Section ───────────────────────────────────────────────────────

class _PullQuoteSection extends StatelessWidget {
  const _PullQuoteSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Column(
        children: [
          Text(
            '"Where culinary artistry meets the warmth of home"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontStyle: FontStyle.italic,
              fontSize: 22,
              color: _primary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'THE AURA MANIFESTO',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 3.0,
              color: _onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home, label: 'Home', isActive: true),
          _NavItem(icon: Icons.restaurant_menu, label: 'Menu', isActive: false),
          _NavItem(icon: Icons.shopping_cart, label: 'Cart', isActive: false),
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
