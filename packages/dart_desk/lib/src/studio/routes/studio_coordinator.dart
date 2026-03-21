import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:zenrouter/zenrouter.dart';

import '../../data/cms_data_source.dart';
import '../components/common/cms_document_type_decoration.dart';
import 'studio_route.dart';
import 'studio_layout.dart';
import 'document_type_route.dart';
import 'document_route.dart';
import 'media_route.dart';
import 'version_route.dart';

class StudioCoordinator extends Coordinator<StudioRoute> {
  final List<DocumentType> documentTypes;
  final DataSource dataSource;
  final List<DocumentTypeDecoration> documentTypeDecorations;
  final VoidCallback? onSignOut;

  String get defaultDocumentTypeSlug =>
      documentTypes.isNotEmpty ? documentTypes.first.name : '';

  late final studioStack = NavigationPath<StudioRoute>.createWith(
    coordinator: this,
    label: 'studio',
  )..bindLayout(StudioLayout.new);

  StudioCoordinator({
    required this.documentTypes,
    required this.dataSource,
    this.documentTypeDecorations = const [],
    this.onSignOut,
  });

  @override
  List<StackPath> get paths => [...super.paths, studioStack];

  String? get currentDocumentTypeSlug {
    final route = studioStack.activeRoute;
    if (route is VersionRoute) return route.documentTypeSlug;
    if (route is DocumentRoute) return route.documentTypeSlug;
    if (route is DocumentTypeRoute) return route.documentTypeSlug;
    return null;
  }

  String? get currentDocumentId {
    final route = studioStack.activeRoute;
    if (route is VersionRoute) return route.documentId;
    if (route is DocumentRoute) return route.documentId;
    return null;
  }

  String? get currentVersionId {
    final route = studioStack.activeRoute;
    if (route is VersionRoute) return route.versionId;
    return null;
  }

  @override
  StudioRoute parseRouteFromUri(Uri uri) {
    final segments = uri.pathSegments;

    if (segments.isEmpty) {
      return DocumentTypeRoute(defaultDocumentTypeSlug);
    }

    if (segments.length == 1 && segments.first == 'media') {
      return MediaRoute();
    }

    return switch (segments) {
      [final slug] => DocumentTypeRoute(slug),
      [final slug, final docId] => DocumentRoute(slug, docId),
      [final slug, final docId, final versionId] =>
        VersionRoute(slug, docId, versionId),
      _ => DocumentTypeRoute(defaultDocumentTypeSlug),
    };
  }
}
