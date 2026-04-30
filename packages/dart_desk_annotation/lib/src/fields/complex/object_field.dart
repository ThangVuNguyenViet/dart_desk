import '../base/field.dart';
import 'field_layout.dart';

class DeskObjectOption extends DeskOption {
  final List<DeskFieldLayout> children;

  const DeskObjectOption({required this.children, super.hidden, super.optional});

  /// Walk the layout tree to collect all leaf [DeskField] instances.
  List<DeskField> get fields => children.expand((c) => c.flatFields).toList();
}

class DeskObjectField extends DeskField {
  const DeskObjectField({
    required super.name,
    required super.title,
    super.description,
    this.fromMap,
    DeskObjectOption super.option = const DeskObjectOption(children: []),
  });

  /// Converts a raw [Map<String, dynamic>] (e.g. from Firestore) back to a
  /// typed object [T]. For non-primitive object types, the model class must
  /// provide a static `$fromMap` method and the generated code passes it here.
  final Function(Map<String, dynamic>)? fromMap;

  @override
  DeskObjectOption get option =>
      (super.option as DeskObjectOption?) ?? const DeskObjectOption(children: []);
}

class DeskObject extends DeskFieldConfig {
  const DeskObject({
    super.name,
    super.title,
    super.description,
    DeskObjectOption super.option = const DeskObjectOption(children: []),
  });

  @override
  List<Type> get supportedFieldTypes => [Object];
}
