import 'dart:typed_data';

import 'package:signals/signals.dart';

import '../../data/cms_data_source.dart';
import '../../data/models/image_types.dart';
import '../../data/models/media_asset.dart';

class MediaBrowserState {
  final CmsDataSource dataSource;

  // Filter/search state
  final search = signal('');
  final typeFilter = signal(MediaTypeFilter.all);
  final sort = signal(MediaSort.dateDesc);
  final page = signal(0);
  final int pageSize;

  // View state
  final isGridView = signal(true);
  final selectedAssetId = signal<String?>(null);
  final isLoading = signal(false);
  final error = signal<String?>(null);

  // Data
  final assets = signal<List<MediaAsset>>([]);
  final totalCount = signal(0);

  MediaBrowserState({required this.dataSource, this.pageSize = 24});

  Future<void> loadAssets() async {
    isLoading.value = true;
    error.value = null;
    try {
      final result = await dataSource.listMedia(
        search: search.value.isEmpty ? null : search.value,
        type: typeFilter.value,
        sort: sort.value,
        limit: pageSize,
        offset: page.value * pageSize,
      );
      assets.value = result.items;
      totalCount.value = result.total;
    } catch (e) {
      error.value = 'Failed to load media: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<MediaAsset> uploadFile(String fileName, Uint8List bytes,
      QuickImageMetadata metadata) async {
    final asset = await dataSource.uploadImage(fileName, bytes, metadata);
    await loadAssets();
    return asset;
  }

  Future<void> deleteAsset(String assetId) async {
    await dataSource.deleteMedia(assetId);
    if (selectedAssetId.value == assetId) {
      selectedAssetId.value = null;
    }
    await loadAssets();
  }

  MediaAsset? get selectedAsset {
    final id = selectedAssetId.value;
    if (id == null) return null;
    return assets.value.where((a) => a.assetId == id).firstOrNull;
  }

  int get totalPages => (totalCount.value / pageSize).ceil().clamp(1, 999);

  void dispose() {
    search.dispose();
    typeFilter.dispose();
    sort.dispose();
    page.dispose();
    isGridView.dispose();
    selectedAssetId.dispose();
    isLoading.dispose();
    error.dispose();
    assets.dispose();
    totalCount.dispose();
  }
}
