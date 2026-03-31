import 'package:flutter/material.dart';

import '../base/field.dart';

typedef CmsArrayFieldItemBuilder<T> =
    Widget Function(BuildContext context, T value);
typedef CmsArrayFieldItemEditor<T> =
    Widget Function(
      BuildContext context,
      T value,
      ValueChanged<T>? onChanged,
    );

abstract class CmsArrayOption<T> extends CmsOption {
  const CmsArrayOption({super.hidden});

  CmsArrayFieldItemBuilder<T> get itemBuilder;

  /// Override to provide a custom editor widget for array items.
  /// When null, a default editor will be used for primitive types
  /// (String, num, int, double, bool).
  CmsArrayFieldItemEditor<T>? get itemEditor => null;
}

class CmsArrayField<T> extends CmsField {
  const CmsArrayField({
    required super.name,
    required super.title,
    super.description,
    CmsArrayOption<T>? super.option,
  });

  @override
  CmsArrayOption<T>? get option => super.option as CmsArrayOption<T>?;
}

class CmsArrayFieldConfig<T extends Object?> extends CmsFieldConfig {
  const CmsArrayFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsArrayOption<T>? super.option,
  });

  @override
  List<Type> get supportedFieldTypes => [List];
}
