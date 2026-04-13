import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

class BrandThemeScreen extends StatelessWidget {
  const BrandThemeScreen({super.key, required this.config});

  final BrandTheme config;

  String _toHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(config.cornerRadius.toDouble());
    final isDark = config.themeMode.toLowerCase() == 'dark';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero
          _ThemeHero(config: config, isDark: isDark),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color palette
                const Text(
                  'Color Palette',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ColorSwatch(
                      color: config.primaryColor,
                      label: 'Primary',
                      hex: _toHex(config.primaryColor),
                    ),
                    const SizedBox(width: 10),
                    _ColorSwatch(
                      color: config.secondaryColor,
                      label: 'Secondary',
                      hex: _toHex(config.secondaryColor),
                    ),
                    const SizedBox(width: 10),
                    _ColorSwatch(
                      color: config.accentColor,
                      label: 'Accent',
                      hex: _toHex(config.accentColor),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Typography specimen
                _TypographySection(config: config),
                const SizedBox(height: 28),

                // Live preview card
                _LivePreviewCard(config: config, radius: radius),
                const SizedBox(height: 24),

                // Settings
                _SettingsSection(config: config),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeHero extends StatelessWidget {
  const _ThemeHero({required this.config, required this.isDark});
  final BrandTheme config;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.primaryColor,
            Color.lerp(config.primaryColor, config.secondaryColor, 0.5)!,
            config.secondaryColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Noise texture overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Decorative accent dot
          Positioned(
            right: 30,
            top: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: config.accentColor.withValues(alpha: 0.4),
              ),
            ),
          ),
          // Content
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isDark ? 'DARK MODE' : 'LIGHT MODE',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  config.name,
                  style: TextStyle(
                    fontFamily: config.headlineFont,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
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

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.label,
    required this.hex,
  });
  final Color color;
  final String label;
  final String hex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            hex,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _TypographySection extends StatelessWidget {
  const _TypographySection({required this.config});
  final BrandTheme config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.text_fields, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Typography',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Headline Font',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The Art of Fine Dining',
            style: TextStyle(
              fontFamily: config.headlineFont,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            config.headlineFont,
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'Body Font',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Experience culinary excellence crafted with the finest seasonal ingredients from around the world.',
            style: TextStyle(
              fontFamily: config.bodyFont,
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            config.bodyFont,
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _LivePreviewCard extends StatelessWidget {
  const _LivePreviewCard({required this.config, required this.radius});
  final BrandTheme config;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Preview',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Mini image placeholder
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      config.primaryColor.withValues(alpha: 0.15),
                      config.accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: radius.topLeft,
                    topRight: radius.topRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 36,
                    color: config.primaryColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Truffle Risotto',
                      style: TextStyle(
                        fontFamily: config.headlineFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Creamy arborio rice with black truffle',
                      style: TextStyle(
                        fontFamily: config.bodyFont,
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$34.50',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: config.primaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: config.primaryColor,
                            borderRadius: radius,
                          ),
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontFamily: config.bodyFont,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.config});
  final BrandTheme config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _SettingRow(
            icon: Icons.rounded_corner,
            label: 'Corner Radius',
            value: '${config.cornerRadius}px',
          ),
          Divider(height: 20, color: Colors.grey[200]),
          _SettingRow(
            icon: Icons.title,
            label: 'Headline Font',
            value: config.headlineFont,
          ),
          Divider(height: 20, color: Colors.grey[200]),
          _SettingRow(
            icon: Icons.text_snippet_outlined,
            label: 'Body Font',
            value: config.bodyFont,
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
