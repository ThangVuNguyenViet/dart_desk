import 'package:flutter/material.dart';

import '../data/cms_data_source.dart';
import 'routes/studio_coordinator.dart';
import 'screens/cms_studio.dart';

class CmsStudioApp extends StatelessWidget {
  const CmsStudioApp({
    super.key,
    required this.coordinator,
    required this.sidebar,
    required this.dataSource,
  });

  final StudioCoordinator coordinator;
  final Widget sidebar;
  final CmsDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return CmsStudio(coordinator: coordinator, sidebar: sidebar);
  }
}
