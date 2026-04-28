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
  // 'Inter-Regular.ttf' -> 'Inter'; 'NotoSerif-Italic.ttf' -> 'Noto Serif'
  final base = filename.split('.').first.split('-').first;
  // Insert spaces before capitals (camel-case to "Camel Case")
  return base.replaceAllMapped(
    RegExp(r'(?<=[a-z])(?=[A-Z])'),
    (_) => ' ',
  );
}
