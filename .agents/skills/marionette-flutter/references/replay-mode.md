# Replay Mode

Replay mode re-runs a previously recorded test session by following the saved marionette commands.

## Replay File Location

```
test_automation/replays/C{id}_replay.json
```

Files have **no timestamps** — subsequent runs overwrite the same file so `git diff` shows exactly what changed.

## Replay File Format

```json
{
  "test_case_id": "C134",
  "test_case_title": "Sign In",
  "actions": [
    {"step": 1, "tool": "connect", "params": {"uri": "ws://127.0.0.1:8181/ws"}},
    {"step": 2, "tool": "tap", "params": {"text": "Sign In"}},
    {"step": 3, "tool": "enter_text", "params": {"key": "email_field", "input": "user@example.com"}},
    {"step": 4, "tool": "scroll_to", "params": {"text": "Submit"}},
    {"step": 5, "tool": "call_custom_extension", "params": {"extension": "myExt", "args": {}}},
    {"step": 6, "tool": "hot_reload", "params": {}},
    {"step": 7, "tool": "disconnect", "params": {}}
  ]
}
```

### Recorded Tools

Record **only** these marionette commands:
- `connect`, `tap`, `enter_text`, `scroll_to`, `hot_reload`, `call_custom_extension`, `disconnect`

**Exclude** from recording: `take_screenshots`, `get_interactive_elements`, `get_logs`, `list_custom_extensions`.

## Recording (New Session)

Build the replay actions list as you execute each marionette command. After the test completes (before disconnect):

1. Write `test_automation/replays/C{id}_replay.json` with the collected actions.
2. The file overwrites any existing replay for that test case.

## Replaying (Replay Session)

1. **Load** `test_automation/replays/C{id}_replay.json`. If missing, inform user and fall back to new session mode.
2. **Execute each action in order**, calling `get_interactive_elements` after each to verify state (as normal).
3. **Flexible matching** — test data may have changed between sessions:
   - If a `tap` target text changed slightly (e.g., price updated), match by element position/key instead.
   - If an `enter_text` input value differs, use the replay's value (it represents the intended test input).
   - If a screen has additional elements (new modal, banner), dismiss them and continue.
4. **Report as BUG** if you cannot follow a replay step — e.g., expected element is completely missing, navigation leads to a different screen, or an action fails after reasonable retry.
5. **Still record** the action log and capture API logs as normal — replay mode only changes how you decide what actions to take.
6. **Do NOT overwrite** the replay file during a replay session — preserve the original for diffing.
