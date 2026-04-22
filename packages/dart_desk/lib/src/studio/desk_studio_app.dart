import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

import '../data/desk_data_source.dart';
import 'components/common/desk_document_type_decoration.dart';
import 'components/common/default_desk_header.dart';
import 'config/desk_breakpoints.dart';
import 'config/studio_config.dart';
import 'router/studio_route_observer.dart';
import 'router/studio_router.dart';
import 'theme/theme.dart';

/// The complete CMS Studio entry point.
///
/// Creates [StudioConfig] and registers it in GetIt, instantiates [StudioRouter],
/// and wires [ShadApp.router]. The consuming app only needs to provide data
/// and document type configuration.
class DeskStudioApp extends StatefulWidget {
  const DeskStudioApp({
    super.key,
    required this.dataSource,
    required this.documentTypes,
    required this.documentTypeDecorations,
    this.title = 'CMS Studio',
    this.subtitle,
    this.icon,
    this.onSignOut,
    this.theme,
  });

  final DataSource dataSource;
  final List<DocumentType> documentTypes;
  final List<DocumentTypeDecoration> documentTypeDecorations;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onSignOut;
  final ShadThemeData? theme;

  @override
  State<DeskStudioApp> createState() => _DeskStudioAppState();
}

class _DeskStudioAppState extends State<DeskStudioApp> {
  late final StudioRouter _router;
  final _themeMode = Signal<ThemeMode>(ThemeMode.dark, debugLabel: 'themeMode');

  @override
  void initState() {
    super.initState();
    GetIt.I.registerSingleton<StudioConfig>(
      StudioConfig(
        documentTypes: widget.documentTypes,
        dataSource: widget.dataSource,
        documentTypeDecorations: widget.documentTypeDecorations,
        onSignOut: widget.onSignOut,
      ),
    );
    _router = StudioRouter();
    _loadPersistedTheme();
  }

  Future<void> _loadPersistedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('desk_theme_mode_dark') ?? true;
    _themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  void dispose() {
    GetIt.I.unregister<StudioConfig>();
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = _themeMode.watch(context);
    final resolvedTheme =
        widget.theme ??
        (currentMode == ThemeMode.dark ? deskStudioTheme : deskStudioLightTheme);

    return DeskThemeModeProvider(
      themeMode: _themeMode,
      child: DefaultDeskHeaderConfig(
        title: widget.title,
        subtitle: widget.subtitle,
        icon: widget.icon,
        child: ShadApp.router(
          theme: resolvedTheme,
          materialThemeBuilder: (context, mTheme) {
            final isDark = resolvedTheme.brightness == Brightness.dark;
            return mTheme.copyWith(
              extensions: <ThemeExtension<dynamic>>[
                isDark ? DartDeskPalette.dark : DartDeskPalette.light,
              ],
            );
          },
          routeInformationParser: _router.defaultRouteParser(),
          routerDelegate: _router.delegate(
            // Builder called once per Navigator (root + each nested shell).
            // NavigatorObserver can only be attached to one Navigator, so a
            // fresh instance must be returned each time.
            navigatorObservers: () => [StudioRouteObserver(_router)],
          ),
          builder: (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(
                start: 0,
                end: DeskBreakpoints.mobile,
                name: DeskBreakpoints.mobileTag,
              ),
              const Breakpoint(
                start: DeskBreakpoints.mobile,
                end: DeskBreakpoints.tablet,
                name: DeskBreakpoints.tabletTag,
              ),
              const Breakpoint(
                start: DeskBreakpoints.tablet,
                end: double.infinity,
                name: DeskBreakpoints.desktopTag,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Provides the theme mode signal to descendants.
class DeskThemeModeProvider extends InheritedWidget {
  final Signal<ThemeMode> themeMode;

  const DeskThemeModeProvider({
    super.key,
    required this.themeMode,
    required super.child,
  });

  static Signal<ThemeMode> of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DeskThemeModeProvider>()!
        .themeMode;
  }

  @override
  bool updateShouldNotify(DeskThemeModeProvider oldWidget) =>
      themeMode != oldWidget.themeMode;
}
