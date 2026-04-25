import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../../studio.dart';

@RoutePage()
class DocumentTypeScreen extends StatelessWidget {
  const DocumentTypeScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
  });

  final String documentTypeSlug;

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

    if (confirmed != true || !context.mounted) return;

    try {
      final result = await viewModel.deleteDocument.run(docId);
      if (context.mounted && result != null) {
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
      if (context.mounted) {
        toaster.show(
          ShadToast.destructive(description: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = GetIt.I<DeskViewModel>();
    final docType = viewModel.currentDocumentType.watch(context);
    final breakpoint = ResponsiveBreakpoints.of(context);
    final isMobile = breakpoint.isMobile;

    if (docType == null) return const SizedBox.shrink();

    // Mobile: full-screen doc list (shell doesn't show it on mobile)
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          DeskSpacing.md,
          DeskSpacing.sm,
          DeskSpacing.md,
          0,
        ),
        child: DeskDocumentListView(
          selectedDocumentType: docType,
          icon: FontAwesomeIcons.file,
          onOpenDocument: (documentId) {
            context.router.navigate(
              DocumentScreenRoute(
                documentTypeSlug: documentTypeSlug,
                documentId: documentId,
              ),
            );
          },
          onDeleteDocument: (docId) => _deleteDocument(context, docId: docId),
        ),
      );
    }

    // Desktop: no document selected — empty state
    return Container(
      color: theme.colorScheme.background,
      alignment: Alignment.center,
      child: Text(
        'Select or create a document to get started',
        style: theme.textTheme.muted,
      ),
    );
  }
}
