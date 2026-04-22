import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/models/media_asset.dart';

class AssetDeleteConfirmDialog extends StatelessWidget {
  final MediaAsset asset;
  final int usageCount;

  const AssetDeleteConfirmDialog({
    super.key,
    required this.asset,
    required this.usageCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final inUse = usageCount > 0;

    return ShadDialog(
      title: Text(inUse ? 'Cannot delete' : 'Delete asset?'),
      description: Text(
        inUse
            ? 'In use by $usageCount document(s). Remove references before '
                'deleting.'
            : "This can't be undone.",
      ),
      actions: inUse
          ? [
              ShadButton.outline(
                child: const Text('Close'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ]
          : [
              ShadButton.outline(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ShadButton.destructive(
                child: const Text('Delete'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: asset.isImage
                  ? Image.network(
                      asset.publicUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: theme.colorScheme.muted,
                        child: const Icon(Icons.image_outlined, size: 24),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.muted,
                      child: const Icon(Icons.insert_drive_file, size: 24),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              asset.fileName,
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
