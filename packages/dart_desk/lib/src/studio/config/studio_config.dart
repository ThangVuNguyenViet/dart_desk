import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';

import '../../data/cms_data_source.dart';
import '../components/common/cms_document_type_decoration.dart';

/// Holds CMS studio configuration data.
///
/// Registered as a GetIt singleton by [CmsStudioApp] before the widget tree
/// builds. All widgets that previously received [StudioCoordinator] as a
/// parameter now read from [GetIt.I<StudioConfig>()] instead.
class StudioConfig {
  final List<DocumentType> documentTypes;
  final DataSource dataSource;
  final List<DocumentTypeDecoration> documentTypeDecorations;
  final VoidCallback? onSignOut;

  const StudioConfig({
    required this.documentTypes,
    required this.dataSource,
    this.documentTypeDecorations = const [],
    this.onSignOut,
  });
}
