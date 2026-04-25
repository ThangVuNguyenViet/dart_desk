import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/document_version.dart';
import '../components/common/desk_button.dart';
import '../components/forms/desk_form.dart';
import '../core/view_models/desk_document_view_model.dart';
import '../core/view_models/desk_view_model.dart';

/// Document editor widget that dynamically generates forms based on fields
class DeskDocumentEditor extends StatefulWidget {
  final List<DeskField> fields;
  final String? title;

  const DeskDocumentEditor({super.key, required this.fields, this.title});

  @override
  State<DeskDocumentEditor> createState() => _DeskDocumentEditorState();
}

class _DeskDocumentEditorState extends State<DeskDocumentEditor>
    with SignalsMixin {
  /// Shared edited data signal from the document view model.
  MapSignal<String, dynamic> get editedData =>
      GetIt.I<DeskDocumentViewModel>().editedData;

  Future<void> _performSave({required bool publish}) async {
    final viewModel = GetIt.I<DeskViewModel>();
    try {
      final documentViewModel = GetIt.I<DeskDocumentViewModel>();
      final docId = documentViewModel.documentId.value;

      final dataToSave = editedData.value;

      if (docId != null) {
        if (publish) {
          await viewModel.publishDocumentData.run((
            documentId: docId,
            data: dataToSave,
          ));
        } else {
          await viewModel.saveDocumentData.run((
            documentId: docId,
            data: dataToSave,
          ));
        }
        documentViewModel.isDirty.value = false;
      } else {
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

        await viewModel.createDocument.run((
          title: title,
          data: dataToSave,
          slug: slug,
          isDefault: false,
          publish: publish,
        ));
      }

      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            description: Text(
              publish
                  ? 'Document published successfully'
                  : 'Document saved successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            description: Text('Failed to ${publish ? 'publish' : 'save'}: $e'),
          ),
        );
      }
    }
  }

  Future<void> _saveDocument() => _performSave(publish: false);
  Future<void> _publishDocument() => _performSave(publish: true);

  Future<void> _discardDocument() async {
    try {
      final viewModel = GetIt.I<DeskViewModel>();
      final versionId = viewModel.selectedVersionId.value;

      final documentViewModel = GetIt.I<DeskDocumentViewModel>();
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
      documentViewModel.isDirty.value = false;

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
    final viewModel = GetIt.I<DeskViewModel>();

    final saveStatus = viewModel.saveDocumentData.watch(context);
    final publishStatus = viewModel.publishDocumentData.watch(context);
    final createStatus = viewModel.createDocument.watch(context);

    final isSaving = saveStatus.isLoading || createStatus.isLoading;
    final isPublishing = publishStatus.isLoading || createStatus.isLoading;
    final isAnyBusy = isSaving || isPublishing;

    final versionId = viewModel.selectedVersionId.watch(context);
    final versionState = versionId != null
        ? viewModel.documentDataContainer(versionId).watch(context)
        : null;

    // If editedData is already populated (e.g. by auto-version-select),
    // skip the loading state and render the editor immediately.
    final edited = editedData.value;
    if (versionState == null) {
      return _buildEditor(edited, isSaving: isSaving, isPublishing: isPublishing, isAnyBusy: isAnyBusy);
    }

    return versionState.map<Widget>(
      loading: () => const Center(child: ShadProgress()),
      error: (error, stackTrace) =>
          Center(child: Text('Error loading document: $error')),
      data: (versionData) {
        final versionDataMap = versionData?.data ?? {};
        final displayData = editedData.value.isEmpty
            ? versionDataMap
            : editedData.value;
        return _buildEditor(displayData, isSaving: isSaving, isPublishing: isPublishing, isAnyBusy: isAnyBusy);
      },
    );
  }

  Widget _buildEditor(
    Map<String, dynamic> documentData, {
    required bool isSaving,
    required bool isPublishing,
    required bool isAnyBusy,
  }) {
    editedData.watch(context);
    final hasUnsavedChanges =
        GetIt.I<DeskDocumentViewModel>().isDirty.watch(context);

    final theme = ShadTheme.of(context);

    return Column(
      children: [
        Expanded(
          child: DeskForm(
            fields: widget.fields,
            data: Map<String, dynamic>.from(documentData),
            title: widget.title,
            onFieldChanged: (fieldName, value) {
              editedData[fieldName] = value;
              GetIt.I<DeskDocumentViewModel>().isDirty.value = true;
            },
          ),
        ),
        if (hasUnsavedChanges)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.colorScheme.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DeskButton(
                  key: const ValueKey('discard_document_button'),
                  text: 'Discard',
                  variant: ShadButtonVariant.outline,
                  onPressed: isAnyBusy ? null : _discardDocument,
                ),
                const SizedBox(width: 8),
                DeskButton(
                  key: const ValueKey('save_document_button'),
                  text: 'Save',
                  loading: isSaving,
                  onPressed: isAnyBusy ? null : _saveDocument,
                ),
                const SizedBox(width: 8),
                DeskButton(
                  key: const ValueKey('publish_document_button'),
                  text: 'Publish',
                  loading: isPublishing,
                  onPressed: isAnyBusy ? null : _publishDocument,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
