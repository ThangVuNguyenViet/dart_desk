# Rename "IR" terminology in spec + plans

## Goal

Replace the compiler-jargon term "IR" with Flutter-dev-friendly terminology across the desk_sdui spec and Phase 1–4 plans. Flutter developers don't know "IR"; they know `.uib` files (our file extension), "widget tree", and "wire format".

## Scope

Files to edit (in `/Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/`):

- `docs/superpowers/specs/2026-05-10-desk-sdui-design.md` (35 mentions)
- `.plans/desk-sdui-1-foundation.md` (95 mentions)
- `.plans/desk-sdui-2-runtime.md` (48 mentions)
- `.plans/desk-sdui-3-codegen.md` (85 mentions)
- `.plans/desk-sdui-4-porting.md` (5 mentions)

**Do NOT edit** any source code under `packages/` in either `desk_sdui/` or `dart_desk/`. Class names like `IrNode`, `IrEmitter`, file paths like `ir_node.dart` etc. are fine to keep — they're internal to the codegen package and not user-facing.

## Replacement rules

Apply these rules per occurrence — **judgment required, not blind sed**.

### Rule 1: "the IR" / "an IR" / "this IR" (referring to the wire artifact)

When "IR" refers to **the thing that gets shipped, downloaded, decoded, cached, or parsed** — replace with `.uib` payload terminology:

| Before | After |
|---|---|
| "the IR" | "the `.uib` payload" or "the widget payload" |
| "an IR file" | "a `.uib` file" |
| "ship the IR" | "ship the `.uib`" |
| "decode the IR" | "decode the `.uib`" |
| "IR cache" | "`.uib` cache" |
| "IR tree" (when meaning the on-wire shape) | "`.uib` tree" or "widget payload tree" |

### Rule 2: "lower to IR" / "emit IR" / "codegen produces IR" (codegen verbs)

When "IR" refers to **what codegen outputs**, replace with `.uib`:

| Before | After |
|---|---|
| "lower to IR" | "compile to a `.uib`" |
| "emit IR" | "emit a `.uib`" |
| "IR emitter" (in prose, not class names) | "`.uib` emitter" |
| "AST → IR lowering" | "AST → `.uib` compilation" |
| "IR generation" | "`.uib` generation" |

### Rule 3: "IR shape" / "IR format" (versioning / wire concepts)

When "IR" refers to **the format itself** — its versioning, stability, encoding choices — replace with "wire format":

| Before | After |
|---|---|
| "the IR shape" | "the wire format" |
| "IR format" | "wire format" |
| "IR will churn" | "wire format will churn" |
| "IR versioning" | "wire format versioning" |

### Rule 4: KEEP "IR" when referring to the in-memory tree of `IrNode` instances

When "IR" specifically means **the in-memory `IrNode` data structure** that the runtime walks during render (NOT the wire bytes) — leave it alone, OR replace with **"node tree"** or **"widget tree spec"** if the rewrite reads better.

Heuristic: if the sentence is talking about `IrNode`, `WidgetNode`, `RefNode`, etc. as Dart objects in memory — keep "IR" or use "node tree". If the sentence is about bytes-on-disk or bytes-on-wire — use `.uib`.

Examples that should stay (or become "node tree"):

- "the runtime walks the IR" → "the runtime walks the node tree" (or keep "IR")
- "IrNode hierarchy" → keep as-is (class name)
- "build the IR in memory" → "build the node tree in memory" (or keep "IR")

### Rule 5: Code identifiers stay

Do not rename:

- Dart class names (`IrNode`, `IrEmitter`, etc.)
- File names (`ir_node.dart`, `ir_emitter_dart.dart`, etc.)
- Variable names in code blocks
- Import paths

Only edit prose. Code blocks inside fenced ```dart``` should be left alone unless the surrounding sentence is being rewritten and the code reference becomes inconsistent.

## Process

For each file:

1. Read the file.
2. Find every occurrence of "IR" (case-sensitive, word-boundary).
3. For each, apply Rules 1–5 above using judgment.
4. After all edits, re-read the modified file and skim for awkward phrasing — sometimes a literal replacement reads badly and needs minor rephrasing for flow.
5. Commit per-file with a clear message.

## Commits

One commit per file. Five commits total. Suggested messages:

```
docs(desk_sdui): rename "IR" → ".uib" / wire format in design spec
docs(desk_sdui): rename "IR" → ".uib" / wire format in Phase 1 plan
docs(desk_sdui): rename "IR" → ".uib" / wire format in Phase 2 plan
docs(desk_sdui): rename "IR" → ".uib" / wire format in Phase 3 plan
docs(desk_sdui): rename "IR" → ".uib" / wire format in Phase 4 plan
```

## Verify

After all five commits:

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
grep -nP '\bIR(s|-tree-size)?\b' docs/superpowers/specs/2026-05-10-desk-sdui-design.md .plans/desk-sdui-1-foundation.md .plans/desk-sdui-2-runtime.md .plans/desk-sdui-3-codegen.md .plans/desk-sdui-4-porting.md
```

Expected output: only mentions that fall under Rule 4 (in-memory node tree) or Rule 5 (code identifiers/file names). Specifically, occurrences inside code blocks, class name references, and file paths are expected to remain.

Report a count of remaining IR mentions per file and a one-line justification for why each remaining mention is a Rule 4 or Rule 5 case.

## Out of scope

- Do not edit source code under `packages/`.
- Do not edit `dart_desk/CLAUDE.md`, `AGENTS.md`, or any other unrelated docs.
- Do not rename class names or file names — they're an internal detail.
- Do not touch the foodtech worktree at `foodtech_flutter_design_system_eval_poc/`.
