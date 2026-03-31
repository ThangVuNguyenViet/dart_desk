import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

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
      children: [
        AutoRoute(page: MediaScreenRoute.page, path: 'media'),
        CustomRoute(
          page: DocumentTypeScreenRoute.page,
          path: ':documentTypeSlug',
        ),
        CustomRoute(
          page: DocumentScreenRoute.page,
          path: ':documentTypeSlug/:documentId',
        ),
        CustomRoute(
          page: VersionScreenRoute.page,
          path: ':documentTypeSlug/:documentId/:versionId',
        ),
      ],
    ),
  ];
}
