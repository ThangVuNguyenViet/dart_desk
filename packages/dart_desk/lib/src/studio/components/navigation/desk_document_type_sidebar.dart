import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../core/view_models/desk_view_model.dart';
import '../../router/studio_router.dart';
import '../../theme/spacing.dart';
import '../common/desk_collapse_bar.dart';
import '../common/desk_document_type_decoration.dart';
import '../common/desk_document_type_item.dart';

/// A sidebar widget that displays document type navigation items.
///
/// Supports expanded (icon + label + count) and collapsed (icon-only rail) modes.
/// Collapse state is driven by [DeskViewModel.sidebarCollapsed].
class DeskDocumentTypeSidebar extends StatelessWidget {
  final List<DocumentTypeDecoration> documentTypeDecorations;
  final Widget? header;
  final Widget? footer;

  const DeskDocumentTypeSidebar({
    super.key,
    required this.documentTypeDecorations,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = GetIt.I<DeskViewModel>();
    final isCollapsed = viewModel.sidebarCollapsed.watch(context);
    final currentSlug = viewModel.currentDocumentTypeSlug.watch(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: isCollapsed ? 48 : 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        children: [
          if (header != null && !isCollapsed) header!,
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DeskSpacing.sm,
                DeskSpacing.md,
                DeskSpacing.sm,
                DeskSpacing.sm,
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
                horizontal: isCollapsed ? DeskSpacing.sm : DeskSpacing.sm,
                vertical: isCollapsed ? DeskSpacing.md : 0,
              ),
              children: documentTypeDecorations.map((decoration) {
                final isSelected = currentSlug == decoration.documentType.name;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: DocumentTypeItem(
                    key: ValueKey('doc_type_${decoration.documentType.title}'),
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
          DeskCollapseBar(
            isCollapsed: isCollapsed,
            onToggle: () => viewModel.sidebarCollapsed.value = !isCollapsed,
          ),
        ],
      ),
    );
  }
}
