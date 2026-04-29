import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

const _eq = DeepCollectionEquality();

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
          _eq.equals(other.data, data) &&
          other.publishedAt == publishedAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        documentType,
        title,
        slug,
        isDefault,
        _eq.hash(data),
        publishedAt,
        updatedAt,
      );
}
