import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  late bool? _value;

  @override
  void initState() {
    super.initState();
    _value = _parseValue(widget.data);
  }

  @override
  void didUpdateWidget(DeskCheckboxInput oldWidget) {
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
      return raw as bool?;
    } else {
      return data?.value as bool? ?? widget.field.option.initialValue;
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
    if (widget.field.option.hidden) {
      return const SizedBox.shrink();
    }

    final theme = ShadTheme.of(context);
    final label = widget.field.option.label ?? widget.field.title;
    final isOptional = widget.field.option.optional;
    final isNull = _value == null;

    // For tri-state null: render as checked (filled box) but with a dash
    // icon to indicate the indeterminate/unset state. ShadCheckbox only
    // renders its icon when value==true, so we pass value:true + dash icon.
    final bool checkboxValue;
    final Widget? checkboxIcon;
    if (isOptional && isNull) {
      checkboxValue = true;
      checkboxIcon = Icon(
        LucideIcons.minus,
        color: ShadTheme.of(context).colorScheme.primaryForeground,
        size: 16,
      );
    } else {
      checkboxValue = _value ?? false;
      checkboxIcon = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadCheckbox(
              value: checkboxValue,
              icon: checkboxIcon,
              onChanged: (_) => _handleTap(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _handleTap,
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
