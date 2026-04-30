import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads dart_desk's Aura fonts plus shadcn_ui's Geist so screen goldens
/// render with real typefaces. See packages/dart_desk/test/flutter_test_config.dart
/// for the full rationale.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // dart_desk ships its Aura fonts under lib/fonts/. We reach across the
  // workspace because flutter_test starts CWD in this package root.
  await _loadFontsFromDir(
    Directory('../../packages/dart_desk/lib/fonts'),
    family: (name) => _familyFromFilename(name),
  );
  final geistDir = await _resolvePackageDir(
    packageRoot: Directory.current,
    package: 'shadcn_ui',
    subdir: 'fonts',
  );
  if (geistDir != null) {
    await _loadFontsFromDir(
      geistDir,
      family: (name) {
        final base = name.split('-').first;
        return 'packages/shadcn_ui/$base';
      },
    );
  }
  // ARM↔x86 sub-pixel drift on real fonts. See dart_desk's flutter_test_config.
  final defaultComparator = goldenFileComparator as LocalFileComparator;
  goldenFileComparator = _TolerantComparator(
    defaultComparator.basedir.resolve('flutter_test_config.dart'),
  );
  await testMain();
}

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  static const double _kPixelTolerance = 0.001;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= _kPixelTolerance) {
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}

Future<Directory?> _resolvePackageDir({
  required Directory packageRoot,
  required String package,
  required String subdir,
}) async {
  File? config;
  for (var d = packageRoot; ; d = d.parent) {
    final candidate = File('${d.path}/.dart_tool/package_config.json');
    if (candidate.existsSync()) {
      config = candidate;
      break;
    }
    if (d.parent.path == d.path) break;
  }
  if (config == null) return null;
  final data = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
  final packages = (data['packages'] as List).cast<Map<String, dynamic>>();
  final entry = packages.firstWhere(
    (p) => p['name'] == package,
    orElse: () => <String, dynamic>{},
  );
  final rootUri = entry['rootUri'] as String?;
  if (rootUri == null) return null;
  final normalisedRoot = rootUri.endsWith('/') ? rootUri : '$rootUri/';
  final base = config.parent.uri;
  return Directory.fromUri(base.resolve(normalisedRoot).resolve('$subdir/'));
}

Future<void> _loadFontsFromDir(
  Directory dir, {
  required String Function(String filename) family,
}) async {
  if (!dir.existsSync()) return;
  final byFamily = <String, List<File>>{};
  for (final f in dir.listSync().whereType<File>()) {
    final name = f.uri.pathSegments.last;
    if (!name.endsWith('.ttf') && !name.endsWith('.otf')) continue;
    byFamily.putIfAbsent(family(name), () => []).add(f);
  }
  for (final entry in byFamily.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      loader.addFont(
        Future.value(ByteData.view(file.readAsBytesSync().buffer)),
      );
    }
    await loader.load();
  }
}

String _familyFromFilename(String filename) {
  final base = filename.split('.').first.split('-').first;
  return base
      .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ')
      .replaceAllMapped(RegExp(r'(?<=[A-Z])(?=[A-Z][a-z])'), (_) => ' ');
}
