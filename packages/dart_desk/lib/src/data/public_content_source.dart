import 'models/public_desk_document.dart';

/// Read-only view of published CMS content for consumer apps.
///
/// Mirrors `dart_desk_client.publicContent` but returns
/// platform-agnostic [PublicDeskDocument] values so dart_desk's public API
/// does not leak Serverpod-generated types.
abstract class PublicContentSource {
  Future<Map<String, List<PublicDeskDocument>>> getAllContents();
  Future<Map<String, PublicDeskDocument>> getDefaultContents();
  Future<List<PublicDeskDocument>> getContentsByType(String documentType);
  Future<PublicDeskDocument> getDefaultContent(String documentType);
  Future<PublicDeskDocument> getContentBySlug(String documentType, String slug);
  Future<List<PublicDeskDocument>> getContentsByDataContains(
    String documentType,
    String dataContainsJson,
  );
}
