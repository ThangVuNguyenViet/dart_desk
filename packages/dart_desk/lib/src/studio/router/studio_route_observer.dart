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
/// Registered on [StudioRouter.delegate] so it fires at the Navigator level,
/// bypassing the inner-router notifyListeners limitation of [StackRouter.addListener].
class StudioRouteObserver extends AutoRouterObserver {
  final StudioRouter router;

  StudioRouteObserver(this.router);

  void _syncSignals() {
    if (!GetIt.I.isRegistered<CmsViewModel>()) return;
    final params = router.topRoute.params;
    final vm = GetIt.I<CmsViewModel>();
    final docId = params.optString('documentId');
    final versionId = params.optString('versionId');
    final docTypeSlug = params.optString('documentTypeSlug');
    batch(() {
      vm.currentDocumentTypeSlug.value = docTypeSlug;
      vm.currentDocumentId.value = docId;
      vm.selectedDocumentId.value =
          docId != null ? int.tryParse(docId) : null;
      vm.currentVersionId.value = versionId;
      vm.selectedVersionId.value =
          versionId != null ? int.tryParse(versionId) : null;
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
