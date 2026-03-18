import 'package:flutter/material.dart';
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/document_version.dart';
import '../components/common/cms_toolbar_ribbon.dart';
import '../core/view_models/cms_view_model.dart';
import '../providers/studio_provider.dart';
import '../routes/document_route.dart';
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
  Future<void> _saveDocument(BuildContext context) async {
    final viewModel = cmsViewModelProvider.of(context);
    final documentViewModel = documentViewModelProvider.of(context);
    final toaster = ShadToaster.of(context);
    final docId = documentViewModel.documentId.value;
    final data = documentViewModel.editedData.value;

    try {
      if (docId != null) {
        await viewModel.updateDocumentData(data);
      }

      if (mounted) {
        toaster.show(
          const ShadToast(description: Text('Document saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        toaster.show(
          ShadToast.destructive(
            description: Text('Failed to save: $e'),
          ),
        );
      }
    }
  }

  Future<void> _discardDocument(BuildContext context) async {
    final viewModel = cmsViewModelProvider.of(context);
    final documentViewModel = documentViewModelProvider.of(context);
    final versionId = viewModel.selectedVersionId.value;

    if (versionId != null) {
      final versionState = viewModel.documentDataContainer(versionId).value;
      if (versionState is AsyncData && versionState.value?.data != null) {
        documentViewModel.editedData.value =
            Map<String, dynamic>.from(versionState.value!.data!);
      }
    } else {
      final docType = viewModel.currentDocumentType.value;
      documentViewModel.editedData.value = docType?.defaultValue?.toMap() ?? {};
    }
  }

  Future<void> _deleteDocument(BuildContext context) async {
    final viewModel = cmsViewModelProvider.of(context);
    final documentViewModel = documentViewModelProvider.of(context);
    final toaster = ShadToaster.of(context);
    final docId = documentViewModel.documentId.value;

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
          toaster.show(
            const ShadToast(description: Text('Document deleted')),
          );
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
          ShadToast.destructive(
            description: Text('Failed to delete: $e'),
          ),
        );
      }
    }
  }

  Widget _buildDocumentsList(
    BuildContext context,
    ShadThemeData theme,
    CmsViewModel viewModel,
  ) {
    final docType = viewModel.currentDocumentType.value;

    return Container(
      width: 220,
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
              description: 'Select a document type to see available documents',
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(
                CmsSpacing.md, CmsSpacing.sm, CmsSpacing.md, CmsSpacing.md,
              ),
              child: CmsDocumentListView(
                selectedDocumentType: docType,
                icon: FontAwesomeIcons.file,
                onOpenDocument: (documentId) {
                  widget.coordinator.pushOrMoveToTop(
                    DocumentRoute(docType.name, documentId),
                  );
                },
              ),
            ),
    );
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
    CmsDocumentType docType,
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
          error: (_, __) => defaultData,
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
                style:
                    theme.textTheme.large.copyWith(fontWeight: FontWeight.w600),
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

  DocumentVersionStatus _deriveToolbarStatus(
    BuildContext context,
    CmsViewModel viewModel,
  ) {
    final versionId = viewModel.selectedVersionId.watch(context);
    if (versionId == null) return DocumentVersionStatus.draft;

    final versionState =
        viewModel.documentDataContainer(versionId).watch(context);
    return versionState.map(
      loading: () => DocumentVersionStatus.draft,
      error: (_, __) => DocumentVersionStatus.draft,
      data: (version) => version?.status ?? DocumentVersionStatus.draft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = cmsViewModelProvider.of(context);
    final documentViewModel = documentViewModelProvider.of(context);

    final isListVisible = viewModel.documentListVisible.watch(context);
    final isSidebarCollapsed = viewModel.sidebarCollapsed.watch(context);
    final docType = viewModel.currentDocumentType.watch(context);
    final isSaving = viewModel.isSaving.watch(context);
    final editedData = documentViewModel.editedData.watch(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // Toolbar ribbon
          CmsToolbarRibbon(
            sidebarVisible: !isSidebarCollapsed,
            onToggleSidebar: () =>
                viewModel.sidebarCollapsed.value = !isSidebarCollapsed,
            listVisible: isListVisible,
            onToggleList: () =>
                viewModel.documentListVisible.value = !isListVisible,
            documentStatus: docType != null
                ? _deriveToolbarStatus(context, viewModel)
                : null,
            hasUnsavedChanges: editedData.isNotEmpty && docType != null,
            isSaving: isSaving,
            onSave: () => _saveDocument(context),
            onDiscard: () => _discardDocument(context),
            onDelete: () => _deleteDocument(context),
          ),
          // Main content area
          Expanded(
            child: Row(
              children: [
                // Sidebar (already handles its own width/collapse)
                widget.sidebar,
                // Document list (collapsible)
                if (isListVisible)
                  _buildDocumentsList(context, theme, viewModel),
                // Editor + Preview split
                Expanded(
                    child: _buildEditorPreview(context, theme, viewModel)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
