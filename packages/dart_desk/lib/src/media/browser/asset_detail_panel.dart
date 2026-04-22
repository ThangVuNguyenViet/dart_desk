import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/cms_data_source.dart';
import '../../data/models/image_types.dart';
import '../../data/models/media_asset.dart';

class AssetDetailPanel extends StatefulWidget {
  final MediaAsset asset;
  final DataSource dataSource;
  final VoidCallback? onDelete;

  const AssetDetailPanel({
    super.key,
    required this.asset,
    required this.dataSource,
    this.onDelete,
  });

  @override
  State<AssetDetailPanel> createState() => _AssetDetailPanelState();
}

class _AssetDetailPanelState extends State<AssetDetailPanel> {
  late MediaAsset _asset = widget.asset;
  int _usageCount = 0;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadUsage();
    _startPollingIfPending();
  }

  @override
  void didUpdateWidget(AssetDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.assetId != widget.asset.assetId) {
      _asset = widget.asset;
      _loadUsage();
      _pollTimer?.cancel();
      _startPollingIfPending();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPollingIfPending() {
    if (_asset.metadataStatus == MediaAssetMetadataStatus.pending) {
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
        final refreshed = await widget.dataSource.getMediaAsset(_asset.assetId);
        if (refreshed != null && mounted) {
          setState(() => _asset = refreshed);
          if (refreshed.metadataStatus != MediaAssetMetadataStatus.pending) {
            _pollTimer?.cancel();
          }
        }
      });
    }
  }

  Future<void> _loadUsage() async {
    final count = await widget.dataSource.getMediaUsageCount(_asset.assetId);
    if (mounted) setState(() => _usageCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.colorScheme.border)),
        color: theme.colorScheme.background,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Preview
          if (_asset.isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                _asset.publicUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: 200,
                errorBuilder: (_, _, _) => Container(
                  height: 200,
                  color: theme.colorScheme.muted,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Filename
          Text(
            _asset.fileName,
            style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // Metadata rows
          _metadataRow(theme, 'Dimensions', '${_asset.width}×${_asset.height}'),
          _metadataRow(theme, 'File size', _asset.fileSizeFormatted),
          _metadataRow(theme, 'Type', _asset.mimeType),
          _metadataRow(
            theme,
            'Uploaded',
            '${_asset.createdAt.year}-${_asset.createdAt.month.toString().padLeft(2, '0')}-${_asset.createdAt.day.toString().padLeft(2, '0')}',
          ),
          _metadataRow(theme, 'Usage', '$_usageCount document(s)'),

          const SizedBox(height: 8),

          // Metadata status indicator
          Row(
            children: [
              Text(
                'Metadata: ',
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              _metadataStatusBadge(theme),
            ],
          ),

          // Palette colors
          if (_asset.palette != null) ...[
            const SizedBox(height: 12),
            Text(
              'Palette',
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _paletteCircle(theme,_asset.palette!.dominant),
                if (_asset.palette!.vibrant != null)
                  _paletteCircle(theme,_asset.palette!.vibrant!),
                if (_asset.palette!.muted != null)
                  _paletteCircle(theme,_asset.palette!.muted!),
                if (_asset.palette!.darkMuted != null)
                  _paletteCircle(theme,_asset.palette!.darkMuted!),
              ],
            ),
          ],

          // Location
          if (_asset.location != null) ...[
            const SizedBox(height: 8),
            _metadataRow(
              theme,
              'Location',
              '${_asset.location!.lat.toStringAsFixed(4)}, ${_asset.location!.lng.toStringAsFixed(4)}',
            ),
          ],

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: ShadButton.destructive(
                  size: ShadButtonSize.sm,
                  onPressed: widget.onDelete,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.trash, size: 12),
                      const SizedBox(width: 4),
                      Text(_usageCount > 0 ? 'In use' : 'Delete'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_usageCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Cannot delete: referenced by $_usageCount document(s)',
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _metadataRow(ShadThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.small)),
        ],
      ),
    );
  }

  Widget _metadataStatusBadge(ShadThemeData theme) {
    return switch (_asset.metadataStatus) {
      MediaAssetMetadataStatus.pending => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Processing...',
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
      MediaAssetMetadataStatus.complete => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text('Complete', style: theme.textTheme.small),
        ],
      ),
      MediaAssetMetadataStatus.failed => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, size: 14, color: theme.colorScheme.destructive),
          const SizedBox(width: 4),
          Text(
            'Failed',
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.destructive,
            ),
          ),
        ],
      ),
    };
  }

  Widget _paletteCircle(ShadThemeData theme, PaletteColor color) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Tooltip(
        message: color.hex,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, color.r, color.g, color.b),
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.foreground, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.foreground.withValues(alpha: 0.15),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
