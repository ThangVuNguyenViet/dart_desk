import 'package:dart_desk/dart_desk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PublicDeskDocument', () {
    test('holds published metadata + decoded JSON data', () {
      final published = DateTime.utc(2026, 1, 1);
      final updated = DateTime.utc(2026, 2, 1);
      final doc = PublicDeskDocument(
        id: 'doc-1',
        documentType: 'brandTheme',
        title: 'Default theme',
        slug: 'default',
        isDefault: true,
        data: const {'documentType': 'brandTheme', 'name': 'Aura'},
        publishedAt: published,
        updatedAt: updated,
      );
      expect(doc.id, 'doc-1');
      expect(doc.documentType, 'brandTheme');
      expect(doc.title, 'Default theme');
      expect(doc.slug, 'default');
      expect(doc.isDefault, isTrue);
      expect(doc.data['name'], 'Aura');
      expect(doc.publishedAt, published);
      expect(doc.updatedAt, updated);
    });

    test('equality is value-based on all fields', () {
      PublicDeskDocument make() => PublicDeskDocument(
            id: 'x',
            documentType: 't',
            title: 'T',
            slug: 's',
            isDefault: false,
            data: const {'a': 1},
            publishedAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          );
      expect(make(), equals(make()));
      expect(make().hashCode, equals(make().hashCode));
    });

    test('inequality: differs on any field, including nested data', () {
      PublicDeskDocument build({
        String id = 'x',
        String documentType = 't',
        String title = 'T',
        String slug = 's',
        bool isDefault = false,
        Map<String, dynamic> data = const {
          'a': {'b': 1},
        },
        DateTime? publishedAt,
        DateTime? updatedAt,
      }) =>
          PublicDeskDocument(
            id: id,
            documentType: documentType,
            title: title,
            slug: slug,
            isDefault: isDefault,
            data: data,
            publishedAt: publishedAt ?? DateTime.utc(2026),
            updatedAt: updatedAt ?? DateTime.utc(2026),
          );

      final base = build();

      // Differing id.
      expect(base, isNot(equals(build(id: 'y'))));

      // Differing nested data value — proves deep equality is in use.
      expect(
        base,
        isNot(equals(build(data: const {
          'a': {'b': 2},
        }))),
      );

      // Equal nested data structures still compare equal.
      expect(
        build(data: const {
          'a': {'b': 1},
        }),
        equals(build(data: const {
          'a': {'b': 1},
        })),
      );

      // Differing publishedAt.
      expect(
        base,
        isNot(equals(build(publishedAt: DateTime.utc(2027)))),
      );

      // hashCode must incorporate data — differing data should yield
      // a different hash (would have caught the original hashCode bug).
      expect(
        build(data: const {'a': 1}).hashCode,
        isNot(equals(build(data: const {'a': 2}).hashCode)),
      );
    });
  });
}
