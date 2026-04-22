import 'package:dart_desk/src/studio/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  group('deskStudioTheme (dark)', () {
    test('uses editorial dark palette on ShadColorScheme', () {
      final scheme = deskStudioTheme.colorScheme;
      expect(scheme.background, DartDeskColors.darkBackground);
      expect(scheme.foreground, DartDeskColors.darkForeground);
      expect(scheme.primary, DartDeskColors.darkPrimary);
      expect(scheme.primaryForeground, DartDeskColors.darkPrimaryForeground);
      expect(scheme.accent, DartDeskColors.darkAccent);
      expect(scheme.accentForeground, DartDeskColors.darkAccentForeground);
      expect(scheme.ring, DartDeskColors.darkRing);
      expect(scheme.destructive, DartDeskColors.darkDestructive);
    });

    test('brightness is dark', () {
      expect(deskStudioTheme.brightness, Brightness.dark);
    });
  });

  group('deskStudioLightTheme', () {
    test('uses editorial light palette', () {
      final scheme = deskStudioLightTheme.colorScheme;
      expect(scheme.background, DartDeskColors.lightBackground);
      expect(scheme.primary, DartDeskColors.lightPrimary);
      expect(scheme.accent, DartDeskColors.lightAccent);
      expect(scheme.ring, DartDeskColors.lightRing);
    });

    test('brightness is light', () {
      expect(deskStudioLightTheme.brightness, Brightness.light);
    });
  });

  test('accent is the same chartreuse in both modes', () {
    expect(
      deskStudioTheme.colorScheme.accent,
      deskStudioLightTheme.colorScheme.accent,
    );
  });

  testWidgets(
    'context.dartDeskPalette is available inside ShadApp with materialThemeBuilder',
    (tester) async {
      DartDeskPalette? read;
      await tester.pumpWidget(
        ShadApp(
          theme: deskStudioTheme,
          materialThemeBuilder: (context, mTheme) => mTheme.copyWith(
            extensions: const <ThemeExtension<dynamic>>[DartDeskPalette.dark],
          ),
          home: Builder(
            builder: (context) {
              read = context.dartDeskPalette;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(read, isNotNull);
      expect(read!.accentText, DartDeskColors.darkAccentText);
    },
  );
}
