import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../components/layout/cms_content_layout.dart';
import '../theme/spacing.dart';

@RoutePage()
class DocumentTypeScreen extends StatelessWidget {
  const DocumentTypeScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
  });

  final String documentTypeSlug;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return CmsContentLayout(
      documentTypeSlug: documentTypeSlug,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(CmsSpacing.xl),
          child: ShadCard(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(CmsSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(CmsBorderRadius.md),
                  ),
                  child: FaIcon(FontAwesomeIcons.pen,
                      size: 24, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: CmsSpacing.md),
                Text(
                  'Document Editor',
                  style: theme.textTheme.large
                      .copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: CmsSpacing.md - CmsSpacing.sm),
                Text(
                  'Select a document from the list to start editing',
                  style: theme.textTheme.muted.copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
