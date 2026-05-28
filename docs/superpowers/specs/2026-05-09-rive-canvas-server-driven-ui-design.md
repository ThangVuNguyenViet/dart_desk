# Rive Canvas — Server-Driven UI Design

- **Date:** 2026-05-09
- **Status:** Draft, pending review
- **Owner:** thangvu
- **Scope:** Cross-repo experiment spanning `dart_desk` (Flutter) and `dart_desk_be` (Serverpod)
- **Workspace:** Implementation must run in a `git worktree` per repo (this is experimental)

## 1. Problem

dart_desk-powered apps (food-ordering CMS, white-label) currently ship UI as Flutter code. Visual changes — promo refreshes, seasonal looks, per-tenant theming, A/B layout tests — require an app build and store review. The agency model wants:

1. **Marketing velocity** — designers ship visual changes weekly without engineering involvement.
2. **White-label at scale** — visually distinct apps from one codebase, configured per tenant.
3. **A/B testing** — visual variants per cohort, measured.

Behavior changes (new flows, payment changes, native integrations) remain in the binary. This is explicitly out of scope.

## 2. Approach

**Rive-first canvas with Flutter slots.** Each templated screen is a Rive artboard authored by a designer; specific subregions are named layout containers ("slots") into which Flutter widgets are mounted. The Flutter app shell (router, auth, payments, system dialogs) stays Flutter-native. Routed content pages are Rive-templated. Per-tenant/cohort selection of `.riv` templates and ViewModel bindings happens in dart_desk CMS, served by Serverpod.

This is the option labeled "Approach 1" during brainstorming, after the canvas-vs-composition fork was decided in favor of canvas (β).

### 2.1 Three boundaries

| Concern | Owner | Lives in |
|---|---|---|
| **Behavior** — what an action *does* (API calls, validation, error handling) | Dev | App binary |
| **Look** — visuals, layout, motion, copy, where things go | Designer | `.riv` files + CMS bindings |
| **Wiring** — "this Rive event triggers `addToCart` with `productId={productId}`" | Dev | Code or shipped config in app binary |

CMS does **not** author event-action wiring in v1. Wiring lives in code/config and ships with the binary; the catalog of actions is the contract designers consume.

### 2.2 Screen model

- **App shell is Flutter** — `MaterialApp.router`, bottom nav, auth gate, payment sheets, push registration, system error pages.
- **Routed content pages are Rive-templated** by default. Each templated route is a `RiveTemplatedScreen('route_name')` widget at the route destination.
- **Opt-out screens are Flutter-authored** — login, password reset, error states, deep system flows, anything where CMS-driven content is inappropriate. Listed explicitly in the Slot Catalog config.

### 2.3 What is a slot?

A slot is a Flutter widget mounted at the world bounds of a named layout container inside a Rive artboard. Slots are reserved for things Rive structurally cannot render today:

1. Native text input (IME, autocorrect, system keyboard, password masking).
2. Long recycled scrollable lists (Rive's layout renders all nodes every frame).
3. Native scroll physics (until Rive Phase 3 scrolling lands in pub.dev).
4. System sheets and platform views (payments, share, date picker, camera, maps, video, web view).
5. Accessibility-critical interactive elements that need first-class Semantics tree presence (mitigates v1 a11y gap; see §11).

Everything else — cart pill, buttons, badges, hero, promo cards, empty states, decoration, animation — is Rive content inside the template.

## 3. Architecture

### 3.1 Components (Flutter, in `dart_desk` packages)

A new package `packages/dart_desk_canvas/` contains the platform code. The existing `dart_desk_widgets` package depends on it for app-side use.

- **`RiveBundleCache`** — Versioned `.riv` fetch + on-disk cache keyed by `(url, version)`. LRU eviction. Pre-warm hook for next-likely templates. Backed by `path_provider` documents directory.
- **`RiveTemplatedScreen`** — Top-level widget for a templated route. Fetches the resolved `RiveTemplateConfig`, loads the `.riv`, instantiates artboard + state machine, applies bindings, renders the canvas full-bleed, mounts each declared slot.
- **`SlotBoundsRuntime`** — Walks the artboard's layout component tree, finds named containers (convention: `slot:<name>`), exposes per-frame world `Rect` per slot via `ValueListenable<Rect>`. Built on `Component.localBounds` (shipped 0.14.0-dev.7) + `getTransformTo` for parent-chain composition.
- **`SlotRegistry`** — App-wide registry of `String → WidgetBuilder(Map<String,String> params)`. The dev-defined catalog of mountable Flutter widgets.
- **`ActionCatalog`** — App-wide registry of `String → ActionHandler` with typed param specs. The dev-defined behavior vocabulary.
- **`RiveEventDispatcher`** — Subscribes to state-machine events on the active artboard, looks up the wiring config, resolves event payload templates (`{productId}` from event property → action param), invokes the matching `ActionCatalog` handler.
- **`HitTestPartitioner`** — Configures the `RiveWidget`'s `hitTestBehavior` (shipped 0.14.4) so taps inside a slot rect bypass Rive's gesture detector and reach the mounted Flutter widget. Slots live in a `Stack` above the canvas.
- **`ScrollOffsetBridge`** — For any slot whose container is named `scroll:<name>` (instead of `slot:<name>`), the runtime treats the mounted Flutter scroll widget as the source and forwards the scroll offset into a Rive ViewModel `Number` property named `<name>_offset`. Lets designers author scroll-driven motion in their state machine.
- **`TemplateFallback`** — Per-template Flutter widget rendered when fetch fails, parse fails, or `minAppVersion` mismatches. Each templated route registers its fallback.

### 3.2 Components (Serverpod, in `dart_desk_be`)

- **`RiveTemplateConfig` model** — `.spy.yaml` with the schema in §4.
- **`RiveTemplate` endpoint** — `getTemplateConfig(routeName, tenantId, cohort) → RiveTemplateConfig`. Resolves tenant-default-then-override, cohort variant selection (deterministic by user-id hash), returns the merged config.
- **CDN-fronted `.riv` storage** — `.riv` bundles uploaded via the existing dart_desk asset pipeline. Versioned URLs, immutable per version. Existing dart_desk image pipeline is reused; no new infra.
- **CMS authoring UI** — dart_desk editor screens for `RiveTemplateConfig`: pick artboard / state machine, edit ViewModel bindings (typed form generated from the registered Slot Widget Catalog and the template's declared VM schema), assign slot widgets and parameters per slot container.

### 3.3 Components (dev-authored, ship in app binary)

- **Slot Widget Catalog** — Dart code: `SlotRegistry.register(...)` calls in app bootstrap. Each entry is `{key, builder, paramSpec}`.
- **Action Catalog** — Dart code: `ActionCatalog.register(...)` calls in app bootstrap. Each entry is `{name, paramSpec, handler}`.
- **Per-template Wiring Config** — YAML or JSON shipped as a Flutter asset, loaded on app start. Maps `(templateName, eventName) → action(params)` with template strings for payload propagation. Rationale: keeping wiring out of CMS in v1 avoids an authoring UI burden and gives engineering review of behavior changes.
- **Designer handoff doc per template** — Markdown manifest in `dart_desk/docs/templates/<name>.md` documenting expected slots, VM schema, events. Produced by designer + dev jointly.

## 4. Data model

```yaml
# dart_desk_be/dart_desk_server/lib/src/generated/protocol/rive_template_config.spy.yaml
class: RiveTemplateConfig
table: rive_template_config
fields:
  routeName: String          # "home", "menu", "checkout"
  tenantId: String?          # null = default for all tenants
  cohort: String?            # null = default for all cohorts
  bundleUrl: String          # https://cdn.../home_v12.riv
  artboard: String
  stateMachine: String
  viewModelInstance: String  # which VM instance to bind
  bindings: Map<String, String>  # property name → value template ("{tenantLogoUrl}")
  slots: List<RiveSlotMount>
  fallbackKey: String        # SlotRegistry key for the static Flutter fallback
  minAppVersion: String      # semver; templates with higher requirements are skipped
  version: int               # cache-bust
indexes:
  rive_template_config_lookup_idx:
    fields: routeName, tenantId, cohort
    unique: true

class: RiveSlotMount
fields:
  containerName: String      # "primary_list" (matches "slot:primary_list" in artboard)
  widgetKey: String          # SlotRegistry key — "scrollable_menu", "search_field"
  params: Map<String, String>
```

Wiring config (Flutter asset, `assets/canvas/wiring.yaml`):

```yaml
home:
  cta_tapped:
    action: deeplink
    params:
      to: "{to}"
  hero_dismissed:
    action: dismissHero
menu:
  product_card_tapped:
    action: openProduct
    params:
      productId: "{productId}"
```

## 5. Runtime flow

1. Router pushes `RiveTemplatedScreen('home')`.
2. Widget reads `(tenantId, cohort)` from app session, calls Serverpod `getTemplateConfig('home', ...)`.
3. `RiveBundleCache.fetch(bundleUrl, version)` returns the local file path; downloads if not cached. ETag honored for revalidation.
4. `RiveWidgetController` loads the artboard, attaches state machine, binds VM instance.
5. For each binding in config, the corresponding ViewModel property is written using template substitution against the session context.
6. `SlotBoundsRuntime` walks the artboard, finds `slot:*` and `scroll:*` containers, registers `ValueListenable<Rect>` per slot.
7. The widget renders `Stack` with the canvas at the back and one `Positioned.fromRect` per slot binding to its `ValueListenable`.
8. `RiveEventDispatcher` subscribes to state-machine events. On each fired event, it looks up `wiring[templateName][eventName]`, substitutes payload properties, and invokes the matching `ActionCatalog` handler.
9. `HitTestPartitioner` ensures slot rects route gestures to the Flutter widget.
10. For `scroll:` slots, the Flutter scroll widget's `ScrollController.offset` is mirrored into the `<name>_offset` ViewModel property each frame (throttled to display refresh rate).
11. On any failure (fetch, parse, minAppVersion), `TemplateFallback[fallbackKey]` is rendered instead.

## 6. Authoring contracts

### 6.1 Designer (per template, in Rive editor)

1. Create a screen artboard using Layouts (responsive, Hug/Fill, N-slicing where appropriate).
2. Place named empty layout containers prefixed `slot:` for Flutter widgets and `scroll:` for the scroll-source slot. Set Fill behavior; document expected widget per container.
3. Define a ViewModel listing all externally-settable inputs with types: text, color, image, number, enum, boolean.
4. Bind elements to ViewModel properties.
5. Author state machine; declare Rive Events with payload property shapes.
6. Test against the dev-shipped Slot Widget Catalog (designer needs a dev-provided "host harness" build to preview; see §10).
7. Hand off: `.riv` URL, artboard name, state-machine name, VM schema table, event list with payload shape, slot manifest.

### 6.2 Dev (one-time per app)

1. Build the platform layer (`dart_desk_canvas` package) — see §3.1.
2. Register the Slot Widget Catalog. v1 catalog: `search_field`, `scrollable_menu`, `address_picker_button`, `payment_button`. Add per real need.
3. Register the Action Catalog. v1 catalog: `deeplink(to)`, `addToCart(productId, quantity?)`, `openProduct(productId)`, `share(content)`, `signIn`, `dismissHero`. Add per real need.
4. Author per-template wiring config, reviewed alongside template handoff.
5. Author each template's static fallback Flutter widget; register in `SlotRegistry`.
6. Configure Serverpod endpoint and migrations.

### 6.3 CMS author (per tenant/cohort, in dart_desk)

1. Pick template for the route (or use default).
2. Edit ViewModel bindings — typed form generated from the template's declared VM schema. Constants and a small set of session placeholders (`{firstName}`, `{tenantLogoUrl}`, `{accentColor}`).
3. Assign slot widget + params per slot container — dropdowns from the registered Slot Widget Catalog.
4. Save → publishes a new version row.

## 7. Catalogs (v1)

### 7.1 Slot widgets

| Key | Backing widget | Why it must be Flutter |
|---|---|---|
| `search_field` | `ShadInputFormField` wrapper | Native IME |
| `scrollable_menu` | `MenuListSliver` | Recycled list + native scroll |
| `address_picker_button` | Tappable opening `showModalBottomSheet` | System sheet |
| `payment_button` | Apple/Google Pay button | Platform integration |
| `static_fallback_<name>` | Static `Container`/`Image` | Used by `TemplateFallback` |

### 7.2 Actions

| Action | Params | Description |
|---|---|---|
| `deeplink` | `to: path` | Navigate via app router |
| `openProduct` | `productId: string` | Push product detail route |
| `addToCart` | `productId: string`, `quantity: int = 1` | Cart VM mutation + toast |
| `share` | `content: string` | Show OS share sheet |
| `signIn` | — | Push auth flow |
| `dismissHero` | — | Local state — hides the slot until session end |

## 8. Hard problems and mitigations

| Problem | v1 mitigation | Trajectory |
|---|---|---|
| **Slot-bounds runtime is custom** | Build it on shipped APIs (`localBounds`, `getTransformTo`); time-box a 1-week feasibility spike before broader investment | Likely simpler as upstream layout APIs stabilize |
| **A11y outside slots** | House rule: all interactive/informational elements that must be a11y-discoverable belong in slots. CMS lints templates with no slots. Document for designers | Rive `SemanticManager` is in upstream master (commits visible). Plan to bridge to Flutter Semantics when it lands in pub.dev |
| **Native scroll lives in slots** | `scroll:` slot type + offset bridge | Rive Phase 3 scrolling + `ArtboardComponentList` in upstream master will eventually let scroll lists be native Rive |
| **Asset weight & cold start** | Versioned cache, prewarm next-likely template, loading state for first paint, fallback if fetch slow | CDN edge caching, possible Brotli for `.riv` |
| **App Store policy** | `.riv` is data; no executable code crosses to host. Rive Scripting permitted *inside* artboard only; nothing reaches the app except declared events. Document in designer guidelines | Re-review with legal if scripting use widens |
| **Performance budget** | Per-template perf review at handoff; target 60fps on midrange devices; fallback to static if dropped frames exceed threshold | Telemetry-driven |
| **Versioning compatibility** | Templates declare `minAppVersion`; older binaries fall back. Slot/Action catalog entries are additive only; deprecations require ≥2 release deprecation window | Catalog version included in telemetry |
| **Rive runtime risk** | Pin `rive: ^0.14.6` for v1. Track upstream master for `SemanticManager`, `ArtboardComponentList`, scroll components. Architect so removing a slot kind (because Rive can do it natively) is a deletion, not a rewrite | Subscribe to rive-flutter releases |

## 9. Forward-compatibility

Architectural rules that buy room for upstream Rive evolution:

- **Never let app code reach into slot widget internals** — slots are a registry contract, not a class hierarchy.
- **Slot Widget Catalog entries are deletable.** When `ArtboardComponentList` reaches the Flutter runtime, `scrollable_menu` may become unnecessary; deleting it must not break templates that no longer need it.
- **Events and actions are versioned independently.** Old templates with old event names continue to work even after the action handler is rewritten.
- **No bundling of `.riv` assets in the binary** for v1, except fallbacks. All canvas content is fetched.

## 10. Designer preview / iteration loop

Out of scope for the first build, but documented to avoid a v2 surprise:

- **Designer host harness:** a stripped-down Flutter app the designer runs locally that points at a staging `.riv` URL. Hot-swap by changing the URL; the harness re-fetches and re-renders.
- **Local override in dev builds:** `RIVE_LOCAL_OVERRIDE=/path/to/file.riv` env var causes `RiveBundleCache` to load from disk. Lets a designer ship a `.riv` to the dev's machine for review.

To be specced separately when the v1 platform exists.

## 11. Experiment scope (v1 build)

In a `git worktree` off `main` for both `dart_desk` and `dart_desk_be`:

1. **Spike (week 1):** prove `SlotBoundsRuntime` works at 60fps with one named container in a real artboard. Pass/fail gate; if it can't be made to work, the entire approach falls back to the composition-list alternative ("Approach 2.5" in brainstorming) and this spec is superseded.
2. **Platform (weeks 2–3):** `RiveBundleCache`, `RiveTemplatedScreen`, `SlotRegistry`, `ActionCatalog`, `RiveEventDispatcher`, `HitTestPartitioner`, `ScrollOffsetBridge`, `TemplateFallback`. No CMS yet; configs hardcoded in app bootstrap for the first probe.
3. **Probe screen (week 4):** tenant Home with one Rive template containing:
   - `slot:search_field` at top
   - `slot:scrollable_menu` in body
   - everything else (hero, cart pill, promo cards, category strip) as Rive content inside the artboard
   - one button firing `cta_tapped` → wired to `addToCart` for a fixed product
   - real `addToCart` mutation on the existing CartVm; toast on success
4. **Serverpod side (weeks 5–6):** `RiveTemplateConfig` model, endpoint, migration, basic CMS form in dart_desk authoring UI. Replace hardcoded probe config with CMS-served config.
5. **Probe validation (week 7):** designer authors a second `.riv` for the same Home route, replaces it via CMS, app fetches and renders without rebuild. This is the proof the architecture works end-to-end.

**Explicitly out of scope for v1:** A/B cohort split, telemetry beyond logs, image binding for tenant photos (constants only), CMS event-action wiring UI, designer preview harness, multiple templated routes (one is enough for the probe), Android/iOS performance tuning beyond "no obvious regressions".

## 12. Success criteria

- Designer hands off a new `.riv`, CMS author updates `bundleUrl` and `version`, the app on next launch fetches and renders the new design — with zero engineering involvement and zero app rebuild.
- A button authored in Rive on that new design fires `cta_tapped`, the wired `addToCart` action mutates the cart, the toast appears, the cart pill animates.
- `slot:search_field` accepts native IME input; `slot:scrollable_menu` scrolls with native physics and recycles offscreen rows.
- Fetch failure shows the fallback within 200ms; subsequent successful fetch swaps to the canvas on next session.
- 60fps sustained on a 2022-era midrange Android device with the probe screen visible.

## 13. Non-goals

- Server-driven *behavior*. Actions are dev-defined.
- Replacing the auth, payment, or settings flows.
- Allowing CMS authors to add new actions or new slot widget kinds without an app build.
- Cross-platform (web, desktop) parity in v1 — mobile only for the probe.
- Real-time template push (poll-on-launch is sufficient for v1).

## 14. Open questions to resolve before writing the implementation plan

1. **Scroll-offset bridge throttling rate** — display refresh tick vs. fixed 60Hz vs. coalesced via `Stream.throttle`. Pick after the spike measures cost.
2. **Tenant placeholder set** — exact list of `{...}` placeholders the binding template engine resolves. v1 needs at least `{firstName}`, `{tenantLogoUrl}`, `{accentColor}`. More can be added.
3. **Cohort assignment authority** — does the app or the server decide which cohort a user is in? Recommendation: server (deterministic by user-id hash, stored on user record). Defer to existing dart_desk_be patterns.
4. **`.riv` upload pipeline** — does it go through dart_desk's existing asset uploader (S3) or a new path? Recommendation: existing uploader, content-type `application/octet-stream`.
5. **Wiring config format** — YAML asset vs. Dart code vs. generated from a `@WiringSpec` annotation. Recommendation: YAML for v1 (simplest, hot-reloadable on debug builds).

## 15. Alternatives considered

Other Flutter server-driven UI solutions exist; none satisfy goal β (canvas-quality designer-authored visuals and motion). They are documented here so the choice is auditable.

| Tool | Category | What it gives | Why it doesn't fit |
|---|---|---|---|
| **RFW** (Remote Flutter Widgets, flutter.dev, v1.1.3) | Widget-tree SDUI | Renders declarative Flutter widget trees fetched at runtime; official Flutter team | Docs explicitly out-of-scope: "page transitions, drag and drop, custom painters". Designer is bounded by Flutter's stock widget appearance. Solves α (composition + theming), not β. |
| **Stac** / formerly Mirai (stac.dev, v1.4.0) | Widget-tree SDUI | JSON payload from Dart DSL; routing, forms, theming, screen caching | Same category as RFW — Flutter widget vocabulary over the wire. No canvas-quality motion design. Solves α, not β. |
| **MXFlutter** (Tencent) | JS runtime over Flutter | JavaScript-driven widget trees | App Store policy gray area; project momentum has declined; would couple us to a JS runtime we don't otherwise need. |
| **Lottie / Hummingbird** | Animation asset format | High-fidelity animations | Not interactive UI. Suitable for hero animations within Flutter or Rive, not as a UI delivery mechanism. |
| **Custom Dart code download** | Hot-loaded bytecode | Full Flutter capability | App Store rejection risk for non-content code download; not viable on iOS. |

The category we want is **graphics-tree + state-machine** (Rive), not widget-tree (RFW/Stac). Rive is the only Flutter-compatible option in that category.

**Possible future intersection:** RFW could later replace the compile-time `SlotRegistry` so slots become CMS-authored Flutter widget trees instead of dev-registered keys. This trades flexibility for a second DSL designers must learn. Out of scope for v1 (the fixed Slot Widget Catalog of ~5 entries is sufficient); revisit if the catalog grows past ~20 entries or CMS authors need ad-hoc native blocks.

## 16. References

- [Rive Layouts overview](https://rive.app/docs/editor/layouts/layouts-overview)
- [Rive Layouts Phase 2 — N-Slicing](https://rive.app/blog/responsive-layouts-phase-two-n-slicing)
- [Rive releases blog](https://rive.app/blog/releases)
- [rive Flutter package on pub.dev](https://pub.dev/packages/rive)
- [rive-flutter changelog](https://pub.dev/packages/rive/changelog) — pinned reference: 0.14.6
- [rive-flutter master commits](https://github.com/rive-app/rive-flutter/commits/master/) — `SemanticManager`, `ArtboardComponentList`, `FocusData` snap-scroll
- Brainstorming session: 2026-05-09 (this conversation)
