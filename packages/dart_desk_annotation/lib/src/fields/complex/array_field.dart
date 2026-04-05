import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';

typedef CmsArrayFieldItemBuilder<T> =
    Widget Function(BuildContext context, T value);

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

class CmsArrayOption<T> extends CmsOption {
  const CmsArrayOption({super.hidden, this.itemBuilder});

  final CmsArrayFieldItemBuilder<T>? itemBuilder;

  /// Calls [itemBuilder] with [value] cast to [T], bypassing the static
  /// type system so that a typed option (e.g. CmsArrayOption<String>) can be
  /// used through an untyped CmsArrayField reference.
  Widget buildItem(BuildContext context, T value) {
    return itemBuilder?.call(context, value) ?? Text(value.toString());
  }

  /// Convert a raw stored value (e.g. a [Map] from Firestore) to [T].
  /// Override this in subclasses for complex types; the default works for
  /// primitives where the stored form IS already [T].
  T fromDynamic(dynamic value) => value as T;
}

class CmsArrayField<T> extends CmsField {
  const CmsArrayField({
    required super.name,
    required super.title,
    super.description,
    required this.innerField,
    CmsArrayOption<T>? super.option,
  });

  final CmsField innerField;

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
    this.inner,
    CmsArrayOption<T>? super.option,
  });

  final CmsFieldConfig? inner;

  @override
  List<Type> get supportedFieldTypes => [List];
}
