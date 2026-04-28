import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads `package:dart_desk` fonts from the sibling package so screen goldens
/// render with real typefaces instead of Ahem.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fontDir = Directory('../../packages/dart_desk/lib/fonts');
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
  // 'DMSans-Variable.ttf' -> 'DM Sans'
  final base = filename.split('.').first.split('-').first;
  return base
      .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ')
      .replaceAllMapped(RegExp(r'(?<=[A-Z])(?=[A-Z][a-z])'), (_) => ' ');
}
