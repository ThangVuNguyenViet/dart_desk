# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2026-04-11

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dart_desk` - `v0.1.2`](#dart_desk---v012)

---

#### `dart_desk` - `v0.1.2`

 - **REFACTOR**: rename FlutterCmsAuth to DartDeskAuth and remove context extension.
 - **REFACTOR**: update CMS editor, resolver, and barrel exports for unified ImageReference.
 - **REFACTOR**: replace dart_desk ImageReference with re-export + MediaAsset bridge.
 - **REFACTOR**: update ImageUrl to wrap annotation-layer ImageReference.
 - **REFACTOR**: move Hotspot and CropRect to dart_desk_annotation.
 - **REFACTOR**: make DataSource non-null and consolidate editedData initialization.
 - **REFACTOR**: decouple CmsViewModel from CmsDocumentViewModel, depend on signals directly.
 - **REFACTOR**: update TestStringArrayOption and field declarations to use typed generics.
 - **REFACTOR**: replace dart_desk_be_client dep with onSignOut callback on StudioCoordinator.
 - **REFACTOR**: move QA test automation to packages/dart_desk/tests/qa/.
 - **REFACTOR**(dart_desk): simplify studio screens and slim down VersionScreen.
 - **REFACTOR**(dart_desk): replace addListener with AutoRouterObserver for signal sync.
 - **REFACTOR**: clean up unused imports, remove onDashboardPressed, switch to Zinc color scheme.
 - **REFACTOR**: rename dart_desk_be_client to dart_desk_client.
 - **REFACTOR**: update document_ref_dropdown to CmsMultiDropdownField.
 - **REFACTOR**: remove marionette_flutter from published API surface.
 - **REFACTOR**: replace disco with get_it in StudioProvider.
 - **REFACTOR**: move test reports, delete stale execution plan.
 - **REFACTOR**: migrate consumer files from disco to get_it.
 - **REFACTOR**: simplify CMS view model by removing pagination.
 - **REFACTOR**: migrate test files from disco to get_it.
 - **REFACTOR**: move E2E tests to packages/dart_desk/tests/e2e/.
 - **REFACTOR**: consolidate DartDeskBuiltInApp into DartDeskApp.
 - **REFACTOR**: CmsViewModel owns selectedDocumentId, remove signal params.
 - **REFACTOR**: wire reactive VM communication in StudioProvider.
 - **REFACTOR**(dart_desk): migrate media browser and view models to signals.
 - **REFACTOR**(dart_desk): drop coordinator from CmsDocumentTypeSidebar.
 - **REFACTOR**(dart_desk): remove setRouteParams from CmsViewModel.
 - **FIX**(dart_desk): replace setRouteParams with router navigation in CmsVersionHistory.
 - **FIX**(dart_desk): resolve analysis errors post auto_route migration.
 - **FIX**(dart_desk): move initial redirect from guard to StudioShellScreen.
 - **FIX**(dart_desk): configure replaceInRouteName for ScreenRoute suffix.
 - **FIX**(dart_desk): guard CmsViewModel access until StudioProvider builds.
 - **FIX**(dart_desk): flatten route tree, responsive layout, eliminate infinite loop.
 - **FIX**(dart_desk): sync signals after inner-router navigation.
 - **FIX**(dart_desk): mirror CRDT parent/child fix and fix TC-E2E-07-04.
 - **FIX**(dart_desk): non-nullable TransformUrlBuilder, fix mutable test fixture.
 - **FIX**(auth): wire DartDeskAuthKeyProvider into client for compound bearer token.
 - **FIX**(e2e): scope reset to e2e project only instead of TRUNCATE all.
 - **FIX**(e2e): add combined test runner and fix documents_data reset.
 - **FIX**: resolve analyzer warnings and dual round-trip in CmsViewModel.
 - **FIX**: restore Serializable bound, fix cms_app errors, unify workspace.
 - **FIX**: restore Serializable bound and fix analysis errors.
 - **FIX**: address code review issues for type-safe array field.
 - **FIX**(dart_desk): update for Serverpod 3.4.5 tenant refactor.
 - **FIX**: fix letOrNull returning null unconditionally and update dropdown API.
 - **FIX**: update stale test directory references in pubignore and docs.
 - **FIX**: use ShadThemeData in CmsFileInput and fix worktree path overrides.
 - **FIX**(widget): clear errorMessage when switching to URL tab in CmsImageInput.
 - **FIX**: correct dependency paths and add marionette_flutter dep.
 - **FIX**: update stale test_e2e paths in error resilience test spec.
 - **FIX**: update path references in test skills and setup scripts.
 - **FIX**: correct GitHub repository URL to ThangVuNguyenViet/dart_desk.
 - **FIX**(widget): remove redundant CrossAxisAlignment.center from OptionalFieldWrapper Row.
 - **FEAT**(dart_desk): redesign image framing editor ux.
 - **FEAT**: handle auto-default toast in delete handlers.
 - **FEAT**(widget): add URL tab and fix initial data loading in CmsImageInput.
 - **FEAT**: add setDefaultDocument and update deleteDocument return in CmsViewModel.
 - **FEAT**(dart_desk): implement VersionScreen.
 - **FEAT**(dart_desk): implement DocumentScreen.
 - **FEAT**(dart_desk): implement DocumentTypeScreen.
 - **FEAT**(dart_desk): implement MediaScreen.
 - **FEAT**(dart_desk): implement StudioShellScreen.
 - **FEAT**(dart_desk): extract CmsTopBar from StudioLayout.
 - **FEAT**: auto-default on create and delete in MockDataSource.
 - **FEAT**(dart_desk): add StudioRouter with DefaultDocTypeGuard.
 - **FEAT**(dart_desk): add @RoutePage screen stubs.
 - **FEAT**(dart_desk): add StudioConfig.
 - **FEAT**: implement setDefaultDocument in MockDataSource.
 - **FEAT**: add setDefaultDocument to DataSource interface.
 - **FEAT**: CmsDocumentViewModel.listenTo() with reactive effect.
 - **FEAT**: refactor mutations to use MutationSignal pattern and add publish button.
 - **FEAT**: add client-side MediaAsset, ImageReference, and supporting types.
 - **FEAT**(widget): add optional support to CmsDateInput, CmsDateTimeInput, CmsFileInput.
 - **FEAT**(widget): add optional support to CmsStringInput, CmsTextInput, CmsNumberInput, CmsUrlInput.
 - **FEAT**(array): enforce typed CmsArrayInput via generic function factory.
 - **FEAT**: update CmsDataSource interface and mock for MediaAsset.
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
 - **FEAT**(ui): refactor CmsArrayInput to use global registry for items.
 - **FEAT**: add CmsMultiDropdownField with ShadSelect.multiple support.
 - **FEAT**: resolve selected document title in preview builder.
 - **FEAT**: add TestDocumentRefDropdownOption to test_document_types.
 - **FEAT**: wire CloudDataSource.setDefaultDocument to Serverpod client.
 - **FEAT**: add setDefaultDocument to CloudDataSource.
 - **FEAT**: add ImageUrl builder and TransformUrlBuilder typedef.
 - **FEAT**: send API key via x-api-key custom header.
 - **FEAT**(dart_desk): add responsive_framework with CMS breakpoints.
 - **FEAT**: rewrite CmsImageInput with upload, blurHash, drop zone, ImageReference.
 - **FEAT**: show auto-default toast when first document is created.
 - **FEAT**: add Set as default to document tile overflow menu.
 - **FEAT**: replace Default text with ShadBadge in document tile.
 - **FEAT**(dart_desk): wire CmsStudioApp to StudioRouter + StudioConfig.
 - **FEAT**: render MediaBrowser for standalone media route in CmsStudio.
 - **FEAT**: add DartDeskApp widget, DartDeskConfig, DartDesk InheritedWidget.
 - **FEAT**(testing): seed MockDataSource with 4 media assets for E2E tests.
 - **FEAT**: add Media Library button to sidebar footer.
 - **FEAT**: add media browser, hotspot input, E2E test infrastructure, and bug fixes.
 - **FEAT**(widget): add optional toggle switch to CmsColorInput.
 - **DOCS**: update README descriptions for dart_desk.
 - **DOCS**: add QA test plans and clean up stale test reports.
 - **DOCS**: update E2E skill.md with seed command.
 - **DOCS**: add isDefault document UI design spec.
 - **DOCS**: add image system design spec (Sanity-inspired architecture).
 - **DOCS**: add isDefault UI implementation plan.
 - **DOCS**: add unified test suite README.

