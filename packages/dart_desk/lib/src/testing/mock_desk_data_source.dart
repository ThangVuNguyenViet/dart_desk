import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:image/image.dart' as img;

import '../data/desk_data_source.dart';
import '../data/models/document_list.dart';
import '../data/models/document_version.dart';
import '../data/models/image_types.dart';
import '../data/models/media_asset.dart';
import '../data/models/media_page.dart';

// ---------------------------------------------------------------------------
// Default seed data (inlined — no dependency on test_document_types.dart)
// ---------------------------------------------------------------------------

const _kDefaultDocumentSeedData = [
  {
    'title': 'Test Document Alpha',
    'slug': 'test-document-alpha',
    'data': {
      'string_field': 'Hello World',
      'text_field': 'This is a multi-line\ntext field value.',
      'number_field': 42,
      'boolean_field': true,
      'checkbox_field': false,
      'url_field': 'https://example.com',
      'date_field': '2026-03-01',
      'datetime_field': '2026-03-01T10:30:00',
      'color_field': '#FF5733',
      'image_field': {'_type': 'imageReference', 'assetId': 'asset-hero'},
      'file_field': null,
      'dropdown_field': 'option_a',
      'document_ref_dropdown': <String>[],
      'array_field': ['Item 1', 'Item 2', 'Item 3'],
      'object_field': {
        'nested_title': 'Nested Value',
        'nested_count': 10,
        'nested_tag': 'alpha',
        'nested_notes': 'Some notes',
      },
      'block_field': null,
      'geopoint_field': {'lat': 37.7749, 'lng': -122.4194},
    },
  },
  {
    'title': 'Test Document Beta',
    'slug': 'test-document-beta',
    'data': {
      'string_field': 'Second Document',
      'text_field': 'Beta text content.',
      'number_field': 100,
      'boolean_field': false,
      'checkbox_field': true,
      'url_field': 'https://flutter.dev',
      'date_field': '2026-01-15',
      'datetime_field': '2026-01-15T14:00:00',
      'color_field': '#2196F3',
      'image_field': null,
      'file_field': null,
      'dropdown_field': 'option_b',
      'document_ref_dropdown': <String>[],
      'array_field': ['Alpha', 'Beta'],
      'object_field': {
        'nested_title': 'Beta Nested',
        'nested_count': 5,
        'nested_tag': 'beta',
        'nested_notes': '',
      },
      'block_field': null,
      'geopoint_field': {'lat': 40.7128, 'lng': -74.0060},
    },
  },
  {
    'title': 'Test Document Gamma',
    'slug': 'test-document-gamma',
    'data': {
      'string_field': 'Third Document',
      'text_field': 'Gamma text.',
      'number_field': 0,
      'boolean_field': true,
      'checkbox_field': true,
      'url_field': '',
      'date_field': null,
      'datetime_field': null,
      'color_field': '#4CAF50',
      'image_field': {'_type': 'imageReference', 'assetId': 'asset-landscape'},
      'file_field': null,
      'dropdown_field': null,
      'document_ref_dropdown': <String>[],
      'array_field': <String>[],
      'object_field': {
        'nested_title': '',
        'nested_count': 0,
        'nested_tag': '',
        'nested_notes': null,
      },
      'block_field': null,
      'geopoint_field': null,
    },
  },
];

/// In-memory mock implementation of [DataSource] for testing.
///
/// Constructed empty by default. Call [seedDefaults] to populate with 3
/// standard test documents and 4 media assets (the pre-Phase-4 behaviour).
///
/// All operations are synchronous in-memory. No network calls.
class MockDataSource implements DataSource {
  final Map<String, DeskDocument> _documents = {};
  final Map<String, Map<String, DocumentVersion>> _versions = {};
  final Map<String, Map<String, dynamic>> _versionData = {};
  final Map<String, MediaAsset> _media = {};
  int _nextDocId = 1;
  int _nextVersionId = 1;
  int _nextMediaId = 1;

  /// Constructs an empty [MockDataSource].
  ///
  /// Call [seedDefaults] to pre-populate with the standard test fixture data,
  /// or use [createDocument] / [uploadImage] to add data incrementally.
  MockDataSource();

  String _genDocId() => 'doc-${_nextDocId++}';
  String _genVersionId() => 'ver-${_nextVersionId++}';
  String _genMediaId() => 'media-${_nextMediaId++}';

  /// Seeds the store with 3 standard test documents of type `test_all_fields`
  /// and 4 media assets.
  ///
  /// This reproduces the legacy auto-seed behaviour. Useful in [setUp] blocks
  /// that need a pre-populated store:
  /// ```dart
  /// setUp(() { dataSource = MockDataSource()..seedDefaults(); });
  /// ```
  void seedDefaults() {
    for (final seed in _kDefaultDocumentSeedData) {
      final docId = _genDocId();
      final versionId = _genVersionId();
      final now = DateTime.now();

      _documents[docId] = DeskDocument(
        id: docId,
        clientId: 'mock-client-1',
        documentType: 'test_all_fields',
        title: seed['title'] as String,
        slug: seed['slug'] as String,
        isDefault: _nextDocId == 2, // first doc
        activeVersionData: seed['data'] as Map<String, dynamic>,
        createdAt: now,
        updatedAt: now,
      );

      _versions[docId] = {
        versionId: DocumentVersion(
          id: versionId,
          documentId: docId,
          versionNumber: 1,
          status: _nextDocId == 2
              ? DocumentVersionStatus.published
              : DocumentVersionStatus.draft,
          changeLog: 'Initial version',
          createdAt: now,
          publishedAt: _nextDocId == 2 ? now : null,
        ),
      };

      _versionData[versionId] = Map<String, dynamic>.from(
        seed['data'] as Map<String, dynamic>,
      );
    }

    // Add a second version to first document (draft on top of published)
    final firstDocId = _documents.keys.first;
    final secondVersionId = _genVersionId();
    _versions[firstDocId]![secondVersionId] = DocumentVersion(
      id: secondVersionId,
      documentId: firstDocId,
      versionNumber: 2,
      status: DocumentVersionStatus.draft,
      changeLog: 'Updated string field',
      createdAt: DateTime.now(),
    );
    _versionData[secondVersionId] = {
      ..._kDefaultDocumentSeedData[0]['data'] as Map<String, dynamic>,
      'string_field': 'Hello World (v2)',
    };

    // Seed media assets for testing
    _media['asset-hero'] = MediaAsset(
      id: _genMediaId(),
      assetId: 'asset-hero',
      fileName: 'hero-banner.jpg',
      mimeType: 'image/jpeg',
      fileSize: 245000,
      publicUrl: 'https://picsum.photos/seed/hero/800/400',
      width: 800,
      height: 400,
      hasAlpha: false,
      blurHash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
      createdAt: DateTime(2026, 3, 1),
      metadataStatus: MediaAssetMetadataStatus.complete,
    );
    _media['asset-profile'] = MediaAsset(
      id: _genMediaId(),
      assetId: 'asset-profile',
      fileName: 'profile-photo.png',
      mimeType: 'image/png',
      fileSize: 128000,
      publicUrl: 'https://picsum.photos/seed/profile/400/400',
      width: 400,
      height: 400,
      hasAlpha: true,
      blurHash: 'LGF5]+Yk^6#M@-5c,1J5@[or[Q6.',
      createdAt: DateTime(2026, 3, 5),
      metadataStatus: MediaAssetMetadataStatus.complete,
    );
    _media['asset-landscape'] = MediaAsset(
      id: _genMediaId(),
      assetId: 'asset-landscape',
      fileName: 'mountain-landscape.jpg',
      mimeType: 'image/jpeg',
      fileSize: 512000,
      publicUrl: 'https://picsum.photos/seed/landscape/1200/800',
      width: 1200,
      height: 800,
      hasAlpha: false,
      blurHash: 'LdKBt%j[WBay~qj[j[j[WBayfQfQ',
      createdAt: DateTime(2026, 3, 10),
      metadataStatus: MediaAssetMetadataStatus.complete,
    );
    _media['asset-icon'] = MediaAsset(
      id: _genMediaId(),
      assetId: 'asset-icon',
      fileName: 'app-icon.png',
      mimeType: 'image/png',
      fileSize: 24000,
      publicUrl: 'https://picsum.photos/seed/icon/128/128',
      width: 128,
      height: 128,
      hasAlpha: true,
      blurHash: 'L6PZfSi_.AyE_3t7t7R**0o#DgR4',
      createdAt: DateTime(2026, 3, 15),
      metadataStatus: MediaAssetMetadataStatus.complete,
    );
  }

  /// Clears all data and re-seeds with default fixture data.
  ///
  /// Equivalent to constructing a fresh `MockDataSource()..seedDefaults()`.
  void reset() {
    _documents.clear();
    _versions.clear();
    _versionData.clear();
    _media.clear();
    _nextDocId = 1;
    _nextVersionId = 1;
    _nextMediaId = 1;
    seedDefaults();
  }

  @override
  Future<DocumentList> getDocuments(
    String documentType, {
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    var docs = _documents.values
        .where((d) => d.documentType == documentType)
        .toList();

    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      docs = docs.where((d) => d.title.toLowerCase().contains(query)).toList();
    }

    final total = docs.length;
    final paged = docs.skip(offset).take(limit).toList();

    return DocumentList(
      documents: paged,
      total: total,
      page: (offset ~/ limit) + 1,
      pageSize: limit,
    );
  }

  /// Test helper: forcibly sets crdtHlc on a document without going through
  /// the full updateDocumentData path. Useful when that method is overridden
  /// in a subclass (e.g. _HangingDataSource) to simulate in-flight requests.
  void forceSetCrdtHlc(String documentId, String hlc) {
    final doc = _documents[documentId];
    if (doc != null) {
      _documents[documentId] = doc.copyWith(crdtHlc: hlc);
    }
  }

  @override
  Future<DeskDocument?> getDocument(String documentId) async {
    return _documents[documentId];
  }

  @override
  Future<DeskDocument> createDocument(
    String documentType,
    String title,
    Map<String, dynamic> data, {
    String? slug,
    bool isDefault = false,
  }) async {
    final docId = _genDocId();
    final versionId = _genVersionId();
    final now = DateTime.now();

    // Determine effective isDefault: auto-assign if this is the first doc for this type
    final isFirstForType = !_documents.values.any(
      (d) => d.documentType == documentType,
    );
    final effectiveIsDefault = isDefault || isFirstForType;

    final doc = DeskDocument(
      id: docId,
      clientId: 'mock-client-1',
      documentType: documentType,
      title: title,
      slug: slug ?? _generateSlug(title),
      isDefault: effectiveIsDefault,
      activeVersionData: data,
      createdAt: now,
      updatedAt: now,
    );

    _documents[docId] = doc;
    _versions[docId] = {
      versionId: DocumentVersion(
        id: versionId,
        documentId: docId,
        versionNumber: 1,
        status: DocumentVersionStatus.draft,
        changeLog: 'Initial version',
        createdAt: now,
      ),
    };
    _versionData[versionId] = Map<String, dynamic>.from(data);

    return doc;
  }

  @override
  Future<DeskDocument?> updateDocument(
    String documentId, {
    String? title,
    String? slug,
    bool? isDefault,
  }) async {
    final doc = _documents[documentId];
    if (doc == null) return null;

    _documents[documentId] = doc.copyWith(
      title: title ?? doc.title,
      slug: slug ?? doc.slug,
      isDefault: isDefault ?? doc.isDefault,
      updatedAt: DateTime.now(),
    );

    return _documents[documentId];
  }

  @override
  Future<DeskDocument> setDefaultDocument(
    String documentTypeSlug,
    String documentId,
  ) async {
    // Unset any existing default for this type
    final currentDefault = _documents.values.firstWhereOrNull(
      (d) => d.documentType == documentTypeSlug && d.isDefault,
    );
    if (currentDefault?.id != null) {
      _documents[currentDefault!.id!] = currentDefault.copyWith(
        isDefault: false,
      );
    }

    // Set new default
    final doc = _documents[documentId];
    if (doc == null) {
      throw DeskNotFoundException(
        resourceType: 'Document',
        resourceId: documentId,
      );
    }
    final updated = doc.copyWith(isDefault: true);
    _documents[documentId] = updated;
    return updated;
  }

  @override
  Future<bool> deleteDocument(String documentId) async {
    final doc = _documents[documentId];
    if (doc == null) return false;

    final wasDefault = doc.isDefault;
    final docType = doc.documentType;

    // Remove document and all its versions
    final versionIds = _versions.remove(documentId)?.keys.toList() ?? [];
    for (final vid in versionIds) {
      _versionData.remove(vid);
    }
    _documents.remove(documentId);

    // Auto-assign default to the sole remaining document if needed
    if (wasDefault) {
      final remaining = _documents.values
          .where((d) => d.documentType == docType)
          .toList();
      if (remaining.length == 1) {
        final newDefault = remaining.first;
        _documents[newDefault.id!] = newDefault.copyWith(isDefault: true);
      }
    }

    return true;
  }

  @override
  Future<String> suggestSlug(String title, String documentType) async {
    return _generateSlug(title);
  }

  @override
  Future<List<String>> getDocumentTypes() async {
    return _documents.values.map((d) => d.documentType).toSet().toList();
  }

  @override
  Future<DocumentVersionList> getDocumentVersions(
    String documentId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final versions = (_versions[documentId]?.values ?? []).toList()
      ..sort((a, b) => a.versionNumber.compareTo(b.versionNumber));

    return DocumentVersionList(
      versions: versions.skip(offset).take(limit).toList(),
      total: versions.length,
      page: (offset ~/ limit) + 1,
      pageSize: limit,
    );
  }

  @override
  Future<DocumentVersion?> getDocumentVersion(String versionId) async {
    for (final docVersions in _versions.values) {
      if (docVersions.containsKey(versionId)) {
        return docVersions[versionId];
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getDocumentVersionData(String versionId) async {
    return _versionData[versionId];
  }

  @override
  Future<DocumentVersion> createDocumentVersion(
    String documentId, {
    String status = 'draft',
    String? changeLog,
  }) async {
    final versionId = _genVersionId();
    final existingVersions = _versions[documentId]?.values ?? [];
    final maxVersion = existingVersions.isEmpty
        ? 0
        : existingVersions
              .map((v) => v.versionNumber)
              .reduce((a, b) => a > b ? a : b);

    final parsedStatus = DocumentVersionStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => DocumentVersionStatus.draft,
    );

    final version = DocumentVersion(
      id: versionId,
      documentId: documentId,
      versionNumber: maxVersion + 1,
      status: parsedStatus,
      changeLog: changeLog,
      createdAt: DateTime.now(),
    );

    _versions.putIfAbsent(documentId, () => {});
    _versions[documentId]![versionId] = version;
    _versionData[versionId] = {};

    return version;
  }

  @override
  Future<DeskDocument> updateDocumentData(
    String documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  }) async {
    final docVersions = _versions[documentId]?.values.toList() ?? [];
    docVersions.sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
    if (docVersions.isNotEmpty) {
      final latestVersionId = docVersions.first.id!;
      final existingData = _versionData[latestVersionId] ?? {};
      existingData.addAll(updates);
      _versionData[latestVersionId] = existingData;
    }

    final doc = _documents[documentId]!;
    final updatedData = Map<String, dynamic>.from(doc.activeVersionData ?? {});
    updatedData.addAll(updates);
    // Advance crdtHlc so hasUnpublishedChanges can detect unsaved changes.
    final hlc = DateTime.now().microsecondsSinceEpoch.toString();
    _documents[documentId] = doc.copyWith(
      activeVersionData: updatedData,
      updatedAt: DateTime.now(),
      crdtHlc: hlc,
    );

    return _documents[documentId]!;
  }

  @override
  Future<DocumentVersion?> publishDocumentVersion(String versionId) async {
    return _updateVersionStatus(versionId, DocumentVersionStatus.published);
  }

  @override
  Future<DocumentVersion?> archiveDocumentVersion(String versionId) async {
    return _updateVersionStatus(versionId, DocumentVersionStatus.archived);
  }

  @override
  Future<bool> deleteDocumentVersion(String versionId) async {
    for (final docVersions in _versions.values) {
      if (docVersions.containsKey(versionId)) {
        docVersions.remove(versionId);
        _versionData.remove(versionId);
        return true;
      }
    }
    return false;
  }

  @override
  Future<DocumentVersion> publishCurrentVersion(String documentId) async {
    // Create a new version snapshot and immediately publish it.
    final version = await createDocumentVersion(documentId);
    final published = await publishDocumentVersion(version.id!);
    // Stamp snapshotHlc so hasUnpublishedChanges can detect the publish boundary.
    final doc = _documents[documentId];
    final hlc = doc?.crdtHlc ?? DateTime.now().microsecondsSinceEpoch.toString();
    for (final docVersions in _versions.values) {
      if (docVersions.containsKey(published!.id)) {
        docVersions[published.id!] = published.copyWith(snapshotHlc: hlc);
        return docVersions[published.id!]!;
      }
    }
    return published!;
  }

  @override
  Future<DeskDocument> restoreDocumentVersion(
    String documentId,
    String versionId,
  ) async {
    throw UnimplementedError(
      'restoreDocumentVersion not implemented in MockDeskDataSource',
    );
  }

  @override
  Future<MediaAsset> uploadImage(String fileName, Uint8List fileData) async {
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'bin';
    final contentHash = sha256.convert(fileData).toString();

    // Try to decode for dimensions; fall back to zeros for non-images.
    int width = 0;
    int height = 0;
    bool hasAlpha = false;
    try {
      final decoded = img.decodeImage(fileData);
      if (decoded != null) {
        width = decoded.width;
        height = decoded.height;
        hasAlpha = decoded.hasAlpha;
      }
    } catch (_) {
      // ignore
    }

    final assetId = 'image-$contentHash-${width}x$height-$ext';
    if (_media.containsKey(assetId)) return _media[assetId]!;

    final mimeType = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'svg' => 'image/svg+xml',
      _ => 'image/$ext',
    };

    final id = _genMediaId();
    final asset = MediaAsset(
      id: id,
      assetId: assetId,
      fileName: fileName,
      mimeType: mimeType,
      fileSize: fileData.length,
      publicUrl: 'https://mock-cdn.test/media/$assetId/$fileName',
      width: width,
      height: height,
      hasAlpha: hasAlpha,
      blurHash: 'L00000fQfQfQfQfQfQfQfQfQfQ', // placeholder
      createdAt: DateTime.now(),
      metadataStatus: MediaAssetMetadataStatus.complete,
    );
    _media[assetId] = asset;
    return asset;
  }

  @override
  Future<MediaAsset> uploadFile(String fileName, Uint8List fileData) async {
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'bin';
    final hash = fileData.length.toRadixString(16); // simple mock hash
    final assetId = 'file-$hash-$ext';

    if (_media.containsKey(assetId)) {
      return _media[assetId]!;
    }

    final mimeType = switch (ext) {
      'pdf' => 'application/pdf',
      'doc' => 'application/msword',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'txt' => 'text/plain',
      'csv' => 'text/csv',
      'xlsx' =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      _ => 'application/octet-stream',
    };

    final id = _genMediaId();
    final asset = MediaAsset(
      id: id,
      assetId: assetId,
      fileName: fileName,
      mimeType: mimeType,
      fileSize: fileData.length,
      publicUrl: 'https://mock-cdn.test/media/$assetId/$fileName',
      width: 0,
      height: 0,
      hasAlpha: false,
      blurHash: '',
      createdAt: DateTime.now(),
      metadataStatus: MediaAssetMetadataStatus.complete,
    );
    _media[assetId] = asset;
    return asset;
  }

  @override
  Future<bool> deleteMedia(String assetId) async {
    final usageCount = await getMediaUsageCount(assetId);
    if (usageCount > 0) {
      throw const DeskValidationException(
        'Cannot delete media asset that is still referenced by documents',
      );
    }
    return _media.remove(assetId) != null;
  }

  @override
  Future<MediaAsset?> getMediaAsset(String assetId) async {
    return _media[assetId];
  }

  @override
  Future<MediaPage> listMedia({
    String? search,
    MediaTypeFilter? type,
    MediaSort sort = MediaSort.dateDesc,
    int limit = 50,
    int offset = 0,
  }) async {
    var items = _media.values.toList();

    // Filter by search
    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      items = items
          .where((a) => a.fileName.toLowerCase().contains(query))
          .toList();
    }

    // Filter by type
    if (type != null && type != MediaTypeFilter.all) {
      items = items.where((a) {
        return switch (type) {
          MediaTypeFilter.image => a.mimeType.startsWith('image/'),
          MediaTypeFilter.video => a.mimeType.startsWith('video/'),
          MediaTypeFilter.file =>
            !a.mimeType.startsWith('image/') &&
                !a.mimeType.startsWith('video/'),
          MediaTypeFilter.all => true,
        };
      }).toList();
    }

    // Sort
    items.sort((a, b) {
      return switch (sort) {
        MediaSort.dateDesc => b.createdAt.compareTo(a.createdAt),
        MediaSort.dateAsc => a.createdAt.compareTo(b.createdAt),
        MediaSort.nameAsc => a.fileName.toLowerCase().compareTo(
          b.fileName.toLowerCase(),
        ),
        MediaSort.nameDesc => b.fileName.toLowerCase().compareTo(
          a.fileName.toLowerCase(),
        ),
        MediaSort.sizeDesc => b.fileSize.compareTo(a.fileSize),
        MediaSort.sizeAsc => a.fileSize.compareTo(b.fileSize),
      };
    });

    final total = items.length;
    final paged = items.skip(offset).take(limit).toList();
    return MediaPage(items: paged, total: total);
  }

  @override
  Future<MediaAsset> updateMediaAsset(
    String assetId, {
    String? fileName,
  }) async {
    final existing = _media[assetId];
    if (existing == null) {
      throw DeskNotFoundException(
        resourceType: 'MediaAsset',
        resourceId: assetId,
      );
    }

    if (fileName != null) {
      final json = existing.toJson();
      json['fileName'] = fileName;
      final updated = MediaAsset.fromJson(json);
      _media[assetId] = updated;
      return updated;
    }
    return existing;
  }

  @override
  Future<int> getMediaUsageCount(String assetId) async {
    int count = 0;
    for (final doc in _documents.values) {
      final data = doc.activeVersionData;
      if (data != null) {
        final jsonStr = jsonEncode(data);
        if (jsonStr.contains(assetId)) {
          count++;
        }
      }
    }
    return count;
  }

  String _generateSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  DocumentVersion? _updateVersionStatus(
    String versionId,
    DocumentVersionStatus status,
  ) {
    for (final docVersions in _versions.values) {
      if (docVersions.containsKey(versionId)) {
        final version = docVersions[versionId]!;
        final updated = DocumentVersion(
          id: version.id,
          documentId: version.documentId,
          versionNumber: version.versionNumber,
          status: status,
          changeLog: version.changeLog,
          createdAt: version.createdAt,
          publishedAt: status == DocumentVersionStatus.published
              ? DateTime.now()
              : version.publishedAt,
          archivedAt: status == DocumentVersionStatus.archived
              ? DateTime.now()
              : version.archivedAt,
        );
        docVersions[versionId] = updated;
        return updated;
      }
    }
    return null;
  }
}
