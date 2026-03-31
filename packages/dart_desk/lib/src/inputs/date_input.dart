import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'CmsDateInput')
Widget preview() => ShadApp(
  home: CmsDateInput(
    field: const CmsDateField(
      name: 'birthdate',
      title: 'Birth Date',
      option: CmsDateOption(),
    ),
  ),
);

class CmsDateInput extends StatefulWidget {
  final CmsDateField field;
  final CmsData? data;
  final ValueChanged<DateTime?>? onChanged;

  const CmsDateInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<CmsDateInput> createState() => _CmsDateInputState();
}

class _CmsDateInputState extends State<CmsDateInput> {
  DateTime? _selectedDate;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _selectedDate = switch (widget.data?.value) {
      DateTime dt => dt,
      String s => DateTime.tryParse(s),
      _ => null,
    };
    _isEnabled = widget.field.option.optional ? _selectedDate != null : true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.option.hidden) return const SizedBox.shrink();

    final isOptional = widget.field.option.optional;

    if (!isOptional) {
      return ShadDatePickerFormField(
        initialValue: _selectedDate,
        label: Text(widget.field.title),
        onChanged: (date) {
          setState(() => _selectedDate = date);
          widget.onChanged?.call(date);
        },
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
        const SizedBox(height: 8),
        OptionalFieldWrapper(
          isOptional: true,
          isEnabled: _isEnabled,
          onToggle: (value) {
            setState(() => _isEnabled = value);
            if (!value) {
              widget.onChanged?.call(null);
            } else if (_selectedDate != null) {
              widget.onChanged?.call(_selectedDate);
            }
          },
          child: ShadDatePickerFormField(
            initialValue: _selectedDate,
            onChanged: (date) {
              setState(() => _selectedDate = date);
              widget.onChanged?.call(date);
            },
          ),
        ),
      ],
    );
  }
}
