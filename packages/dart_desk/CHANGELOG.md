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
