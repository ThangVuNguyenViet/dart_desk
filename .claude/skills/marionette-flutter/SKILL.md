---
name: marionette-flutter
description: "Expert guidance for Marionette MCP, enabling AI agents to inspect and interact with running Flutter applications. Use when (1) setting up Marionette in a Flutter project, (2) configuring MCP server for Claude Code or Cursor, (3) automating UI testing with tap, enter_text, scroll_to, or take_screenshots, (4) debugging Flutter apps by inspecting widget trees or retrieving logs, (5) performing smoke tests or verifying user flows, (6) using replay mode to re-run recorded test sessions. Triggers include marionette, MCP server, flutter testing, widget inspection, UI automation, VM service, replay."
---

# Marionette Flutter

Marionette MCP enables AI agents to inspect and interact with running Flutter applications at runtime. It's "Playwright MCP, but for Flutter apps."

## Quick Setup

### 1. Add Package to Flutter App

```yaml
# pubspec.yaml
dev_dependencies:
  marionette_flutter: ^0.4.0
```

### 2. Initialize Binding (Debug Mode Only)

```dart
// main.dart
import 'package:flutter/foundation.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  }
  runApp(const MyApp());
}
```

**Logging options** (choose one):
```dart
// Option 1: Dart logging package
import 'package:marionette_logging/marionette_logging.dart';
MarionetteBinding.ensureInitialized(
  MarionetteConfiguration(logCollector: LoggingLogCollector()),
);

// Option 2: logger package
import 'package:marionette_logger/marionette_logger.dart';
MarionetteBinding.ensureInitialized(
  MarionetteConfiguration(logCollector: LoggerLogCollector()),
);

// Option 3: Default (PrintLogCollector) — no extra import needed
```

### 3. Install MCP Server

```bash
dart pub global activate marionette_mcp
```

### 4. Configure AI Tool

**Claude Code** (`.claude/mcp.json`):
```json
{
  "mcpServers": {
    "marionette": {
      "command": "dart",
      "args": ["run", "marionette_mcp"]
    }
  }
}
```

**Cursor** (`.cursor/mcp.json`):
```json
{
  "mcpServers": {
    "marionette": {
      "command": "marionette_mcp"
    }
  }
}
```

### 5. Connect to Running App

Run Flutter app in debug mode, find VM Service URI in console:
```
The Dart VM service is listening on http://127.0.0.1:12345/AbCdEfGh=/
```

Connect using `ws://127.0.0.1:12345/AbCdEfGh=/ws`

**Version check:** On connect, marionette_mcp verifies its version matches marionette_flutter. Mismatches fail with a clear error — update both packages together.

## Available Tools

| Tool | Purpose |
|------|---------|
| `connect` | Connect to Flutter app via VM Service URI |
| `disconnect` | Disconnect from current app |
| `get_interactive_elements` | List visible UI elements (buttons, inputs, etc.) |
| `tap` | Tap element by key or visible text |
| `enter_text` | Enter text by key or into focused element |
| `scroll_to` | Scroll until element is visible (auto-reverses direction) |
| `take_screenshots` | Capture base64-encoded screenshots |
| `get_logs` | Retrieve logs from configured log collector |
| `hot_reload` | Apply code changes without state loss |
| `list_custom_extensions` | Discover app-registered VM service extensions |
| `call_custom_extension` | Call an app-specific VM service extension |

### Text Entry

`enter_text` accepts **exactly one of**:
- `key`: Target by ValueKey — `enter_text(key: "email_field", input: "hello")`
- `focused_element: true`: Target currently focused field — tap a field first, then `enter_text(focused_element: true, input: "hello")`

`onChanged` callbacks are triggered properly.

### Custom Extensions

Apps can register VM service extensions. Discover them with `list_custom_extensions`, then call with `call_custom_extension(extension: "extensionName", args: {})`.

## Custom Widget Configuration

Register custom interactive widgets so marionette can discover them:

```dart
MarionetteBinding.ensureInitialized(
  configuration: MarionetteConfiguration(
    customInteractiveWidgets: [
      CustomWidget<MyButton>(
        type: InteractiveElementType.button,
        getText: (widget) => widget.label,
      ),
    ],
  ),
);
```

## Session Mode (Replay Support)

**At the start of every test session, ask the user:**
> "Is this a **replay** of a previous session, or a **new session**?"

- **New session**: Execute tests normally and record actions to the replay folder.
- **Replay**: Load and follow the replay file. Report as bug if a step cannot be followed (flexible on data changes like updated prices/text).

See [references/replay-mode.md](references/replay-mode.md) for full replay format and rules.

## Common Workflows

### Smoke Test After Refactor
1. Connect to running app
2. `get_interactive_elements` to see current screen
3. `tap` buttons to navigate
4. `take_screenshots` to verify visual state
5. `get_logs` to check for errors

### Form Testing
1. `get_interactive_elements` to find text fields
2. `enter_text` to fill form (by key or focused element)
3. `tap` submit button
4. `get_logs` to verify submission

### UI Debugging
1. Connect to app
2. `get_interactive_elements` to inspect widget tree
3. Identify missing or misplaced elements
4. `hot_reload` after fixes

## Limitations

- **Debug/profile mode only** — requires VM Service (not available in release)
- **Manual URI connection** — must copy URI from console each run
- **Custom widgets need configuration** — register non-standard interactive widgets
