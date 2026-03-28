import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../components/common/cms_collapse_bar.dart';
import '../components/common/cms_top_bar.dart';
import '../components/navigation/cms_document_type_sidebar.dart';
import '../config/studio_config.dart';
import '../core/view_models/cms_view_model.dart';
import '../providers/studio_provider.dart';
import '../router/studio_router.dart';
import '../screens/document_list.dart';
import '../theme/spacing.dart';

@RoutePage()
class StudioShellScreen extends StatefulWidget {
  const StudioShellScreen({super.key});

  @override
  State<StudioShellScreen> createState() => _StudioShellScreenState();
}

class _StudioShellScreenState extends State<StudioShellScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect to the first document type on initial bare-root load.
    // Scheduled after the first frame so StudioProvider has registered
    // CmsViewModel and the router has settled on its initial route.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final params = context.router.topRoute.params;
      if (params.optString('documentTypeSlug') == null) {
        final config = GetIt.I<StudioConfig>();
        if (config.documentTypes.isNotEmpty) {
          context.router.navigate(DocumentTypeScreenRoute(
            documentTypeSlug: config.documentTypes.first.name,
          ));
        }
      }
    });
  }

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
    final config = GetIt.I<StudioConfig>();

    return StudioProvider(
      dataSource: config.dataSource,
      documentTypes: config.documentTypes,
      child: Builder(
        builder: (context) {
          final isMobile = ResponsiveBreakpoints.of(context).isMobile;

          return Column(
            children: [
              const CmsTopBar(),
              const Divider(height: 1),
              Expanded(
                child: isMobile
                    ? AutoRouter()
                    : _buildDesktopLayout(context, config),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, StudioConfig config) {
    final theme = ShadTheme.of(context);
    final viewModel = GetIt.I<CmsViewModel>();
    final docType = viewModel.currentDocumentType.watch(context);
    final isListVisible = viewModel.documentListVisible.watch(context);
    final docTypeSlug = viewModel.currentDocumentTypeSlug.watch(context);

    return Row(
      children: [
        CmsDocumentTypeSidebar(
          documentTypeDecorations: config.documentTypeDecorations,
          footer: ShadButton.ghost(
            key: const ValueKey('sidebar_media_button'),
            onPressed: () =>
                context.router.navigate(const MediaScreenRoute()),
            child: const Row(
              children: [
                FaIcon(FontAwesomeIcons.images, size: 14),
                SizedBox(width: CmsSpacing.sm),
                Text('Media Library'),
              ],
            ),
          ),
        ),
        // Collapsible doc list panel
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
                    onOpenDocument: (documentId) => context.router.navigate(
                      DocumentScreenRoute(
                        documentTypeSlug: docTypeSlug ?? docType.name,
                        documentId: documentId,
                      ),
                    ),
                    onDeleteDocument: (docId) =>
                        _deleteDocument(context, docId: docId),
                  ),
                ),
        ),
        // Collapsed rail (when list hidden)
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
        // Route content: preview + editor
        Expanded(child: AutoRouter()),
      ],
    );
  }
}
