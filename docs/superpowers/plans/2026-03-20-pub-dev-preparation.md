# Pub.dev Publication Preparation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare dart_desk_annotation, dart_desk_generator, and dart_desk packages for pub.dev publication.

**Architecture:** Three packages published in dependency order (annotation → generator → main). Path dependencies replaced with version constraints for publishing. Marionette and backend client dependencies removed from published surface.

**Tech Stack:** Dart 3.8, Flutter, pub.dev

**Spec:** `docs/superpowers/specs/2026-03-20-pub-dev-preparation-design.md`

---

### Task 1: Cleanup — Remove Dead Files and Directories

**Files:**
- Delete: `packages/dart_desk/packages/flutter_cms_annotation/` (orphaned rename artifact)
- Delete: `packages/dart_desk/lib/src/core/` (empty directory)
- Delete: `packages/dart_desk/lib/src/generators/` (empty directory)
- Modify: `.gitignore` — add `app.log`

- [ ] **Step 1: Delete orphaned flutter_cms_annotation directory**

```bash
rm -rf packages/dart_desk/packages/flutter_cms_annotation/
```

- [ ] **Step 2: Delete empty directories**

```bash
rmdir packages/dart_desk/lib/src/core/
rmdir packages/dart_desk/lib/src/generators/
```

- [ ] **Step 3: Add app.log to .gitignore**

Append to `.gitignore`:
```
app.log
```

- [ ] **Step 4: Remove app.log from git tracking if present**

```bash
git rm --cached app.log 2>/dev/null || true
```

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "chore: remove dead directories and ignore app.log"
```

---

### Task 2: dart_desk_annotation — Pub.dev Metadata

**Files:**
- Modify: `packages/dart_desk_annotation/pubspec.yaml`
- Create: `packages/dart_desk_annotation/LICENSE`
- Create: `packages/dart_desk_annotation/CHANGELOG.md`
- Modify: `packages/dart_desk_annotation/README.md`
- Create: `packages/dart_desk_annotation/example/example.dart`
- Create: `packages/dart_desk_annotation/.pubignore`

- [ ] **Step 1: Update pubspec.yaml**

In `packages/dart_desk_annotation/pubspec.yaml`:
- Remove `publish_to: 'none'`
- Add after `version:`:

```yaml
description: Annotations and field definitions for the Dart Desk CMS framework.
homepage: https://github.com/vietthangvunguyen/dart_desk
repository: https://github.com/vietthangvunguyen/dart_desk
topics:
  - cms
  - annotations
  - flutter
```

Note: Keep `resolution: workspace` for now — it's needed for local dev. The pre-publish script (Task 7) handles removal.

- [ ] **Step 2: Create LICENSE file**

Create `packages/dart_desk_annotation/LICENSE` with MIT license, year 2024-2026, copyright holder "Dart Desk Authors".

- [ ] **Step 3: Create CHANGELOG.md**

Create `packages/dart_desk_annotation/CHANGELOG.md`:

```markdown
## 0.1.0

- Initial release
- Field annotations for primitive, complex, and media types
- Validator support via `CmsValidator`
- CMS data model configuration annotations
```

- [ ] **Step 4: Improve README.md**

Rewrite `packages/dart_desk_annotation/README.md` to include:
- Package description (1 paragraph)
- Installation instructions (`dart pub add dart_desk_annotation`)
- Basic usage example showing a document type annotation
- Link to API docs
- License badge

- [ ] **Step 5: Create example file**

Create `packages/dart_desk_annotation/example/example.dart`:

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

// Example: Define a blog post document type
@CmsDocument(name: 'Blog Post')
class BlogPost {
  @CmsStringField(label: 'Title')
  final String title;

  @CmsTextField(label: 'Body')
  final String body;

  @CmsBooleanField(label: 'Published')
  final bool published;

  BlogPost({required this.title, required this.body, this.published = false});
}
```

Note: Adapt to actual annotation API — read `lib/src/annotations.dart` and `lib/src/config.dart` to use the correct annotation names and constructors.

- [ ] **Step 6: Create .pubignore**

Create `packages/dart_desk_annotation/.pubignore`:

```
CLAUDE.md
*.skill
*.iml
.specify/
devtools_options.yaml
```

- [ ] **Step 7: Verify with dart analyze**

```bash
cd packages/dart_desk_annotation && dart analyze
```

Expected: No errors.

- [ ] **Step 8: Commit**

```bash
git add packages/dart_desk_annotation/ && git commit -m "chore: prepare dart_desk_annotation for pub.dev"
```

---

### Task 3: dart_desk_generator — Pub.dev Metadata

**Files:**
- Modify: `packages/dart_desk_generator/pubspec.yaml`
- Create: `packages/dart_desk_generator/LICENSE`
- Create: `packages/dart_desk_generator/CHANGELOG.md`
- Modify: `packages/dart_desk_generator/README.md`
- Create: `packages/dart_desk_generator/example/example.dart`
- Create: `packages/dart_desk_generator/.pubignore`

- [ ] **Step 1: Update pubspec.yaml**

In `packages/dart_desk_generator/pubspec.yaml`:
- Remove `publish_to: 'none'`
- Add after `version:`:

```yaml
description: Code generator for the Dart Desk CMS framework. Generates CMS configuration from annotations.
homepage: https://github.com/vietthangvunguyen/dart_desk
repository: https://github.com/vietthangvunguyen/dart_desk
topics:
  - cms
  - code-generation
  - build-runner
```

Note: `dart_desk_generator` is a pure Dart package (no Flutter SDK dep), so don't add `flutter` as a topic.

- [ ] **Step 2: Create LICENSE file**

Same MIT license as annotation package.

- [ ] **Step 3: Create CHANGELOG.md**

```markdown
## 0.1.0

- Initial release
- Code generation for CMS document types
- Field configuration generation from annotations
```

- [ ] **Step 4: Improve README.md**

Rewrite to include:
- Package description
- Installation: add to `dev_dependencies` with `build_runner`
- Usage: add annotations, run `dart run build_runner build`
- Link to `dart_desk_annotation` for available annotations

- [ ] **Step 5: Create example file**

Create `packages/dart_desk_generator/example/example.dart` showing a `build.yaml` configuration snippet and a minimal annotated class. Since this is a builder package, the example shows configuration rather than executable code:

```dart
// This package is a code generator used with build_runner.
//
// 1. Add to pubspec.yaml dev_dependencies:
//    dart_desk_generator: ^0.1.0
//    build_runner: ^2.4.0
//
// 2. Annotate your models with dart_desk_annotation:
//    @CmsDocument(name: 'Blog Post')
//    class BlogPost { ... }
//
// 3. Run: dart run build_runner build
//
// See the dart_desk_annotation package for available annotations.
void main() {}
```

- [ ] **Step 6: Create .pubignore**

```
CLAUDE.md
*.skill
*.iml
.specify/
devtools_options.yaml
```

- [ ] **Step 7: Verify with dart analyze**

```bash
cd packages/dart_desk_generator && dart analyze
```

- [ ] **Step 8: Commit**

```bash
git add packages/dart_desk_generator/ && git commit -m "chore: prepare dart_desk_generator for pub.dev"
```

---

### Task 4: dart_desk — Remove dart_desk_be_client Dependency

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/routes/studio_coordinator.dart`
- Modify: `packages/dart_desk/lib/src/studio/routes/studio_layout.dart`
- Modify: `packages/dart_desk/pubspec.yaml` (remove `dart_desk_be_client`)
- Modify: `examples/cms_app/` (update caller to pass callback)

The only usage is `context.signOut()` on line 200 of `studio_layout.dart`. We need to replace this with a callback.

**Important architectural note:** `StudioLayout` is bound via `bindLayout(StudioLayout.new)` in `studio_coordinator.dart` — a no-arg constructor tear-off. The callback CANNOT be passed via the constructor. Instead, add `onSignOut` to `StudioCoordinator`, which is already accessible in `StudioLayout.build(coordinator, context)`.

- [ ] **Step 1: Add onSignOut to StudioCoordinator**

In `packages/dart_desk/lib/src/studio/routes/studio_coordinator.dart`:
- Add `final VoidCallback? onSignOut;` field
- Add it to the constructor as an optional named parameter

- [ ] **Step 2: Update StudioLayout to use coordinator.onSignOut**

In `packages/dart_desk/lib/src/studio/routes/studio_layout.dart`:
- Remove the `import 'package:dart_desk_be_client/dart_desk_be_client.dart';` import (line 2)
- Replace `context.signOut()` (line 200) with `coordinator.onSignOut?.call()`
- The `coordinator` variable is already available in the `build` method

- [ ] **Step 3: Update callers of StudioCoordinator**

Search for all instantiations of `StudioCoordinator` in the workspace (likely in `examples/cms_app/`). Update them to pass the `onSignOut` callback:

```dart
StudioCoordinator(
  documentTypes: ...,
  dataSource: ...,
  onSignOut: () => context.signOut(), // from dart_desk_be_client
)
```

- [ ] **Step 4: Remove dart_desk_be_client from packages/dart_desk/pubspec.yaml**

Remove the `dart_desk_be_client` path dependency. The `examples/cms_app/` keeps its own dependency on `dart_desk_be_client`.

- [ ] **Step 5: Verify no remaining imports**

```bash
grep -r "dart_desk_be_client" packages/dart_desk/lib/
```

Expected: No matches.

- [ ] **Step 6: Run dart analyze**

```bash
cd packages/dart_desk && dart analyze
```

- [ ] **Step 7: Commit**

```bash
git add -A && git commit -m "refactor: replace dart_desk_be_client dep with onSignOut callback on StudioCoordinator"
```

---

### Task 5: dart_desk — Remove marionette_flutter from Published API

**Files:**
- Modify: `packages/dart_desk/lib/studio.dart` (line 36) — remove marionette_config.dart export
- Modify: `packages/dart_desk/pubspec.yaml` — remove marionette_flutter dependency

**Note:** The `marionette_config.dart` export is in `lib/studio.dart` (NOT `lib/testing.dart`). The spec's description was incorrect — `testing.dart` only exports `test_document_types.dart` and `mock_cms_data_source.dart`.

- [ ] **Step 1: Remove marionette_config.dart export from studio.dart**

In `packages/dart_desk/lib/studio.dart`, remove line 36:
```dart
export 'src/studio/core/marionette_config.dart';
```

- [ ] **Step 2: Check if marionette_config.dart is imported anywhere else in lib/**

```bash
grep -r "marionette_config\|marionette_flutter" packages/dart_desk/lib/
```

If it's only in `studio.dart` and `marionette_config.dart` itself, proceed. If other files import it, those need updating too.

- [ ] **Step 3: Remove marionette_flutter from pubspec.yaml**

In `packages/dart_desk/pubspec.yaml`, remove the `marionette_flutter` path dependency.

- [ ] **Step 4: Run dart analyze**

```bash
cd packages/dart_desk && dart analyze
```

Expected: Clean (marionette_config.dart still exists but is not exported or imported by published code).

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "refactor: remove marionette_flutter from published API surface"
```

---

### Task 6: dart_desk — Pub.dev Metadata

**Files:**
- Modify: `packages/dart_desk/pubspec.yaml`
- Create: `packages/dart_desk/LICENSE`
- Create: `packages/dart_desk/CHANGELOG.md`
- Create: `packages/dart_desk/README.md`
- Create: `packages/dart_desk/example/example.dart`
- Create: `packages/dart_desk/.pubignore`

- [ ] **Step 1: Update pubspec.yaml**

In `packages/dart_desk/pubspec.yaml`:
- Remove `publish_to: 'none'`
- Add after `version:`:

```yaml
description: Flutter widget library for building CMS studio interfaces with shadcn_ui components.
homepage: https://github.com/vietthangvunguyen/dart_desk
repository: https://github.com/vietthangvunguyen/dart_desk
topics:
  - cms
  - flutter
  - content-management
```

- [ ] **Step 2: Create LICENSE file**

Same MIT license as other packages.

- [ ] **Step 3: Create CHANGELOG.md**

```markdown
## 0.1.0

- Initial release
- Studio layout with navigation and document management
- Input widgets for all CMS field types
- Reactive state management with signals
- shadcn_ui-based component library
```

- [ ] **Step 4: Create README.md**

Create `packages/dart_desk/README.md` with:
- Package description and features (bullet list)
- Installation instructions
- Quick start example showing a basic CMS setup
- Links to annotation and generator packages
- Screenshot placeholder
- License

Read `packages/dart_desk/lib/dart_desk.dart` to understand what the main API looks like and write a realistic example.

- [ ] **Step 5: Create example file**

Create `packages/dart_desk/example/example.dart` with a minimal Flutter app that demonstrates the CMS studio. Read the existing `examples/cms_app/` for reference on how the library is used.

- [ ] **Step 6: Create .pubignore**

Create `packages/dart_desk/.pubignore`:

```
CLAUDE.md
*.skill
*.iml
.specify/
devtools_options.yaml
test_automation/
app.log
flutter_*.log
sanity-fields-example.json
docs/
test_e2e/
packages/
lib/src/studio/core/marionette_config.dart
```

- [ ] **Step 7: Run dart analyze**

```bash
cd packages/dart_desk && dart analyze
```

- [ ] **Step 8: Commit**

```bash
git add packages/dart_desk/ && git commit -m "chore: prepare dart_desk for pub.dev"
```

---

### Task 7: Create Pre-Publish Script

**Files:**
- Create: `tool/pre_publish_check.sh`

This script automates the dry-run verification for each package.

- [ ] **Step 1: Create the script**

First create the directory: `mkdir -p tool/`

Create `tool/pre_publish_check.sh`:

```bash
#!/bin/bash
set -e

# Pre-publish check script for dart_desk packages.
# This temporarily modifies pubspecs for pub.dev compatibility,
# runs dry-run publish, then reverts changes.

PACKAGES=("packages/dart_desk_annotation" "packages/dart_desk_generator" "packages/dart_desk")

# Safety: restore all backups on any exit (success, failure, or signal)
trap 'for pkg in "${PACKAGES[@]}"; do [ -f "$pkg/pubspec.yaml.bak" ] && mv "$pkg/pubspec.yaml.bak" "$pkg/pubspec.yaml"; done' EXIT

for pkg in "${PACKAGES[@]}"; do
  echo "=== Checking $pkg ==="

  # Backup pubspec
  cp "$pkg/pubspec.yaml" "$pkg/pubspec.yaml.bak"

  # Remove resolution: workspace
  sed -i '' '/^resolution: workspace$/d' "$pkg/pubspec.yaml"

  # Replace dart_desk_annotation path dep with version constraint (preserve 2-space indent)
  sed -i '' 's|^  dart_desk_annotation:.*|  dart_desk_annotation: ^0.1.0|' "$pkg/pubspec.yaml"
  sed -i '' '/^    path: \.\.\/dart_desk_annotation$/d' "$pkg/pubspec.yaml"

  # Remove dart_desk_be_client entirely (both key line and path line)
  sed -i '' '/^  dart_desk_be_client:$/d' "$pkg/pubspec.yaml"
  sed -i '' '/^    path: \.\.\/\.\.\/\.\.\/dart_desk_be\/dart_desk_be_client$/d' "$pkg/pubspec.yaml"

  # Remove marionette_flutter entirely (both key line and path line)
  sed -i '' '/^  marionette_flutter:$/d' "$pkg/pubspec.yaml"
  sed -i '' '/^    path: \.\.\/\.\.\/\.\.\/\.\.\/marionette_mcp\/packages\/marionette_flutter$/d' "$pkg/pubspec.yaml"

  # Run pub get then dry-run
  (cd "$pkg" && flutter pub get && dart pub publish --dry-run) || {
    echo "FAILED: $pkg"
    exit 1
  }

  # Restore pubspec (trap also handles this, but be explicit)
  mv "$pkg/pubspec.yaml.bak" "$pkg/pubspec.yaml"

  echo "=== $pkg OK ==="
  echo ""
done

echo "All packages passed dry-run checks!"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x tool/pre_publish_check.sh
```

- [ ] **Step 3: Test the script**

```bash
./tool/pre_publish_check.sh
```

Expected: All three packages pass dry-run. If they don't, fix issues before proceeding.

- [ ] **Step 4: Commit**

```bash
git add tool/ && git commit -m "chore: add pre-publish dry-run check script"
```

---

### Task 8: Workspace Cleanup

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Verify signals published version**

```bash
curl -s https://pub.dev/api/packages/signals | python3 -c "import sys,json; print(json.load(sys.stdin)['latest']['version'])"
```

Verify that the latest published version satisfies `^6.1.0`. If not, update the constraint in `packages/dart_desk/pubspec.yaml`.

- [ ] **Step 2: Final dart analyze on all packages**

```bash
cd packages/dart_desk_annotation && dart analyze
cd ../dart_desk_generator && dart analyze
cd ../dart_desk && dart analyze
```

- [ ] **Step 3: Run pre-publish check**

```bash
./tool/pre_publish_check.sh
```

- [ ] **Step 4: Commit any final fixes**

```bash
git add -A && git commit -m "chore: final pub.dev preparation fixes"
```
