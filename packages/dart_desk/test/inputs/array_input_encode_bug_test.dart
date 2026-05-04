import 'dart:convert';

import 'package:dart_desk/src/inputs/array_input.dart';
import 'package:dart_desk/src/inputs/serializable_encode.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helpers/input_test_helpers.dart';

/// Mimics dart_mappable's generated contract:
///   - `Map<String, dynamic> toMap()` — encodable form
///   - `String toJson()` — already-encoded JSON string (the trap that
///     trips Dart's `_defaultToEncodable`)
///   - static `fromMap` for hydration
class _Item with Serializable<_Item> {
  _Item({this.label});
  final String? label;

  @override
  Map<String, dynamic> toMap() => {'label': label};

  String toJson() => jsonEncode(toMap());

  static _Item fromMap(Map<String, dynamic> m) =>
      _Item(label: m['label'] as String?);

  @override
  bool operator ==(Object other) => other is _Item && other.label == label;
  @override
  int get hashCode => label.hashCode;
}

/// Simulates the document_editor boundary: every input's onChanged passes
/// its value through `encodeForSave` before it lands in `editedData`,
/// which is then `jsonEncode`d at the data-source boundary.
List _wireListFor(String fieldName, dynamic emittedFromInput) {
  final editedData = <String, dynamic>{
    fieldName: encodeForSave(emittedFromInput),
  };
  final wire = jsonEncode(editedData);
  final decoded = jsonDecode(wire) as Map<String, dynamic>;
  return decoded[fieldName] as List;
}

void main() {
  group('Serializable items survive the input → wire boundary', () {
    testWidgets('array_input: delete emits items that encode as Maps', (
      tester,
    ) async {
      final field = DeskArrayField<_Item>(
        name: 'items',
        title: 'Items',
        innerField: const DeskStringField(name: 'label', title: 'Label'),
        fromMap: _Item.fromMap,
      );

      List? received;
      await tester.pumpWidget(
        buildInputApp(
          DeskArrayInput<_Item>(
            field: field,
            data: DeskData(
              value: <_Item>[
                _Item(label: 'A'),
                _Item(label: 'B'),
              ],
              path: 'items',
            ),
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger onChanged via a delete (no editor interaction needed).
      await tester.tap(find.byIcon(FontAwesomeIcons.trash).last);
      await tester.pumpAndSettle();

      final itemsOnWire = _wireListFor('items', received);
      expect(
        itemsOnWire.first,
        isA<Map>(),
        reason: 'array items must serialize as Maps on the wire',
      );
      expect((itemsOnWire.first as Map)['label'], 'A');
    });

    test('encodeForSave: single Serializable lands as Map on the wire', () {
      // Mirrors what dropdown_input emits: a single typed T?, which the
      // form boundary pipes through encodeForSave.
      final selection = _Item(label: 'A');
      final wire = jsonEncode({'item': encodeForSave(selection)});
      final decoded = jsonDecode(wire) as Map<String, dynamic>;
      expect(decoded['item'], isA<Map>());
      expect((decoded['item'] as Map)['label'], 'A');
    });

    test('encodeForSave: list of Serializables lands as list of Maps', () {
      // Mirrors what multi_dropdown_input emits: a List<T> of typed
      // values. The form boundary pipes the whole list through
      // encodeForSave.
      final selection = <_Item>[_Item(label: 'A'), _Item(label: 'B')];
      final itemsOnWire = _wireListFor('items', selection);
      expect(itemsOnWire, hasLength(2));
      expect(itemsOnWire.every((e) => e is Map), isTrue);
      expect((itemsOnWire[0] as Map)['label'], 'A');
      expect((itemsOnWire[1] as Map)['label'], 'B');
    });
  });
}
