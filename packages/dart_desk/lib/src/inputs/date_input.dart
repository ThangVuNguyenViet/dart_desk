import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

@Preview(name: 'DeskDateInput')
Widget preview() => ShadApp(
  home: DeskDateInput(
    field: const DeskDateField(
      name: 'birthdate',
      title: 'Birth Date',
      option: DeskDateOption(),
    ),
  ),
);

class DeskDateInput extends StatefulWidget {
  final DeskDateField field;
  final DeskData? data;
  final ValueChanged<DateTime?>? onChanged;

  const DeskDateInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<DeskDateInput> createState() => _DeskDateInputState();
}

class _DeskDateInputState extends State<DeskDateInput> {
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
    return ShadDatePickerFormField(
      initialValue: _selectedDate,
      label: Text(widget.field.title),
      width: double.infinity,
      enabled: !widget.field.option.optional || _isEnabled,
      trailing: widget.field.option.optional
          ? ShadCheckbox(
              value: _isEnabled,
              onChanged: (value) {
                setState(() => _isEnabled = value);
                if (!value) {
                  widget.onChanged?.call(null);
                } else if (_selectedDate != null) {
                  widget.onChanged?.call(_selectedDate);
                }
              },
            )
          : null,
      onChanged: (date) {
        setState(() => _selectedDate = date);
        widget.onChanged?.call(date);
      },
    );
  }
}
