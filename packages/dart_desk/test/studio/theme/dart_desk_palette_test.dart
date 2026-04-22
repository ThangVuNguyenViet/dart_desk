import 'package:dart_desk/src/studio/theme/dart_desk_palette.dart';
import 'package:dart_desk/src/studio/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DartDeskPalette', () {
    test('dark factory has the dark accent tokens', () {
      const p = DartDeskPalette.dark;
      expect(p.accentHover, DartDeskColors.darkAccentHover);
      expect(p.accentTint, DartDeskColors.darkAccentTint);
      expect(p.accentTintBorder, DartDeskColors.darkAccentTintBorder);
      expect(p.accentText, DartDeskColors.darkAccentText);
    });

    test('light factory has the light accent tokens', () {
      const p = DartDeskPalette.light;
      expect(p.accentHover, DartDeskColors.lightAccentHover);
      expect(p.accentText, DartDeskColors.lightAccentText);
    });

    test('lerp at t=0 returns a, at t=1 returns b', () {
      const a = DartDeskPalette.dark;
      const b = DartDeskPalette.light;
      final zero = a.lerp(b, 0);
      final one = a.lerp(b, 1);
      expect(zero.accentText, a.accentText);
      expect(one.accentText, b.accentText);
    });

    test('copyWith overrides only the named field', () {
      const p = DartDeskPalette.dark;
      final copy = p.copyWith(accentText: const Color(0xFF123456));
      expect(copy.accentText, const Color(0xFF123456));
      expect(copy.accentHover, p.accentHover);
    });

    testWidgets('context.dartDeskPalette reads from ThemeExtension', (
      tester,
    ) async {
      DartDeskPalette? read;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [DartDeskPalette.dark]),
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
    });
  });
}
