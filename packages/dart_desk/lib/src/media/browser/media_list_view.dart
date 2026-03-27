import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/media_asset.dart';
import 'media_browser_state.dart';

class MediaListView extends StatelessWidget {
  final MediaBrowserState state;
  final ValueChanged<MediaAsset>? onDoubleClick;

  const MediaListView({super.key, required this.state, this.onDoubleClick});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final asyncState = state.assetsData.watch(context);
    final assets = asyncState.value?.items ?? [];
    final selectedId = state.selectedAssetId.watch(context);

    if (asyncState.isLoading && assets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (assets.isEmpty) {
      return Center(
        child: Text('No media found', style: theme.textTheme.muted),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        final isSelected = asset.assetId == selectedId;

        return GestureDetector(
          key: ValueKey('media_list_item_${asset.assetId}'),
          onTap: () => state.selectedAssetId.value = asset.assetId,
          onDoubleTap: onDoubleClick != null
              ? () => onDoubleClick!(asset)
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : null,
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                // Thumbnail
                SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: asset.isImage
                        ? Image.network(
                            asset.publicUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: theme.colorScheme.muted,
                              child: const Icon(Icons.broken_image, size: 20),
                            ),
                          )
                        : Container(
                            color: theme.colorScheme.muted,
                            child: const Icon(
                              Icons.insert_drive_file,
                              size: 20,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${asset.mimeType}  ·  ${asset.fileSizeFormatted}  ·  ${asset.width}×${asset.height}',
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                // Date
                Text(
                  _formatDate(asset.createdAt),
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
