import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:dart_desk_client/dart_desk_client.dart' as serverpod;

import '../data/data.dart';
import '../data/models/public_desk_document.dart';
import '../data/public_content_source.dart';

/// Cloud implementation of [PublicContentSource] backed by the Serverpod
/// `publicContent` endpoint.
///
/// Converts [serverpod.PublicDocument] values to platform-agnostic
/// [PublicDeskDocument] values so consumers never depend on generated client
/// types. Errors from the underlying endpoint (network, parsing) are wrapped
/// in [DeskDataSourceException] to match [CloudDataSource]'s contract.
class CloudPublicContentSource implements PublicContentSource {
  /// Creates a [CloudPublicContentSource] using the production [client].
  CloudPublicContentSource(serverpod.Client client)
      : _endpoint = client.publicContent;

  /// Test-only constructor that injects an endpoint directly.
  CloudPublicContentSource.fromEndpoint(this._endpoint);

  final serverpod.EndpointPublicContent _endpoint;

  /// Logs the error with stack trace and throws a [DeskDataSourceException].
  Never _throw(String message, Object error, [StackTrace? stack]) {
    final st = stack ?? StackTrace.current;
    debugPrint('[CloudPublicContentSource] $message: $error');
    debugPrintStack(stackTrace: st, label: 'CloudPublicContentSource');
    throw DeskDataSourceException(message, error);
  }

  @override
  Future<Map<String, List<PublicDeskDocument>>> getAllContents() async {
    try {
      final raw = await _endpoint.getAllContents();
      return raw.map((k, v) => MapEntry(k, v.map(_toPublic).toList()));
    } catch (e, st) {
      _throw('Failed to get all contents', e, st);
    }
  }

  @override
  Future<Map<String, PublicDeskDocument>> getDefaultContents() async {
    try {
      final raw = await _endpoint.getDefaultContents();
      return raw.map((k, v) => MapEntry(k, _toPublic(v)));
    } catch (e, st) {
      _throw('Failed to get default contents', e, st);
    }
  }

  @override
  Future<List<PublicDeskDocument>> getContentsByType(
    String documentType,
  ) async {
    try {
      final raw = await _endpoint.getContentsByType(documentType);
      return raw.map(_toPublic).toList();
    } catch (e, st) {
      _throw('Failed to get contents by type', e, st);
    }
  }

  @override
  Future<PublicDeskDocument> getDefaultContent(String documentType) async {
    try {
      final raw = await _endpoint.getDefaultContent(documentType);
      return _toPublic(raw);
    } catch (e, st) {
      _throw('Failed to get default content', e, st);
    }
  }

  @override
  Future<PublicDeskDocument> getContentBySlug(
    String documentType,
    String slug,
  ) async {
    try {
      final raw = await _endpoint.getContentBySlug(documentType, slug);
      return _toPublic(raw);
    } catch (e, st) {
      _throw('Failed to get content by slug', e, st);
    }
  }

  @override
  Future<List<PublicDeskDocument>> getContentsByDataContains(
    String documentType,
    String dataContainsJson,
  ) async {
    try {
      final raw = await _endpoint.getContentsByDataContains(
        documentType,
        dataContainsJson,
      );
      return raw.map(_toPublic).toList();
    } catch (e, st) {
      _throw('Failed to get contents by data contains', e, st);
    }
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
