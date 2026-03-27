import 'package:auto_route/auto_route.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../components/common/cms_collapse_bar.dart';
import '../core/view_models/cms_document_view_model.dart';
import '../core/view_models/cms_view_model.dart';
import '../router/studio_router.dart';
import '../theme/spacing.dart';
import 'document_editor.dart';
import 'document_list.dart';

@RoutePage()
class DocumentScreen extends StatefulWidget {
  const DocumentScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
    @PathParam('documentId') required this.documentId,
  });

  final String documentTypeSlug;
  final String documentId;

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
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

  Widget _buildPreview(
    BuildContext context,
    ShadThemeData theme,
    CmsViewModel viewModel,
    DocumentType docType,
  ) {
    final documentViewModel = GetIt.I<CmsDocumentViewModel>();
    final edited = documentViewModel.editedData.watch(context);

    Map<String, dynamic> data;
    if (edited.isNotEmpty) {
      data = edited;
    } else {
      final versionId = viewModel.selectedVersionId.value;
      final defaultData = docType.defaultValue?.toMap() ?? {};
      data = defaultData;

      if (versionId != null) {
        final versionState = viewModel.documentDataContainer(versionId).value;
        data = versionState.map<Map<String, dynamic>>(
          loading: () => defaultData,
          error: (_, _) => defaultData,
          data: (version) => version?.data ?? defaultData,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(CmsSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREVIEW',
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.mutedForeground,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: CmsSpacing.md),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CmsBorderRadius.lg),
              ),
              clipBehavior: Clip.antiAlias,
              child: docType.builder(data),
            ),
          ),
        ],
      ),
    );
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
        // Editor + Preview split
        if (docType != null)
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.card,
                      border: Border(
                        right: BorderSide(
                          color: theme.colorScheme.border
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: _buildPreview(context, theme, viewModel, docType),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: theme.colorScheme.background,
                    child: CmsDocumentEditor(
                      fields: docType.fields,
                      title: docType.title,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
