import '../base/field.dart';
import 'field_layout.dart';

class CmsObjectOption extends CmsOption {
  final List<CmsFieldLayout> children;

  const CmsObjectOption({required this.children, super.hidden});

  /// Walk the layout tree to collect all leaf [CmsField] instances.
  List<CmsField> get fields => children.expand((c) => c.flatFields).toList();
}

class CmsObjectField extends CmsField {
  const CmsObjectField({
    required super.name,
    required super.title,
    super.description,
    this.fromMap,
    CmsObjectOption super.option = const CmsObjectOption(children: []),
  });

  /// Converts a raw [Map<String, dynamic>] (e.g. from Firestore) back to a
  /// typed object [T]. For non-primitive object types, the model class must
  /// provide a static `$fromMap` method and the generated code passes it here.
  final Function(Map<String, dynamic>)? fromMap;

  @override
  CmsObjectOption get option => (super.option as CmsObjectOption?) ?? const CmsObjectOption(children: []);
}

class CmsObjectFieldConfig extends CmsFieldConfig {
  const CmsObjectFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsObjectOption super.option = const CmsObjectOption(
      children: [],
    ),
  });

  @override
  List<Type> get supportedFieldTypes => [Object];
}
