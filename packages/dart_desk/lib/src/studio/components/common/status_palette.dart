import 'package:flutter/painting.dart';

/// Semantic status colors for state indicators (status pills, version badges).
///
/// Intentional exception to the "one chromatic color" rule — status colors are
/// a functional taxonomy (info/success/warning/special), not accent chrome.
/// Kept outside the theme so the distinct hues survive theme changes.
class StatusColors {
  const StatusColors({
    required this.darkBg,
    required this.darkFg,
    required this.lightBg,
    required this.lightFg,
    required this.badgeLightBg,
    required this.badgeLightFg,
  });

  /// Status-pill background (lives on any theme bg).
  final Color darkBg;

  /// Status-pill foreground (dot + text).
  final Color darkFg;

  final Color lightBg;
  final Color lightFg;

  /// High-contrast pair used by version-history badges on cream surfaces.
  final Color badgeLightBg;
  final Color badgeLightFg;
}

abstract final class StatusPalette {
  /// Blue family — "changed / in review / scheduled info".
  static const StatusColors info = StatusColors(
    darkBg: Color(0x1A3B82F6), // 10% alpha of 0xFF3b82f6
    darkFg: Color(0xFF3B82F6),
    lightBg: Color(0x143B82F6), // 8% alpha
    lightFg: Color(0xFF2563EB),
    badgeLightBg: Color(0xFFDBEAFE), // Blue-100
    badgeLightFg: Color(0xFF1E40AF), // Blue-900
  );

  /// Green family — "published / success".
  static const StatusColors success = StatusColors(
    darkBg: Color(0x1A22C55E),
    darkFg: Color(0xFF22C55E),
    lightBg: Color(0x1422C55E),
    lightFg: Color(0xFF16A34A),
    badgeLightBg: Color(0xFFD1FAE5), // Green-100
    badgeLightFg: Color(0xFF065F46), // Green-900
  );

  /// Yellow family — "draft / warning / attention".
  static const StatusColors warning = StatusColors(
    darkBg: Color(0x1AEAB308),
    darkFg: Color(0xFFEAB308),
    lightBg: Color(0x14EAB308),
    lightFg: Color(0xFFB45309),
    badgeLightBg: Color(0xFFFEF3C7), // Yellow-100
    badgeLightFg: Color(0xFF92400E), // Yellow-900
  );

  /// Violet family — "scheduled / special".
  static const StatusColors special = StatusColors(
    darkBg: Color(0x1A8B5CF6),
    darkFg: Color(0xFF8B5CF6),
    lightBg: Color(0x148B5CF6),
    lightFg: Color(0xFF7C3AED),
    badgeLightBg: Color(0xFFEDE9FE),
    badgeLightFg: Color(0xFF5B21B6),
  );
}
