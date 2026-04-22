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
