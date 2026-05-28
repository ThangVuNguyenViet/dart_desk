# Serverpod Sessions Reference

## Table of Contents
- [Overview](#overview)
- [Session Properties](#session-properties)
- [Session Types](#session-types)
- [Manual Sessions](#manual-sessions)
- [Common Pitfalls](#common-pitfalls)

## Overview

A Session is a request-scoped context object that exists for the duration of a single client request or connection. It provides access to all server resources.

## Session Properties

```dart
session.db              // Database operations
session.caches          // Local and distributed caching
session.storage         // File storage operations
session.messages        // Real-time server events
session.passwords       // Configuration credentials (from passwords.yaml)
session.authenticated   // AuthenticationInfo? (synchronous in 3.x)
```

## Session Types

| Type | Purpose | Lifetime |
|------|---------|----------|
| `MethodCallSession` | Future endpoint methods | Single request |
| `WebCallSession` | Web server routes | Single request |
| `MethodStreamSession` | Stream endpoint methods | Stream duration |
| `StreamingSession` | WebSocket connections | Connection duration |
| `FutureCallSession` | Scheduled tasks | Task execution |
| `InternalSession` | Manual creation | Until explicitly closed |

Regular sessions batch logs and persist them upon closure. Streaming sessions write logs continuously.

## Manual Sessions

```dart
var session = await Serverpod.instance.createSession();
try {
  await operation(session);
} finally {
  await session.close();
}
```

### Cleanup Listeners

```dart
session.addWillCloseListener((session) async {
  // Cleanup resources before session closes
});
```

## Common Pitfalls

1. **Using sessions after closure** throws `StateError`
2. **Forgetting to close manual sessions** causes memory leaks and lost logs
3. **Improper error handling** prevents cleanup execution - always use try/finally
