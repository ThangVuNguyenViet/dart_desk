import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../config/cms_breakpoints.dart';
import '../core/view_models/cms_view_model.dart';
import 'document_editor.dart';
import 'document_preview.dart';

@RoutePage()
class DocumentScreen extends StatelessWidget {
  const DocumentScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
    @PathParam('documentId') required this.documentId,
    @PathParam('versionId') this.versionId,
  });

  final String documentTypeSlug;
  final String documentId;
  final String? versionId;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = GetIt.I<CmsViewModel>();
    final docType = viewModel.currentDocumentType.watch(context);
    final breakpoint = ResponsiveBreakpoints.of(context);
    final isMobile = breakpoint.isMobile;
    final isDesktop = breakpoint.largerThan(CmsBreakpoints.tabletTag);

    if (docType == null) return const SizedBox.shrink();

    final editor = Container(
      color: theme.colorScheme.background,
      child: CmsDocumentEditor(
        fields: docType.fields,
        title: docType.title,
      ),
    );

    // Mobile / Tablet: full-screen editor only
    if (!isDesktop) return editor;

    // Desktop: preview + editor side by side
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
}
