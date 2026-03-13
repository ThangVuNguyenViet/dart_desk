# CMS Studio Architecture Alignment Design

**Date:** 2026-03-14
**Status:** Draft
**Scope:** Refactor `flutter_cms` package and example app to align with `flutter_cms_be_manage` architecture patterns.

---

## Overview

Align the CMS studio app with the manage app's architecture: ZenRouter for URL-driven navigation, dark theme, top bar layout shell, and consistent component styling. The studio remains a separate app from the manage app, sharing patterns and theme but not a codebase entry point.

## Goals

1. Replace signal-based navigation with ZenRouter URL-driven routing
2. Switch to dark theme matching the manage app
3. Add a top bar layout shell with branding and user controls
4. Align component styling with manage app patterns
5. Keep the 4-panel resizable layout as the studio's content area
6. Maintain signals for reactive data fetching and form state

## Non-Goals

- Merging the studio and manage apps into a single entry point
- Changing the data source abstraction or form/field system
- Adding new CMS features beyond the architecture refactor
- Creating a shared design system package (may be done later)

---

## 1. Routing Architecture

### Dependencies

Add `zenrouter` to the `flutter_cms` package's `pubspec.yaml`.

### StudioCoordinator

A `Coordinator<StudioRoute>` that manages all CMS studio navigation.

**Route structure:**

| URL Pattern | Route Class | Description |
|---|---|---|
| `/` | Redirect | Redirects to first registered document type |
| `/{documentTypeSlug}` | `DocumentTypeRoute` | Shows doc list, empty preview + editor |
| `/{documentTypeSlug}/{documentId}` | `DocumentRoute` | Shows doc list + preview + editor with latest version |
| `/{documentTypeSlug}/{documentId}/{versionId}` | `VersionRoute` | Shows doc list + preview + specific version in editor |

**Navigation stack:**

- `studioStack` — manages the 4-panel content area. Routes push state into the panels rather than replacing the whole screen.

**Route parsing:**

`StudioCoordinator.parseRouteFromUri()` converts URLs to route objects. Each route class implements `toUri()` for URL generation and `build()` for widget construction.

**How routes map to panels:**

- `/{documentTypeSlug}` — Sidebar highlights the type, document list panel populates, preview + editor show empty states
- `/{documentTypeSlug}/{documentId}` — Above + document list highlights the doc, latest version loads in preview + editor
- `/{documentTypeSlug}/{documentId}/{versionId}` — Above + specific version loads in editor

**Layout definition:** `StudioCoordinator.defineLayout()` registers `StudioLayout` as the layout for all studio routes via `RouteLayout.defineLayout`, following the same pattern as `ManageCoordinator`.

**Key principle:** Navigation calls like `coordinator.push(DocumentRoute(...))` push a new URL. Panels react to route parameters. Signals handle data fetching and form state, not navigation state.

### Route Files

New files in `lib/src/studio/routes/`:

- `studio_coordinator.dart` — Main coordinator with route parsing and layout definition
- `studio_route.dart` — Base `StudioRoute` class extending `RouteTarget`
- `document_type_route.dart` — Route for `/{documentTypeSlug}`
- `document_route.dart` — Route for `/{documentTypeSlug}/{documentId}`
- `version_route.dart` — Route for `/{documentTypeSlug}/{documentId}/{versionId}`

---

## 2. Layout Architecture

### StudioLayout

A new top-level shell widget, analogous to `ManageLayout` in the manage app.

**Structure:**

```
StudioLayout
├─ _TopBar (48px, full width)
│   ├─ Left: App icon + CMS title (from header config)
│   ├─ Center: (empty, reserved for future breadcrumbs)
│   └─ Right: "Open Dashboard" ghost button (links to manage app URL, configurable) + User avatar/menu + Logout
├─ Expanded: child (the 4-panel resizable content)
```

**Top bar styling:**

- 48px height
- `theme.colorScheme.background` with bottom border (`theme.colorScheme.border`)
- Title: `theme.textTheme.large` with bold weight
- Action buttons: `ShadButton.ghost`
- Matches manage app's `_TopBar` pattern exactly

### 4-Panel Resizable Layout

The existing `ResizableContainer` layout stays structurally unchanged. Panels become route-aware:

**Panel 1: Sidebar (ratio 0.2, non-resizable)**
- Document type list from registered types
- Each item navigates to `/{documentTypeSlug}` via coordinator
- Active item highlighted based on current route's `documentTypeSlug`

**Panel 2: Document List (resizable ~20%)**
- Header: type name + search + create button
- List of documents, each navigates to `/{documentTypeSlug}/{documentId}`
- Active document highlighted based on current route's `documentId`

**Panel 3: Content Preview (resizable ~40%)**
- Renders selected document's builder with version data
- Reads document/version from route params

**Panel 4: Document Editor (resizable ~20%)**
- Version history items navigate to `/{documentTypeSlug}/{documentId}/{versionId}`
- Form fields for editing
- Save/Discard buttons

### DefaultCmsHeader Changes

The existing `DefaultCmsHeader` widget is repurposed. Its properties (`name`, `title`, `subtitle`, `icon`) feed the top bar's branding section rather than rendering inside the sidebar panel. The sidebar panel no longer has its own header — document type navigation starts immediately.

---

## 3. Theme & Styling

### Dark Theme

Switch from light to dark theme:

```dart
ShadApp.router(
  theme: ShadThemeData(
    brightness: Brightness.dark,
    colorScheme: const ShadSlateColorScheme.dark(),
  ),
)
```

### Panel Styling

| Element | Token |
|---|---|
| Panel backgrounds | `theme.colorScheme.background` |
| Panel borders/dividers | `theme.colorScheme.border` |
| Selected items (sidebar, doc list) | `theme.colorScheme.accent` |
| Primary text | `theme.colorScheme.foreground` |
| Secondary text | `theme.colorScheme.mutedForeground` |
| Headers | `theme.textTheme.h3` |
| Descriptions | `theme.textTheme.muted` |

### Component Alignment

| Component | Pattern |
|---|---|
| Document list items | Styled like manage's table rows with hover states |
| Sidebar nav items | Icon + label, accent highlight on active (like manage's `ApiLayout` sidebar) |
| Create/Save buttons | `ShadButton` primary |
| Delete/Discard buttons | `ShadButton.destructive` / `ShadButton.outline` |
| Version status | `ShadBadge` (published, draft, archived) — replace existing `_StatusBadge` which has hardcoded light-mode colors |
| Search input | `ShadInputFormField` |
| Confirmation dialogs | `showShadDialog` matching manage patterns |
| Empty states | Lucide icon + muted text, centered |
| Icons | Lucide icons throughout (replacing Material Icons) |

---

## 4. Auth & Data Flow

### Authentication

`FlutterCmsAuth` is a stateful widget that manages its own auth lifecycle internally — it creates a `Client`, initializes Google Sign-In, and conditionally renders either its login UI or its `builder` child. It is not a simple screen that can be wrapped in a route.

**Integration pattern:** `FlutterCmsAuth` wraps the entire router output (like the manage app's `AuthGate`), not as a route destination. The `/login` route is removed from the coordinator.

**Flow:**

1. App starts → `FlutterCmsAuth` widget wraps the `ShadApp.router`/coordinator output
2. Not authenticated → `FlutterCmsAuth` shows its login UI (Google Sign In)
3. Authenticated → `FlutterCmsAuth.builder` provides the client → `ShadApp.router` with `StudioCoordinator` renders
4. Coordinator redirects `/` to `/{firstDocumentTypeSlug}`

**Dark theme fix:** The current `FlutterCmsAuth` login screen wraps itself in `ShadTheme(data: ShadThemeData(), ...)` which overrides to light theme. This must be removed so the login screen inherits the app's dark theme.

### Data Flow with Routes

1. URL changes to `/{documentTypeSlug}` → Coordinator parses route → `CmsViewModel.setRouteParams(slug, null, null)` → documents signal fetches list
2. URL changes to `/{documentTypeSlug}/{documentId}` → `CmsViewModel.setRouteParams(slug, docId, null)` → versions signal fetches, latest version loads
3. URL changes to `/{documentTypeSlug}/{documentId}/{versionId}` → `CmsViewModel.setRouteParams(slug, docId, versionId)` → specific version data loads

### CmsViewModel Changes

**Remove:**
- `selectDocumentType()` method
- `selectDocument()` method (note: its side effects — clearing `selectedVersionId` and setting `_documentViewModel.documentId` — move into `setRouteParams()`)
- `selectVersion()` method
- `selectedDocumentType` signal (replaced by route param + computed lookup)

**Add:**
- `setRouteParams(String? documentTypeSlug, String? documentId, String? versionId)` — called by coordinator when route changes. This method:
  - Sets `currentDocumentTypeSlug`, `currentDocumentId`, `currentVersionId` signals
  - Updates `_documentViewModel.documentId` when documentId changes
- Route param signals: `currentDocumentTypeSlug`, `currentDocumentId`, `currentVersionId`
- `currentDocumentType` — a computed signal that resolves `currentDocumentTypeSlug` to a `CmsDocumentType` object by looking up the slug in the registered document types list. This is needed by `createDocument()`, `updateDocumentData()`, and other methods that require the full object.

**Update:**
- `queryParams` computed signal — currently depends on `selectedDocumentType.value?.name`. Update to derive from `currentDocumentType` (the new computed signal) instead.
- `createDocument()`, `updateDocumentData()` — update to read from `currentDocumentType` instead of `selectedDocumentType`

**Keep unchanged:**
- `documentsContainer`, `versionsContainer`, `documentDataContainer` (react to new param signals via updated `queryParams`)
- `isSaving`, `searchQuery`, `page`, `pageSize` signals
- `publishVersion()`, `archiveVersion()` methods
- All form state management

### CmsDocumentViewModel Changes

- `documentId` signal is now set by `CmsViewModel.setRouteParams()` when the route's `documentId` param changes (previously set by `selectDocument()`)
- No other changes to its interface or behavior

### No Changes To

- `CmsDataSource` interface and `CloudDataSource` implementation
- Form/field system (`CmsFieldInputRegistry`, all input widgets)
- Document type registration (`CmsDocumentTypeDecoration`)
- Preview builder pattern

---

## 5. Files Summary

### New Files

| File | Purpose |
|---|---|
| `lib/src/studio/routes/studio_coordinator.dart` | ZenRouter coordinator with route parsing and layout |
| `lib/src/studio/routes/studio_route.dart` | Base route class |
| `lib/src/studio/routes/document_type_route.dart` | Document type selection route |
| `lib/src/studio/routes/document_route.dart` | Document selection route |
| `lib/src/studio/routes/version_route.dart` | Version selection route |
| `lib/src/studio/routes/studio_layout.dart` | Top bar + content shell |

### Modified Files

| File | Changes |
|---|---|
| `lib/src/studio/cms_studio_app.dart` | Use `ShadApp.router` with coordinator, dark theme |
| `lib/src/studio/screens/cms_studio.dart` | Panels read from route params instead of selection signals |
| `lib/src/studio/core/view_models/cms_view_model.dart` | Replace `selectX()` with `setRouteParams()`, add `currentDocumentType` computed, update `queryParams` |
| `lib/src/studio/core/view_models/cms_document_view_model.dart` | `documentId` now driven by route params via `setRouteParams()` |
| `lib/src/studio/components/navigation/cms_document_type_sidebar.dart` | Items navigate via coordinator instead of calling viewModel |
| `lib/src/studio/components/common/cms_document_type_item.dart` | Navigation link instead of signal mutation |
| `lib/src/studio/components/common/default_cms_header.dart` | Repurposed for top bar branding |
| `lib/src/studio/theme/theme.dart` | Dark theme as default |
| `lib/src/studio/components/auth/flutter_cms_auth.dart` (or equivalent) | Remove hardcoded light theme override on login screen |
| `pubspec.yaml` (flutter_cms package) | Add zenrouter dependency |
| `examples/cms_app/lib/main.dart` | Update to use StudioCoordinator, dark theme, new layout |

### Removed Logic

- Signal-based selection methods in `CmsViewModel` (`selectDocumentType`, `selectDocument`, `selectVersion`)
- Direct signal reads for navigation state in panels (replaced by route param reads)
