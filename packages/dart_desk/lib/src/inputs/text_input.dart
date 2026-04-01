import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

@Preview(name: 'CmsTextInput')
Widget preview() => ShadApp(
  home: CmsTextInput(
    field: CmsTextField(
      name: 'name',
      title: 'title',
      option: CmsTextOption(rows: 1),
    ),
  ),
);

class CmsTextInput extends StatefulWidget {
  final CmsTextField field;
  final CmsData? data;
  final ValueChanged<String?>? onChanged;

  const CmsTextInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<CmsTextInput> createState() => _CmsTextInputState();
}

class _CmsTextInputState extends State<CmsTextInput> {
  late final TextEditingController _controller;
  late final UndoHistoryController _undoController;
  late bool _isEnabled;

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
  }

  void _onTextChanged() {
    if (_isEnabled) widget.onChanged?.call(_controller.text);
  }

  @override
  void didUpdateWidget(covariant CmsTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText =
        widget.data?.value ?? widget.field.option.initialValue ?? '';
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

    final theme = ShadTheme.of(context);
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
        ShadInputFormField(
          controller: _controller,
          undoController: _undoController,
          label: Text(label),
          placeholder: const Text('Enter text...'),
          description: widget.field.description != null
              ? Text(widget.field.description!)
              : null,
          maxLines: widget.field.option.rows,
          readOnly: widget.field.option.readOnly,
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
        ),
      ],
    );
  }
}
