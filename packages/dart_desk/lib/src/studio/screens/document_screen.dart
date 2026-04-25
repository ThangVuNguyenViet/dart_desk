import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../config/desk_breakpoints.dart';
import '../core/view_models/desk_view_model.dart';
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
    final viewModel = GetIt.I<DeskViewModel>();
    final docType = viewModel.currentDocumentType.watch(context);
    final breakpoint = ResponsiveBreakpoints.of(context);
    final isDesktop = breakpoint.largerThan(DeskBreakpoints.tabletTag);

    if (docType == null) return const SizedBox.shrink();

    final editor = Container(
      color: theme.colorScheme.background,
      child: DeskDocumentEditor(fields: docType.fields, title: docType.title),
    );

    // Mobile / Tablet: full-screen editor only
    if (!isDesktop) return editor;

    // Desktop: preview + editor side by side
    return ResizableContainer(
      direction: Axis.horizontal,
      children: [
        ResizableChild(
          size: const ResizableSize.expand(),
          divider: ResizableDivider(
            thickness: 2,
            padding: 4,
            color: theme.colorScheme.border,
            cursor: SystemMouseCursors.resizeColumn,
          ),
          child: Container(
            color: theme.colorScheme.card,
            child: DocumentPreview(docType: docType),
          ),
        ),
        ResizableChild(size: const ResizableSize.expand(), child: editor),
      ],
    );
  }
}
