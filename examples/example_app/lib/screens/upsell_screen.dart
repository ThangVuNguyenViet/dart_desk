import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

const _primary = Color(0xFF496455);
const _surface = Color(0xFFFAF9F7);
const _onSurface = Color(0xFF2F3331);
const _onSurfaceVariant = Color(0xFF5C605D);
const _warmCardBg = Color(0xFFF9F3EA);
const _surfaceContainer = Color(0xFFEDEEEB);

class UpsellScreen extends StatelessWidget {
  const UpsellScreen({super.key, required this.config});

  final UpsellConfig config;

  @override
  Widget build(BuildContext context) {
    final products = config.products
        .map((key) => lookupProduct(key, upsellProducts))
        .whereType<SeedProduct>()
        .toList();

    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 80, bottom: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Editorial header
                  _EditorialHeader(config: config),
                  const SizedBox(height: 40),
                  // Product list with pull quote inserted between items 2 and 3
                  _ProductList(products: products, config: config),
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
            radius: 16,
            backgroundImage: NetworkImage(profileAvatarUrl),
          ),
        ],
      ),
    );
  }
}

// ─── Editorial Header ─────────────────────────────────────────────────────────

class _EditorialHeader extends StatelessWidget {
  const _EditorialHeader({required this.config});

  final UpsellConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'MONTHLY CURATION',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 3.2,
            fontWeight: FontWeight.bold,
            color: _onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          config.sectionTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 36,
            fontWeight: FontWeight.w400,
            color: _primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(width: 48, height: 1, color: _primary.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text(
          config.sectionSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: _onSurfaceVariant, height: 1.6),
        ),
      ],
    );
  }
}

// ─── Product List ─────────────────────────────────────────────────────────────

class _ProductList extends StatelessWidget {
  const _ProductList({required this.products, required this.config});

  final List<SeedProduct> products;
  final UpsellConfig config;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    for (var i = 0; i < products.length; i++) {
      // Insert pull quote between items 2 and 3 (after index 1)
      if (i == 2) {
        items.add(_PullQuoteCard(config: config));
        items.add(const SizedBox(height: 24));
      }

      final isWarmBg = i == 0 || i == 3;
      items.add(_ProductCard(product: products[i], isWarmBg: isWarmBg));

      if (i < products.length - 1) {
        items.add(const SizedBox(height: 24));
      }
    }

    return Column(children: items);
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.isWarmBg});

  final SeedProduct product;
  final bool isWarmBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarmBg ? _warmCardBg : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left 1/3: product image
          Expanded(
            flex: 1,
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(product.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right 2/3: content
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge + calories row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ChefBadge(),
                      Text(
                        '${product.calories} kcal',
                        style: TextStyle(
                          fontSize: 10,
                          color: _onSurfaceVariant.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Product name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 18,
                      color: _onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: _onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price + cart button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 17,
                          color: _primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 16,
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

// ─── Chef Badge ───────────────────────────────────────────────────────────────

class _ChefBadge extends StatelessWidget {
  const _ChefBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF496455), Color(0xFF3E5849)],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "CHEF'S CHOICE",
        style: TextStyle(
          fontSize: 8,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ─── Pull Quote Card ──────────────────────────────────────────────────────────

class _PullQuoteCard extends StatelessWidget {
  const _PullQuoteCard({required this.config});

  final UpsellConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      decoration: BoxDecoration(
        color: _surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '"${config.quoteText}"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontStyle: FontStyle.italic,
              fontSize: 17,
              color: _primary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 32,
            height: 1,
            color: _onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            '— ${config.chefName}',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
              color: _onSurfaceVariant,
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
          _NavItem(icon: Icons.home, label: 'Home', isActive: false),
          _NavItem(icon: Icons.restaurant_menu, label: 'Menu', isActive: true),
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
