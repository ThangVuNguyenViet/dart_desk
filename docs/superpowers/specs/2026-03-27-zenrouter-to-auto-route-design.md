# Migration: zenrouter → auto_route

**Date:** 2026-03-27
**Scope:** `packages/dart_desk`
**Approach:** Big bang — single pass, all changes in one PR

---

## Background

`dart_desk` is a Flutter library package. The CMS studio is exposed to consumers via `CmsStudioApp`, which wraps the entire routing setup internally. Consumers never touch the router directly.

The current router (`zenrouter ^2.0.3`) uses a `StudioCoordinator` that serves two roles: routing/navigation and carrying config data (`documentTypes`, `dataSource`, `decorations`, `onSignOut`) through the widget tree. This migration replaces zenrouter with `auto_route ^11.1.0`, eliminates the coordinator, and decomposes the monolithic `CmsStudio` widget into proper leaf screens.

---

## Architecture

### What goes away

| Old | Reason |
|---|---|
| `StudioCoordinator` | Split into `StudioRouter` (routing) + `StudioConfig` in GetIt (data) |
| `StudioRoute`, `StudioLayout` | Replaced by `@RoutePage()` screens |
| `DocumentTypeRoute`, `DocumentRoute`, `VersionRoute`, `MediaRoute` | Replaced by annotated screens |
| `CmsStudio` | Decomposed into individual leaf screens |
| `zenrouter` dep | Removed |

### What replaces them

| Old | New |
|---|---|
| `StudioCoordinator` (routing) | `StudioRouter extends RootStackRouter` |
| `StudioCoordinator` (config data) | `StudioConfig` registered in GetIt |
| `StudioLayout` + `StudioShell` | `StudioShellScreen` (`@RoutePage()`) |
| Leaf route classes | `@RoutePage()` screen widgets |
| `studioStack.addListener(...)` | `context.router.addListener(...)` in shell |
| `coordinator.pushOrMoveToTop(...)` | `context.router.navigate(...)` |
| `coordinator.studioStack.reset()` | `context.router.navigate(DocumentTypeScreenRoute(...))` |

---

## Route Tree

```dart
@AutoRouterConfig()
class StudioRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: StudioShellScreenRoute.page,
      path: '/',
      guards: [DefaultDocTypeGuard()],
      children: [
        AutoRoute(page: MediaScreenRoute.page,        path: 'media'),
        AutoRoute(page: DocumentTypeScreenRoute.page, path: ':documentTypeSlug'),
        AutoRoute(page: DocumentScreenRoute.page,     path: ':documentTypeSlug/:documentId'),
        AutoRoute(page: VersionScreenRoute.page,      path: ':documentTypeSlug/:documentId/:versionId'),
      ],
    ),
  ];
}
```

### URL structure (unchanged)

| Path | Screen |
|---|---|
| `/media` | `MediaScreen` |
| `/:documentTypeSlug` | `DocumentTypeScreen` |
| `/:documentTypeSlug/:documentId` | `DocumentScreen` |
| `/:documentTypeSlug/:documentId/:versionId` | `VersionScreen` |

### Default route guard

`documentTypes` is always synchronously available at construction time. `DefaultDocTypeGuard` redirects `/` to the first document type:

```dart
class DefaultDocTypeGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final config = GetIt.I<StudioConfig>();
    if (config.documentTypes.isNotEmpty) {
      resolver.redirectUntil(
        DocumentTypeScreenRoute(documentTypeSlug: config.documentTypes.first.name),
      );
    } else {
      resolver.next(true); // shell renders empty state
    }
  }
}
```

---

## StudioConfig

Replaces the config-carrying role of `StudioCoordinator`. Plain data class, registered as a GetIt singleton by `CmsStudioApp.initState`:

```dart
class StudioConfig {
  final List<DocumentType> documentTypes;
  final DataSource dataSource;
  final List<DocumentTypeDecoration> documentTypeDecorations;
  final VoidCallback? onSignOut;

  const StudioConfig({
    required this.documentTypes,
    required this.dataSource,
    this.documentTypeDecorations = const [],
    this.onSignOut,
  });
}
```

`CmsStudioApp.initState`:
```dart
@override
void initState() {
  super.initState();
  GetIt.I.registerSingleton(StudioConfig(
    documentTypes: widget.documentTypes,
    dataSource: widget.dataSource,
    documentTypeDecorations: widget.documentTypeDecorations,
    onSignOut: widget.onSignOut,
  ));
  _router = StudioRouter();
}
```

`CmsStudioApp.build` wires `ShadApp.router` as before:
```dart
ShadApp.router(
  theme: resolvedTheme,
  routeInformationParser: _router.defaultRouteParser(),
  routerDelegate: _router.delegate(),
)
```

---

## Shell Screen + Reactive Param Sync

`StudioShellScreen` replaces both `StudioLayout` and `StudioShell`. It owns the persistent chrome (topbar + sidebar) and renders child routes via `AutoRouter()`.

`StackRouter` is a `Listenable`. The shell uses `context.router.addListener` — auto_route's native interface — to write route params directly to `CmsViewModel` signals. No wrapper signal, no `currentRoute` object.

```dart
@RoutePage()
class StudioShellScreen extends StatefulWidget {
  const StudioShellScreen({super.key});
}

class _StudioShellScreenState extends State<StudioShellScreen> {
  late final StackRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = context.router;
    _router.addListener(_onRouteChanged);
    _onRouteChanged();
  }

  @override
  void dispose() {
    _router.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    final params = _router.current.params;
    final vm = GetIt.I<CmsViewModel>();
    batch(() {
      vm.currentDocumentTypeSlug.value = params.optString('documentTypeSlug');
      vm.currentDocumentId.value       = params.optString('documentId');
      vm.currentVersionId.value        = params.optString('versionId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = GetIt.I<StudioConfig>();
    return StudioProvider(
      dataSource: config.dataSource,
      documentTypes: config.documentTypes,
      child: Column(
        children: [
          const CmsTopBar(),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                CmsDocumentTypeSidebar(
                  documentTypeDecorations: config.documentTypeDecorations,
                ),
                Expanded(child: AutoRouter()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Leaf Screen Decomposition

`CmsStudio` is deleted. Each leaf screen renders its own content area (the region to the right of the sidebar inside `AutoRouter()`).

### MediaScreen
```dart
@RoutePage()
class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final config = GetIt.I<StudioConfig>();
    return MediaBrowser(
      dataSource: config.dataSource,
      mode: MediaBrowserMode.standalone,
    );
  }
}
```

### DocumentTypeScreen
Renders the collapsible document list. No document selected — editor panel shows empty state.

```dart
@RoutePage()
class DocumentTypeScreen extends StatelessWidget {
  const DocumentTypeScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
  });

  final String documentTypeSlug;

  @override
  Widget build(BuildContext context) {
    // Document list + empty editor state
  }
}
```

### DocumentScreen
Renders document list + editor/preview split with the selected document loaded.

```dart
@RoutePage()
class DocumentScreen extends StatelessWidget {
  const DocumentScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
    @PathParam('documentId') required this.documentId,
  });

  final String documentTypeSlug;
  final String documentId;
}
```

### VersionScreen
Same layout as `DocumentScreen` but locked to a specific version.

```dart
@RoutePage()
class VersionScreen extends StatelessWidget {
  const VersionScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
    @PathParam('documentId') required this.documentId,
    @PathParam('versionId') required this.versionId,
  });

  final String documentTypeSlug;
  final String documentId;
  final String versionId;
}
```

---

## CmsViewModel Changes

`setRouteParams()` is removed. The shell's `_onRouteChanged` writes directly to existing param signals. No new signals needed — `isMediaRoute` is no longer required because `MediaScreen` renders `MediaBrowser` directly; no external switch checks route type.

```dart
// existing signals — now written by shell listener, not setRouteParams()
// currentDocumentTypeSlug, currentDocumentId, currentVersionId
```

---

## Navigation Call Sites

| Old | New |
|---|---|
| `coordinator.pushOrMoveToTop(DocumentTypeRoute(slug))` | `context.router.navigate(DocumentTypeScreenRoute(documentTypeSlug: slug))` |
| `coordinator.pushOrMoveToTop(DocumentRoute(slug, docId))` | `context.router.navigate(DocumentScreenRoute(documentTypeSlug: slug, documentId: docId))` |
| `coordinator.pushOrMoveToTop(MediaRoute())` | `context.router.navigate(const MediaScreenRoute())` |
| `coordinator.studioStack.reset()` | `context.router.navigate(DocumentTypeScreenRoute(documentTypeSlug: slug))` |

From non-widget code (e.g. ViewModels): `GetIt.I<StudioRouter>().navigate(...)`.

---

## File Changes Summary

### Delete
```
lib/src/studio/routes/studio_coordinator.dart
lib/src/studio/routes/studio_route.dart
lib/src/studio/routes/studio_layout.dart
lib/src/studio/routes/document_type_route.dart
lib/src/studio/routes/document_route.dart
lib/src/studio/routes/media_route.dart
lib/src/studio/routes/version_route.dart
lib/src/studio/screens/cms_studio.dart
```

### Create
```
lib/src/studio/router/studio_router.dart       (AppRouter + DefaultDocTypeGuard)
lib/src/studio/router/studio_router.gr.dart    (generated by build_runner)
lib/src/studio/config/studio_config.dart
lib/src/studio/screens/studio_shell_screen.dart
lib/src/studio/screens/document_type_screen.dart
lib/src/studio/screens/document_screen.dart
lib/src/studio/screens/version_screen.dart
lib/src/studio/screens/media_screen.dart
```

### Modify
```
packages/dart_desk/pubspec.yaml
  - remove: zenrouter: ^2.0.3
  + add:    auto_route: ^11.1.0
  + add:    auto_route_generator: ^10.5.0  (dev)

lib/src/studio/cms_studio_app.dart
  - coordinator → StudioRouter + StudioConfig registered in GetIt

lib/src/studio/core/view_models/cms_view_model.dart
  - remove setRouteParams()
  - add isMediaRoute signal

lib/src/studio/components/navigation/cms_document_type_sidebar.dart
  - remove coordinator param
  - navigation via context.router.navigate(...)
```

---

## Build Step

After all code changes:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Generates `studio_router.gr.dart` as a `part` file of `studio_router.dart`.
