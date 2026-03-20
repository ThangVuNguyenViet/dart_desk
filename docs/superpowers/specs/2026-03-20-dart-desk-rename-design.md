# Project Rename: dart_desk → dart_desk

**Date:** 2026-03-20
**Domain:** dartdesk.dev

## Overview

Rename the entire dart_desk workspace to dart_desk, including directories, Dart packages, GitHub repos, and user-level Claude config. Scrub credentials from the public repo.

## Directory Renames

| Current | New |
|---|---|
| `dart_desk_workspace/` | `dart_desk_workspace/` |
| `dart_desk_workspace/dart_desk/` | `dart_desk_workspace/dart_desk/` |
| `dart_desk_workspace/dart_desk_be/` | `dart_desk_workspace/dart_desk_be/` |
| `dart_desk_workspace/dart_desk_be/dart_desk_be_server/` | `dart_desk_be/dart_desk_be_server/` |
| `dart_desk_workspace/dart_desk_be/dart_desk_be_client/` | `dart_desk_be/dart_desk_be_client/` |
| `dart_desk_workspace/dart_desk_be/dart_desk_admin/` | `dart_desk_be/dart_desk_admin/` |
| `dart_desk_workspace/dart_desk_be/dart_desk_manage/` | `dart_desk_be/dart_desk_manage/` |
| `dart_desk_workspace/dart_desk_cli/` | `dart_desk_workspace/dart_desk_cli/` |
| `dart_desk.code-workspace` | `dart_desk.code-workspace` |

## Package Renames

| Current package name | New package name |
|---|---|
| `dart_desk` | `dart_desk` |
| `dart_desk_be_server` | `dart_desk_be_server` |
| `dart_desk_be_client` | `dart_desk_be_client` |
| `dart_desk_admin` | `dart_desk_admin` |
| `dart_desk_manage` | `dart_desk_manage` |
| `dart_desk_cli` | `dart_desk_cli` |

All `import 'package:dart_desk...'` statements update accordingly.
All `library` directives update accordingly.

## GitHub Operations

1. **Rename** `ThangVuNguyenViet/dart_desk` → `ThangVuNguyenViet/dart_desk` (stays public)
2. **Rename** `ThangVuNguyenViet/dart_desk_be` → `ThangVuNguyenViet/dart_desk_be` (stays private)
3. **Create** `ThangVuNguyenViet/dart_desk_cli` (private)
4. **Update** git remotes in all local repos to point to new names
5. **Init** git in `dart_desk_cli/` and push to new repo

## Credential Scrub (public repo: dart_desk only)

Remove from ALL files (including .md):
- `thangvnv0806@gmail.com` — replace with `<your-email>` or remove
- `1234567890` — remove (password references)
- `thangvnv0806/1234567890` — remove (credential pairs)
- Seed data in `test_e2e/setup/seed_data.sh` — replace real values with placeholders
- Any other hardcoded credentials or tokens

## User-Level Claude Config Updates

Update `~/.claude/projects/` directory entries and memory files that reference `dart_desk`:
- Rename/update project directories under `~/.claude/projects/`
- Update content in memory `.md` files that mention `dart_desk`
- Update `~/.claude/plans/` files are ephemeral — leave as-is

## Serverpod-Specific Updates

- Docker/docker-compose files referencing `dart_desk_be`
- Serverpod config files (`config/development.yaml`, `config/production.yaml`, etc.)
- Generated code paths in `lib/src/generated/`
- Migration files referencing old names
- `servertools/` or deployment scripts

## Out of Scope

- `serverpod_fork/` — untouched (upstream fork)
- Git history rewriting — forward-only rename
- Re-generating Serverpod code (user can run `serverpod generate` after rename)

## Verification

After all renames:
1. `grep -r "dart_desk" dart_desk_workspace/` should return zero hits (excluding .git dirs and serverpod_fork)
2. `grep -r "thangvnv0806\|1234567890" dart_desk/` should return zero hits (excluding .git)
3. All pubspec.yaml files parse correctly
4. GitHub repos accessible at new URLs
5. Git remotes point to correct URLs
