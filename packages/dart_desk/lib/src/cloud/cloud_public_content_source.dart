import 'dart:convert';

import 'package:dart_desk_client/dart_desk_client.dart' as serverpod;

import '../data/models/public_desk_document.dart';
import '../data/public_content_source.dart';

/// Cloud implementation of [PublicContentSource] backed by the Serverpod
/// `publicContent` endpoint.
///
/// Converts [serverpod.PublicDocument] values to platform-agnostic
/// [PublicDeskDocument] values so consumers never depend on generated client
/// types.
class CloudPublicContentSource implements PublicContentSource {
  /// Creates a [CloudPublicContentSource] using the production [client].
  CloudPublicContentSource(serverpod.Client client)
      : _endpoint = client.publicContent;

  /// Test-only constructor that injects an endpoint directly.
  CloudPublicContentSource.fromEndpoint(this._endpoint);

  final serverpod.EndpointPublicContent _endpoint;

  @override
  Future<Map<String, List<PublicDeskDocument>>> getAllContents() async {
    final raw = await _endpoint.getAllContents();
    return raw.map((k, v) => MapEntry(k, v.map(_toPublic).toList()));
  }

  @override
  Future<Map<String, PublicDeskDocument>> getDefaultContents() async {
    final raw = await _endpoint.getDefaultContents();
    return raw.map((k, v) => MapEntry(k, _toPublic(v)));
  }

  @override
  Future<List<PublicDeskDocument>> getContentsByType(
    String documentType,
  ) async {
    final raw = await _endpoint.getContentsByType(documentType);
    return raw.map(_toPublic).toList();
  }

  @override
  Future<PublicDeskDocument> getDefaultContent(String documentType) async {
    final raw = await _endpoint.getDefaultContent(documentType);
    return _toPublic(raw);
  }

  @override
  Future<PublicDeskDocument> getContentBySlug(
    String documentType,
    String slug,
  ) async {
    final raw = await _endpoint.getContentBySlug(documentType, slug);
    return _toPublic(raw);
  }

  @override
  Future<List<PublicDeskDocument>> getContentsByDataContains(
    String documentType,
    String dataContainsJson,
  ) async {
    final raw =
        await _endpoint.getContentsByDataContains(documentType, dataContainsJson);
    return raw.map(_toPublic).toList();
  }

  PublicDeskDocument _toPublic(serverpod.PublicDocument d) => PublicDeskDocument(
        id: d.id.toString(),
        documentType: d.documentType,
        title: d.title,
        slug: d.slug,
        isDefault: d.isDefault,
        data: jsonDecode(d.data) as Map<String, dynamic>,
        publishedAt: d.publishedAt,
        updatedAt: d.updatedAt,
      );
}
