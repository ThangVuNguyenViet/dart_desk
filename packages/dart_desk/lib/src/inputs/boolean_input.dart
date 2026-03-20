import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

@Preview(name: 'CmsBooleanInput')
Widget preview() => ShadApp(
  home: CmsBooleanInput(
    field: const CmsBooleanField(
      name: 'isActive',
      title: 'Is Active',
      option: CmsBooleanOption(),
    ),
  ),
);

class CmsBooleanInput extends StatefulWidget {
  final CmsBooleanField field;
  final CmsData? data;
  final ValueChanged<bool?>? onChanged;
  const CmsBooleanInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });
  @override
  State<CmsBooleanInput> createState() => _CmsBooleanInputState();
}

class _CmsBooleanInputState extends State<CmsBooleanInput> {
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
    if (widget.field.option.hidden) {
      return const SizedBox.shrink();
    }
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
