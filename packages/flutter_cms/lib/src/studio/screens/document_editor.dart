import 'package:flutter/material.dart';
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/document_version.dart';
import '../components/forms/cms_form.dart';
import '../providers/studio_provider.dart';

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
  /// Signal for edited document data (working copy)
  late final MapSignal<String, dynamic> editedData;

  @override
  void initState() {
    final viewModel = cmsViewModelProvider.of(context);
    final docType = viewModel.currentDocumentType.value;
    editedData = createMapSignal(docType?.defaultValue?.toMap() ?? {});
    super.initState();
  }

  Future<void> _saveDocument() async {
    final viewModel = cmsViewModelProvider.of(context);
    try {
      final documentViewModel = documentViewModelProvider.of(context);
      final docId = documentViewModel.documentId.value;

      final dataToSave = editedData.value;

      if (docId != null) {
        // Update existing document data
        await viewModel.updateDocumentData(dataToSave);
      } else {
        final documentViewModel = documentViewModelProvider.of(context);
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
      final viewModel = cmsViewModelProvider.of(context);
      final versionId = viewModel.selectedVersionIdInt;

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
    final viewModel = cmsViewModelProvider.of(context);

    return Watch((context) {
      final isSaving = viewModel.isSaving.value;
      final versionId = viewModel.selectedVersionIdInt;

      if (versionId == null) {
        // No version selected - use editedData or defaults
        final docType = viewModel.currentDocumentType.value;
        final data = editedData.value.isEmpty
            ? (docType?.defaultValue?.toMap() ?? {})
            : editedData.value;

        // Initialize editedData if empty
        if (editedData.value.isEmpty && docType?.defaultValue != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            editedData.value = docType!.defaultValue!.toMap();
          });
        }

        return _buildEditor(data, isSaving);
      }

      final versionState = viewModel.documentDataContainer(versionId).value;

      return versionState.map<Widget>(
        loading: () => const Center(child: ShadProgress()),
        error: (error, stackTrace) =>
            Center(child: Text('Error loading document: $error')),
        data: (versionData) {
          final versionDataMap = versionData?.data ?? {};

          // Initialize editedData from version data if not already set
          if (editedData.value.isEmpty && versionDataMap.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              editedData.value = Map<String, dynamic>.from(versionDataMap);
            });
          }

          // Use editedData for display (working copy)
          final displayData = editedData.value.isEmpty
              ? versionDataMap
              : editedData.value;

          return _buildEditor(displayData, isSaving);
        },
      );
    });
  }

  Widget _buildEditor(Map<String, dynamic> documentData, bool isSaving) {
    return Watch((context) {
      final viewModel = cmsViewModelProvider.of(context);
      final versionId = viewModel.selectedVersionIdInt;

      // Compute hasUnsavedChanges by comparing editedData with version data
      bool hasUnsavedChanges = false;
      if (versionId != null) {
        final versionState = viewModel.documentDataContainer(versionId).value;
        if (versionState is AsyncData<DocumentVersion?>) {
          final originalData = versionState.value?.data ?? {};
          final edited = editedData.value;

          // Check if there are changes
          if (edited.length != originalData.length) {
            hasUnsavedChanges = true;
          } else {
            for (final key in edited.keys) {
              if (edited[key] != originalData[key]) {
                hasUnsavedChanges = true;
                break;
              }
            }
          }
        }
      } else {
        // For new documents, check if editedData is not empty
        hasUnsavedChanges = editedData.value.isNotEmpty;
      }

      return Stack(
        children: [
          CmsForm(
            fields: widget.fields,
            data: Map<String, dynamic>.from(documentData),
            title: widget.title,
            onSave: isSaving ? null : _saveDocument,
            onDiscard: isSaving || !hasUnsavedChanges ? null : _discardDocument,
            onFieldChanged: (fieldName, value) => editedData[fieldName] = value,
          ),
          if (isSaving)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(child: ShadProgress()),
              ),
            ),
        ],
      );
    });
  }
}
