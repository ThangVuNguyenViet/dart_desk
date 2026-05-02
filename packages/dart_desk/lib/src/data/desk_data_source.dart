import 'dart:typed_data';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'models/document_list.dart';
import 'models/document_version.dart';
import 'models/image_types.dart';
import 'models/media_asset.dart';
import 'models/media_page.dart';

/// Abstract interface for CMS data operations.
///
/// This interface defines all data operations needed by the CMS UI,
/// allowing different backend implementations (Serverpod, local database,
/// REST API, etc.) to be used interchangeably.
///
/// ## Usage
///
/// Implement this interface to create a custom data source:
///
/// ```dart
/// class MyDataSource implements DataSource {
///   @override
///   Future<DocumentList> getDocuments(...) async {
///     // Your implementation
///   }
///   // ... implement other methods
/// }
/// ```
///
/// ## Error Handling
///
/// All methods throw exceptions on failure. Implementations should throw
/// descriptive exceptions that can be caught and handled by the UI layer.
///
/// Common exceptions:
/// - [DeskDataSourceException] - Base exception for data source errors
/// - [DeskAuthenticationException] - Authentication required or failed
/// - [DeskNotFoundException] - Resource not found
abstract class DataSource {
  // ============================================================
  // Document Operations
  // ============================================================

  /// Retrieves a paginated list of documents for a specific document type.
  ///
  /// [documentType] - The type of documents to retrieve (e.g., 'article', 'page')
  /// [search] - Optional search query to filter documents
  /// [limit] - Maximum number of documents to return (default: 20)
  /// [offset] - Number of documents to skip for pagination (default: 0)
  ///
  /// Returns a [DocumentList] containing the documents and pagination info.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  Future<DocumentList> getDocuments(
    String documentType, {
    String? search,
    int limit = 20,
    int offset = 0,
  });

  /// Retrieves a single document by its ID.
  ///
  /// [documentId] - The unique identifier of the document
  ///
  /// Returns the [DeskDocument] if found, or null if not found.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  Future<DeskDocument?> getDocument(String documentId);

  /// Creates a new document with an initial version.
  ///
  /// [documentType] - The type of document to create
  /// [title] - The document title
  /// [data] - The initial version data as a map
  /// [slug] - Optional URL-friendly slug
  /// [isDefault] - Whether this is the default document for this type
  ///
  /// Returns the created [DeskDocument] with its assigned ID.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  /// Throws [DeskAuthenticationException] if authentication is required.
  Future<DeskDocument> createDocument(
    String documentType,
    String title,
    Map<String, dynamic> data, {
    String? slug,
    bool isDefault = false,
  });

  /// Updates document metadata (title, slug, isDefault).
  /// To update document data, use createDocumentVersion instead.
  ///
  /// [documentId] - The ID of the document to update
  /// [title] - Optional new title
  /// [slug] - Optional new slug
  /// [isDefault] - Optional new default status
  ///
  /// Returns the updated [DeskDocument], or null if the document was not found.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  /// Throws [DeskAuthenticationException] if authentication is required.
  Future<DeskDocument?> updateDocument(
    String documentId, {
    String? title,
    String? slug,
    bool? isDefault,
  });

  /// Deletes a document.
  ///
  /// [documentId] - The ID of the document to delete
  ///
  /// Returns true if the document was deleted, false if it was not found.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  /// Throws [DeskAuthenticationException] if authentication is required.
  Future<bool> deleteDocument(String documentId);

  /// Atomically unsets the current default for [documentTypeSlug] and sets
  /// [documentId] as the new default. Returns the updated document.
  Future<DeskDocument> setDefaultDocument(
    String documentTypeSlug,
    String documentId,
  );

  /// Suggests a unique slug for a document based on its title.
  ///
  /// [title] - The document title to generate a slug from
  /// [documentType] - The document type to check uniqueness within
  ///
  /// Returns a unique slug string. If a duplicate exists, appends a suffix.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  Future<String> suggestSlug(String title, String documentType);

  /// Retrieves all unique document types in the system.
  ///
  /// Returns a list of document type names.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  Future<List<String>> getDocumentTypes();

  // ============================================================
  // Document Version Operations
  // ============================================================

  /// Retrieves a paginated list of versions for a specific document.
  ///
  /// Each [DocumentVersion] in the result will have its `data` field
  /// populated with the reconstructed document data at that version.
  ///
  /// [documentId] - The ID of the document to get versions for
  /// [limit] - Maximum number of versions to return (default: 20)
  /// [offset] - Number of versions to skip for pagination (default: 0)
  ///
  /// Returns a [DocumentVersionList] containing the versions and pagination info.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  Future<DocumentVersionList> getDocumentVersions(
    String documentId, {
    int limit = 20,
    int offset = 0,
  });

  /// Retrieves a single document version by its ID.
  ///
  /// [versionId] - The unique identifier of the version
  ///
  /// Returns the [DocumentVersion] if found, or null if not found.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  Future<DocumentVersion?> getDocumentVersion(String versionId);

  /// Get the document data for a specific version
  /// Reconstructs data from CRDT operations at the version's HLC snapshot
  Future<Map<String, dynamic>?> getDocumentVersionData(String versionId);

  /// Creates a new version snapshot for a document at the current state.
  ///
  /// [documentId] - The ID of the document to create a version for
  /// [status] - The initial status (default: 'draft')
  /// [changeLog] - Optional description of what changed
  ///
  /// Returns the created [DocumentVersion] with its assigned ID.
  ///
  /// Note: Version data is stored as CRDT operations, not in the version itself.
  /// Use getDocumentVersionData() to retrieve the data for a version.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  /// Throws [DeskAuthenticationException] if authentication is required.
  Future<DocumentVersion> createDocumentVersion(
    String documentId, {
    String status = 'draft',
    String? changeLog,
  });

  /// Updates document data using CRDT operations (partial updates).
  /// Only changed fields need to be provided - they will be merged automatically.
  ///
  /// [documentId] - The ID of the document to update
  /// [updates] - Map of field updates (only changed fields)
  /// [sessionId] - Optional session ID for collaborative editing tracking
  ///
  /// Returns the updated [DeskDocument] with merged data.
  ///
  /// Note: This uses CRDT operations for conflict-free collaborative editing.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  /// Throws [DeskAuthenticationException] if authentication is required.
  Future<DeskDocument> updateDocumentData(
    String documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  });

  /// Publishes a document version, making it the current published version.
  ///
  /// [versionId] - The ID of the version to publish
  ///
  /// Returns the updated [DocumentVersion] with published status.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  /// Throws [DeskAuthenticationException] if authentication is required.
  Future<DocumentVersion?> publishDocumentVersion(String versionId);

  /// Archives a document version.
  ///
  /// [versionId] - The ID of the version to archive
  ///
  /// Returns the updated [DocumentVersion] with archived status.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  /// Throws [DeskAuthenticationException] if authentication is required.
  Future<DocumentVersion?> archiveDocumentVersion(String versionId);

  /// Restores a previous version's data into the current draft. Appends CRDT
  /// ops bringing the document back to the historical state. Does not
  /// auto-publish.
  ///
  /// [documentId] - The ID of the document
  /// [versionId] - The ID of the version to restore from
  ///
  /// Returns the updated [DeskDocument] with the restored draft data.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  /// Throws [DeskAuthenticationException] if authentication is required.
  Future<DeskDocument> restoreDocumentVersion(
    String documentId,
    String versionId,
  );

  /// Deletes a document version.
  ///
  /// [versionId] - The ID of the version to delete
  ///
  /// Returns true if the version was deleted, false if it was not found.
  ///
  /// Throws [DeskDataSourceException] if the operation fails.
  /// Throws [DeskAuthenticationException] if authentication is required.
  Future<bool> deleteDocumentVersion(String versionId);

  // ============================================================
  // Media Operations
  // ============================================================

  /// Upload an image. The server computes all derived metadata.
  /// Returns the MediaAsset (existing if deduplicated, new otherwise).
  Future<MediaAsset> uploadImage(String fileName, Uint8List fileData);

  /// Upload a non-image file.
  Future<MediaAsset> uploadFile(String fileName, Uint8List fileData);

  /// Delete a media asset. Fails if asset is still referenced by documents.
  Future<bool> deleteMedia(String assetId);

  /// Get a single asset by assetId.
  Future<MediaAsset?> getMediaAsset(String assetId);

  /// List/search media assets with filtering and sorting.
  Future<MediaPage> listMedia({
    String? search,
    MediaTypeFilter? type,
    MediaSort sort = MediaSort.dateDesc,
    int limit = 50,
    int offset = 0,
  });

  /// Update mutable asset fields.
  Future<MediaAsset> updateMediaAsset(String assetId, {String? fileName});

  /// Get usage count: how many documents reference this asset.
  Future<int> getMediaUsageCount(String assetId);
}

// ============================================================
// Exceptions
// ============================================================

/// Base exception for CMS data source errors.
class DeskDataSourceException implements Exception {
  /// Human-readable error message
  final String message;

  /// Optional underlying error/exception
  final Object? cause;

  const DeskDataSourceException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'DeskDataSourceException: $message (caused by: $cause)';
    }
    return 'DeskDataSourceException: $message';
  }
}

/// Exception thrown when authentication is required but not provided,
/// or when authentication fails.
class DeskAuthenticationException extends DeskDataSourceException {
  const DeskAuthenticationException([super.message = 'Authentication required']);

  @override
  String toString() => 'DeskAuthenticationException: $message';
}

/// Exception thrown when a requested resource is not found.
class DeskNotFoundException extends DeskDataSourceException {
  /// The type of resource that was not found
  final String? resourceType;

  /// The ID of the resource that was not found
  final dynamic resourceId;

  const DeskNotFoundException({
    this.resourceType,
    this.resourceId,
    String message = 'Resource not found',
  }) : super(message);

  @override
  String toString() {
    if (resourceType != null && resourceId != null) {
      return 'DeskNotFoundException: $resourceType with id $resourceId not found';
    }
    return 'DeskNotFoundException: $message';
  }
}

/// Exception thrown when validation fails.
class DeskValidationException extends DeskDataSourceException {
  /// Map of field names to error messages
  final Map<String, String>? fieldErrors;

  const DeskValidationException(super.message, {this.fieldErrors});

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      return 'DeskValidationException: $message - $fieldErrors';
    }
    return 'DeskValidationException: $message';
  }
}
