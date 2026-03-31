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
          Row(
            children: [
              Text(
                widget.field.title,
                style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
              ),
              if (isOptional) ...[
                const SizedBox(width: 8),
                SizedBox(
                  height: 20,
                  width: 36,
                  child: Switch(
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
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          IgnorePointer(
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
        ],
      ),
    );
  }
}

/// Color picker dialog with HSV color wheel
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
  late HSVColor _hsvColor;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor);
  }

  void _updateColor(HSVColor newColor) {
    setState(() {
      _hsvColor = newColor;
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
                color: _hsvColor.toColor(),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.border),
              ),
            ),
            const SizedBox(height: 16),

            // Hue slider
            _buildSlider(
              label: 'Hue',
              value: _hsvColor.hue,
              max: 360,
              onChanged: (value) {
                _updateColor(_hsvColor.withHue(value));
              },
              gradient: LinearGradient(
                colors: [
                  const HSVColor.fromAHSV(1, 0, 1, 1).toColor(),
                  const HSVColor.fromAHSV(1, 60, 1, 1).toColor(),
                  const HSVColor.fromAHSV(1, 120, 1, 1).toColor(),
                  const HSVColor.fromAHSV(1, 180, 1, 1).toColor(),
                  const HSVColor.fromAHSV(1, 240, 1, 1).toColor(),
                  const HSVColor.fromAHSV(1, 300, 1, 1).toColor(),
                  const HSVColor.fromAHSV(1, 360, 1, 1).toColor(),
                ],
              ),
            ),

            // Saturation slider
            _buildSlider(
              label: 'Saturation',
              value: _hsvColor.saturation,
              max: 1,
              onChanged: (value) {
                _updateColor(_hsvColor.withSaturation(value));
              },
              gradient: LinearGradient(
                colors: [
                  _hsvColor.withSaturation(0).toColor(),
                  _hsvColor.withSaturation(1).toColor(),
                ],
              ),
            ),

            // Value/Brightness slider
            _buildSlider(
              label: 'Brightness',
              value: _hsvColor.value,
              max: 1,
              onChanged: (value) {
                _updateColor(_hsvColor.withValue(value));
              },
              gradient: LinearGradient(
                colors: [
                  _hsvColor.withValue(0).toColor(),
                  _hsvColor.withValue(1).toColor(),
                ],
              ),
            ),

            // Alpha slider (if enabled)
            if (widget.showAlpha)
              _buildSlider(
                label: 'Opacity',
                value: _hsvColor.alpha,
                max: 1,
                onChanged: (value) {
                  _updateColor(_hsvColor.withAlpha(value));
                },
                gradient: LinearGradient(
                  colors: [
                    _hsvColor.withAlpha(0).toColor(),
                    _hsvColor.withAlpha(1).toColor(),
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
                    onTap: () {
                      _updateColor(HSVColor.fromColor(color));
                    },
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
            widget.onColorSelected(_hsvColor.toColor());
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${(value / max * 100).toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          height: 20,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Slider(value: value, max: max, onChanged: onChanged),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
