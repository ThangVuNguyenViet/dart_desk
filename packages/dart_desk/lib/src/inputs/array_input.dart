import 'package:flutter/material.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../studio/components/forms/desk_form.dart';
import 'edit_styles/edit_styles.dart';
import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

class DeskArrayInput<T> extends StatefulWidget {
  final DeskArrayField<T> field;
  final DeskData? data;
  final ValueChanged<List?>? onChanged;
  final EditStyles editStyle;

  const DeskArrayInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
    this.editStyle = const InlineEditStyles(),
  });

  @override
  State<DeskArrayInput<T>> createState() => _DeskArrayInputState<T>();
}

class _DeskArrayInputState<T> extends State<DeskArrayInput<T>> {
  late List<T> _items;
  int? _editingIndex; // -1 for adding new, null for none, >= 0 for editing
  dynamic _editingValue;
  late bool _isEnabled;
  List<T>? _lastValue;

  bool get _isOptional => widget.field.option?.optional ?? false;

  @override
  void initState() {
    super.initState();
    _items = _parseItems(widget.data?.value);
    _isEnabled = _isOptional ? widget.data?.value != null : true;
    _lastValue = _isEnabled ? List<T>.from(_items) : null;
  }

  List<T> _parseItems(Object? raw) {
    final fromMap = widget.field.fromMap;
    return (raw as List?)?.map<T>((e) {
          if (e is T) return e;
          return fromMap!(Map<String, dynamic>.from(e as Map));
        }).toList() ??
        [];
  }

  @override
  void didUpdateWidget(covariant DeskArrayInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data?.value != widget.data?.value) {
      _items = _parseItems(widget.data?.value);
      if (_isOptional) {
        setState(() => _isEnabled = widget.data?.value != null);
      }
    }
  }

  void _handleToggle(bool enabled) {
    setState(() {
      if (!enabled) {
        _lastValue = List<T>.from(_items);
        _isEnabled = false;
        _items = [];
        _editingIndex = null;
        _editingValue = null;
      } else {
        _isEnabled = true;
        _items = _lastValue != null ? List<T>.from(_lastValue!) : <T>[];
      }
    });
    widget.onChanged?.call(enabled ? List<T>.from(_items) : null);
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
      if (_editingValue != null) {
        final fromMap = widget.field.fromMap;
        final T typed;
        if (_editingValue is T) {
          typed = _editingValue as T;
        } else {
          typed = fromMap!(Map<String, dynamic>.from(_editingValue as Map));
        }
        if (_editingIndex == -1) {
          _items.add(typed);
        } else if (_editingIndex != null && _editingIndex! >= 0) {
          _items[_editingIndex!] = typed;
        }
      }
      _editingIndex = null;
      _editingValue = null;
    });
    _lastValue = List<T>.from(_items);
    widget.onChanged?.call(List<T>.from(_items));
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
    _lastValue = List<T>.from(_items);
    widget.onChanged?.call(List<T>.from(_items));
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    _lastValue = List<T>.from(_items);
    widget.onChanged?.call(List<T>.from(_items));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionalFieldHeader(
          title: widget.field.title,
          isOptional: _isOptional,
          isEnabled: _isEnabled,
          onToggle: _handleToggle,
        ),
        const SizedBox(height: 8),
        OptionalFieldWrapper(
          isEnabled: !_isOptional || _isEnabled,
          child: ShadCard(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                            ? _buildEditorWithActions(
                                context,
                                theme,
                                isNew: false,
                              )
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
            Tooltip(
              message: 'Save array item',
              child: ShadButton(
                key: const ValueKey('array_item_save'),
                onPressed: _saveItem,
                size: ShadButtonSize.sm,
                child: const Text('Save'),
              ),
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

    // Use the registry for the innerField!
    final builder = DeskFieldInputRegistry.getBuilder(widget.field.innerField);
    if (builder != null) {
      final path = widget.data?.path ?? widget.field.name;
      final itemIndex = _editingIndex == -1 ? _items.length : _editingIndex;

      return builder(
        widget.field.innerField,
        DeskData(value: _editingValue, path: '$path.[$itemIndex]'),
        (_, newValue) {
          setState(() {
            _editingValue = newValue;
          });
        },
      );
    }

    return Text(
      'No editor found for item type: ${widget.field.innerField.runtimeType}',
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
              child:
                  widget.field.option?.buildItem(context, _items[index]) ??
                  Text(_items[index]?.toString() ?? ''),
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
