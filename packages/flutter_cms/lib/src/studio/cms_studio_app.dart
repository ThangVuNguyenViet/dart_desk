import 'package:flutter/material.dart';
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../data/cms_data_source.dart';
import 'components/common/cms_document_type_decoration.dart';
import 'components/common/default_cms_header.dart';
import 'routes/studio_coordinator.dart';
import 'theme/theme.dart';

/// The complete CMS Studio entry point.
///
/// Creates the [StudioCoordinator] internally, wraps in [ShadApp.router]
/// with dark theme, and provides [DefaultCmsHeaderConfig] for the top bar.
/// The consuming app only needs to provide data and document type configuration.
class CmsStudioApp extends StatefulWidget {
  const CmsStudioApp({
    super.key,
    required this.dataSource,
    required this.documentTypes,
    required this.documentTypeDecorations,
    this.title = 'CMS Studio',
    this.subtitle,
    this.icon,
    this.onDashboardPressed,
    this.theme,
  });

  final CmsDataSource dataSource;
  final List<CmsDocumentType> documentTypes;
  final List<CmsDocumentTypeDecoration> documentTypeDecorations;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onDashboardPressed;
  final ShadThemeData? theme;

  @override
  State<CmsStudioApp> createState() => _CmsStudioAppState();
}

class _CmsStudioAppState extends State<CmsStudioApp> {
  late final StudioCoordinator coordinator;

  @override
  void initState() {
    super.initState();
    coordinator = StudioCoordinator(
      documentTypes: widget.documentTypes,
      dataSource: widget.dataSource,
      documentTypeDecorations: widget.documentTypeDecorations,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultCmsHeaderConfig(
      title: widget.title,
      subtitle: widget.subtitle,
      icon: widget.icon,
      onDashboardPressed: widget.onDashboardPressed,
      child: ShadApp.router(
        theme: widget.theme ?? cmsStudioTheme,
        routeInformationParser: coordinator.routeInformationParser,
        routerDelegate: coordinator.routerDelegate,
      ),
    );
  }
}
