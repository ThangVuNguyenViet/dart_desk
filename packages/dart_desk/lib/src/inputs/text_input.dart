import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'DeskTextInput')
Widget preview() => ShadApp(
  home: DeskTextInput(
    field: DeskTextField(
      name: 'name',
      title: 'title',
      option: DeskTextOption(rows: 1),
    ),
  ),
);

class DeskTextInput extends StatefulWidget {
  final DeskTextField field;
  final DeskData? data;
  final ValueChanged<String?>? onChanged;

  const DeskTextInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<DeskTextInput> createState() => _DeskTextInputState();
}

class _DeskTextInputState extends State<DeskTextInput> {
  late final TextEditingController _controller;
  late final UndoHistoryController _undoController;
  String _lastText = '';
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    final initialText =
        widget.data?.value ?? widget.field.option.initialValue ?? '';
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
  void didUpdateWidget(covariant DeskTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.data?.value;
    if (oldWidget.data?.value != newValue) {
      final newText = newValue ?? widget.field.option.initialValue ?? '';
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
    final theme = ShadTheme.of(context);
    final isOptional = widget.field.option.optional;
    final label =
        widget.field.option.validation?.labelTransformer?.call(
          widget.field.title,
        ) ??
        widget.field.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.field.option.deprecatedReason case String deprecatedReason)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Deprecated: $deprecatedReason',
              style: theme.textTheme.small.copyWith(color: Colors.red),
            ),
          ),
        OptionalFieldHeader(
          title: label,
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
            maxLines: widget.field.option.rows,
            readOnly: widget.field.option.readOnly,
            enabled: !isOptional || _isEnabled,
          ),
        ),
      ],
    );
  }
}
