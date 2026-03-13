# CMS Studio Architecture Alignment Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the CMS studio to use ZenRouter URL-driven navigation, dark theme, and a top bar layout matching the manage app's architecture.

**Architecture:** ZenRouter `Coordinator` drives navigation via URL segments (`/{documentTypeSlug}/{documentId}/{versionId}`). `FlutterCmsAuth` wraps the entire router as an auth gate. The 4-panel resizable layout stays but reads route params instead of selection signals. Dark theme via `ShadSlateColorScheme.dark()`.

**Tech Stack:** Flutter, ZenRouter, Signals, shadcn_ui, disco, flutter_resizable_container

**Spec:** `docs/superpowers/specs/2026-03-14-cms-studio-architecture-alignment-design.md`

---

## File Structure

### New Files (in `packages/flutter_cms/lib/src/studio/routes/`)

| File | Responsibility |
|---|---|
| `studio_route.dart` | Base `StudioRoute` class extending `RouteTarget` with `RouteUnique` |
| `studio_coordinator.dart` | `Coordinator<StudioRoute>` — route parsing, layout definition, navigation stacks |
| `studio_layout.dart` | `StudioLayout` route + `StudioShell` widget — top bar + 4-panel content |
| `document_type_route.dart` | Route for `/{documentTypeSlug}` |
| `document_route.dart` | Route for `/{documentTypeSlug}/{documentId}` |
| `version_route.dart` | Route for `/{documentTypeSlug}/{documentId}/{versionId}` |

### Modified Files

| File | Changes |
|---|---|
| `packages/flutter_cms/pubspec.yaml` | Add `zenrouter` dependency |
| `packages/flutter_cms/lib/studio.dart` | Export new route files |
| `packages/flutter_cms/lib/src/studio/cms_studio_app.dart` | Accept coordinator, use `StudioProvider` wrapping route child |
| `packages/flutter_cms/lib/src/studio/screens/cms_studio.dart` | Read route params from coordinator instead of selection signals |
| `packages/flutter_cms/lib/src/studio/core/view_models/cms_view_model.dart` | Replace `selectX()` with `setRouteParams()`, add `currentDocumentType` computed |
| `packages/flutter_cms/lib/src/studio/components/navigation/cms_document_type_sidebar.dart` | Navigate via coordinator instead of `viewModel.selectDocumentType()` |
| `packages/flutter_cms/lib/src/studio/components/common/cms_document_type_item.dart` | Accept `onTap` callback, remove direct viewModel dependency |
| `packages/flutter_cms/lib/src/studio/theme/theme.dart` | Make dark theme the default export |
| `flutter_cms_be/flutter_cms_be_client/lib/src/flutter_cms_auth.dart` | Remove `ShadTheme(data: ShadThemeData())` wrapper in `_buildSignInScreen()` |
| `examples/cms_app/lib/main.dart` | Use `ShadApp.router`, `StudioCoordinator`, dark theme, `FlutterCmsAuth` wrapping router |

---

## Chunk 1: Foundation — Dependencies, Routes, and Coordinator

### Task 1: Add ZenRouter dependency

**Files:**
- Modify: `packages/flutter_cms/pubspec.yaml`

- [ ] **Step 1: Add zenrouter to pubspec.yaml**

In `packages/flutter_cms/pubspec.yaml`, add under `dependencies:`:

```yaml
  zenrouter: ^0.1.0
```

- [ ] **Step 2: Run pub get**

```bash
cd /Users/vietthangvunguyen/Workspace/flutter_cms/packages/flutter_cms && flutter pub get
```

Expected: resolves successfully with zenrouter added.

- [ ] **Step 3: Commit**

```bash
git add packages/flutter_cms/pubspec.yaml packages/flutter_cms/pubspec.lock
git commit -m "chore: add zenrouter dependency to flutter_cms package"
```

---

### Task 2: Create base StudioRoute class

**Files:**
- Create: `packages/flutter_cms/lib/src/studio/routes/studio_route.dart`

Reference: `flutter_cms_be/flutter_cms_manage/lib/src/routes/manage_route.dart`

- [ ] **Step 1: Create studio_route.dart**

```dart
import 'package:zenrouter/zenrouter.dart';

abstract class StudioRoute extends RouteTarget with RouteUnique {}
```

- [ ] **Step 2: Verify file compiles**

```bash
cd /Users/vietthangvunguyen/Workspace/flutter_cms/packages/flutter_cms && dart analyze lib/src/studio/routes/studio_route.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/routes/studio_route.dart
git commit -m "feat: add StudioRoute base class for ZenRouter integration"
```

---

### Task 3: Create route classes

**Files:**
- Create: `packages/flutter_cms/lib/src/studio/routes/document_type_route.dart`
- Create: `packages/flutter_cms/lib/src/studio/routes/document_route.dart`
- Create: `packages/flutter_cms/lib/src/studio/routes/version_route.dart`

Reference: `flutter_cms_be/flutter_cms_manage/lib/src/routes/overview_route.dart` for pattern.

- [ ] **Step 1: Create document_type_route.dart**

```dart
import 'package:flutter/material.dart';

import 'studio_coordinator.dart';
import 'studio_layout.dart';
import 'studio_route.dart';

class DocumentTypeRoute extends StudioRoute {
  final String documentTypeSlug;

  DocumentTypeRoute(this.documentTypeSlug);

  @override
  Type get layout => StudioLayout;

  @override
  Uri toUri() => Uri.parse('/$documentTypeSlug');

  @override
  List<Object?> get props => [documentTypeSlug];

  @override
  Widget build(StudioCoordinator coordinator, BuildContext context) =>
      const SizedBox.shrink(); // Layout handles rendering
}
```

- [ ] **Step 2: Create document_route.dart**

```dart
import 'package:flutter/material.dart';

import 'studio_coordinator.dart';
import 'studio_layout.dart';
import 'studio_route.dart';

class DocumentRoute extends StudioRoute {
  final String documentTypeSlug;
  final String documentId;

  DocumentRoute(this.documentTypeSlug, this.documentId);

  @override
  Type get layout => StudioLayout;

  @override
  Uri toUri() => Uri.parse('/$documentTypeSlug/$documentId');

  @override
  List<Object?> get props => [documentTypeSlug, documentId];

  @override
  Widget build(StudioCoordinator coordinator, BuildContext context) =>
      const SizedBox.shrink(); // Layout handles rendering
}
```

- [ ] **Step 3: Create version_route.dart**

```dart
import 'package:flutter/material.dart';

import 'studio_coordinator.dart';
import 'studio_layout.dart';
import 'studio_route.dart';

class VersionRoute extends StudioRoute {
  final String documentTypeSlug;
  final String documentId;
  final String versionId;

  VersionRoute(this.documentTypeSlug, this.documentId, this.versionId);

  @override
  Type get layout => StudioLayout;

  @override
  Uri toUri() => Uri.parse('/$documentTypeSlug/$documentId/$versionId');

  @override
  List<Object?> get props => [documentTypeSlug, documentId, versionId];

  @override
  Widget build(StudioCoordinator coordinator, BuildContext context) =>
      const SizedBox.shrink(); // Layout handles rendering
}
```

- [ ] **Step 4: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/routes/document_type_route.dart \
       packages/flutter_cms/lib/src/studio/routes/document_route.dart \
       packages/flutter_cms/lib/src/studio/routes/version_route.dart
git commit -m "feat: add route classes for document type, document, and version"
```

---

### Task 4: Create StudioCoordinator

**Files:**
- Create: `packages/flutter_cms/lib/src/studio/routes/studio_coordinator.dart`

Reference: `flutter_cms_be/flutter_cms_manage/lib/src/routes/manage_coordinator.dart`

- [ ] **Step 1: Create studio_coordinator.dart**

```dart
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:zenrouter/zenrouter.dart';

import '../../../data/cms_data_source.dart';
import '../components/common/cms_document_type_decoration.dart';
import 'studio_route.dart';
import 'studio_layout.dart';
import 'document_type_route.dart';
import 'document_route.dart';
import 'version_route.dart';

class StudioCoordinator extends Coordinator<StudioRoute> {
  /// The registered document types available in the studio.
  /// Note: CmsDocumentType is generic (`CmsDocumentType<T extends Serializable>`),
  /// but bare `CmsDocumentType` is used here (equivalent to `CmsDocumentType<dynamic>`),
  /// which matches how CmsDocumentTypeDecoration and other consumers use it.
  final List<CmsDocumentType> documentTypes;

  /// The data source for the CMS studio.
  final CmsDataSource dataSource;

  /// Decorations for document types in the sidebar.
  final List<CmsDocumentTypeDecoration> documentTypeDecorations;

  /// The slug of the first document type, used for root redirect.
  String get defaultDocumentTypeSlug =>
      documentTypes.isNotEmpty ? documentTypes.first.name : '';

  late final studioStack = NavigationPath<StudioRoute>('studio');

  StudioCoordinator({
    required this.documentTypes,
    required this.dataSource,
    this.documentTypeDecorations = const [],
  });

  @override
  List<StackPath> get paths => [...super.paths, studioStack];

  @override
  void defineLayout() {
    RouteLayout.defineLayout(StudioLayout, StudioLayout.new);
  }

  // -- Current route params (read by the layout/panels) --

  String? get currentDocumentTypeSlug {
    final route = studioStack.current;
    if (route is VersionRoute) return route.documentTypeSlug;
    if (route is DocumentRoute) return route.documentTypeSlug;
    if (route is DocumentTypeRoute) return route.documentTypeSlug;
    return null;
  }

  String? get currentDocumentId {
    final route = studioStack.current;
    if (route is VersionRoute) return route.documentId;
    if (route is DocumentRoute) return route.documentId;
    return null;
  }

  String? get currentVersionId {
    final route = studioStack.current;
    if (route is VersionRoute) return route.versionId;
    return null;
  }

  @override
  StudioRoute parseRouteFromUri(Uri uri) {
    final segments = uri.pathSegments;

    // Root → redirect to first document type
    if (segments.isEmpty) {
      return DocumentTypeRoute(defaultDocumentTypeSlug);
    }

    return switch (segments) {
      [final slug] => DocumentTypeRoute(slug),
      [final slug, final docId] => DocumentRoute(slug, docId),
      [final slug, final docId, final versionId] =>
        VersionRoute(slug, docId, versionId),
      _ => DocumentTypeRoute(defaultDocumentTypeSlug),
    };
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
cd /Users/vietthangvunguyen/Workspace/flutter_cms/packages/flutter_cms && dart analyze lib/src/studio/routes/studio_coordinator.dart
```

Note: This will show an error for `StudioLayout` import since we haven't created it yet. That's expected — we create it in the next task.

- [ ] **Step 3: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/routes/studio_coordinator.dart
git commit -m "feat: add StudioCoordinator with URL-based route parsing"
```

---

## Chunk 2: Layout and Theme

### Task 5: Create StudioLayout with top bar

**Files:**
- Create: `packages/flutter_cms/lib/src/studio/routes/studio_layout.dart`

Reference: `flutter_cms_be/flutter_cms_manage/lib/src/routes/manage_layout.dart`

- [ ] **Step 1: Create studio_layout.dart**

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zenrouter/zenrouter.dart';

import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';

import '../cms_studio_app.dart';
import '../components/common/default_cms_header.dart';
import '../components/navigation/cms_document_type_sidebar.dart';
import '../providers/studio_provider.dart';
import 'studio_coordinator.dart';
import 'studio_route.dart';

class StudioLayout extends StudioRoute with RouteLayout<StudioRoute> {
  @override
  NavigationPath<StudioRoute> resolvePath(StudioCoordinator coordinator) =>
      coordinator.studioStack;

  @override
  Widget build(StudioCoordinator coordinator, BuildContext context) {
    return StudioShell(
      coordinator: coordinator,
      child: CmsStudioApp(
        coordinator: coordinator,
        sidebar: CmsDocumentTypeSidebar(
          documentTypeDecorations: coordinator.documentTypeDecorations,
          coordinator: coordinator,
        ),
        dataSource: coordinator.dataSource,
        documentTypes: coordinator.documentTypes,
      ),
    );
  }
}

/// The top-level shell for the CMS studio.
/// Renders the top bar and the CmsStudioApp (4-panel layout) below it.
/// This widget creates the StudioProvider and CmsStudio internally,
/// since it has access to the coordinator and route child.
class StudioShell extends StatefulWidget {
  final StudioCoordinator coordinator;
  final Widget child;

  const StudioShell({
    super.key,
    required this.coordinator,
    required this.child,
  });

  @override
  State<StudioShell> createState() => _StudioShellState();
}

class _StudioShellState extends State<StudioShell> {
  @override
  void initState() {
    super.initState();
    widget.coordinator.studioStack.addListener(_syncRouteParams);
    // Initial sync
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncRouteParams());
  }

  @override
  void dispose() {
    widget.coordinator.studioStack.removeListener(_syncRouteParams);
    super.dispose();
  }

  void _syncRouteParams() {
    if (!mounted) return;
    final viewModel = cmsViewModelProvider.of(context);
    viewModel.setRouteParams(
      documentTypeSlug: widget.coordinator.currentDocumentTypeSlug,
      documentId: widget.coordinator.currentDocumentId,
      versionId: widget.coordinator.currentVersionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          _TopBar(coordinator: widget.coordinator),
          const Divider(height: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final StudioCoordinator coordinator;
  const _TopBar({required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    // Read header config from the nearest DefaultCmsHeaderConfig if available
    final headerConfig = DefaultCmsHeaderConfig.of(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          if (headerConfig?.icon != null) ...[
            Icon(headerConfig!.icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Text(
            headerConfig?.title ?? 'CMS Studio',
            style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
          ),
          if (headerConfig?.subtitle != null) ...[
            const SizedBox(width: 8),
            Text(
              headerConfig!.subtitle!,
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
          const Spacer(),
          if (headerConfig?.dashboardUrl != null)
            ShadButton.ghost(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Open Dashboard'),
                  const SizedBox(width: 4),
                  Icon(LucideIcons.externalLink, size: 14),
                ],
              ),
              onPressed: () {
                headerConfig?.onDashboardPressed?.call();
              },
            ),
          const SizedBox(width: 8),
          ShadButton.ghost(
            onPressed: () {
              context.signOut();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text('U', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Icon(LucideIcons.logOut, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Add `DefaultCmsHeaderConfig` InheritedWidget to `default_cms_header.dart`**

Modify `packages/flutter_cms/lib/src/studio/components/common/default_cms_header.dart` — add a config provider that the top bar can read:

```dart
/// InheritedWidget that provides header config data to the studio layout.
/// Place this above the router so the top bar can read branding info.
class DefaultCmsHeaderConfig extends InheritedWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? dashboardUrl;
  final VoidCallback? onDashboardPressed;

  const DefaultCmsHeaderConfig({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.dashboardUrl,
    this.onDashboardPressed,
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
        dashboardUrl != oldWidget.dashboardUrl ||
        onDashboardPressed != oldWidget.onDashboardPressed;
  }
}
```

- [ ] **Step 3: Verify compile**

```bash
cd /Users/vietthangvunguyen/Workspace/flutter_cms/packages/flutter_cms && dart analyze lib/src/studio/routes/studio_layout.dart
```

- [ ] **Step 4: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/routes/studio_layout.dart \
       packages/flutter_cms/lib/src/studio/components/common/default_cms_header.dart
git commit -m "feat: add StudioLayout with top bar and DefaultCmsHeaderConfig"
```

---

### Task 6: Switch to dark theme

**Files:**
- Modify: `packages/flutter_cms/lib/src/studio/theme/theme.dart`
- Modify: `flutter_cms_be/flutter_cms_be_client/lib/src/flutter_cms_auth.dart`

- [ ] **Step 1: Update theme.dart to make dark the default**

Replace the entire file content of `packages/flutter_cms/lib/src/studio/theme/theme.dart`:

```dart
/// Flutter CMS Studio Theme
///
/// Provides theme configuration for the CMS studio interface
library;

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Default theme for the CMS studio (dark, matching manage app)
ShadThemeData get cmsStudioTheme => ShadThemeData(
  brightness: Brightness.dark,
  colorScheme: const ShadSlateColorScheme.dark(),
);

/// Light theme for the CMS studio (kept for optional use)
ShadThemeData get cmsStudioLightTheme => ShadThemeData(
  brightness: Brightness.light,
  colorScheme: const ShadSlateColorScheme.light(),
);
```

- [ ] **Step 2: Fix FlutterCmsAuth login screen — remove light theme override**

In `flutter_cms_be/flutter_cms_be_client/lib/src/flutter_cms_auth.dart`, in the `_buildSignInScreen()` method (line 171-286), remove the `ShadTheme(data: ShadThemeData(), ...)` wrapper. Also update hardcoded `Colors.grey[600]` and `Colors.red[...]` to use theme tokens.

Replace `_buildSignInScreen()`:

```dart
  Widget _buildSignInScreen() {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Builder(
              builder: (context) {
                final theme = ShadTheme.of(context);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.logo != null) ...[
                      Center(child: widget.logo!),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      widget.title,
                      style: theme.textTheme.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (widget.subtitle != null) ...[
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.muted,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      const SizedBox(height: 32),
                    ],
                    ShadCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign in to continue',
                            style: theme.textTheme.large.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (_errorMessage != null) ...[
                            ShadAlert.destructive(
                              title: const Text('Error'),
                              description: Text(_errorMessage!),
                            ),
                            const SizedBox(height: 16),
                          ],
                          GoogleSignInWidget(
                            client: _client,
                            scopes: const [],
                            onAuthenticated: () {
                              if (mounted) setState(() {});
                            },
                            onError: (error) {
                              setState(() {
                                _errorMessage =
                                    'Google Sign-In failed. Please try again.';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'By signing in, you agree to our Terms of Service and Privacy Policy.',
                      style: theme.textTheme.muted.copyWith(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
```

- [ ] **Step 3: Verify both files compile**

```bash
cd /Users/vietthangvunguyen/Workspace/flutter_cms/packages/flutter_cms && dart analyze lib/src/studio/theme/theme.dart
cd /Users/vietthangvunguyen/Workspace/flutter_cms_be/flutter_cms_be_client && dart analyze lib/src/flutter_cms_auth.dart
```

- [ ] **Step 4: Commit**

This touches two separate git repos. Commit each change in its own repo:

```bash
# flutter_cms repo — theme change
cd /Users/vietthangvunguyen/Workspace/flutter_cms
git add packages/flutter_cms/lib/src/studio/theme/theme.dart
git commit -m "feat: switch CMS studio to dark theme"
```

```bash
# flutter_cms_be repo — auth screen fix (this file is in the flutter_cms_be repo)
cd /Users/vietthangvunguyen/Workspace/flutter_cms_be && git add flutter_cms_be_client/lib/src/flutter_cms_auth.dart && git commit -m 'fix: remove light theme override from CMS auth login screen'
```

**Note:** The `flutter_cms_auth.dart` file is in the `flutter_cms_be` repo, not `flutter_cms`. It must be committed separately in that repo as shown above.

---

## Chunk 3: ViewModel Refactor — Route Params Replace Selection Signals

### Task 7: Refactor CmsViewModel to use route params

**Files:**
- Modify: `packages/flutter_cms/lib/src/studio/core/view_models/cms_view_model.dart`

- [ ] **Step 1: Replace selection signals with route param signals**

Replace the Selection Signals section and add the new route param approach. The key changes:

1. Remove `selectedDocumentType` signal
2. Add `currentDocumentTypeSlug`, `currentDocumentId`, `currentVersionId` signals
3. Add `documentTypes` list (injected from coordinator)
4. Add `currentDocumentType` computed signal
5. Replace `selectDocumentType()`, `selectDocument()`, `selectVersion()` with `setRouteParams()`
6. Update `queryParams` to use `currentDocumentType`
7. Update `createDocument()` and `updateDocumentData()` to use `currentDocumentType`
8. Remove `clearSelection()` and `clearVersionSelection()`

Full updated file:

```dart
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:signals/signals_flutter.dart';

import '../../../data/cms_data_source.dart';
import '../../../data/models/cms_document.dart';
import '../../../data/models/document_list.dart';
import '../../../data/models/document_version.dart';
import 'cms_document_view_model.dart';

class CmsViewModel {
  final CmsDataSource dataSource;
  final CmsDocumentViewModel _documentViewModel;

  /// The registered document types (injected from coordinator/app config).
  final List<CmsDocumentType> documentTypes;

  // ============================================================
  // Route Param Signals (set by coordinator via setRouteParams)
  // ============================================================

  final currentDocumentTypeSlug = Signal<String?>(null);
  final currentDocumentId = Signal<String?>(null);
  final currentVersionId = Signal<String?>(null);

  /// Computed: resolves the slug to a CmsDocumentType object.
  late final currentDocumentType = Computed<CmsDocumentType?>(() {
    final slug = currentDocumentTypeSlug.value;
    if (slug == null) return null;
    try {
      return documentTypes.firstWhere((dt) => dt.name == slug);
    } catch (_) {
      return null;
    }
  });

  // ============================================================
  // Pagination & Search Signals
  // ============================================================

  final page = Signal<int>(1);
  final pageSize = Signal<int>(20);
  final searchQuery = Signal<String?>(null);

  // ============================================================
  // Operation State Signals
  // ============================================================

  final isSaving = Signal<bool>(false);

  // ============================================================
  // Computed Signals
  // ============================================================

  late final queryParams = Computed(
    () => _DocumentQueryParams(
      documentType: currentDocumentType.value?.name,
      page: page.value,
      pageSize: pageSize.value,
      search: searchQuery.value,
    ),
  );

  // ============================================================
  // Signal Containers for Dynamic Data Fetching
  // ============================================================

  late final documentsContainer = SignalContainer(
    (_DocumentQueryParams params) =>
        FutureSignal(() => _fetchDocumentsWithParams(params)),
    cache: true,
  );

  late final versionsContainer = SignalContainer(
    (int documentId) =>
        FutureSignal(() => dataSource.getDocumentVersions(documentId)),
    cache: true,
  );

  late final documentDataContainer = SignalContainer(
    (int versionId) =>
        FutureSignal(() => dataSource.getDocumentVersion(versionId)),
    cache: true,
  );

  // ============================================================
  // Constructor
  // ============================================================

  CmsViewModel({
    required this.dataSource,
    required CmsDocumentViewModel documentViewModel,
    required this.documentTypes,
  }) : _documentViewModel = documentViewModel;

  // ============================================================
  // Internal Fetch Methods
  // ============================================================

  Future<DocumentList> _fetchDocumentsWithParams(
    _DocumentQueryParams params,
  ) async {
    final documentType = params.documentType;
    if (documentType == null) return DocumentList.empty();

    final offset = (params.page - 1) * params.pageSize;
    return await dataSource.getDocuments(
      documentType,
      search: params.search,
      limit: params.pageSize,
      offset: offset,
    );
  }

  // ============================================================
  // Route Params (called by coordinator on route change)
  // ============================================================

  /// Called by the coordinator when the URL changes.
  /// Sets all route param signals and updates the document view model.
  void setRouteParams({
    String? documentTypeSlug,
    String? documentId,
    String? versionId,
  }) {
    currentDocumentTypeSlug.value = documentTypeSlug;

    // Update document ID (and document view model)
    final docIdInt = documentId != null ? int.tryParse(documentId) : null;
    if (_documentViewModel.documentId.value != docIdInt) {
      _documentViewModel.documentId.value = docIdInt;
    }
    currentDocumentId.value = documentId;

    // Update version ID
    final versionIdInt = versionId != null ? int.tryParse(versionId) : null;
    currentVersionId.value = versionId;

    // If version ID changed, also set selectedVersionId for containers
    _selectedVersionIdInt.value = versionIdInt;
  }

  /// Internal int version of selectedVersionId for containers.
  final _selectedVersionIdInt = Signal<int?>(null);

  /// Public getter for the int version ID (used by panels).
  int? get selectedVersionIdInt => _selectedVersionIdInt.value;

  // ============================================================
  // Document Operations
  // ============================================================

  Future<CmsDocument?> createDocument(
    String title,
    Map<String, dynamic> data, {
    String? slug,
    bool isDefault = false,
  }) async {
    final docType = currentDocumentType.value;
    if (docType == null) return null;

    isSaving.value = true;
    try {
      final document = await dataSource.createDocument(
        docType.name,
        title,
        data,
        slug: slug,
        isDefault: isDefault,
      );

      _documentViewModel.documentId.value = document.id;

      final versions = await dataSource.getDocumentVersions(document.id!);
      if (versions.versions.isNotEmpty) {
        _selectedVersionIdInt.value = versions.versions.first.id;
      }

      return document;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteDocument(int documentId) async {
    final result = await dataSource.deleteDocument(documentId);
    if (result && _documentViewModel.documentId.value == documentId) {
      _documentViewModel.documentId.value = null;
      _selectedVersionIdInt.value = null;
    }
    return result;
  }

  Future<CmsDocument?> updateDocumentData(Map<String, dynamic> data) async {
    final documentId = _documentViewModel.documentId.value;
    if (documentId == null) return null;

    isSaving.value = true;
    try {
      final result = await dataSource.updateDocumentData(documentId, data);

      final params = _DocumentQueryParams(
        documentType: currentDocumentType.value?.name,
        page: page.value,
        pageSize: pageSize.value,
      );
      documentsContainer(params).reload();

      return result;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // Version Status Operations
  // ============================================================

  Future<DocumentVersion?> publishVersion() async {
    final versionId = _selectedVersionIdInt.value;
    if (versionId == null) return null;

    isSaving.value = true;
    try {
      final result = await dataSource.publishDocumentVersion(versionId);

      final docId = _documentViewModel.documentId.value;
      if (docId != null) {
        versionsContainer(docId).reload();
      }
      documentDataContainer(versionId).reload();

      return result;
    } finally {
      isSaving.value = false;
    }
  }

  Future<DocumentVersion?> archiveVersion() async {
    final versionId = _selectedVersionIdInt.value;
    if (versionId == null) return null;

    isSaving.value = true;
    try {
      final result = await dataSource.archiveDocumentVersion(versionId);

      final docId = _documentViewModel.documentId.value;
      if (docId != null) {
        versionsContainer(docId).reload();
      }
      documentDataContainer(versionId).reload();

      return result;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteVersion(int versionId) async {
    final result = await dataSource.deleteDocumentVersion(versionId);
    if (result) {
      if (_selectedVersionIdInt.value == versionId) {
        _selectedVersionIdInt.value = null;
      }

      final docId = _documentViewModel.documentId.value;
      if (docId != null) {
        versionsContainer(docId).reload();
      }
    }
    return result;
  }

  // ============================================================
  // Pagination & Search
  // ============================================================

  void setSearchQuery(String? query) {
    searchQuery.value = query;
  }

  void setPage(int value) {
    page.value = value;
  }

  void setPageSize(int value) {
    pageSize.value = value;
  }

  // ============================================================
  // Refresh Methods
  // ============================================================

  void refreshDocuments() {
    final params = queryParams.value;
    if (params.documentType != null) {
      documentsContainer(params).reload();
    }
  }

  void refreshVersions() {
    final docId = _documentViewModel.documentId.value;
    if (docId != null) {
      versionsContainer(docId).reload();
    }
  }

  void refreshSelectedData() {
    final versionId = _selectedVersionIdInt.value;
    if (versionId != null) {
      documentDataContainer(versionId).reload();
    }
  }

  // ============================================================
  // Disposal
  // ============================================================

  void dispose() {
    queryParams.dispose();
    currentDocumentType.dispose();
    currentDocumentTypeSlug.dispose();
    currentDocumentId.dispose();
    currentVersionId.dispose();
    _selectedVersionIdInt.dispose();
    _documentViewModel.dispose();
    page.dispose();
    pageSize.dispose();
    searchQuery.dispose();
    isSaving.dispose();
  }
}

class _DocumentQueryParams {
  final String? documentType;
  final int page;
  final int pageSize;
  final String? search;

  const _DocumentQueryParams({
    this.documentType,
    required this.page,
    required this.pageSize,
    this.search,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DocumentQueryParams &&
          documentType == other.documentType &&
          page == other.page &&
          pageSize == other.pageSize &&
          search == other.search;

  @override
  int get hashCode => Object.hash(documentType, page, pageSize, search);
}
```

- [ ] **Step 2: Update StudioProvider to pass documentTypes**

In `packages/flutter_cms/lib/src/studio/providers/studio_provider.dart`, update to accept and pass `documentTypes`:

```dart
import 'package:disco/disco.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';

import '../../../flutter_cms.dart';
import '../../../studio.dart';
import '../core/view_models/cms_document_view_model.dart';

class StudioProvider extends StatelessWidget {
  const StudioProvider({
    super.key,
    required this.child,
    required this.dataSource,
    required this.documentTypes,
  });

  final Widget child;
  final CmsDataSource dataSource;
  final List<CmsDocumentType> documentTypes;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      providers: [documentViewModelProvider(dataSource)],
      child: ProviderScope(
        providers: [cmsViewModelProvider((dataSource, documentTypes))],
        child: child,
      ),
    );
  }
}

final documentViewModelProvider = Provider.withArgument(
  (context, CmsDataSource dataSource) => CmsDocumentViewModel(dataSource),
);

final cmsViewModelProvider = Provider.withArgument(
  (context, (CmsDataSource, List<CmsDocumentType>) args) => CmsViewModel(
    dataSource: args.$1,
    documentViewModel: documentViewModelProvider.of(context),
    documentTypes: args.$2,
  ),
);
```

**Note:** This is a breaking change to `StudioProvider`'s public API. The only consumer is `CmsStudioApp` which is updated in Task 10.

- [ ] **Step 3: Verify compile**

```bash
cd /Users/vietthangvunguyen/Workspace/flutter_cms/packages/flutter_cms && dart analyze lib/src/studio/core/view_models/cms_view_model.dart lib/src/studio/providers/studio_provider.dart
```

- [ ] **Step 4: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/core/view_models/cms_view_model.dart \
       packages/flutter_cms/lib/src/studio/providers/studio_provider.dart
git commit -m "refactor: replace signal-based navigation with route param signals in CmsViewModel"
```

---

## Chunk 4: Wire Up Panels to Route Params

### Task 8: Update CmsStudio panels to read route params

**Files:**
- Modify: `packages/flutter_cms/lib/src/studio/screens/cms_studio.dart`

- [ ] **Step 1: Refactor CmsStudio to accept coordinator and use route params**

Replace the entire content of `packages/flutter_cms/lib/src/studio/screens/cms_studio.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../providers/studio_provider.dart';
import '../routes/studio_coordinator.dart';
import '../routes/document_route.dart';
import 'document_editor.dart';
import 'document_list.dart';

class CmsStudio extends StatefulWidget {
  final StudioCoordinator coordinator;
  final Widget sidebar;

  const CmsStudio({super.key, required this.coordinator, required this.sidebar});

  @override
  State<CmsStudio> createState() => _CmsStudioState();
}

class _CmsStudioState extends State<CmsStudio> {
  Widget _buildEditor() {
    final theme = ShadTheme.of(context);
    final cmsViewModel = cmsViewModelProvider.of(context);

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.background),
      child: Watch((context) {
        final selectedDocumentType = cmsViewModel.currentDocumentType.value;
        if (selectedDocumentType == null) {
          return _buildEmptyState(
            icon: LucideIcons.pencil,
            title: 'Document Editor',
            description:
                'Select a document type from the sidebar to start editing',
          );
        }

        // Build document editor with compact spacing for web
        return CmsDocumentEditor(
          fields: selectedDocumentType.fields,
          title: selectedDocumentType.title,
        );
      }),
    );
  }

  Widget _buildContentPreview() {
    final theme = ShadTheme.of(context);
    final viewModel = cmsViewModelProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(left: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Watch((context) {
        final selectedDocument = viewModel.currentDocumentType.value;
        if (selectedDocument == null) {
          return _buildEmptyState(
            icon: LucideIcons.eye,
            title: 'Content Preview',
            description:
                'Select a document type from the sidebar to see preview',
          );
        }

        // Use the documentDataContainer for preview
        final versionId = viewModel.selectedVersionIdInt;
        if (versionId == null) {
          return _buildEmptyState(
            icon: LucideIcons.fileText,
            title: 'Content Preview',
            description: 'No version selected',
          );
        }

        final versionState = viewModel.documentDataContainer(versionId).value;

        return versionState.map<Widget>(
          loading: () => _buildEmptyState(
            icon: LucideIcons.fileText,
            title: 'Content Preview',
            description: 'Loading document...',
            showProgress: true,
          ),
          error: (error, stackTrace) => _buildEmptyState(
            icon: LucideIcons.alertCircle,
            title: 'Error',
            description: 'Failed to load document: $error',
          ),
          data: (versionData) {
            if (versionData == null || versionData.data == null) {
              return _buildEmptyState(
                icon: LucideIcons.fileText,
                title: 'Content Preview',
                description:
                    'Start editing your document to see the preview here',
                showProgress: false,
              );
            }

            // Wrap preview content with compact padding for web
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: selectedDocument.builder(versionData.data!),
            );
          },
        );
      }),
    );
  }

  Widget _buildDocumentsList() {
    final theme = ShadTheme.of(context);
    final viewModel = cmsViewModelProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(right: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Watch((context) {
        final selectedDocument = viewModel.currentDocumentType.value;

        if (selectedDocument == null) {
          return _buildEmptyState(
            icon: LucideIcons.folderOpen,
            title: 'Documents',
            description: 'Select a document type to see available documents',
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: CmsDocumentListView(
            selectedDocumentType: selectedDocument,
            icon: LucideIcons.file,
            onOpenDocument: (documentId) {
              final slug = viewModel.currentDocumentTypeSlug.value ?? '';
              widget.coordinator.push(DocumentRoute(slug, documentId));
            },
          ),
        );
      }),
    );
  }

  Widget _buildSidebar() {
    final theme = ShadTheme.of(context);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        border: Border(right: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: widget.sidebar,
      ),
    );
  }

  /// Helper method to build consistent empty states
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    bool showProgress = false,
  }) {
    final theme = ShadTheme.of(context);

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: ShadCard(
          width: 280,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 24, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.large.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.muted.copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                if (showProgress) ...[
                  const SizedBox(height: 12),
                  const ShadProgress(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
        ),
        child: ResizableContainer(
          direction: Axis.horizontal,
          children: [
            // Sidebar (fixed, non-resizable)
            ResizableChild(
              size: ResizableSize.ratio(0.2),
              child: _buildSidebar(),
            ),

            // Documents list panel (resizable)
            ResizableChild(
              size: ResizableSize.ratio(0.2),
              child: _buildDocumentsList(),
            ),

            // Content preview panel (resizable)
            ResizableChild(
              size: ResizableSize.ratio(0.4),
              child: _buildContentPreview(),
            ),

            // Document editor panel (resizable)
            ResizableChild(
              size: ResizableSize.ratio(0.2),
              child: _buildEditor(),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify compile**

```bash
cd /Users/vietthangvunguyen/Workspace/flutter_cms/packages/flutter_cms && dart analyze lib/src/studio/screens/cms_studio.dart
```

- [ ] **Step 3: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/screens/cms_studio.dart
git commit -m "refactor: update CMS studio panels to read from route params"
```

---

### Task 9: Update sidebar navigation to use coordinator

**Files:**
- Modify: `packages/flutter_cms/lib/src/studio/components/navigation/cms_document_type_sidebar.dart`
- Modify: `packages/flutter_cms/lib/src/studio/components/common/cms_document_type_item.dart`

- [ ] **Step 1: Update CmsDocumentTypeSidebar**

Remove `initState` auto-selection (coordinator handles initial route). Read `currentDocumentTypeSlug` from viewModel for active state. Pass `onTap` to items that navigates via coordinator.

```dart
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../providers/studio_provider.dart';
import '../../routes/document_type_route.dart';
import '../../routes/studio_coordinator.dart';
import '../common/cms_document_type_decoration.dart';
import '../common/cms_document_type_item.dart';

class CmsDocumentTypeSidebar extends StatelessWidget {
  final List<CmsDocumentTypeDecoration> documentTypeDecorations;
  final StudioCoordinator coordinator;
  final EdgeInsets? padding;
  final Widget? header;
  final Widget? footer;

  const CmsDocumentTypeSidebar({
    super.key,
    required this.documentTypeDecorations,
    required this.coordinator,
    this.padding,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = cmsViewModelProvider.of(context);

    return Watch((context) {
      final currentSlug = viewModel.currentDocumentTypeSlug.value;
      return Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: ListView(
              padding: padding ?? const EdgeInsets.all(8),
              children: [
                ...documentTypeDecorations.map((decoration) {
                  final isSelected =
                      currentSlug == decoration.documentType.name;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: CmsDocumentTypeItem(
                      documentType: decoration.documentType,
                      isSelected: isSelected,
                      icon: decoration.icon,
                      onTap: () {
                        coordinator.push(
                          DocumentTypeRoute(decoration.documentType.name),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          if (footer != null) footer!,
        ],
      );
    });
  }
}
```

- [ ] **Step 2: Update CmsDocumentTypeItem to remove direct viewModel dependency**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CmsDocumentTypeItem extends StatelessWidget {
  final CmsDocumentType documentType;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const CmsDocumentTypeItem({
    super.key,
    required this.documentType,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ShadCard(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : theme.colorScheme.muted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon ?? Icons.description,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                documentType.title,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.foreground,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Verify compile**

```bash
cd /Users/vietthangvunguyen/Workspace/flutter_cms/packages/flutter_cms && dart analyze lib/src/studio/components/navigation/cms_document_type_sidebar.dart lib/src/studio/components/common/cms_document_type_item.dart
```

- [ ] **Step 4: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/components/navigation/cms_document_type_sidebar.dart \
       packages/flutter_cms/lib/src/studio/components/common/cms_document_type_item.dart
git commit -m "refactor: sidebar navigates via coordinator instead of signal mutation"
```

---

## Chunk 5: Wire Up App Entry Point

### Task 10: Update CmsStudioApp and exports

**Files:**
- Modify: `packages/flutter_cms/lib/src/studio/cms_studio_app.dart`
- Modify: `packages/flutter_cms/lib/studio.dart`

- [ ] **Step 1: Update CmsStudioApp to accept coordinator and document types**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';

import '../../studio.dart';
import '../data/cms_data_source.dart';
import 'providers/studio_provider.dart';
import 'routes/studio_coordinator.dart';

class CmsStudioApp extends StatelessWidget {
  const CmsStudioApp({
    super.key,
    required this.coordinator,
    required this.sidebar,
    required this.dataSource,
    required this.documentTypes,
  });

  final StudioCoordinator coordinator;
  final Widget sidebar;
  final CmsDataSource dataSource;
  final List<CmsDocumentType> documentTypes;

  @override
  Widget build(BuildContext context) {
    return StudioProvider(
      dataSource: dataSource,
      documentTypes: documentTypes,
      child: CmsStudio(coordinator: coordinator, sidebar: sidebar),
    );
  }
}
```

- [ ] **Step 2: Update studio.dart exports**

Add new route exports to `packages/flutter_cms/lib/studio.dart`:

```dart
// Routes
export 'src/studio/routes/studio_coordinator.dart';
export 'src/studio/routes/studio_layout.dart';
export 'src/studio/routes/studio_route.dart';
export 'src/studio/routes/document_type_route.dart';
export 'src/studio/routes/document_route.dart';
export 'src/studio/routes/version_route.dart';
```

- [ ] **Step 3: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/cms_studio_app.dart \
       packages/flutter_cms/lib/studio.dart
git commit -m "feat: update CmsStudioApp to accept coordinator, export route files"
```

---

### Task 11: Update example app main.dart

**Files:**
- Modify: `examples/cms_app/lib/main.dart`

- [ ] **Step 1: Rewrite main.dart to use ZenRouter, dark theme, auth gate wrapping router**

```dart
import 'package:data_models/example_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cms/flutter_cms.dart';
import 'package:flutter_cms/studio.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zenrouter/zenrouter.dart';

// Server configuration
const String _defaultServerUrl = 'http://localhost:8080/';
const String _defaultClientId = 'honeygrow';
const String _defaultApiToken = 'cms_ad_kaKYBjZkB9BBFSjnykvELvzVRKRDHFKrEZsPcy7v240';

void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const serverUrl = String.fromEnvironment(
      'SERVER_URL',
      defaultValue: _defaultServerUrl,
    );
    const clientId = String.fromEnvironment(
      'CMS_CLIENT_ID',
      defaultValue: _defaultClientId,
    );
    const apiToken = String.fromEnvironment(
      'CMS_API_TOKEN',
      defaultValue: _defaultApiToken,
    );

    // Document types for the studio
    final documentTypes = [
      homeScreenConfigDocumentType,
    ];

    // Document type decorations (icons/labels for sidebar)
    final documentTypeDecorations = documentTypes
        .map((d) => CmsDocumentTypeDecoration(documentType: d))
        .toList();

    return FlutterCmsAuth(
      clientId: clientId,
      apiToken: apiToken,
      serverUrl: serverUrl,
      title: 'Honeygrow CMS',
      builder: (context, client) {
        final dataSource = CloudDataSource(client);
        final coordinator = StudioCoordinator(
          documentTypes: documentTypes,
          dataSource: dataSource,
          documentTypeDecorations: documentTypeDecorations,
        );

        return DefaultCmsHeaderConfig(
          title: 'Honeygrow CMS',
          subtitle: 'Content Management',
          icon: Icons.dashboard,
          child: ShadApp.router(
            theme: cmsStudioTheme,
            routerDelegate: ZenRouterDelegate(coordinator),
            routeInformationParser: ZenRouteInformationParser(coordinator),
            builder: (context, child) => Scaffold(
              body: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
```

Note: The exact `ShadApp.router` API and ZenRouter delegate setup may need adjustment based on the actual zenrouter and shadcn_ui APIs. The implementer should reference the manage app's `main.dart` for the exact wiring pattern.

- [ ] **Step 2: Verify compile**

```bash
cd /Users/vietthangvunguyen/Workspace/flutter_cms/examples/cms_app && flutter pub get && dart analyze lib/main.dart
```

- [ ] **Step 3: Run the app and verify**

```bash
flutter run -d chrome --web-port=60366
```

Verify:
- Dark theme renders
- Top bar shows "Honeygrow CMS" with subtitle
- Login screen appears (dark themed)
- After sign-in, URL navigates to `/{firstDocumentTypeSlug}`
- Sidebar shows document types
- Clicking a document type updates the URL
- 4-panel layout renders

- [ ] **Step 4: Commit**

```bash
git add examples/cms_app/lib/main.dart
git commit -m "feat: wire up example app with ZenRouter, dark theme, and auth gate"
```

---

### Task 12: Verify full integration with hot reload

> **Note:** Task 12 (connect coordinator to viewModel) was merged into Task 5. `StudioShell` is defined as a `StatefulWidget` from the start with route listener and `_syncRouteParams()` that calls `viewModel.setRouteParams()`. No separate task needed.

- [ ] **Step 1: Launch the app**

```bash
cd /Users/vietthangvunguyen/Workspace/flutter_cms/examples/cms_app
flutter run -d chrome --web-port=60366
```

- [ ] **Step 2: Test navigation flow**

1. App loads → login screen (dark theme) appears
2. Sign in with Google
3. Redirects to `/{firstDocumentTypeSlug}` (e.g., `/home-screen-config`)
4. Sidebar shows document types with active highlight
5. Document list panel populates
6. Click a document → URL updates to `/{slug}/{docId}`
7. Preview and editor panels populate
8. Click a version → URL updates to `/{slug}/{docId}/{versionId}`
9. Browser back/forward works
10. Top bar shows "Honeygrow CMS" title

- [ ] **Step 3: Fix any issues found during testing**

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "fix: integration fixes for CMS studio architecture alignment"
```

---

## Chunk 6: Component Alignment

### Task 13: Component alignment — Lucide icons, ShadBadge, styling

**Files:**
- Modify: `packages/flutter_cms/lib/src/studio/screens/cms_studio.dart`
- Modify: `packages/flutter_cms/lib/src/studio/components/common/cms_document_type_item.dart`
- Potentially modify: version history / document list components

This task covers visual consistency with the manage app's component library.

- [ ] **Step 1: Replace Material Icons with Lucide equivalents in CmsStudio empty states**

In `cms_studio.dart`, the empty state icons should already use Lucide icons (done in Task 8). Verify the following replacements are in place:

| Old (Material) | New (Lucide) |
|---|---|
| `Icons.edit` | `LucideIcons.pencil` |
| `Icons.visibility` | `LucideIcons.eye` |
| `Icons.folder_open` | `LucideIcons.folderOpen` |
| `Icons.article` | `LucideIcons.fileText` |
| `Icons.error` | `LucideIcons.alertCircle` |
| `Icons.description` | `LucideIcons.file` |

Also update `CmsDocumentTypeItem` — replace `Icons.description` fallback with `LucideIcons.file`:

```dart
// In cms_document_type_item.dart, change:
icon ?? Icons.description,
// To:
icon ?? LucideIcons.file,
```

- [ ] **Step 2: Replace `_StatusBadge` with `ShadBadge` in version history**

If a custom `_StatusBadge` widget exists in version history or document list components, replace it with `ShadBadge` from shadcn_ui:

```dart
// Before:
_StatusBadge(status: version.status)

// After:
ShadBadge(
  child: Text(version.status.name),
  // Use variant based on status:
  // ShadBadge.destructive for 'archived'
  // ShadBadge.secondary for 'draft'
  // ShadBadge (default) for 'published'
)
```

- [ ] **Step 3: Update document list items styling**

Ensure document list items use consistent dark theme styling:
- Use `theme.colorScheme.card` for item backgrounds
- Use `theme.colorScheme.border` for borders
- Use `theme.colorScheme.mutedForeground` for secondary text
- Use `ShadCard` for item containers where appropriate

- [ ] **Step 4: Verify compile**

```bash
cd /Users/vietthangvunguyen/Workspace/flutter_cms/packages/flutter_cms && dart analyze lib/src/studio/
```

- [ ] **Step 5: Commit**

```bash
git add packages/flutter_cms/lib/src/studio/
git commit -m "style: align studio components with Lucide icons, ShadBadge, and dark theme styling"
```
