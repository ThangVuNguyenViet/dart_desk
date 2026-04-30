import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'DeskUrlInput')
Widget preview() => ShadApp(
  home: DeskUrlInput(
    field: const DeskUrlField(
      name: 'website',
      title: 'Website URL',
      option: DeskUrlOption(),
    ),
  ),
);

class DeskUrlInput extends StatefulWidget {
  final DeskUrlField field;
  final DeskData? data;
  final ValueChanged<String?>? onChanged;

  const DeskUrlInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<DeskUrlInput> createState() => _DeskUrlInputState();
}

class _DeskUrlInputState extends State<DeskUrlInput> {
  late final TextEditingController _controller;
  late final UndoHistoryController _undoController;
  String _lastText = '';
  late bool _isEnabled;
  String? _validationError;

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
    final value = _controller.text;
    _validateUrl(value);
    if (_isEnabled) widget.onChanged?.call(value);
  }

  void _validateUrl(String value) {
    if (value.isEmpty) {
      setState(() => _validationError = null);
      return;
    }
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        setState(
          () => _validationError =
              'Please enter a valid URL starting with http:// or https://',
        );
      } else {
        setState(() => _validationError = null);
      }
    } catch (e) {
      setState(() => _validationError = 'Please enter a valid URL');
    }
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
  void didUpdateWidget(covariant DeskUrlInput oldWidget) {
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
            description: widget.field.description != null
                ? Text(widget.field.description!)
                : null,
            placeholder: const Text('https://example.com'),
            maxLines: 1,
            error: _validationError != null
                ? (_) => Text(_validationError!)
                : null,
            enabled: !isOptional || _isEnabled,
          ),
        ),
      ],
    );
  }
}
