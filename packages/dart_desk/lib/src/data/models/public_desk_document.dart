import 'package:meta/meta.dart';

/// Platform-agnostic representation of a published document returned by
/// [PublicContentSource]. Mirrors the Serverpod `PublicDocument` shape but
/// keeps dart_desk's public API free of generated client types.
@immutable
class PublicDeskDocument {
  const PublicDeskDocument({
    required this.id,
    required this.documentType,
    required this.title,
    required this.slug,
    required this.isDefault,
    required this.data,
    required this.publishedAt,
    required this.updatedAt,
  });

  final String id;
  final String documentType;
  final String title;
  final String slug;
  final bool isDefault;
  final Map<String, dynamic> data;
  final DateTime publishedAt;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicDeskDocument &&
          other.id == id &&
          other.documentType == documentType &&
          other.title == title &&
          other.slug == slug &&
          other.isDefault == isDefault &&
          _mapEquals(other.data, data) &&
          other.publishedAt == publishedAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        documentType,
        title,
        slug,
        isDefault,
        publishedAt,
        updatedAt,
      );
}

bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
  if (a.length != b.length) return false;
  for (final k in a.keys) {
    if (!b.containsKey(k) || b[k] != a[k]) return false;
  }
  return true;
}
