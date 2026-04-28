import 'dart:convert';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk_client/dart_desk_client.dart' as serverpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_client/serverpod_client.dart';

class _MockEndpointPublicContent extends Mock
    implements serverpod.EndpointPublicContent {}

void main() {
  late _MockEndpointPublicContent endpoint;
  late CloudPublicContentSource source;

  final uuid = UuidValue.fromString('00000000-0000-0000-0000-000000000001');
  final now = DateTime(2026, 4, 28);

  serverpod.PublicDocument makeDoc({
    String documentType = 'article',
    String title = 'Hello',
    String slug = 'hello',
    bool isDefault = true,
    Map<String, dynamic>? data,
  }) =>
      serverpod.PublicDocument(
        id: uuid,
        documentType: documentType,
        title: title,
        slug: slug,
        isDefault: isDefault,
        data: jsonEncode(data ?? {'body': 'world'}),
        publishedAt: now,
        updatedAt: now,
      );

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
      final converted = result['article']!;
      expect(converted.id, uuid.toString());
      expect(converted.documentType, 'article');
      expect(converted.title, 'Hello');
      expect(converted.slug, 'hello');
      expect(converted.isDefault, isTrue);
      expect(converted.data, {'body': 'world'});
      expect(converted.publishedAt, now);
      expect(converted.updatedAt, now);
    });
  });

  group('getAllContents', () {
    test('converts list values', () async {
      final doc = makeDoc();
      when(() => endpoint.getAllContents())
          .thenAnswer((_) async => {'article': [doc]});

      final result = await source.getAllContents();

      expect(result['article'], hasLength(1));
      expect(result['article']!.first.id, uuid.toString());
    });
  });

  group('getContentsByType', () {
    test('converts list', () async {
      final doc = makeDoc();
      when(() => endpoint.getContentsByType('article'))
          .thenAnswer((_) async => [doc]);

      final result = await source.getContentsByType('article');

      expect(result, hasLength(1));
      expect(result.first.slug, 'hello');
    });
  });

  group('getDefaultContent', () {
    test('converts single doc', () async {
      final doc = makeDoc();
      when(() => endpoint.getDefaultContent('article'))
          .thenAnswer((_) async => doc);

      final result = await source.getDefaultContent('article');

      expect(result.isDefault, isTrue);
    });
  });

  group('getContentBySlug', () {
    test('converts single doc', () async {
      final doc = makeDoc(slug: 'my-slug');
      when(() => endpoint.getContentBySlug('article', 'my-slug'))
          .thenAnswer((_) async => doc);

      final result = await source.getContentBySlug('article', 'my-slug');

      expect(result.slug, 'my-slug');
    });
  });

  group('getContentsByDataContains', () {
    test('converts list', () async {
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
      expect(result.first.data, {'tag': 'flutter'});
    });
  });
}
