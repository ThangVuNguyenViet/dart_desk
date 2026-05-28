import 'dart:typed_data';

import 'package:signals/signals.dart';

import '../../data/desk_data_source.dart';
import '../../data/models/image_types.dart';
import '../../data/models/media_asset.dart';
import '../../data/models/media_page.dart';

class MediaBrowserState {
  final DataSource dataSource;

  // Filter/search state
  final search = signal('', options: SignalOptions(name: 'search'));
  final typeFilter = signal(MediaTypeFilter.all, options: SignalOptions(name: 'typeFilter'));
  final sort = signal(MediaSort.dateDesc, options: SignalOptions(name: 'sort'));
  final page = signal(0, options: SignalOptions(name: 'page'));
  final int pageSize;

  // View state
  final isGridView = signal(true, options: SignalOptions(name: 'isGridView'));
  final selectedAssetId = signal<String?>(null, options: SignalOptions(name: 'selectedAssetId'));

  // Data — reactive: auto-reloads when filter signals change
  late final assetsData = futureSignal<MediaPage>(
    () => dataSource.listMedia(
      search: search.value.isEmpty ? null : search.value,
      type: typeFilter.value,
      sort: sort.value,
      limit: pageSize,
      offset: page.value * pageSize,
    ),
    options: AsyncSignalOptions(dependencies: [search, typeFilter, sort, page], name: 'assetsData'),
  );

  MediaBrowserState({
    required this.dataSource,
    this.pageSize = 24,
    MediaTypeFilter? initialTypeFilter,
  }) {
    if (initialTypeFilter != null) typeFilter.value = initialTypeFilter;
  }

  Future<MediaAsset> uploadFile(String fileName, Uint8List bytes) async {
    final asset = await dataSource.uploadImage(fileName, bytes);
    assetsData.reload();
    return asset;
  }

  Future<void> deleteAsset(String assetId) async {
    await dataSource.deleteMedia(assetId);
    if (selectedAssetId.value == assetId) {
      selectedAssetId.value = null;
    }
    assetsData.reload();
  }

  /// Fetches the usage count for [assetId], then invokes [confirm] with that
  /// count. If [confirm] resolves to `true`, deletes the asset via [deleteAsset].
  /// Returns `true` iff a deletion actually occurred.
  Future<bool> confirmAndDelete({
    required String assetId,
    required Future<bool> Function(int usageCount) confirm,
  }) async {
    final usageCount = await dataSource.getMediaUsageCount(assetId);
    final shouldDelete = await confirm(usageCount);
    if (!shouldDelete) return false;
    await deleteAsset(assetId);
    return true;
  }

  MediaAsset? get selectedAsset {
    final id = selectedAssetId.value;
    if (id == null) return null;
    return assetsData.value.value?.items
        .where((a) => a.assetId == id)
        .firstOrNull;
  }

  int get totalPages =>
      ((assetsData.value.value?.total ?? 0) / pageSize).ceil().clamp(1, 999);

  void dispose() {
    search.dispose();
    typeFilter.dispose();
    sort.dispose();
    page.dispose();
    isGridView.dispose();
    selectedAssetId.dispose();
    assetsData.dispose();
  }
}