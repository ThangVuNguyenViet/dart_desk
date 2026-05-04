## 0.3.3

 - **FEAT**(dart_desk): DeskListenable.asValueListenable() extension.

## 0.3.2

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

## 0.3.1

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

## 0.3.0

> **Breaking**: `defaultValue` on field annotations renamed to `initialValue` (#16). Update annotation usages and regenerate (`dart run build_runner build`).

 - **FEAT**: image transform (scale + offset) + slide-over Edit Framing (#35).
 - **FEAT**: Save/Publish redesign — autosave, `hasUnpublishedChanges`, event-style version history (#20).
 - **FEAT**: Optional fields driven by Dart nullability, propagated across all inputs (#15).
 - **FEAT**: render autosaved drafts in version history (#29).
 - **FEAT**(dart_desk): DeskContext cross-document lookup for builders (#17).
 - **FEAT**: DeskConditionContext for runtime-aware field conditions (#14).
 - **FEAT**(dart_desk): debugShowSignalLogs and debugShowClientLog flags (#18).
 - **FEAT**(dart_desk): add Clear button + refactor image input to ViewModel (#12).
 - **FIX**: drop legacy publish endpoint, polish editor toolbar (#21).
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
 - **REFACTOR**: 4-layer test architecture, fixtures, screen goldens (#8).
 - **DOCS**: rewrite dart_desk READMEs (#11).
 - **CHORE**: bump `dart_desk_annotation` to `^0.3.0`, `dart_desk_widgets` to `^0.1.0`.
 - **CHORE**: pin goldens to `linux/arm64`; per-pixel tolerance back to 0.1% (#36).

## 0.2.0

> **Breaking**: `Cms*` prefix renamed to `Desk*` across the public API (e.g. `CmsImageInput` → `DeskImageInput`, `CmsDocumentViewModel` → `DeskDocumentViewModel`). Run a workspace-wide find/replace from `Cms` to `Desk` on identifiers from this package.

### Features
- Unified image input with server-side metadata extraction and BlurHash perf fix
- UUID-backed document models
- Conditional field visibility and dropdown search
- Forgot password flow in `DartDeskAuth`
- Media gallery delete UX with hover trash and confirm dialog
- Aura Gastronomy CMS example

### Fixes
- Reject sign-in when user isn't a member of the API key's project
- Keep `DeskImageInput` state alive across `ListView` scroll
- Guard `DeskDocumentViewModel` async writes against disposal
- Studio save/publish bugs, Google sign-in, and button loading UX
- Update `cloud_data_source` for new `PaginatedDocuments` response shape and 410 handling
- Make integration tests self-cleaning and prod-compatible

### Chore
- Bump `dart_desk_annotation` to `^0.2.0`
- Bump `dart_desk_client` to `^0.2.0` (UUID primary keys)

## 0.1.4

 - **FEAT**: redesign image hotspot/crop editor UI with golden tests.

## 0.1.3

- Pin dependency versions: `dart_desk_annotation: ^0.1.1`, `dart_desk_client: ^0.1.1`

## 0.1.2

### Features
- **Studio screens** — DocumentScreen, DocumentTypeScreen, MediaScreen, VersionScreen, StudioShellScreen with auto_route navigation
- **Image system** — rewritten DeskImageInput with upload, blurHash, drop zone, hotspot editor; MediaAsset and ImageReference types
- **Auth & cloud** — Serverpod IDP auth module, API key injection, compound bearer token
- **Input widgets** — optional support for all primitive inputs, DeskMultiDropdownField, color picker, field layout system (row/column/group)
- **Array fields** — typed DeskArrayInput with global registry and type-dispatched default editors
- **Document management** — default document support (set/auto-default on create/delete), publish button with MutationSignal pattern
- **Media browser** — standalone media route with sidebar button
- **App shell** — DartDeskApp widget, StudioConfig, responsive breakpoints

### Fixes
- Defer signal sync in StudioRouteObserver to prevent framework assertion during navigation
- Guard DeskViewModel access until StudioProvider builds
- Flatten route tree and fix infinite loop in responsive layout
- Fix letOrNull, dropdown API, and dual round-trip in DeskViewModel

### Refactors
- Migrate DI from disco to get_it
- Rename FlutterDeskAuth → DartDeskAuth
- Decouple DeskViewModel from DeskDocumentViewModel
- Unify ImageReference across annotation and widget layers

## 0.1.1

- Cloud-first documentation with Dart Desk Cloud quick start
- Expanded example app with 5 document types demonstrating all field types
- Architecture guide for the three-package pattern
- Advanced patterns documentation (default merging, custom editors, async dropdowns)
- Added dart_desk_cli and dart_desk_client to related packages

## 0.1.0

- Initial release
- Studio layout with navigation and document management
- Input widgets for all CMS field types
- Reactive state management with signals
- shadcn_ui-based component library
