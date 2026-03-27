# zenrouter → auto_route Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace zenrouter with auto_route v11 in `packages/dart_desk`, eliminating `StudioCoordinator` and decomposing the monolithic `CmsStudio` widget into proper leaf screens.

**Architecture:** `StudioRouter` (code-gen `RootStackRouter`) owns all routing internally; `StudioConfig` (plain data class in GetIt) replaces coordinator config data; `StudioShellScreen` uses `StackRouter.addListener` to write path params directly to `CmsViewModel` signals via `batch()`; each content area is its own `@RoutePage()` screen.

**Tech Stack:** `auto_route ^11.1.0`, `auto_route_generator ^10.5.0`, `signals` (existing), `get_it` (existing), `shadcn_ui` (existing), `font_awesome_flutter` (existing)

---

## File Map

### Create
```
packages/dart_desk/lib/src/studio/config/studio_config.dart
packages/dart_desk/lib/src/studio/router/studio_router.dart
packages/dart_desk/lib/src/studio/router/studio_router.gr.dart   ← generated
packages/dart_desk/lib/src/studio/components/common/cms_top_bar.dart
packages/dart_desk/lib/src/studio/screens/studio_shell_screen.dart
packages/dart_desk/lib/src/studio/screens/media_screen.dart
packages/dart_desk/lib/src/studio/screens/document_type_screen.dart
packages/dart_desk/lib/src/studio/screens/document_screen.dart
packages/dart_desk/lib/src/studio/screens/version_screen.dart
```

### Modify
```
packages/dart_desk/pubspec.yaml
packages/dart_desk/lib/src/studio/core/view_models/cms_view_model.dart
packages/dart_desk/lib/src/studio/components/navigation/cms_document_type_sidebar.dart
packages/dart_desk/lib/src/studio/cms_studio_app.dart
packages/dart_desk/lib/studio.dart
```

### Delete
```
packages/dart_desk/lib/src/studio/routes/studio_coordinator.dart
packages/dart_desk/lib/src/studio/routes/studio_route.dart
packages/dart_desk/lib/src/studio/routes/studio_layout.dart
packages/dart_desk/lib/src/studio/routes/document_type_route.dart
packages/dart_desk/lib/src/studio/routes/document_route.dart
packages/dart_desk/lib/src/studio/routes/media_route.dart
packages/dart_desk/lib/src/studio/routes/version_route.dart
packages/dart_desk/lib/src/studio/screens/cms_studio.dart
```

---

## Task 1: Add auto_route dependencies

**Files:**
- Modify: `packages/dart_desk/pubspec.yaml`

- [ ] **Step 1: Update pubspec.yaml**

In `packages/dart_desk/pubspec.yaml`, under `dependencies`, replace:
```yaml
  zenrouter: ^2.0.3
```
with:
```yaml
  auto_route: ^11.1.0
```

Under `dev_dependencies`, add:
```yaml
  auto_route_generator: ^10.5.0
```

The `dev_dependencies` section should now include:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.13.1
  auto_route_generator: ^10.5.0
```

- [ ] **Step 2: Run pub get**

From the workspace root (not the package — it uses workspace resolution):
```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
flutter pub get
```

Expected: dependencies resolved with no errors. You will see `auto_route` added and `zenrouter` removed.

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/pubspec.yaml pubspec.yaml
git commit -m "chore(dart_desk): swap zenrouter for auto_route"
```

---

## Task 2: Create StudioConfig

**Files:**
- Create: `packages/dart_desk/lib/src/studio/config/studio_config.dart`

- [ ] **Step 1: Create the file**

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';

import '../../data/cms_data_source.dart';
import '../components/common/cms_document_type_decoration.dart';

/// Holds CMS studio configuration data.
///
/// Registered as a GetIt singleton by [CmsStudioApp] before the widget tree
/// builds. All widgets that previously received [StudioCoordinator] as a
/// parameter now read from [GetIt.I<StudioConfig>()] instead.
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

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/lib/src/studio/config/studio_config.dart
git commit -m "feat(dart_desk): add StudioConfig"
```

---

## Task 3: Create screen stubs for code generation

All five `@RoutePage()` screens must exist before `build_runner` can generate `studio_router.gr.dart`. Create minimal stubs now; full implementations follow in later tasks.

**Files:**
- Create: `packages/dart_desk/lib/src/studio/screens/studio_shell_screen.dart`
- Create: `packages/dart_desk/lib/src/studio/screens/media_screen.dart`
- Create: `packages/dart_desk/lib/src/studio/screens/document_type_screen.dart`
- Create: `packages/dart_desk/lib/src/studio/screens/document_screen.dart`
- Create: `packages/dart_desk/lib/src/studio/screens/version_screen.dart`

- [ ] **Step 1: Create studio_shell_screen.dart stub**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class StudioShellScreen extends StatefulWidget {
  const StudioShellScreen({super.key});

  @override
  State<StudioShellScreen> createState() => _StudioShellScreenState();
}

class _StudioShellScreenState extends State<StudioShellScreen> {
  @override
  Widget build(BuildContext context) => const AutoRouter();
}
```

- [ ] **Step 2: Create media_screen.dart stub**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
```

- [ ] **Step 3: Create document_type_screen.dart stub**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class DocumentTypeScreen extends StatelessWidget {
  const DocumentTypeScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
  });

  final String documentTypeSlug;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
```

- [ ] **Step 4: Create document_screen.dart stub**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class DocumentScreen extends StatelessWidget {
  const DocumentScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
    @PathParam('documentId') required this.documentId,
  });

  final String documentTypeSlug;
  final String documentId;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
```

- [ ] **Step 5: Create version_screen.dart stub**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
```

- [ ] **Step 6: Commit stubs**

```bash
git add packages/dart_desk/lib/src/studio/screens/studio_shell_screen.dart \
        packages/dart_desk/lib/src/studio/screens/media_screen.dart \
        packages/dart_desk/lib/src/studio/screens/document_type_screen.dart \
        packages/dart_desk/lib/src/studio/screens/document_screen.dart \
        packages/dart_desk/lib/src/studio/screens/version_screen.dart
git commit -m "feat(dart_desk): add @RoutePage screen stubs"
```

---

## Task 4: Create StudioRouter and run build_runner

**Files:**
- Create: `packages/dart_desk/lib/src/studio/router/studio_router.dart`
- Create: `packages/dart_desk/lib/src/studio/router/studio_router.gr.dart` (generated)

- [ ] **Step 1: Create studio_router.dart**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';

import '../config/studio_config.dart';
import '../screens/document_screen.dart';
import '../screens/document_type_screen.dart';
import '../screens/media_screen.dart';
import '../screens/studio_shell_screen.dart';
import '../screens/version_screen.dart';

part 'studio_router.gr.dart';

@AutoRouterConfig()
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
///
/// Applied to the shell route so every entry to `/` immediately lands on a
/// concrete document type rather than an empty shell.
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
```

- [ ] **Step 2: Run build_runner**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
dart run build_runner build --delete-conflicting-outputs
```

Expected output: `[INFO] Succeeded after ...` with no errors. This creates `packages/dart_desk/lib/src/studio/router/studio_router.gr.dart`.

- [ ] **Step 3: Verify generated file exists**

```bash
ls packages/dart_desk/lib/src/studio/router/
```

Expected: both `studio_router.dart` and `studio_router.gr.dart` present.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk/lib/src/studio/router/
git commit -m "feat(dart_desk): add StudioRouter with DefaultDocTypeGuard"
```

---

## Task 5: Extract CmsTopBar

Extract the private `_TopBar` widget from `studio_layout.dart` into a standalone file. Replace all `coordinator` references with GetIt lookups and `context.router.navigate` calls.

**Files:**
- Create: `packages/dart_desk/lib/src/studio/components/common/cms_top_bar.dart`

- [ ] **Step 1: Create cms_top_bar.dart**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

import '../../cms_studio_app.dart';
import '../../config/studio_config.dart';
import '../../core/view_models/cms_document_view_model.dart';
import '../../core/view_models/cms_view_model.dart';
import '../../router/studio_router.dart';
import '../../screens/document_type_screen.dart';
import '../../theme/spacing.dart';
import '../version/cms_version_history.dart';
import 'cms_breadcrumbs.dart';
import 'cms_theme_toggle.dart';
import 'default_cms_header.dart';

/// Persistent top bar for the CMS studio.
///
/// Displays logo, breadcrumbs, theme toggle, version history, and sign-out.
/// Navigation uses [context.router.navigate] (auto_route).
class CmsTopBar extends StatelessWidget {
  const CmsTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final headerConfig = DefaultCmsHeaderConfig.of(context);
    final viewModel = GetIt.I<CmsViewModel>();
    final config = GetIt.I<StudioConfig>();

    final docTypeSlug = viewModel.currentDocumentTypeSlug.watch(context);
    final docId = viewModel.currentDocumentId.watch(context);

    final segments = <BreadcrumbSegment>[
      BreadcrumbSegment(
        label: headerConfig?.title ?? 'CMS Studio',
        onTap: docTypeSlug != null
            ? () => context.router.navigate(
                  DocumentTypeScreenRoute(documentTypeSlug: docTypeSlug),
                )
            : null,
      ),
    ];

    if (docTypeSlug != null) {
      final docType = viewModel.currentDocumentType.value;
      segments.add(BreadcrumbSegment(
        label: docType?.title ?? docTypeSlug,
        key: docId != null ? const ValueKey('breadcrumb_back') : null,
        onTap: docId != null
            ? () => context.router.navigate(
                  DocumentTypeScreenRoute(documentTypeSlug: docTypeSlug),
                )
            : null,
      ));
    }

    if (docId != null) {
      final documentViewModel = GetIt.I<CmsDocumentViewModel>();
      final title = documentViewModel.title.watch(context);
      segments
          .add(BreadcrumbSegment(label: title.isNotEmpty ? title : 'Document'));
    }

    final themeModeSignal = CmsThemeModeProvider.of(context);
    final currentTheme = themeModeSignal.watch(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: CmsSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          if (headerConfig?.icon != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(CmsBorderRadius.md),
              ),
              child: Center(
                child: FaIcon(
                  headerConfig!.icon!,
                  size: 14,
                  color: theme.colorScheme.primaryForeground,
                ),
              ),
            ),
            const SizedBox(width: CmsSpacing.md),
          ],
          Expanded(child: CmsBreadcrumbs(segments: segments)),
          CmsThemeToggle(
            themeMode: currentTheme,
            onChanged: (mode) async {
              themeModeSignal.value = mode;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('cms_theme_mode_dark', mode == ThemeMode.dark);
            },
          ),
          const SizedBox(width: CmsSpacing.md),
          CmsVersionHistory(viewModel: viewModel),
          const SizedBox(width: CmsSpacing.md),
          GestureDetector(
            onTap: () => config.onSignOut?.call(),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.solidUser,
                    size: 12,
                    color: theme.colorScheme.primaryForeground,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/lib/src/studio/components/common/cms_top_bar.dart
git commit -m "feat(dart_desk): extract CmsTopBar from StudioLayout"
```

---

## Task 6: Implement StudioShellScreen

Replace the stub with the full implementation. The shell owns the persistent chrome (topbar + sidebar) and syncs route params to `CmsViewModel` via `StackRouter.addListener`.

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/screens/studio_shell_screen.dart`

- [ ] **Step 1: Replace stub with full implementation**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/cms_data_source.dart';
import '../components/common/cms_top_bar.dart';
import '../components/navigation/cms_document_type_sidebar.dart';
import '../config/studio_config.dart';
import '../core/view_models/cms_view_model.dart';
import '../providers/studio_provider.dart';
import '../router/studio_router.dart';
import '../theme/spacing.dart';

@RoutePage()
class StudioShellScreen extends StatefulWidget {
  const StudioShellScreen({super.key});

  @override
  State<StudioShellScreen> createState() => _StudioShellScreenState();
}

class _StudioShellScreenState extends State<StudioShellScreen> {
  late final StackRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // StackRouter is a Listenable — use auto_route's native interface.
    // didChangeDependencies can be called more than once; guard against
    // double-registration by always removing before re-adding.
    _router = context.router;
    _router.removeListener(_onRouteChanged);
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
    final docId = params.optString('documentId');
    final versionId = params.optString('versionId');
    batch(() {
      vm.currentDocumentTypeSlug.value = params.optString('documentTypeSlug');
      vm.currentDocumentId.value = docId;
      vm.selectedDocumentId.value =
          docId != null ? int.tryParse(docId) : null;
      vm.currentVersionId.value = versionId;
      vm.selectedVersionId.value =
          versionId != null ? int.tryParse(versionId) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = GetIt.I<StudioConfig>();

    return StudioProvider(
      dataSource: config.dataSource,
      documentTypes: config.documentTypes,
      child: Builder(
        builder: (context) => Column(
          children: [
            const CmsTopBar(),
            const Divider(height: 1),
            Expanded(
              child: Row(
                children: [
                  CmsDocumentTypeSidebar(
                    documentTypeDecorations: config.documentTypeDecorations,
                    footer: ShadButton.ghost(
                      key: const ValueKey('sidebar_media_button'),
                      onPressed: () =>
                          context.router.navigate(const MediaScreenRoute()),
                      child: const Row(
                        children: [
                          FaIcon(FontAwesomeIcons.images, size: 14),
                          SizedBox(width: CmsSpacing.sm),
                          Text('Media Library'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: AutoRouter()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/lib/src/studio/screens/studio_shell_screen.dart
git commit -m "feat(dart_desk): implement StudioShellScreen"
```

---

## Task 7: Implement MediaScreen

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/screens/media_screen.dart`

- [ ] **Step 1: Replace stub with full implementation**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../media/browser/media_browser.dart';
import '../config/studio_config.dart';

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

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/lib/src/studio/screens/media_screen.dart
git commit -m "feat(dart_desk): implement MediaScreen"
```

---

## Task 8: Implement DocumentTypeScreen

Renders the collapsible document list and an empty editor state. Tapping a document navigates to `DocumentScreenRoute`.

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/screens/document_type_screen.dart`

- [ ] **Step 1: Replace stub with full implementation**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../components/common/cms_collapse_bar.dart';
import '../core/view_models/cms_view_model.dart';
import '../router/studio_router.dart';
import '../screens/document_screen.dart';
import '../theme/spacing.dart';
import 'document_list.dart';

@RoutePage()
class DocumentTypeScreen extends StatefulWidget {
  const DocumentTypeScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
  });

  final String documentTypeSlug;

  @override
  State<DocumentTypeScreen> createState() => _DocumentTypeScreenState();
}

class _DocumentTypeScreenState extends State<DocumentTypeScreen> {
  Future<void> _deleteDocument(BuildContext context, {int? docId}) async {
    final viewModel = GetIt.I<CmsViewModel>();
    final toaster = ShadToaster.of(context);
    if (docId == null) return;

    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog(
        title: const Text('Delete document'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
        child: const Text(
          'This will permanently delete this document and all its versions. This cannot be undone.',
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final result = await viewModel.deleteDocument(docId);
      if (mounted) {
        if (result) {
          toaster.show(const ShadToast(description: Text('Document deleted')));
        } else {
          toaster.show(ShadToast.destructive(
              description: const Text('Failed to delete document')));
        }
      }
    } catch (e) {
      if (mounted) {
        toaster.show(
            ShadToast.destructive(description: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = GetIt.I<CmsViewModel>();
    final docType = viewModel.currentDocumentType.watch(context);
    final isListVisible = viewModel.documentListVisible.watch(context);

    return Row(
      children: [
        // Collapsible document list
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isListVisible ? 220 : 0,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            border: Border(
              right: BorderSide(
                  color: theme.colorScheme.border.withValues(alpha: 0.5)),
            ),
          ),
          child: docType == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                      CmsSpacing.md, CmsSpacing.sm, CmsSpacing.md, 0),
                  child: CmsDocumentListView(
                    selectedDocumentType: docType,
                    icon: FontAwesomeIcons.file,
                    onOpenDocument: (documentId) {
                      context.router.navigate(DocumentScreenRoute(
                        documentTypeSlug: widget.documentTypeSlug,
                        documentId: documentId,
                      ));
                    },
                    onDeleteDocument: (docId) =>
                        _deleteDocument(context, docId: docId),
                  ),
                ),
        ),
        // Collapsed rail
        if (!isListVisible)
          Container(
            width: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              border: Border(
                right: BorderSide(
                    color: theme.colorScheme.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Column(
              children: [
                const Spacer(),
                CmsCollapseBar(
                  isCollapsed: true,
                  onToggle: () =>
                      viewModel.documentListVisible.value = true,
                ),
              ],
            ),
          ),
        // Empty editor state
        Expanded(
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
                        borderRadius:
                            BorderRadius.circular(CmsBorderRadius.md),
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
                      style:
                          theme.textTheme.muted.copyWith(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/lib/src/studio/screens/document_type_screen.dart
git commit -m "feat(dart_desk): implement DocumentTypeScreen"
```

---

## Task 9: Implement DocumentScreen

Renders the collapsible document list plus the editor/preview split.

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/screens/document_screen.dart`

- [ ] **Step 1: Replace stub with full implementation**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../components/common/cms_collapse_bar.dart';
import '../core/view_models/cms_document_view_model.dart';
import '../core/view_models/cms_view_model.dart';
import '../router/studio_router.dart';
import '../theme/spacing.dart';
import 'document_editor.dart';
import 'document_list.dart';

@RoutePage()
class DocumentScreen extends StatefulWidget {
  const DocumentScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
    @PathParam('documentId') required this.documentId,
  });

  final String documentTypeSlug;
  final String documentId;

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  Future<void> _deleteDocument(BuildContext context, {int? docId}) async {
    final viewModel = GetIt.I<CmsViewModel>();
    final toaster = ShadToaster.of(context);
    if (docId == null) return;

    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog(
        title: const Text('Delete document'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
        child: const Text(
          'This will permanently delete this document and all its versions. This cannot be undone.',
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final result = await viewModel.deleteDocument(docId);
      if (mounted) {
        if (result) {
          toaster.show(const ShadToast(description: Text('Document deleted')));
        } else {
          toaster.show(ShadToast.destructive(
              description: const Text('Failed to delete document')));
        }
      }
    } catch (e) {
      if (mounted) {
        toaster.show(
            ShadToast.destructive(description: Text('Failed to delete: $e')));
      }
    }
  }

  Widget _buildPreview(
    BuildContext context,
    ShadThemeData theme,
    CmsViewModel viewModel,
    DocumentType docType,
  ) {
    final documentViewModel = GetIt.I<CmsDocumentViewModel>();
    final edited = documentViewModel.editedData.watch(context);

    Map<String, dynamic> data;
    if (edited.isNotEmpty) {
      data = edited;
    } else {
      final versionId = viewModel.selectedVersionId.value;
      final defaultData = docType.defaultValue?.toMap() ?? {};
      data = defaultData;

      if (versionId != null) {
        final versionState = viewModel.documentDataContainer(versionId).value;
        data = versionState.map<Map<String, dynamic>>(
          loading: () => defaultData,
          error: (_, _) => defaultData,
          data: (version) => version?.data ?? defaultData,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(CmsSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREVIEW',
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.mutedForeground,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: CmsSpacing.md),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CmsBorderRadius.lg),
              ),
              clipBehavior: Clip.antiAlias,
              child: docType.builder(data),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = GetIt.I<CmsViewModel>();
    final docType = viewModel.currentDocumentType.watch(context);
    final isListVisible = viewModel.documentListVisible.watch(context);

    return Row(
      children: [
        // Collapsible document list
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isListVisible ? 220 : 0,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            border: Border(
              right: BorderSide(
                  color: theme.colorScheme.border.withValues(alpha: 0.5)),
            ),
          ),
          child: docType == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                      CmsSpacing.md, CmsSpacing.sm, CmsSpacing.md, 0),
                  child: CmsDocumentListView(
                    selectedDocumentType: docType,
                    icon: FontAwesomeIcons.file,
                    onOpenDocument: (documentId) {
                      context.router.navigate(DocumentScreenRoute(
                        documentTypeSlug: widget.documentTypeSlug,
                        documentId: documentId,
                      ));
                    },
                    onDeleteDocument: (docId) =>
                        _deleteDocument(context, docId: docId),
                  ),
                ),
        ),
        // Collapsed rail
        if (!isListVisible)
          Container(
            width: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              border: Border(
                right: BorderSide(
                    color: theme.colorScheme.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Column(
              children: [
                const Spacer(),
                CmsCollapseBar(
                  isCollapsed: true,
                  onToggle: () =>
                      viewModel.documentListVisible.value = true,
                ),
              ],
            ),
          ),
        // Editor + Preview split
        if (docType != null)
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.card,
                      border: Border(
                        right: BorderSide(
                          color: theme.colorScheme.border
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: _buildPreview(context, theme, viewModel, docType),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: theme.colorScheme.background,
                    child: CmsDocumentEditor(
                      fields: docType.fields,
                      title: docType.title,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/lib/src/studio/screens/document_screen.dart
git commit -m "feat(dart_desk): implement DocumentScreen"
```

---

## Task 10: Implement VersionScreen

Same layout as `DocumentScreen` — the shell already sets `selectedVersionId` signal from the URL, so `CmsDocumentViewModel` automatically loads version-specific data.

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/screens/version_screen.dart`

- [ ] **Step 1: Replace stub with full implementation**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../components/common/cms_collapse_bar.dart';
import '../core/view_models/cms_document_view_model.dart';
import '../core/view_models/cms_view_model.dart';
import '../router/studio_router.dart';
import '../theme/spacing.dart';
import 'document_editor.dart';
import 'document_list.dart';

@RoutePage()
class VersionScreen extends StatefulWidget {
  const VersionScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
    @PathParam('documentId') required this.documentId,
    @PathParam('versionId') required this.versionId,
  });

  final String documentTypeSlug;
  final String documentId;
  final String versionId;

  @override
  State<VersionScreen> createState() => _VersionScreenState();
}

class _VersionScreenState extends State<VersionScreen> {
  Future<void> _deleteDocument(BuildContext context, {int? docId}) async {
    final viewModel = GetIt.I<CmsViewModel>();
    final toaster = ShadToaster.of(context);
    if (docId == null) return;

    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog(
        title: const Text('Delete document'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
        child: const Text(
          'This will permanently delete this document and all its versions. This cannot be undone.',
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final result = await viewModel.deleteDocument(docId);
      if (mounted) {
        if (result) {
          toaster.show(const ShadToast(description: Text('Document deleted')));
        } else {
          toaster.show(ShadToast.destructive(
              description: const Text('Failed to delete document')));
        }
      }
    } catch (e) {
      if (mounted) {
        toaster.show(
            ShadToast.destructive(description: Text('Failed to delete: $e')));
      }
    }
  }

  Widget _buildPreview(
    BuildContext context,
    ShadThemeData theme,
    CmsViewModel viewModel,
    DocumentType docType,
  ) {
    final documentViewModel = GetIt.I<CmsDocumentViewModel>();
    final edited = documentViewModel.editedData.watch(context);

    Map<String, dynamic> data;
    if (edited.isNotEmpty) {
      data = edited;
    } else {
      final versionId = viewModel.selectedVersionId.value;
      final defaultData = docType.defaultValue?.toMap() ?? {};
      data = defaultData;

      if (versionId != null) {
        final versionState = viewModel.documentDataContainer(versionId).value;
        data = versionState.map<Map<String, dynamic>>(
          loading: () => defaultData,
          error: (_, _) => defaultData,
          data: (version) => version?.data ?? defaultData,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(CmsSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREVIEW',
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.mutedForeground,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: CmsSpacing.md),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CmsBorderRadius.lg),
              ),
              clipBehavior: Clip.antiAlias,
              child: docType.builder(data),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = GetIt.I<CmsViewModel>();
    final docType = viewModel.currentDocumentType.watch(context);
    final isListVisible = viewModel.documentListVisible.watch(context);

    return Row(
      children: [
        // Collapsible document list
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isListVisible ? 220 : 0,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            border: Border(
              right: BorderSide(
                  color: theme.colorScheme.border.withValues(alpha: 0.5)),
            ),
          ),
          child: docType == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                      CmsSpacing.md, CmsSpacing.sm, CmsSpacing.md, 0),
                  child: CmsDocumentListView(
                    selectedDocumentType: docType,
                    icon: FontAwesomeIcons.file,
                    onOpenDocument: (documentId) {
                      context.router.navigate(DocumentScreenRoute(
                        documentTypeSlug: widget.documentTypeSlug,
                        documentId: documentId,
                      ));
                    },
                    onDeleteDocument: (docId) =>
                        _deleteDocument(context, docId: docId),
                  ),
                ),
        ),
        // Collapsed rail
        if (!isListVisible)
          Container(
            width: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              border: Border(
                right: BorderSide(
                    color: theme.colorScheme.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Column(
              children: [
                const Spacer(),
                CmsCollapseBar(
                  isCollapsed: true,
                  onToggle: () =>
                      viewModel.documentListVisible.value = true,
                ),
              ],
            ),
          ),
        // Editor + Preview split
        if (docType != null)
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.card,
                      border: Border(
                        right: BorderSide(
                          color: theme.colorScheme.border
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: _buildPreview(context, theme, viewModel, docType),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: theme.colorScheme.background,
                    child: CmsDocumentEditor(
                      fields: docType.fields,
                      title: docType.title,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/lib/src/studio/screens/version_screen.dart
git commit -m "feat(dart_desk): implement VersionScreen"
```

---

## Task 11: Update CmsDocumentTypeSidebar

Drop the `coordinator` parameter. Navigation uses `context.router.navigate`.

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/components/navigation/cms_document_type_sidebar.dart`

- [ ] **Step 1: Remove coordinator param and update navigation**

Replace the entire file content:

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:get_it/get_it.dart';

import '../../core/view_models/cms_view_model.dart';
import '../../router/studio_router.dart';
import '../../screens/document_type_screen.dart';
import '../../theme/spacing.dart';
import '../common/cms_collapse_bar.dart';
import '../common/cms_document_type_decoration.dart';
import '../common/cms_document_type_item.dart';

/// A sidebar widget that displays document type navigation items.
///
/// Supports expanded (icon + label + count) and collapsed (icon-only rail) modes.
/// Collapse state is driven by [CmsViewModel.sidebarCollapsed].
class CmsDocumentTypeSidebar extends StatelessWidget {
  final List<DocumentTypeDecoration> documentTypeDecorations;
  final Widget? header;
  final Widget? footer;

  const CmsDocumentTypeSidebar({
    super.key,
    required this.documentTypeDecorations,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final viewModel = GetIt.I<CmsViewModel>();
    final isCollapsed = viewModel.sidebarCollapsed.watch(context);
    final currentSlug = viewModel.currentDocumentTypeSlug.watch(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: isCollapsed ? 48 : 180,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          right: BorderSide(
              color: theme.colorScheme.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          if (header != null && !isCollapsed) header!,
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CmsSpacing.sm, CmsSpacing.md, CmsSpacing.sm, CmsSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CONTENT',
                  style: TextStyle(
                    fontSize: 9,
                    color: theme.colorScheme.mutedForeground,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? CmsSpacing.sm : CmsSpacing.sm,
                vertical: isCollapsed ? CmsSpacing.md : 0,
              ),
              children: documentTypeDecorations.map((decoration) {
                final isSelected =
                    currentSlug == decoration.documentType.name;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: DocumentTypeItem(
                    key: ValueKey(
                        'doc_type_${decoration.documentType.title}'),
                    documentType: decoration.documentType,
                    isSelected: isSelected,
                    icon: decoration.icon,
                    isCollapsed: isCollapsed,
                    onTap: () {
                      context.router.navigate(
                        DocumentTypeScreenRoute(
                          documentTypeSlug: decoration.documentType.name,
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          if (footer != null && !isCollapsed) footer!,
          CmsCollapseBar(
            isCollapsed: isCollapsed,
            onToggle: () =>
                viewModel.sidebarCollapsed.value = !isCollapsed,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/lib/src/studio/components/navigation/cms_document_type_sidebar.dart
git commit -m "refactor(dart_desk): drop coordinator from CmsDocumentTypeSidebar"
```

---

## Task 12: Update CmsViewModel — remove setRouteParams()

The shell now writes directly to the existing signals. `setRouteParams()` is dead code.

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/core/view_models/cms_view_model.dart`

- [ ] **Step 1: Remove setRouteParams() and update comment block**

Remove the entire `setRouteParams` method (lines 118–135) and the comment above it. Change the comment at the top of the route param signals section from:

```dart
  // ============================================================
  // Route Param Signals (set by coordinator via setRouteParams)
  // ============================================================
```

to:

```dart
  // ============================================================
  // Route Param Signals (written by StudioShellScreen._onRouteChanged)
  // ============================================================
```

Also remove the `// Route Params (called by coordinator on route change)` section header (lines 113–116).

The `selectedDocumentId` and `selectedVersionId` signals stay — they're still written by `StudioShellScreen._onRouteChanged`.

- [ ] **Step 2: Verify no other callers of setRouteParams exist**

```bash
grep -r "setRouteParams" /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk/lib
```

Expected: no output (zero matches).

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/lib/src/studio/core/view_models/cms_view_model.dart
git commit -m "refactor(dart_desk): remove setRouteParams from CmsViewModel"
```

---

## Task 13: Update CmsStudioApp

Replace `StudioCoordinator` with `StudioRouter`. Register `StudioConfig` in GetIt. Wire `ShadApp.router` with the new router.

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/cms_studio_app.dart`

- [ ] **Step 1: Replace cms_studio_app.dart content**

```dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

import '../data/cms_data_source.dart';
import 'components/common/cms_document_type_decoration.dart';
import 'components/common/default_cms_header.dart';
import 'config/studio_config.dart';
import 'router/studio_router.dart';
import 'theme/theme.dart';

/// The complete CMS Studio entry point.
///
/// Creates [StudioConfig] and registers it in GetIt, instantiates [StudioRouter],
/// and wires [ShadApp.router]. The consuming app only needs to provide data
/// and document type configuration.
class CmsStudioApp extends StatefulWidget {
  const CmsStudioApp({
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
  State<CmsStudioApp> createState() => _CmsStudioAppState();
}

class _CmsStudioAppState extends State<CmsStudioApp> {
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
    final isDark = prefs.getBool('cms_theme_mode_dark') ?? true;
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
        (currentMode == ThemeMode.dark ? cmsStudioTheme : cmsStudioLightTheme);

    return CmsThemeModeProvider(
      themeMode: _themeMode,
      child: DefaultCmsHeaderConfig(
        title: widget.title,
        subtitle: widget.subtitle,
        icon: widget.icon,
        child: ShadApp.router(
          theme: resolvedTheme,
          routeInformationParser: _router.defaultRouteParser(),
          routerDelegate: _router.delegate(),
        ),
      ),
    );
  }
}

/// Provides the theme mode signal to descendants.
class CmsThemeModeProvider extends InheritedWidget {
  final Signal<ThemeMode> themeMode;

  const CmsThemeModeProvider({
    super.key,
    required this.themeMode,
    required super.child,
  });

  static Signal<ThemeMode> of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CmsThemeModeProvider>()!
        .themeMode;
  }

  @override
  bool updateShouldNotify(CmsThemeModeProvider oldWidget) =>
      themeMode != oldWidget.themeMode;
}
```

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/lib/src/studio/cms_studio_app.dart
git commit -m "feat(dart_desk): wire CmsStudioApp to StudioRouter + StudioConfig"
```

---

## Task 14: Update studio.dart exports

Remove old zenrouter exports. Add new router, config, and screen exports.

**Files:**
- Modify: `packages/dart_desk/lib/studio.dart`

- [ ] **Step 1: Update studio.dart**

Replace the routes section and screens section:

```dart
/// Dart Desk Studio - Complete CMS interface components
library;

// Cloud (built-in Serverpod IDP auth)
export 'src/cloud/dart_desk_auth.dart';
export 'src/inputs/hotspot/image_hotspot_editor.dart';
// Media system
export 'src/media/browser/media_browser.dart';
export 'src/media/image_transform_params.dart';
export 'src/media/image_url.dart';
// App entry point
export 'src/studio/cms_studio_app.dart';
// Common components
export 'src/studio/components/common/cms_breadcrumbs.dart';
export 'src/studio/components/common/cms_button.dart';
export 'src/studio/components/common/cms_document_type_decoration.dart';
export 'src/studio/components/common/cms_document_type_item.dart';
export 'src/studio/components/common/cms_status_pill.dart';
export 'src/studio/components/common/cms_theme_toggle.dart';
export 'src/studio/components/common/cms_top_bar.dart';
export 'src/studio/components/common/default_cms_header.dart';
export 'src/studio/components/forms/cms_form.dart';
export 'src/studio/components/navigation/cms_document_type_sidebar.dart';
export 'src/studio/components/version/cms_version_history.dart';
// Config
export 'src/studio/config/studio_config.dart';
// Core studio functionality
export 'src/studio/core/marionette_config.dart';
export 'src/studio/core/registry.dart';
export 'src/studio/core/view_models/cms_view_model.dart';
export 'src/studio/dart_desk_app.dart';
export 'src/studio/dart_desk_config.dart';
// Router
export 'src/studio/router/studio_router.dart';
// Screens
export 'src/studio/screens/document_editor.dart';
export 'src/studio/screens/document_list.dart';
export 'src/studio/screens/document_screen.dart';
export 'src/studio/screens/document_type_screen.dart';
export 'src/studio/screens/media_screen.dart';
export 'src/studio/screens/studio_shell_screen.dart';
export 'src/studio/screens/version_screen.dart';
// Theme
export 'src/studio/theme/spacing.dart';
export 'src/studio/theme/theme.dart';
```

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/lib/studio.dart
git commit -m "chore(dart_desk): update studio.dart exports for auto_route"
```

---

## Task 15: Delete old zenrouter files

**Files to delete:**
```
packages/dart_desk/lib/src/studio/routes/studio_coordinator.dart
packages/dart_desk/lib/src/studio/routes/studio_route.dart
packages/dart_desk/lib/src/studio/routes/studio_layout.dart
packages/dart_desk/lib/src/studio/routes/document_type_route.dart
packages/dart_desk/lib/src/studio/routes/document_route.dart
packages/dart_desk/lib/src/studio/routes/media_route.dart
packages/dart_desk/lib/src/studio/routes/version_route.dart
packages/dart_desk/lib/src/studio/screens/cms_studio.dart
```

- [ ] **Step 1: Delete all old route files and cms_studio.dart**

```bash
git rm packages/dart_desk/lib/src/studio/routes/studio_coordinator.dart \
        packages/dart_desk/lib/src/studio/routes/studio_route.dart \
        packages/dart_desk/lib/src/studio/routes/studio_layout.dart \
        packages/dart_desk/lib/src/studio/routes/document_type_route.dart \
        packages/dart_desk/lib/src/studio/routes/document_route.dart \
        packages/dart_desk/lib/src/studio/routes/media_route.dart \
        packages/dart_desk/lib/src/studio/routes/version_route.dart \
        packages/dart_desk/lib/src/studio/screens/cms_studio.dart
```

- [ ] **Step 2: Verify no remaining imports of deleted files**

```bash
grep -r "studio_coordinator\|studio_layout\|studio_route\|document_type_route\|document_route\|media_route\|version_route\|cms_studio" \
  /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk/lib \
  --include="*.dart"
```

Expected: no output. If any files appear, fix their imports before committing.

- [ ] **Step 3: Commit**

```bash
git commit -m "chore(dart_desk): delete zenrouter routes and CmsStudio"
```

---

## Task 16: Verify — analyse and run the app

- [ ] **Step 1: Run Dart analysis**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
dart analyze packages/dart_desk/lib
```

Expected: `No issues found!` or only pre-existing warnings unrelated to this migration.

- [ ] **Step 2: Launch the CMS app**

Use the Dart MCP tool `mcp__dart__launch_app` to start the `examples/cms_app` on macOS. Do not use `flutter run` directly.

- [ ] **Step 3: Verify navigation works**

Using Marionette (connect to the VM service URI from step 2):
1. App should land on the first document type route (guard redirect works)
2. Tap a document type in the sidebar → URL changes to `/:slug`
3. Click a document in the list → URL changes to `/:slug/:docId`, editor/preview appears
4. Click "Media Library" in sidebar footer → URL changes to `/media`, MediaBrowser appears
5. Breadcrumb back navigation works (clicking doc type in breadcrumb returns to `/:slug`)
6. Sign-out button calls `onSignOut` callback

- [ ] **Step 4: Run integration tests**

```bash
dart run build_runner build --delete-conflicting-outputs 2>/dev/null; \
flutter test packages/dart_desk/test/
```

Expected: all tests pass.

- [ ] **Step 5: Commit any fixes**

If any issues were found and fixed in steps 1–4, commit them:
```bash
git add -p
git commit -m "fix(dart_desk): post-migration analysis fixes"
```
