import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

/// Preview of the brand theme as applied to a mini food ordering app mockup.
class AppThemePreview extends StatelessWidget {
  final AppTheme config;
  const AppThemePreview({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(config.cornerRadius.toDouble());

    return Scaffold(
      backgroundColor: config.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo
            _ThemeHeader(config: config, radius: radius),
            const SizedBox(height: 28),
            // Color swatches
            Text(
              'Brand Colors',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: config.textColor.withValues(alpha: 0.5),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ColorSwatch(
                    color: config.primaryColor, label: 'Primary', radius: radius),
                const SizedBox(width: 10),
                _ColorSwatch(
                    color: config.secondaryColor,
                    label: 'Secondary',
                    radius: radius),
                const SizedBox(width: 10),
                _ColorSwatch(
                    color: config.backgroundColor, label: 'BG', radius: radius),
                const SizedBox(width: 10),
                _ColorSwatch(
                    color: config.textColor, label: 'Text', radius: radius),
              ],
            ),
            const SizedBox(height: 28),
            // Sample UI elements
            Text(
              'UI Preview',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: config.textColor.withValues(alpha: 0.5),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            // Sample card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: config.textColor.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Truffle Mushroom Risotto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: config.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Creamy Arborio rice with wild mushrooms',
                    style: TextStyle(
                      fontSize: 13,
                      color: config.textColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '\$24',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: config.primaryColor,
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: config.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: radius),
                        ),
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Buttons row
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: config.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(borderRadius: radius),
                    ),
                    child: const Text('Primary'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: config.secondaryColor,
                      side: BorderSide(color: config.secondaryColor),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(borderRadius: radius),
                    ),
                    child: const Text('Secondary'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Settings
            _SettingsRow(
              label: 'Theme Mode',
              value: config.themeMode,
              textColor: config.textColor,
            ),
            _SettingsRow(
              label: 'Corner Radius',
              value: '${config.cornerRadius}dp',
              textColor: config.textColor,
            ),
            _SettingsRow(
              label: 'Material 3',
              value: config.useMaterial3 ? 'Enabled' : 'Disabled',
              textColor: config.textColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeHeader extends StatelessWidget {
  final AppTheme config;
  final BorderRadius radius;
  const _ThemeHeader({required this.config, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (config.logoLight != null)
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: radius,
              image: DecorationImage(
                // ImageUrl.url() supports CDN transforms (width, height, format, quality)
                image: NetworkImage(config.logoLight!.url(width: 200, format: 'webp')!),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: config.primaryColor,
              borderRadius: radius,
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 24),
          ),
        Text(
          'Theme Preview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: config.textColor,
          ),
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String label;
  final BorderRadius radius;
  const _ColorSwatch(
      {required this.color, required this.label, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: radius,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          Text(
            '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade400,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  const _SettingsRow(
      {required this.label, required this.value, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
