import 'package:dart_mappable/dart_mappable.dart';

part 'cms_content.mapper.dart';

/// Base class for all CMS content types.
///
/// Uses dart_mappable's polymorphic deserialization so that a JSON payload
/// with a `"documentType"` key is automatically routed to the correct
/// subclass (e.g. `"heroConfig"` → [HeroConfig]).
///
/// Usage:
/// ```dart
/// final json = jsonDecode(publicDocument.data) as Map<String, dynamic>;
/// json['documentType'] = 'heroConfig'; // inject discriminator
/// final config = CmsContentMapper.fromMap(json); // returns HeroConfig
/// ```
@MappableClass(discriminatorKey: 'documentType')
abstract class CmsContent with CmsContentMappable {
  const CmsContent();
}
