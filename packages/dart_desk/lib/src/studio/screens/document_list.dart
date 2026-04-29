import 'dart:async';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/desk_document.dart';
import '../../data/models/document_list.dart';
import '../../data/models/document_version.dart';
import '../components/common/desk_collapse_bar.dart';
import '../components/common/desk_status_pill.dart';
import '../core/view_models/desk_document_view_model.dart';
import '../core/view_models/desk_view_model.dart';
import '../theme/spacing.dart';

/// Document list view for browsing multiple documents of a type
class DeskDocumentListView extends StatefulWidget {
  final DocumentType selectedDocumentType;
  final IconData? icon;
  final String? filter;
  final void Function(String documentId)? onOpenDocument;
  final void Function(String documentId)? onDeleteDocument;

  const DeskDocumentListView({
    super.key,
    required this.selectedDocumentType,
    this.icon,
    this.filter,
    this.onOpenDocument,
    this.onDeleteDocument,
  });

  @override
  State<DeskDocumentListView> createState() => _DeskDocumentListViewState();
}

class _DeskDocumentListViewState extends State<DeskDocumentListView> {
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
    final viewModel = GetIt.I<DeskViewModel>();

    final resourceState = viewModel
        .documentsContainer(widget.selectedDocumentType.name)
        .watch(context);
    return resourceState.map<Widget>(
      data: (result) => _buildContent(context, theme, result),
      loading: () => _buildLoading(theme),
      error: (error, stackTrace) => _buildError(theme, error),
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
          FaIcon(
            FontAwesomeIcons.circleExclamation,
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
    final viewModel = GetIt.I<DeskViewModel>();
    final documents = result.documents;
    final filteredDocuments = documents.where((doc) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return doc.title.toLowerCase().contains(query);
    }).toList();

    return Column(
      key: const ValueKey('document_list_view'),
      children: [
        // Header with search and create button
        Row(
          children: [
            if (widget.icon != null) ...[
              FaIcon(widget.icon!, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                widget.selectedDocumentType.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.p,
              ),
            ),
            ShadIconButton.secondary(
              key: const ValueKey('create_document_button'),
              onPressed: () {
                setState(() {
                  _isCreatingNew = !_isCreatingNew;
                  if (!_isCreatingNew) {
                    _titleController.clear();
                    _slugController.clear();
                  }
                });
              },
              icon: FaIcon(
                _isCreatingNew ? FontAwesomeIcons.xmark : FontAwesomeIcons.plus,
                size: 16,
              ),
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
          trailing: const FaIcon(FontAwesomeIcons.magnifyingGlass),
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
                      FaIcon(
                        FontAwesomeIcons.inbox,
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
                  itemCount:
                      (_isCreatingNew ? 1 : 0) + filteredDocuments.length,
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
        DeskCollapseBar(
          onToggle: () {
            final viewModel = GetIt.I<DeskViewModel>();
            viewModel.documentListVisible.value = false;
          },
        ),
      ],
    );
  }

  Widget _buildInlineCreateForm(BuildContext context, ShadThemeData theme) {
    final viewModel = GetIt.I<DeskViewModel>();
    final documentViewModel = GetIt.I<DeskDocumentViewModel>();

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
                  onPressed: () async {
                    if (_titleController.text.trim().isNotEmpty &&
                        _slugController.text.trim().isNotEmpty) {
                      // Save title and slug to the document view model signals
                      final title = _titleController.text.trim();
                      final slug = _slugController.text.trim();

                      // Clear documentId to indicate this is a new document
                      documentViewModel.documentId.value = null;

                      // Hide the form before the network call so the inline
                      // form text field isn't visible during the list reload.
                      setState(() {
                        _isCreatingNew = false;
                        _titleController.clear();
                        _slugController.clear();
                      });

                      // Capture toaster before the async gap
                      final toaster = ShadToaster.of(context);

                      final document = await viewModel.createDocument.run((
                        title: title,
                        data:
                            viewModel.currentDocumentType.value?.defaultValue
                                ?.toMap() ??
                            {},
                        slug: slug,
                        isDefault: false,
                        publish: false,
                      ));

                      if (document?.id != null) {
                        widget.onOpenDocument?.call(document!.id.toString());
                      }
                      if (document?.isDefault == true && context.mounted) {
                        toaster.show(
                          ShadToast(
                            description: Text(
                              '"${document!.title}" is now the default.',
                            ),
                          ),
                        );
                      }
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
    DeskDocument doc,
    DeskViewModel viewModel,
  ) {
    final documentViewModel = GetIt.I<DeskDocumentViewModel>();
    final isSelected = documentViewModel.documentId.watch(context) == doc.id;

    return GestureDetector(
      onTap: () {
        if (doc.id != null && !isSelected) {
          widget.onOpenDocument?.call(doc.id.toString());
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DeskSpacing.md,
            vertical: DeskSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.06)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : theme.colorScheme.border,
            ),
            borderRadius: BorderRadius.circular(DeskBorderRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + status pill + menu row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      doc.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.normal,
                        color: theme.colorScheme.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (doc.id != null)
                    _DocumentStatusPill(
                      documentId: doc.id!,
                      viewModel: viewModel,
                    ),
                  if (doc.id != null && widget.onDeleteDocument != null)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: PopupMenuButton<String>(
                        key: ValueKey('document_menu_${doc.id}'),
                        padding: EdgeInsets.zero,
                        iconSize: 14,
                        icon: const FaIcon(
                          FontAwesomeIcons.ellipsisVertical,
                          size: 12,
                        ),
                        onSelected: (value) async {
                          if (value == 'set_default') {
                            final toaster = ShadToaster.of(context);
                            final newDefault = await viewModel
                                .setDefaultDocument
                                .run(doc.id!);
                            if (context.mounted && newDefault != null) {
                              toaster.show(
                                ShadToast(
                                  description: Text(
                                    '"${newDefault.title}" is now the default.',
                                  ),
                                ),
                              );
                            }
                          } else if (value == 'delete') {
                            widget.onDeleteDocument!(doc.id!);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'set_default',
                            enabled: !doc.isDefault,
                            child: const Text(
                              'Set as default',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          PopupMenuItem<String>(
                            key: const ValueKey('delete_document_button'),
                            value: 'delete',
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.trashCan,
                                  size: 12,
                                  color: theme.colorScheme.destructive,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: theme.colorScheme.destructive,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (doc.slug != null) ...[
                const SizedBox(height: DeskSpacing.xs),
                Text(
                  '/${doc.slug}',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.mutedForeground,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              const SizedBox(height: DeskSpacing.xs),
              Row(
                children: [
                  if (doc.isDefault) ...[
                    ShadBadge.secondary(
                      child: const Text(
                        'Default',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    _formatTimestamp(doc.updatedAt),
                    style: TextStyle(
                      fontSize: 9,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    if (diff.inDays < 7) return 'Updated ${diff.inDays}d ago';
    return 'Updated ${(diff.inDays / 7).floor()}w ago';
  }
}

/// Watches the versions container for a document and displays its latest
/// version's status as a [DeskStatusPill].
class _DocumentStatusPill extends StatelessWidget {
  final String documentId;
  final DeskViewModel viewModel;

  const _DocumentStatusPill({
    required this.documentId,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final versionsState = viewModel
        .versionsContainer(documentId)
        .watch(context);

    // Render nothing while loading/erroring instead of misleadingly showing
    // "draft" — AsyncDataReloading still routes to data, so reloads keep the
    // last known status visible.
    return versionsState.map<Widget>(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (versionList) {
        if (versionList.versions.isEmpty) {
          return const DeskStatusPill(status: DocumentVersionStatus.draft);
        }
        return DeskStatusPill(status: versionList.versions.last.status);
      },
    );
  }
}
