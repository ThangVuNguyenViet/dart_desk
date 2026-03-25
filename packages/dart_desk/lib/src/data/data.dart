/// Data layer for Dart Desk.
///
/// This library provides the data source abstraction and implementations
/// for communicating with different backends.
///
/// ## Usage
///
/// ```dart
/// import 'package:dart_desk/data.dart';
///
/// // Use the Serverpod implementation
/// final client = Client('http://localhost:8080/');
/// final dataSource = ServerpodDataSource(client);
///
/// // Or implement your own data source
/// class MyDataSource implements DataSource {
///   // ... implementation
/// }
/// ```
library;

// Abstract interface
export 'cms_data_source.dart';

// Serverpod implementation is in dart_desk_client package
// export 'serverpod_data_source.dart';

// Models
export 'models/cms_document.dart';
export 'models/cms_document_data.dart';
export 'models/document_list.dart';
export 'models/document_version.dart';
export 'models/image_types.dart';
export 'models/media_asset.dart';
export 'models/image_reference.dart';
export 'models/media_page.dart';
