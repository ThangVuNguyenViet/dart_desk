import 'dart:convert';
import 'dart:typed_data';

import '../data/data.dart';
import 'package:dart_desk_be_client/dart_desk_be_client.dart' as serverpod;

/// Cloud data source implementation using the Serverpod dart_desk_be_client.
///
/// This class wraps the Serverpod-generated client and converts between
/// Serverpod models and platform-agnostic CMS data models.
///
/// ## Usage
///
/// ```dart
/// import 'package:dart_desk_be_client/dart_desk_be_client.dart';
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
        documents: response.documents.map(_toCmsDocument).toList(),
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
      );
    } catch (e) {
      throw CmsDataSourceException('Failed to get documents', e);
    }
  }

  @override
  Future<CmsDocument?> getDocument(int documentId) async {
    try {
      final response = await _client.document.getDocument(documentId);
      if (response == null) return null;
      return _toCmsDocument(response);
    } catch (e) {
      throw CmsDataSourceException('Failed to get document', e);
    }
  }

  @override
  Future<CmsDocument> createDocument(
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
        data,
        slug: slug,
        isDefault: isDefault,
      );
      return _toCmsDocument(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to create document', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to create document', e);
    }
  }

  @override
  Future<CmsDocument?> updateDocument(
    int documentId, {
    String? title,
    String? slug,
    bool? isDefault,
  }) async {
    try {
      final response = await _client.document.updateDocument(
        documentId,
        title: title,
        slug: slug,
        isDefault: isDefault,
      );
      if (response == null) return null;
      return _toCmsDocument(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to update document', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to update document', e);
    }
  }

  @override
  Future<bool> deleteDocument(int documentId) async {
    try {
      return await _client.document.deleteDocument(documentId);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to delete document', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to delete document', e);
    }
  }

  @override
  Future<String> suggestSlug(String title, String documentType) async {
    try {
      return await _client.document.suggestSlug(title, documentType);
    } catch (e) {
      throw CmsDataSourceException('Failed to suggest slug', e);
    }
  }

  @override
  Future<List<String>> getDocumentTypes() async {
    try {
      return await _client.document.getDocumentTypes();
    } catch (e) {
      throw CmsDataSourceException('Failed to get document types', e);
    }
  }

  // ============================================================
  // Document Version Operations
  // ============================================================

  @override
  Future<DocumentVersionList> getDocumentVersions(
    int documentId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Always fetch with operations to compute data
      final response = await _client.document.getDocumentVersions(
        documentId,
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

        versions.add(_toDocumentVersionWithData(
          versionWithOps.version,
          accumulatedState,
        ));
      }

      return DocumentVersionList(
        versions: versions,
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
      );
    } catch (e) {
      throw CmsDataSourceException('Failed to get document versions', e);
    }
  }

  @override
  Future<DocumentVersion?> getDocumentVersion(int versionId) async {
    try {
      final response = await _client.document.getDocumentVersion(versionId);
      if (response == null) return null;

      return _toDocumentVersion(response);
    } catch (e) {
      throw CmsDataSourceException('Failed to get document version', e);
    }
  }

  @override
  Future<Map<String, dynamic>?> getDocumentVersionData(int versionId) async {
    try {
      final data = await _client.document.getDocumentVersionData(versionId);
      return data;
    } catch (e) {
      throw CmsDataSourceException('Failed to get document version data', e);
    }
  }

  @override
  Future<DocumentVersion> createDocumentVersion(
    int documentId, {
    String status = 'draft',
    String? changeLog,
  }) async {
    try {
      // Convert string status to enum
      final enumStatus = _parseDocumentVersionStatus(status);

      final response = await _client.document.createDocumentVersion(
        documentId,
        status: enumStatus,
        changeLog: changeLog,
      );
      return _toDocumentVersion(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to create document version', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to create document version', e);
    }
  }

  @override
  Future<DocumentVersion?> publishDocumentVersion(int versionId) async {
    try {
      final response = await _client.document.publishDocumentVersion(versionId);
      if (response == null) return null;
      return _toDocumentVersion(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to publish document version', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to publish document version', e);
    }
  }

  @override
  Future<DocumentVersion?> archiveDocumentVersion(int versionId) async {
    try {
      final response = await _client.document.archiveDocumentVersion(versionId);
      if (response == null) return null;
      return _toDocumentVersion(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to archive document version', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to archive document version', e);
    }
  }

  @override
  Future<bool> deleteDocumentVersion(int versionId) async {
    try {
      return await _client.document.deleteDocumentVersion(versionId);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to delete document version', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to delete document version', e);
    }
  }

  // ============================================================
  // Media Operations
  // ============================================================

  @override
  Future<MediaAsset> uploadImage(
    String fileName,
    Uint8List fileData,
    QuickImageMetadata metadata,
  ) async {
    try {
      final byteData = ByteData.view(fileData.buffer);
      final response = await _client.media.uploadImage(
        fileName,
        byteData,
        metadata.width,
        metadata.height,
        metadata.hasAlpha,
        metadata.blurHash,
        metadata.contentHash,
      );
      return _toMediaAsset(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to upload image', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to upload image', e);
    }
  }

  @override
  Future<MediaAsset> uploadFile(String fileName, Uint8List fileData) async {
    try {
      final byteData = ByteData.view(fileData.buffer);
      final response = await _client.media.uploadFile(fileName, byteData);
      return _toMediaAsset(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to upload file', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to upload file', e);
    }
  }

  @override
  Future<bool> deleteMedia(String assetId) async {
    try {
      return await _client.media.deleteMedia(assetId);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to delete media', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to delete media', e);
    }
  }

  @override
  Future<MediaAsset?> getMediaAsset(String assetId) async {
    try {
      final response = await _client.media.getMedia(assetId);
      if (response == null) return null;
      return _toMediaAsset(response);
    } catch (e) {
      throw CmsDataSourceException('Failed to get media asset', e);
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
    } catch (e) {
      throw CmsDataSourceException('Failed to list media', e);
    }
  }

  @override
  Future<MediaAsset> updateMediaAsset(String assetId,
      {String? fileName}) async {
    try {
      final response = await _client.media.updateMediaAsset(
        assetId,
        fileName: fileName,
      );
      return _toMediaAsset(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to update media asset', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to update media asset', e);
    }
  }

  @override
  Future<int> getMediaUsageCount(String assetId) async {
    try {
      return await _client.media.getMediaUsageCount(assetId);
    } catch (e) {
      throw CmsDataSourceException('Failed to get media usage count', e);
    }
  }

  // ============================================================
  // Conversion Helpers
  // ============================================================

  /// Converts a Serverpod Document to a platform-agnostic CmsDocument.
  CmsDocument _toCmsDocument(serverpod.Document doc) {
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

    return CmsDocument(
      id: doc.id,
      clientId: doc.clientId ?? 0,
      documentType: doc.documentType,
      title: doc.title,
      slug: doc.slug,
      isDefault: doc.isDefault,
      activeVersionData:
          parsedData, // Frontend still uses activeVersionData name
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
      createdByUserId: doc.createdByUserId,
      updatedByUserId: doc.updatedByUserId,
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
      id: asset.id ?? 0,
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
      uploadedByUserId: asset.uploadedByUserId,
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
      id: version.id,
      documentId: version.documentId,
      versionNumber: version.versionNumber,
      status: DocumentVersionStatus.fromString(version.status.name),
      changeLog: version.changeLog,
      publishedAt: version.publishedAt,
      scheduledAt: version.scheduledAt,
      archivedAt: version.archivedAt,
      createdAt: version.createdAt,
      createdByUserId: version.createdByUserId,
    );
  }

  /// Converts a Serverpod DocumentVersion to platform-agnostic with computed data.
  DocumentVersion _toDocumentVersionWithData(
    serverpod.DocumentVersion version,
    Map<String, dynamic> data,
  ) {
    return DocumentVersion(
      id: version.id,
      documentId: version.documentId,
      versionNumber: version.versionNumber,
      status: DocumentVersionStatus.fromString(version.status.name),
      data: Map<String, dynamic>.from(data), // Copy to avoid mutation
      changeLog: version.changeLog,
      publishedAt: version.publishedAt,
      scheduledAt: version.scheduledAt,
      archivedAt: version.archivedAt,
      createdAt: version.createdAt,
      createdByUserId: version.createdByUserId,
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
        flatState[op.fieldPath] = jsonDecode(op.fieldValue!);
      } else if (op.operationType == serverpod.CrdtOperationType.delete) {
        flatState.remove(op.fieldPath);
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
  Future<CmsDocument> updateDocumentData(
    int documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  }) async {
    try {
      final response = await _client.document.updateDocumentData(
        documentId,
        updates,
        sessionId: sessionId,
      );
      return _toCmsDocument(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to update document data', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to update document data', e);
    }
  }

  /// Get CRDT operations since a specific HLC timestamp
  /// Used for polling updates from other users
  Future<List<serverpod.DocumentCrdtOperation>> getOperationsSince(
    int documentId,
    String sinceHlc, {
    int limit = 100,
  }) async {
    try {
      return await _client.documentCollaboration.getOperationsSince(
        documentId,
        sinceHlc,
        limit: limit,
      );
    } catch (e) {
      throw CmsDataSourceException('Failed to get operations', e);
    }
  }

  /// Submit an edit (partial field updates) for collaborative editing
  Future<CmsDocument> submitEdit(
    int documentId,
    String sessionId,
    Map<String, dynamic> fieldUpdates,
  ) async {
    try {
      final response = await _client.documentCollaboration.submitEdit(
        documentId,
        sessionId,
        fieldUpdates,
      );
      return _toCmsDocument(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to submit edit', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to submit edit', e);
    }
  }

  /// Get list of users currently editing this document
  Future<List<Map<String, dynamic>>> getActiveEditors(int documentId) async {
    try {
      return await _client.documentCollaboration.getActiveEditors(documentId);
    } catch (e) {
      throw CmsDataSourceException('Failed to get active editors', e);
    }
  }

  /// Get the current HLC for a document
  Future<String?> getCurrentHlc(int documentId) async {
    try {
      return await _client.documentCollaboration.getCurrentHlc(documentId);
    } catch (e) {
      throw CmsDataSourceException('Failed to get current HLC', e);
    }
  }

  /// Get operation count for a document
  Future<int> getOperationCount(int documentId) async {
    try {
      return await _client.documentCollaboration.getOperationCount(documentId);
    } catch (e) {
      throw CmsDataSourceException('Failed to get operation count', e);
    }
  }

  // ============================================================
  // CRDT Helpers (Internal)
  // ============================================================

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
