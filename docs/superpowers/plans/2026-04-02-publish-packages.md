# Publish dart_desk Packages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up melos, prepare all 3 packages (dart_desk_annotation, dart_desk_generator, dart_desk) for pub.dev, and publish v0.1.0.

**Architecture:** Melos manages the monorepo with conventional commits for changelog generation. Packages publish in dependency order. Each package gets BSD 3-Clause license, cleaned pubspec, and existing READMEs/CHANGELOGs are already good.

**Tech Stack:** Dart, Flutter, melos, pana, pub.dev

---

### Task 1: Install melos globally

**Files:** None

- [ ] **Step 1: Install melos**

```bash
dart pub global activate melos
```

Expected: melos activated successfully.

- [ ] **Step 2: Verify melos is available**

```bash
melos --version
```

Expected: Version number printed (e.g. `6.x.x`).

- [ ] **Step 3: Commit** — nothing to commit, this is a global tool install.

---

### Task 2: Create melos.yaml at workspace root

**Files:**
- Create: `melos.yaml`

- [ ] **Step 1: Create `melos.yaml`**

Write this file at `/Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/melos.yaml`:

```yaml
name: dart_desk_workspace

packages:
  - packages/*

command:
  version:
    message: "chore(release): publish packages"
    includeCommitId: true
    workspaceChangelog: false
    changelogs:
      - path: CHANGELOG.md
        packageFilters:
          scope: "*"
  publish:
    hooks:
      pre: melos run analyze

scripts:
  analyze:
    run: dart analyze --fatal-infos
    packageFilters:
      scope:
        - dart_desk
        - dart_desk_annotation
        - dart_desk_generator
  test:
    run: flutter test
    packageFilters:
      dirExists: test
  dry-run:
    run: dart pub publish --dry-run
    packageFilters:
      noPrivate: true
```

- [ ] **Step 2: Run `melos bootstrap` to verify**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk && melos bootstrap
```

Expected: All 3 packages linked successfully.

- [ ] **Step 3: Commit**

```bash
git add melos.yaml
git commit -m "chore: add melos.yaml for monorepo management"
```

---

### Task 3: Replace LICENSE files with BSD 3-Clause (all 3 packages)

**Files:**
- Modify: `packages/dart_desk/LICENSE`
- Modify: `packages/dart_desk_annotation/LICENSE`
- Modify: `packages/dart_desk_generator/LICENSE`

- [ ] **Step 1: Write BSD 3-Clause LICENSE to all 3 packages**

Use this content for all three LICENSE files:

```
BSD 3-Clause License

Copyright (c) 2024-2026, Viet Thang Vu Nguyen
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

- [ ] **Step 2: Update license references in READMEs**

In all 3 READMEs, change `MIT — see [LICENSE](LICENSE)` to `BSD 3-Clause — see [LICENSE](LICENSE)`.

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk/LICENSE packages/dart_desk_annotation/LICENSE packages/dart_desk_generator/LICENSE packages/dart_desk/README.md packages/dart_desk_annotation/README.md packages/dart_desk_generator/README.md
git commit -m "chore: switch all packages to BSD 3-Clause license"
```

---

### Task 4: Clean up pubspec.yaml files

**Files:**
- Modify: `packages/dart_desk/pubspec.yaml`
- Modify: `packages/dart_desk_annotation/pubspec.yaml`
- Modify: `packages/dart_desk_generator/pubspec.yaml`

- [ ] **Step 1: Fix `dart_desk_generator/pubspec.yaml`**

Remove the `publish_to: none` line (line 4).

Add `issue_tracker`:
```yaml
issue_tracker: https://github.com/vietthangvunguyen/dart_desk/issues
```

Change `dart_desk_annotation` dependency from git ref to version constraint:
```yaml
  dart_desk_annotation: ^0.1.0
```

- [ ] **Step 2: Fix `dart_desk/pubspec.yaml`**

Add `issue_tracker`:
```yaml
issue_tracker: https://github.com/vietthangvunguyen/dart_desk/issues
```

Change `dart_desk_annotation` dependency from git ref to version constraint:
```yaml
  dart_desk_annotation: ^0.1.0
```

- [ ] **Step 3: Fix `dart_desk_annotation/pubspec.yaml`**

Add `issue_tracker`:
```yaml
issue_tracker: https://github.com/vietthangvunguyen/dart_desk/issues
```

- [ ] **Step 4: Verify resolution still works**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk && melos bootstrap
```

Expected: All packages resolve (workspace overrides still point to local paths, so `^0.1.0` resolves locally).

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk/pubspec.yaml packages/dart_desk_annotation/pubspec.yaml packages/dart_desk_generator/pubspec.yaml
git commit -m "chore: clean up pubspec.yaml files for pub.dev publishing"
```

---

### Task 5: Create example for dart_desk

**Files:**
- Create: `packages/dart_desk/example/example.md`

pub.dev awards points for an `example/` directory. Since `dart_desk` is a Flutter widget library, a standalone runnable example is complex. An `example.md` pointing to the examples directory is acceptable.

- [ ] **Step 1: Create `packages/dart_desk/example/example.md`**

```markdown
# dart_desk Example

See the full example CMS app in the repository:

- [CMS App Example](https://github.com/vietthangvunguyen/dart_desk/tree/main/examples/cms_app) — A complete CMS studio built with dart_desk
- [Data Models Example](https://github.com/vietthangvunguyen/dart_desk/tree/main/examples/data_models) — Annotated content models with code generation

## Quick Start

```dart
import 'package:dart_desk/dart_desk.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  CmsStudioApp(
    dataSource: myDataSource,
    documentTypes: [blogPost, product],
    documentTypeDecorations: [
      CmsDocumentTypeDecoration(documentType: blogPost, icon: Icons.article),
      CmsDocumentTypeDecoration(documentType: product, icon: Icons.shopping_bag),
    ],
    title: 'My CMS',
  ),
);
```
```

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/example/example.md
git commit -m "docs: add example reference for dart_desk"
```

---

### Task 6: Run dry-run publish on all packages

**Files:** None

- [ ] **Step 1: Dry-run dart_desk_annotation**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk_annotation && dart pub publish --dry-run
```

Expected: No errors. Warnings about pub points are OK to note.

- [ ] **Step 2: Dry-run dart_desk_generator**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk_generator && dart pub publish --dry-run
```

Expected: No errors.

- [ ] **Step 3: Dry-run dart_desk**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk && dart pub publish --dry-run
```

Expected: No errors.

- [ ] **Step 4: Fix any issues found** — address warnings/errors from dry-run output before proceeding.

---

### Task 7: Install and run pana for pub.dev score check

**Files:** None

- [ ] **Step 1: Install pana**

```bash
dart pub global activate pana
```

- [ ] **Step 2: Run pana on dart_desk_annotation**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk_annotation && pana .
```

Review the output for pub point deductions and fix any actionable items.

- [ ] **Step 3: Run pana on dart_desk_generator**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk_generator && pana .
```

- [ ] **Step 4: Run pana on dart_desk**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk && pana .
```

- [ ] **Step 5: Fix any actionable pana issues and commit**

```bash
git add -A
git commit -m "fix: address pana findings for pub.dev score"
```

(Only commit if there were changes.)

---

### Task 8: Publish packages to pub.dev

**Files:** None

This task requires the user to be authenticated with `dart pub`. Publishing is interactive (requires confirmation).

- [ ] **Step 1: Verify pub.dev authentication**

```bash
dart pub token list
```

If not authenticated, the user needs to run `dart pub login`.

- [ ] **Step 2: Publish dart_desk_annotation**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk_annotation && dart pub publish
```

Wait for confirmation that the package is published.

- [ ] **Step 3: Publish dart_desk_generator**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk_generator && dart pub publish
```

- [ ] **Step 4: Publish dart_desk**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk && dart pub publish
```

- [ ] **Step 5: Tag the release**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk && git tag v0.1.0 && git push origin v0.1.0
```

---

### Task 9: Post-publish verification

**Files:** None

- [ ] **Step 1: Verify packages on pub.dev**

Check these URLs exist and show the correct version:
- https://pub.dev/packages/dart_desk_annotation
- https://pub.dev/packages/dart_desk_generator
- https://pub.dev/packages/dart_desk

- [ ] **Step 2: Verify pub points**

Check the pub.dev score tab for each package. Target: 120+ out of 160 for a first release.
