# Serverpod Real-time Communication Reference

## Table of Contents
- [Message Channels](#message-channels)
- [Streaming Endpoints](#streaming-endpoints)
- [WebSocket Connection](#websocket-connection)
- [Common Patterns](#common-patterns)
- [Connection Management](#connection-management)
- [Performance](#performance)

## Message Channels

The simplest way to send real-time data between server and clients.

### Server: Post Messages

```dart
// Post to a named channel
session.messages.postMessage(
  'chat:room_1',
  ChatMessage(text: 'Hello!', sender: 'Alice'),
);

// Post to user-specific channel
session.messages.postMessage(
  'notifications:$userId',
  Notification(title: 'New message', body: 'You have a new message'),
);
```

### Client: Listen to Channels

```dart
// Subscribe to a channel
final subscription = client.messages.listen<ChatMessage>('chat:room_1');

subscription.listen((message) {
  print('${message.sender}: ${message.text}');
});

// Cancel subscription
subscription.cancel();
```

### Server: Listen to Messages (Server-to-Server)

```dart
// Listen within server code
session.messages.addListener('internal:events', (message) {
  if (message is SystemEvent) {
    handleEvent(message);
  }
});
```

## Streaming Endpoints

Define endpoints that return `Stream<T>` for server-sent data:

### Server

```dart
class LiveEndpoint extends Endpoint {
  // Simple stream
  Stream<int> countdown(Session session, {required int from}) async* {
    for (var i = from; i >= 0; i--) {
      yield i;
      await Future.delayed(Duration(seconds: 1));
    }
  }

  // Database-backed live updates
  Stream<List<Order>> liveOrders(Session session) async* {
    while (true) {
      final orders = await Order.db.find(
        session,
        where: (t) => t.status.equals('pending'),
        orderBy: (t) => t.createdAt,
        orderDescending: true,
      );
      yield orders;
      await Future.delayed(Duration(seconds: 5));
    }
  }

  // Bidirectional: receive stream input
  Stream<ChatMessage> chat(
    Session session,
    Stream<ChatMessage> incomingMessages,
  ) async* {
    await for (final message in incomingMessages) {
      // Process and broadcast
      session.messages.postMessage('chat:global', message);
      yield ChatMessage(text: 'Received: ${message.text}', sender: 'Server');
    }
  }
}
```

### Client

```dart
// Listen to stream endpoint
final stream = client.live.countdown(from: 10);
stream.listen(
  (count) => print('$count...'),
  onDone: () => print('Done!'),
  onError: (e) => print('Error: $e'),
);

// Bidirectional streaming
final controller = StreamController<ChatMessage>();
final responses = client.live.chat(controller.stream);

responses.listen((msg) => print(msg.text));
controller.add(ChatMessage(text: 'Hello!', sender: 'User'));
```

## WebSocket Connection

Serverpod uses WebSocket connections for streaming and real-time features.

### Client Setup

```dart
// The client automatically manages WebSocket connections
final client = Client(
  'http://localhost:8080/',
  authenticationKeyManager: FlutterAuthenticationKeyManager(),
);

// Open streaming connection (required for messages and streams)
await client.openStreamingConnection();

// Check connection status
client.isStreamingConnectionOpen;

// Close when done
client.closeStreamingConnection();
```

### Connection Lifecycle

```dart
// Listen to connection status
client.streamingConnectionStatusController.stream.listen((status) {
  switch (status) {
    case StreamingConnectionStatus.connected:
      print('Connected');
      break;
    case StreamingConnectionStatus.connecting:
      print('Connecting...');
      break;
    case StreamingConnectionStatus.disconnected:
      print('Disconnected');
      break;
  }
});
```

## Common Patterns

### Live Dashboard Updates

```dart
// Server
class DashboardEndpoint extends Endpoint {
  Stream<DashboardData> liveDashboard(Session session) async* {
    while (true) {
      final stats = await computeStats(session);
      yield DashboardData(
        activeUsers: stats.activeUsers,
        totalOrders: stats.totalOrders,
        revenue: stats.revenue,
      );
      await Future.delayed(Duration(seconds: 10));
    }
  }
}

// Client
final stream = client.dashboard.liveDashboard();
stream.listen((data) {
  setState(() => dashboardData = data);
});
```

### Chat Room

```dart
// Server
class ChatEndpoint extends Endpoint {
  Future<void> sendMessage(Session session, {
    required String roomId,
    required String text,
  }) async {
    final userId = await session.auth.authenticatedUserId;
    final message = ChatMessage(
      roomId: roomId,
      senderId: userId!,
      text: text,
      timestamp: DateTime.now(),
    );

    // Persist to database
    await ChatMessage.db.insertRow(session, message);

    // Broadcast to channel
    session.messages.postMessage('chat:$roomId', message);
  }
}

// Client
await client.openStreamingConnection();
final messages = client.messages.listen<ChatMessage>('chat:room_1');
messages.listen((msg) => addToUI(msg));

// Send a message
await client.chat.sendMessage(roomId: 'room_1', text: 'Hello!');
```

### User Notifications

```dart
// Server: send notification
Future<void> notifyUser(Session session, {
  required int userId,
  required String title,
  required String body,
}) async {
  session.messages.postMessage(
    'notifications:$userId',
    AppNotification(title: title, body: body, createdAt: DateTime.now()),
  );
}

// Client: listen for own notifications
final userId = sessionManager.signedInUser!.id!;
final notifications = client.messages.listen<AppNotification>('notifications:$userId');
notifications.listen((n) => showNotification(n));
```

### Presence / Online Status

```dart
// Server
class PresenceEndpoint extends Endpoint {
  Future<void> setOnline(Session session) async {
    final userId = (await session.auth.authenticatedUserId)!;
    await session.caches.global.put(
      'presence:$userId',
      OnlineStatus(userId: userId, lastSeen: DateTime.now()),
      lifetime: Duration(seconds: 30),
    );
    session.messages.postMessage('presence', UserOnline(userId: userId));
  }
}
```

## Connection Management

### Auto-Reconnection

The Serverpod client handles reconnection automatically. Configure behavior:

```dart
final client = Client(
  'http://localhost:8080/',
  authenticationKeyManager: FlutterAuthenticationKeyManager(),
  streamingConnectionTimeout: Duration(seconds: 30),
);
```

### Graceful Shutdown

```dart
// In Flutter app dispose
@override
void dispose() {
  client.closeStreamingConnection();
  super.dispose();
}
```

## Performance

### Throttling

For high-frequency updates, throttle server-side:

```dart
Stream<SensorData> liveSensorData(Session session) async* {
  var lastEmit = DateTime.now();
  while (true) {
    final data = await readSensor();
    final now = DateTime.now();
    // Emit at most once per second
    if (now.difference(lastEmit) >= Duration(seconds: 1)) {
      yield data;
      lastEmit = now;
    }
    await Future.delayed(Duration(milliseconds: 100));
  }
}
```

### Batching

Batch multiple updates into single messages:

```dart
Stream<List<StockPrice>> liveStockPrices(Session session) async* {
  while (true) {
    // Fetch all at once instead of individual streams
    final prices = await StockPrice.db.find(
      session,
      where: (t) => t.symbol.inSet(watchlist),
    );
    yield prices;
    await Future.delayed(Duration(seconds: 2));
  }
}
```

### Channel Naming

Use structured, predictable channel names:
- `chat:<room_id>` - Chat rooms
- `notifications:<user_id>` - User notifications
- `presence` - Global presence updates
- `updates:<entity>:<id>` - Entity-specific updates
