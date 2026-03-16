import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../providers/studio_provider.dart';
import '../../routes/document_type_route.dart';
import '../../routes/studio_coordinator.dart';
import '../../theme/spacing.dart';
import '../common/cms_document_type_decoration.dart';
import '../common/cms_document_type_item.dart';

/// A sidebar widget that displays document type navigation items.
///
/// Supports expanded (icon + label + count) and collapsed (icon-only rail) modes.
/// Collapse state is driven by [CmsViewModel.sidebarCollapsed].
class CmsDocumentTypeSidebar extends StatelessWidget {
  final List<CmsDocumentTypeDecoration> documentTypeDecorations;
  final StudioCoordinator coordinator;
  final Widget? header;
  final Widget? footer;

  const CmsDocumentTypeSidebar({
    super.key,
    required this.documentTypeDecorations,
    required this.coordinator,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = cmsViewModelProvider.of(context);
    final isCollapsed = viewModel.sidebarCollapsed.watch(context);
    final currentSlug = viewModel.currentDocumentTypeSlug.watch(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: isCollapsed ? 48 : 180,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          right: BorderSide(color: theme.colorScheme.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          if (header != null && !isCollapsed) header!,
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CmsSpacing.sm, CmsSpacing.md, CmsSpacing.sm, CmsSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CONTENT',
                  style: TextStyle(
                    fontSize: 9,
                    color: theme.colorScheme.mutedForeground,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? CmsSpacing.sm : CmsSpacing.sm,
                vertical: isCollapsed ? CmsSpacing.md : 0,
              ),
              children: documentTypeDecorations.map((decoration) {
                final isSelected = currentSlug == decoration.documentType.name;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: CmsDocumentTypeItem(
                    documentType: decoration.documentType,
                    isSelected: isSelected,
                    icon: decoration.icon,
                    isCollapsed: isCollapsed,
                    onTap: () {
                      coordinator.pushOrMoveToTop(
                        DocumentTypeRoute(decoration.documentType.name),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          if (footer != null && !isCollapsed) footer!,
          // Collapse/expand button
          GestureDetector(
            onTap: () => viewModel.sidebarCollapsed.value = !isCollapsed,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.all(CmsSpacing.sm),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.border.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: isCollapsed
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    FaIcon(
                      isCollapsed
                          ? FontAwesomeIcons.anglesRight
                          : FontAwesomeIcons.anglesLeft,
                      size: 12,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: CmsSpacing.sm),
                      Text(
                        'Collapse',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
