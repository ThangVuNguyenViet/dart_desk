import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

class BrandThemeScreen extends StatelessWidget {
  const BrandThemeScreen({super.key, required this.config});

  final BrandTheme config;

  String _toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(config.cornerRadius.toDouble());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.restaurant, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Theme Preview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Color swatches
          Row(
            children: [
              _ColorSwatch(
                color: config.primaryColor,
                label: _toHex(config.primaryColor),
              ),
              _ColorSwatch(
                color: config.surfaceColor,
                label: _toHex(config.surfaceColor),
              ),
              _ColorSwatch(
                color: config.textColor,
                label: _toHex(config.textColor),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Typography section
          Text(
            'The Art of Fine Dining',
            style: TextStyle(
              fontFamily: config.headlineFont,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Experience culinary excellence crafted with the finest ingredients '
            'from around the world.',
            style: TextStyle(
              fontFamily: config.bodyFont,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Sample food card
          Card(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: radius),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Truffle Wagyu Burger',
                    style: TextStyle(
                      fontFamily: config.headlineFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Grass-fed Wagyu beef patty topped with shaved black truffle, '
                    'aged Gruyère, and house aioli on a brioche bun.',
                    style: TextStyle(
                      fontFamily: config.bodyFont,
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$42.00',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: config.primaryColor,
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: config.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: radius),
                        ),
                        onPressed: () {},
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Button row
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: config.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: radius),
                  ),
                  onPressed: () {},
                  child: const Text('Primary Action'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: config.primaryColor,
                    side: BorderSide(color: config.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: radius),
                  ),
                  onPressed: () {},
                  child: const Text('Secondary'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Settings summary
          const Text(
            'Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _SettingsRow(label: 'Theme Mode', value: config.themeMode),
          _SettingsRow(
            label: 'Corner Radius',
            value: '${config.cornerRadius}px',
          ),
          _SettingsRow(label: 'Headline Font', value: config.headlineFont),
          _SettingsRow(label: 'Body Font', value: config.bodyFont),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
