import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../providers/studio_provider.dart';
import '../routes/document_route.dart';
import '../routes/studio_coordinator.dart';
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
  Widget _buildEditor() {
    final theme = ShadTheme.of(context);
    final cmsViewModel = cmsViewModelProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(left: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Watch((context) {
        final docType = cmsViewModel.currentDocumentType.value;
        if (docType == null) {
          return _buildEmptyState(
            icon: Icons.edit,
            title: 'Document Editor',
            description:
                'Select a document type from the sidebar to start editing',
          );
        }

        // Build document editor with compact spacing for web
        return CmsDocumentEditor(fields: docType.fields, title: docType.title);
      }),
    );
  }

  Widget _buildContentPreview() {
    final theme = ShadTheme.of(context);
    final viewModel = cmsViewModelProvider.of(context);
    final documentViewModel = documentViewModelProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(left: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Watch((context) {
        final docType = viewModel.currentDocumentType.value;

        // No document type → empty view
        if (docType == null) {
          return _buildEmptyState(
            icon: Icons.visibility,
            title: 'Content Preview',
            description:
                'Select a document type from the sidebar to see preview',
          );
        }

        // Prefer live editedData from the editor; fall back to saved version
        final edited = documentViewModel.editedData.value;
        if (edited.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: docType.builder(edited),
          );
        }

        // Fall back to saved version data
        final defaultData = docType.defaultValue?.toMap() ?? {};
        Map<String, dynamic> data = defaultData;

        final versionId = viewModel.selectedVersionId.watch(context);
        if (versionId != null) {
          final versionState = viewModel.documentDataContainer(versionId).value;
          data = versionState.map<Map<String, dynamic>>(
            loading: () => defaultData,
            error: (_, __) => defaultData,
            data: (version) => version?.data ?? defaultData,
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: docType.builder(data),
        );
      }),
    );
  }

  Widget _buildDocumentsList() {
    final theme = ShadTheme.of(context);
    final viewModel = cmsViewModelProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(right: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Watch((context) {
        final docType = viewModel.currentDocumentType.value;

        if (docType == null) {
          return _buildEmptyState(
            icon: Icons.folder_open,
            title: 'Documents',
            description: 'Select a document type to see available documents',
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: CmsDocumentListView(
            selectedDocumentType: docType,
            icon: Icons.description,
            onOpenDocument: (documentId) {
              widget.coordinator.pushOrMoveToTop(
                DocumentRoute(docType.name, documentId),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildSidebar() {
    final theme = ShadTheme.of(context);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.15),
        border: Border(right: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: widget.sidebar,
      ),
    );
  }

  /// Helper method to build consistent empty states
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    bool showProgress = false,
  }) {
    final theme = ShadTheme.of(context);

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: ShadCard(
          width: 320,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 24, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.large.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.muted.copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                if (showProgress) ...[
                  const SizedBox(height: 12),
                  const ShadProgress(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Container(
        decoration: BoxDecoration(color: theme.colorScheme.background),
        child: ResizableContainer(
          direction: Axis.horizontal,
          children: [
            // Sidebar (fixed, non-resizable)
            ResizableChild(
              size: ResizableSize.ratio(0.2),
              child: _buildSidebar(),
            ),

            // Documents list panel (resizable)
            ResizableChild(
              size: ResizableSize.ratio(0.2),
              child: _buildDocumentsList(),
            ),

            // Content preview panel (resizable)
            ResizableChild(
              size: ResizableSize.ratio(0.4),
              child: _buildContentPreview(),
            ),

            // Document editor panel (resizable)
            ResizableChild(
              size: ResizableSize.ratio(0.2),
              child: _buildEditor(),
            ),
          ],
        ),
      ),
    );
  }
}
