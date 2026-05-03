import 'dart:convert';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_client/dart_desk_client.dart' as serverpod;

import '../data/data.dart';

final _log = Logger('dart_desk.cloud.dataSource');

/// Cloud data source implementation using the Serverpod dart_desk_client.
///
/// This class wraps the Serverpod-generated client and converts between
/// Serverpod models and platform-agnostic CMS data models.
///
/// ## Usage
///
/// ```dart
/// import 'package:dart_desk_client/dart_desk_client.dart';
/// import 'package:dart_desk_cloud/dart_desk_cloud.dart';
///
/// final client = Client('http://localhost:8080/');
/// final dataSource = CloudDataSource(client);
///
/// // Use the data source
/// final documents = await dataSource.getDocuments('article');
/// ```
class CloudDataSource implements DataSource {
  /// The Serverpod client used for API calls
  final serverpod.Client _client;

  /// Creates a new CloudDataSource with the given client.
  ///
  /// [client] - The Serverpod client instance configured with the server URL
  CloudDataSource(this._client);

  /// JSON-encodes [data] for the wire. Converts [Serializable] values to
  /// their [Map] form so a misplaced typed instance doesn't fall through
  /// to `obj.toJson()` (which, for dart_mappable, returns a String and
  /// would land in storage as an escaped JSON string literal).
  String _encodeData(Object? data) => jsonEncode(data, toEncodable: (v) {
    if (v is Serializable) return v.toMap();
    return (v as dynamic).toJson();
  });

  /// Logs the error with stack trace and throws a [DeskDataSourceException].
  Never _throw(String message, Object error, [StackTrace? stack]) {
    final st = stack ?? StackTrace.current;
    _log.severe(message, error, st);
    throw DeskDataSourceException(message, error);
  }

  // ============================================================
  // Document Operations
  // ============================================================

  @override
  Future<DocumentList> getDocuments(
    String documentType, {
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client.document.getDocuments(
        documentType,
        search: search,
        limit: limit,
        offset: offset,
      );

      return DocumentList(
        documents: response.items.map(_toDeskDocument).toList(),
        total: response.total,
        page: offset ~/ limit,
        pageSize: limit,
      );
    } catch (e, st) {
      _throw('Failed to get documents', e, st);
    }
  }

  @override
  Future<DeskDocument?> getDocument(String documentId) async {
    try {
      final response = await _client.document.getDocument(
        UuidValue.fromString(documentId),
      );
      if (response == null) return null;
      return _toDeskDocument(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 410) return null;
      rethrow;
    } catch (e, st) {
      _throw('Failed to get document', e, st);
    }
  }

  @override
  Future<DeskDocument> createDocument(
    String documentType,
    String title,
    Map<String, dynamic> data, {
    String? slug,
    bool isDefault = false,
  }) async {
    try {
      final response = await _client.document.createDocument(
        documentType,
        title,
        _encodeData(data),
        slug: slug,
        isDefault: isDefault,
      );
      return _toDeskDocument(response);
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to create document', e, st);
    } catch (e, st) {
      _throw('Failed to create document', e, st);
    }
  }

  @override
  Future<DeskDocument?> updateDocument(
    String documentId, {
    String? title,
    String? slug,
    bool? isDefault,
  }) async {
    try {
      final response = await _client.document.updateDocument(
        UuidValue.fromString(documentId),
        title: title,
        slug: slug,
        isDefault: isDefault,
      );
      if (response == null) return null;
      return _toDeskDocument(response);
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to update document', e, st);
    } catch (e, st) {
      _throw('Failed to update document', e, st);
    }
  }

  @override
  Future<DeskDocument> setDefaultDocument(
    String documentTypeSlug,
    String documentId,
  ) async {
    try {
      final doc = await _client.document.setDefaultDocument(
        documentTypeSlug,
        UuidValue.fromString(documentId),
      );
      return _toDeskDocument(doc);
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) throw const DeskAuthenticationException();
      _throw('Failed to set default document', e, st);
    } catch (e, st) {
      _throw('Failed to set default document', e, st);
    }
  }

  @override
  Future<bool> deleteDocument(String documentId) async {
    try {
      return await _client.document.deleteDocument(
        UuidValue.fromString(documentId),
      );
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to delete document', e, st);
    } catch (e, st) {
      _throw('Failed to delete document', e, st);
    }
  }

  @override
  Future<String> suggestSlug(String title, String documentType) async {
    try {
      return await _client.document.suggestSlug(title, documentType);
    } catch (e, st) {
      _throw('Failed to suggest slug', e, st);
    }
  }

  @override
  Future<List<String>> getDocumentTypes() async {
    try {
      return await _client.document.getDocumentTypes();
    } catch (e, st) {
      _throw('Failed to get document types', e, st);
    }
  }

  // ============================================================
  // Document Version Operations
  // ============================================================

  @override
  Future<DocumentVersionList> getDocumentVersions(
    String documentId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Always fetch with operations to compute data
      final response = await _client.document.getDocumentVersions(
        UuidValue.fromString(documentId),
        limit: limit,
        offset: offset,
        includeOperations: true,
      );

      // Convert versions and compute data from operations
      final versions = <DocumentVersion>[];

      // Start from base state (state at HLC before first version in page)
      // This ensures correct reconstruction even with pagination
      Map<String, dynamic> accumulatedState = response.baseData != null
          ? jsonDecode(response.baseData!) as Map<String, dynamic>
          : {}; // Empty state for first page (offset = 0)

      for (final versionWithOps in response.versions) {
        // Apply operations to accumulate state
        accumulatedState = _reconstructFromOperations(
          versionWithOps.operationsSincePrevious,
          initialState: accumulatedState,
        );

        versions.add(
          _toDocumentVersionWithData(versionWithOps.version, accumulatedState),
        );
      }

      return DocumentVersionList(
        versions: versions,
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
      );
    } catch (e, st) {
      _throw('Failed to get document versions', e, st);
    }
  }

  @override
  Future<DocumentVersion?> getDocumentVersion(String versionId) async {
    try {
      final response = await _client.document.getDocumentVersion(
        UuidValue.fromString(versionId),
      );
      if (response == null) return null;
      return _toDocumentVersion(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 410) return null;
      rethrow;
    } catch (e, st) {
      _throw('Failed to get document version', e, st);
    }
  }

  @override
  Future<Map<String, dynamic>?> getDocumentVersionData(String versionId) async {
    try {
      final dataJson = await _client.document.getDocumentVersionData(
        UuidValue.fromString(versionId),
      );
      return dataJson != null
          ? jsonDecode(dataJson) as Map<String, dynamic>
          : null;
    } catch (e, st) {
      _throw('Failed to get document version data', e, st);
    }
  }

  @override
  Future<DocumentVersion> createDocumentVersion(
    String documentId, {
    String status = 'draft',
    String? changeLog,
  }) async {
    try {
      // Convert string status to enum
      final enumStatus = _parseDocumentVersionStatus(status);

      final response = await _client.document.createDocumentVersion(
        UuidValue.fromString(documentId),
        status: enumStatus,
        changeLog: changeLog,
      );
      return _toDocumentVersion(response);
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to create document version', e, st);
    } catch (e, st) {
      _throw('Failed to create document version', e, st);
    }
  }

  @override
  Future<DocumentVersion?> archiveDocumentVersion(String versionId) async {
    try {
      final response = await _client.document.archiveDocumentVersion(
        UuidValue.fromString(versionId),
      );
      if (response == null) return null;
      return _toDocumentVersion(response);
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to archive document version', e, st);
    } catch (e, st) {
      _throw('Failed to archive document version', e, st);
    }
  }

  @override
  Future<bool> deleteDocumentVersion(String versionId) async {
    try {
      return await _client.document.deleteDocumentVersion(
        UuidValue.fromString(versionId),
      );
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to delete document version', e, st);
    } catch (e, st) {
      _throw('Failed to delete document version', e, st);
    }
  }

  @override
  Future<DocumentVersion> publishCurrentVersion(String documentId) async {
    try {
      final response = await _client.document.publishCurrentVersion(
        UuidValue.fromString(documentId),
      );
      return _toDocumentVersion(response);
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to publish current version', e, st);
    } catch (e, st) {
      _throw('Failed to publish current version', e, st);
    }
  }

  // ============================================================
  // Media Operations
  // ============================================================

  @override
  Future<MediaAsset> uploadImage(String fileName, Uint8List fileData) async {
    try {
      final byteData = ByteData.view(fileData.buffer);
      final response = await _client.media.uploadImage(fileName, byteData);
      return _toMediaAsset(response);
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to upload image', e, st);
    } catch (e, st) {
      _throw('Failed to upload image', e, st);
    }
  }

  @override
  Future<MediaAsset> uploadFile(String fileName, Uint8List fileData) async {
    try {
      final byteData = ByteData.view(fileData.buffer);
      final response = await _client.media.uploadFile(fileName, byteData);
      return _toMediaAsset(response);
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to upload file', e, st);
    } catch (e, st) {
      _throw('Failed to upload file', e, st);
    }
  }

  @override
  Future<bool> deleteMedia(String assetId) async {
    try {
      return await _client.media.deleteMedia(assetId);
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to delete media', e, st);
    } catch (e, st) {
      _throw('Failed to delete media', e, st);
    }
  }

  @override
  Future<MediaAsset?> getMediaAsset(String assetId) async {
    try {
      final response = await _client.media.getMedia(assetId);
      if (response == null) return null;
      return _toMediaAsset(response);
    } catch (e, st) {
      _throw('Failed to get media asset', e, st);
    }
  }

  @override
  Future<MediaPage> listMedia({
    String? search,
    MediaTypeFilter? type,
    MediaSort sort = MediaSort.dateDesc,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final sortBy = switch (sort) {
        MediaSort.dateDesc => 'date_desc',
        MediaSort.dateAsc => 'date_asc',
        MediaSort.nameAsc => 'name_asc',
        MediaSort.nameDesc => 'name_desc',
        MediaSort.sizeDesc => 'size_desc',
        MediaSort.sizeAsc => 'size_asc',
      };
      final mimeTypePrefix = switch (type) {
        MediaTypeFilter.image => 'image/',
        MediaTypeFilter.video => 'video/',
        MediaTypeFilter.file => null,
        MediaTypeFilter.all => null,
        null => null,
      };
      final response = await _client.media.listMedia(
        search: search,
        mimeTypePrefix: mimeTypePrefix,
        sortBy: sortBy,
        limit: limit,
        offset: offset,
      );
      final total = await _client.media.listMediaCount(
        search: search,
        mimeTypePrefix: mimeTypePrefix,
      );
      final items = response.map(_toMediaAsset).toList();
      return MediaPage(items: items, total: total);
    } catch (e, st) {
      _throw('Failed to list media', e, st);
    }
  }

  @override
  Future<MediaAsset> updateMediaAsset(
    String assetId, {
    String? fileName,
  }) async {
    try {
      final response = await _client.media.updateMediaAsset(
        assetId,
        fileName: fileName,
      );
      return _toMediaAsset(response);
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to update media asset', e, st);
    } catch (e, st) {
      _throw('Failed to update media asset', e, st);
    }
  }

  @override
  Future<int> getMediaUsageCount(String assetId) async {
    try {
      return await _client.media.getMediaUsageCount(assetId);
    } catch (e, st) {
      _throw('Failed to get media usage count', e, st);
    }
  }

  // ============================================================
  // Conversion Helpers
  // ============================================================

  /// Converts a Serverpod Document to a platform-agnostic DeskDocument.
  DeskDocument _toDeskDocument(serverpod.Document doc) {
    // Parse the data JSON string into a map if present
    // Note: 'data' now contains the latest CRDT-merged document state
    Map<String, dynamic>? parsedData;
    if (doc.data != null && doc.data!.isNotEmpty) {
      try {
        parsedData = jsonDecode(doc.data!) as Map<String, dynamic>;
      } catch (_) {
        parsedData = null;
      }
    }

    return DeskDocument(
      id: doc.id.toString(),
      clientId: doc.projectId.toString(),
      documentType: doc.documentType,
      title: doc.title,
      slug: doc.slug,
      isDefault: doc.isDefault,
      activeVersionData:
          parsedData, // Frontend still uses activeVersionData name
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
      createdByUserId: doc.createdByUserId?.toString(),
      updatedByUserId: doc.updatedByUserId?.toString(),
      crdtHlc: doc.crdtHlc,
    );
  }

  /// Converts a Serverpod MediaAsset to a platform-agnostic MediaAsset.
  MediaAsset _toMediaAsset(serverpod.MediaAsset asset) {
    MediaPalette? palette;
    if (asset.paletteJson != null) {
      try {
        palette = MediaPalette.fromJson(
          jsonDecode(asset.paletteJson!) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    Map<String, dynamic>? exif;
    if (asset.exifJson != null) {
      try {
        exif = jsonDecode(asset.exifJson!) as Map<String, dynamic>;
      } catch (_) {}
    }

    MediaGeoLocation? location;
    if (asset.locationLat != null && asset.locationLng != null) {
      location = MediaGeoLocation(
        lat: asset.locationLat!,
        lng: asset.locationLng!,
      );
    }

    return MediaAsset(
      id: asset.id.toString(),
      assetId: asset.assetId,
      fileName: asset.fileName,
      mimeType: asset.mimeType,
      fileSize: asset.fileSize,
      publicUrl: asset.publicUrl,
      width: asset.width,
      height: asset.height,
      hasAlpha: asset.hasAlpha,
      blurHash: asset.blurHash,
      lqip: asset.lqip,
      palette: palette,
      exif: exif,
      location: location,
      uploadedByUserId: asset.uploadedByUserId?.toString(),
      createdAt: asset.createdAt ?? DateTime.now(),
      metadataStatus: _toMetadataStatus(asset.metadataStatus),
    );
  }

  MediaAssetMetadataStatus _toMetadataStatus(
    serverpod.MediaAssetMetadataStatus status,
  ) {
    return switch (status) {
      serverpod.MediaAssetMetadataStatus.pending =>
        MediaAssetMetadataStatus.pending,
      serverpod.MediaAssetMetadataStatus.complete =>
        MediaAssetMetadataStatus.complete,
      serverpod.MediaAssetMetadataStatus.failed =>
        MediaAssetMetadataStatus.failed,
    };
  }

  /// Converts a Serverpod DocumentVersion to a platform-agnostic DocumentVersion.
  DocumentVersion _toDocumentVersion(serverpod.DocumentVersion version) {
    return DocumentVersion(
      id: version.id.toString(),
      documentId: version.documentId.toString(),
      versionNumber: version.versionNumber,
      status: DocumentVersionStatus.fromString(version.status.name),
      snapshotHlc: version.snapshotHlc,
      changeLog: version.changeLog,
      publishedAt: version.publishedAt,
      scheduledAt: version.scheduledAt,
      archivedAt: version.archivedAt,
      createdAt: version.createdAt,
      createdByUserId: version.createdByUserId?.toString(),
    );
  }

  /// Converts a Serverpod DocumentVersion to platform-agnostic with computed data.
  DocumentVersion _toDocumentVersionWithData(
    serverpod.DocumentVersion version,
    Map<String, dynamic> data,
  ) {
    return DocumentVersion(
      id: version.id.toString(),
      documentId: version.documentId.toString(),
      versionNumber: version.versionNumber,
      status: DocumentVersionStatus.fromString(version.status.name),
      data: Map<String, dynamic>.from(data), // Copy to avoid mutation
      snapshotHlc: version.snapshotHlc,
      changeLog: version.changeLog,
      publishedAt: version.publishedAt,
      scheduledAt: version.scheduledAt,
      archivedAt: version.archivedAt,
      createdAt: version.createdAt,
      createdByUserId: version.createdByUserId?.toString(),
    );
  }

  /// Reconstructs document data from Serverpod CRDT operations.
  Map<String, dynamic> _reconstructFromOperations(
    List<serverpod.DocumentCrdtOperation> operations, {
    Map<String, dynamic> initialState = const {},
  }) {
    Map<String, dynamic> flatState = _flattenMap(initialState);

    for (var op in operations) {
      if (op.operationType == serverpod.CrdtOperationType.put &&
          op.fieldValue != null) {
        _applyPutToFlatState(
          flatState,
          op.fieldPath,
          jsonDecode(op.fieldValue!),
        );
      } else if (op.operationType == serverpod.CrdtOperationType.delete) {
        flatState.remove(op.fieldPath);
        flatState.removeWhere((k, _) => k.startsWith('${op.fieldPath}.'));
      }
    }

    return _unflattenMap(flatState);
  }

  /// Helper to parse string status to DocumentVersionStatus enum
  serverpod.DocumentVersionStatus _parseDocumentVersionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return serverpod.DocumentVersionStatus.draft;
      case 'published':
        return serverpod.DocumentVersionStatus.published;
      case 'scheduled':
        return serverpod.DocumentVersionStatus.scheduled;
      case 'archived':
        return serverpod.DocumentVersionStatus.archived;
      default:
        return serverpod.DocumentVersionStatus.draft;
    }
  }

  // ============================================================
  // CRDT Collaboration Operations (NEW)
  // ============================================================

  @override
  Future<DeskDocument> updateDocumentData(
    String documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  }) async {
    try {
      final response = await _client.document.updateDocumentData(
        UuidValue.fromString(documentId),
        _encodeData(updates),
        sessionId: sessionId,
      );
      return _toDeskDocument(response);
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to update document data', e, st);
    } catch (e, st) {
      _throw('Failed to update document data', e, st);
    }
  }

  /// Get CRDT operations since a specific HLC timestamp
  /// Used for polling updates from other users
  Future<List<serverpod.DocumentCrdtOperation>> getOperationsSince(
    String documentId,
    String sinceHlc, {
    int limit = 100,
  }) async {
    try {
      return await _client.documentCollaboration.getOperationsSince(
        UuidValue.fromString(documentId),
        sinceHlc,
        limit: limit,
      );
    } catch (e, st) {
      _throw('Failed to get operations', e, st);
    }
  }

  /// Submit an edit (partial field updates) for collaborative editing
  Future<DeskDocument> submitEdit(
    String documentId,
    String sessionId,
    Map<String, dynamic> fieldUpdates,
  ) async {
    try {
      final response = await _client.documentCollaboration.submitEdit(
        UuidValue.fromString(documentId),
        sessionId,
        _encodeData(fieldUpdates),
      );
      return _toDeskDocument(response);
    } on serverpod.ServerpodClientException catch (e, st) {
      if (e.statusCode == 401) {
        throw const DeskAuthenticationException();
      }
      _throw('Failed to submit edit', e, st);
    } catch (e, st) {
      _throw('Failed to submit edit', e, st);
    }
  }

  /// Get list of users currently editing this document
  Future<List<Map<String, dynamic>>> getActiveEditors(String documentId) async {
    try {
      final response = await _client.documentCollaboration.getActiveEditors(
        UuidValue.fromString(documentId),
      );
      return response
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
    } catch (e, st) {
      _throw('Failed to get active editors', e, st);
    }
  }

  /// Get the current HLC for a document
  Future<String?> getCurrentHlc(String documentId) async {
    try {
      return await _client.documentCollaboration.getCurrentHlc(UuidValue.fromString(documentId));
    } catch (e, st) {
      _throw('Failed to get current HLC', e, st);
    }
  }

  /// Get operation count for a document
  Future<int> getOperationCount(String documentId) async {
    try {
      return await _client.documentCollaboration.getOperationCount(UuidValue.fromString(documentId));
    } catch (e, st) {
      _throw('Failed to get operation count', e, st);
    }
  }

  // ============================================================
  // CRDT Helpers (Internal)
  // ============================================================

  /// Apply a put operation to flat state with parent/child conflict resolution.
  ///
  /// Invariants:
  /// - Setting K = null removes all K.* sub-keys (null overrides a prior sub-map).
  /// - Setting K.X = val removes any K = null ancestor (sub-key overrides a prior null).
  void _applyPutToFlatState(
    Map<String, dynamic> flatState,
    String fieldPath,
    dynamic value,
  ) {
    if (value == null) {
      flatState.removeWhere((k, _) => k.startsWith('$fieldPath.'));
    } else {
      var path = fieldPath;
      while (path.contains('.')) {
        path = path.substring(0, path.lastIndexOf('.'));
        if (flatState.containsKey(path) && flatState[path] == null) {
          flatState.remove(path);
        }
      }
    }
    flatState[fieldPath] = value;
  }

  /// Flatten nested map to dot-notation
  /// Example: {"user": {"name": "John"}} -> {"user.name": "John"}
  Map<String, dynamic> _flattenMap(
    Map<String, dynamic> map, [
    String prefix = '',
  ]) {
    final result = <String, dynamic>{};

    for (var entry in map.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';

      if (entry.value is Map<String, dynamic>) {
        result.addAll(_flattenMap(entry.value as Map<String, dynamic>, key));
      } else {
        result[key] = entry.value;
      }
    }

    return result;
  }

  /// Unflatten dot-notation to nested map
  /// Example: {"user.name": "John"} -> {"user": {"name": "John"}}
  Map<String, dynamic> _unflattenMap(Map<String, dynamic> flat) {
    final result = <String, dynamic>{};

    for (var entry in flat.entries) {
      final keys = entry.key.split('.');
      dynamic current = result;

      for (var i = 0; i < keys.length - 1; i++) {
        if (current is! Map<String, dynamic>) {
          break;
        }
        current[keys[i]] ??= <String, dynamic>{};
        current = current[keys[i]];
      }

      if (current is Map<String, dynamic>) {
        current[keys.last] = entry.value;
      }
    }

    return result;
  }
}
