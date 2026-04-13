import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Color picker input widget with full functionality
class CmsColorInput extends StatefulWidget {
  final CmsColorField field;
  final CmsData? data;
  final ValueChanged<String?>? onChanged;

  const CmsColorInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<CmsColorInput> createState() => _CmsColorInputState();
}

class _CmsColorInputState extends State<CmsColorInput> {
  late Color _selectedColor;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final parsedColor = _parseColor(widget.data?.value?.toString());
    _selectedColor = parsedColor ?? Colors.black;
    _isEnabled = widget.field.option.optional ? parsedColor != null : true;
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
    if (widget.field.option.hidden) {
      return const SizedBox.shrink();
    }

    final theme = ShadTheme.of(context);
    final isOptional = widget.field.option.optional;

    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.field.title,
            style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: IgnorePointer(
                  ignoring: !_isEnabled,
                  child: AnimatedOpacity(
                    opacity: _isEnabled ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 200),
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
                ),
              ),
              if (isOptional) ...[
                const SizedBox(width: 8),
                ShadCheckbox(
                  value: _isEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isEnabled = value;
                    });
                    if (!value) {
                      widget.onChanged?.call(null);
                    } else {
                      widget.onChanged?.call(_colorToHex(_selectedColor));
                    }
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
