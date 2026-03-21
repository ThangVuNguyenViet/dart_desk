import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/media_asset.dart';
import 'media_browser_state.dart';

class MediaGrid extends StatelessWidget {
  final MediaBrowserState state;
  final ValueChanged<MediaAsset>? onDoubleClick;

  const MediaGrid({super.key, required this.state, this.onDoubleClick});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final assets = state.assets.watch(context);
    final selectedId = state.selectedAssetId.watch(context);
    final loading = state.isLoading.watch(context);

    if (loading && assets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (assets.isEmpty) {
      return Center(
        child: Text(
          'No media found',
          style: theme.textTheme.muted,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        final isSelected = asset.assetId == selectedId;

        return GestureDetector(
          key: ValueKey('media_grid_item_${asset.assetId}'),
          onTap: () => state.selectedAssetId.value = asset.assetId,
          onDoubleTap:
              onDoubleClick != null ? () => onDoubleClick!(asset) : null,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // BlurHash placeholder color
                  Container(color: _colorFromBlurHash(asset.blurHash)),
                  // Actual image
                  if (asset.isImage)
                    Image.network(
                      asset.publicUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.broken_image,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            size: 32,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              asset.fileName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.small,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Filename overlay at bottom
                  if (asset.isImage)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        color: Colors.black54,
                        child: Text(
                          asset.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Derive a rough dominant color from a blurHash string.
  static const _base83Chars =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#\$%*+,-.:;=?@[]^_{|}~';

  Color _colorFromBlurHash(String hash) {
    if (hash.length < 6) return Colors.grey;
    try {
      var value = 0;
      for (final c in hash.substring(2, 6).codeUnits) {
        final idx = _base83Chars.indexOf(String.fromCharCode(c));
        if (idx == -1) return Colors.grey;
        value = value * 83 + idx;
      }
      return Color.fromARGB(
          255, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF);
    } catch (_) {
      return Colors.grey;
    }
  }
}
