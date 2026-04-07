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

  @CmsBlockFieldConfig(option: CmsBlockOption())
  final Object blockField;

  @CmsGeopointFieldConfig(option: CmsGeopointOption())
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
            contains('option: CmsBlockOption()'),
            contains('CmsGeopointField('),
            contains('option: CmsGeopointOption()'),
            contains('final childConfigFields = ['),
          ]),
        );
      },
    );

    test('preserves optional flags when explicit options omit them', () async {
      await _testCmsBuilder(
        _fixture('''
@CmsConfig(title: 'Optional Fields', description: 'Optional fields config')
class OptionalFieldsConfig {
  @CmsTextFieldConfig(optional: true, option: CmsTextOption(rows: 3))
  final String textField;

  @CmsStringFieldConfig(optional: true, option: CmsStringOption(hidden: true))
  final String stringField;

  @CmsNumberFieldConfig(optional: true, option: CmsNumberOption(min: 1))
  final num numberField;

  @CmsDateFieldConfig(optional: true, option: CmsDateOption(hidden: true))
  final DateTime dateField;

  @CmsDateTimeFieldConfig(
    optional: true,
    option: CmsDateTimeOption(hidden: true),
  )
  final DateTime dateTimeField;

  @CmsUrlFieldConfig(optional: true, option: CmsUrlOption(hidden: true))
  final Uri urlField;

  @CmsFileFieldConfig(optional: true, option: CmsFileOption(hidden: true))
  final String fileField;

  @CmsColorFieldConfig(optional: true, option: CmsColorOption(showAlpha: true))
  final String colorField;

  const OptionalFieldsConfig({
    required this.textField,
    required this.stringField,
    required this.numberField,
    required this.dateField,
    required this.dateTimeField,
    required this.urlField,
    required this.fileField,
    required this.colorField,
  });

  static OptionalFieldsConfig? defaultValue;
}
'''),
        allOf([
          contains('option: CmsTextOption(optional: true, rows: 3)'),
          contains('option: CmsStringOption(optional: true, hidden: true)'),
          contains('option: CmsNumberOption(optional: true, min: 1)'),
          contains('option: CmsDateOption(optional: true, hidden: true)'),
          contains('option: CmsDateTimeOption(optional: true, hidden: true)'),
          contains('option: CmsUrlOption(optional: true, hidden: true)'),
          contains('option: CmsFileOption(optional: true, hidden: true)'),
          contains('option: CmsColorOption(optional: true, showAlpha: true)'),
        ]),
      );
    });

    test(
      'generates legacy reference style field configs by display name',
      () async {
        await _testCmsBuilder(
          _fixture('''
class CmsSlugFieldConfig {
  const CmsSlugFieldConfig({this.option});

  final Object? option;
}

class CmsReferenceFieldConfig {
  const CmsReferenceFieldConfig({this.option});

  final Object? option;
}

class CmsCrossDatasetReferenceFieldConfig {
  const CmsCrossDatasetReferenceFieldConfig({this.option});

  final Object? option;
}

class CmsSlugOption {
  const CmsSlugOption({this.hidden = false});

  final bool hidden;
}

class CmsReferenceOption {
  const CmsReferenceOption({this.to = ''});

  final String to;
}

class CmsCrossDatasetReferenceOption {
  const CmsCrossDatasetReferenceOption({this.dataset = ''});

  final String dataset;
}

@CmsConfig(title: 'Legacy', description: 'Legacy field config names')
class LegacyFieldsConfig {
  @CmsSlugFieldConfig(option: CmsSlugOption(hidden: true))
  final String slugField;

  @CmsReferenceFieldConfig(option: CmsReferenceOption(to: 'post'))
  final String referenceField;

  @CmsCrossDatasetReferenceFieldConfig(
    option: CmsCrossDatasetReferenceOption(dataset: 'production'),
  )
  final String crossDatasetReferenceField;

  const LegacyFieldsConfig({
    required this.slugField,
    required this.referenceField,
    required this.crossDatasetReferenceField,
  });

  static LegacyFieldsConfig? defaultValue;
}
'''),
          allOf([
            contains('CmsSlugField('),
            contains('option: CmsSlugOption(hidden: true)'),
            contains('CmsReferenceField('),
            contains("option: CmsReferenceOption(to: 'post')"),
            contains('CmsCrossDatasetReferenceField('),
            contains(
              "option: CmsCrossDatasetReferenceOption(dataset: 'production')",
            ),
          ]),
        );
      },
    );

    test('infers dropdown generic types from the Dart field types', () async {
      await _testCmsBuilder(
        _fixture('''
@CmsConfig(title: 'Dropdowns', description: 'Dropdown config')
class DropdownsConfig {
  @CmsDropdownFieldConfig()
  final String dropdownField;

  @CmsMultiDropdownFieldConfig()
  final List<int> multiDropdownField;

  const DropdownsConfig({
    required this.dropdownField,
    required this.multiDropdownField,
  });

  static DropdownsConfig? defaultValue;
}
'''),
        allOf([
          contains('CmsDropdownField<String>('),
          contains('CmsMultiDropdownField<int>('),
        ]),
      );
    });

    test('generates document id and nested CmsConfig data wrappers', () async {
      await _testCmsBuilder(
        _fixture('''
@CmsConfig(title: 'Nested', description: 'Nested config')
class NestedConfig {
  @CmsStringFieldConfig()
  final String title;

  const NestedConfig({required this.title});

  static NestedConfig? defaultValue;
}

@CmsConfig(title: 'Document', description: 'Document config', id: 'custom-id')
class DocumentConfig {
  @CmsObjectFieldConfig()
  final NestedConfig nested;

  final NestedConfig? nullableNested;

  const DocumentConfig({required this.nested, this.nullableNested});

  static DocumentConfig? defaultValue;
}
'''),
        allOf(
          contains("name: 'custom-id'"),
          contains('final CmsData<NestedConfigCmsConfig?> nullableNested;'),
        ),
      );
    });

    test('reports an error when CmsConfig is used on a non-class', () async {
      await expectLater(
        _testCmsBuilder('''
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

part 'input.cms.g.dart';

@CmsConfig(title: 'Bad', description: 'Bad config')
const badConfig = 1;
''', anything),
        throwsA(anything),
      );
    });
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

    test(
      'preserves explicit inner description and augments explicit inner options',
      () async {
        await _testCmsBuilder(
          _fixture('''
@CmsConfig(title: 'Array Config', description: 'Array config')
class ArrayConfig {
  @CmsArrayFieldConfig<String>(
    inner: CmsStringFieldConfig(
      name: 'tag',
      title: 'Tag',
      description: 'Visible tag',
      optional: true,
      option: CmsStringOption(hidden: true),
    ),
    option: CmsArrayOption(horizontal: true),
  )
  final List<String> tags;

  const ArrayConfig({required this.tags});

  static ArrayConfig? defaultValue = const ArrayConfig(tags: []);
}
'''),
          allOf(
            contains("innerField: CmsStringField("),
            contains("name: 'tag'"),
            contains("title: 'Tag'"),
            contains("description: 'Visible tag'"),
            contains('option: CmsStringOption(optional: true, hidden: true)'),
            contains('option: CmsArrayOption(horizontal: true)'),
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

    test('infers fields for unannotated object array item classes', () async {
      await _testCmsBuilder(
        _fixture('''
class ImageReference {
  final String url;

  const ImageReference({required this.url});
}

class ItemConfig {
  final String title;
  final ImageReference? image;

  const ItemConfig({required this.title, this.image});

  static ItemConfig? defaultValue = const ItemConfig(title: '');
}

@CmsConfig(title: 'Array Config', description: 'Array config')
class ArrayConfig {
  @CmsArrayFieldConfig<ItemConfig>()
  final List<ItemConfig> items;

  final String unannotatedTopLevelField;

  const ArrayConfig({
    required this.items,
    required this.unannotatedTopLevelField,
  });

  static ArrayConfig? defaultValue = const ArrayConfig(
    items: [],
    unannotatedTopLevelField: '',
  );
}
'''),
        allOf(
          contains('ColumnFields(children: itemConfigFields)'),
          contains('final itemConfigFields = ['),
          contains("CmsStringField(name: 'title', title: 'Title')"),
          contains("CmsImageField(name: 'image', title: 'Image')"),
          contains("name: 'unannotatedTopLevelField'"),
        ),
      );
    });
  });

  group('CmsFieldGenerator deduplication', () {
    test(
      'does not emit field list for discovered classes with @CmsConfig',
      () async {
        await _testCmsBuilder(
          _fixture('''
@CmsConfig(title: 'Hero', description: 'Hero config')
class HeroConfig {
  @CmsStringFieldConfig()
  final String heroName;

  const HeroConfig({required this.heroName});

  static HeroConfig? defaultValue;
}

@CmsConfig(title: 'Array Test', description: 'Array test config')
class ArrayTestConfig {
  @CmsArrayFieldConfig<HeroConfig>()
  final List<HeroConfig> heroes;

  const ArrayTestConfig({required this.heroes});

  static ArrayTestConfig? defaultValue = const ArrayTestConfig(heroes: []);
}
'''),
          _containsExactCount('final heroConfigFields = [', 1),
        );
      },
    );

    test(
      'still emits field list for discovered classes without @CmsConfig',
      () async {
        await _testCmsBuilder(
          _fixture('''
class SampleConfig {
  @CmsStringFieldConfig()
  final String sampleName;

  const SampleConfig({required this.sampleName});

  static SampleConfig? defaultValue;
}

@CmsConfig(title: 'Parent', description: 'Parent config')
class ParentConfig {
  @CmsArrayFieldConfig<SampleConfig>()
  final List<SampleConfig> samples;

  const ParentConfig({required this.samples});

  static ParentConfig? defaultValue = const ParentConfig(samples: []);
}
'''),
          allOf(
            contains('final parentConfigFields = ['),
            // SampleConfig has no @CmsConfig, so its fields should be emitted
            contains('final sampleConfigFields = ['),
          ),
        );
      },
    );
  });

  group('CmsFieldGenerator auto-detection', () {
    test('auto-detects String field without annotation', () async {
      await _testCmsBuilder(
        _fixture('''
@CmsConfig(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final String name;

  const AutoDetectConfig({required this.name});

  static AutoDetectConfig? defaultValue;
}
'''),
        contains('CmsStringField(name: \'name\', title: \'Name\')'),
      );
    });

    test(
      'auto-detects List<String> field without annotation defaults to Array',
      () async {
        await _testCmsBuilder(
          _fixture('''
@CmsConfig(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final List<String> tags;

  const AutoDetectConfig({required this.tags});

  static AutoDetectConfig? defaultValue = const AutoDetectConfig(tags: []);
}
'''),
          allOf(
            contains('CmsArrayField<String>'),
            contains('innerField: CmsStringField'),
          ),
        );
      },
    );

    test('auto-detects int field as NumberField', () async {
      await _testCmsBuilder(
        _fixture('''
@CmsConfig(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final int count;

  const AutoDetectConfig({required this.count});

  static AutoDetectConfig? defaultValue;
}
'''),
        contains('CmsNumberField(name: \'count\', title: \'Count\')'),
      );
    });

    test('auto-detects bool field as BooleanField', () async {
      await _testCmsBuilder(
        _fixture('''
@CmsConfig(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final bool enabled;

  const AutoDetectConfig({required this.enabled});

  static AutoDetectConfig? defaultValue;
}
'''),
        contains('CmsBooleanField(name: \'enabled\', title: \'Enabled\')'),
      );
    });

    test('auto-detects DateTime field as DateTimeField', () async {
      await _testCmsBuilder(
        _fixture('''
@CmsConfig(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final DateTime createdAt;

  const AutoDetectConfig({required this.createdAt});

  static AutoDetectConfig? defaultValue;
}
'''),
        contains(
          'CmsDateTimeField(name: \'createdAt\', title: \'Created At\')',
        ),
      );
    });

    test('auto-detects Uri field as UrlField', () async {
      await _testCmsBuilder(
        _fixture('''
@CmsConfig(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final Uri website;

  const AutoDetectConfig({required this.website});

  static AutoDetectConfig? defaultValue;
}
'''),
        contains('CmsUrlField(name: \'website\', title: \'Website\')'),
      );
    });

    test('explicit annotation takes precedence over auto-detection', () async {
      await _testCmsBuilder(
        _fixture('''
@CmsConfig(title: 'Mixed', description: 'Mixed config')
class MixedConfig {
  final String name;

  @CmsTextFieldConfig()
  final String description;

  const MixedConfig({required this.name, required this.description});

  static MixedConfig? defaultValue;
}
'''),
        allOf(
          contains('CmsStringField(name: \'name\', title: \'Name\')'),
          contains(
            'CmsTextField(name: \'description\', title: \'Description\')',
          ),
        ),
      );
    });
  });
}

/// Matches a string that contains [substring] exactly [count] times.
Matcher _containsExactCount(String substring, int count) =>
    predicate(
      (dynamic s) {
        var occurrences = 0;
        var index = 0;
        while ((index = s.indexOf(substring, index)) != -1) {
          occurrences++;
          index += substring.length;
        }
        return occurrences == count;
      },
      'contains "$substring" exactly $count time(s)',
    );

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
