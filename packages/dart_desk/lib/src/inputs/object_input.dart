import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'string_input.dart';

@Preview(name: 'CmsObjectInput')
Widget preview() => ShadApp(
  home: CmsObjectInput(
    field: const CmsObjectField(
      name: 'address',
      title: 'Address',
      option: CmsObjectOption(
        fields: [
          CmsStringField(
            name: 'street',
            title: 'Street',
            option: CmsStringOption(),
          ),
          CmsStringField(
            name: 'city',
            title: 'City',
            option: CmsStringOption(),
          ),
          CmsStringField(
            name: 'zipCode',
            title: 'Zip Code',
            option: CmsStringOption(),
          ),
        ],
      ),
    ),
  ),
);

class CmsObjectInput extends StatelessWidget {
  final CmsObjectField field;
  final CmsData? data;
  final ValueChanged<Map<String, dynamic>?>? onChanged;

  const CmsObjectInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  Widget _buildFieldInput(CmsField field) {
    // For now, we only support string fields in objects
    // TODO: Support all field types recursively
    if (field is CmsStringField) {
      return CmsStringInput(field: field);
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (field.option.hidden) {
      return const SizedBox.shrink();
    }

    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.title,
            style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...field.option.fields.map((f) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildFieldInput(f),
            );
          }),
        ],
      ),
    );
  }
}
