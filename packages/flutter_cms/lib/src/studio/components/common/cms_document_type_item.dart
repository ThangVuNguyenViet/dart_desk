import 'package:flutter/material.dart';
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A navigation item widget for a CmsDocumentType
class CmsDocumentTypeItem extends StatelessWidget {
  final CmsDocumentType documentType;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const CmsDocumentTypeItem({
    super.key,
    required this.documentType,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ShadCard(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : theme.colorScheme.muted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon ?? Icons.description,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(width: 8),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentType.title,
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.foreground,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
