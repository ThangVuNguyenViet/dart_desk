import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'DeskGeopointInput')
Widget preview() => ShadApp(
  home: DeskGeopointInput(
    field: const DeskGeopointField(
      name: 'location',
      title: 'Location',
      option: DeskGeopointOption(),
    ),
  ),
);

class DeskGeopointInput extends StatefulWidget {
  final DeskGeopointField field;
  final DeskData? data;
  final ValueChanged<Map<String, double>?>? onChanged;

  const DeskGeopointInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<DeskGeopointInput> createState() => _DeskGeopointInputState();
}

class _DeskGeopointInputState extends State<DeskGeopointInput> {
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late bool _isEnabled;
  Map<String, double>? _lastValue;
  bool _suppressEmit = false;

  @override
  void initState() {
    super.initState();
    final parsed = _parseValue(widget.data?.value);
    _latController = TextEditingController(text: parsed?['lat']?.toString());
    _lngController = TextEditingController(text: parsed?['lng']?.toString());
    _isEnabled = widget.field.option.optional ? parsed != null : true;
    _lastValue = parsed;
  }

  Map<String, double>? _parseValue(Object? raw) {
    if (raw is Map) {
      final lat = raw['lat'];
      final lng = raw['lng'];
      if (lat is num && lng is num) {
        return {'lat': lat.toDouble(), 'lng': lng.toDouble()};
      }
    }
    return null;
  }

  @override
  void didUpdateWidget(covariant DeskGeopointInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = _parseValue(widget.data?.value);
    final oldValue = _parseValue(oldWidget.data?.value);
    final changed =
        newValue?['lat'] != oldValue?['lat'] ||
        newValue?['lng'] != oldValue?['lng'];
    if (changed) {
      _suppressEmit = true;
      _latController.text = newValue?['lat']?.toString() ?? '';
      _lngController.text = newValue?['lng']?.toString() ?? '';
      _suppressEmit = false;
      if (widget.field.option.optional) {
        setState(() => _isEnabled = newValue != null);
      }
    }
  }

  void _handleToggle(bool enabled) {
    setState(() {
      if (!enabled) {
        final lat = double.tryParse(_latController.text);
        final lng = double.tryParse(_lngController.text);
        if (lat != null && lng != null) {
          _lastValue = {'lat': lat, 'lng': lng};
        }
        _isEnabled = false;
      } else {
        _isEnabled = true;
        final restore = _lastValue;
        _latController.text = restore?['lat']?.toString() ?? '';
        _lngController.text = restore?['lng']?.toString() ?? '';
      }
    });
    widget.onChanged?.call(enabled ? _lastValue : null);
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  String? _validateCoordinate(String? value, String type) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final doubleValue = double.tryParse(value);
    if (doubleValue == null) {
      return 'Please enter a valid number';
    }

    if (type == 'latitude') {
      if (doubleValue < -90 || doubleValue > 90) {
        return 'Latitude must be between -90 and 90';
      }
    } else if (type == 'longitude') {
      if (doubleValue < -180 || doubleValue > 180) {
        return 'Longitude must be between -180 and 180';
      }
    }

    return null;
  }

  void _emit() {
    if (!_isEnabled || _suppressEmit) return;
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat != null && lng != null) {
      _lastValue = {'lat': lat, 'lng': lng};
      widget.onChanged?.call({'lat': lat, 'lng': lng});
    } else {
      widget.onChanged?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOptional = widget.field.option.optional;
    final theme = ShadTheme.of(context);

    return Column(
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
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ShadInputFormField(
                        controller: _latController,
                        label: const Text('Latitude'),
                        placeholder: const Text('e.g., 37.7749'),
                        enabled: !isOptional || _isEnabled,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*\.?\d*'),
                          ),
                        ],
                        validator: (value) =>
                            _validateCoordinate(value, 'latitude'),
                        onChanged: (_) => _emit(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ShadInputFormField(
                        controller: _lngController,
                        label: const Text('Longitude'),
                        placeholder: const Text('e.g., -122.4194'),
                        enabled: !isOptional || _isEnabled,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*\.?\d*'),
                          ),
                        ],
                        validator: (value) =>
                            _validateCoordinate(value, 'longitude'),
                        onChanged: (_) => _emit(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.circleInfo,
                      size: 16,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Latitude: -90 to 90, Longitude: -180 to 180',
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ShadButton.outline(
                  size: ShadButtonSize.sm,
                  onPressed: () {
                    ShadToaster.of(context).show(
                      const ShadToast(
                        description: Text('Map picker coming soon!'),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(FontAwesomeIcons.locationDot, size: 16),
                      SizedBox(width: 8),
                      Text('Pick from map'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
