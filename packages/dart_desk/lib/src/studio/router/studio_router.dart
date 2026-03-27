import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';

import '../config/studio_config.dart';
import '../screens/document_screen.dart';
import '../screens/document_type_screen.dart';
import '../screens/media_screen.dart';
import '../screens/studio_shell_screen.dart';
import '../screens/version_screen.dart';

part 'studio_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,ScreenRoute')
class StudioRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: StudioShellScreenRoute.page,
          path: '/',
          guards: [DefaultDocTypeGuard()],
          children: [
            AutoRoute(page: MediaScreenRoute.page, path: 'media'),
            AutoRoute(
                page: DocumentTypeScreenRoute.page,
                path: ':documentTypeSlug'),
            AutoRoute(
                page: DocumentScreenRoute.page,
                path: ':documentTypeSlug/:documentId'),
            AutoRoute(
                page: VersionScreenRoute.page,
                path: ':documentTypeSlug/:documentId/:versionId'),
          ],
        ),
      ];
}

/// Redirects the root path to the first document type slug.
class DefaultDocTypeGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final config = GetIt.I<StudioConfig>();
    if (config.documentTypes.isNotEmpty) {
      resolver.redirectUntil(
        DocumentTypeScreenRoute(
            documentTypeSlug: config.documentTypes.first.name),
      );
    } else {
      resolver.next(true);
    }
  }
}
