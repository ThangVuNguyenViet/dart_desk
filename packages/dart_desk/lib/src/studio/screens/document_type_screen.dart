import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../components/common/cms_collapse_bar.dart';
import '../core/view_models/cms_view_model.dart';
import '../router/studio_router.dart';
import '../screens/document_screen.dart';
import '../theme/spacing.dart';
import 'document_list.dart';

@RoutePage()
class DocumentTypeScreen extends StatefulWidget {
  const DocumentTypeScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
  });

  final String documentTypeSlug;

  @override
  State<DocumentTypeScreen> createState() => _DocumentTypeScreenState();
}

class _DocumentTypeScreenState extends State<DocumentTypeScreen> {
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

    if (confirmed != true || !mounted) return;

    try {
      final result = await viewModel.deleteDocument(docId);
      if (mounted) {
        if (result) {
          toaster.show(const ShadToast(description: Text('Document deleted')));
        } else {
          toaster.show(ShadToast.destructive(
              description: const Text('Failed to delete document')));
        }
      }
    } catch (e) {
      if (mounted) {
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
    final isListVisible = viewModel.documentListVisible.watch(context);

    return Row(
      children: [
        // Collapsible document list
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isListVisible ? 220 : 0,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            border: Border(
              right: BorderSide(
                  color: theme.colorScheme.border.withValues(alpha: 0.5)),
            ),
          ),
          child: docType == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                      CmsSpacing.md, CmsSpacing.sm, CmsSpacing.md, 0),
                  child: CmsDocumentListView(
                    selectedDocumentType: docType,
                    icon: FontAwesomeIcons.file,
                    onOpenDocument: (documentId) {
                      context.router.navigate(DocumentScreenRoute(
                        documentTypeSlug: widget.documentTypeSlug,
                        documentId: documentId,
                      ));
                    },
                    onDeleteDocument: (docId) =>
                        _deleteDocument(context, docId: docId),
                  ),
                ),
        ),
        // Collapsed rail
        if (!isListVisible)
          Container(
            width: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              border: Border(
                right: BorderSide(
                    color: theme.colorScheme.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Column(
              children: [
                const Spacer(),
                CmsCollapseBar(
                  isCollapsed: true,
                  onToggle: () =>
                      viewModel.documentListVisible.value = true,
                ),
              ],
            ),
          ),
        // Empty editor state
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(CmsSpacing.xl),
              child: ShadCard(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(CmsSpacing.sm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(CmsBorderRadius.md),
                      ),
                      child: FaIcon(FontAwesomeIcons.pen,
                          size: 24, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: CmsSpacing.md),
                    Text(
                      'Document Editor',
                      style: theme.textTheme.large
                          .copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: CmsSpacing.md - CmsSpacing.sm),
                    Text(
                      'Select a document from the list to start editing',
                      style:
                          theme.textTheme.muted.copyWith(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
