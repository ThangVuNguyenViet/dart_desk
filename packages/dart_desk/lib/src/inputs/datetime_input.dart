import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'DeskDateTimeInput')
Widget preview() => ShadApp(
  home: DeskDateTimeInput(
    field: const DeskDateTimeField(
      name: 'createdAt',
      title: 'Created At',
      option: DeskDateTimeOption(),
    ),
  ),
);

class DeskDateTimeInput extends StatefulWidget {
  final DeskDateTimeField field;
  final DeskData? data;
  final ValueChanged<DateTime?>? onChanged;

  const DeskDateTimeInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<DeskDateTimeInput> createState() => _DeskDateTimeInputState();
}

class _DeskDateTimeInputState extends State<DeskDateTimeInput> {
  DateTime? _selectedDateTime;
  DateTime? _lastValue;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = switch (widget.data?.value) {
      DateTime dt => dt,
      String s => DateTime.tryParse(s),
      _ => null,
    };
    _isEnabled = widget.field.option.optional
        ? _selectedDateTime != null
        : true;
    _lastValue = _selectedDateTime;
  }

  void _handleToggle(bool enabled) {
    setState(() {
      if (!enabled) {
        _lastValue = _selectedDateTime;
        _isEnabled = false;
      } else {
        _isEnabled = true;
        _selectedDateTime = _lastValue;
      }
    });
    widget.onChanged?.call(enabled ? _selectedDateTime : null);
  }

  @override
  void didUpdateWidget(covariant DeskDateTimeInput oldWidget) {
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
        _selectedDateTime = newValue;
        if (widget.field.option.optional) {
          _isEnabled = newValue != null;
        }
      });
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showShadDialog<DateTime>(
      context: context,
      builder: (context) => ShadDialog(
        title: Text(widget.field.title),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ShadButton(
            size: ShadButtonSize.sm,
            onPressed: () {
              Navigator.pop(context, _selectedDateTime);
            },
            child: const Text('Select'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadDatePicker(
              selected: _selectedDateTime,
              onChanged: (date) {
                if (date != null) {
                  setState(() {
                    _selectedDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      _selectedDateTime?.hour ?? DateTime.now().hour,
                      _selectedDateTime?.minute ?? DateTime.now().minute,
                    );
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ShadTimePickerFormField(
              initialValue: _selectedDateTime != null
                  ? ShadTimeOfDay.fromDateTime(_selectedDateTime!)
                  : ShadTimeOfDay.now(),
              onChanged: (time) {
                if (time != null) {
                  setState(() {
                    final date = _selectedDateTime ?? DateTime.now();
                    _selectedDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              },
            ),
          ],
        ),
      ),
    );

    if (date != null) {
      setState(() => _selectedDateTime = date);
      widget.onChanged?.call(_selectedDateTime);
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
          child: ShadButton.outline(
            onPressed: _selectDateTime,
            child: Text(
              _selectedDateTime != null
                  ? _formatDateTime(_selectedDateTime!)
                  : 'Select date and time',
            ),
          ),
        ),
      ],
    );
  }
}
