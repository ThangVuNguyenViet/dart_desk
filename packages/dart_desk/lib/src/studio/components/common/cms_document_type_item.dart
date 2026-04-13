import 'package:flutter/material.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/spacing.dart';

/// A navigation item for a document type in the sidebar.
///
/// Supports expanded mode (icon + label) and collapsed mode (icon only with tooltip).
/// Uses solid Font Awesome icons when selected, regular when not.
class DocumentTypeItem extends StatelessWidget {
  final DocumentType documentType;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback? onTap;
  final IconData? icon;

  const DocumentTypeItem({
    super.key,
    required this.documentType,
    this.isSelected = false,
    this.isCollapsed = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final activeIcon = icon ?? FontAwesomeIcons.solidFile;
    final inactiveIcon = icon ?? FontAwesomeIcons.file;

    final item = GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.all(isCollapsed ? CmsSpacing.sm : CmsSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(CmsBorderRadius.md),
            border: isSelected
                ? Border(
                    left: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  )
                : null,
          ),
          child: isCollapsed
              ? Center(
                  child: FaIcon(
                    isSelected ? activeIcon : inactiveIcon,
                    size: 14,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.mutedForeground,
                  ),
                )
              : Row(
                  children: [
                    FaIcon(
                      isSelected ? activeIcon : inactiveIcon,
                      size: 14,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: CmsSpacing.sm),
                    Expanded(
                      child: Text(
                        documentType.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.foreground
                              : theme.colorScheme.mutedForeground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    if (isCollapsed) {
      return Tooltip(message: documentType.title, child: item);
    }

    return item;
  }
}
