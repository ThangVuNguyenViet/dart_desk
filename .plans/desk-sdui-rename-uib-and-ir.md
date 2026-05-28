# Rename `.uib` → `.sdui.json` and sweep "IR" terminology

## Goal

1. Rename the wire-payload file extension `.uib` → `.sdui.json` across both repos (`dart_desk` docs + `desk_sdui` source).
2. Sweep "IR" (compiler jargon) out of user-facing prose in the spec + Phase 1–4 plans, replacing with `.sdui.json` payload, "widget payload", or "wire format" depending on context.

Both renames serve the same goal: make the docs and the artifacts comprehensible to a Flutter dev who has never read a compilers textbook.

## Scope — two repos

### Repo A: `/Users/vietthangvunguyen/Workspace/dart_desk_workspace/desk_sdui/` (source code)

This is where the actual `.uib` extension is wired into codegen and runtime. **Edit code here.**

### Repo B: `/Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/` (specs + plans)

This is where the IR / `.uib` terminology lives in prose. **Edit docs here.**

Each repo gets its own commits; do not cross-commit.

---

## Part 1: Rename `.uib` → `.sdui.json` in source (Repo A)

### Files to change in `desk_sdui/`

Find them with:

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/desk_sdui
grep -rn '\.uib\|"uib"\|'"'"'uib'"'"'' --include='*.dart' --include='*.yaml' --include='*.json' --include='*.md' .
```

Expected hot spots (verify with grep above):

- `packages/desk_sdui_generator/build.yaml` — `build_extensions` mapping `.dart` → `.uib`
- `packages/desk_sdui_generator/lib/src/builders.dart` — builder output extension
- `packages/desk_sdui_generator/lib/src/screen_lowering/ir_emitter_json.dart` — the JSON emitter (file might write `.uib`)
- `packages/desk_sdui_generator/lib/src/screen_lowering/screen_generator.dart` — emit logic
- `packages/desk_sdui/lib/src/runtime.dart` — fetcher/assetBundle path resolution (looks for `<name>.uib`)
- `packages/desk_sdui_demo/lib/screens/chef.uib` — physical file to rename → `chef.sdui.json`
- Any tests asserting on `.uib` paths

### Steps

- [ ] **Step 1: Survey.** Run the grep above. Capture the full list. Anything outside the expected hot spots — investigate before editing.

- [ ] **Step 2: Rename `build.yaml` extension mapping.**

  Change `build_extensions` so the JSON output is `.sdui.json` instead of `.uib`. The `.sdui.g.dart` mapping stays as-is. Example shape:

  ```yaml
  build_extensions:
    "^lib/{{}}.dart":
      - "lib/{{}}.sdui.g.dart"
      - "lib/{{}}.sdui.json"
  ```

- [ ] **Step 3: Update builder code.** In `builders.dart` / `screen_generator.dart` / `ir_emitter_json.dart`, change every literal `.uib` to `.sdui.json`. Keep the JSON contents identical — we're only renaming the extension.

- [ ] **Step 4: Update runtime.** In `runtime.dart`, change asset-bundle and fetcher path resolution from `<name>.uib` to `<name>.sdui.json`. Update any cache-key comments.

- [ ] **Step 5: Rename the existing chef artifact.**

  ```bash
  cd packages/desk_sdui_demo
  git mv lib/screens/chef.uib lib/screens/chef.sdui.json
  ```

  (If `.gitignore` excludes `*.sdui.json`, add an exception parallel to the existing `*.g.dart` exception. Check the demo package `.gitignore`.)

- [ ] **Step 6: Regenerate.**

  ```bash
  cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/desk_sdui
  dart run build_runner build --delete-conflicting-outputs
  ```

  Expected: `chef.sdui.json` is regenerated with identical content to the renamed file. Old `chef.uib` should NOT reappear.

- [ ] **Step 7: Verify analyze + tests.**

  ```bash
  cd packages/desk_sdui && dart analyze
  cd ../desk_sdui_generator && dart analyze
  cd ../desk_sdui_demo && flutter analyze
  cd ../desk_sdui && dart test
  cd ../desk_sdui_generator && dart test
  ```

  All must be green.

- [ ] **Step 8: Commit (one commit, file-extension renames belong together).**

  ```bash
  git add -A
  git commit -m "refactor(desk_sdui): rename .uib wire artifact to .sdui.json"
  ```

### Out of scope for Part 1

- Do NOT rename Dart class names (`IrNode`, `IrEmitter`, `JsonIrCodec`, etc.). Those are internal.
- Do NOT rename the `.sdui.g.dart` partial — that one's already correctly named.
- Do NOT touch the foodtech worktree or the eval POC.

---

## Part 2: Sweep "IR" terminology (Repo B — docs only)

### Files to edit in `dart_desk/`

- `docs/superpowers/specs/2026-05-10-desk-sdui-design.md` (35 mentions)
- `.plans/desk-sdui-1-foundation.md` (95 mentions)
- `.plans/desk-sdui-2-runtime.md` (48 mentions)
- `.plans/desk-sdui-3-codegen.md` (85 mentions)
- `.plans/desk-sdui-4-porting.md` (5 mentions)

### Replacement rules — apply with judgment, not blind sed

#### Rule 1: "the IR" / "an IR" referring to **the wire artifact**

When "IR" means the thing shipped, downloaded, decoded, cached, or parsed:

| Before | After |
|---|---|
| "the IR" | "the `.sdui.json` payload" or "the widget payload" |
| "an IR file" | "a `.sdui.json` file" |
| "ship the IR" | "ship the `.sdui.json`" |
| "decode the IR" | "decode the `.sdui.json`" |
| "IR cache" | "`.sdui.json` cache" |

#### Rule 2: codegen verbs

When "IR" is what codegen outputs:

| Before | After |
|---|---|
| "lower to IR" | "compile to a `.sdui.json`" |
| "emit IR" | "emit a `.sdui.json`" |
| "AST → IR lowering" | "AST → `.sdui.json` compilation" |
| "IR generation" | "`.sdui.json` generation" |

#### Rule 3: format-as-concept

When "IR" refers to versioning / stability / encoding:

| Before | After |
|---|---|
| "the IR shape" | "the wire format" |
| "IR format" | "wire format" |
| "IR will churn" | "wire format will churn" |
| "IR versioning" | "wire format versioning" |

#### Rule 4: KEEP "IR" or use "node tree" when referring to the in-memory `IrNode` tree

If the sentence is talking about `IrNode` instances as Dart objects in memory (the thing the runtime walks during render), either keep "IR" or rephrase to **"node tree"** if it reads better.

Heuristic: bytes/disk/wire → `.sdui.json`. In-memory Dart objects → "IR" stays, or "node tree".

#### Rule 5: code identifiers stay

Do NOT rewrite inside fenced code blocks. Class names (`IrNode`, `IrEmitter`), file paths (`ir_node.dart`), and import paths stay as-is. Only edit prose.

### Steps

- [ ] **Step 1: For each of the 5 files, edit per Rules 1–5.** After editing, re-read the file and skim for awkward phrasing — sometimes a literal replacement reads badly and needs minor rephrasing for flow.

- [ ] **Step 2: Per-file commit.** Five commits.

  ```
  docs(desk_sdui): rename "IR" → ".sdui.json" / wire format in design spec
  docs(desk_sdui): rename "IR" → ".sdui.json" / wire format in Phase 1 plan
  docs(desk_sdui): rename "IR" → ".sdui.json" / wire format in Phase 2 plan
  docs(desk_sdui): rename "IR" → ".sdui.json" / wire format in Phase 3 plan
  docs(desk_sdui): rename "IR" → ".sdui.json" / wire format in Phase 4 plan
  ```

- [ ] **Step 3: Verify.**

  ```bash
  cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
  grep -nP '\bIR(s|-tree-size)?\b' docs/superpowers/specs/2026-05-10-desk-sdui-design.md .plans/desk-sdui-*.md
  ```

  Expected: only Rule 4 (in-memory node tree) and Rule 5 (code identifiers/file paths) cases remain. Report a count of remaining IR mentions per file with one-line justification for each remaining mention.

---

## Order of operations

1. Do **Part 1 first** (rename `.uib` → `.sdui.json` in source). One commit.
2. Then do **Part 2** (IR sweep in docs). Five commits.

Doing Part 1 first ensures the docs reference the new filename consistently when the sweep happens.

## Final report

When complete, report:

- The single Part 1 commit hash on `desk_sdui` `main`.
- The five Part 2 commit hashes on `dart_desk` `main`.
- Count of "IR" mentions still present per file, with Rule-4 / Rule-5 justification.
- Any unexpected references to `.uib` discovered during the survey that needed handling beyond the expected hot spots.
