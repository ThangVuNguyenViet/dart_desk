/// Example: Extending CmsForm with Custom Field Types
///
/// This file demonstrates how to register custom field input builders
/// using the CmsFieldInputRegistry, inspired by dart_mappable's extensibility pattern.
///
/// NOTE: CmsColorField is now included as a default field type in the CMS!
/// This example shows how the pattern works by implementing a Rating field.
library;

import 'package:flutter/material.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../components/forms/cms_form.dart';

/// ColorField is now a built-in field type!
///
/// You can use it directly without any registration:
///
/// ```dart
/// @CmsConfig(
///   title: 'Theme Settings',
///   description: 'Customize your theme colors',
/// )
/// class ThemeConfig {
///   @CmsColorFieldConfig(
///     option: CmsColorOption(showAlpha: true),
///   )
///   final String primaryColor;
///
///   @CmsColorFieldConfig()
///   final String accentColor;
///
///   const ThemeConfig({
///     required this.primaryColor,
///     required this.accentColor,
///   });
/// }
/// ```
///
/// Or use it directly in CmsForm:
///
/// ```dart
/// CmsForm(
///   fields: [
///     CmsColorField(
///       name: 'brandColor',
///       title: 'Brand Color',
///       option: CmsColorOption(
///         showAlpha: true,
///         presetColors: [
///           Colors.red,
///           Colors.blue,
///           Colors.green,
///           Colors.amber,
///         ],
///       ),
///     ),
///   ],
/// )
/// ```

/// Example: Creating a completely custom field type (e.g., Rating field)
class CmsRatingField extends CmsField {
  const CmsRatingField({
    required super.name,
    required super.title,
    CmsRatingOption super.option = const CmsRatingOption(),
  });

  @override
  CmsRatingOption get option => super.option as CmsRatingOption;
}

class CmsRatingOption extends CmsOption {
  final int maxRating;
  final IconData icon;

  const CmsRatingOption({
    this.maxRating = 5,
    this.icon = FontAwesomeIcons.solidStar,
    super.hidden,
  });
}

/// Custom rating input widget
class CmsRatingInput extends StatefulWidget {
  final CmsRatingField field;
  final CmsData? data;
  final ValueChanged<int?>? onChanged;

  const CmsRatingInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<CmsRatingInput> createState() => _CmsRatingInputState();
}

class _CmsRatingInputState extends State<CmsRatingInput> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.data?.value as int? ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.option.hidden) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.field.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(widget.field.option.maxRating, (index) {
            final starIndex = index + 1;
            return ShadIconButton(
              icon: FaIcon(
                widget.field.option.icon,
                color: starIndex <= _rating ? Colors.amber : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _rating = starIndex;
                });
                widget.onChanged?.call(_rating);
              },
            );
          }),
        ),
      ],
    );
  }
}

/// Register the custom rating field
void registerRatingField() {
  CmsFieldInputRegistry.register<CmsRatingField>(
    (field, data, onChanged) => CmsRatingInput(
      field: field as CmsRatingField,
      data: data,
      onChanged: (value) => onChanged(field.name, value),
    ),
  );
}

/// Example usage:
///
/// ```dart
/// void main() {
///   // Register your custom fields before running the app
///   registerRatingField();
///
///   runApp(MyApp());
/// }
///
/// // Then use it in your forms:
/// CmsForm(
///   fields: [
///     CmsRatingField(
///       name: 'userRating',
///       title: 'Rate this product',
///       option: CmsRatingOption(
///         maxRating: 5,
///         icon: FontAwesomeIcons.solidStar,
///       ),
///     ),
///   ],
/// )
/// ```
