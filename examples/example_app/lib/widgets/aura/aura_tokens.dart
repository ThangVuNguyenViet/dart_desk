import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

/// Editorial tokens not expressible in Material 3 — soft tones used in the
/// Aura JSX that `ThemeData` alone can't carry.
///
/// Computed from [BrandTheme]. Call `AuraTokens.of(context)` inside any
/// subtree wrapped by [AuraTheme.wrap].
class AuraTokens extends InheritedWidget {
  final Color creamWarm;   // surface-1 / card
  final Color inkSoft;     // muted body text
  final Color mute;        // tertiary text
  final Color line;        // hairline border
  final Color greenDark;   // dark surface (chef quote card)

  const AuraTokens({
    super.key,
    required super.child,
    required this.creamWarm,
    required this.inkSoft,
    required this.mute,
    required this.line,
    required this.greenDark,
  });

  static AuraTokens of(BuildContext context) {
    final t = context.dependOnInheritedWidgetOfExactType<AuraTokens>();
    assert(t != null, 'AuraTokens.of() called outside an AuraTheme.wrap');
    return t!;
  }

  @override
  bool updateShouldNotify(AuraTokens old) =>
      creamWarm != old.creamWarm ||
      inkSoft != old.inkSoft ||
      mute != old.mute ||
      line != old.line ||
      greenDark != old.greenDark;
}
