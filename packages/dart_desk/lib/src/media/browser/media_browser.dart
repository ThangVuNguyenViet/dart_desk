import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../../data/cms_data_source.dart';
import '../../data/models/media_asset.dart';
import '../quick_metadata_extractor.dart';
import 'asset_detail_panel.dart';
import 'media_browser_state.dart';
import 'media_grid.dart';
import 'media_list_view.dart';
import 'media_toolbar.dart';

enum MediaBrowserMode { standalone, picker }

class MediaBrowser extends StatefulWidget {
  final DataSource dataSource;
  final MediaBrowserMode mode;
  final ValueChanged<MediaAsset>? onAssetSelected;
  final VoidCallback? onClose;

  const MediaBrowser({
    super.key,
    required this.dataSource,
    this.mode = MediaBrowserMode.standalone,
    this.onAssetSelected,
    this.onClose,
  });

  @override
  State<MediaBrowser> createState() => _MediaBrowserState();
}

class _MediaBrowserState extends State<MediaBrowser> {
  late final _state = MediaBrowserState(dataSource: widget.dataSource);
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _state.loadAssets();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      await _uploadBytes(image.name, bytes);
    } catch (e) {
      _state.error.value = 'Upload failed: $e';
    }
  }

  Future<void> _uploadBytes(String fileName, Uint8List bytes) async {
    final metadata = await QuickMetadataExtractor.extract(bytes);
    await _state.uploadFile(fileName, bytes, metadata);
  }

  Future<void> _handleDrop(PerformDropEvent event) async {
    final items = event.session.items;
    if (items.isEmpty) return;

    final reader = items.first.dataReader;
    if (reader == null) return;

    final completer = Completer<void>();
    reader.getFile(
      null,
      (file) async {
        try {
          final bytes = await file.readAll();
          final name = file.fileName ?? 'dropped_file';
          await _uploadBytes(name, bytes);
        } catch (e) {
          _state.error.value = 'Drop upload failed: $e';
        }
        completer.complete();
      },
      onError: (error) {
        _state.error.value = 'Failed to read dropped file: $error';
        completer.complete();
      },
    );
    await completer.future;
  }

  void _onAssetDoubleClick(MediaAsset asset) {
    if (widget.mode == MediaBrowserMode.picker) {
      widget.onAssetSelected?.call(asset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) => DropOperation.copy,
      onPerformDrop: _handleDrop,
      child: Column(
        key: const ValueKey('media_browser'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  widget.mode == MediaBrowserMode.picker
                      ? 'Select Media'
                      : 'Media Library',
                  style: theme.textTheme.h4,
                ),
                const Spacer(),
                ShadButton.outline(
                  size: ShadButtonSize.sm,
                  onPressed: _handleUpload,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(FontAwesomeIcons.cloudArrowUp, size: 14),
                      SizedBox(width: 6),
                      Text('Upload'),
                    ],
                  ),
                ),
                if (widget.onClose != null) ...[
                  const SizedBox(width: 8),
                  ShadButton.ghost(
                    size: ShadButtonSize.sm,
                    onPressed: widget.onClose,
                    child: const FaIcon(FontAwesomeIcons.xmark, size: 14),
                  ),
                ],
              ],
            ),
          ),

          // Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MediaToolbar(state: _state),
          ),

          // Error banner
          Watch((context) {
            final error = _state.error.watch(context);
            if (error == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.destructive.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                error,
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.destructive,
                ),
              ),
            );
          }),

          // Body
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grid or List
                Expanded(
                  flex: 2,
                  child: Watch((context) {
                    final isGrid = _state.isGridView.watch(context);
                    if (isGrid) {
                      return MediaGrid(
                        state: _state,
                        onDoubleClick: _onAssetDoubleClick,
                      );
                    }
                    return MediaListView(
                      state: _state,
                      onDoubleClick: _onAssetDoubleClick,
                    );
                  }),
                ),
                // Detail panel
                Watch((context) {
                  final selected = _state.selectedAssetId.watch(context);
                  final assets = _state.assets.watch(context);
                  if (selected == null) return const SizedBox.shrink();

                  final asset = assets
                      .where((a) => a.assetId == selected)
                      .firstOrNull;
                  if (asset == null) return const SizedBox.shrink();

                  return SizedBox(
                    width: 280,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: theme.colorScheme.border),
                        ),
                      ),
                      child: AssetDetailPanel(
                        asset: asset,
                        dataSource: widget.dataSource,
                        onDelete: () => _state.deleteAsset(asset.assetId),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Footer: pagination + picker select button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Pagination
                Watch((context) {
                  final currentPage = _state.page.watch(context);
                  final total = _state.totalCount.watch(context);
                  final totalPages = _state.totalPages;

                  return Row(
                    children: [
                      ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        onPressed: currentPage > 0
                            ? () {
                                _state.page.value = currentPage - 1;
                                _state.loadAssets();
                              }
                            : null,
                        child: const FaIcon(
                          FontAwesomeIcons.chevronLeft,
                          size: 12,
                        ),
                      ),
                      Text(
                        'Page ${currentPage + 1} of $totalPages ($total items)',
                        style: theme.textTheme.small,
                      ),
                      ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        onPressed: currentPage < totalPages - 1
                            ? () {
                                _state.page.value = currentPage + 1;
                                _state.loadAssets();
                              }
                            : null,
                        child: const FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 12,
                        ),
                      ),
                    ],
                  );
                }),
                const Spacer(),
                // Picker mode: Select button
                if (widget.mode == MediaBrowserMode.picker)
                  Watch((context) {
                    final selectedId = _state.selectedAssetId.watch(context);
                    final assets = _state.assets.watch(context);
                    final asset = selectedId != null
                        ? assets
                              .where((a) => a.assetId == selectedId)
                              .firstOrNull
                        : null;

                    return ShadButton(
                      size: ShadButtonSize.sm,
                      onPressed: asset != null
                          ? () => widget.onAssetSelected?.call(asset)
                          : null,
                      child: const Text('Select'),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
