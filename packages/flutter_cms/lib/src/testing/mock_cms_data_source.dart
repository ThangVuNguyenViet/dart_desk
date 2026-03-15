import 'dart:typed_data';

import '../data/cms_data_source.dart';
import '../data/models/cms_document.dart';
import '../data/models/document_list.dart';
import '../data/models/document_version.dart';
import '../data/models/media_file.dart';
import '../data/models/media_upload_result.dart';
import 'test_document_types.dart';

/// In-memory mock implementation of [CmsDataSource] for testing.
///
/// Pre-seeded with 3 documents from [testDocumentSeedData].
/// All operations are synchronous in-memory. No network calls.
class MockCmsDataSource implements CmsDataSource {
  final Map<int, CmsDocument> _documents = {};
  final Map<int, Map<int, DocumentVersion>> _versions = {};
  final Map<int, Map<String, dynamic>> _versionData = {};
  final Map<int, MediaFile> _media = {};
  int _nextDocId = 1;
  int _nextVersionId = 1;
  int _nextMediaId = 1;

  MockCmsDataSource() {
    _seed();
  }

  void _seed() {
    for (final seed in testDocumentSeedData) {
      final docId = _nextDocId++;
      final versionId = _nextVersionId++;
      final now = DateTime.now();

      _documents[docId] = CmsDocument(
        id: docId,
        clientId: 1,
        documentType: 'test_all_fields',
        title: seed['title'] as String,
        slug: seed['slug'] as String,
        isDefault: docId == 1,
        activeVersionData: seed['data'] as Map<String, dynamic>,
        createdAt: now,
        updatedAt: now,
      );

      _versions[docId] = {
        versionId: DocumentVersion(
          id: versionId,
          documentId: docId,
          versionNumber: 1,
          status: docId == 1
              ? DocumentVersionStatus.published
              : DocumentVersionStatus.draft,
          changeLog: 'Initial version',
          createdAt: now,
          publishedAt: docId == 1 ? now : null,
        ),
      };

      _versionData[versionId] = Map<String, dynamic>.from(
        seed['data'] as Map<String, dynamic>,
      );
    }

    // Add a second version to document 1 (draft on top of published)
    final secondVersionId = _nextVersionId++;
    _versions[1]![secondVersionId] = DocumentVersion(
      id: secondVersionId,
      documentId: 1,
      versionNumber: 2,
      status: DocumentVersionStatus.draft,
      changeLog: 'Updated string field',
      createdAt: DateTime.now(),
    );
    _versionData[secondVersionId] = {
      ...testDocumentSeedData[0]['data'] as Map<String, dynamic>,
      'string_field': 'Hello World (v2)',
    };
  }

  /// Reset to initial seed state.
  void reset() {
    _documents.clear();
    _versions.clear();
    _versionData.clear();
    _media.clear();
    _nextDocId = 1;
    _nextVersionId = 1;
    _nextMediaId = 1;
    _seed();
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

  @override
  Future<CmsDocument?> getDocument(int documentId) async {
    return _documents[documentId];
  }

  @override
  Future<CmsDocument> createDocument(
    String documentType,
    String title,
    Map<String, dynamic> data, {
    String? slug,
    bool isDefault = false,
  }) async {
    final docId = _nextDocId++;
    final versionId = _nextVersionId++;
    final now = DateTime.now();

    final doc = CmsDocument(
      id: docId,
      clientId: 1,
      documentType: documentType,
      title: title,
      slug: slug ?? _generateSlug(title),
      isDefault: isDefault,
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
  Future<CmsDocument?> updateDocument(
    int documentId, {
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
  Future<bool> deleteDocument(int documentId) async {
    if (!_documents.containsKey(documentId)) return false;
    _documents.remove(documentId);
    final versionIds = _versions.remove(documentId)?.keys ?? [];
    for (final vid in versionIds) {
      _versionData.remove(vid);
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
    int documentId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final versions = (_versions[documentId]?.values ?? []).toList()
      ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber));

    return DocumentVersionList(
      versions: versions.skip(offset).take(limit).toList(),
      total: versions.length,
      page: (offset ~/ limit) + 1,
      pageSize: limit,
    );
  }

  @override
  Future<DocumentVersion?> getDocumentVersion(int versionId) async {
    for (final docVersions in _versions.values) {
      if (docVersions.containsKey(versionId)) {
        return docVersions[versionId];
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getDocumentVersionData(int versionId) async {
    return _versionData[versionId];
  }

  @override
  Future<DocumentVersion> createDocumentVersion(
    int documentId, {
    String status = 'draft',
    String? changeLog,
  }) async {
    final versionId = _nextVersionId++;
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
  Future<CmsDocument> updateDocumentData(
    int documentId,
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
    _documents[documentId] = doc.copyWith(
      activeVersionData: updatedData,
      updatedAt: DateTime.now(),
    );

    return _documents[documentId]!;
  }

  @override
  Future<DocumentVersion?> publishDocumentVersion(int versionId) async {
    return _updateVersionStatus(versionId, DocumentVersionStatus.published);
  }

  @override
  Future<DocumentVersion?> archiveDocumentVersion(int versionId) async {
    return _updateVersionStatus(versionId, DocumentVersionStatus.archived);
  }

  @override
  Future<bool> deleteDocumentVersion(int versionId) async {
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
  Future<MediaUploadResult> uploadImage(
    String fileName,
    Uint8List fileData,
  ) async {
    return _uploadMedia(fileName, fileData, isImage: true);
  }

  @override
  Future<MediaUploadResult> uploadFile(
    String fileName,
    Uint8List fileData,
  ) async {
    return _uploadMedia(fileName, fileData, isImage: false);
  }

  @override
  Future<bool> deleteMedia(int fileId) async {
    return _media.remove(fileId) != null;
  }

  @override
  Future<MediaFile?> getMedia(int fileId) async {
    return _media[fileId];
  }

  @override
  Future<List<MediaFile>> listMedia({int limit = 50, int offset = 0}) async {
    return _media.values.skip(offset).take(limit).toList();
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
    int versionId,
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

  MediaUploadResult _uploadMedia(
    String fileName,
    Uint8List fileData, {
    required bool isImage,
  }) {
    final id = _nextMediaId++;
    final file = MediaFile(
      id: id,
      fileName: fileName,
      publicUrl: 'https://mock-cdn.test/$fileName',
      fileSize: fileData.length,
      fileType: isImage ? 'png' : 'bin',
      createdAt: DateTime.now(),
    );
    _media[id] = file;
    return MediaUploadResult(
      id: id.toString(),
      url: 'https://mock-cdn.test/$fileName',
      fileName: fileName,
    );
  }
}
