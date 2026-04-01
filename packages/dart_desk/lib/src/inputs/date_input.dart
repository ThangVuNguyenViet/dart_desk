import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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

    return ShadDatePickerFormField(
      initialValue: _selectedDate,
      label: Text(widget.field.title),
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
