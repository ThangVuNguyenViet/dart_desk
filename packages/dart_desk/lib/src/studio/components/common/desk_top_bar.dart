import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

import '../../desk_studio_app.dart';
import '../../config/studio_config.dart';
import '../../core/view_models/desk_document_view_model.dart';
import '../../core/view_models/desk_view_model.dart';
import '../../router/studio_router.dart';
import '../../theme/spacing.dart';
import '../version/desk_version_history.dart';
import 'desk_breadcrumbs.dart';
import 'desk_theme_toggle.dart';
import 'default_desk_header.dart';

/// Persistent top bar for the CMS studio.
///
/// Displays logo, breadcrumbs, theme toggle, version history, and sign-out.
/// Navigation uses [context.router.navigate] (auto_route).
class DeskTopBar extends StatelessWidget {
  const DeskTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final headerConfig = DefaultDeskHeaderConfig.of(context);
    final viewModel = GetIt.I<DeskViewModel>();
    final config = GetIt.I<StudioConfig>();

    final docTypeSlug = viewModel.currentDocumentTypeSlug.watch(context);
    final docId = viewModel.currentDocumentId.watch(context);

    final segments = <BreadcrumbSegment>[
      BreadcrumbSegment(
        label: headerConfig?.title ?? 'CMS Studio',
        onTap: docTypeSlug != null
            ? () => context.router.navigate(
                DocumentTypeScreenRoute(documentTypeSlug: docTypeSlug),
              )
            : null,
      ),
    ];

    if (docTypeSlug != null) {
      final docType = viewModel.currentDocumentType.value;
      segments.add(
        BreadcrumbSegment(
          label: docType?.title ?? docTypeSlug,
          key: docId != null ? const ValueKey('breadcrumb_back') : null,
          onTap: docId != null
              ? () => context.router.navigate(
                  DocumentTypeScreenRoute(documentTypeSlug: docTypeSlug),
                )
              : null,
        ),
      );
    }

    if (docId != null) {
      final documentViewModel = GetIt.I<DeskDocumentViewModel>();
      final title =
          documentViewModel.selectedDocument.watch(context).value?.title ?? '';
      segments.add(
        BreadcrumbSegment(label: title.isNotEmpty ? title : 'Document'),
      );
    }

    final themeModeSignal = DeskThemeModeProvider.of(context);
    final currentTheme = themeModeSignal.watch(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: DeskSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Row(
        children: [
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
                borderRadius: BorderRadius.circular(DeskBorderRadius.md),
              ),
              child: Center(
                child: FaIcon(
                  headerConfig!.icon!,
                  size: 14,
                  color: theme.colorScheme.primaryForeground,
                ),
              ),
            ),
            const SizedBox(width: DeskSpacing.md),
          ],
          Expanded(child: DeskBreadcrumbs(segments: segments)),
          DeskThemeToggle(
            themeMode: currentTheme,
            onChanged: (mode) async {
              themeModeSignal.value = mode;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(
                'desk_theme_mode_dark',
                mode == ThemeMode.dark,
              );
            },
          ),
          const SizedBox(width: DeskSpacing.md),
          DeskVersionHistory(viewModel: viewModel),
          const SizedBox(width: DeskSpacing.md),
          GestureDetector(
            onTap: () => config.onSignOut?.call(),
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
