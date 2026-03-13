import 'package:flutter/material.dart';

import 'studio_coordinator.dart';
import 'studio_layout.dart';
import 'studio_route.dart';

class DocumentRoute extends StudioRoute {
  final String documentTypeSlug;
  final String documentId;
  DocumentRoute(this.documentTypeSlug, this.documentId);

  @override
  Type get layout => StudioLayout;

  @override
  Uri toUri() => Uri.parse('/$documentTypeSlug/$documentId');

  @override
  List<Object?> get props => [documentTypeSlug, documentId];

  @override
  Widget build(StudioCoordinator coordinator, BuildContext context) =>
      const SizedBox.shrink();
}
