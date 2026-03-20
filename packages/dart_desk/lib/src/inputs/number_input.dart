import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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

class CmsNumberInput extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (field.option.hidden) {
      return const SizedBox.shrink();
    }

    return ShadInputFormField(
      initialValue: data?.value?.toString(),
      label: Text(field.title),
      placeholder: const Text('Enter number...'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (value) {
        if (onChanged != null) {
          final numValue = num.tryParse(value);
          onChanged!(numValue);
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          return null;
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }

        final numValue = double.parse(value);

        // Check min/max constraints
        if (field.option.min != null && numValue < field.option.min!) {
          return 'Value must be at least ${field.option.min}';
        }
        if (field.option.max != null && numValue > field.option.max!) {
          return 'Value must be at most ${field.option.max}';
        }

        // Apply custom validation if provided
        if (field.option.validation != null) {
          return field.option.validation!(field.title, numValue);
        }

        return null;
      },
    );
  }
}
