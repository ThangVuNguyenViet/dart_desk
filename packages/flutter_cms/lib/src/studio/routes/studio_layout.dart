import 'package:flutter/material.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zenrouter/zenrouter.dart';

import '../components/common/default_cms_header.dart';
import '../components/navigation/cms_document_type_sidebar.dart';
import '../providers/studio_provider.dart';
import '../screens/cms_studio.dart';
import 'studio_coordinator.dart';
import 'studio_route.dart';

/// The root layout for all studio routes.
///
/// Wraps content in [StudioProvider] + [StudioShell] + [CmsStudio] to provide
/// the top bar, sidebar, and document management panels.
class StudioLayout extends StudioRoute with RouteLayout<StudioRoute> {
  @override
  StackPath<RouteUnique> resolvePath(StudioCoordinator coordinator) =>
      coordinator.studioStack;

  @override
  Widget build(StudioCoordinator coordinator, BuildContext context) {
    return StudioProvider(
      dataSource: coordinator.dataSource,
      documentTypes: coordinator.documentTypes,
      child: StudioShell(
        coordinator: coordinator,
        child: CmsStudio(
          coordinator: coordinator,
          sidebar: CmsDocumentTypeSidebar(
            documentTypeDecorations: coordinator.documentTypeDecorations,
            coordinator: coordinator,
          ),
        ),
      ),
    );
  }
}

/// Shell widget that provides the top bar and listens to route changes
/// to sync route params with the CMS view model.
class StudioShell extends StatefulWidget {
  final StudioCoordinator coordinator;
  final Widget child;

  const StudioShell({
    super.key,
    required this.coordinator,
    required this.child,
  });

  @override
  State<StudioShell> createState() => _StudioShellState();
}

class _StudioShellState extends State<StudioShell> {
  @override
  void initState() {
    super.initState();
    widget.coordinator.studioStack.addListener(_onRouteChanged);
    // Sync initial route params after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onRouteChanged();
    });
  }

  @override
  void dispose() {
    widget.coordinator.studioStack.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    final vm = cmsViewModelProvider.of(context);

    vm.setRouteParams(
      documentTypeSlug: widget.coordinator.currentDocumentTypeSlug,
      documentId: widget.coordinator.currentDocumentId,
      versionId: widget.coordinator.currentVersionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TopBar(),
        const Divider(height: 1),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Top bar for the studio layout.
///
/// Reads branding from [DefaultCmsHeaderConfig] and provides
/// navigation and sign-out actions.
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final headerConfig = DefaultCmsHeaderConfig.of(context);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (headerConfig?.icon != null) ...[
            Icon(
              headerConfig!.icon,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerConfig?.title ?? 'CMS Studio',
                  style: theme.textTheme.large.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (headerConfig?.subtitle != null)
                  Text(
                    headerConfig!.subtitle!,
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
              ],
            ),
          ),
          if (headerConfig?.onDashboardPressed != null)
            ShadButton.ghost(
              onPressed: headerConfig!.onDashboardPressed,
              child: const Text('Open Dashboard'),
            ),
          const SizedBox(width: 8),
          ShadButton.outline(
            size: ShadButtonSize.sm,
            onPressed: () => context.signOut(),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
