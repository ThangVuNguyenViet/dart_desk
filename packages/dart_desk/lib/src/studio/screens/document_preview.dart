import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../core/view_models/desk_document_view_model.dart';
import '../core/view_models/desk_view_model.dart';
import '../theme/spacing.dart';

/// Live preview panel that renders the document type's builder with current
/// edited data, falling back to the saved version data.
class DocumentPreview extends StatelessWidget {
  const DocumentPreview({super.key, required this.docType});

  final DocumentType docType;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = GetIt.I<DeskViewModel>();
    final documentViewModel = GetIt.I<DeskDocumentViewModel>();
    final edited = documentViewModel.editedData.watch(context);

    Map<String, dynamic> data = edited;
    if (data.isEmpty) {
      final versionId = viewModel.selectedVersionId.value;
      if (versionId != null) {
        final versionState = viewModel.documentDataContainer(versionId).value;
        data = versionState.maybeMap<Map<String, dynamic>>(
          data: (v) => v?.data ?? const {},
          orElse: () => const {},
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(DeskSpacing.sm),
          child: Text(
            'PREVIEW',
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.mutedForeground,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: KeyedSubtree(
            key: ValueKey(docType.name),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DeskBorderRadius.lg),
              ),
              clipBehavior: Clip.antiAlias,
              child: Builder(
                builder: (context) => docType.builder(context, data),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
