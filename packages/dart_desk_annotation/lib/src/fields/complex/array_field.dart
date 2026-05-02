import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';

typedef DeskArrayFieldItemBuilder<T> =
    Widget Function(BuildContext context, T value);

/// Factory function used to build a [DeskArrayInput]-like widget for a given
/// [DeskArrayField]. Defined as a generic function so the type parameter T is
/// propagated correctly through virtual dispatch in [DeskArrayField.buildInput].
typedef DeskArrayInputFactory =
    Widget Function<T>(
      DeskArrayField<T> field,
      DeskData? data,
      ValueChanged<List?>? onChanged,
      Key? key,
    );

class DeskArrayOption<T> extends DeskOption {
  const DeskArrayOption({super.optional, super.visibleWhen, this.itemBuilder});

  final DeskArrayFieldItemBuilder<T>? itemBuilder;

  /// Calls [itemBuilder] with [value], bypassing the static
  /// type system so that a typed option (e.g. DeskArrayOption<String>) can be
  /// used through an untyped DeskArrayField reference.
  Widget buildItem(BuildContext context, T value) {
    return itemBuilder?.call(context, value) ?? Text(value.toString());
  }
}

class DeskArrayField<T> extends DeskField {
  const DeskArrayField({
    required super.name,
    required super.title,
    super.description,
    required this.innerField,
    this.fromMap,
    DeskArrayOption<T>? super.option,
  });

  final DeskField innerField;

  /// Converts a raw [Map<String, dynamic>] (e.g. from Firestore) to [T].
  ///
  /// For non-primitive array item types, the model class must provide a static
  /// `$fromMap` method (e.g. `CategoryConfig.$fromMap`) and the generated code
  /// passes it here. Primitive types (String, int, etc.) don't need this.
  final T Function(Map<String, dynamic>)? fromMap;

  static DeskArrayInputFactory? _inputFactory;

  /// Register the factory used by [buildInput] to construct the typed input
  /// widget. Call this once from the `dart_desk` package (e.g. inside
  /// [DeskFieldInputRegistry]) before any form is rendered.
  static void registerInputFactory(DeskArrayInputFactory factory) {
    _inputFactory ??= factory;
  }

  /// Builds the typed input widget for this field. Because this method is
  /// defined inside [DeskArrayField<T>], Dart's virtual dispatch ensures T is
  /// the concrete item type (e.g. TipOption) even when the caller holds an
  /// erased [DeskArrayField<Object?>] reference.
  Widget buildInput({Key? key, DeskData? data, ValueChanged<List?>? onChanged}) {
    assert(
      _inputFactory != null,
      'DeskArrayField.registerInputFactory() must be called before buildInput(). '
      'Call it from dart_desk (e.g. in DeskFieldInputRegistry) at startup.',
    );
    return _inputFactory!<T>(this, data, onChanged, key);
  }

  @override
  DeskArrayOption<T>? get option => super.option as DeskArrayOption<T>?;
}

class DeskArray<T> extends DeskFieldConfig {
  const DeskArray({
    super.name,
    super.title,
    super.description,
    this.inner,
    DeskArrayOption<T>? super.option,
  });

  final DeskFieldConfig? inner;

  @override
  List<Type> get supportedFieldTypes => [List<T>];
}
