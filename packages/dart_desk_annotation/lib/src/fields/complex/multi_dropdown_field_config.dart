import '../base/field.dart';
import 'dropdown_field.dart';

/// Annotation to mark a `List<T>` field as a multi-select dropdown in the CMS.
///
/// Requires a [CmsMultiDropdownOption<T>] to supply the available options.
class CmsMultiDropdownFieldConfig<T> extends CmsFieldConfig {
  const CmsMultiDropdownFieldConfig({
    super.name,
    super.title,
    super.description,
    required CmsMultiDropdownOption<T> super.option,
  });

  @override
  List<Type> get supportedFieldTypes => [List<T>];
}
