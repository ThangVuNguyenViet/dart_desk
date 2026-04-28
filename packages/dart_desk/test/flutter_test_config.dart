import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

/// Loads bundled fonts so goldens render with real typefaces.
///
/// Two passes:
/// 1. [TestFonts.loadAppFonts] reads `FontManifest.json` and loads every font
///    declared by this package or any transitive dependency. That covers
///    shadcn_ui's `Geist` (the default family for `ShadApp` chrome) and
///    FontAwesome, neither of which lives in `lib/fonts/`.
/// 2. The manual walk below registers dart_desk's own faces a second time
///    under their raw family names ("DM Sans", "Inter", …). FontManifest
///    registers them prefixed as `packages/dart_desk/<family>`, so widgets
///    inside dart_desk that use plain `fontFamily: 'DM Sans'` (no `package:`)
///    wouldn't otherwise resolve.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await TestFonts.loadAppFonts();
  final fontDir = Directory('lib/fonts');
  if (fontDir.existsSync()) {
    for (final font in fontDir.listSync().whereType<File>()) {
      final name = font.uri.pathSegments.last;
      if (!name.endsWith('.ttf') && !name.endsWith('.otf')) continue;
      final loader = FontLoader(_familyFromFilename(name));
      loader.addFont(
        Future.value(ByteData.view(font.readAsBytesSync().buffer)),
      );
      await loader.load();
    }
  }
  await testMain();
}

String _familyFromFilename(String filename) {
  // 'Inter-Variable.ttf' -> 'Inter'
  // 'NotoSerif-Variable.ttf' -> 'Noto Serif'
  // 'DMSans-Variable.ttf' -> 'DM Sans' (acronym case)
  final base = filename.split('.').first.split('-').first;
  return base
      .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ')
      .replaceAllMapped(RegExp(r'(?<=[A-Z])(?=[A-Z][a-z])'), (_) => ' ');
}
