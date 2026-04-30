import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

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
  DateTime? _lastValue;
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
    _lastValue = _selectedDate;
  }

  void _handleToggle(bool enabled) {
    setState(() {
      if (!enabled) {
        _lastValue = _selectedDate;
        _isEnabled = false;
      } else {
        _isEnabled = true;
        _selectedDate = _lastValue;
      }
    });
    widget.onChanged?.call(enabled ? _selectedDate : null);
  }

  @override
  void didUpdateWidget(covariant DeskDateInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = switch (widget.data?.value) {
      DateTime dt => dt,
      String s => DateTime.tryParse(s),
      _ => null,
    };
    final oldValue = switch (oldWidget.data?.value) {
      DateTime dt => dt,
      String s => DateTime.tryParse(s),
      _ => null,
    };
    if (oldValue != newValue) {
      setState(() {
        _selectedDate = newValue;
        if (widget.field.option.optional) {
          _isEnabled = newValue != null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.option.hidden) return const SizedBox.shrink();

    final isOptional = widget.field.option.optional;

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
          child: ShadDatePickerFormField(
            key: ValueKey(_selectedDate),
            initialValue: _selectedDate,
            width: double.infinity,
            enabled: !isOptional || _isEnabled,
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
