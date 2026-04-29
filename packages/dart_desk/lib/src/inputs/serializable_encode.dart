import 'package:dart_desk_annotation/dart_desk_annotation.dart';

/// Converts [v] to its on-the-wire representation: [Serializable] instances
/// become [Map]s; [Iterable]s are converted recursively; primitives pass
/// through unchanged.
///
/// Inputs that emit typed model instances (array, dropdown, multi-dropdown)
/// pipe their `onChanged` payloads through this helper so the form's
/// `editedData` map only ever contains JSON-encodable primitives. Without
/// it, `jsonEncode` at the data-source boundary falls through to
/// `obj.toJson()` — which for dart_mappable returns a [String] and lands
/// in storage as an escaped JSON string literal.
dynamic encodeForSave(dynamic v) {
  if (v is Serializable) return v.toMap();
  if (v is Iterable) return v.map(encodeForSave).toList();
  return v;
}
