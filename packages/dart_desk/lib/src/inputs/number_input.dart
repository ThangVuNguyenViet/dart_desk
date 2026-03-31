import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'CmsNumberInput')
Widget preview() => ShadApp(
  home: CmsNumberInput(
    field: const CmsNumberField(
      name: 'age',
      title: 'Age',
      option: CmsNumberOption(min: 0, max: 120),
    ),
  ),
);

class CmsNumberInput extends StatefulWidget {
  final CmsNumberField field;
  final CmsData? data;
  final ValueChanged<num?>? onChanged;

  const CmsNumberInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<CmsNumberInput> createState() => _CmsNumberInputState();
}

class _CmsNumberInputState extends State<CmsNumberInput> {
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
    if (widget.field.option.min != null && numValue < widget.field.option.min!) {
      return 'Value must be at least ${widget.field.option.min}';
    }
    if (widget.field.option.max != null && numValue > widget.field.option.max!) {
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

    if (!isOptional) {
      return ShadInputFormField(
        initialValue: widget.data?.value?.toString(),
        label: Text(widget.field.title),
        placeholder: const Text('Enter number...'),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: inputFormatters,
        onChanged: (value) {
          widget.onChanged?.call(num.tryParse(value));
        },
        validator: _validate,
      );
    }

    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.field.title,
          style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
        ),
        if (widget.field.description != null) ...[
          const SizedBox(height: 2),
          Text(widget.field.description!, style: theme.textTheme.muted),
        ],
        const SizedBox(height: 8),
        OptionalFieldWrapper(
          isOptional: true,
          isEnabled: _isEnabled,
          onToggle: (value) {
            setState(() => _isEnabled = value);
            if (!value) widget.onChanged?.call(null);
          },
          child: ShadInputFormField(
            initialValue: widget.data?.value?.toString(),
            placeholder: const Text('Enter number...'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: inputFormatters,
            onChanged: (value) {
              if (_isEnabled) widget.onChanged?.call(num.tryParse(value));
            },
            validator: _validate,
          ),
        ),
      ],
    );
  }
}
