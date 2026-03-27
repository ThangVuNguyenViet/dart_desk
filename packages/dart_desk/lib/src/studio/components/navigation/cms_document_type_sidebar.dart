import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:get_it/get_it.dart';

import '../../core/view_models/cms_view_model.dart';
import '../../router/studio_router.dart';
import '../../theme/spacing.dart';
import '../common/cms_collapse_bar.dart';
import '../common/cms_document_type_decoration.dart';
import '../common/cms_document_type_item.dart';

/// A sidebar widget that displays document type navigation items.
///
/// Supports expanded (icon + label + count) and collapsed (icon-only rail) modes.
/// Collapse state is driven by [CmsViewModel.sidebarCollapsed].
class CmsDocumentTypeSidebar extends StatelessWidget {
  final List<DocumentTypeDecoration> documentTypeDecorations;
  final Widget? header;
  final Widget? footer;

  const CmsDocumentTypeSidebar({
    super.key,
    required this.documentTypeDecorations,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = GetIt.I<CmsViewModel>();
    final isCollapsed = viewModel.sidebarCollapsed.watch(context);
    final currentSlug = viewModel.currentDocumentTypeSlug.watch(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: isCollapsed ? 48 : 180,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          right: BorderSide(
              color: theme.colorScheme.border.withValues(alpha: 0.5)),
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
                final isSelected =
                    currentSlug == decoration.documentType.name;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: DocumentTypeItem(
                    key: ValueKey(
                        'doc_type_${decoration.documentType.title}'),
                    documentType: decoration.documentType,
                    isSelected: isSelected,
                    icon: decoration.icon,
                    isCollapsed: isCollapsed,
                    onTap: () {
                      context.router.navigate(
                        DocumentTypeScreenRoute(
                          documentTypeSlug: decoration.documentType.name,
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          if (footer != null && !isCollapsed) footer!,
          CmsCollapseBar(
            isCollapsed: isCollapsed,
            onToggle: () =>
                viewModel.sidebarCollapsed.value = !isCollapsed,
          ),
        ],
      ),
    );
  }
}
