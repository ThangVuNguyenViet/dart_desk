# Serverpod Server Events Reference

## Table of Contents
- [Overview](#overview)
- [Sending Messages](#sending-messages)
- [Receiving Messages](#receiving-messages)
- [Authentication Revocation](#authentication-revocation)

## Overview

Built-in event messaging system for message exchange within and across servers. Accessed via `session.messages`.

## Sending Messages

### Local (single server)

```dart
var message = UserUpdate();
session.messages.postMessage('user_updates', message);
```

### Global (multi-server, requires Redis)

```dart
session.messages.postMessage('user_updates', message, global: true);
```

Messages must be Serverpod models (serializable).

## Receiving Messages

### Stream approach

```dart
var stream = session.messages.createStream('user_updates');
stream.listen((message) {
  print('Received: $message');
});
```

Streams auto-close when session ends or via `subscription.cancel()`.

### Listener approach

```dart
var callback = (message) { print('Received: $message'); };

// Add
session.messages.addListener('user_updates', callback);

// Remove
session.messages.removeListener('user_updates', callback);
```

Listeners persist until session closes or manual removal.

## Authentication Revocation

```dart
session.messages.revokeAuthentication();
```

Revokes authentication tokens across the application.
