import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

class MenuItemScreen extends StatelessWidget {
  const MenuItemScreen({super.key, required this.config});

  final MenuItem config;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero photo
          _PhotoHero(config: config),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            config.category,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${config.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B3A2D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${config.calories} cal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (config.isVegetarian)
                      _Tag(
                        label: 'Vegetarian',
                        icon: Icons.eco,
                        color: const Color(0xFF16A34A),
                      ),
                    if (config.isGlutenFree)
                      _Tag(
                        label: 'Gluten-free',
                        icon: Icons.grain,
                        color: const Color(0xFFEA580C),
                      ),
                    ...config.tags.map(
                      (t) => _Tag(label: t, color: const Color(0xFF7C3AED)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nutrition
                _NutritionSection(config: config),
                const SizedBox(height: 24),

                // Allergens
                if (config.allergens.isNotEmpty) ...[
                  _AllergensSection(allergens: config.allergens),
                  const SizedBox(height: 24),
                ],

                // Variants
                if (config.variants.isNotEmpty)
                  _VariantsSection(variants: config.variants),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoHero extends StatelessWidget {
  const _PhotoHero({required this.config});
  final MenuItem config;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EB),
        gradient: config.photo == null
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF5F0EB), Color(0xFFEDE5DC)],
              )
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (config.photo != null)
            Image.network(config.photo!.url!, fit: BoxFit.cover)
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 48, color: Colors.brown[200]),
                  const SizedBox(height: 8),
                  Text(
                    'No photo',
                    style: TextStyle(fontSize: 12, color: Colors.brown[300]),
                  ),
                ],
              ),
            ),
          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withValues(alpha: 0), Colors.white],
                ),
              ),
            ),
          ),
          // Availability badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: config.isAvailable
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        (config.isAvailable
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626))
                            .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    config.isAvailable ? 'Available' : 'Unavailable',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SKU
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                config.sku,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionSection extends StatelessWidget {
  const _NutritionSection({required this.config});
  final MenuItem config;

  @override
  Widget build(BuildContext context) {
    final total =
        config.nutritionInfo.protein +
        config.nutritionInfo.carbs +
        config.nutritionInfo.fat;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8F0EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${config.calories} calories per serving',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          // Macro bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  if (total > 0) ...[
                    Expanded(
                      flex: config.nutritionInfo.protein,
                      child: Container(color: const Color(0xFF3B82F6)),
                    ),
                    Expanded(
                      flex: config.nutritionInfo.carbs,
                      child: Container(color: const Color(0xFFF59E0B)),
                    ),
                    Expanded(
                      flex: config.nutritionInfo.fat,
                      child: Container(color: const Color(0xFFEF4444)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MacroItem(
                label: 'Protein',
                value: '${config.nutritionInfo.protein}g',
                color: const Color(0xFF3B82F6),
              ),
              _MacroItem(
                label: 'Carbs',
                value: '${config.nutritionInfo.carbs}g',
                color: const Color(0xFFF59E0B),
              ),
              _MacroItem(
                label: 'Fat',
                value: '${config.nutritionInfo.fat}g',
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  const _MacroItem({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllergensSection extends StatelessWidget {
  const _AllergensSection({required this.allergens});
  final List<String> allergens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Allergens',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
                Text(
                  allergens.join(', '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF991B1B),
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

class _VariantsSection extends StatelessWidget {
  const _VariantsSection({required this.variants});
  final List<MenuItemVariant> variants;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size Options',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        ...variants.asMap().entries.map((entry) {
          final v = entry.value;
          final isFirst = entry.key == 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isFirst ? const Color(0xFFF0F7F3) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFirst
                    ? const Color(0xFF496455).withValues(alpha: 0.3)
                    : Colors.grey[200]!,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isFirst)
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF496455),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    Text(
                      v.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${v.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isFirst ? const Color(0xFF1B3A2D) : Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
