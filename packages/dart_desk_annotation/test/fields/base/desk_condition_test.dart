import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeContext extends DeskContext {
  const _FakeContext({this.document});
  @override
  final DeskDocument? document;
  @override
  DeskListenable<List<DeskDocument>> documents(String documentType) =>
      throw StateError('documents() not stubbed in this test');
  @override
  T read<T extends Object>() =>
      throw StateError('read<$T>() not stubbed in this test');
}

DeskContext _ctxWithData(Map<String, dynamic> data) {
  return _FakeContext(
    document: DeskDocument(
      clientId: 'c',
      documentType: 'doc',
      title: 't',
      activeVersionData: data,
    ),
  );
}

void main() {
  group('FieldEquals', () {
    test('returns true when field equals value', () {
      const cond = FieldEquals('status', 'published');
      expect(cond.evaluate(_ctxWithData({'status': 'published'})), isTrue);
    });
    test('returns false when field differs', () {
      const cond = FieldEquals('status', 'published');
      expect(cond.evaluate(_ctxWithData({'status': 'draft'})), isFalse);
    });
    test('returns false when document is null', () {
      const cond = FieldEquals('status', 'published');
      expect(cond.evaluate(const _FakeContext()), isFalse);
    });
  });

  group('FieldNotEquals', () {
    test('returns true when field differs', () {
      const cond = FieldNotEquals('status', 'published');
      expect(cond.evaluate(_ctxWithData({'status': 'draft'})), isTrue);
    });
    test('returns false when field matches', () {
      const cond = FieldNotEquals('status', 'published');
      expect(cond.evaluate(_ctxWithData({'status': 'published'})), isFalse);
    });
  });

  group('FieldNotNull', () {
    test('returns true when field is set', () {
      const cond = FieldNotNull('publishedAt');
      expect(cond.evaluate(_ctxWithData({'publishedAt': 'x'})), isTrue);
    });
    test('returns false when field is null', () {
      const cond = FieldNotNull('publishedAt');
      expect(cond.evaluate(_ctxWithData({'publishedAt': null})), isFalse);
    });
    test('returns false when document is null', () {
      const cond = FieldNotNull('publishedAt');
      expect(cond.evaluate(const _FakeContext()), isFalse);
    });
  });

  group('FieldIsNull', () {
    test('returns true when field is null', () {
      const cond = FieldIsNull('publishedAt');
      expect(cond.evaluate(_ctxWithData({'publishedAt': null})), isTrue);
    });
    test('returns false when field is set', () {
      const cond = FieldIsNull('publishedAt');
      expect(cond.evaluate(_ctxWithData({'publishedAt': 'x'})), isFalse);
    });
  });

  group('AllConditions', () {
    test('returns true when every child returns true', () {
      const cond = AllConditions([
        FieldEquals('a', 1),
        FieldEquals('b', 2),
      ]);
      expect(cond.evaluate(_ctxWithData({'a': 1, 'b': 2})), isTrue);
    });
    test('returns false when any child returns false', () {
      const cond = AllConditions([
        FieldEquals('a', 1),
        FieldEquals('b', 2),
      ]);
      expect(cond.evaluate(_ctxWithData({'a': 1, 'b': 3})), isFalse);
    });
  });

  group('AnyCondition', () {
    test('returns true when at least one child returns true', () {
      const cond = AnyCondition([
        FieldEquals('a', 1),
        FieldEquals('b', 2),
      ]);
      expect(cond.evaluate(_ctxWithData({'a': 99, 'b': 2})), isTrue);
    });
    test('returns false when no child returns true', () {
      const cond = AnyCondition([
        FieldEquals('a', 1),
        FieldEquals('b', 2),
      ]);
      expect(cond.evaluate(_ctxWithData({'a': 99, 'b': 99})), isFalse);
    });
  });
}
