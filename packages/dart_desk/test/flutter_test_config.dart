import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads bundled fonts so goldens render with real typefaces.
///
/// Fonts ship with `package:dart_desk` (declared in pubspec.yaml), but
/// Flutter's test runner does not auto-load `flutter:` `fonts:` declarations
/// the way the app runtime does. We register each face from disk via
/// [FontLoader] so widget tests see "DM Sans" et al. instead of Ahem.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
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
