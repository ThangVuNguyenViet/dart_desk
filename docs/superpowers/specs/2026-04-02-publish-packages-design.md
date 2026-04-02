# Publish dart_desk packages to pub.dev — v0.1.0

## Overview

Set up melos for the monorepo, prepare all 3 packages for pub.dev publishing, write READMEs, CHANGELOGs, LICENSE files, and publish v0.1.0.

## Packages

| Package | Version | Dependencies |
|---|---|---|
| `dart_desk_annotation` | 0.1.0 | None (internal) |
| `dart_desk_generator` | 0.1.0 | `dart_desk_annotation` |
| `dart_desk` | 0.1.0 | `dart_desk_annotation`, `dart_desk_generator` |

Repository: `https://github.com/ThangVuNguyenViet/dart_desk`

License: BSD 3-Clause (all packages)

## 1. Melos Setup

- Add `melos.yaml` at workspace root with:
  - Package globs pointing to `packages/*`
  - Conventional commit scopes: `dart_desk`, `dart_desk_annotation`, `dart_desk_generator`
  - Version config for conventional commits
- Add `melos` as a dev dependency in root `pubspec.yaml`

## 2. Package Preparation (all 3)

For each package:

- **LICENSE** — BSD 3-Clause, copyright holder: Viet Thang Vu Nguyen
- **CHANGELOG.md** — Handwritten initial v0.1.0 entry summarizing features
- **pubspec.yaml cleanup:**
  - `description` (60-180 chars)
  - `homepage: https://github.com/ThangVuNguyenViet/dart_desk`
  - `repository: https://github.com/ThangVuNguyenViet/dart_desk`
  - `issue_tracker: https://github.com/ThangVuNguyenViet/dart_desk/issues`
  - `topics` (max 5, lowercase, alphanumeric+hyphens)
  - Remove `publish_to: "none"` from `dart_desk_generator`
  - Verify all dependency version constraints are appropriate for publishing

## 3. README Content

### dart_desk (main package)

- **Tagline:** Schema-first content studio for Flutter
- **What it is:** A Flutter widget library for building content management studios — define your schema in Dart, generate the editing UI automatically
- **Key features:**
  - 16 built-in field types (string, text, number, boolean, date, datetime, url, dropdown, multi-dropdown, array, object, block/rich-text, image, file, color, geopoint)
  - Media library with upload, search, deduplication, blurhash placeholders, hotspot/crop editor
  - Document versioning with CRDT-based collaborative editing, draft/publish/archive workflow
  - Backend-agnostic via `DataSource` interface
  - Reactive state with `signals` — fine-grained updates
  - Built on `shadcn_ui` with dark/light themes
  - Responsive layout (mobile/tablet/desktop) with resizable panels
  - Deep-linkable routing via `auto_route`
  - Code generation via `dart_desk_annotation` + `dart_desk_generator`
- **Quick start:** Annotate a class → run build_runner → wire up CmsStudioApp
- **Code examples:** Annotation, generated fields, studio app setup
- **Links** to `dart_desk_annotation` and `dart_desk_generator`

### dart_desk_annotation

- What annotations are available
- Quick reference table of all field annotations
- Link to `dart_desk` for the full picture

### dart_desk_generator

- What it generates (field lists, DocumentTypeSpec, CmsData wrapper)
- Setup: build.yaml config, build_runner command
- Link to `dart_desk` for the full picture

## 4. pub.dev Score Optimization

- Run `dart pub publish --dry-run` on each package
- Run `pana` locally to check pub points
- Ensure: valid description, example/ or inline examples, platform support, documented exports

## 5. Publish Order

Managed by melos, logical sequence:
1. `dart_desk_annotation`
2. `dart_desk_generator`
3. `dart_desk`

## 6. Conventions Going Forward

- **Commits:** Conventional commits (`feat(scope):`, `fix(scope):`, `chore(scope):`, etc.)
- **Workflow:** PR to main only, no direct push
- **Releases:** `melos version` generates changelogs from conventional commits, `melos publish` publishes in dependency order
- **Tags:** melos auto-tags `v0.1.0` per package
