import 'dart:convert';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk_client/dart_desk_client.dart' as serverpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockEndpointPublicContent extends Mock
    implements serverpod.EndpointPublicContent {}

void main() {
  late _MockEndpointPublicContent endpoint;
  late CloudPublicContentSource source;

  final uuid = serverpod.UuidValue.fromString(
    '00000000-0000-0000-0000-000000000001',
  );
  final publishedAt = DateTime.utc(2026, 4, 28, 9, 30);
  final updatedAt = DateTime.utc(2026, 4, 28, 10, 15);

  serverpod.PublicDocument makeDoc({
    String documentType = 'article',
    String title = 'Hello World',
    String slug = 'hello-world',
    bool isDefault = true,
    Map<String, dynamic>? data,
  }) =>
      serverpod.PublicDocument(
        id: uuid,
        documentType: documentType,
        title: title,
        slug: slug,
        isDefault: isDefault,
        data: jsonEncode(data ?? {'body': 'world', 'count': 3}),
        publishedAt: publishedAt,
        updatedAt: updatedAt,
      );

  /// Asserts every field of [actual] matches the canonical fixture from
  /// [makeDoc]. Any regression in `_toPublic` for any field will fail here.
  void expectFullConversion(
    PublicDeskDocument actual, {
    required String expectedDocumentType,
    required String expectedTitle,
    required String expectedSlug,
    required bool expectedIsDefault,
    required Map<String, dynamic> expectedData,
  }) {
    expect(actual.id, uuid.toString());
    expect(actual.documentType, expectedDocumentType);
    expect(actual.title, expectedTitle);
    expect(actual.slug, expectedSlug);
    expect(actual.isDefault, expectedIsDefault);
    expect(actual.data, expectedData);
    expect(actual.publishedAt, publishedAt);
    expect(actual.updatedAt, updatedAt);
  }

  setUp(() {
    endpoint = _MockEndpointPublicContent();
    source = CloudPublicContentSource.fromEndpoint(endpoint);
  });

  group('getDefaultContents', () {
    test('converts serverpod.PublicDocument → PublicDeskDocument', () async {
      final doc = makeDoc();
      when(() => endpoint.getDefaultContents())
          .thenAnswer((_) async => {'article': doc});

      final result = await source.getDefaultContents();

      expect(result.keys, contains('article'));
      expectFullConversion(
        result['article']!,
        expectedDocumentType: 'article',
        expectedTitle: 'Hello World',
        expectedSlug: 'hello-world',
        expectedIsDefault: true,
        expectedData: {'body': 'world', 'count': 3},
      );
    });
  });

  group('getAllContents', () {
    test('converts list values fully', () async {
      final doc = makeDoc();
      when(() => endpoint.getAllContents())
          .thenAnswer((_) async => {'article': [doc]});

      final result = await source.getAllContents();

      expect(result['article'], hasLength(1));
      expectFullConversion(
        result['article']!.first,
        expectedDocumentType: 'article',
        expectedTitle: 'Hello World',
        expectedSlug: 'hello-world',
        expectedIsDefault: true,
        expectedData: {'body': 'world', 'count': 3},
      );
    });
  });

  group('getContentsByType', () {
    test('converts list fully', () async {
      final doc = makeDoc(documentType: 'page', isDefault: false);
      when(() => endpoint.getContentsByType('page'))
          .thenAnswer((_) async => [doc]);

      final result = await source.getContentsByType('page');

      expect(result, hasLength(1));
      expectFullConversion(
        result.first,
        expectedDocumentType: 'page',
        expectedTitle: 'Hello World',
        expectedSlug: 'hello-world',
        expectedIsDefault: false,
        expectedData: {'body': 'world', 'count': 3},
      );
    });
  });

  group('getDefaultContent', () {
    test('converts single doc fully', () async {
      final doc = makeDoc();
      when(() => endpoint.getDefaultContent('article'))
          .thenAnswer((_) async => doc);

      final result = await source.getDefaultContent('article');

      expectFullConversion(
        result,
        expectedDocumentType: 'article',
        expectedTitle: 'Hello World',
        expectedSlug: 'hello-world',
        expectedIsDefault: true,
        expectedData: {'body': 'world', 'count': 3},
      );
    });
  });

  group('getContentBySlug', () {
    test('converts single doc fully', () async {
      final doc = makeDoc(slug: 'my-slug', title: 'My Title');
      when(() => endpoint.getContentBySlug('article', 'my-slug'))
          .thenAnswer((_) async => doc);

      final result = await source.getContentBySlug('article', 'my-slug');

      expectFullConversion(
        result,
        expectedDocumentType: 'article',
        expectedTitle: 'My Title',
        expectedSlug: 'my-slug',
        expectedIsDefault: true,
        expectedData: {'body': 'world', 'count': 3},
      );
    });
  });

  group('getContentsByDataContains', () {
    test('converts list fully', () async {
      final doc = makeDoc(data: {'tag': 'flutter'});
      when(() => endpoint.getContentsByDataContains(
            'article',
            '{"tag":"flutter"}',
          )).thenAnswer((_) async => [doc]);

      final result = await source.getContentsByDataContains(
        'article',
        '{"tag":"flutter"}',
      );

      expect(result, hasLength(1));
      expectFullConversion(
        result.first,
        expectedDocumentType: 'article',
        expectedTitle: 'Hello World',
        expectedSlug: 'hello-world',
        expectedIsDefault: true,
        expectedData: {'tag': 'flutter'},
      );
    });
  });

  group('error wrapping', () {
    test('wraps endpoint errors in DeskDataSourceException', () async {
      when(() => endpoint.getDefaultContents())
          .thenThrow(Exception('network down'));

      await expectLater(
        () => source.getDefaultContents(),
        throwsA(isA<DeskDataSourceException>()),
      );
    });
  });
}
