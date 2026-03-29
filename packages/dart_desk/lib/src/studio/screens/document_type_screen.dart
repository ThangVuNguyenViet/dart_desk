import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../config/cms_breakpoints.dart';
import '../core/view_models/cms_view_model.dart';
import '../router/studio_router.dart';
import '../screens/document_list.dart';
import '../theme/spacing.dart';
import 'document_editor.dart';
import 'document_preview.dart';

@RoutePage()
class DocumentTypeScreen extends StatelessWidget {
  const DocumentTypeScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
  });

  final String documentTypeSlug;

  Future<void> _deleteDocument(BuildContext context, {int? docId}) async {
    final viewModel = GetIt.I<CmsViewModel>();
    final toaster = ShadToaster.of(context);
    if (docId == null) return;

    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog(
        title: const Text('Delete document'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
        child: const Text(
          'This will permanently delete this document and all its versions. This cannot be undone.',
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final result = await viewModel.deleteDocument(docId);
      if (context.mounted) {
        if (result) {
          toaster
              .show(const ShadToast(description: Text('Document deleted')));
        } else {
          toaster.show(ShadToast.destructive(
              description: const Text('Failed to delete document')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        toaster.show(
            ShadToast.destructive(description: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = GetIt.I<CmsViewModel>();
    final docType = viewModel.currentDocumentType.watch(context);
    final breakpoint = ResponsiveBreakpoints.of(context);
    final isMobile = breakpoint.isMobile;
    final isDesktop = breakpoint.largerThan(CmsBreakpoints.tabletTag);

    if (docType == null) return const SizedBox.shrink();

    // Mobile: full-screen doc list (shell doesn't show it on mobile)
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            CmsSpacing.md, CmsSpacing.sm, CmsSpacing.md, 0),
        child: CmsDocumentListView(
          selectedDocumentType: docType,
          icon: FontAwesomeIcons.file,
          onOpenDocument: (documentId) {
            context.router.navigate(DocumentScreenRoute(
              documentTypeSlug: documentTypeSlug,
              documentId: documentId,
            ));
          },
          onDeleteDocument: (docId) =>
              _deleteDocument(context, docId: docId),
        ),
      );
    }

    final editor = Container(
      color: theme.colorScheme.background,
      child: CmsDocumentEditor(
        fields: docType.fields,
        title: docType.title,
      ),
    );

    // Desktop: preview + editor side by side
    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.border.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: DocumentPreview(docType: docType),
            ),
          ),
          Expanded(child: editor),
        ],
      );
    }

    // Tablet: editor only
    return editor;
  }
}
