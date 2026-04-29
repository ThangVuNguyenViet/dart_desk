import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/document_list.dart';
import '../components/common/desk_collapse_bar.dart';
import '../components/common/desk_top_bar.dart';
import '../components/navigation/desk_document_type_sidebar.dart';
import '../config/desk_breakpoints.dart';
import '../config/studio_config.dart';
import '../core/view_models/desk_view_model.dart';
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
  EffectCleanup? _autoSelectCleanup;

  @override
  void initState() {
    super.initState();
    final viewModel = GetIt.I<DeskViewModel>();
    // Auto-navigate to the default (or first) document whenever a doc type is
    // selected but no document is. Desktop-only — on mobile the document list
    // is the screen itself, so jumping past it would be hostile.
    _autoSelectCleanup = effect(() {
      final slug = viewModel.currentDocumentTypeSlug.value;
      final docId = viewModel.currentDocumentId.value;
      if (slug == null || docId != null) return;
      final state = viewModel.documentsContainer(slug).value;
      if (state is! AsyncData<DocumentList>) return;
      final docs = state.value.documents;
      if (docs.isEmpty) return;
      final picked =
          docs.firstWhereOrNull((d) => d.isDefault) ?? docs.first;
      final id = picked.id;
      if (id == null) return;
      untracked(() {
        if (!mounted) return;
        final isDesktop = ResponsiveBreakpoints.of(
          context,
        ).largerThan(DeskBreakpoints.tabletTag);
        if (!isDesktop) return;
        context.router.navigate(
          DocumentScreenRoute(documentTypeSlug: slug, documentId: id),
        );
      });
    });
  }

  @override
  void didChangeDependencies() {
    final params = context.router.topRoute.params;
    if (params.optString('documentTypeSlug') == null) {
      final config = GetIt.I<StudioConfig>();
      if (config.documentTypes.isNotEmpty) {
        context.router.navigate(
          DocumentTypeScreenRoute(
            documentTypeSlug: config.documentTypes.first.name,
          ),
        );
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _autoSelectCleanup?.call();
    super.dispose();
  }

  Future<void> _deleteDocument(BuildContext context, {String? docId}) async {
    final viewModel = GetIt.I<DeskViewModel>();
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
      final result = await viewModel.deleteDocument.run(docId);
      if (mounted && result != null) {
        if (result.deleted) {
          toaster.show(const ShadToast(description: Text('Document deleted')));
          if (result.newDefault != null) {
            toaster.show(
              ShadToast(
                description: Text(
                  '"${result.newDefault!.title}" is now the default.',
                ),
              ),
            );
          }
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
              const DeskTopBar(),
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
    final viewModel = GetIt.I<DeskViewModel>();
    final docType = viewModel.currentDocumentType.watch(context);
    final isListVisible = viewModel.documentListVisible.watch(context);
    final docTypeSlug = viewModel.currentDocumentTypeSlug.watch(context);

    return Row(
      children: [
        DeskDocumentTypeSidebar(
          documentTypeDecorations: config.documentTypeDecorations,
          footer: ShadButton.ghost(
            key: const ValueKey('sidebar_media_button'),
            onPressed: () => context.router.navigate(const MediaScreenRoute()),
            child: const Row(
              children: [
                FaIcon(FontAwesomeIcons.images, size: 14),
                SizedBox(width: DeskSpacing.sm),
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
                color: theme.colorScheme.border.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: docType == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DeskSpacing.md,
                    DeskSpacing.sm,
                    DeskSpacing.md,
                    0,
                  ),
                  child: DeskDocumentListView(
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
                  color: theme.colorScheme.border.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Column(
              children: [
                const Spacer(),
                DeskCollapseBar(
                  isCollapsed: true,
                  onToggle: () => viewModel.documentListVisible.value = true,
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
