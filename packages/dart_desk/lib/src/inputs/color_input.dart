import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
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
    showDialog(
      context: context,
      builder: (context) => _ColorPickerDialog(
        initialColor: _selectedColor,
        showAlpha: widget.field.option.showAlpha,
        presetColors: widget.field.option.presetColors,
        onColorSelected: (color) {
          setState(() {
            _selectedColor = color;
          });
          widget.onChanged?.call(_colorToHex(color));
        },
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

/// Color picker dialog with RGB sliders
class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final bool showAlpha;
  final List<Color>? presetColors;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerDialog({
    required this.initialColor,
    required this.showAlpha,
    required this.presetColors,
    required this.onColorSelected,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late int _red;
  late int _green;
  late int _blue;
  late double _alpha;

  @override
  void initState() {
    super.initState();
    _red = widget.initialColor.red;
    _green = widget.initialColor.green;
    _blue = widget.initialColor.blue;
    _alpha = widget.initialColor.opacity;
  }

  Color get _currentColor => Color.fromRGBO(_red, _green, _blue, _alpha);

  void _setFromColor(Color color) {
    setState(() {
      _red = color.red;
      _green = color.green;
      _blue = color.blue;
      _alpha = color.opacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return AlertDialog(
      title: const Text('Pick a Color'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color preview
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.border),
              ),
            ),
            const SizedBox(height: 16),

            // Red slider
            _buildSlider(
              label: 'R',
              value: _red.toDouble(),
              max: 255,
              activeColor: Colors.red,
              onChanged: (value) {
                setState(() => _red = value.round());
              },
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, _green, _blue, 1),
                  Color.fromRGBO(255, _green, _blue, 1),
                ],
              ),
            ),

            // Green slider
            _buildSlider(
              label: 'G',
              value: _green.toDouble(),
              max: 255,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() => _green = value.round());
              },
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(_red, 0, _blue, 1),
                  Color.fromRGBO(_red, 255, _blue, 1),
                ],
              ),
            ),

            // Blue slider
            _buildSlider(
              label: 'B',
              value: _blue.toDouble(),
              max: 255,
              activeColor: Colors.blue,
              onChanged: (value) {
                setState(() => _blue = value.round());
              },
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(_red, _green, 0, 1),
                  Color.fromRGBO(_red, _green, 255, 1),
                ],
              ),
            ),

            // Alpha slider (if enabled)
            if (widget.showAlpha)
              _buildSlider(
                label: 'A',
                value: _alpha * 255,
                max: 255,
                onChanged: (value) {
                  setState(() => _alpha = value / 255);
                },
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(_red, _green, _blue, 0),
                    Color.fromRGBO(_red, _green, _blue, 1),
                  ],
                ),
              ),

            // Preset colors
            if (widget.presetColors != null) ...[
              const SizedBox(height: 16),
              const Text('Preset Colors'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.presetColors!.map((color) {
                  return InkWell(
                    onTap: () => _setFromColor(color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.border,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
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
            widget.onColorSelected(_currentColor);
            Navigator.of(context).pop();
          },
          child: const Text('Select'),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double max,
    required ValueChanged<double> onChanged,
    Gradient? gradient,
    Color? activeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.round()}',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          height: 20,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeColor?.withValues(alpha: 0.0),
              inactiveTrackColor: Colors.transparent,
              thumbColor: activeColor,
            ),
            child: Slider(value: value, max: max, onChanged: onChanged),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
