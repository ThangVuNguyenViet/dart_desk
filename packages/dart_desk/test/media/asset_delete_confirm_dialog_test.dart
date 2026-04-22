import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:dart_desk/src/media/browser/asset_delete_confirm_dialog.dart';
import 'package:dart_desk/src/data/models/media_asset.dart';
import 'package:dart_desk/src/data/models/image_types.dart';

MediaAsset _fakeAsset({String fileName = 'hero.jpg'}) {
  return MediaAsset(
    id: '1',
    assetId: 'asset-hero',
    fileName: fileName,
    mimeType: 'image/jpeg',
    fileSize: 1024,
    publicUrl: 'https://example.test/hero.jpg',
    width: 100,
    height: 100,
    hasAlpha: false,
    blurHash: '',
    createdAt: DateTime(2024),
    metadataStatus: MediaAssetMetadataStatus.complete,
  );
}

Future<void> _openDialog(
  WidgetTester tester, {
  required MediaAsset asset,
  required int usageCount,
  void Function(bool? result)? onResult,
}) async {
  await tester.pumpWidget(
    ShadApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              final result = await showShadDialog<bool>(
                context: context,
                builder: (_) => AssetDeleteConfirmDialog(
                  asset: asset,
                  usageCount: usageCount,
                ),
              );
              onResult?.call(result);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows Delete + Cancel when usageCount == 0', (tester) async {
    await _openDialog(tester, asset: _fakeAsset(), usageCount: 0);
    expect(find.text('hero.jpg'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.textContaining('In use'), findsNothing);
  });

  testWidgets('tapping Delete pops true', (tester) async {
    bool? result;
    await _openDialog(
      tester,
      asset: _fakeAsset(),
      usageCount: 0,
      onResult: (r) => result = r,
    );
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('tapping Cancel pops false', (tester) async {
    bool? result;
    await _openDialog(
      tester,
      asset: _fakeAsset(),
      usageCount: 0,
      onResult: (r) => result = r,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('shows in-use message and only Close when usageCount > 0',
      (tester) async {
    await _openDialog(tester, asset: _fakeAsset(), usageCount: 3);
    expect(find.textContaining('In use by 3 document'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
  });
}
