import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_desk_generator/dart_desk_generator.dart';
import 'package:test/test.dart';

void main() {
  group('CmsFieldGenerator field mappings', () {
    test(
      'generates field configs for every supported field annotation',
      () async {
        await _testCmsBuilder(
          _fixture('''
class ChildConfig {
  @CmsStringFieldConfig()
  final String childTitle;

  const ChildConfig({required this.childTitle});

  static ChildConfig? defaultValue;
}

@CmsConfig(title: 'All Fields', description: 'All fields config')
class AllFieldsConfig {
  @CmsTextFieldConfig(optional: true)
  final String textField;

  @CmsStringFieldConfig(option: CmsStringOption(hidden: true))
  final String stringField;

  @CmsNumberFieldConfig(optional: true)
  final num numberField;

  @CmsBooleanFieldConfig(option: CmsBooleanOption(hidden: true))
  final bool booleanField;

  @CmsCheckboxFieldConfig(
    option: CmsCheckboxOption(label: 'Check me', initialValue: true),
  )
  final bool checkboxField;

  @CmsDateFieldConfig(optional: true)
  final DateTime dateField;

  @CmsDateTimeFieldConfig(optional: true)
  final DateTime dateTimeField;

  @CmsUrlFieldConfig(optional: true)
  final Uri urlField;

  @CmsImageFieldConfig(option: CmsImageOption(hotspot: true))
  final Object imageField;

  @CmsFileFieldConfig(optional: true)
  final String fileField;

  @CmsColorFieldConfig(optional: true)
  final String colorField;

  @CmsDropdownFieldConfig<String>(
    option: CmsDropdownSimpleOption<String>(
      options: [DropdownOption(value: 'a', label: 'A')],
    ),
  )
  final String dropdownField;

  @CmsMultiDropdownFieldConfig<String>(
    option: CmsMultiDropdownSimpleOption<String>(
      options: [DropdownOption(value: 'a', label: 'A')],
    ),
  )
  final List<String> multiDropdownField;

  @CmsArrayFieldConfig<String>()
  final List<String> arrayField;

  @CmsObjectFieldConfig()
  final ChildConfig objectField;

  @CmsBlockFieldConfig()
  final Object blockField;

  @CmsGeopointFieldConfig()
  final Object geopointField;

  const AllFieldsConfig({
    required this.textField,
    required this.stringField,
    required this.numberField,
    required this.booleanField,
    required this.checkboxField,
    required this.dateField,
    required this.dateTimeField,
    required this.urlField,
    required this.imageField,
    required this.fileField,
    required this.colorField,
    required this.dropdownField,
    required this.multiDropdownField,
    required this.arrayField,
    required this.objectField,
    required this.blockField,
    required this.geopointField,
  });

  static AllFieldsConfig? defaultValue;
}
'''),
          allOf([
            contains('final allFieldsConfigFields = ['),
            contains('CmsTextField('),
            contains('option: CmsTextOption(optional: true)'),
            contains('CmsStringField('),
            contains('option: CmsStringOption(hidden: true)'),
            contains('CmsNumberField('),
            contains('option: CmsNumberOption(optional: true)'),
            contains('CmsBooleanField('),
            contains('option: CmsBooleanOption(hidden: true)'),
            contains('CmsCheckboxField('),
            contains(
              "option: CmsCheckboxOption(label: 'Check me', initialValue: true)",
            ),
            contains('CmsDateField('),
            contains('option: CmsDateOption(optional: true)'),
            contains('CmsDateTimeField('),
            contains('option: CmsDateTimeOption(optional: true)'),
            contains('CmsUrlField('),
            contains('option: CmsUrlOption(optional: true)'),
            contains('CmsImageField('),
            contains('option: CmsImageOption(hotspot: true)'),
            contains('CmsFileField('),
            contains('option: CmsFileOption(optional: true)'),
            contains('CmsColorField('),
            contains('option: CmsColorOption(optional: true)'),
            contains('CmsDropdownField<String>('),
            contains('CmsMultiDropdownField<String>('),
            contains('CmsArrayField<String>('),
            contains(
              "innerField: CmsStringField(name: 'item', title: 'String')",
            ),
            contains('CmsObjectField('),
            contains('ColumnFields(children: childConfigFields)'),
            contains('CmsBlockField('),
            contains('CmsGeopointField('),
            contains('final childConfigFields = ['),
          ]),
        );
      },
    );
  });

  group('CmsFieldGenerator arrays', () {
    test(
      'infers the item type from List<T> when explicit inner is provided',
      () async {
        await _testCmsBuilder(
          _fixture('''
@CmsConfig(title: 'Array Config', description: 'Array config')
class ArrayConfig {
  @CmsArrayFieldConfig(inner: CmsImageFieldConfig())
  final List<String> imageItems;

  const ArrayConfig({required this.imageItems});

  static ArrayConfig? defaultValue = const ArrayConfig(imageItems: []);
}
'''),
          allOf(
            contains('CmsArrayField<String>('),
            contains("name: 'imageItems'"),
            contains("innerField: CmsImageField(name: 'item', title: 'Item')"),
            isNot(contains('CmsArrayField<dynamic>(')),
          ),
        );
      },
    );

    test(
      'converts explicit optional inner config to a valid inner field',
      () async {
        await _testCmsBuilder(
          _fixture('''
@CmsConfig(title: 'Array Config', description: 'Array config')
class ArrayConfig {
  @CmsArrayFieldConfig<String>(inner: CmsStringFieldConfig(optional: true))
  final List<String> tags;

  const ArrayConfig({required this.tags});

  static ArrayConfig? defaultValue = const ArrayConfig(tags: []);
}
'''),
          allOf(
            contains('CmsArrayField<String>('),
            contains("innerField: CmsStringField("),
            contains("option: CmsStringOption(optional: true)"),
            isNot(contains("optional: true,\n      option:")),
          ),
        );
      },
    );

    test('infers primitive inner fields from the array item type', () async {
      await _testCmsBuilder(
        _fixture('''
@CmsConfig(title: 'Array Config', description: 'Array config')
class ArrayConfig {
  @CmsArrayFieldConfig<int>()
  final List<int> scores;

  const ArrayConfig({required this.scores});

  static ArrayConfig? defaultValue = const ArrayConfig(scores: []);
}
'''),
        allOf(
          contains('CmsArrayField<int>('),
          contains("innerField: CmsNumberField(name: 'item', title: 'Int')"),
        ),
      );
    });

    test('discovers object array item field lists', () async {
      await _testCmsBuilder(
        _fixture('''
class ItemConfig {
  @CmsStringFieldConfig()
  final String title;

  const ItemConfig({required this.title});

  static ItemConfig? defaultValue = const ItemConfig(title: '');
}

@CmsConfig(title: 'Array Config', description: 'Array config')
class ArrayConfig {
  @CmsArrayFieldConfig<ItemConfig>()
  final List<ItemConfig> items;

  const ArrayConfig({required this.items});

  static ArrayConfig? defaultValue = const ArrayConfig(items: []);
}
'''),
        allOf(
          contains('final arrayConfigFields = ['),
          contains('ColumnFields(children: itemConfigFields)'),
          contains('final itemConfigFields = ['),
          contains("CmsStringField(name: 'title', title: 'Title')"),
        ),
      );
    });
  });
}

String _fixture(String body) =>
    '''
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

part 'input.cms.g.dart';

$body
''';

Future<void> _testCmsBuilder(String source, Matcher outputMatcher) async {
  final reader = TestReaderWriter(rootPackage: 'dart_desk_generator');
  await reader.testing.loadIsolateSources();

  await testBuilder(
    cmsBuilder(BuilderOptions({})),
    {'dart_desk_generator|lib/input.dart': source},
    generateFor: {'dart_desk_generator|lib/input.dart'},
    readerWriter: reader,
    outputs: {
      'dart_desk_generator|lib/input.cms.g.dart': decodedMatches(outputMatcher),
    },
  );
}
