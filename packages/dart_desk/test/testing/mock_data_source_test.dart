import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:dart_desk/testing.dart';
import 'package:dart_desk/dart_desk.dart';

void main() {
  late MockDataSource dataSource;

  setUp(() {
    dataSource = MockDataSource()..seedDefaults();
  });

  /// Helper: returns sorted seed document IDs for 'test_all_fields'.
  Future<List<String>> seedDocIds() async {
    final result = await dataSource.getDocuments('test_all_fields');
    return result.documents.map((d) => d.id!).toList();
  }

  // ============================================================
  // 1. Seed state
  // ============================================================

  group('Seed state', () {
    test('getDocuments returns 3 documents for test_all_fields', () async {
      final result = await dataSource.getDocuments('test_all_fields');
      expect(result.documents.length, 3);
      expect(result.total, 3);
    });

    test('listMedia returns 4 media assets', () async {
      final result = await dataSource.listMedia();
      expect(result.items.length, 4);
      expect(result.total, 4);
    });

    test('First seed document title is Test Document Alpha', () async {
      final ids = await seedDocIds();
      final doc = await dataSource.getDocument(ids[0]);
      expect(doc, isNotNull);
      expect(doc!.title, 'Test Document Alpha');
    });

    test('First seed document is default', () async {
      final ids = await seedDocIds();
      final doc = await dataSource.getDocument(ids[0]);
      expect(doc, isNotNull);
      expect(doc!.isDefault, isTrue);
    });
  });

  // ============================================================
  // 2. Document CRUD
  // ============================================================

  group('Document CRUD', () {
    test(
      'createDocument adds a 4th document with correct title and slug',
      () async {
        final created = await dataSource.createDocument(
          'test_all_fields',
          'New Document Delta',
          {'string_field': 'Delta value'},
          slug: 'new-document-delta',
        );

        expect(created.title, 'New Document Delta');
        expect(created.slug, 'new-document-delta');

        final list = await dataSource.getDocuments('test_all_fields');
        expect(list.documents.length, 4);
      },
    );

    test(
      'updateDocument changes the title, verifiable via getDocument',
      () async {
        final ids = await seedDocIds();
        await dataSource.updateDocument(ids[1], title: 'Updated Beta Title');
        final doc = await dataSource.getDocument(ids[1]);
        expect(doc, isNotNull);
        expect(doc!.title, 'Updated Beta Title');
      },
    );

    test('deleteDocument removes the document and count drops', () async {
      final ids = await seedDocIds();
      final deleted = await dataSource.deleteDocument(ids[2]);
      expect(deleted, isTrue);

      final list = await dataSource.getDocuments('test_all_fields');
      expect(list.documents.length, 2);
    });
  });

  // ============================================================
  // 3. Media upload with deduplication
  // ============================================================

  group('Media upload with dedup', () {
    test(
      'uploadImage creates a new asset and returns it with correct fileName',
      () async {
        final fileData = Uint8List.fromList([0, 1, 2, 3]);
        final asset = await dataSource.uploadImage(
          'test-image.png',
          fileData,
        );

        expect(asset.fileName, 'test-image.png');

        final list = await dataSource.listMedia();
        expect(list.total, 5);
      },
    );

    test(
      'uploadImage with same bytes returns existing asset (dedup)',
      () async {
        final fileData = Uint8List.fromList([0, 1, 2, 3]);

        final first = await dataSource.uploadImage(
          'test-image.png',
          fileData,
        );
        final second = await dataSource.uploadImage(
          'test-image.png',
          fileData,
        );

        // Same asset returned — same assetId and id
        expect(second.assetId, first.assetId);
        expect(second.id, first.id);

        // Total media count should not have increased
        final list = await dataSource.listMedia();
        expect(list.total, 5);
      },
    );
  });

  // ============================================================
  // 4. Media delete blocks when referenced
  // ============================================================

  group('Media delete blocks when referenced', () {
    test(
      'deleteMedia on asset-hero throws DeskValidationException because document Alpha references it',
      () async {
        expect(
          () => dataSource.deleteMedia('asset-hero'),
          throwsA(isA<DeskValidationException>()),
        );
      },
    );

    test('deleteMedia on an unreferenced asset succeeds', () async {
      // asset-profile is not referenced by any document
      final result = await dataSource.deleteMedia('asset-profile');
      expect(result, isTrue);

      final list = await dataSource.listMedia();
      expect(list.total, 3);
    });
  });

  // ============================================================
  // N. setDefaultDocument
  // ============================================================

  group('setDefaultDocument', () {
    test(
      'swaps isDefault from the current default to a new document',
      () async {
        final ids = await seedDocIds();
        final doc4 = await dataSource.createDocument(
          'test_all_fields',
          'Doc Four',
          {},
          slug: 'doc-four',
        );

        final updated = await dataSource.setDefaultDocument(
          'test_all_fields',
          doc4.id!,
        );

        expect(updated.isDefault, isTrue);

        // Old default should now be false
        final old = await dataSource.getDocument(ids[0]);
        expect(old?.isDefault, isFalse);
      },
    );

    test('returns the updated document with isDefault true', () async {
      final doc4 = await dataSource.createDocument(
        'test_all_fields',
        'Doc Four',
        {},
        slug: 'doc-four',
      );
      final result = await dataSource.setDefaultDocument(
        'test_all_fields',
        doc4.id!,
      );
      expect(result.id, doc4.id);
      expect(result.isDefault, isTrue);
    });

    test('throws DeskNotFoundException for unknown documentId', () async {
      expect(
        () => dataSource.setDefaultDocument('test_all_fields', 'nonexistent'),
        throwsA(isA<DeskNotFoundException>()),
      );
    });
  });

  // ============================================================
  // N+1. Auto-default behaviours
  // ============================================================

  group('Auto-default on create', () {
    test('first document for a new type is auto-set as default', () async {
      final doc = await dataSource.createDocument(
        'new_type',
        'First Doc',
        {},
        slug: 'first-doc',
      );
      expect(doc.isDefault, isTrue);
    });

    test('second document for a type is NOT auto-set as default', () async {
      await dataSource.createDocument('new_type', 'First', {}, slug: 'first');
      final second = await dataSource.createDocument(
        'new_type',
        'Second',
        {},
        slug: 'second',
      );
      expect(second.isDefault, isFalse);
    });
  });

  group('Auto-default on delete', () {
    test(
      'sole remaining document becomes default when the default is deleted',
      () async {
        // Create two docs in a fresh type; first is auto-default
        final a = await dataSource.createDocument(
          'solo_type',
          'A',
          {},
          slug: 'a',
        );
        final b = await dataSource.createDocument(
          'solo_type',
          'B',
          {},
          slug: 'b',
        );
        expect(a.isDefault, isTrue);

        // Delete the default (a)
        await dataSource.deleteDocument(a.id!);

        final remaining = await dataSource.getDocument(b.id!);
        expect(remaining?.isDefault, isTrue);
      },
    );

    test(
      'no auto-default when a non-default is deleted and multiple remain',
      () async {
        final a = await dataSource.createDocument(
          'multi_type',
          'A',
          {},
          slug: 'a',
        );
        final b = await dataSource.createDocument(
          'multi_type',
          'B',
          {},
          slug: 'b',
        );
        final c = await dataSource.createDocument(
          'multi_type',
          'C',
          {},
          slug: 'c',
        );
        expect(a.isDefault, isTrue);

        // Delete non-default (c)
        await dataSource.deleteDocument(c.id!);

        final stillDefault = await dataSource.getDocument(a.id!);
        final bDoc = await dataSource.getDocument(b.id!);
        expect(stillDefault?.isDefault, isTrue);
        expect(bDoc?.isDefault, isFalse);
      },
    );
  });

  // ============================================================
  // 5. reset() restores seed state
  // ============================================================

  group('reset() restores seed state', () {
    test('after creating a document, reset() brings count back to 3', () async {
      await dataSource.createDocument('test_all_fields', 'Extra Document', {});

      var list = await dataSource.getDocuments('test_all_fields');
      expect(list.documents.length, 4);

      dataSource.reset();

      list = await dataSource.getDocuments('test_all_fields');
      expect(list.documents.length, 3);
    });
  });

  // ============================================================
  // 6. List filtering / sorting / pagination
  // ============================================================

  group('List filtering, sorting, and pagination', () {
    test('listMedia with search "hero" returns 1 result', () async {
      final result = await dataSource.listMedia(search: 'hero');
      expect(result.items.length, 1);
      expect(result.items.first.fileName, contains('hero'));
    });

    test(
      'listMedia with sort nameAsc returns assets in alphabetical order',
      () async {
        final result = await dataSource.listMedia(sort: MediaSort.nameAsc);
        final names = result.items
            .map((a) => a.fileName.toLowerCase())
            .toList();
        final sorted = List<String>.from(names)..sort();
        expect(names, sorted);
      },
    );

    test('getDocuments with search "Alpha" returns 1 document', () async {
      final result = await dataSource.getDocuments(
        'test_all_fields',
        search: 'Alpha',
      );
      expect(result.documents.length, 1);
      expect(result.documents.first.title, 'Test Document Alpha');
    });

    test('getDocuments with limit 2 returns 2 documents', () async {
      final result = await dataSource.getDocuments('test_all_fields', limit: 2);
      expect(result.documents.length, 2);
    });
  });
}
