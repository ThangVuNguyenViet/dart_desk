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
  late bool? _value;

  @override
  void initState() {
    super.initState();
    _value = _parseValue(widget.data);
  }

  @override
  void didUpdateWidget(DeskBooleanInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      setState(() {
        _value = _parseValue(widget.data);
      });
    }
  }

  bool? _parseValue(DeskData? data) {
    if (widget.field.option.optional) {
      final raw = data?.value;
      if (raw == null) return null;
      return switch (raw) {
        bool b => b,
        'true' => true,
        'false' => false,
        _ => null,
      };
    } else {
      final raw = data?.value;
      return switch (raw) {
        bool b => b,
        'true' => true,
        _ => false,
      };
    }
  }

  void _handleTap() {
    final bool? next;
    if (widget.field.option.optional) {
      next = switch (_value) {
        null => false,
        false => true,
        true => null,
      };
    } else {
      next = !(_value ?? false);
    }
    setState(() {
      _value = next;
    });
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isOptional = widget.field.option.optional;
    final isNull = _value == null;

    // When optional and null, show the switch in the off position with reduced
    // opacity to indicate the indeterminate/unset state.
    return Opacity(
      opacity: (isOptional && isNull) ? 0.4 : 1.0,
      child: Row(
        children: [
          ShadSwitch(
            value: _value ?? false,
            onChanged: (_) => _handleTap(),
          ),
          const SizedBox(width: 12),
          Text(widget.field.title, style: theme.textTheme.small),
        ],
      ),
    );
  }
}
