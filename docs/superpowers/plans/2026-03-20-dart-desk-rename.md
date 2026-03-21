# dart_desk Rename Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the entire dart_desk workspace to dart_desk, update all references, scrub credentials from the public repo, and update GitHub repos.

**Architecture:** Mechanical find-and-replace across 3 git repos + 1 new repo. Rename directories bottom-up (inner first), then do text replacements, then GitHub operations. The `dart_desk_admin` subproject becomes `dart_desk_admin` (intentionally asymmetric).

**Tech Stack:** Dart/Flutter, Serverpod, GitHub CLI, git

**Important rename mappings:**
- `dart_desk` → `dart_desk` (package and repo)
- `dart_desk_annotation` → `dart_desk_annotation`
- `dart_desk_generator` → `dart_desk_generator`
- `dart_desk_be` → `dart_desk_be` (repo)
- `dart_desk_be_server` → `dart_desk_be_server`
- `dart_desk_be_client` → `dart_desk_be_client`
- `dart_desk_admin` → `dart_desk_admin`
- `dart_desk_manage` → `dart_desk_manage`
- `dart_desk_cli` → `dart_desk_cli`
- `dart_desk_workspace` → `dart_desk_workspace`
- CLI executable: `dart_desk` → `dart_desk`

---

### Task 1: Credential scrub in dart_desk (public repo)

Remove any credential or seed data references before they get carried into the renamed repo.

**Files:**
- Modify: `packages/dart_desk/tests/e2e/setup/seed_data.sh`
- Modify: `packages/dart_desk/tests/e2e/tests/06_cloud_deployment.md`
- Modify: any other file containing `thangvnv0806` or `1234567890`

- [ ] **Step 1: Find all credential references**

Run: `grep -rn "thangvnv0806\|1234567890" --include="*.md" --include="*.sh" --include="*.dart" --include="*.yaml" .` (in dart_desk dir, excluding .git)

- [ ] **Step 2: Replace credentials with placeholders**

Replace `thangvnv0806@gmail.com` → `<your-email>` or remove entirely.
Replace `1234567890` (when used as password) → `<your-password>` or remove.
Remove any credential pairs like `thangvnv0806/1234567890`.
In seed_data.sh, replace real tokens/passwords with obvious placeholders.

- [ ] **Step 3: Verify no credentials remain**

Run: `grep -rn "thangvnv0806\|1234567890" --include="*.md" --include="*.sh" --include="*.dart" --include="*.yaml" .`
Expected: zero matches

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: scrub credentials from public repo"
```

---

### Task 2: Text replacements in dart_desk repo

Do all string replacements BEFORE renaming directories (so paths are still valid).

**Files:** All ~69 files listed in the exploration that contain `dart_desk` references.

- [ ] **Step 1: Replace package/import references (order matters — longest match first)**

In the dart_desk repo, perform these replacements across ALL files (excluding .git):
1. `dart_desk_admin` → `dart_desk_admin`
2. `dart_desk_be_server` → `dart_desk_be_server`
3. `dart_desk_be_client` → `dart_desk_be_client`
4. `dart_desk_annotation` → `dart_desk_annotation`
5. `dart_desk_generator` → `dart_desk_generator`
6. `dart_desk_workspace` → `dart_desk_workspace`
7. `dart_desk_manage` → `dart_desk_manage`
8. `dart_desk_cli` → `dart_desk_cli`
9. `dart_desk_be` → `dart_desk_be`
10. `dart_desk` → `dart_desk` (catches remaining — package imports, etc.)

Use `find . -not -path './.git/*' -type f | xargs sed -i '' 's/dart_desk_admin/dart_desk_admin/g'` etc.

IMPORTANT: Do replacements in this exact order to avoid partial matches (e.g., replacing `dart_desk` before `dart_desk_be` would produce `dart_desk_be` instead of `dart_desk_be`).

- [ ] **Step 2: Rename files that contain dart_desk in their name**

```bash
# In packages/
mv packages/dart_desk packages/dart_desk
mv packages/dart_desk_annotation packages/dart_desk_annotation
mv packages/dart_desk_generator packages/dart_desk_generator

# Rename library files
mv packages/dart_desk/lib/dart_desk.dart packages/dart_desk/lib/dart_desk.dart
mv packages/dart_desk_annotation/lib/dart_desk_annotation.dart packages/dart_desk_annotation/lib/dart_desk_annotation.dart
mv packages/dart_desk_generator/lib/dart_desk_generator.dart packages/dart_desk_generator/lib/dart_desk_generator.dart

# Rename example config
mv examples/cms_app/dart_desk.yaml examples/cms_app/dart_desk.yaml

# Rename CLI entry point (in dart_desk_cli — handled in Task 5)
```

- [ ] **Step 3: Verify no dart_desk references remain**

Run: `grep -rn "dart_desk" --include="*.dart" --include="*.yaml" --include="*.md" --include="*.json" --include="*.sh" . | grep -v ".git/"`
Expected: zero matches (or only in lock files which will regenerate)

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: rename dart_desk to dart_desk in all source files"
```

---

### Task 3: Text replacements in dart_desk_be repo

**Files:** All ~156 files containing dart_desk references in the backend repo.

- [ ] **Step 1: Replace all text references (longest match first)**

Same replacement order as Task 2, applied across the entire dart_desk_be directory (excluding .git).

- [ ] **Step 2: Rename directories**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be
mv dart_desk_admin dart_desk_admin
mv dart_desk_be_server dart_desk_be_server
mv dart_desk_be_client dart_desk_be_client
mv dart_desk_manage dart_desk_manage
```

- [ ] **Step 3: Rename library/entry files inside those dirs**

```bash
mv dart_desk_be_client/lib/dart_desk_be_client.dart dart_desk_be_client/lib/dart_desk_be_client.dart
mv dart_desk_be_client/lib/src/dart_desk_auth.dart dart_desk_be_client/lib/src/dart_desk_auth.dart
# Rename any other files with dart_desk in their name
```

- [ ] **Step 4: Verify no dart_desk references remain**

Run: `grep -rn "dart_desk" --include="*.dart" --include="*.yaml" --include="*.yml" --include="*.md" --include="*.json" --include="*.sh" --include="*.tf" . | grep -v ".git/" | grep -v "migration"`
Expected: zero matches (migrations may still have old names — that's OK, they're historical)

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: rename dart_desk_be to dart_desk_be in all source files"
```

---

### Task 4: Text replacements in dart_desk_cli

**Files:** All 13 files in the CLI project.

- [ ] **Step 1: Replace all text references**

Same replacement order. Also rename the executable in pubspec.yaml from `dart_desk` to `dart_desk`.

- [ ] **Step 2: Rename files**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_cli
mv bin/dart_desk.dart bin/dart_desk.dart
mv lib/dart_desk_cli.dart lib/dart_desk_cli.dart
```

- [ ] **Step 3: Verify**

Run: `grep -rn "dart_desk" . | grep -v ".git/"`
Expected: zero matches

- [ ] **Step 4: Init git and commit**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_cli
git init
git add -A
git commit -m "chore: rename dart_desk_cli to dart_desk_cli"
```

---

### Task 5: Rename workspace-level files and directories

- [ ] **Step 1: Update workspace CLAUDE.md**

Replace all `dart_desk` references with `dart_desk` equivalents in `/Users/vietthangvunguyen/Workspace/dart_desk_workspace/CLAUDE.md`.

- [ ] **Step 2: Update and rename .code-workspace file**

Update internal folder paths in `dart_desk.code-workspace`, then rename to `dart_desk.code-workspace`.

- [ ] **Step 3: Rename project directories**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace
mv dart_desk dart_desk
mv dart_desk_be dart_desk_be
mv dart_desk_cli dart_desk_cli
```

- [ ] **Step 4: Rename workspace directory itself**

```bash
mv /Users/vietthangvunguyen/Workspace/dart_desk_workspace /Users/vietthangvunguyen/Workspace/dart_desk_workspace
```

---

### Task 6: GitHub operations

- [ ] **Step 1: Rename repos**

```bash
gh repo rename dart_desk --repo ThangVuNguyenViet/dart_desk --yes
gh repo rename dart_desk_be --repo ThangVuNguyenViet/dart_desk_be --yes
```

- [ ] **Step 2: Update git remotes**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
git remote set-url origin git@github.com:ThangVuNguyenViet/dart_desk.git

cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be
git remote set-url origin git@github.com:ThangVuNguyenViet/dart_desk_be.git
```

- [ ] **Step 3: Create CLI repo and push**

```bash
gh repo create ThangVuNguyenViet/dart_desk_cli --private
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_cli
git remote add origin git@github.com:ThangVuNguyenViet/dart_desk_cli.git
git push -u origin main
```

- [ ] **Step 4: Push renamed repos**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
git push

cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be
git push
```

---

### Task 7: Update ~/.claude/ project config

- [ ] **Step 1: Copy memory to new project paths**

The active memory directory is at:
`~/.claude/projects/-Users-vietthangvunguyen-Workspace-dart_desk_workspace-dart_desk/memory/`

Create new directory matching new path and copy memory files, updating content:
`~/.claude/projects/-Users-vietthangvunguyen-Workspace-dart_desk_workspace-dart_desk/memory/`

Update all `dart_desk` references in memory file content to `dart_desk`.

- [ ] **Step 2: Update other project directories**

For each `.claude/projects/` directory referencing dart_desk:
- Create equivalent with dart_desk path
- Copy and update any settings/memory files
- Old directories can be left (Claude Code will ignore them) or removed

- [ ] **Step 3: Verify**

Run: `ls ~/.claude/projects/ | grep dart_desk`
Expected: new directories exist with updated memory files

---

### Task 8: Final verification

- [ ] **Step 1: Grep entire workspace for dart_desk**

Run: `grep -rn "dart_desk" /Users/vietthangvunguyen/Workspace/dart_desk_workspace/ --include="*.dart" --include="*.yaml" --include="*.yml" --include="*.md" --include="*.json" --include="*.sh" --include="*.tf" | grep -v ".git/" | grep -v "serverpod_fork" | grep -v "migration" | grep -v ".lock"`
Expected: zero matches

- [ ] **Step 2: Grep public repo for credentials**

Run: `grep -rn "thangvnv0806\|1234567890" /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/ | grep -v ".git/"`
Expected: zero matches

- [ ] **Step 3: Verify GitHub repos accessible**

```bash
gh repo view ThangVuNguyenViet/dart_desk --json name
gh repo view ThangVuNguyenViet/dart_desk_be --json name
gh repo view ThangVuNguyenViet/dart_desk_cli --json name
```

- [ ] **Step 4: Verify git remotes**

```bash
git -C /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk remote -v
git -C /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be remote -v
git -C /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_cli remote -v
```
