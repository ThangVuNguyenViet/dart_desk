import 'package:flutter/material.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'edit_styles/edit_styles.dart';

class CmsArrayInput extends StatefulWidget {
  final CmsArrayField field;
  final CmsData? data;
  final ValueChanged<List?>? onChanged;
  final EditStyles editStyle;

  const CmsArrayInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
    this.editStyle = const InlineEditStyles(),
  });

  @override
  State<CmsArrayInput> createState() => _CmsArrayInputState();
}

class _CmsArrayInputState extends State<CmsArrayInput> {
  late List _items;
  int? _editingIndex; // -1 for adding new, null for none, >= 0 for editing
  dynamic _editingValue;

  @override
  void initState() {
    super.initState();
    _items = (widget.data?.value as List?)?.cast() ?? [];
  }

  void _addItem() {
    if (widget.editStyle is InlineEditStyles) {
      // Show inline editor for new item
      setState(() {
        _editingIndex = -1;
        _editingValue = null;
      });
    } else {
      // For modal style, handle later
      widget.onChanged?.call(_items);
    }
  }

  void _startEditing(int index) {
    if (widget.editStyle is InlineEditStyles) {
      setState(() {
        _editingIndex = index;
        _editingValue = _items[index];
      });
    }
  }

  void _saveItem() {
    setState(() {
      if (_editingIndex == -1) {
        // Adding new item
        if (_editingValue != null) {
          _items.add(_editingValue);
        }
      } else if (_editingIndex != null && _editingIndex! >= 0) {
        // Updating existing item
        _items[_editingIndex!] = _editingValue;
      }
      _editingIndex = null;
      _editingValue = null;
    });
    widget.onChanged?.call(_items);
  }

  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _editingValue = null;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    widget.onChanged?.call(_items);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    widget.onChanged?.call(_items);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.option.hidden) {
      return const SizedBox.shrink();
    }

    final theme = ShadTheme.of(context);

    return Column(
      children: [
        ShadCard(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.field.title,
                    style: theme.textTheme.large.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Opacity(
                    opacity: _editingIndex == null ? 1.0 : 0.4,
                    child: IgnorePointer(
                      ignoring: _editingIndex != null,
                      child: ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: _addItem,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(FontAwesomeIcons.plus, size: 12),
                            SizedBox(width: 4),
                            Text('Add'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Show empty state or list
              if (_items.isEmpty && _editingIndex != -1)
                Center(
                  child: Text(
                    'No items. Click "Add" to create one.',
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                )
              else if (_items.isNotEmpty)
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  onReorder: _onReorder,
                  buildDefaultDragHandles: false,
                  itemBuilder: (context, index) {
                    final isEditing = _editingIndex == index;

                    return Padding(
                      key: ValueKey('item_$index'),
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: isEditing && widget.editStyle is InlineEditStyles
                          ? _buildEditorWithActions(context, theme, isNew: false)
                          : _buildItemRow(context, theme, index),
                    );
                  },
                ),

              // Inline editor for adding new item
              SizedBox(height: 8),
              if (widget.editStyle is InlineEditStyles && _editingIndex == -1)
                _buildEditorWithActions(context, theme, isNew: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditorWithActions(
    BuildContext context,
    ShadThemeData theme, {
    required bool isNew,
  }) {
    return Column(
      children: [
        _buildInlineEditor(context, theme, isNew: isNew),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ShadButton(
              onPressed: _saveItem,
              size: ShadButtonSize.sm,
              child: const Text('Save'),
            ),
            const SizedBox(width: 8),
            ShadButton.outline(
              onPressed: _cancelEditing,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInlineEditor(
    BuildContext context,
    ShadThemeData theme, {
    required bool isNew,
  }) {
    final editStyle = widget.editStyle;
    if (editStyle is! InlineEditStyles) {
      return const SizedBox.shrink();
    }

    final itemEditor = widget.field.option.itemEditor;
    if (itemEditor != null) {
      return itemEditor(context, _editingValue, (value) {
        setState(() {
          _editingValue = value;
        });
      });
    }

    // Default shadcn text editor
    return ShadInputFormField(
      initialValue: _editingValue?.toString() ?? '',
      onChanged: (value) {
        setState(() {
          _editingValue = value;
        });
      },
      placeholder: const Text('Enter value...'),
    );
  }

  Widget _buildItemRow(BuildContext context, ShadThemeData theme, int index) {
    final isIdle = _editingIndex == null;
    final showEditButton = widget.editStyle is InlineEditStyles;

    return Opacity(
      opacity: isIdle ? 1.0 : 0.4,
      child: IgnorePointer(
        ignoring: !isIdle,
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              enabled: isIdle,
              child: MouseRegion(
                cursor: isIdle
                    ? SystemMouseCursors.grab
                    : SystemMouseCursors.basic,
                child: FaIcon(
                  FontAwesomeIcons.gripLines,
                  size: 14,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: widget.field.option.itemBuilder(context, _items[index]),
            ),
            const SizedBox(width: 8),
            if (showEditButton) ...[
              ShadIconButton(
                icon: const FaIcon(FontAwesomeIcons.pen, size: 12),
                onPressed: () => _startEditing(index),
              ),
              const SizedBox(width: 4),
            ],
            ShadIconButton(
              icon: const FaIcon(FontAwesomeIcons.trash, size: 14),
              onPressed: () => _removeItem(index),
            ),
          ],
        ),
      ),
    );
  }
}
