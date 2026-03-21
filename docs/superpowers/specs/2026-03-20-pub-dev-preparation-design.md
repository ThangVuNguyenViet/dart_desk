# Pub.dev Publication Preparation — Design Spec

## Goal

Prepare the three `dart_desk` packages for publication on pub.dev without actually publishing.

## Packages (publish order)

1. **dart_desk_annotation** — annotations + validators (Flutter package due to `form_builder_validators` dep)
2. **dart_desk_generator** — code generator, depends on annotation
3. **dart_desk** — main Flutter widget library, depends on both

## Changes Required

### All three packages

- Remove `publish_to: 'none'`
- Remove `resolution: workspace` (workspace-only directive, invalid for published packages)
- Add `homepage` and `repository` fields (use GitHub repo URL — TBD from user, placeholder until confirmed)
- Add `topics` field for pub.dev discoverability
- Add MIT `LICENSE` file
- Add `CHANGELOG.md` with initial `0.1.0` entry
- Add `.pubignore` to exclude dev files
- Add `README.md` (create or improve existing)

### dart_desk_annotation

- Improve existing `README.md`
- Add `example/` directory with a simple usage example
- Keep `form_builder_validators` and `flutter` deps — they are used by `validators.dart` which provides `CmsValidator`, `RequiredValidator` etc. This is intentional, not accidental.
- Add `topics: [cms, annotations, flutter]`

### dart_desk_generator

- **Create `README.md`** (currently missing)
- Add `example/` directory with a simple usage example
- For publishing: `dart_desk_annotation` path dep must be replaced with `^0.1.0` version constraint
- Add `topics: [cms, code-generation, flutter]`

### dart_desk (main package)

- **Create `README.md`** with package description, features, installation, basic usage
- **Remove `dart_desk_be_client` dependency**: only used for `context.signOut()` in `studio_layout.dart` (line 2 import, line 200 usage). Replace with an `onSignOut` callback parameter injected via `StudioProvider` or the studio widget constructor.
- **Resolve `marionette_flutter` dependency**: used in `marionette_config.dart` which is exported from `lib/testing.dart`. Since exported libraries cannot use dev dependencies, the solution is: **remove `marionette_config.dart` from `lib/testing.dart` exports and don't ship it as part of the published package.** Instead, keep it in the workspace for local testing only. Add it to `.pubignore`. Consumers can write their own marionette config if needed.
- **Remove empty directories**: `lib/src/core/`, `lib/src/generators/`
- **Remove orphaned `packages/flutter_cms_annotation/`** nested package
- **Add `example/` directory**
- For publishing: `dart_desk_annotation` path dep must be replaced with `^0.1.0` version constraint
- Add `topics: [cms, flutter, content-management]`

### Workspace root (dev environment cleanup, not publish blockers)

- Keep `dependency_overrides` for signals — these are workspace-level and don't affect individual package publishing. Note: published packages will use `signals ^6.1.0` from pub.dev.
- Remove `app.log` from tracking and add to `.gitignore`

## Pre-Publish Workflow

For each package (in order: annotation → generator → main):

1. Create a `publish` branch
2. In the package's `pubspec.yaml`:
   - Remove `resolution: workspace`
   - Replace path dependencies with version constraints (e.g., `dart_desk_annotation: ^0.1.0`)
   - Remove `marionette_flutter` dependency (main package only)
3. Run `dart pub publish --dry-run`
4. Fix any issues
5. Run `dart pub publish` (when ready — not in scope of this prep work)
6. Revert pubspec changes on the working branch

We'll create a `tool/publish.sh` script documenting these steps.

## Inter-Package Version Strategy

All packages start at `0.1.0`. Cross-references use `^0.1.0` (which means `>=0.1.0 <0.2.0` for pre-1.0 packages). When any package has a breaking change, bump the minor version of all three together.

## .pubignore (per package, adapted to each)

Common entries:
```
CLAUDE.md
*.skill
*.iml
.specify/
devtools_options.yaml
tests/
app.log
flutter_*.log
sanity-fields-example.json
docs/
packages/
```

For `dart_desk` specifically, also exclude:
```
lib/src/studio/core/marionette_config.dart
```

## Success Criteria

- `dart pub publish --dry-run` passes for all three packages (after pre-publish pubspec edits)
- Each package has: LICENSE, CHANGELOG.md, README.md, example/, .pubignore
- No path dependencies in published pubspecs
- No `resolution: workspace` in published pubspecs
- `dart analyze` clean on all packages
- `marionette_flutter` not in published dependency tree
- `dart_desk_be_client` not in published dependency tree
