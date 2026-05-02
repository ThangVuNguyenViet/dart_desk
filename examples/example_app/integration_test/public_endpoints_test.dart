// Public-endpoint round-trip integration tests.
//
// Each test publishes content via the authenticated studio data source
// (`CloudDataSource`) and verifies the consumer-facing example_app reads
// it back through `CloudPublicContentSource`. Together they pin the
// publish → read wire format that powers production consumers.
//
// These tests do NOT reset the database; each test scopes itself to
// uniquely-titled documents and asserts on its own writes.
import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils/test_app.dart';

void main() {
  ensureTestInitialized();

  group('Public endpoints round-trip', () {
    testWidgets(
      'TC-PUB-01: studio publishes BrandTheme default → consumer renders it',
      (tester) async {
        final studio = await studioDataSource();

        // Publish a default BrandTheme so example_app's `getDefaultContents`
        // has something to render. Use a unique title so concurrent test
        // runs don't collide on metadata, but the document type stays
        // `brandTheme` (one default per type).
        final title = 'PUB-01 Theme ${DateTime.now().toIso8601String()}';
        final doc = await studio.createDocument(
          'brandTheme',
          title,
          BrandThemeFixtures.showcase().toMap(),
        );
        await studio.publishCurrentVersion(doc.id!);
        await studio.setDefaultDocument('brandTheme', doc.id!);

        await pumpExampleApp(tester);

        // Spinner should be gone — the content fetched and decoded.
        expect(find.byType(CircularProgressIndicator), findsNothing);
        // Section labels are static markers from BrandThemeScreen — their
        // presence proves the BrandTheme was read, decoded, and rendered.
        expect(find.text('COLOR PALETTE'), findsOneWidget);
        expect(find.text('TYPOGRAPHY'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-PUB-02: studio publishes new version → consumer reads updated data',
      (tester) async {
        final studio = await studioDataSource();
        final reader = publicContentSource();

        // First version: showcase BrandTheme.
        final title = 'PUB-02 Theme ${DateTime.now().toIso8601String()}';
        final doc = await studio.createDocument(
          'brandTheme',
          title,
          BrandThemeFixtures.showcase().toMap(),
        );
        await studio.publishCurrentVersion(doc.id!);
        await studio.setDefaultDocument('brandTheme', doc.id!);

        // Second publish: tweak the brand name and publish.
        await studio.updateDocumentData(
          doc.id!,
          BrandThemeFixtures.showcase().copyWith(name: 'Updated Aura').toMap(),
        );
        await studio.publishCurrentVersion(doc.id!);

        final read = await reader.getDefaultContent('brandTheme');
        final theme = BrandThemeMapper.fromMap(read.data);
        expect(theme.name, 'Updated Aura');
      },
    );

    testWidgets(
      'TC-PUB-03: getContentBySlug returns a published non-default document',
      (tester) async {
        final studio = await studioDataSource();
        final reader = publicContentSource();

        final slug = 'pub-03-${DateTime.now().millisecondsSinceEpoch}';
        final title = 'PUB-03 Theme';
        final doc = await studio.createDocument(
          'brandTheme',
          title,
          BrandThemeFixtures.showcase().copyWith(name: 'Slug Theme').toMap(),
          slug: slug,
        );
        await studio.publishCurrentVersion(doc.id!);

        final read = await reader.getContentBySlug('brandTheme', slug);
        final theme = BrandThemeMapper.fromMap(read.data);
        expect(theme.name, 'Slug Theme');
        expect(read.slug, slug);
      },
    );
  });
}
