import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Register bundled fonts so goldens render with real typefaces.
  final fontDir = Directory('test/fonts');
  if (fontDir.existsSync()) {
    for (final font in fontDir.listSync().whereType<File>()) {
      if (font.path.endsWith('.ttf') || font.path.endsWith('.otf')) {
        final family = _familyFromFilename(font.uri.pathSegments.last);
        final loader = FontLoader(family);
        loader.addFont(
          Future.value(ByteData.view(font.readAsBytesSync().buffer)),
        );
        await loader.load();
      }
    }
  }
  await testMain();
}

String _familyFromFilename(String filename) {
  // 'Inter-Variable.ttf' -> 'Inter'
  // 'NotoSerif-Italic.ttf' -> 'Noto Serif'
  // 'DMSans-Variable.ttf' -> 'DM Sans' (acronym case)
  final base = filename.split('.').first.split('-').first;
  // Two passes: split before an uppercase preceded by lowercase (camel→space),
  // and split before an uppercase that begins a new word inside an acronym
  // (run of caps followed by lowercase).
  return base
      .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ')
      .replaceAllMapped(RegExp(r'(?<=[A-Z])(?=[A-Z][a-z])'), (_) => ' ');
}
