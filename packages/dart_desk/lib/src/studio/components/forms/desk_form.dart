import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../inputs/array_input.dart';
import '../../../inputs/block_input.dart';
import '../../../inputs/boolean_input.dart';
import '../../../inputs/checkbox_input.dart';
import '../../../inputs/color_input.dart';
import '../../../inputs/date_input.dart';
import '../../../inputs/datetime_input.dart';
import '../../../inputs/dropdown_input.dart';
import '../../../inputs/file_input.dart';
import '../../../inputs/geopoint_input.dart';
import '../../../inputs/image_input.dart';
import '../../../inputs/multi_dropdown_input.dart';
import '../../../inputs/number_input.dart';
import '../../../inputs/object_input.dart';
import '../../../inputs/string_input.dart';
import '../../../inputs/text_input.dart';
import '../../../inputs/url_input.dart';
import '../../core/view_models/desk_view_model.dart';
import '../../internal/get_it_condition_context.dart';

/// Type definition for field value change callbacks
typedef OnFieldChanged = void Function(String fieldName, dynamic value);

/// Type definition for field input builder functions
typedef FieldInputBuilder =
    Widget Function(DeskField? field, DeskData? data, OnFieldChanged onChanged);

/// Registry of field types to their corresponding input widgets.
/// Uses switch-case pattern for default field types with optional custom registry.
class DeskFieldInputRegistry {
  /// Map of custom field runtime types to their input builder functions
  static final Map<Type, FieldInputBuilder> _customRegistry =
      <Type, FieldInputBuilder>{};

  /// Register a custom field input builder for a specific field type.
  /// This allows extending the form system with custom field types.
  static void register<T extends DeskField>(FieldInputBuilder builder) {
    _customRegistry[T] = builder;
  }

  /// Get the input builder for a given field type using switch-case for defaults.
  /// Returns null if no builder is available for the type.
  static FieldInputBuilder? getBuilder(DeskField field) {
    // Check custom registry first
    if (_customRegistry.containsKey(field.runtimeType)) {
      return _customRegistry[field.runtimeType];
    }

    // Default field builders using switch-case
    switch (field) {
      case DeskTextField():
        return (_, data, onChanged) => DeskTextInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskStringField():
        return (_, data, onChanged) => DeskStringInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskNumberField():
        return (_, data, onChanged) => DeskNumberInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskBooleanField():
        return (_, data, onChanged) => DeskBooleanInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskCheckboxField():
        return (_, data, onChanged) => DeskCheckboxInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskDateField():
        return (_, data, onChanged) => DeskDateInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskDateTimeField():
        return (_, data, onChanged) => DeskDateTimeInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskDropdownField():
        return (_, data, onChanged) => DeskDropdownInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskMultiDropdownField():
        return (_, data, onChanged) => DeskMultiDropdownInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskUrlField():
        return (_, data, onChanged) => DeskUrlInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );

      case DeskImageField():
        return (_, data, onChanged) => DeskImageInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          dataSource: GetIt.I<DeskViewModel>().dataSource,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskFileField():
        return (_, data, onChanged) => DeskFileInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskArrayField():
        DeskArrayField.registerInputFactory(
          <T>(f, data, onChanged, key) => DeskArrayInput<T>(
            key: key,
            field: f,
            data: data,
            onChanged: onChanged,
          ),
        );
        return (_, data, onChanged) => field.buildInput(
          key: ValueKey(field.name),
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskBlockField():
        return (_, data, onChanged) => DeskBlockInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskObjectField():
        return (_, data, onChanged) => DeskObjectInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );

      case DeskGeopointField():
        return (_, data, onChanged) => DeskGeopointInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case DeskColorField():
        return (_, data, onChanged) => DeskColorInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      default:
        return null;
    }
  }

  /// Check if a builder is available for a given field type.
  static bool hasBuilder(DeskField field) {
    return getBuilder(field) != null;
  }
}

/// A form widget that renders fields based on DeskField list
class DeskForm extends StatefulWidget {
  final List<DeskField> fields;
  final Map<String, dynamic> data;
  final String? title;

  /// Callback when a field value changes
  final OnFieldChanged? onFieldChanged;

  const DeskForm({
    super.key,
    required this.fields,
    this.data = const {},
    this.title,
    this.onFieldChanged,
  });

  @override
  State<DeskForm> createState() => _DeskFormState();
}

class _DeskFormState extends State<DeskForm> {
  void _handleFieldChange(String fieldName, dynamic value) {
    // Call the external callback if provided
    widget.onFieldChanged?.call(fieldName, value);
  }

  Widget _buildFieldInput(BuildContext context, DeskField field) {
    final fieldName = field.name;
    final data = widget.data[fieldName] != null
        ? DeskData(value: widget.data[fieldName], path: fieldName)
        : null;

    // Special case: DeskImageField needs dataSource from the provider
    if (field is DeskImageField) {
      final dataSource = GetIt.I<DeskViewModel>().dataSource;
      return DeskImageInput(
        key: ValueKey(field.name),
        field: field,
        data: data,
        dataSource: dataSource,
        onChanged: (value) => _handleFieldChange(field.name, value),
      );
    }

    // Look up the builder for this field type in the registry
    final builder = DeskFieldInputRegistry.getBuilder(field);

    if (builder != null) {
      return builder(field, data, _handleFieldChange);
    }

    // If no builder found, return empty widget and log warning
    assert(
      false,
      'No input builder registered for field type: ${field.runtimeType}. '
      'Register a builder using DeskFieldInputRegistry.register<${field.runtimeType}>().',
    );
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList.list(
                  children: [
                    if (widget.title != null)
                      Text(widget.title!, style: theme.textTheme.h2),
                    const SizedBox(height: 12),
                    ...widget.fields
                        .where((field) {
                          final condition = field.option?.condition;
                          return condition == null ||
                              condition.evaluate(const GetItConditionContext());
                        })
                        .map((field) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildFieldInput(context, field),
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
