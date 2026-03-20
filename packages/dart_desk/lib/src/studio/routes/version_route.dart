import 'package:flutter/material.dart';

import 'studio_coordinator.dart';
import 'studio_layout.dart';
import 'studio_route.dart';

class VersionRoute extends StudioRoute {
  final String documentTypeSlug;
  final String documentId;
  final String versionId;
  VersionRoute(this.documentTypeSlug, this.documentId, this.versionId);

  @override
  Type get layout => StudioLayout;

  @override
  Uri toUri() => Uri.parse('/$documentTypeSlug/$documentId/$versionId');

  @override
  List<Object?> get props => [documentTypeSlug, documentId, versionId];

  @override
  Widget build(StudioCoordinator coordinator, BuildContext context) =>
      const SizedBox.shrink();
}
