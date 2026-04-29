# README Improvements — Design Spec

**Date:** 2026-04-29
**Scope:** dart_desk monorepo + dart_desk_be (sibling repo). Six README files.

## Goals

- Make `packages/dart_desk/README.md` a scannable pub.dev landing page that walks a reader through a complete model → studio → consumer loop.
- Replace stale "A new Flutter project" READMEs in `examples/desk_app` and `examples/example_app` with showcase-oriented docs.
- Make the workspace-root README a clear monorepo guide for contributors (separate from the package landing).
- Refresh `dart_desk_be` server + client READMEs to reflect features added since they were last written (UUID PKs, soft delete with slug reuse, JSONB lookups, server-side image metadata, role guards, pagination, rate-limit, health-check, and the `publicContent` API surface).
- Across all files: include a "rapid development" disclaimer linking to issues, since APIs may shift between minor versions.

## Non-goals

- No new dedicated `docs/public-api.md` for `dart_desk_be` (deferred — refresh existing READMEs only).
- No advanced device-group override walkthrough in the package README (deferred — advanced use case).
- No field-type matrix or advanced-pattern reference content in the package README (drifts too fast; either deleted or moved to versioned `docs/`).

## Cross-cutting elements

- **Rapid-dev disclaimer** at the top of every file:
  > ⚠️ Rapid development. APIs may shift between minor versions. Bug reports and requests welcome at the [issues page](…).
- **Hero asset placeholder** — every README that benefits from a screenshot/GIF gets a `<!-- TODO: hero asset — provided later -->` marker. The user supplies assets later.

---

## 1. `packages/dart_desk/README.md` (pub.dev landing)

**Audience:** developers evaluating dart_desk on pub.dev.

**Length target:** ~150 lines.

**Section order:**

1. **Title + 2-sentence pitch.** "A schema-driven CMS studio for Flutter. Define your content as annotated Dart classes, get a full editing UI, and consume the published JSON from any Dart/Flutter app."
2. **Rapid-dev disclaimer** with link to issues.
3. **Hero placeholder** (TODO).
4. **Walkthrough** — single running `StorefrontConfig` example, four labelled steps:
   - **Step 1 — Define a DeskModel.** ~25 lines: `@DeskModel`, `@DeskString`, `@DeskImage(option: DeskImageOption(hotspot: true))`, `@DeskColor`, plus one `@DeskArray` of a nested `@DeskObject` to show all four shape categories (primitive / media / array / object) without overwhelming.
   - **Step 2 — Run the generator.** `dart run build_runner build`. One-line note that it produces `storefrontConfigTypeSpec`.
   - **Step 3 — Run the studio.** Minimal `DartDeskApp.withDataSource(...)` with `documentTypes: [storefrontConfigTypeSpec.build(builder: (data) => StorefrontPreview(...))]`. Hero asset placeholder for editor screenshot.
   - **Step 4 — Consume in your real app.** Real API: `client.publicContent.getDefaultContents()` returns `Map<String, PublicDocument>`; show `jsonDecode(doc.data)` then `StorefrontConfigMapper.fromMap(...)`. No device-group aside.
5. **Cloud quick start.** Three lines: sign up at `manage.dartdesk.dev`, install CLI (`dart pub global activate dart_desk_cli`), `dartdesk login && dartdesk deploy`. Link to `dartdesk.dev` for full docs.
6. **Self-host.** One paragraph: implement `DataSource` or point `DartDeskApp` at a `dart_desk_be` Serverpod instance with `serverUrl` + `apiKey`. Link to backend repo.
7. **Features.** Compact bulleted list, one line each: schema-driven, 16 field types, version history, media browser with hotspot/crop, live preview, BYO backend, theming via shadcn_ui, signals-based reactive state.
8. **Related packages.** Short table: `dart_desk_annotation`, `dart_desk_generator`, `dart_desk_cli`, `dart_desk_client`.
9. **License.** BSD-3.

**Removed from current README:** the 16-row field-type matrix, the architecture / three-package-pattern section, the advanced patterns section (`DocumentTypeSpec.build` deep-dive, custom array editors, async dropdown options). These either drift too fast or belong in dedicated docs.

---

## 2. `dart_desk/README.md` (workspace root)

**Audience:** contributors and people cloning the monorepo.

**Length target:** ~80 lines.

**Section order:**

1. **Title + 1-line pitch.** "Monorepo for the dart_desk Flutter CMS. End users: see [packages/dart_desk](packages/dart_desk)."
2. **Rapid-dev disclaimer** with link to issues.
3. **Repo layout.** Table:
   - `packages/dart_desk` — main Flutter package (the studio)
   - `packages/dart_desk_annotation` — annotations
   - `packages/dart_desk_generator` — code generator
   - `examples/data_models` — schema fixtures
   - `examples/desk_app` — runnable studio app (showcase)
   - `examples/example_app` — runnable consumer app
4. **Working in the monorepo.** `melos bootstrap`, common scripts (test, analyze, build_runner), pointer to `melos.yaml`.
5. **Running the examples.** `cd examples/desk_app && flutter run` and same for `example_app`; note about `--dart-define=SERVER_URL=...` and `API_KEY=...`.
6. **Related repos.** Links to `dart_desk_be` (backend), `dart_desk_cli`, `dart_desk_cloud`, `dartdesk-landing`.
7. **Contributing + License.**

---

## 3. `examples/desk_app/README.md`

**Audience:** people running the studio showcase.

**Length target:** ~30 lines.

**Section order:**

1. **Title + 1-line pitch.** "Runnable studio showcase for dart_desk."
2. **What it shows.** 6 wired document types covering all 16 field annotations, with `DocumentTypeDecoration` icons. Defaults to `CloudDataSource` against a hosted Dart Desk Cloud project.
3. **Run.** `flutter run`, with `--dart-define=SERVER_URL=...` and `API_KEY=...` overrides for self-host.
4. **Where to look.** Pointers: `lib/document_types.dart` (type wiring), `lib/bootstrap.dart` (DartDeskApp config), `lib/main.dart` (entrypoint).

---

## 4. `examples/example_app/README.md`

**Audience:** people running the consumer showcase.

**Length target:** ~25 lines.

**Section order:**

1. **Title + 1-line pitch.** "Runnable consumer-app showcase: reads published content from dart_desk via `dart_desk_client`."
2. **What it shows.** Pure consumer (no studio widgets); fetches content via `client.publicContent.getDefaultContents()`, decodes `PublicDocument.data`, and renders.
3. **Run.** `flutter run`, with env override note.
4. **Where to look.** Point at the screen that fetches + renders, and the `dart_mappable` decode site.

---

## 5. `dart_desk_be/dart_desk_server/README.md` (refresh)

**Audience:** developers running or self-hosting the backend.

**Length target:** ~90 lines (current is 47).

**Changes from current README:**

- Add rapid-dev disclaimer at top.
- Keep prerequisites + Getting Started (Docker compose + `dart bin/main.dart`) — minimal edits.
- Keep configuration section, add note on `passwords.yaml` not being committed and where to source secrets.
- **Expand Features** to reflect what's actually shipped:
  - Document CRUD with **soft delete**, slug reuse via partial unique indexes, and version status workflows.
  - **UUID primary keys** across all entities.
  - **CRDT-based collaborative editing** (existing).
  - **Media uploads** with single-pass server-side metadata extraction (EXIF, BlurHash, dominant palette, content hash).
  - **Public read API** (`publicContent`): `getDefaultContents`, `getDefaultContent`, plus JSONB containment lookups (`getContentsByDataContains`, `getAllContentsByDataContains`) for advanced device/segment routing.
  - **Auth**: Serverpod IDP (Google + email/password), API tokens, role guards (RBAC).
  - **Operational**: paginated responses, structured logging, purge service for soft-deleted rows, rate limiting, health check endpoint.
- Add a **JSONB containment caveats** note linking to the schema-drift section in `CLAUDE.md` (the `data_jsonb` generated column is hand-rolled and lives outside Serverpod's tooling).
- License unchanged (BSL 1.1).

---

## 6. `dart_desk_be/dart_desk_client/README.md` (refresh)

**Audience:** developers integrating consumer apps against the backend.

**Length target:** ~70 lines (current is 41).

**Changes from current README:**

- Add rapid-dev disclaimer at top.
- Keep installation snippet.
- **Reorganize Usage into two sections:**
  - **Public read API** (no auth required for default content; this is what consumer apps use). Show `client.publicContent.getDefaultContents()` returning `Map<String, PublicDocument>`, then `jsonDecode(doc.data)` and a `dart_mappable` decode. This is the integration surface most consumers actually need and is missing from the current README.
  - **Authenticated/admin API.** Existing `client.document`, `client.media`, `client.user`, `client.apiToken` usage with the Serverpod auth key manager.
- **Update endpoints table** to include `client.publicContent` (currently missing) and clarify which require auth.
- License unchanged (BSL 1.1).

---

## Open questions

None outstanding. Hero / screenshot assets are deferred to the user; placeholders mark the slots.
