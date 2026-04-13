import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

import '../../cms_studio_app.dart';
import '../../config/studio_config.dart';
import '../../core/view_models/cms_document_view_model.dart';
import '../../core/view_models/cms_view_model.dart';
import '../../router/studio_router.dart';
import '../../theme/spacing.dart';
import '../version/cms_version_history.dart';
import 'cms_breadcrumbs.dart';
import 'cms_theme_toggle.dart';
import 'default_cms_header.dart';

/// Persistent top bar for the CMS studio.
///
/// Displays logo, breadcrumbs, theme toggle, version history, and sign-out.
/// Navigation uses [context.router.navigate] (auto_route).
class CmsTopBar extends StatelessWidget {
  const CmsTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final headerConfig = DefaultCmsHeaderConfig.of(context);
    final viewModel = GetIt.I<CmsViewModel>();
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
      final documentViewModel = GetIt.I<CmsDocumentViewModel>();
      final title = documentViewModel.title.watch(context);
      segments.add(
        BreadcrumbSegment(label: title.isNotEmpty ? title : 'Document'),
      );
    }

    final themeModeSignal = CmsThemeModeProvider.of(context);
    final currentTheme = themeModeSignal.watch(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: CmsSpacing.lg),
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
          Expanded(child: CmsBreadcrumbs(segments: segments)),
          CmsThemeToggle(
            themeMode: currentTheme,
            onChanged: (mode) async {
              themeModeSignal.value = mode;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(
                'cms_theme_mode_dark',
                mode == ThemeMode.dark,
              );
            },
          ),
          const SizedBox(width: CmsSpacing.md),
          CmsVersionHistory(viewModel: viewModel),
          const SizedBox(width: CmsSpacing.md),
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
