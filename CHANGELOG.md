# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2026-05-04

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dart_desk` - `v0.3.2`](#dart_desk---v032)
 - [`dart_desk_annotation` - `v0.3.2`](#dart_desk_annotation---v032)
 - [`dart_desk_generator` - `v0.3.2`](#dart_desk_generator---v032)
 - [`dart_desk_widgets` - `v0.1.2`](#dart_desk_widgets---v012)

---

#### `dart_desk` - `v0.3.2`

 - **REFACTOR**: 4-layer architecture, fixtures, screen goldens (#8).
 - **FIX**(annotation): split DeskContext so generator-safe barrel stays Flutter-free (#41).
 - **FIX**(image_input): deep-equal DeskData.value to stop rebuild churn (#31).
 - **FIX**(array_input): stream in-progress edits to parent for live preview (#30).
 - **FIX**(auth): silent token refresh no longer tears down UI (#28).
 - **FIX**(image_input): stop flooding logs with image bytes on upload (#27).
 - **FIX**(dart_desk): always show Publish button (drop conditional badge) (#24).
 - **FIX**(dart_desk): enable hierarchicalLoggingEnabled before setting per-logger level (#19).
 - **FIX**(dart_desk): editor footer alignment, clear-to-null, rename defaultValue → initialValue (#16).
 - **FIX**(dart_desk): auto-select default doc, hide status pill while loading, 500px editor (#10).
 - **FIX**(dart_desk): keep app mounted on auth refresh + save/publish bar UX (#9).
 - **FIX**(dart_desk): keep editor mounted while version data loads (#7).
 - **FIX**(dart_desk): encode Serializable values before writing to editedData.
 - **FEAT**(image_input): scale slider in Edit Framing transform mode (#39).
 - **FEAT**: image transform (scale + offset) + slide-over Edit Framing (#35).
 - **FEAT**: render autosaved drafts in version history (#29).
 - **FEAT**(dart_desk): DeskContext cross-document lookup for builders (#17).
 - **FEAT**(dart_desk): debugShowSignalLogs and debugShowClientLog flags (#18).
 - **FEAT**: DeskConditionContext for runtime-aware field conditions (#14).
 - **FEAT**(dart_desk): add Clear button + refactor image input to ViewModel (#12).
 - **DOCS**: rewrite dart_desk READMEs (#11).

#### `dart_desk_annotation` - `v0.3.2`

 - **FIX**(annotation): split DeskContext so generator-safe barrel stays Flutter-free (#41).
 - **FIX**(image_input): deep-equal DeskData.value to stop rebuild churn (#31).
 - **FIX**(dart_desk): editor footer alignment, clear-to-null, rename defaultValue → initialValue (#16).
 - **FEAT**(image_input): scale slider in Edit Framing transform mode (#39).
 - **FEAT**: image transform (scale + offset) + slide-over Edit Framing (#35).
 - **FEAT**(dart_desk): DeskContext cross-document lookup for builders (#17).
 - **FEAT**: DeskConditionContext for runtime-aware field conditions (#14).

#### `dart_desk_generator` - `v0.3.2`

 - **FIX**(annotation): split DeskContext so generator-safe barrel stays Flutter-free (#41).
 - **FIX**(dart_desk): editor footer alignment, clear-to-null, rename defaultValue → initialValue (#16).
 - **FEAT**: DeskConditionContext for runtime-aware field conditions (#14).

#### `dart_desk_widgets` - `v0.1.2`

 - **FIX**(annotation): split DeskContext so generator-safe barrel stays Flutter-free (#41).
 - **FIX**(image_input): deep-equal DeskData.value to stop rebuild churn (#31).
 - **FEAT**(image_input): scale slider in Edit Framing transform mode (#39).
 - **FEAT**: image transform (scale + offset) + slide-over Edit Framing (#35).


## 2026-05-04

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dart_desk` - `v0.3.1`](#dart_desk---v031)
 - [`dart_desk_annotation` - `v0.3.1`](#dart_desk_annotation---v031)
 - [`dart_desk_generator` - `v0.3.1`](#dart_desk_generator---v031)
 - [`dart_desk_widgets` - `v0.1.1`](#dart_desk_widgets---v011)

---

#### `dart_desk` - `v0.3.1`

 - **REFACTOR**: 4-layer architecture, fixtures, screen goldens (#8).
 - **FIX**(image_input): deep-equal DeskData.value to stop rebuild churn (#31).
 - **FIX**(array_input): stream in-progress edits to parent for live preview (#30).
 - **FIX**(auth): silent token refresh no longer tears down UI (#28).
 - **FIX**(image_input): stop flooding logs with image bytes on upload (#27).
 - **FIX**(dart_desk): always show Publish button (drop conditional badge) (#24).
 - **FIX**(dart_desk): enable hierarchicalLoggingEnabled before setting per-logger level (#19).
 - **FIX**(dart_desk): editor footer alignment, clear-to-null, rename defaultValue → initialValue (#16).
 - **FIX**(dart_desk): auto-select default doc, hide status pill while loading, 500px editor (#10).
 - **FIX**(dart_desk): keep app mounted on auth refresh + save/publish bar UX (#9).
 - **FIX**(dart_desk): keep editor mounted while version data loads (#7).
 - **FIX**(dart_desk): encode Serializable values before writing to editedData.
 - **FEAT**(image_input): scale slider in Edit Framing transform mode (#39).
 - **FEAT**: image transform (scale + offset) + slide-over Edit Framing (#35).
 - **FEAT**: render autosaved drafts in version history (#29).
 - **FEAT**(dart_desk): DeskContext cross-document lookup for builders (#17).
 - **FEAT**(dart_desk): debugShowSignalLogs and debugShowClientLog flags (#18).
 - **FEAT**: DeskConditionContext for runtime-aware field conditions (#14).
 - **FEAT**(dart_desk): add Clear button + refactor image input to ViewModel (#12).
 - **DOCS**: rewrite dart_desk READMEs (#11).

#### `dart_desk_annotation` - `v0.3.1`

 - **FIX**(image_input): deep-equal DeskData.value to stop rebuild churn (#31).
 - **FIX**(dart_desk): editor footer alignment, clear-to-null, rename defaultValue → initialValue (#16).
 - **FEAT**(image_input): scale slider in Edit Framing transform mode (#39).
 - **FEAT**: image transform (scale + offset) + slide-over Edit Framing (#35).
 - **FEAT**(dart_desk): DeskContext cross-document lookup for builders (#17).
 - **FEAT**: DeskConditionContext for runtime-aware field conditions (#14).

#### `dart_desk_generator` - `v0.3.1`

 - **FIX**(dart_desk): editor footer alignment, clear-to-null, rename defaultValue → initialValue (#16).
 - **FEAT**: DeskConditionContext for runtime-aware field conditions (#14).

#### `dart_desk_widgets` - `v0.1.1`

 - **FIX**(image_input): deep-equal DeskData.value to stop rebuild churn (#31).
 - **FEAT**(image_input): scale slider in Edit Framing transform mode (#39).
 - **FEAT**: image transform (scale + offset) + slide-over Edit Framing (#35).


## 2026-04-13

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dart_desk` - `v0.1.4`](#dart_desk---v014)
 - [`data_models` - `v1.1.0`](#data_models---v110)
 - [`example` - `v1.1.0`](#example---v110)
 - [`example_app` - `v1.1.0`](#example_app---v110)

---

#### `dart_desk` - `v0.1.4`

 - **FEAT**: redesign image hotspot/crop editor UI with golden tests.

#### `data_models` - `v1.1.0`

 - **REFACTOR**: update examples for unified ImageReference.
 - **REFACTOR**(data_models): remove configBuilder and example_app dependency.
 - **FIX**: deduplicate field lists for @DeskModel-annotated classes.
 - **FIX**: correctly handle unannotated fields in object array items.
 - **FIX**: restore Serializable bound, fix desk_app errors, unify workspace.
 - **FIX**: restore Serializable bound and fix analysis errors.
 - **FIX**(generator): support external projects outside workspace.
 - **FIX**: fix letOrNull returning null unconditionally and update dropdown API.
 - **FIX**: normalize featuredItems JSON string before mapper deserialization.
 - **FEAT**: redesign example app with restaurant-themed data models.
 - **FEAT**: use flutter_colorpicker package for color input.
 - **FEAT**: update barrel file and run code generation for new models.
 - **FEAT**: add RewardConfig data model.
 - **FEAT**: add UpsellConfig data model.
 - **FEAT**: add HeroConfig data model.
 - **FEAT**: add KioskConfig data model.
 - **FEAT**: add BrandTheme data model.
 - **FEAT**: add seed data for products and coupons.
 - **FEAT**(examples): migrate HomeScreenConfig image fields to ImageUrl.
 - **FEAT**: add DartDeskApp widget, DartDeskConfig, DartDesk InheritedWidget.
 - **FEAT**: extract DeskCollapseBar widget, fix editor button bar and panel layout.
 - **FEAT**: upgrade shadcn_ui to 0.52.1 and improve CMS input components.
 - **FEAT**: Add core data models for CMS including document, version, and media file management.

#### `example` - `v1.1.0`

 - **REFACTOR**: rename dart_desk_be_client to dart_desk_client.
 - **REFACTOR**: consolidate DartDeskBuiltInApp into DartDeskApp.
 - **REFACTOR**: replace dart_desk_be_client dep with onSignOut callback on StudioCoordinator.
 - **FIX**: restore Serializable bound, fix desk_app errors, unify workspace.
 - **FIX**(generator): support external projects outside workspace.
 - **FIX**: correct dependency paths and add marionette_flutter dep.
 - **FIX**: integration fixes for CMS studio architecture alignment.
 - **FEAT**: redesign example app with restaurant-themed data models.
 - **FEAT**: use flutter_colorpicker package for color input.
 - **FEAT**: wire up new document types in desk_app.
 - **FEAT**: send API key via Authorization header using DartDesk scheme.
 - **FEAT**: pass API_KEY from dart-define to DartDeskApp.
 - **FEAT**(desk_app): supply preview builder via DocumentTypeSpec.build().
 - **FEAT**: add field layout system for object inputs with row/column/group support.
 - **FEAT**: add cloud module with Serverpod IDP auth integration.
 - **FEAT**: render MediaBrowser for standalone media route in DeskStudio.
 - **FEAT**: add DartDeskApp widget, DartDeskConfig, DartDesk InheritedWidget.
 - **FEAT**: add media browser, hotspot input, E2E test infrastructure, and bug fixes.
 - **FEAT**: upgrade shadcn_ui to 0.52.1 and improve CMS input components.
 - **FEAT**: Wire up ZenRouter integration, exports, and example app.
 - **FEAT**: Update CMS app with auth integration and dependency updates.
 - **FEAT**: Add core data models for CMS including document, version, and media file management.
 - **DOCS**: update config to use project_id and dartdesk command name.

#### `example_app` - `v1.1.0`

 - **REFACTOR**: update examples for unified ImageReference.
 - **REFACTOR**: move Hotspot and CropRect to dart_desk_annotation.
 - **REFACTOR**: clean up unused imports, remove onDashboardPressed, switch to Zinc color scheme.
 - **FIX**: update example_app main.dart to use KioskPreview.
 - **FIX**: restore Serializable bound, fix desk_app errors, unify workspace.
 - **FEAT**: redesign example app with restaurant-themed data models.
 - **FEAT**: use flutter_colorpicker package for color input.
 - **FEAT**: add RewardPreview widget.
 - **FEAT**: add UpsellPreview widget.
 - **FEAT**: add HeroPreview widget.
 - **FEAT**: add KioskPreview widget.
 - **FEAT**: add BrandThemePreview widget.
 - **FEAT**(examples): migrate HomeScreenConfig image fields to ImageUrl.
 - **FEAT**: extract DeskCollapseBar widget, fix editor button bar and panel layout.
 - **FEAT**: Update CMS app with auth integration and dependency updates.
 - **FEAT**: Add core data models for CMS including document, version, and media file management.


## 2026-04-11

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dart_desk` - `v0.1.2`](#dart_desk---v012)

---

#### `dart_desk` - `v0.1.2`

 - **REFACTOR**: rename FlutterDeskAuth to DartDeskAuth and remove context extension.
 - **REFACTOR**: update CMS editor, resolver, and barrel exports for unified ImageReference.
 - **REFACTOR**: replace dart_desk ImageReference with re-export + MediaAsset bridge.
 - **REFACTOR**: update ImageUrl to wrap annotation-layer ImageReference.
 - **REFACTOR**: move Hotspot and CropRect to dart_desk_annotation.
 - **REFACTOR**: make DataSource non-null and consolidate editedData initialization.
 - **REFACTOR**: decouple DeskViewModel from DeskDocumentViewModel, depend on signals directly.
 - **REFACTOR**: update TestStringArrayOption and field declarations to use typed generics.
 - **REFACTOR**: replace dart_desk_be_client dep with onSignOut callback on StudioCoordinator.
 - **REFACTOR**: move QA test automation to packages/dart_desk/tests/qa/.
 - **REFACTOR**(dart_desk): simplify studio screens and slim down VersionScreen.
 - **REFACTOR**(dart_desk): replace addListener with AutoRouterObserver for signal sync.
 - **REFACTOR**: clean up unused imports, remove onDashboardPressed, switch to Zinc color scheme.
 - **REFACTOR**: rename dart_desk_be_client to dart_desk_client.
 - **REFACTOR**: update document_ref_dropdown to DeskMultiDropdownField.
 - **REFACTOR**: remove marionette_flutter from published API surface.
 - **REFACTOR**: replace disco with get_it in StudioProvider.
 - **REFACTOR**: move test reports, delete stale execution plan.
 - **REFACTOR**: migrate consumer files from disco to get_it.
 - **REFACTOR**: simplify CMS view model by removing pagination.
 - **REFACTOR**: migrate test files from disco to get_it.
 - **REFACTOR**: move E2E tests to packages/dart_desk/tests/e2e/.
 - **REFACTOR**: consolidate DartDeskBuiltInApp into DartDeskApp.
 - **REFACTOR**: DeskViewModel owns selectedDocumentId, remove signal params.
 - **REFACTOR**: wire reactive VM communication in StudioProvider.
 - **REFACTOR**(dart_desk): migrate media browser and view models to signals.
 - **REFACTOR**(dart_desk): drop coordinator from DeskDocumentTypeSidebar.
 - **REFACTOR**(dart_desk): remove setRouteParams from DeskViewModel.
 - **FIX**(dart_desk): replace setRouteParams with router navigation in DeskVersionHistory.
 - **FIX**(dart_desk): resolve analysis errors post auto_route migration.
 - **FIX**(dart_desk): move initial redirect from guard to StudioShellScreen.
 - **FIX**(dart_desk): configure replaceInRouteName for ScreenRoute suffix.
 - **FIX**(dart_desk): guard DeskViewModel access until StudioProvider builds.
 - **FIX**(dart_desk): flatten route tree, responsive layout, eliminate infinite loop.
 - **FIX**(dart_desk): sync signals after inner-router navigation.
 - **FIX**(dart_desk): mirror CRDT parent/child fix and fix TC-E2E-07-04.
 - **FIX**(dart_desk): non-nullable TransformUrlBuilder, fix mutable test fixture.
 - **FIX**(auth): wire DartDeskAuthKeyProvider into client for compound bearer token.
 - **FIX**(e2e): scope reset to e2e project only instead of TRUNCATE all.
 - **FIX**(e2e): add combined test runner and fix documents_data reset.
 - **FIX**: resolve analyzer warnings and dual round-trip in DeskViewModel.
 - **FIX**: restore Serializable bound, fix desk_app errors, unify workspace.
 - **FIX**: restore Serializable bound and fix analysis errors.
 - **FIX**: address code review issues for type-safe array field.
 - **FIX**(dart_desk): update for Serverpod 3.4.5 tenant refactor.
 - **FIX**: fix letOrNull returning null unconditionally and update dropdown API.
 - **FIX**: update stale test directory references in pubignore and docs.
 - **FIX**: use ShadThemeData in DeskFileInput and fix worktree path overrides.
 - **FIX**(widget): clear errorMessage when switching to URL tab in DeskImageInput.
 - **FIX**: correct dependency paths and add marionette_flutter dep.
 - **FIX**: update stale test_e2e paths in error resilience test spec.
 - **FIX**: update path references in test skills and setup scripts.
 - **FIX**: correct GitHub repository URL to ThangVuNguyenViet/dart_desk.
 - **FIX**(widget): remove redundant CrossAxisAlignment.center from OptionalFieldWrapper Row.
 - **FEAT**(dart_desk): redesign image framing editor ux.
 - **FEAT**: handle auto-default toast in delete handlers.
 - **FEAT**(widget): add URL tab and fix initial data loading in DeskImageInput.
 - **FEAT**: add setDefaultDocument and update deleteDocument return in DeskViewModel.
 - **FEAT**(dart_desk): implement VersionScreen.
 - **FEAT**(dart_desk): implement DocumentScreen.
 - **FEAT**(dart_desk): implement DocumentTypeScreen.
 - **FEAT**(dart_desk): implement MediaScreen.
 - **FEAT**(dart_desk): implement StudioShellScreen.
 - **FEAT**(dart_desk): extract DeskTopBar from StudioLayout.
 - **FEAT**: auto-default on create and delete in MockDataSource.
 - **FEAT**(dart_desk): add StudioRouter with DefaultDocTypeGuard.
 - **FEAT**(dart_desk): add @RoutePage screen stubs.
 - **FEAT**(dart_desk): add StudioConfig.
 - **FEAT**: implement setDefaultDocument in MockDataSource.
 - **FEAT**: add setDefaultDocument to DataSource interface.
 - **FEAT**: DeskDocumentViewModel.listenTo() with reactive effect.
 - **FEAT**: refactor mutations to use MutationSignal pattern and add publish button.
 - **FEAT**: add client-side MediaAsset, ImageReference, and supporting types.
 - **FEAT**(widget): add optional support to DeskDateInput, DeskDateTimeInput, DeskFileInput.
 - **FEAT**(widget): add optional support to DeskStringInput, DeskTextInput, DeskNumberInput, DeskUrlInput.
 - **FEAT**(array): enforce typed DeskArrayInput via generic function factory.
 - **FEAT**: update DeskDataSource interface and mock for MediaAsset.
 - **FEAT**: restore seed_data.sh with auth-only seed for E2E convenience.
 - **FEAT**(widget): add OptionalFieldWrapper for reusable optional input toggle.
 - **FEAT**: send API key via Authorization header using DartDesk scheme.
 - **FEAT**: redesign example app with restaurant-themed data models.
 - **FEAT**: use flutter_colorpicker package for color input.
 - **FEAT**(dart_desk): add ImageUrlMapper and export media types.
 - **FEAT**: add apiKey parameter to DartDeskApp and DartDeskAuth.
 - **FEAT**: add ApiKeyHttpClient for x-api-key header injection.
 - **FEAT**: add field layout system for object inputs with row/column/group support.
 - **FEAT**(annotation): add ImageRef.url getter with configurable defaultAssetResolver.
 - **FEAT**(dart_desk): add ImageUrl.fromJson and withTransform.
 - **FEAT**: add client-side quick metadata extractor (dimensions, hash).
 - **FEAT**(dart_desk): add MediaAsset.fromInlineJson for resolved image nodes.
 - **FEAT**: add type-dispatched default editors for primitive array types.
 - **FEAT**: add cloud module with Serverpod IDP auth integration.
 - **FEAT**(ui): refactor DeskArrayInput to use global registry for items.
 - **FEAT**: add DeskMultiDropdownField with ShadSelect.multiple support.
 - **FEAT**: resolve selected document title in preview builder.
 - **FEAT**: add TestDocumentRefDropdownOption to test_document_types.
 - **FEAT**: wire CloudDataSource.setDefaultDocument to Serverpod client.
 - **FEAT**: add setDefaultDocument to CloudDataSource.
 - **FEAT**: add ImageUrl builder and TransformUrlBuilder typedef.
 - **FEAT**: send API key via x-api-key custom header.
 - **FEAT**(dart_desk): add responsive_framework with CMS breakpoints.
 - **FEAT**: rewrite DeskImageInput with upload, blurHash, drop zone, ImageReference.
 - **FEAT**: show auto-default toast when first document is created.
 - **FEAT**: add Set as default to document tile overflow menu.
 - **FEAT**: replace Default text with ShadBadge in document tile.
 - **FEAT**(dart_desk): wire DeskStudioApp to StudioRouter + StudioConfig.
 - **FEAT**: render MediaBrowser for standalone media route in DeskStudio.
 - **FEAT**: add DartDeskApp widget, DartDeskConfig, DartDesk InheritedWidget.
 - **FEAT**(testing): seed MockDataSource with 4 media assets for E2E tests.
 - **FEAT**: add Media Library button to sidebar footer.
 - **FEAT**: add media browser, hotspot input, E2E test infrastructure, and bug fixes.
 - **FEAT**(widget): add optional toggle switch to DeskColorInput.
 - **DOCS**: update README descriptions for dart_desk.
 - **DOCS**: add QA test plans and clean up stale test reports.
 - **DOCS**: update E2E skill.md with seed command.
 - **DOCS**: add isDefault document UI design spec.
 - **DOCS**: add image system design spec (Sanity-inspired architecture).
 - **DOCS**: add isDefault UI implementation plan.
 - **DOCS**: add unified test suite README.

