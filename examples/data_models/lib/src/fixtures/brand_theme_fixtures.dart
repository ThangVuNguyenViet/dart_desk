import 'package:dart_desk/dart_desk.dart';
import 'package:flutter/material.dart';

import '../configs/brand_theme.dart';
import '../primitives/aura_assets.dart';

class BrandThemeFixtures {
  /// The demo-quality fixture used by showcase apps and happy-path tests.
  static BrandTheme showcase() => BrandTheme.initialValue;

  /// Required fields at minimum, optionals null.
  static BrandTheme empty() => const BrandTheme(
    name: '',
    primaryColor: Color(0xFF000000),
    surfaceColor: Color(0xFFFFFFFF),
    accentColor: Color(0xFF000000),
    inkColor: Color(0xFF000000),
    headlineFont: 'Noto Serif',
    bodyFont: 'Manrope',
    cornerRadius: 0,
  );

  /// Every field set, including optionals `logo` and `brandGuidelinesPdf`
  /// that the showcase value leaves null.
  static BrandTheme allFieldsPopulated() => BrandTheme(
    name: showcase().name,
    primaryColor: showcase().primaryColor,
    surfaceColor: showcase().surfaceColor,
    accentColor: showcase().accentColor,
    inkColor: showcase().inkColor,
    headlineFont: showcase().headlineFont,
    bodyFont: showcase().bodyFont,
    cornerRadius: showcase().cornerRadius,
    logo: const ImageReference(externalUrl: AuraAssets.heroPlating),
    brandGuidelinesPdf: 'https://example.invalid/aura-brand-guidelines.pdf',
  );

  /// Showcase data with `name` cleared so non-blank validation fires.
  static BrandTheme withValidationError() => BrandTheme(
    name: '',
    primaryColor: showcase().primaryColor,
    surfaceColor: showcase().surfaceColor,
    accentColor: showcase().accentColor,
    inkColor: showcase().inkColor,
    headlineFont: showcase().headlineFont,
    bodyFont: showcase().bodyFont,
    cornerRadius: showcase().cornerRadius,
    logo: showcase().logo,
    brandGuidelinesPdf: showcase().brandGuidelinesPdf,
  );
}
