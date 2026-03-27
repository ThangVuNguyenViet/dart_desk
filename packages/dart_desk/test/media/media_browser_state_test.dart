import 'package:flutter_test/flutter_test.dart';
import 'package:dart_desk/src/media/browser/media_browser_state.dart';
import 'package:dart_desk/testing.dart';
import 'package:dart_desk/dart_desk.dart';

void main() {
  group('MediaBrowserState', () {
    late MockDataSource dataSource;
    late MediaBrowserState state;

    setUp(() {
      dataSource = MockDataSource();
      state = MediaBrowserState(dataSource: dataSource);
    });

    tearDown(() {
      state.dispose();
    });

    test('assetsData loads on first access', () async {
      final page = await state.assetsData.future;

      expect(page.items, hasLength(4));
      expect(page.total, equals(4));
      expect(state.assetsData.value.isLoading, isFalse);
    });

    test('search signal flows through', () async {
      state.search.value = 'hero';

      final page = await state.assetsData.future;

      expect(page.items, hasLength(1));
      expect(page.items.first.fileName, contains('hero'));
    });

    test('sort signal flows through', () async {
      state.sort.value = MediaSort.nameAsc;

      final page = await state.assetsData.future;

      expect(page.items, isNotEmpty);
      expect(page.items.first.fileName, equals('app-icon.png'));
    });

    test('deleteAsset removes and reloads', () async {
      await state.assetsData.future;
      expect(state.assetsData.value.value?.items, hasLength(4));

      await state.deleteAsset('asset-icon');
      await state.assetsData.future;

      expect(state.assetsData.value.value?.items, hasLength(3));
    });

    test('deleteAsset clears selectedAssetId when deleted asset was selected',
        () async {
      await state.assetsData.future;
      state.selectedAssetId.value = 'asset-icon';

      await state.deleteAsset('asset-icon');

      expect(state.selectedAssetId.value, isNull);
    });

    test('selectedAsset tracks selection', () async {
      await state.assetsData.future;

      state.selectedAssetId.value = 'asset-hero';
      final selected = state.selectedAsset;
      expect(selected, isNotNull);
      expect(selected!.assetId, equals('asset-hero'));

      state.selectedAssetId.value = null;
      expect(state.selectedAsset, isNull);
    });

    test('dispose cleans up without errors', () {
      expect(() => state.dispose(), returnsNormally);
    });
  });
}
