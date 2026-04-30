import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

@Preview(name: 'DeskBooleanInput')
Widget preview() => ShadApp(
  home: DeskBooleanInput(
    field: const DeskBooleanField(
      name: 'isActive',
      title: 'Is Active',
      option: DeskBooleanOption(),
    ),
  ),
);

class DeskBooleanInput extends StatefulWidget {
  final DeskBooleanField field;
  final DeskData? data;
  final ValueChanged<bool?>? onChanged;
  const DeskBooleanInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });
  @override
  State<DeskBooleanInput> createState() => _DeskBooleanInputState();
}

class _DeskBooleanInputState extends State<DeskBooleanInput> {
  late bool _value;
  @override
  void initState() {
    super.initState();
    final raw = widget.data?.value;
    _value = switch (raw) {
      bool b => b,
      'true' => true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      children: [
        ShadSwitch(
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value;
            });
            widget.onChanged?.call(value);
          },
        ),
        const SizedBox(width: 12),
        Text(widget.field.title, style: theme.textTheme.small),
      ],
    );
  }
}
