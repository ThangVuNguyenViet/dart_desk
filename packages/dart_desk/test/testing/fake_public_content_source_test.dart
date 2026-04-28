import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter_test/flutter_test.dart';

PublicDeskDocument _doc({
  String id = 'a',
  String type = 'brandTheme',
  String slug = 'default',
  bool isDefault = true,
  Map<String, dynamic>? data,
}) => PublicDeskDocument(
      id: id,
      documentType: type,
      title: 'T',
      slug: slug,
      isDefault: isDefault,
      data: data ?? const {'name': 'Aura'},
      publishedAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

void main() {
  group('FakePublicContentSource', () {
    test('seed() with published docs makes them visible', () async {
      final source = FakePublicContentSource()..seed([_doc()]);
      final defaults = await source.getDefaultContents();
      expect(defaults.keys, ['brandTheme']);
    });

    test('seedDraft() docs are filtered from all read methods', () async {
      final source = FakePublicContentSource()..seedDraft([_doc(id: 'd1')]);
      expect(await source.getDefaultContents(), isEmpty);
      expect(await source.getAllContents(), isEmpty);
      expect(await source.getContentsByType('brandTheme'), isEmpty);
      await expectLater(
        () => source.getDefaultContent('brandTheme'),
        throwsA(isA<StateError>()),
      );
    });

    test('getDefaultContent throws when no default exists', () async {
      final source = FakePublicContentSource();
      await expectLater(
        () => source.getDefaultContent('nope'),
        throwsA(isA<StateError>()),
      );
    });

    test('getContentBySlug returns the matching published doc', () async {
      final source = FakePublicContentSource()
        ..seed([_doc(slug: 'home'), _doc(id: 'b', slug: 'about')]);
      final doc = await source.getContentBySlug('brandTheme', 'about');
      expect(doc.id, 'b');
    });

    test('getContentsByDataContains matches a JSON-object fragment', () async {
      final source = FakePublicContentSource()
        ..seed([
          _doc(id: '1', data: const {'tag': 'x', 'n': 1}),
          _doc(id: '2', data: const {'tag': 'y', 'n': 2}),
        ]);
      final hits = await source.getContentsByDataContains(
        'brandTheme',
        '{"tag":"x"}',
      );
      expect(hits.map((d) => d.id), ['1']);
    });
  });
}
