import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'package:get_it/get_it.dart';

import '../studio/core/view_models/desk_view_model.dart';

/// Test document type that exercises all 16 CMS field types.
/// Use this in test apps to get full field coverage.
final allFieldsDocumentType = DocumentType(
  name: 'test_all_fields',
  title: 'Test All Fields',
  description: 'Document type with all 16 field types for QA testing',
  fields: [
    // Primitive fields (8)
    const DeskStringField(
      name: 'string_field',
      title: 'String Field',
      description: 'A single-line string input',
      option: DeskStringOption(),
    ),
    const DeskTextField(
      name: 'text_field',
      title: 'Text Field',
      description: 'A multi-line text area',
      option: DeskTextOption(rows: 3),
    ),
    const DeskNumberField(
      name: 'number_field',
      title: 'Number Field',
      description: 'A numeric input',
      option: DeskNumberOption(),
    ),
    const DeskBooleanField(
      name: 'boolean_field',
      title: 'Boolean Field',
      description: 'A toggle switch',
      option: DeskBooleanOption(),
    ),
    const DeskCheckboxField(
      name: 'checkbox_field',
      title: 'Checkbox Field',
      description: 'A checkbox control',
      option: DeskCheckboxOption(label: 'Enable this feature'),
    ),
    const DeskUrlField(
      name: 'url_field',
      title: 'URL Field',
      description: 'A URL input',
      option: DeskUrlOption(),
    ),
    const DeskDateField(
      name: 'date_field',
      title: 'Date Field',
      description: 'A date picker',
      option: DeskDateOption(),
    ),
    const DeskDateTimeField(
      name: 'datetime_field',
      title: 'DateTime Field',
      description: 'A date and time picker',
      option: DeskDateTimeOption(),
    ),
    // Media fields (3)
    const DeskColorField(
      name: 'color_field',
      title: 'Color Field',
      description: 'A color picker',
      option: DeskColorOption(showAlpha: true),
    ),
    const DeskImageField(
      name: 'image_field',
      title: 'Image Field',
      description: 'An image upload/URL field',
      option: DeskImageOption(hotspot: true),
    ),
    const DeskFileField(
      name: 'file_field',
      title: 'File Field',
      description: 'A file upload field',
      option: DeskFileOption(),
    ),
    // Complex fields (5)
    const DeskDropdownField<String>(
      name: 'dropdown_field',
      title: 'Dropdown Field',
      description: 'A dropdown select',
      option: DeskDropdownSimpleOption(
        options: [
          DropdownOption(value: 'option_a', label: 'Option A'),
          DropdownOption(value: 'option_b', label: 'Option B'),
          DropdownOption(value: 'option_c', label: 'Option C'),
        ],
        placeholder: 'Select an option',
      ),
    ),
    DeskMultiDropdownField<String>(
      name: 'document_ref_dropdown',
      title: 'Document Reference',
      description:
          'Context-aware multi-select dropdown that loads documents reactively',
      option: TestDocumentRefDropdownOption(),
    ),
    DeskArrayField<String>(
      name: 'array_field',
      title: 'Array Field',
      description: 'A list of string items',
      innerField: const DeskStringField(name: 'item', title: 'Item'),
      option: const TestStringArrayOption(),
    ),
    const DeskObjectField(
      name: 'object_field',
      title: 'Object Field',
      description: 'A nested object with sub-fields',
      option: DeskObjectOption(
        children: [
          ColumnFields(
            children: [
              DeskStringField(
                name: 'nested_title',
                title: 'Nested Title',
                option: DeskStringOption(),
              ),
            ],
          ),
          RowFields(
            children: [
              DeskNumberField(
                name: 'nested_count',
                title: 'Nested Count',
                option: DeskNumberOption(),
              ),
              DeskStringField(
                name: 'nested_tag',
                title: 'Nested Tag',
                option: DeskStringOption(),
              ),
            ],
          ),
          GroupFields(
            title: 'Extra Details',
            description: 'Optional metadata',
            collapsible: true,
            collapsed: true,
            children: [
              ColumnFields(
                children: [
                  DeskStringField(
                    name: 'nested_notes',
                    title: 'Nested Notes',
                    option: DeskStringOption(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
    const DeskBlockField(
      name: 'block_field',
      title: 'Block Field',
      option: DeskBlockOption(),
    ),
    const DeskGeopointField(
      name: 'geopoint_field',
      title: 'Geopoint Field',
      option: DeskGeopointOption(),
    ),
  ],
  builder: _testAllFieldsBuilder,
);

Widget _testAllFieldsBuilder(Map<String, dynamic> data) {
  return Builder(
    builder: (context) {
      // Resolve selected document titles from the context-aware multi-dropdown
      final selectedIds = data['document_ref_dropdown'];
      String? selectedDocTitles;
      if (selectedIds is List && selectedIds.isNotEmpty) {
        final viewModel = GetIt.I<DeskViewModel>();
        final state = viewModel
            .documentsContainer('test_all_fields')
            .watch(context);
        selectedDocTitles = state.map(
          data: (list) => selectedIds
              .map(
                (id) => list.documents
                    .where((d) => d.id.toString() == id)
                    .firstOrNull
                    ?.title,
              )
              .whereType<String>()
              .join(', '),
          loading: () => null,
          error: (_, _) => null,
        );
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('preview:string_field: ${data['string_field'] ?? ''}'),
              Text('preview:number_field: ${data['number_field'] ?? ''}'),
              Text('preview:boolean_field: ${data['boolean_field'] ?? ''}'),
              Text('preview:checkbox_field: ${data['checkbox_field'] ?? ''}'),
              Text('preview:url_field: ${data['url_field'] ?? ''}'),
              Text('preview:date_field: ${data['date_field'] ?? ''}'),
              Text('preview:datetime_field: ${data['datetime_field'] ?? ''}'),
              Text('preview:color_field: ${data['color_field'] ?? ''}'),
              Text('preview:dropdown_field: ${data['dropdown_field'] ?? ''}'),
              Text(
                'preview:document_ref_dropdown: ${data['document_ref_dropdown'] ?? '[]'}'
                '${selectedDocTitles != null ? ' ($selectedDocTitles)' : ''}',
              ),
              Text('preview:text_field: ${data['text_field'] ?? ''}'),
              Text('preview:image_field: ${data['image_field'] ?? ''}'),
              Text('preview:file_field: ${data['file_field'] ?? ''}'),
              Text('preview:array_field: ${data['array_field'] ?? ''}'),
              Text('preview:object_field: ${data['object_field'] ?? ''}'),
              Text('preview:block_field: ${data['block_field'] ?? ''}'),
              Text('preview:geopoint_field: ${data['geopoint_field'] ?? ''}'),
            ],
          ),
        ),
      );
    },
  );
}

/// Concrete DeskArrayOption for testing string arrays.
class TestStringArrayOption extends DeskArrayOption<String> {
  const TestStringArrayOption();

  @override
  DeskArrayFieldItemBuilder<String> get itemBuilder =>
      (context, value) => Text(value);
}

/// Context-aware multi-dropdown option that resolves options reactively from
/// the documents of type 'test_all_fields' via DeskViewModel signals.
class TestDocumentRefDropdownOption extends DeskMultiDropdownOption<String> {
  const TestDocumentRefDropdownOption();

  @override
  List<DropdownOption<String>> options(BuildContext context) {
    final viewModel = GetIt.I<DeskViewModel>();
    final state = viewModel
        .documentsContainer('test_all_fields')
        .watch(context);
    return state.map(
      data: (list) => list.documents
          .map((d) => DropdownOption(value: d.id.toString(), label: d.title))
          .toList(),
      loading: () => [],
      error: (_, _) => [],
    );
  }

  @override
  List<String>? get defaultValues => null;

  @override
  String? get placeholder => 'Select documents...';

  @override
  int? get minSelected => null;

  @override
  int? get maxSelected => null;
}
