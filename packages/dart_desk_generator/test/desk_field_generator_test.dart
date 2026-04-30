import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_desk_generator/dart_desk_generator.dart';
import 'package:test/test.dart';

void main() {
  group('DeskFieldGenerator field mappings', () {
    test(
      'generates field configs for every supported field annotation',
      () async {
        await _testDeskBuilder(
          _fixture('''
class ChildConfig {
  @DeskString()
  final String childTitle;

  const ChildConfig({required this.childTitle});

  static ChildConfig? defaultValue;
}

@DeskModel(title: 'All Fields', description: 'All fields config')
class AllFieldsConfig {
  @DeskText(optional: true)
  final String? textField;

  @DeskString(option: DeskStringOption(optional: true))
  final String stringField;

  @DeskNumber(optional: true)
  final num? numberField;

  @DeskBoolean(option: DeskBooleanOption())
  final bool booleanField;

  @DeskCheckbox(
    option: DeskCheckboxOption(label: 'Check me', initialValue: true),
  )
  final bool checkboxField;

  @DeskDate(optional: true)
  final DateTime? dateField;

  @DeskDateTime(optional: true)
  final DateTime? dateTimeField;

  @DeskUrl(optional: true)
  final Uri? urlField;

  @DeskImage(option: DeskImageOption(hotspot: true))
  final Object imageField;

  @DeskFile(optional: true)
  final String? fileField;

  @DeskColor(optional: true)
  final String? colorField;

  @DeskDropdown<String>(
    option: DeskDropdownSimpleOption<String>(
      options: [DropdownOption(value: 'a', label: 'A')],
    ),
  )
  final String dropdownField;

  @DeskMultiDropdown<String>(
    option: DeskMultiDropdownSimpleOption<String>(
      options: [DropdownOption(value: 'a', label: 'A')],
    ),
  )
  final List<String> multiDropdownField;

  @DeskArray<String>()
  final List<String> arrayField;

  @DeskObject()
  final ChildConfig objectField;

  @DeskBlock(option: DeskBlockOption())
  final Object blockField;

  @DeskGeopoint(option: DeskGeopointOption())
  final Object geopointField;

  const AllFieldsConfig({
    this.textField,
    required this.stringField,
    this.numberField,
    required this.booleanField,
    required this.checkboxField,
    this.dateField,
    this.dateTimeField,
    this.urlField,
    required this.imageField,
    this.fileField,
    this.colorField,
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
            contains('DeskTextField('),
            contains('option: DeskTextOption(optional: true)'),
            contains('DeskStringField('),
            contains('option: DeskStringOption(optional: true)'),
            contains('DeskNumberField('),
            contains('option: DeskNumberOption(optional: true)'),
            contains('DeskBooleanField('),
            contains('option: DeskBooleanOption()'),
            contains('DeskCheckboxField('),
            contains(
              "option: DeskCheckboxOption(label: 'Check me', initialValue: true)",
            ),
            contains('DeskDateField('),
            contains('option: DeskDateOption(optional: true)'),
            contains('DeskDateTimeField('),
            contains('option: DeskDateTimeOption(optional: true)'),
            contains('DeskUrlField('),
            contains('option: DeskUrlOption(optional: true)'),
            contains('DeskImageField('),
            contains('option: DeskImageOption(hotspot: true)'),
            contains('DeskFileField('),
            contains('option: DeskFileOption(optional: true)'),
            contains('DeskColorField('),
            contains('option: DeskColorOption(optional: true)'),
            contains('DeskDropdownField<String>('),
            contains('DeskMultiDropdownField<String>('),
            contains('DeskArrayField<String>('),
            contains(
              "innerField: DeskStringField(name: 'item', title: 'String')",
            ),
            contains('DeskObjectField('),
            contains('ColumnFields(children: childConfigFields)'),
            contains('DeskBlockField('),
            contains('option: DeskBlockOption()'),
            contains('DeskGeopointField('),
            contains('option: DeskGeopointOption()'),
            contains('final childConfigFields = ['),
          ]),
        );
      },
    );

    test('preserves optional flags when explicit options omit them', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'Optional Fields', description: 'Optional fields config')
class OptionalFieldsConfig {
  @DeskText(optional: true, option: DeskTextOption(rows: 3))
  final String? textField;

  @DeskString(optional: true, option: DeskStringOption())
  final String? stringField;

  @DeskNumber(optional: true, option: DeskNumberOption(min: 1))
  final num? numberField;

  @DeskDate(optional: true, option: DeskDateOption())
  final DateTime? dateField;

  @DeskDateTime(
    optional: true,
    option: DeskDateTimeOption(),
  )
  final DateTime? dateTimeField;

  @DeskUrl(optional: true, option: DeskUrlOption())
  final Uri? urlField;

  @DeskFile(optional: true, option: DeskFileOption())
  final String? fileField;

  @DeskColor(optional: true, option: DeskColorOption(showAlpha: true))
  final String? colorField;

  const OptionalFieldsConfig({
    this.textField,
    this.stringField,
    this.numberField,
    this.dateField,
    this.dateTimeField,
    this.urlField,
    this.fileField,
    this.colorField,
  });

  static OptionalFieldsConfig? defaultValue;
}
'''),
        allOf([
          contains('option: DeskTextOption(optional: true, rows: 3)'),
          contains('option: DeskStringOption(optional: true)'),
          contains('option: DeskNumberOption(optional: true, min: 1)'),
          contains('option: DeskDateOption(optional: true)'),
          contains('option: DeskDateTimeOption(optional: true)'),
          contains('option: DeskUrlOption(optional: true)'),
          contains('option: DeskFileOption(optional: true)'),
          contains('option: DeskColorOption(optional: true, showAlpha: true)'),
        ]),
      );
    });

    test(
      'generates legacy reference style field configs by display name',
      () async {
        await _testDeskBuilder(
          _fixture('''
class DeskSlugFieldConfig {
  const DeskSlugFieldConfig({this.option});

  final Object? option;
}

class DeskReferenceFieldConfig {
  const DeskReferenceFieldConfig({this.option});

  final Object? option;
}

class DeskCrossDatasetReferenceFieldConfig {
  const DeskCrossDatasetReferenceFieldConfig({this.option});

  final Object? option;
}

class DeskSlugOption {
  const DeskSlugOption({this.hidden = false});

  final bool hidden;
}

class DeskReferenceOption {
  const DeskReferenceOption({this.to = ''});

  final String to;
}

class DeskCrossDatasetReferenceOption {
  const DeskCrossDatasetReferenceOption({this.dataset = ''});

  final String dataset;
}

@DeskModel(title: 'Legacy', description: 'Legacy field config names')
class LegacyFieldsConfig {
  @DeskSlugFieldConfig(option: DeskSlugOption(hidden: true))
  final String slugField;

  @DeskReferenceFieldConfig(option: DeskReferenceOption(to: 'post'))
  final String referenceField;

  @DeskCrossDatasetReferenceFieldConfig(
    option: DeskCrossDatasetReferenceOption(dataset: 'production'),
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
            contains('DeskSlugField('),
            contains('option: DeskSlugOption(hidden: true)'),
            contains('DeskReferenceField('),
            contains("option: DeskReferenceOption(to: 'post')"),
            contains('DeskCrossDatasetReferenceField('),
            contains(
              "option: DeskCrossDatasetReferenceOption(dataset: 'production')",
            ),
          ]),
        );
      },
    );

    test('infers dropdown generic types from the Dart field types', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'Dropdowns', description: 'Dropdown config')
class DropdownsConfig {
  @DeskDropdown()
  final String dropdownField;

  @DeskMultiDropdown()
  final List<int> multiDropdownField;

  const DropdownsConfig({
    required this.dropdownField,
    required this.multiDropdownField,
  });

  static DropdownsConfig? defaultValue;
}
'''),
        allOf([
          contains('DeskDropdownField<String>('),
          contains('DeskMultiDropdownField<int>('),
        ]),
      );
    });

    test('generates document id and nested DeskModel data wrappers', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'Nested', description: 'Nested config')
class NestedConfig {
  @DeskString()
  final String title;

  const NestedConfig({required this.title});

  static NestedConfig? defaultValue;
}

@DeskModel(title: 'Document', description: 'Document config', id: 'custom-id')
class DocumentConfig {
  @DeskObject()
  final NestedConfig nested;

  final NestedConfig? nullableNested;

  const DocumentConfig({required this.nested, this.nullableNested});

  static DocumentConfig? defaultValue;
}
'''),
        allOf(
          contains("name: 'custom-id'"),
          contains('final DeskData<NestedConfigDeskModel?> nullableNested;'),
        ),
      );
    });

    test('reports an error when DeskModel is used on a non-class', () async {
      await expectLater(
        _testDeskBuilder('''
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

part 'input.desk.dart';

@DeskModel(title: 'Bad', description: 'Bad config')
const badConfig = 1;
''', anything),
        throwsA(anything),
      );
    });

    test('infers optional from nullable String field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'Nullable', description: 'Nullable String test')
class NullableConfig {
  @DeskString()
  final String? maybeTitle;

  const NullableConfig({this.maybeTitle});

  static NullableConfig? defaultValue;
}
'''),
        contains('DeskStringOption(optional: true)'),
      );
    });

    test('explicit optional: false overrides nullable inference', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'Override', description: 'Override test')
class OverrideConfig {
  @DeskString(optional: false)
  final String? maybeTitle;

  const OverrideConfig({this.maybeTitle});

  static OverrideConfig? defaultValue;
}
'''),
        isNot(contains('optional: true')),
      );
    });

    // build_test wraps InvalidGenerationSourceError in a TestFailure, so
    // throwsA(anything) is intentional — the exact type is not observable here.
    test('non-nullable + optional: true throws', () async {
      await expectLater(
        _testDeskBuilder(
          _fixture('''
@DeskModel(title: 'Bad', description: 'Bad config')
class BadConfig {
  @DeskString(optional: true)
  final String requiredTitle;

  const BadConfig({required this.requiredTitle});

  static BadConfig? defaultValue;
}
'''),
          anything,
        ),
        throwsA(anything),
      );
    });

    test('infers optional from nullable Text field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableText', description: 'test')
class NullableTextConfig {
  @DeskText()
  final String? maybeBody;

  const NullableTextConfig({this.maybeBody});

  static NullableTextConfig? defaultValue;
}
'''),
        contains('DeskTextOption(optional: true)'),
      );
    });

    test('infers optional from nullable Number field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableNum', description: 'test')
class NullableNumConfig {
  @DeskNumber()
  final num? maybeAge;

  const NullableNumConfig({this.maybeAge});

  static NullableNumConfig? defaultValue;
}
'''),
        contains('DeskNumberOption(optional: true)'),
      );
    });

    test('infers optional from nullable Url field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableUrl', description: 'test')
class NullableUrlConfig {
  @DeskUrl()
  final Uri? maybeLink;

  const NullableUrlConfig({this.maybeLink});

  static NullableUrlConfig? defaultValue;
}
'''),
        contains('DeskUrlOption(optional: true)'),
      );
    });

    test('infers optional from nullable Color field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableColor', description: 'test')
class NullableColorConfig {
  @DeskColor()
  final String? maybeTint;

  const NullableColorConfig({this.maybeTint});

  static NullableColorConfig? defaultValue;
}
'''),
        contains('DeskColorOption(optional: true)'),
      );
    });

    test('infers optional from nullable Date field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableDate', description: 'test')
class NullableDateConfig {
  @DeskDate()
  final DateTime? maybeDob;

  const NullableDateConfig({this.maybeDob});

  static NullableDateConfig? defaultValue;
}
'''),
        contains('DeskDateOption(optional: true)'),
      );
    });

    test('infers optional from nullable DateTime field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableDt', description: 'test')
class NullableDtConfig {
  @DeskDateTime()
  final DateTime? maybeAt;

  const NullableDtConfig({this.maybeAt});

  static NullableDtConfig? defaultValue;
}
'''),
        contains('DeskDateTimeOption(optional: true)'),
      );
    });

    test('infers optional from nullable File field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableFile', description: 'test')
class NullableFileConfig {
  @DeskFile()
  final String? maybeFile;

  const NullableFileConfig({this.maybeFile});

  static NullableFileConfig? defaultValue;
}
'''),
        contains('DeskFileOption(optional: true)'),
      );
    });

    test('infers optional from nullable Boolean field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableBool', description: 'test')
class NullableBoolConfig {
  @DeskBoolean()
  final bool? maybeFlag;

  const NullableBoolConfig({this.maybeFlag});

  static NullableBoolConfig? defaultValue;
}
'''),
        contains('DeskBooleanOption(optional: true)'),
      );
    });

    test('infers optional from nullable Checkbox field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableCheck', description: 'test')
class NullableCheckConfig {
  @DeskCheckbox()
  final bool? maybeChecked;

  const NullableCheckConfig({this.maybeChecked});

  static NullableCheckConfig? defaultValue;
}
'''),
        contains('DeskCheckboxOption(optional: true)'),
      );
    });

    test('infers optional from nullable Image field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableImage', description: 'test')
class NullableImageConfig {
  @DeskImage()
  final Object? maybeImage;

  const NullableImageConfig({this.maybeImage});

  static NullableImageConfig? defaultValue;
}
'''),
        contains('DeskImageOption(optional: true)'),
      );
    });

    test('infers optional from nullable Geopoint field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableGeopoint', description: 'test')
class NullableGeopointConfig {
  @DeskGeopoint()
  final Object? maybeGeo;

  const NullableGeopointConfig({this.maybeGeo});

  static NullableGeopointConfig? defaultValue;
}
'''),
        contains('DeskGeopointOption(optional: true)'),
      );
    });

    test('infers optional from nullable Dropdown field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableDropdown', description: 'test')
class NullableDropdownConfig {
  @DeskDropdown<String>(option: DeskDropdownSimpleOption<String>(options: []))
  final String? maybeChoice;

  const NullableDropdownConfig({this.maybeChoice});

  static NullableDropdownConfig? defaultValue;
}
'''),
        contains('optional: true'),
      );
    });

    test('infers optional from nullable MultiDropdown field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableMultiDropdown', description: 'test')
class NullableMultiDropdownConfig {
  @DeskMultiDropdown<String>(option: DeskMultiDropdownSimpleOption<String>(options: []))
  final List<String>? maybeTags;

  const NullableMultiDropdownConfig({this.maybeTags});

  static NullableMultiDropdownConfig? defaultValue;
}
'''),
        contains('optional: true'),
      );
    });

    test('infers optional from nullable Array field (outer)', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableArray', description: 'test')
class NullableArrayConfig {
  @DeskArray<String>()
  final List<String>? maybeTags;

  const NullableArrayConfig({this.maybeTags});

  static NullableArrayConfig? defaultValue;
}
'''),
        contains('DeskArrayOption(optional: true)'),
      );
    });

    test('infers optional from nullable Block field', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'NullableBlock', description: 'test')
class NullableBlockConfig {
  @DeskBlock()
  final Object? maybeContent;

  const NullableBlockConfig({this.maybeContent});

  static NullableBlockConfig? defaultValue;
}
'''),
        contains('DeskBlockOption(optional: true)'),
      );
    });
  });

  group('DeskFieldGenerator arrays', () {
    test(
      'infers the item type from List<T> when explicit inner is provided',
      () async {
        await _testDeskBuilder(
          _fixture('''
@DeskModel(title: 'Array Config', description: 'Array config')
class ArrayConfig {
  @DeskArray(inner: DeskImage())
  final List<String> imageItems;

  const ArrayConfig({required this.imageItems});

  static ArrayConfig? defaultValue = const ArrayConfig(imageItems: []);
}
'''),
          allOf(
            contains('DeskArrayField<String>('),
            contains("name: 'imageItems'"),
            contains("innerField: DeskImageField(name: 'item', title: 'Item')"),
            isNot(contains('DeskArrayField<dynamic>(')),
          ),
        );
      },
    );

    test(
      'converts explicit optional inner config to a valid inner field',
      () async {
        await _testDeskBuilder(
          _fixture('''
@DeskModel(title: 'Array Config', description: 'Array config')
class ArrayConfig {
  @DeskArray<String>(inner: DeskString(optional: true))
  final List<String> tags;

  const ArrayConfig({required this.tags});

  static ArrayConfig? defaultValue = const ArrayConfig(tags: []);
}
'''),
          allOf(
            contains('DeskArrayField<String>('),
            contains("innerField: DeskStringField("),
            contains("option: DeskStringOption(optional: true)"),
            isNot(contains("optional: true,\n      option:")),
          ),
        );
      },
    );

    test(
      'preserves explicit inner description and augments explicit inner options',
      () async {
        await _testDeskBuilder(
          _fixture('''
@DeskModel(title: 'Array Config', description: 'Array config')
class ArrayConfig {
  @DeskArray<String>(
    inner: DeskString(
      name: 'tag',
      title: 'Tag',
      description: 'Visible tag',
      optional: true,
      option: DeskStringOption(optional: true),
    ),
    option: DeskArrayOption(horizontal: true),
  )
  final List<String> tags;

  const ArrayConfig({required this.tags});

  static ArrayConfig? defaultValue = const ArrayConfig(tags: []);
}
'''),
          allOf(
            contains("innerField: DeskStringField("),
            contains("name: 'tag'"),
            contains("title: 'Tag'"),
            contains("description: 'Visible tag'"),
            contains('option: DeskStringOption(optional: true)'),
            contains('option: DeskArrayOption(horizontal: true)'),
          ),
        );
      },
    );

    test('infers primitive inner fields from the array item type', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'Array Config', description: 'Array config')
class ArrayConfig {
  @DeskArray<int>()
  final List<int> scores;

  const ArrayConfig({required this.scores});

  static ArrayConfig? defaultValue = const ArrayConfig(scores: []);
}
'''),
        allOf(
          contains('DeskArrayField<int>('),
          contains("innerField: DeskNumberField(name: 'item', title: 'Int')"),
        ),
      );
    });

    test('discovers object array item field lists', () async {
      await _testDeskBuilder(
        _fixture('''
class ItemConfig {
  @DeskString()
  final String title;

  const ItemConfig({required this.title});

  static ItemConfig? defaultValue = const ItemConfig(title: '');
}

@DeskModel(title: 'Array Config', description: 'Array config')
class ArrayConfig {
  @DeskArray<ItemConfig>()
  final List<ItemConfig> items;

  const ArrayConfig({required this.items});

  static ArrayConfig? defaultValue = const ArrayConfig(items: []);
}
'''),
        allOf(
          contains('final arrayConfigFields = ['),
          contains('ColumnFields(children: itemConfigFields)'),
          contains('final itemConfigFields = ['),
          contains("DeskStringField(name: 'title', title: 'Title')"),
        ),
      );
    });

    test('infers fields for unannotated object array item classes', () async {
      await _testDeskBuilder(
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

@DeskModel(title: 'Array Config', description: 'Array config')
class ArrayConfig {
  @DeskArray<ItemConfig>()
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
          contains("DeskStringField(name: 'title', title: 'Title')"),
          contains("DeskImageField(name: 'image', title: 'Image')"),
          contains("name: 'unannotatedTopLevelField'"),
        ),
      );
    });
  });

  group('DeskFieldGenerator deduplication', () {
    test(
      'does not emit field list for discovered classes with @DeskModel',
      () async {
        await _testDeskBuilder(
          _fixture('''
@DeskModel(title: 'Hero', description: 'Hero config')
class HeroConfig {
  @DeskString()
  final String heroName;

  const HeroConfig({required this.heroName});

  static HeroConfig? defaultValue;
}

@DeskModel(title: 'Array Test', description: 'Array test config')
class ArrayTestConfig {
  @DeskArray<HeroConfig>()
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
      'still emits field list for discovered classes without @DeskModel',
      () async {
        await _testDeskBuilder(
          _fixture('''
class SampleConfig {
  @DeskString()
  final String sampleName;

  const SampleConfig({required this.sampleName});

  static SampleConfig? defaultValue;
}

@DeskModel(title: 'Parent', description: 'Parent config')
class ParentConfig {
  @DeskArray<SampleConfig>()
  final List<SampleConfig> samples;

  const ParentConfig({required this.samples});

  static ParentConfig? defaultValue = const ParentConfig(samples: []);
}
'''),
          allOf(
            contains('final parentConfigFields = ['),
            // SampleConfig has no @DeskModel, so its fields should be emitted
            contains('final sampleConfigFields = ['),
          ),
        );
      },
    );
  });

  group('DeskFieldGenerator auto-detection', () {
    test('auto-detects String field without annotation', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final String name;

  const AutoDetectConfig({required this.name});

  static AutoDetectConfig? defaultValue;
}
'''),
        contains('DeskStringField(name: \'name\', title: \'Name\')'),
      );
    });

    test(
      'auto-detects List<String> field without annotation defaults to Array',
      () async {
        await _testDeskBuilder(
          _fixture('''
@DeskModel(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final List<String> tags;

  const AutoDetectConfig({required this.tags});

  static AutoDetectConfig? defaultValue = const AutoDetectConfig(tags: []);
}
'''),
          allOf(
            contains('DeskArrayField<String>'),
            contains('innerField: DeskStringField'),
          ),
        );
      },
    );

    test('auto-detects int field as NumberField', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final int count;

  const AutoDetectConfig({required this.count});

  static AutoDetectConfig? defaultValue;
}
'''),
        contains('DeskNumberField(name: \'count\', title: \'Count\')'),
      );
    });

    test('auto-detects bool field as BooleanField', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final bool enabled;

  const AutoDetectConfig({required this.enabled});

  static AutoDetectConfig? defaultValue;
}
'''),
        contains('DeskBooleanField(name: \'enabled\', title: \'Enabled\')'),
      );
    });

    test('auto-detects DateTime field as DateTimeField', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final DateTime createdAt;

  const AutoDetectConfig({required this.createdAt});

  static AutoDetectConfig? defaultValue;
}
'''),
        contains(
          'DeskDateTimeField(name: \'createdAt\', title: \'Created At\')',
        ),
      );
    });

    test('auto-detects Uri field as UrlField', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'Auto', description: 'Auto detect test')
class AutoDetectConfig {
  final Uri website;

  const AutoDetectConfig({required this.website});

  static AutoDetectConfig? defaultValue;
}
'''),
        contains('DeskUrlField(name: \'website\', title: \'Website\')'),
      );
    });

    test('explicit annotation takes precedence over auto-detection', () async {
      await _testDeskBuilder(
        _fixture('''
@DeskModel(title: 'Mixed', description: 'Mixed config')
class MixedConfig {
  final String name;

  @DeskText()
  final String description;

  const MixedConfig({required this.name, required this.description});

  static MixedConfig? defaultValue;
}
'''),
        allOf(
          contains('DeskStringField(name: \'name\', title: \'Name\')'),
          contains(
            'DeskTextField(name: \'description\', title: \'Description\')',
          ),
        ),
      );
    });
  });
}

/// Matches a string that contains [substring] exactly [count] times.
Matcher _containsExactCount(String substring, int count) =>
    predicate((dynamic s) {
      var occurrences = 0;
      var index = 0;
      while ((index = s.indexOf(substring, index)) != -1) {
        occurrences++;
        index += substring.length;
      }
      return occurrences == count;
    }, 'contains "$substring" exactly $count time(s)');

String _fixture(String body) =>
    '''
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

part 'input.desk.dart';

$body
''';

Future<void> _testDeskBuilder(String source, Matcher outputMatcher) async {
  final reader = TestReaderWriter(rootPackage: 'dart_desk_generator');
  await reader.testing.loadIsolateSources();

  await testBuilder(
    deskBuilder(BuilderOptions({})),
    {'dart_desk_generator|lib/input.dart': source},
    generateFor: {'dart_desk_generator|lib/input.dart'},
    readerWriter: reader,
    outputs: {
      'dart_desk_generator|lib/input.desk.dart': decodedMatches(outputMatcher),
    },
  );
}
