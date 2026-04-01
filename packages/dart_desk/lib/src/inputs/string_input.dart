import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

@Preview(name: 'CmsStringInput')
Widget preview() => ShadApp(
  home: CmsStringInput(
    field: const CmsStringField(
      name: 'username',
      title: 'Username',
      option: CmsStringOption(),
    ),
  ),
);

class CmsStringInput extends StatefulWidget {
  final CmsStringField field;
  final CmsData? data;
  final ValueChanged<String?>? onChanged;

  const CmsStringInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<CmsStringInput> createState() => _CmsStringInputState();
}

class _CmsStringInputState extends State<CmsStringInput> {
  late final TextEditingController _controller;
  late final UndoHistoryController _undoController;
  late bool _isEnabled;

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
  }

  void _onTextChanged() {
    if (_isEnabled) widget.onChanged?.call(_controller.text);
  }

  @override
  void didUpdateWidget(covariant CmsStringInput oldWidget) {
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
    if (widget.field.option.hidden) return const SizedBox.shrink();

    return ShadInputFormField(
      controller: _controller,
      undoController: _undoController,
      label: Text(widget.field.title),
      placeholder: const Text('Enter text...'),
      description: widget.field.description != null
          ? Text(widget.field.description!)
          : null,
      maxLines: 1,
      enabled: !widget.field.option.optional || _isEnabled,
      trailing: widget.field.option.optional
          ? ShadCheckbox(
              value: _isEnabled,
              onChanged: (value) {
                setState(() => _isEnabled = value);
                widget.onChanged?.call(value ? _controller.text : null);
              },
            )
          : null,
    );
  }
}
