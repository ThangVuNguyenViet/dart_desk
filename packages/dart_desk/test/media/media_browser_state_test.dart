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

    test('loadAssets populates assets signal', () async {
      await state.loadAssets();

      expect(state.assets.value, hasLength(4));
      expect(state.totalCount.value, equals(4));
      expect(state.isLoading.value, isFalse);
    });

    test('search signal flows through', () async {
      state.search.value = 'hero';

      await state.loadAssets();

      expect(state.assets.value, hasLength(1));
      expect(state.assets.value.first.fileName, contains('hero'));
    });

    test('sort signal flows through', () async {
      state.sort.value = MediaSort.nameAsc;

      await state.loadAssets();

      expect(state.assets.value, isNotEmpty);
      expect(state.assets.value.first.fileName, equals('app-icon.png'));
    });

    test('deleteAsset removes and reloads', () async {
      await state.loadAssets();
      expect(state.assets.value, hasLength(4));

      await state.deleteAsset('asset-icon');

      expect(state.assets.value, hasLength(3));
    });

    test('deleteAsset clears selectedAssetId when deleted asset was selected',
        () async {
      await state.loadAssets();
      state.selectedAssetId.value = 'asset-icon';

      await state.deleteAsset('asset-icon');

      expect(state.selectedAssetId.value, isNull);
    });

    test('selectedAsset tracks selection', () async {
      await state.loadAssets();

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
