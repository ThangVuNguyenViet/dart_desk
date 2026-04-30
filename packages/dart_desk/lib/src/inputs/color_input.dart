import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

/// Color picker input widget with full functionality
class DeskColorInput extends StatefulWidget {
  final DeskColorField field;
  final DeskData? data;
  final ValueChanged<String?>? onChanged;

  const DeskColorInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<DeskColorInput> createState() => _DeskColorInputState();
}

class _DeskColorInputState extends State<DeskColorInput> {
  late Color _selectedColor;
  String? _lastValue;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final parsedColor = _parseColor(widget.data?.value?.toString());
    _selectedColor = parsedColor ?? Colors.black;
    _isEnabled = widget.field.option.optional ? parsedColor != null : true;
    _lastValue = widget.data?.value?.toString();
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      final hexColor = colorString.replaceFirst('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
    } catch (e) {
      // Invalid color format
    }
    return null;
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  void _handleToggle(bool enabled) {
    setState(() {
      if (!enabled) {
        _lastValue = _colorToHex(_selectedColor);
        _isEnabled = false;
      } else {
        _isEnabled = true;
        if (_lastValue != null) {
          final restored = _parseColor(_lastValue);
          if (restored != null) _selectedColor = restored;
        }
      }
    });
    widget.onChanged?.call(enabled ? _colorToHex(_selectedColor) : null);
  }

  @override
  void didUpdateWidget(covariant DeskColorInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.data?.value?.toString();
    if (oldWidget.data?.value?.toString() != newValue) {
      final parsedColor = _parseColor(newValue);
      setState(() {
        _selectedColor = parsedColor ?? Colors.black;
        if (widget.field.option.optional) {
          _isEnabled = parsedColor != null;
        }
      });
    }
  }

  void _showColorPicker() {
    Color pickerColor = _selectedColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            enableAlpha: widget.field.option.showAlpha,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ShadButton(
            size: ShadButtonSize.sm,
            onPressed: () {
              setState(() {
                _selectedColor = pickerColor;
              });
              widget.onChanged?.call(_colorToHex(pickerColor));
              Navigator.of(context).pop();
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isOptional = widget.field.option.optional;

    return Material(
      child: Column(
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
            child: Row(
              children: [
                InkWell(
                  onTap: _showColorPicker,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      border: Border.all(
                        color: theme.colorScheme.border,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShadInput(
                    initialValue: _colorToHex(_selectedColor),
                    onChanged: (value) {
                      final color = _parseColor(value);
                      if (color != null) {
                        setState(() {
                          _selectedColor = color;
                        });
                        widget.onChanged?.call(value);
                      }
                    },
                    placeholder: const Text('#RRGGBB'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
