// dart_desk/packages/dart_desk/lib/src/studio/components/common/desk_breadcrumbs.dart

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/spacing.dart';

/// A segment in the breadcrumb trail.
class BreadcrumbSegment {
  final String label;
  final VoidCallback? onTap;
  final Key? key;

  const BreadcrumbSegment({required this.label, this.onTap, this.key});
}

/// Breadcrumb navigation trail for the CMS top bar.
///
/// Displays segments separated by `/` dividers. The last segment
/// uses foreground color (current), intermediate segments use muted color
/// and are tappable for navigation.
class DeskBreadcrumbs extends StatelessWidget {
  final List<BreadcrumbSegment> segments;

  const DeskBreadcrumbs({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < segments.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DeskSpacing.sm),
              child: Text(
                '/',
                style: TextStyle(fontSize: 16, color: theme.colorScheme.border),
              ),
            ),
          _BreadcrumbItem(
            segment: segments[i],
            isLast: i == segments.length - 1,
          ),
        ],
      ],
    );
  }
}

class _BreadcrumbItem extends StatelessWidget {
  final BreadcrumbSegment segment;
  final bool isLast;

  const _BreadcrumbItem({required this.segment, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final style = TextStyle(
      fontSize: 12,
      color: isLast
          ? theme.colorScheme.foreground
          : theme.colorScheme.mutedForeground,
    );

    if (segment.onTap != null && !isLast) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: segment.key,
          onTap: segment.onTap,
          child: Text(segment.label, style: style),
        ),
      );
    }

    return Text(segment.label, style: style);
  }
}
