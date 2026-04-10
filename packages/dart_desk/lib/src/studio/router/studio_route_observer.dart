import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';

import '../core/view_models/cms_view_model.dart';
import 'studio_router.dart';

/// Observes all navigation events in the Studio router and syncs the
/// [CmsViewModel] signals (selectedDocumentId, currentDocumentTypeSlug, etc.)
/// from [StudioRouter.topRoute.params].
///
/// Uses [NavigationHistory.addListener] as the primary mechanism because
/// Flutter's declarative Navigator.pages API does NOT fire didPush/didReplace
/// for same-route-type navigations where only path params differ (e.g.
/// /:documentTypeSlug = tip-screen → login-screen). navigationHistory fires
/// on every URL state change, including param-only changes.
///
/// The NavigatorObserver overrides are kept as a secondary mechanism for
/// cross-type navigations (harmless redundancy).
class StudioRouteObserver extends AutoRouterObserver {
  final StudioRouter router;

  StudioRouteObserver(this.router) {
    router.navigationHistory.addListener(_syncSignals);
  }

  void dispose() {
    router.navigationHistory.removeListener(_syncSignals);
  }

  void _syncSignals() {
    if (!GetIt.I.isRegistered<CmsViewModel>()) return;
    final params = router.topRoute.params;
    final vm = GetIt.I<CmsViewModel>();
    final docId = params.optString('documentId');
    final versionId = params.optString('versionId');
    final docTypeSlug = params.optString('documentTypeSlug');
    // Defer signal updates to avoid triggering rebuilds mid-navigation,
    // which causes _InactiveElements.remove assertion failures.
    Future.microtask(() {
      batch(() {
        vm.currentDocumentTypeSlug.value = docTypeSlug;
        vm.currentDocumentId.value = docId;
        vm.selectedDocumentId.value =
            docId != null ? int.tryParse(docId) : null;
        vm.currentVersionId.value = versionId;
        vm.selectedVersionId.value =
            versionId != null ? int.tryParse(versionId) : null;
      });
    });
  }

  @override
  void didPush(Route route, Route? previousRoute) => _syncSignals();

  @override
  void didPop(Route route, Route? previousRoute) => _syncSignals();

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _syncSignals();

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) =>
      _syncSignals();

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) =>
      _syncSignals();
}
