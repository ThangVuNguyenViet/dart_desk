import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'DeskNumberInput')
Widget preview() => ShadApp(
  home: DeskNumberInput(
    field: const DeskNumberField(
      name: 'age',
      title: 'Age',
      option: DeskNumberOption(min: 0, max: 120),
    ),
  ),
);

class DeskNumberInput extends StatefulWidget {
  final DeskNumberField field;
  final DeskData? data;
  final ValueChanged<num?>? onChanged;

  const DeskNumberInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<DeskNumberInput> createState() => _DeskNumberInputState();
}

class _DeskNumberInputState extends State<DeskNumberInput> {
  late final TextEditingController _controller;
  String _lastText = '';
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final initialText = widget.data?.value?.toString() ?? '';
    _controller = TextEditingController(text: initialText);
    _controller.addListener(_onTextChanged);
    _isEnabled = widget.field.option.optional
        ? widget.data?.value != null
        : true;
    _lastText = initialText;
  }

  void _onTextChanged() {
    if (_isEnabled) widget.onChanged?.call(num.tryParse(_controller.text));
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
    widget.onChanged?.call(enabled ? num.tryParse(_controller.text) : null);
  }

  @override
  void didUpdateWidget(covariant DeskNumberInput oldWidget) {
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
    super.dispose();
  }

  String? _validate(String value) {
    if (value.isEmpty) return null;
    if (double.tryParse(value) == null) return 'Please enter a valid number';
    final numValue = double.parse(value);
    if (widget.field.option.min != null &&
        numValue < widget.field.option.min!) {
      return 'Value must be at least ${widget.field.option.min}';
    }
    if (widget.field.option.max != null &&
        numValue > widget.field.option.max!) {
      return 'Value must be at most ${widget.field.option.max}';
    }
    if (widget.field.option.validation != null) {
      return widget.field.option.validation!(widget.field.title, numValue);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.option.hidden) return const SizedBox.shrink();

    final isOptional = widget.field.option.optional;
    final inputFormatters = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
    ];

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
            description: widget.field.description != null
                ? Text(widget.field.description!)
                : null,
            placeholder: const Text('Enter number...'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: inputFormatters,
            enabled: !isOptional || _isEnabled,
            validator: _validate,
          ),
        ),
      ],
    );
  }
}
