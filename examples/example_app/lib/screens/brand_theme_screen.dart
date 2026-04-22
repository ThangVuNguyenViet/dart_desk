import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

import '../widgets/aura/aura_button.dart';
import '../widgets/aura/aura_theme.dart';
import '../widgets/aura/aura_tokens.dart';
import '../widgets/aura/aura_wordmark.dart';
import '../widgets/aura/photo.dart';

class BrandThemeScreen extends StatelessWidget {
  const BrandThemeScreen({super.key, required this.config});
  final BrandTheme config;

  @override
  Widget build(BuildContext context) {
    return AuraTheme.wrap(
      config,
      child: Builder(builder: (context) => _Body(config: config)),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.config});
  final BrandTheme config;

  @override
  Widget build(BuildContext context) {
    final tokens = AuraTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroStrip(config: config, scheme: scheme),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionLabel(text: 'COLOR PALETTE'),
                const SizedBox(height: 12),
                _ColorPaletteRow(config: config),
                const SizedBox(height: 32),
                _SectionLabel(text: 'TYPOGRAPHY'),
                const SizedBox(height: 12),
                _TypographySample(config: config, scheme: scheme),
                const SizedBox(height: 32),
                _SectionLabel(text: 'BUTTONS'),
                const SizedBox(height: 12),
                _ButtonsRow(config: config, scheme: scheme),
                const SizedBox(height: 32),
                _SectionLabel(text: 'CARD SAMPLE'),
                const SizedBox(height: 12),
                _CardSample(config: config, tokens: tokens, scheme: scheme),
                const SizedBox(height: 32),
                _SectionLabel(text: 'LOGO'),
                const SizedBox(height: 12),
                _LogoPreview(config: config, tokens: tokens),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        letterSpacing: 2.5,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}

// 1. Hero strip
class _HeroStrip extends StatelessWidget {
  const _HeroStrip({required this.config, required this.scheme});
  final BrandTheme config;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: config.primaryColor,
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuraWordmark(color: config.surfaceColor, size: 22),
          const SizedBox(height: 12),
          Text(
            'Brand Theme · live',
            style: TextStyle(
              color: config.surfaceColor.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// 2. Color palette row
class _ColorPaletteRow extends StatelessWidget {
  const _ColorPaletteRow({required this.config});
  final BrandTheme config;

  @override
  Widget build(BuildContext context) {
    final swatches = [
      (config.primaryColor, 'Primary'),
      (config.surfaceColor, 'Surface'),
      (config.accentColor, 'Accent'),
      (config.inkColor, 'Ink'),
    ];
    return Row(
      children: swatches
          .map(
            (s) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _Swatch(color: s.$1, label: s.$2),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label});
  final Color color;
  final String label;

  String get _hex {
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final inkColor = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: inkColor.withValues(alpha: 0.08),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: inkColor,
          ),
        ),
        Text(
          _hex,
          style: TextStyle(
            fontSize: 9.5,
            color: inkColor.withValues(alpha: 0.55),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// 3. Typography sample
class _TypographySample extends StatelessWidget {
  const _TypographySample({required this.config, required this.scheme});
  final BrandTheme config;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A table for the long evening.',
            style: TextStyle(
              fontFamily: config.headlineFont,
              fontSize: 48,
              fontStyle: FontStyle.italic,
              height: 1.05,
              letterSpacing: -0.5,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'The quick brown fox jumps over the lazy dog. '
            'Configured in ${config.bodyFont} at 16pt regular.',
            style: TextStyle(
              fontFamily: config.bodyFont,
              fontSize: 16,
              height: 1.55,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// 4. Buttons row
class _ButtonsRow extends StatelessWidget {
  const _ButtonsRow({required this.config, required this.scheme});
  final BrandTheme config;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        AuraButton(
          label: 'Reserve',
          style: AuraButtonStyle.solid,
          showArrow: false,
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: config.primaryColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: AuraButton(
            label: 'Menu',
            style: AuraButtonStyle.ghost,
            showArrow: false,
          ),
        ),
        AuraButton(
          label: 'Learn more',
          style: AuraButtonStyle.dark,
          showArrow: true,
        ),
      ],
    );
  }
}

// 5. Card sample
class _CardSample extends StatelessWidget {
  const _CardSample({
    required this.config,
    required this.tokens,
    required this.scheme,
  });
  final BrandTheme config;
  final AuraTokens tokens;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final radius = config.cornerRadius.toDouble();
    return SizedBox(
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          color: tokens.creamWarm,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: tokens.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Photo(
              fallbackUrl: AuraAssets.dish1,
              width: 200,
              height: 140,
              radius: 0,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Charred Brassicas',
                    style: TextStyle(
                      fontFamily: config.headlineFont,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -0.1,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$16',
                    style: TextStyle(
                      fontFamily: config.headlineFont,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: scheme.secondary,
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

// 6. Logo preview
class _LogoPreview extends StatelessWidget {
  const _LogoPreview({required this.config, required this.tokens});
  final BrandTheme config;
  final AuraTokens tokens;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (config.logo != null) {
      return Photo(
        reference: config.logo,
        width: 96,
        height: 96,
        radius: 12,
      );
    }
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: tokens.creamWarm,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.line),
      ),
      alignment: Alignment.center,
      child: Text(
        'No logo\nuploaded',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: scheme.onSurface.withValues(alpha: 0.45),
          height: 1.4,
        ),
      ),
    );
  }
}
