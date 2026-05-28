# desk_sdui Phase 4 Continuation — Tasks 6–11

## Goal

Continue Phase 4 from where the previous spawn stopped (after Task 5: chef ported). This continuation plan covers **Tasks 6–11**: chef parity goldens + port and parity-test each of the 5 home variants. Tasks 12–15 (misuse suite, perf benchmark, README, v1 acceptance) are a separate follow-up.

## Context: what's already done

These commits already landed on `main` of `dart_desk_workspace/desk_sdui`:

- `4a2a51d` — bootstrap demo package
- `11e24f2` — vendor 6 originals (chef + 5 home variants), data shapes, ViewModels, fixtures, shared widgets
- `4b09e4d` — Phase 3 generator fix-ups (8 issues) + chef port (`chef.dart`, `chef.sdui.g.dart`, `chef.uib`)

The vendored originals already exist at `packages/desk_sdui_demo/lib/original/` (or wherever `11e24f2` placed them). **Read that directory first** before authoring any port — the originals are the source of truth for what the `@Screen` port must visually equal.

**Authoritative spec sections of the original Phase 4 plan:**
- Task 6 details: `dart_desk/.plans/desk-sdui-4-porting.md` lines 353–469
- Tasks 7–11 details: `dart_desk/.plans/desk-sdui-4-porting.md` lines 472–503

This continuation plan delegates the *exact step-by-step content* to those line ranges. Read them. Don't re-invent the parity test shape — use the `chef_parity_test.dart` template from line 361 verbatim, parameterized per screen.

## Constraints carried forward from original plan

- **Phase 4 is the integration test for Phases 1–3.** When porting reveals a missing IR construct or built-in widget, stop, file the gap as a Phase 1/2/3 fix-up commit, fix it there, and resume.
- Each port commit is its own commit. Don't bundle.
- Use Flutter's `matchesGoldenFile` machinery, not custom pixel comparison.
- Pre-existing chef port revealed these limitations to honor when porting home variants:
  - `BoxDecoration` and `LinearGradient` are not const-evaluable — they demote to placeholders in `.uib`. Plan for this; don't try to make them work without first fixing const eval (which is a Phase 3 fix-up).
  - Method invocations on data fields (`.toUpperCase()`, `.toStringAsFixed(2)`) are unsupported. The chef port worked around this by pre-computing fields on the data class. Apply the same pattern for home variants.
  - Reactive state codegen still emits stubs, not real `ValueListenableBuilder` bindings. If a home variant depends on reactive state, the parity test will diverge — file it as a Phase 3 fix-up before forcing it.

## Tasks

### Task 6: Chef parity test + goldens

Follow `dart_desk/.plans/desk-sdui-4-porting.md` lines 353–469 verbatim. Specifically:

- [ ] **Step 1**: Create `packages/desk_sdui_demo/test/parity/chef_parity_test.dart` using the template at lines 361–438.
- [ ] **Step 2**: Capture goldens — `cd packages/desk_sdui_demo && flutter test test/parity/chef_parity_test.dart --update-goldens`. This creates `goldens/chef.png` and `goldens/chef.sdui.png`.
- [ ] **Step 3**: Verify byte equality — `shasum packages/desk_sdui_demo/goldens/chef.png packages/desk_sdui_demo/goldens/chef.sdui.png`. Hashes MUST match. If they don't:
  - Diff the rendered widgets visually first (open both PNGs).
  - Identify which property/widget diverges in the port.
  - Either fix the port (if a typo) or file a Phase 1/2/3 fix-up commit (if a runtime/codegen gap), then re-capture.
  - **Do not commit divergent goldens.** "Pixel-identical" is the bar.
- [ ] **Step 4**: Lock — re-run without `--update-goldens`. Must pass.
- [ ] **Step 5**: Commit:

  ```bash
  git add packages/desk_sdui_demo/test/parity/chef_parity_test.dart packages/desk_sdui_demo/goldens
  git commit -m "test(desk_sdui_demo): chef parity goldens — sdui matches original"
  ```

### Tasks 7–11: Port + parity-test each home variant

Five iterations, identical shape, one commit each. Order:

1. `home_basic`
2. `home_categories`
3. `home_image`
4. `home_recent_order`
5. `home_scroll`

For **each** variant:

- [ ] **Step 1: Read the original** at `packages/desk_sdui_demo/lib/original/home_<variant>_original.dart` (or wherever it landed). Note any:
  - Method invocations on data → require pre-computed fields (chef-style workaround).
  - `BoxDecoration` / `LinearGradient` use → may need to demote to a `Container(color:...)` simplification, OR file a const-eval Phase 3 fix-up first.
  - Reactive state hookups → file Phase 3 fix-up first if encountered.
- [ ] **Step 2: Author the @Screen port** at `packages/desk_sdui_demo/lib/screens/home_<variant>.dart`. Annotate with `@Screen('home_<variant>')`. Top-level function `Widget build<Variant>(<DataType> data, <ControllerType> controller)`.
- [ ] **Step 3: Run codegen** — `dart run build_runner build --delete-conflicting-outputs` (run from monorepo root or the demo package; whichever the existing setup uses).
- [ ] **Step 4: Verify generated files exist**:
  - `packages/desk_sdui_demo/lib/screens/home_<variant>.sdui.g.dart`
  - `packages/desk_sdui_demo/lib/screens/home_<variant>.uib`
  - The `.uib` should contain JSON without `ConstNode` wrapping leaf literals (Phase 3 fix-up #4 from `4b09e4d`).
- [ ] **Step 5: Author parity test** at `packages/desk_sdui_demo/test/parity/home_<variant>_parity_test.dart`. Copy `chef_parity_test.dart` and substitute names. Three test cases: original render golden, sdui render golden, byte-equality test.
- [ ] **Step 6: Capture goldens** — `flutter test test/parity/home_<variant>_parity_test.dart --update-goldens`.
- [ ] **Step 7: Verify byte equality** — same shasum check as Task 6 step 3. **Goldens must be pixel-identical**. If not, debug per Task 6 step 3.
- [ ] **Step 8: Lock** — re-run without `--update-goldens`. Must pass.
- [ ] **Step 9: Commit** (per-variant, do not bundle):

  ```bash
  git add packages/desk_sdui_demo/lib/screens/home_<variant>.dart \
          packages/desk_sdui_demo/lib/screens/home_<variant>.sdui.g.dart \
          packages/desk_sdui_demo/lib/screens/home_<variant>.uib \
          packages/desk_sdui_demo/test/parity/home_<variant>_parity_test.dart \
          packages/desk_sdui_demo/goldens/home_<variant>.png \
          packages/desk_sdui_demo/goldens/home_<variant>.sdui.png
  git commit -m "feat(desk_sdui_demo): @Screen port + parity test — home_<variant>"
  ```

After Task 11 (home_scroll), all 6 screens (chef + 5 homes) should have a passing parity test.

## Done When

- 6 commits land on `main` (one per variant + chef parity).
- All 6 parity tests pass without `--update-goldens`.
- All 6 pairs of goldens are byte-identical (shasum matches per pair).
- `cd packages/desk_sdui_demo && flutter test` passes (all parity tests green).
- Any Phase 1/2/3 fix-ups required during porting are committed separately with `fix(<package>):` prefix and clearly identified in the commit body as discovered-during-Phase-4.

## Stop Conditions

- **Pixel divergence that requires deep IR/runtime work** → stop, write a one-paragraph note in the final report, do NOT force the goldens to match by changing the original. The whole point is parity.
- **Reactive state needed for a home variant** → file the Phase 3 reactive-binding gap as a fix-up commit, but if fixing it expands scope past 1–2 hours, stop and report. The user will decide whether to fix or to demote that variant out of v1.
- **build_runner errors on a port** → likely a new Phase 3 codegen gap. Capture the error, file the fix-up, retry. If it cascades into more fix-ups, stop after the third and report.

## Verify commands

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/desk_sdui
dart run build_runner build --delete-conflicting-outputs
cd packages/desk_sdui_demo
flutter test
```

Report at the end:
- 6 commit hashes (chef parity + 5 home variants)
- Any Phase 1/2/3 fix-up commits and what they fixed
- Any home variants that could not reach pixel parity, with reason
- Total time the parity test suite takes to run
