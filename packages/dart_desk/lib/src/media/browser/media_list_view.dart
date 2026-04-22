import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/media_asset.dart';
import 'asset_delete_confirm_dialog.dart';
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
        return _MediaRow(
          asset: asset,
          state: state,
          onDoubleClick: onDoubleClick,
        );
      },
    );
  }
}

class _MediaRow extends StatefulWidget {
  final MediaAsset asset;
  final MediaBrowserState state;
  final ValueChanged<MediaAsset>? onDoubleClick;

  const _MediaRow({
    required this.asset,
    required this.state,
    this.onDoubleClick,
  });

  @override
  State<_MediaRow> createState() => _MediaRowState();
}

class _MediaRowState extends State<_MediaRow> {
  bool _hovered = false;

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _handleDelete() async {
    await widget.state.confirmAndDelete(
      assetId: widget.asset.assetId,
      confirm: (usageCount) async {
        if (!mounted) return false;
        final result = await showShadDialog<bool>(
          context: context,
          builder: (_) => AssetDeleteConfirmDialog(
            asset: widget.asset,
            usageCount: usageCount,
          ),
        );
        return result ?? false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final asset = widget.asset;
    final selectedId = widget.state.selectedAssetId.watch(context);
    final isSelected = asset.assetId == selectedId;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        key: ValueKey('media_list_item_${asset.assetId}'),
        onTap: () => widget.state.selectedAssetId.value = asset.assetId,
        onDoubleTap: widget.onDoubleClick != null
            ? () => widget.onDoubleClick!(asset)
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
              // Trash button (hover-revealed)
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: _hovered ? 1.0 : 0.0,
                child: ShadTooltip(
                  builder: (_) => const Text('Delete'),
                  child: ShadIconButton.ghost(
                    key: ValueKey('media_list_trash_${widget.asset.assetId}'),
                    icon: const FaIcon(FontAwesomeIcons.trash, size: 14),
                    onPressed: _handleDelete,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
