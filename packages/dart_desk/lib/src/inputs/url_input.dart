import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

@Preview(name: 'CmsUrlInput')
Widget preview() => ShadApp(
  home: CmsUrlInput(
    field: const CmsUrlField(
      name: 'website',
      title: 'Website URL',
      option: CmsUrlOption(),
    ),
  ),
);

class CmsUrlInput extends StatefulWidget {
  final CmsUrlField field;
  final CmsData? data;
  final ValueChanged<String?>? onChanged;

  const CmsUrlInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<CmsUrlInput> createState() => _CmsUrlInputState();
}

class _CmsUrlInputState extends State<CmsUrlInput> {
  late final TextEditingController _controller;
  late final UndoHistoryController _undoController;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final initialText = widget.data?.value?.toString() ?? '';
    _controller = TextEditingController(text: initialText);
    _undoController = UndoHistoryController();

    // Listen to text changes
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final value = _controller.text;
    _validateUrl(value);
    widget.onChanged?.call(value);
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
          () =>
              _validationError =
                  'Please enter a valid URL starting with http:// or https://',
        );
      } else {
        setState(() => _validationError = null);
      }
    } catch (e) {
      setState(() => _validationError = 'Please enter a valid URL');
    }
  }

  @override
  void didUpdateWidget(covariant CmsUrlInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = widget.data?.value?.toString() ?? '';
    if (newText != _controller.text &&
        oldWidget.data?.value != widget.data?.value) {
      _controller.removeListener(_onTextChanged);
      _controller.text = newText;
      _controller.addListener(_onTextChanged);
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
    if (widget.field.option.hidden) {
      return const SizedBox.shrink();
    }

    return ShadInputFormField(
      controller: _controller,
      undoController: _undoController,
      label: Text(widget.field.title),
      placeholder: const Text('https://example.com'),
      maxLines: 1,
      error: _validationError != null ? (_) => Text(_validationError!) : null,
    );
  }
}
