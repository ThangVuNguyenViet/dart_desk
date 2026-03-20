import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:zenrouter/zenrouter.dart';

import '../../../studio.dart';
import '../providers/studio_provider.dart';

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
        _TopBar(coordinator: widget.coordinator),
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
  final StudioCoordinator coordinator;

  const _TopBar({required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final headerConfig = DefaultCmsHeaderConfig.of(context);
    final viewModel = cmsViewModelProvider.of(context);

    // Build breadcrumb segments reactively
    final docTypeSlug = viewModel.currentDocumentTypeSlug.watch(context);
    final docId = viewModel.currentDocumentId.watch(context);

    final segments = <BreadcrumbSegment>[
      BreadcrumbSegment(
        label: headerConfig?.title ?? 'CMS Studio',
        onTap: docTypeSlug != null
            ? () => coordinator.studioStack.reset()
            : null,
      ),
    ];

    if (docTypeSlug != null) {
      final docType = viewModel.currentDocumentType.value;
      segments.add(BreadcrumbSegment(
        label: docType?.title ?? docTypeSlug,
        onTap: docId != null
            ? () => coordinator.pushOrMoveToTop(
                  DocumentTypeRoute(docTypeSlug),
                )
            : null,
      ));
    }

    if (docId != null) {
      final documentViewModel = documentViewModelProvider.of(context);
      final title = documentViewModel.title.watch(context);
      segments.add(BreadcrumbSegment(label: title.isNotEmpty ? title : 'Document'));
    }

    final themeModeSignal = CmsThemeModeProvider.of(context);
    final currentTheme = themeModeSignal.watch(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: CmsSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          // Logo
          if (headerConfig?.icon != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(CmsBorderRadius.md),
              ),
              child: Center(
                child: FaIcon(
                  headerConfig!.icon!,
                  size: 14,
                  color: theme.colorScheme.primaryForeground,
                ),
              ),
            ),
            const SizedBox(width: CmsSpacing.md),
          ],

          // Breadcrumbs
          Expanded(child: CmsBreadcrumbs(segments: segments)),

          // Right section
          CmsThemeToggle(
            themeMode: currentTheme,
            onChanged: (mode) async {
              themeModeSignal.value = mode;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('cms_theme_mode_dark', mode == ThemeMode.dark);
            },
          ),
          const SizedBox(width: CmsSpacing.md),
          CmsVersionHistory(viewModel: viewModel),
          const SizedBox(width: CmsSpacing.md),

          // User avatar with sign-out
          GestureDetector(
            onTap: () => coordinator.onSignOut?.call(),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.solidUser,
                    size: 12,
                    color: theme.colorScheme.primaryForeground,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
