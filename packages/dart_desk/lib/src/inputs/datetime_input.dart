import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'CmsDateTimeInput')
Widget preview() => ShadApp(
  home: CmsDateTimeInput(
    field: const CmsDateTimeField(
      name: 'createdAt',
      title: 'Created At',
      option: CmsDateTimeOption(),
    ),
  ),
);

class CmsDateTimeInput extends StatefulWidget {
  final CmsDateTimeField field;
  final CmsData? data;
  final ValueChanged<DateTime?>? onChanged;

  const CmsDateTimeInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<CmsDateTimeInput> createState() => _CmsDateTimeInputState();
}

class _CmsDateTimeInputState extends State<CmsDateTimeInput> {
  DateTime? _selectedDateTime;
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
    if (widget.field.option.hidden) return const SizedBox.shrink();

    final isOptional = widget.field.option.optional;
    final theme = ShadTheme.of(context);

    final button = ShadButton.outline(
      onPressed: _selectDateTime,
      child: Text(
        _selectedDateTime != null
            ? _formatDateTime(_selectedDateTime!)
            : 'Select date and time',
      ),
    );

    if (!isOptional) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.field.title, style: theme.textTheme.small),
          const SizedBox(height: 8),
          button,
        ],
      );
    }

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
            } else if (_selectedDateTime != null) {
              widget.onChanged?.call(_selectedDateTime);
            }
          },
          child: button,
        ),
      ],
    );
  }
}
