import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';

typedef CmsArrayFieldItemBuilder<T> =
    Widget Function(BuildContext context, T value);
typedef CmsArrayFieldItemEditor<T> =
    Widget Function(BuildContext context, dynamic value, ValueChanged<T>? onChanged);

/// Factory function used to build a [CmsArrayInput]-like widget for a given
/// [CmsArrayField]. Defined as a generic function so the type parameter T is
/// propagated correctly through virtual dispatch in [CmsArrayField.buildInput].
typedef CmsArrayInputFactory =
    Widget Function<T>(
      CmsArrayField<T> field,
      CmsData? data,
      ValueChanged<List?>? onChanged,
      Key? key,
    );

abstract class CmsArrayOption<T> extends CmsOption {
  const CmsArrayOption({super.hidden});

  CmsArrayFieldItemBuilder<T> get itemBuilder;

  /// Calls [itemBuilder] with [value] cast to [T], bypassing the static
  /// type system so that a typed option (e.g. CmsArrayOption<String>) can be
  /// used through an untyped CmsArrayField reference.
  Widget buildItem(BuildContext context, dynamic value) {
    final toMapValue = value is Serializable ? value.toMap() : value;
    assert(
      toMapValue is T,
      'CmsArrayOption.buildItem: expected $T but got ${toMapValue.runtimeType}',
    );
    return itemBuilder(context, toMapValue);
  }

  /// Override to provide a custom editor widget for array items.
  /// When null, a default editor will be used for primitive types
  /// (String, num, int, double, bool).
  CmsArrayFieldItemEditor<T>? get itemEditor => null;

  /// Calls [itemEditor] with [value] as dynamic, bypassing the static T check
  /// at the call site — mirrors the same pattern as [buildItem].
  /// Returns null when [itemEditor] is null.
  Widget? buildItemEditor(
    BuildContext context,
    dynamic value,
    void Function(dynamic)? onChanged,
  ) {
    final editor = itemEditor;
    if (editor == null) return null;
    return editor(
      context,
      value,
      onChanged == null ? null : (T v) => onChanged(v),
    );
  }
}

class CmsArrayField<T> extends CmsField {
  const CmsArrayField({
    required super.name,
    required super.title,
    super.description,
    CmsArrayOption<T>? super.option,
  });

  static CmsArrayInputFactory? _inputFactory;

  /// Register the factory used by [buildInput] to construct the typed input
  /// widget. Call this once from the `dart_desk` package (e.g. inside
  /// [CmsFieldInputRegistry]) before any form is rendered.
  static void registerInputFactory(CmsArrayInputFactory factory) {
    _inputFactory ??= factory;
  }

  /// Builds the typed input widget for this field. Because this method is
  /// defined inside [CmsArrayField<T>], Dart's virtual dispatch ensures T is
  /// the concrete item type (e.g. TipOption) even when the caller holds an
  /// erased [CmsArrayField<Object?>] reference.
  Widget buildInput({Key? key, CmsData? data, ValueChanged<List?>? onChanged}) {
    assert(
      _inputFactory != null,
      'CmsArrayField.registerInputFactory() must be called before buildInput(). '
      'Call it from dart_desk (e.g. in CmsFieldInputRegistry) at startup.',
    );
    return _inputFactory!<T>(this, data, onChanged, key);
  }

  @override
  CmsArrayOption<T>? get option => super.option as CmsArrayOption<T>?;
}

class CmsArrayFieldConfig<T> extends CmsFieldConfig {
  const CmsArrayFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsArrayOption<T>? super.option,
  });

  @override
  List<Type> get supportedFieldTypes => [List];
}
