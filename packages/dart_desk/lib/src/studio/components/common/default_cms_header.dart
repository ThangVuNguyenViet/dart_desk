import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Default header widget for CMS Studio
class DefaultCmsHeader extends StatelessWidget {
  final String? name;
  final String title;
  final String? subtitle;
  final IconData? icon;

  const DefaultCmsHeader({
    super.key,
    this.name,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                FaIcon(icon!, size: 24, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.large.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// InheritedWidget that provides CMS header configuration (branding)
/// to descendant widgets like the top bar in [StudioShell].
class DefaultCmsHeaderConfig extends InheritedWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? dashboardUrl;

  const DefaultCmsHeaderConfig({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.dashboardUrl,
    required super.child,
  });

  static DefaultCmsHeaderConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DefaultCmsHeaderConfig>();
  }

  @override
  bool updateShouldNotify(DefaultCmsHeaderConfig oldWidget) {
    return title != oldWidget.title ||
        subtitle != oldWidget.subtitle ||
        icon != oldWidget.icon ||
        dashboardUrl != oldWidget.dashboardUrl;
  }
}
