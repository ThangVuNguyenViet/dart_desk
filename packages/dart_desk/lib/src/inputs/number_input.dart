import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.field.option.optional
        ? widget.data?.value != null
        : true;
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
    final inputFormatters = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
    ];

    return ShadInputFormField(
      initialValue: widget.data?.value?.toString(),
      label: Text(widget.field.title),
      description: widget.field.description != null
          ? Text(widget.field.description!)
          : null,
      placeholder: const Text('Enter number...'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: inputFormatters,
      enabled: !widget.field.option.optional || _isEnabled,
      trailing: widget.field.option.optional
          ? ShadCheckbox(
              value: _isEnabled,
              onChanged: (value) {
                setState(() => _isEnabled = value);
                if (!value) widget.onChanged?.call(null);
              },
            )
          : null,
      onChanged: (value) {
        if (_isEnabled) widget.onChanged?.call(num.tryParse(value));
      },
      validator: _validate,
    );
  }
}
