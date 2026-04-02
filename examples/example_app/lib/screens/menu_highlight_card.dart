import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

/// Preview of a featured menu item card as it appears in the food ordering app.
class MenuHighlightCard extends StatelessWidget {
  final MenuHighlight config;
  const MenuHighlightCard({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The card
              _ItemCard(config: config),
              const SizedBox(height: 24),
              // Metadata row
              _MetadataRow(config: config),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final MenuHighlight config;
  const _ItemCard({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image area
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (config.photo != null)
                  Image.network(
                    config.photo!.url!,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    color: const Color(0xFFF5E6D3),
                    child: const Icon(Icons.restaurant_menu,
                        size: 56, color: Color(0xFFD4451A)),
                  ),
                // Badge
                if (config.badge != null && config.badge!.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _badgeColor(config.badge!),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        config.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                // Availability overlay
                if (!config.available)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Currently Unavailable',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        config.itemName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${config.price.toStringAsFixed(config.price.truncateToDouble() == config.price ? 0 : 2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD4451A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _CategoryChip(category: config.category),
                const SizedBox(height: 8),
                Text(
                  config.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Calories & allergens row
                Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 16, color: Colors.orange.shade400),
                    const SizedBox(width: 4),
                    Text(
                      '${config.calories.toInt()} cal',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (config.allergens != null &&
                        config.allergens!.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.info_outline,
                          size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          config.allergens!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _badgeColor(String badge) {
    return switch (badge.toUpperCase()) {
      'NEW' => const Color(0xFF2E7D32),
      'POPULAR' => const Color(0xFFD4451A),
      'SPICY' => const Color(0xFFE65100),
      'VEGAN' => const Color(0xFF558B2F),
      _ => const Color(0xFF5C6BC0),
    };
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final label = switch (category) {
      'appetizer' => 'Appetizer',
      'main' => 'Main Course',
      'dessert' => 'Dessert',
      'drink' => 'Drink',
      'side' => 'Side',
      _ => category,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6D3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8D6E63),
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final MenuHighlight config;
  const _MetadataRow({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MetaItem(
            icon: Icons.sort,
            label: 'Sort',
            value: '#${config.sortOrder}',
          ),
          _MetaItem(
            icon: config.available
                ? Icons.check_circle
                : Icons.cancel,
            label: 'Status',
            value: config.available ? 'Available' : 'Unavailable',
            color: config.available ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color ?? Colors.grey.shade500),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color ?? Colors.grey.shade800)),
      ],
    );
  }
}
