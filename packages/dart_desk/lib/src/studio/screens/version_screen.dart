import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'document_screen.dart';

/// Thin wrapper so auto_route has a unique page for the version path.
/// Rendering is identical to [DocumentScreen].
@RoutePage()
class VersionScreen extends StatelessWidget {
  const VersionScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
    @PathParam('documentId') required this.documentId,
    @PathParam('versionId') required this.versionId,
  });

  final String documentTypeSlug;
  final String documentId;
  final String versionId;

  @override
  Widget build(BuildContext context) {
    return DocumentScreen(
      documentTypeSlug: documentTypeSlug,
      documentId: documentId,
      versionId: versionId,
    );
  }
}
