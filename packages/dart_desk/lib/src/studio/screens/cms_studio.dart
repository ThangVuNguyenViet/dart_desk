import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../media/browser/media_browser.dart';
import '../components/common/cms_collapse_bar.dart';
import '../core/view_models/cms_view_model.dart';
import '../providers/studio_provider.dart';
import '../routes/document_route.dart';
import '../routes/media_route.dart';
import '../routes/studio_coordinator.dart';
import '../theme/spacing.dart';
import 'document_editor.dart';
import 'document_list.dart';

class CmsStudio extends StatefulWidget {
  final StudioCoordinator coordinator;
  final Widget sidebar;

  const CmsStudio({
    super.key,
    required this.coordinator,
    required this.sidebar,
  });

  @override
  State<CmsStudio> createState() => _CmsStudioState();
}

class _CmsStudioState extends State<CmsStudio> {
  Future<void> _deleteDocument(BuildContext context, {int? docId}) async {
    final viewModel = cmsViewModelProvider.of(context);
    final documentViewModel = documentViewModelProvider.of(context);
    final toaster = ShadToaster.of(context);
    docId ??= documentViewModel.documentId.value;

    if (docId == null) return;

    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Delete document'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.pop(context, true),
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
          toaster.show(
            ShadToast.destructive(
              description: const Text('Failed to delete document'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        toaster.show(
          ShadToast.destructive(description: Text('Failed to delete: $e')),
        );
      }
    }
  }

  Widget _buildEditorPreview(
    BuildContext context,
    ShadThemeData theme,
    CmsViewModel viewModel,
  ) {
    final docType = viewModel.currentDocumentType.value;

    if (docType == null) {
      return _buildEmptyState(
        theme: theme,
        icon: FontAwesomeIcons.pen,
        title: 'Document Editor',
        description: 'Select a document type from the sidebar to start editing',
      );
    }

    // 50/50 split initially. An adjustable divider can be added as a follow-up.
    return Row(
      children: [
        // Preview panel
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
            child: _buildPreview(context, theme, viewModel, docType),
          ),
        ),
        // Editor panel
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
    );
  }

  Widget _buildPreview(
    BuildContext context,
    ShadThemeData theme,
    CmsViewModel viewModel,
    DocumentType docType,
  ) {
    final documentViewModel = documentViewModelProvider.of(context);
    final edited = documentViewModel.editedData.watch(context);

    // Prefer live editedData; fall back to saved version data
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

  /// Helper method to build consistent empty states
  Widget _buildEmptyState({
    required ShadThemeData theme,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: ShadCard(
        width: 320,
        child: Padding(
          padding: const EdgeInsets.all(CmsSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(CmsSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(CmsBorderRadius.md),
                ),
                child: FaIcon(icon, size: 24, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: CmsSpacing.md),
              Text(
                title,
                style: theme.textTheme.large.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CmsSpacing.md - CmsSpacing.sm),
              Text(
                description,
                style: theme.textTheme.muted.copyWith(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = cmsViewModelProvider.of(context);

    final isListVisible = viewModel.documentListVisible.watch(context);
    final docType = viewModel.currentDocumentType.watch(context);

    // When on the media route, render standalone MediaBrowser
    final isMediaRoute =
        widget.coordinator.studioStack.activeRoute is MediaRoute;
    if (isMediaRoute) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Row(
          children: [
            widget.sidebar,
            Expanded(
              child: MediaBrowser(
                dataSource: widget.coordinator.dataSource,
                mode: MediaBrowserMode.standalone,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Row(
        children: [
          // Sidebar (already handles its own width/collapse)
          widget.sidebar,
          // Document list (collapsible via header chevron)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isListVisible ? 220 : 0,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              border: Border(
                right: BorderSide(
                  color: theme.colorScheme.border.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: docType == null
                ? _buildEmptyState(
                    theme: theme,
                    icon: FontAwesomeIcons.folderOpen,
                    title: 'Documents',
                    description:
                        'Select a document type to see available documents',
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(
                      CmsSpacing.md,
                      CmsSpacing.sm,
                      CmsSpacing.md,
                      0,
                    ),
                    child: CmsDocumentListView(
                      selectedDocumentType: docType,
                      icon: FontAwesomeIcons.file,
                      onOpenDocument: (documentId) {
                        widget.coordinator.pushOrMoveToTop(
                          DocumentRoute(docType.name, documentId),
                        );
                      },
                      onDeleteDocument: (docId) =>
                          _deleteDocument(context, docId: docId),
                    ),
                  ),
          ),
          // Collapsed document list rail (matching sidebar collapsed style)
          if (!isListVisible)
            Container(
              width: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.border.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  CmsCollapseBar(
                    isCollapsed: true,
                    onToggle: () => viewModel.documentListVisible.value = true,
                  ),
                ],
              ),
            ),
          // Editor + Preview split
          Expanded(child: _buildEditorPreview(context, theme, viewModel)),
        ],
      ),
    );
  }
}
