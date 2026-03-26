import 'package:flutter/material.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../inputs/array_input.dart';
import '../../../inputs/block_input.dart';
import '../../../inputs/boolean_input.dart';
import '../../../inputs/checkbox_input.dart';
import '../../../inputs/color_input.dart';
import '../../../inputs/date_input.dart';
import '../../../inputs/datetime_input.dart';
import '../../../inputs/dropdown_input.dart';
import '../../../inputs/multi_dropdown_input.dart';
import '../../../inputs/file_input.dart';
import '../../../inputs/geopoint_input.dart';
import '../../../inputs/image_input.dart';
import '../../../inputs/number_input.dart';
import 'package:get_it/get_it.dart';

import '../../core/view_models/cms_view_model.dart';
import '../../../inputs/object_input.dart';
import '../../../inputs/string_input.dart';
import '../../../inputs/text_input.dart';
import '../../../inputs/url_input.dart';

/// Type definition for field value change callbacks
typedef OnFieldChanged = void Function(String fieldName, dynamic value);

/// Type definition for field input builder functions
typedef FieldInputBuilder =
    Widget Function(CmsField? field, CmsData? data, OnFieldChanged onChanged);

/// Registry of field types to their corresponding input widgets.
/// Uses switch-case pattern for default field types with optional custom registry.
class CmsFieldInputRegistry {
  /// Map of custom field runtime types to their input builder functions
  static final Map<Type, FieldInputBuilder> _customRegistry =
      <Type, FieldInputBuilder>{};

  /// Register a custom field input builder for a specific field type.
  /// This allows extending the form system with custom field types.
  static void register<T extends CmsField>(FieldInputBuilder builder) {
    _customRegistry[T] = builder;
  }

  /// Get the input builder for a given field type using switch-case for defaults.
  /// Returns null if no builder is available for the type.
  static FieldInputBuilder? getBuilder(CmsField field) {
    // Check custom registry first
    if (_customRegistry.containsKey(field.runtimeType)) {
      return _customRegistry[field.runtimeType];
    }

    // Default field builders using switch-case
    switch (field) {
      case CmsTextField():
        return (_, data, onChanged) => CmsTextInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsStringField():
        return (_, data, onChanged) => CmsStringInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsNumberField():
        return (_, data, onChanged) => CmsNumberInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsBooleanField():
        return (_, data, onChanged) => CmsBooleanInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsCheckboxField():
        return (_, data, onChanged) => CmsCheckboxInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsDateField():
        return (_, data, onChanged) => CmsDateInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsDateTimeField():
        return (_, data, onChanged) => CmsDateTimeInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsDropdownField():
        return (_, data, onChanged) => CmsDropdownInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsMultiDropdownField():
        return (_, data, onChanged) => CmsMultiDropdownInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsUrlField():
        return (_, data, onChanged) => CmsUrlInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );

      case CmsImageField():
        return (_, data, onChanged) => CmsImageInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsFileField():
        return (_, data, onChanged) => CmsFileInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsArrayField():
        return (_, data, onChanged) => CmsArrayInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsBlockField():
        return (_, data, onChanged) => CmsBlockInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsObjectField():
        return (_, data, onChanged) => CmsObjectInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );

      case CmsGeopointField():
        return (_, data, onChanged) => CmsGeopointInput(
          key: ValueKey(field.name),
          field: field,
          data: data,
          onChanged: (value) => onChanged(field.name, value),
        );
      case CmsColorField():
        return (_, data, onChanged) => CmsColorInput(
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
  static bool hasBuilder(CmsField field) {
    return getBuilder(field) != null;
  }
}

/// A form widget that renders fields based on CmsField list
class CmsForm extends StatefulWidget {
  final List<CmsField> fields;
  final Map<String, dynamic> data;
  final String? title;

  /// Callback when a field value changes
  final OnFieldChanged? onFieldChanged;

  const CmsForm({
    super.key,
    required this.fields,
    this.data = const {},
    this.title,
    this.onFieldChanged,
  });

  @override
  State<CmsForm> createState() => _CmsFormState();
}

class _CmsFormState extends State<CmsForm> {
  void _handleFieldChange(String fieldName, dynamic value) {
    // Call the external callback if provided
    widget.onFieldChanged?.call(fieldName, value);
  }

  Widget _buildFieldInput(BuildContext context, CmsField field) {
    final fieldName = field.name;
    final data = widget.data[fieldName] != null
        ? CmsData(value: widget.data[fieldName], path: fieldName)
        : null;

    // Special case: CmsImageField needs dataSource from the provider
    if (field is CmsImageField) {
      final dataSource = GetIt.I<CmsViewModel>().dataSource;
      return CmsImageInput(
        key: ValueKey(field.name),
        field: field,
        data: data,
        dataSource: dataSource,
        onChanged: (value) => _handleFieldChange(field.name, value),
      );
    }

    // Look up the builder for this field type in the registry
    final builder = CmsFieldInputRegistry.getBuilder(field);

    if (builder != null) {
      return builder(field, data, _handleFieldChange);
    }

    // If no builder found, return empty widget and log warning
    assert(
      false,
      'No input builder registered for field type: ${field.runtimeType}. '
      'Register a builder using CmsFieldInputRegistry.register<${field.runtimeType}>().',
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
                    ...widget.fields.map((field) {
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
