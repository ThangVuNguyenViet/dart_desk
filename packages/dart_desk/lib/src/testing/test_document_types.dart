import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'package:get_it/get_it.dart';

import '../studio/core/view_models/cms_view_model.dart';

/// Test document type that exercises all 16 CMS field types.
/// Use this in test apps to get full field coverage.
final allFieldsDocumentType = DocumentType(
  name: 'test_all_fields',
  title: 'Test All Fields',
  description: 'Document type with all 16 field types for QA testing',
  fields: [
    // Primitive fields (8)
    const CmsStringField(
      name: 'string_field',
      title: 'String Field',
      description: 'A single-line string input',
      option: CmsStringOption(),
    ),
    const CmsTextField(
      name: 'text_field',
      title: 'Text Field',
      description: 'A multi-line text area',
      option: CmsTextOption(rows: 3),
    ),
    const CmsNumberField(
      name: 'number_field',
      title: 'Number Field',
      description: 'A numeric input',
      option: CmsNumberOption(),
    ),
    const CmsBooleanField(
      name: 'boolean_field',
      title: 'Boolean Field',
      description: 'A toggle switch',
      option: CmsBooleanOption(),
    ),
    const CmsCheckboxField(
      name: 'checkbox_field',
      title: 'Checkbox Field',
      description: 'A checkbox control',
      option: CmsCheckboxOption(label: 'Enable this feature'),
    ),
    const CmsUrlField(
      name: 'url_field',
      title: 'URL Field',
      description: 'A URL input',
      option: CmsUrlOption(),
    ),
    const CmsDateField(
      name: 'date_field',
      title: 'Date Field',
      description: 'A date picker',
      option: CmsDateOption(),
    ),
    const CmsDateTimeField(
      name: 'datetime_field',
      title: 'DateTime Field',
      description: 'A date and time picker',
      option: CmsDateTimeOption(),
    ),
    // Media fields (3)
    const CmsColorField(
      name: 'color_field',
      title: 'Color Field',
      description: 'A color picker',
      option: CmsColorOption(showAlpha: true),
    ),
    const CmsImageField(
      name: 'image_field',
      title: 'Image Field',
      description: 'An image upload/URL field',
      option: CmsImageOption(hotspot: true),
    ),
    const CmsFileField(
      name: 'file_field',
      title: 'File Field',
      description: 'A file upload field',
      option: CmsFileOption(),
    ),
    // Complex fields (5)
    const CmsDropdownField<String>(
      name: 'dropdown_field',
      title: 'Dropdown Field',
      description: 'A dropdown select',
      option: CmsDropdownSimpleOption(
        options: [
          DropdownOption(value: 'option_a', label: 'Option A'),
          DropdownOption(value: 'option_b', label: 'Option B'),
          DropdownOption(value: 'option_c', label: 'Option C'),
        ],
        placeholder: 'Select an option',
      ),
    ),
    CmsMultiDropdownField<String>(
      name: 'document_ref_dropdown',
      title: 'Document Reference',
      description:
          'Context-aware multi-select dropdown that loads documents reactively',
      option: TestDocumentRefDropdownOption(),
    ),
    CmsArrayField<String>(
      name: 'array_field',
      title: 'Array Field',
      description: 'A list of string items',
      option: TestStringArrayOption(),
    ),
    const CmsObjectField(
      name: 'object_field',
      title: 'Object Field',
      description: 'A nested object with sub-fields',
      option: CmsObjectOption(
        children: [
          ColumnFields(
            children: [
              CmsStringField(
                name: 'nested_title',
                title: 'Nested Title',
                option: CmsStringOption(),
              ),
            ],
          ),
          RowFields(
            children: [
              CmsNumberField(
                name: 'nested_count',
                title: 'Nested Count',
                option: CmsNumberOption(),
              ),
              CmsStringField(
                name: 'nested_tag',
                title: 'Nested Tag',
                option: CmsStringOption(),
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
                  CmsStringField(
                    name: 'nested_notes',
                    title: 'Nested Notes',
                    option: CmsStringOption(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
    const CmsBlockField(
      name: 'block_field',
      title: 'Block Field',
      option: CmsBlockOption(),
    ),
    const CmsGeopointField(
      name: 'geopoint_field',
      title: 'Geopoint Field',
      option: CmsGeopointOption(),
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
        final viewModel = GetIt.I<CmsViewModel>();
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

/// Concrete CmsArrayOption for testing string arrays.
class TestStringArrayOption extends CmsArrayOption<String> {
  const TestStringArrayOption();

  @override
  CmsArrayFieldItemBuilder<String> get itemBuilder =>
      (context, value) => Text(value);
}

/// Context-aware multi-dropdown option that resolves options reactively from
/// the documents of type 'test_all_fields' via CmsViewModel signals.
class TestDocumentRefDropdownOption extends CmsMultiDropdownOption<String> {
  const TestDocumentRefDropdownOption();

  @override
  List<DropdownOption<String>> options(BuildContext context) {
    final viewModel = GetIt.I<CmsViewModel>();
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

/// Seed data for 3 test documents with known values.
const testDocumentSeedData = [
  {
    'title': 'Test Document Alpha',
    'slug': 'test-document-alpha',
    'data': {
      'string_field': 'Hello World',
      'text_field': 'This is a multi-line\ntext field value.',
      'number_field': 42,
      'boolean_field': true,
      'checkbox_field': false,
      'url_field': 'https://example.com',
      'date_field': '2026-03-01',
      'datetime_field': '2026-03-01T10:30:00',
      'color_field': '#FF5733',
      'image_field': {'_type': 'imageReference', 'assetId': 'asset-hero'},
      'file_field': null,
      'dropdown_field': 'option_a',
      'document_ref_dropdown': <String>[],
      'array_field': ['Item 1', 'Item 2', 'Item 3'],
      'object_field': {
        'nested_title': 'Nested Value',
        'nested_count': 10,
        'nested_tag': 'alpha',
        'nested_notes': 'Some notes',
      },
      'block_field': null,
      'geopoint_field': {'lat': 37.7749, 'lng': -122.4194},
    },
  },
  {
    'title': 'Test Document Beta',
    'slug': 'test-document-beta',
    'data': {
      'string_field': 'Second Document',
      'text_field': 'Beta text content.',
      'number_field': 100,
      'boolean_field': false,
      'checkbox_field': true,
      'url_field': 'https://flutter.dev',
      'date_field': '2026-01-15',
      'datetime_field': '2026-01-15T14:00:00',
      'color_field': '#2196F3',
      'image_field': null,
      'file_field': null,
      'dropdown_field': 'option_b',
      'document_ref_dropdown': <String>[],
      'array_field': ['Alpha', 'Beta'],
      'object_field': {
        'nested_title': 'Beta Nested',
        'nested_count': 5,
        'nested_tag': 'beta',
        'nested_notes': '',
      },
      'block_field': null,
      'geopoint_field': {'lat': 40.7128, 'lng': -74.0060},
    },
  },
  {
    'title': 'Test Document Gamma',
    'slug': 'test-document-gamma',
    'data': {
      'string_field': 'Third Document',
      'text_field': 'Gamma text.',
      'number_field': 0,
      'boolean_field': true,
      'checkbox_field': true,
      'url_field': '',
      'date_field': null,
      'datetime_field': null,
      'color_field': '#4CAF50',
      'image_field': {'_type': 'imageReference', 'assetId': 'asset-landscape'},
      'file_field': null,
      'dropdown_field': null,
      'document_ref_dropdown': <String>[],
      'array_field': [],
      'object_field': {
        'nested_title': '',
        'nested_count': 0,
        'nested_tag': '',
        'nested_notes': null,
      },
      'block_field': null,
      'geopoint_field': null,
    },
  },
];
