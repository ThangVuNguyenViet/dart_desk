import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

const _primary = Color(0xFF496455);
const _surface = Color(0xFFFAF9F7);
const _onSurface = Color(0xFF2F3331);
const _cardBg = Colors.white;
const _surfaceContainerLow = Color(0xFFF3F4F1);
const _surfaceContainerHigh = Color(0xFFE6E9E6);
const _onSurfaceVariant = Color(0xFF5C605D);
const _outlineVariant = Color(0xFFAFB3B0);
const _primaryContainer = Color(0xFFCCEAD6);
const _onPrimaryContainer = Color(0xFF3D5749);
const _surfaceContainer = Color(0xFFEDEEEB);
const _surfaceContainerLowest = Color(0xFFFFFFFF);

class KioskPreview extends StatelessWidget {
  const KioskPreview({super.key, required this.config});

  final KioskConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LeftNav(restaurantName: config.restaurantName),
          Expanded(
            child: _CenterPanel(config: config),
          ),
          _RightSidebar(),
        ],
      ),
    );
  }
}

// ─── Left Nav ────────────────────────────────────────────────────────────────

class _LeftNav extends StatelessWidget {
  const _LeftNav({required this.restaurantName});

  final String restaurantName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      color: _surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand name
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 48),
            child: Text(
              restaurantName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: _primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          // Nav buttons
          _NavButton(
            icon: Icons.restaurant,
            label: 'Dine In',
            active: true,
          ),
          _NavButton(
            icon: Icons.local_mall_outlined,
            label: 'Takeaway',
          ),
          _NavButton(
            icon: Icons.auto_awesome_outlined,
            label: 'Seasonal',
          ),
          _NavButton(
            icon: Icons.help_outline,
            label: 'Support',
          ),
          const Spacer(),
          // Wait time card
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _outlineVariant.withValues(alpha: 0.1)),
              ),
              child: const Column(
                children: [
                  Text(
                    'ESTIMATED WAIT',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      color: _onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '~15 Mins',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
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

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.label, this.active = false});

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        margin: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(100),
            bottomRight: Radius.circular(100),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Row(
        children: [
          Icon(icon, color: _onSurface, size: 22),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              color: _onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Center Panel ─────────────────────────────────────────────────────────────

class _CenterPanel extends StatelessWidget {
  const _CenterPanel({required this.config});

  final KioskConfig config;

  @override
  Widget build(BuildContext context) {
    final products = config.products
        .map((key) => lookupProduct(key, kioskProducts))
        .whereType<SeedProduct>()
        .toList();

    return Container(
      color: _surface,
      child: Column(
        children: [
          // Category tab bar (floating top area)
          _CategoryTabBar(),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(40, 16, 40, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner
                  _Banner(config: config),
                  const SizedBox(height: 40),
                  // Section header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CUISINE SELECTION',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w700,
                                color: _onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Chef's Signature Mains",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _IconCircleButton(icon: Icons.filter_list),
                          const SizedBox(width: 12),
                          _IconCircleButton(icon: Icons.search),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Product grid
                  _ProductGrid(products: products),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: _surface.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: _outlineVariant.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          _TabItem(label: 'Mains', active: true),
          const SizedBox(width: 32),
          _TabItem(label: 'Appetizers'),
          const SizedBox(width: 32),
          _TabItem(label: 'Beverages'),
          const SizedBox(width: 32),
          _TabItem(label: 'Desserts'),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: active ? _primary : _onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        if (active)
          Container(
            height: 2,
            width: 40,
            color: _primary,
          ),
      ],
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, size: 20, color: _onSurface),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.config});

  final KioskConfig config;

  @override
  Widget build(BuildContext context) {
    final imageUrl = config.bannerImage?.publicUrl ?? config.bannerImage?.externalUrl ?? kioskBannerImageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 240,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: _primary),
            ),
            // Gradient overlay (left-to-right, primary to transparent)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _primary.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              left: 48,
              top: 0,
              bottom: 0,
              right: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1FFEB),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'LIMITED AVAILABILITY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: Color(0xFF3E5849),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    config.bannerTitle,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    config.bannerSubtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});

  final List<SeedProduct> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    // Bento-style: first card large (col-span-8), second small (col-span-4),
    // then pairs of small/large for remaining items.
    final rows = <Widget>[];

    // Row 1: large + small (if >= 2 products)
    if (products.length >= 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 8,
                child: _FeaturedProductCard(product: products[0]),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: _SmallProductCard(product: products[1]),
              ),
            ],
          ),
        ),
      );
    } else {
      rows.add(_FeaturedProductCard(product: products[0]));
    }

    // Row 2: small + large (products[2] and [3])
    if (products.length >= 3) {
      rows.add(const SizedBox(height: 24));
      final smallCards = <Widget>[];
      for (int i = 2; i < products.length && i < 4; i++) {
        if (smallCards.isNotEmpty) smallCards.add(const SizedBox(width: 24));
        smallCards.add(
          Expanded(
            flex: 4,
            child: _SmallProductCard(product: products[i]),
          ),
        );
      }
      // Pad with empty flex if only 1 item in row 2
      if (products.length == 3) {
        smallCards.add(const SizedBox(width: 24));
        smallCards.add(const Expanded(flex: 4, child: SizedBox.shrink()));
      }
      rows.add(IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: smallCards)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class _FeaturedProductCard extends StatelessWidget {
  const _FeaturedProductCard({required this.product});

  final SeedProduct product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: _surfaceContainerLowest,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image half
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _surfaceContainer),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content half
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: _onSurface,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: _onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                        if (product.tags.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: product.tags.map((tag) => _TagChip(label: tag)).toList(),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.add_shopping_cart, size: 20),
                        label: const Text(
                          'Add to Order',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
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

class _SmallProductCard extends StatelessWidget {
  const _SmallProductCard({required this.product});

  final SeedProduct product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: _surfaceContainerLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _surfaceContainer),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _onSurface,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _onSurfaceVariant,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primary,
                          side: const BorderSide(color: Color(0x33496455), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text(
                          'Quick Add',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
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

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _surfaceContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 1,
          color: _onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── Right Sidebar ────────────────────────────────────────────────────────────

class _RightSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        border: Border(
          left: BorderSide(color: _outlineVariant.withValues(alpha: 0.1)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Order',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    '2 Items',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Order items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _OrderItem(
                      name: 'Black Truffle Risotto',
                      note: 'No parmesan cheese',
                      price: 34.50,
                      quantity: 1,
                      thumbUrl: kioskOrderRisottoThumbUrl,
                    ),
                    const SizedBox(height: 28),
                    _OrderItem(
                      name: 'Heritage Scallops',
                      note: 'Extra puree',
                      price: 28.00,
                      quantity: 1,
                      thumbUrl: kioskOrderScallopsThumbUrl,
                    ),
                  ],
                ),
              ),
            ),
            // Totals
            Container(
              padding: const EdgeInsets.only(top: 32),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: _surfaceContainerHigh),
                ),
              ),
              child: Column(
                children: [
                  _TotalsRow(label: 'Subtotal', value: '\$62.50'),
                  const SizedBox(height: 12),
                  _TotalsRow(label: 'Tax (10%)', value: '\$6.25'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: _surfaceContainerHigh),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const Text(
                          '\$68.75',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: const Column(
                        children: [
                          Text(
                            'PLACE ORDER',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Payment via Card or Digital Wallet',
                            style: TextStyle(fontSize: 10, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Clear Selection',
                      style: TextStyle(
                        color: _onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
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

class _OrderItem extends StatelessWidget {
  const _OrderItem({
    required this.name,
    required this.note,
    required this.price,
    required this.quantity,
    required this.thumbUrl,
  });

  final String name;
  final String note;
  final double price;
  final int quantity;
  final String thumbUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 72,
            height: 72,
            child: Image.network(
              thumbUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: _surfaceContainer),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                note,
                style: const TextStyle(
                  fontSize: 12,
                  color: _onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _QtyButton(icon: Icons.remove),
                  const SizedBox(width: 16),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _QtyButton(icon: Icons.add),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, size: 14, color: _onSurfaceVariant),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _onSurfaceVariant, fontSize: 14)),
        Text(value, style: const TextStyle(color: _onSurfaceVariant, fontSize: 14)),
      ],
    );
  }
}
