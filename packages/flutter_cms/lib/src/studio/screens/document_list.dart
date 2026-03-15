import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/cms_document.dart';
import '../../data/models/document_list.dart';
import '../core/view_models/cms_view_model.dart';
import '../providers/studio_provider.dart';

/// Document list view for browsing multiple documents of a type
class CmsDocumentListView extends StatefulWidget {
  final CmsDocumentType selectedDocumentType;
  final IconData? icon;
  final String? filter;
  final void Function(String documentId)? onOpenDocument;

  const CmsDocumentListView({
    super.key,
    required this.selectedDocumentType,
    this.icon,
    this.filter,
    this.onOpenDocument,
  });

  @override
  State<CmsDocumentListView> createState() => _CmsDocumentListViewState();
}

class _CmsDocumentListViewState extends State<CmsDocumentListView> {
  String _searchQuery = '';
  bool _isCreatingNew = false;
  bool _isLoadingSlug = false;
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  Timer? _slugDebounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _slugDebounceTimer?.cancel();
    _titleController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = cmsViewModelProvider.of(context);

    return Watch((context) {
      final params = viewModel.queryParams.value;
      if (params.documentType == null) {
        return _buildEmpty(theme);
      }

      final resourceState = viewModel.documentsContainer(params).value;
      return resourceState.map<Widget>(
        data: (result) => _buildContent(context, theme, result),
        loading: () => _buildLoading(theme),
        error: (error, stackTrace) => _buildError(theme, error),
      );
    });
  }

  Widget _buildEmpty(ShadThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 40,
            color: theme.colorScheme.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            'Select a document type',
            style: theme.textTheme.muted.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(ShadThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ShadProgress(),
          const SizedBox(height: 12),
          Text(
            'Loading documents...',
            style: theme.textTheme.muted.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ShadThemeData theme, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: theme.colorScheme.destructive,
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load documents',
            style: theme.textTheme.muted.copyWith(
              color: theme.colorScheme.destructive,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error.toString(),
            style: theme.textTheme.muted.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ShadThemeData theme,
    DocumentList result,
  ) {
    final viewModel = cmsViewModelProvider.of(context);
    final documents = result.documents;
    final filteredDocuments = documents.where((doc) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return doc.title.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // Header with search and create button
        Row(
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                widget.selectedDocumentType.title,
                style: theme.textTheme.large.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            ShadIconButton.secondary(
              onPressed: () {
                setState(() {
                  _isCreatingNew = !_isCreatingNew;
                  if (!_isCreatingNew) {
                    _titleController.clear();
                    _slugController.clear();
                  }
                });
              },
              icon: Icon(_isCreatingNew ? Icons.close : Icons.add, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ShadInputFormField(
          placeholder: const Text('Search documents...'),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          trailing: const Icon(Icons.search),
        ),
        // Search bar
        if (widget.filter != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Filter: ${widget.filter}',
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.mutedForeground,
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
          ),
        // Document list
        Expanded(
          child: filteredDocuments.isEmpty && !_isCreatingNew
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 40,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No documents yet'
                            : 'No documents match your search',
                        style: theme.textTheme.muted.copyWith(
                          color: theme.colorScheme.mutedForeground,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: (_isCreatingNew ? 1 : 0) + filteredDocuments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    if (_isCreatingNew && index == 0) {
                      return _buildInlineCreateForm(context, theme);
                    }
                    final docIndex = _isCreatingNew ? index - 1 : index;
                    final doc = filteredDocuments[docIndex];
                    return _buildDocumentTile(context, theme, doc, viewModel);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInlineCreateForm(BuildContext context, ShadThemeData theme) {
    final viewModel = cmsViewModelProvider.of(context);
    final documentViewModel = documentViewModelProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create New Document',
            style: theme.textTheme.muted.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          ShadInputFormField(
            controller: _titleController,
            placeholder: const Text('Document title'),
            onChanged: (value) {
              _slugDebounceTimer?.cancel();
              if (value.trim().isEmpty) {
                _slugController.text = '';
                setState(() => _isLoadingSlug = false);
                return;
              }
              setState(() => _isLoadingSlug = true);
              _slugDebounceTimer = Timer(
                const Duration(milliseconds: 500),
                () async {
                  try {
                    final slug = await viewModel.suggestSlug(value.trim());
                    if (mounted && slug != null) {
                      _slugController.text = slug;
                    }
                  } catch (_) {
                    // Fallback to local slug generation
                    if (mounted) {
                      _slugController.text = value
                          .toLowerCase()
                          .replaceAll(RegExp(r'[^\w\s-]'), '')
                          .replaceAll(RegExp(r'\s+'), '-')
                          .replaceAll(RegExp(r'-+'), '-')
                          .trim();
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isLoadingSlug = false);
                    }
                  }
                },
              );
            },
          ),
          const SizedBox(height: 8),
          ShadInputFormField(
            controller: _slugController,
            placeholder: const Text('slug (auto-generated)'),
            trailing: _isLoadingSlug
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ShadButton.outline(
                  onPressed: () {
                    setState(() {
                      _isCreatingNew = false;
                      _titleController.clear();
                      _slugController.clear();
                    });
                  },
                  size: ShadButtonSize.sm,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ShadButton(
                  onPressed: () {
                    if (_titleController.text.trim().isNotEmpty &&
                        _slugController.text.trim().isNotEmpty) {
                      // Save title and slug to the document view model signals
                      final title = _titleController.text.trim();
                      final slug = _slugController.text.trim();

                      // Clear documentId to indicate this is a new document
                      documentViewModel.documentId.value = null;

                      viewModel.createDocument(
                        title,
                        viewModel.currentDocumentType.value?.defaultValue
                                ?.toMap() ??
                            {},
                        slug: slug,
                      );

                      setState(() {
                        _isCreatingNew = false;
                        _titleController.clear();
                        _slugController.clear();
                      });
                    }
                  },
                  size: ShadButtonSize.sm,
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(
    BuildContext context,
    ShadThemeData theme,
    CmsDocument doc,
    CmsViewModel viewModel,
  ) {
    final documentViewModel = documentViewModelProvider.of(context);

    return Watch((context) {
      final isSelected = documentViewModel.documentId.value == doc.id;

      return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.card,
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.4)
              : theme.colorScheme.border,
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () {
          if (doc.id != null && !isSelected) {
            widget.onOpenDocument?.call(doc.id.toString());
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    doc.title,
                    style: theme.textTheme.muted.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.foreground,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
            if (doc.slug != null) ...[
              const SizedBox(height: 3),
              Text(
                '/${doc.slug}',
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ],
            if (doc.isDefault) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'DEFAULT',
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    });
  }
}
