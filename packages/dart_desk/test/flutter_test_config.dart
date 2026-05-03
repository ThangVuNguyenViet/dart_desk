import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads bundled fonts so goldens render with real typefaces.
///
/// Two sources:
///   - `lib/fonts/` in this package — the Aura design fonts (Inter, Manrope,
///     DM Sans, Noto Serif, Playfair Display, Cormorant Garamond,
///     DM Serif Display) used by data_models brand themes.
///   - `package:shadcn_ui` — Geist + GeistMono, the default text family for
///     ShadApp. Resolved through `.dart_tool/package_config.json` because
///     `Isolate.resolvePackageUri` is unsupported in `flutter_test`.
///
/// `flutter_test` does not honour `flutter:` `fonts:` declarations in
/// pubspec.yaml; every face has to be registered via [FontLoader] or text
/// falls back to Ahem (solid rectangles).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadAuraFonts(Directory('lib/fonts'));
  await _loadShadcnGeist(packageRoot: Directory.current);
  // Goldens are generated on linux/arm64 (cirruslabs/flutter Docker, pinned
  // via scripts/regenerate-goldens.sh) and CI runs the same container on
  // ubuntu-22.04-arm. A tiny per-pixel tolerance absorbs sub-pixel jitter
  // without masking real layout changes (which produce diffs an order of
  // magnitude larger).
  final defaultComparator = goldenFileComparator as LocalFileComparator;
  goldenFileComparator = _TolerantComparator(
    defaultComparator.basedir.resolve('flutter_test_config.dart'),
  );
  await testMain();
}

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  /// 0.1% — goldens are pinned to linux/arm64 in both regeneration and CI,
  /// so only sub-pixel jitter remains. Real layout/style changes produce
  /// diffs an order of magnitude larger.
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

Future<void> _loadAuraFonts(Directory dir) async {
  await _loadFontsFromDir(
    dir,
    family: (name) => _familyFromFilename(name),
  );
}

Future<void> _loadShadcnGeist({required Directory packageRoot}) async {
  final fontsDir = await _resolvePackageDir(
    packageRoot: packageRoot,
    package: 'shadcn_ui',
    subdir: 'fonts',
  );
  if (fontsDir == null) return;
  await _loadFontsFromDir(
    fontsDir,
    // ShadApp uses 'packages/shadcn_ui/Geist' (and GeistMono) as family
    // names — Flutter prefixes package-bundled fonts that way.
    family: (name) {
      final base = name.split('-').first; // Geist | GeistMono
      return 'packages/shadcn_ui/$base';
    },
  );
}

Future<Directory?> _resolvePackageDir({
  required Directory packageRoot,
  required String package,
  required String subdir,
}) async {
  // Workspace setups (resolution: workspace) keep one package_config.json at
  // the workspace root, not per-package. Walk up from the package directory
  // until we find it.
  File? config;
  for (var d = packageRoot; ; d = d.parent) {
    final candidate = File('${d.path}/.dart_tool/package_config.json');
    if (candidate.existsSync()) {
      config = candidate;
      break;
    }
    if (d.parent.path == d.path) break; // hit filesystem root
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
  // Ensure trailing slash so URI resolution treats rootUri as a directory.
  final normalisedRoot = rootUri.endsWith('/') ? rootUri : '$rootUri/';
  final base = config.parent.uri;
  return Directory.fromUri(base.resolve(normalisedRoot).resolve('$subdir/'));
}

Future<void> _loadFontsFromDir(
  Directory dir, {
  required String Function(String filename) family,
}) async {
  if (!dir.existsSync()) return;
  // Group faces by family so each family's variants share one FontLoader.
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
