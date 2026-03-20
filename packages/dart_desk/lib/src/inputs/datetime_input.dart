import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedDateTime = switch (widget.data?.value) {
      DateTime dt => dt,
      String s => DateTime.tryParse(s),
      _ => null,
    };
  }

  Future<void> _selectDateTime() async {
    final date = await showShadDialog<DateTime>(
      context: context,
      builder:
          (context) => ShadDialog(
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
                  initialValue:
                      _selectedDateTime != null
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
      setState(() {
        _selectedDateTime = date;
      });
      widget.onChanged?.call(_selectedDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.option.hidden) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.field.title, style: ShadTheme.of(context).textTheme.small),
        const SizedBox(height: 8),
        ShadButton.outline(
          onPressed: _selectDateTime,
          child: Text(
            _selectedDateTime != null
                ? '${_selectedDateTime!.year}-${_selectedDateTime!.month.toString().padLeft(2, '0')}-${_selectedDateTime!.day.toString().padLeft(2, '0')} ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                : 'Select date and time',
          ),
        ),
      ],
    );
  }
}
