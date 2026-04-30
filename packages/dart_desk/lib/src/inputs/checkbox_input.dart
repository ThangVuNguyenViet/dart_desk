import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

@Preview(name: 'DeskCheckboxInput')
Widget preview() => ShadApp(
  home: DeskCheckboxInput(
    field: const DeskCheckboxField(
      name: 'acceptTerms',
      title: 'Accept Terms',
      option: DeskCheckboxOption(label: 'I agree to the terms and conditions'),
    ),
  ),
);

class DeskCheckboxInput extends StatefulWidget {
  final DeskCheckboxField field;
  final DeskData? data;
  final ValueChanged<bool?>? onChanged;

  const DeskCheckboxInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<DeskCheckboxInput> createState() => _DeskCheckboxInputState();
}

class _DeskCheckboxInputState extends State<DeskCheckboxInput> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.data?.value as bool? ?? widget.field.option.initialValue;
  }

  @override
  void didUpdateWidget(DeskCheckboxInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _value = widget.data?.value as bool? ?? widget.field.option.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final label = widget.field.option.label ?? widget.field.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadCheckbox(
              value: _value,
              onChanged: (value) {
                setState(() {
                  _value = value;
                });
                widget.onChanged?.call(value);
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _value = !_value;
                  });
                  widget.onChanged?.call(_value);
                },
                child: Text(label, style: theme.textTheme.small),
              ),
            ),
          ],
        ),
        if (widget.field.description != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              widget.field.description!,
              style: theme.textTheme.muted,
            ),
          ),
        ],
      ],
    );
  }
}
