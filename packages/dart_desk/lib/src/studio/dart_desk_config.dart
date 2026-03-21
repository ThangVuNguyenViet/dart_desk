import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/widgets.dart';

import 'components/common/cms_document_type_decoration.dart';

/// Configuration for the DartDeskApp widget.
class DartDeskConfig {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<DocumentType> documentTypes;
  final List<DocumentTypeDecoration> documentTypeDecorations;

  const DartDeskConfig({
    required this.documentTypes,
    required this.documentTypeDecorations,
    this.title = 'Dart Desk',
    this.subtitle,
    this.icon,
  });
}
