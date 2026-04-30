import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'DeskStringInput')
Widget preview() => ShadApp(
  home: DeskStringInput(
    field: const DeskStringField(
      name: 'username',
      title: 'Username',
      option: DeskStringOption(),
    ),
  ),
);

class DeskStringInput extends StatefulWidget {
  final DeskStringField field;
  final DeskData? data;
  final ValueChanged<String?>? onChanged;

  const DeskStringInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<DeskStringInput> createState() => _DeskStringInputState();
}

class _DeskStringInputState extends State<DeskStringInput> {
  late final TextEditingController _controller;
  late final UndoHistoryController _undoController;
  String _lastText = '';
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    final initialText = widget.data?.value?.toString() ?? '';
    _controller = TextEditingController(text: initialText);
    _undoController = UndoHistoryController();
    _controller.addListener(_onTextChanged);
    _isEnabled = widget.field.option.optional
        ? widget.data?.value != null
        : true;
    _lastText = initialText;
  }

  void _onTextChanged() {
    if (_isEnabled) widget.onChanged?.call(_controller.text);
  }

  void _handleToggle(bool enabled) {
    setState(() {
      if (!enabled) {
        _lastText = _controller.text;
        _isEnabled = false;
      } else {
        _isEnabled = true;
        _controller.removeListener(_onTextChanged);
        _controller.text = _lastText;
        _controller.addListener(_onTextChanged);
      }
    });
    widget.onChanged?.call(enabled ? _controller.text : null);
  }

  @override
  void didUpdateWidget(covariant DeskStringInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.data?.value;
    if (oldWidget.data?.value != newValue) {
      final newText = newValue?.toString() ?? '';
      _controller.removeListener(_onTextChanged);
      if (newText != _controller.text) _controller.text = newText;
      _controller.addListener(_onTextChanged);
      if (widget.field.option.optional) {
        setState(() => _isEnabled = newValue != null);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _undoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.option.hidden) return const SizedBox.shrink();
    final isOptional = widget.field.option.optional;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionalFieldHeader(
          title: widget.field.title,
          isOptional: isOptional,
          isEnabled: _isEnabled,
          onToggle: _handleToggle,
        ),
        const SizedBox(height: 8),
        OptionalFieldWrapper(
          isEnabled: !isOptional || _isEnabled,
          child: ShadInputFormField(
            controller: _controller,
            undoController: _undoController,
            placeholder: const Text('Enter text...'),
            description: widget.field.description != null
                ? Text(widget.field.description!)
                : null,
            maxLines: 1,
            enabled: !isOptional || _isEnabled,
          ),
        ),
      ],
    );
  }
}
