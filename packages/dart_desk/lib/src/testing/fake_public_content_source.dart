import 'dart:convert';

import '../data/models/public_desk_document.dart';
import '../data/public_content_source.dart';

/// In-memory [PublicContentSource] for tests and showcase apps.
///
/// Enforces the public projection — only documents added via [seed] are
/// returned by reads. [seedDraft] entries simulate unpublished documents
/// and are filtered from every read method, matching the real backend.
class FakePublicContentSource implements PublicContentSource {
  final List<PublicDeskDocument> _published = [];

  void seed(Iterable<PublicDeskDocument> docs) => _published.addAll(docs);

  /// Records draft documents that exist conceptually but should be invisible
  /// to readers. Drafts are intentionally not stored — the assertion is
  /// "they don't show up." Holding them in a separate list would invite
  /// tests that read the draft set, which the real public endpoint cannot do.
  void seedDraft(Iterable<PublicDeskDocument> docs) {}

  @override
  Future<Map<String, List<PublicDeskDocument>>> getAllContents() async {
    final out = <String, List<PublicDeskDocument>>{};
    for (final d in _published) {
      out.putIfAbsent(d.documentType, () => []).add(d);
    }
    return out;
  }

  @override
  Future<Map<String, PublicDeskDocument>> getDefaultContents() async {
    final out = <String, PublicDeskDocument>{};
    for (final d in _published.where((d) => d.isDefault)) {
      out[d.documentType] = d;
    }
    return out;
  }

  @override
  Future<List<PublicDeskDocument>> getContentsByType(String documentType) async =>
      _published.where((d) => d.documentType == documentType).toList();

  @override
  Future<PublicDeskDocument> getDefaultContent(String documentType) async {
    for (final d in _published) {
      if (d.documentType == documentType && d.isDefault) return d;
    }
    throw StateError('No default published document for "$documentType".');
  }

  @override
  Future<PublicDeskDocument> getContentBySlug(
      String documentType, String slug) async {
    for (final d in _published) {
      if (d.documentType == documentType && d.slug == slug) return d;
    }
    throw StateError('No published document for "$documentType" / "$slug".');
  }

  @override
  Future<List<PublicDeskDocument>> getContentsByDataContains(
    String documentType,
    String dataContainsJson,
  ) async {
    final fragment = jsonDecode(dataContainsJson);
    if (fragment is! Map<String, dynamic>) {
      throw ArgumentError('dataContainsJson must be a JSON object');
    }
    return _published
        .where((d) =>
            d.documentType == documentType && _contains(d.data, fragment))
        .toList();
  }

  bool _contains(Map<String, dynamic> haystack, Map<String, dynamic> needle) {
    for (final entry in needle.entries) {
      if (!haystack.containsKey(entry.key)) return false;
      if (haystack[entry.key] != entry.value) return false;
    }
    return true;
  }
}
