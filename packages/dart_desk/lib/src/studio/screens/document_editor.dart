import 'package:flutter/material.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/document_version.dart';
import '../components/common/cms_button.dart';
import '../components/forms/cms_form.dart';
import 'package:get_it/get_it.dart';

import '../core/view_models/cms_document_view_model.dart';
import '../core/view_models/cms_view_model.dart';

/// Document editor widget that dynamically generates forms based on fields
class CmsDocumentEditor extends StatefulWidget {
  final List<CmsField> fields;
  final String? title;

  const CmsDocumentEditor({super.key, required this.fields, this.title});

  @override
  State<CmsDocumentEditor> createState() => _CmsDocumentEditorState();
}

class _CmsDocumentEditorState extends State<CmsDocumentEditor>
    with SignalsMixin {
  /// Shared edited data signal from the document view model.
  MapSignal<String, dynamic> get editedData =>
      GetIt.I<CmsDocumentViewModel>().editedData;

  @override
  void initState() {
    final viewModel = GetIt.I<CmsViewModel>();
    final docType = viewModel.currentDocumentType.value;
    final defaults = docType?.defaultValue?.toMap() ?? {};
    if (editedData.value.isEmpty && defaults.isNotEmpty) {
      editedData.value = defaults;
    }
    super.initState();
  }

  Future<void> _saveDocument() async {
    final viewModel = GetIt.I<CmsViewModel>();
    try {
      final documentViewModel = GetIt.I<CmsDocumentViewModel>();
      final docId = documentViewModel.documentId.value;

      final dataToSave = editedData.value;

      if (docId != null) {
        // Update existing document data
        await viewModel.updateDocumentData(dataToSave);
      } else {
        final documentViewModel = GetIt.I<CmsDocumentViewModel>();
        final title = documentViewModel.title.value;
        final slug = documentViewModel.slug.value;

        if (title.isEmpty || slug.isEmpty) {
          ShadToaster.of(context).show(
            const ShadToast(
              description: Text(
                'Title and Slug are required to create a document',
              ),
            ),
          );
          return;
        }

        // Create new document with initial version
        await viewModel.createDocument(title, dataToSave, slug: slug);
      }

      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(description: Text('Document saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast(description: Text('Failed to save: $e')));
      }
    }
  }

  Future<void> _discardDocument() async {
    try {
      final viewModel = GetIt.I<CmsViewModel>();
      final versionId = viewModel.selectedVersionId.value;

      if (versionId != null) {
        // Reset to original version data
        final versionState = viewModel.documentDataContainer(versionId).value;
        if (versionState is AsyncData<DocumentVersion?> &&
            versionState.value?.data != null) {
          editedData.value = Map<String, dynamic>.from(
            versionState.value!.data!,
          );
        }
      } else {
        // Reset to default values
        final docType = viewModel.currentDocumentType.value;
        editedData.value = docType?.defaultValue?.toMap() ?? {};
      }

      if (mounted) {
        ShadToaster.of(
          context,
        ).show(const ShadToast(description: Text('Changes discarded')));
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast(description: Text('Failed to discard: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<CmsViewModel>();

    final isSaving = viewModel.isSaving.watch(context);
    final versionId = viewModel.selectedVersionId.watch(context);
    final versionState = versionId != null
        ? viewModel.documentDataContainer(versionId).watch(context)
        : null;

    // If editedData is already populated (e.g. by auto-version-select),
    // skip the loading state and render the editor immediately.
    final edited = editedData.value;
    if (versionState == null) {
      return _buildEditor(edited, isSaving);
    }

    return versionState.map<Widget>(
      loading: () => const Center(child: ShadProgress()),
      error: (error, stackTrace) =>
          Center(child: Text('Error loading document: $error')),
      data: (versionData) {
        final versionDataMap = versionData?.data ?? {};

        // Initialize editedData from version data
        if (editedData.value.isEmpty && versionDataMap.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              editedData.value = Map<String, dynamic>.from(versionDataMap);
            }
          });
        }

        final displayData = editedData.value.isEmpty
            ? versionDataMap
            : editedData.value;

        return _buildEditor(displayData, isSaving);
      },
    );
  }

  Widget _buildEditor(Map<String, dynamic> documentData, bool isSaving) {
    final edited = editedData.watch(context);
    final hasUnsavedChanges = edited.isNotEmpty;

    final theme = ShadTheme.of(context);

    return Column(
      children: [
        Expanded(
          child: CmsForm(
            fields: widget.fields,
            data: Map<String, dynamic>.from(documentData),
            title: widget.title,
            onFieldChanged: (fieldName, value) =>
                editedData[fieldName] = value,
          ),
        ),
        if (hasUnsavedChanges)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.border,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CmsButton(
                  text: 'Discard',
                  variant: ShadButtonVariant.outline,
                  onPressed: isSaving ? null : _discardDocument,
                ),
                const SizedBox(width: 8),
                CmsButton(
                  text: 'Save',
                  loading: isSaving,
                  onPressed: isSaving ? null : _saveDocument,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
