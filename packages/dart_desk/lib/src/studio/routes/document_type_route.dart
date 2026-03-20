import 'package:flutter/material.dart';

import 'studio_coordinator.dart';
import 'studio_layout.dart';
import 'studio_route.dart';

class DocumentTypeRoute extends StudioRoute {
  final String documentTypeSlug;
  DocumentTypeRoute(this.documentTypeSlug);

  @override
  Type get layout => StudioLayout;

  @override
  Uri toUri() => Uri.parse('/$documentTypeSlug');

  @override
  List<Object?> get props => [documentTypeSlug];

  @override
  Widget build(StudioCoordinator coordinator, BuildContext context) =>
      const SizedBox.shrink();
}
