import 'package:flutter/widgets.dart';

import 'fields/base/field.dart';
import 'serializable.dart';

/// Represents a document type (schema) in the CMS
class CmsDocumentType<T extends Serializable<dynamic>> {
  /// Unique identifier for this document type
  final String name;

  /// Display title for this document type
  final String title;

  /// Description of this document type
  final String description;

  /// List of fields for this document type
  final List<CmsField> fields;

  /// Required builder function to create a widget from the config data
  final Widget Function(Map<String, dynamic> data) builder;

  /// Function to create a default instance of T
  final T? defaultValue;
  const CmsDocumentType({
    required this.name,
    required this.title,
    required this.description,
    required this.fields,
    required this.builder,
    this.defaultValue,
  });
}
