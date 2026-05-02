import 'dart:async';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

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

  Timer? _autosaveTimer;
  final List<EffectCleanup> _effectCleanups = [];

  /// Tracks the document id and data snapshot for any pending autosave so that
  /// we can flush to the correct document when the selection changes.
  String? _pendingFlushDocId;
  Map<String, dynamic>? _pendingFlushData;

  void _flushPendingAutosave() {
    final flushDocId = _pendingFlushDocId;
    final flushData = _pendingFlushData;
    if (flushDocId == null || flushData == null) return;
    _pendingFlushDocId = null;
    _pendingFlushData = null;
    final documentVM = GetIt.I<DeskDocumentViewModel>();
    // Fire-and-forget — the status pill reflects any resulting error state.
    documentVM.updateData.run((
      documentId: flushDocId,
      updates: Map<String, dynamic>.from(flushData),
    ));
  }

  @override
  void initState() {
    super.initState();
    _effectCleanups.add(
      effect(() {
        final documentVM = GetIt.I<DeskDocumentViewModel>();
        final docId = documentVM.documentId.value;
        final dirty = documentVM.isDirty.value;
        final data = documentVM.editedData.value; // tracked

        if (docId == null || !dirty) return;

        // If the document has switched and there are pending edits for the
        // previous document, flush them synchronously before starting a new
        // autosave cycle for the current document.
        if (_pendingFlushDocId != null && _pendingFlushDocId != docId) {
          _autosaveTimer?.cancel();
          _autosaveTimer = null;
          _flushPendingAutosave();
        }

        _pendingFlushDocId = docId;
        _pendingFlushData = Map<String, dynamic>.from(data);

        _autosaveTimer?.cancel();
        _autosaveTimer = Timer(const Duration(seconds: 1), () async {
          _pendingFlushDocId = null;
          _pendingFlushData = null;
          try {
            await documentVM.updateData.run((
              documentId: docId,
              updates: Map<String, dynamic>.from(data),
            ));
            documentVM.isDirty.value = false;
          } catch (_) {
            // Status pill reflects error state.
          }
        });
      }),
    );
  }

  @override
  void dispose() {
    if (_autosaveTimer?.isActive == true) {
      _autosaveTimer!.cancel();
      _autosaveTimer = null;
      _flushPendingAutosave();
    } else {
      _autosaveTimer?.cancel();
    }
    for (final cleanup in _effectCleanups) {
      cleanup();
    }
    super.dispose();
  }

  Future<void> _publishDocument() async {
    final viewModel = GetIt.I<DeskViewModel>();
    final documentVM = GetIt.I<DeskDocumentViewModel>();
    final docId = documentVM.documentId.value;
    if (docId == null) return;
    try {
      // Flush any pending autosave first.
      _autosaveTimer?.cancel();
      await documentVM.updateData.run((
        documentId: docId,
        updates: Map<String, dynamic>.from(documentVM.editedData.value),
      ));
      documentVM.isDirty.value = false;
      await viewModel.publishCurrentDraft.run(docId);
      if (!mounted) return;
      ShadToaster.of(context).show(const ShadToast(
        description: Text('Document published successfully'),
      ));
    } catch (e) {
      if (!mounted) return;
      ShadToaster.of(context).show(ShadToast(
        description: Text('Failed to publish: $e'),
      ));
    }
  }

  void _clearDocument() {
    editedData.value = {for (final f in widget.fields) f.name: null};
    GetIt.I<DeskDocumentViewModel>().isDirty.value = true;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<DeskViewModel>();

    final documentViewModel = GetIt.I<DeskDocumentViewModel>();
    final saveStatus = documentViewModel.updateData.watch(context);
    final publishStatus = viewModel.publishCurrentDraft.watch(context);
    final createStatus = viewModel.createDocument.watch(context);

    final isSaving = saveStatus.isLoading || createStatus.isLoading;
    final isPublishing = publishStatus.isLoading || createStatus.isLoading;
    final isAnyBusy = isSaving || isPublishing;

    final hasChanges = viewModel.hasUnpublishedChanges.watch(context);

    final versionId = viewModel.selectedVersionId.watch(context);
    final versionState = versionId != null
        ? viewModel.documentDataContainer(versionId).watch(context)
        : null;

    final edited = editedData.value;

    if (versionState == null) {
      return _buildEditor(
        edited,
        isPublishing: isPublishing,
        isAnyBusy: isAnyBusy,
        isVersionLoading: false,
        hasChanges: hasChanges,
      );
    }

    return versionState.map<Widget>(
      loading: () => _buildEditor(
        edited,
        isPublishing: isPublishing,
        isAnyBusy: isAnyBusy,
        isVersionLoading: true,
        hasChanges: hasChanges,
      ),
      error: (error, stackTrace) =>
          Center(child: Text('Error loading document: $error')),
      data: (versionData) {
        final versionDataMap = versionData?.data ?? {};
        final displayData = edited.isEmpty ? versionDataMap : edited;
        return _buildEditor(
          displayData,
          isPublishing: isPublishing,
          isAnyBusy: isAnyBusy,
          isVersionLoading: false,
          hasChanges: hasChanges,
        );
      },
    );
  }

  Widget _buildEditor(
    Map<String, dynamic> documentData, {
    required bool isPublishing,
    required bool isAnyBusy,
    required bool isVersionLoading,
    required bool hasChanges,
  }) {
    editedData.watch(context);

    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 2,
          child: isVersionLoading ? const LinearProgressIndicator(minHeight: 2) : null,
        ),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.colorScheme.border)),
          ),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              DeskButton(
                key: const ValueKey('clear_document_button'),
                text: 'Clear',
                variant: ShadButtonVariant.outline,
                onPressed: isAnyBusy ? null : _clearDocument,
              ),
              if (hasChanges)
                DeskButton(
                  key: const ValueKey('publish_document_button'),
                  text: 'Publish',
                  loading: isPublishing,
                  onPressed: isAnyBusy ? null : _publishDocument,
                )
              else
                Padding(
                  key: const ValueKey('published_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.check,
                        size: 14,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Published',
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
