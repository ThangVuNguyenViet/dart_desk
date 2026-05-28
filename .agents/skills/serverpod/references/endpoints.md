# Serverpod Endpoints Reference

## Table of Contents
- [Basic Endpoint Structure](#basic-endpoint-structure)
- [Session Object](#session-object)
- [Parameter Rules](#parameter-rules)
- [Return Types](#return-types)
- [Error Handling](#error-handling)
- [Endpoint Inheritance](#endpoint-inheritance)
- [Abstract Endpoints](#abstract-endpoints)
- [Method Visibility](#method-visibility)
- [Size Limits](#size-limits)
- [CRUD Patterns](#crud-patterns)

## Basic Endpoint Structure

```dart
import 'package:serverpod/serverpod.dart';

class UserEndpoint extends Endpoint {
  Future<User> create(Session session, {required String name, required String email}) async {
    final user = User(name: name, email: email);
    return User.db.insertRow(session, user);
  }

  Future<User?> find(Session session, {required int id}) async {
    return User.db.findById(session, id);
  }

  Future<List<User>> listAll(Session session) async {
    return User.db.find(session);
  }
}
```

Endpoints are auto-discovered. Place in `lib/src/endpoints/`. Run `serverpod generate` after changes.

## Session Object

The `Session` object provides access to all server resources:

```dart
Future<void> example(Session session) async {
  // Database
  final users = await User.db.find(session);

  // Caching
  await session.caches.local.put('key', value);

  // Authentication
  final userId = await session.auth.authenticatedUserId;
  final isAuth = await session.isUserSignedIn;

  // Logging
  session.log('Processing request', level: LogLevel.info);

  // Message passing
  session.messages.postMessage('channel', payload);
}
```

## Parameter Rules

- First parameter must always be `Session session`
- All subsequent parameters must be **named** (use `{required Type name}` or `{Type? name}`)
- Supported parameter types: primitives, `DateTime`, `ByteData`, `UuidValue`, serializable classes, `List<T>`, `Map<String, T>`
- `Stream` parameters are supported for streaming endpoints

```dart
// Correct
Future<User> create(Session session, {required String name, String? email}) async { ... }

// Wrong - positional params after session
Future<User> create(Session session, String name) async { ... }  // Won't generate
```

## Return Types

- Must return `Future<T>` where T is a serializable type
- `void` return: `Future<void>`
- Streaming: `Stream<T>` for server-sent streams

```dart
Future<void> deleteUser(Session session, {required int id}) async {
  await User.db.deleteRow(session, await User.db.findById(session, id)!);
}

Stream<int> countStream(Session session) async* {
  for (var i = 0; i < 10; i++) {
    yield i;
    await Future.delayed(Duration(seconds: 1));
  }
}
```

## Error Handling

### SerializableException

Define typed exceptions in YAML models, then throw them:

```dart
Future<User> getUser(Session session, {required int id}) async {
  final user = await User.db.findById(session, id);
  if (user == null) {
    throw NotFoundException(message: 'User not found', resourceType: 'User');
  }
  return user;
}
```

Client-side:
```dart
try {
  final user = await client.user.getUser(id: 999);
} on NotFoundException catch (e) {
  print(e.message);
}
```

### Standard Exceptions

Unhandled exceptions return generic server errors to the client. Use `SerializableException` for typed error propagation.

## Endpoint Inheritance

Endpoints can extend other endpoints:

```dart
class BaseEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<void> logAction(Session session, {required String action}) async {
    session.log(action);
  }
}

class AdminEndpoint extends BaseEndpoint {
  @override
  Set<Scope> get requiredScopes => {Scope('admin')};

  Future<List<User>> getAllUsers(Session session) async {
    return User.db.find(session);
  }
}
```

Both `logAction` and `getAllUsers` are generated as client methods. The admin endpoint inherits `requireLogin`.

## Abstract Endpoints

Use abstract classes for shared logic without exposing methods:

```dart
abstract class CrudEndpoint<T extends TableRow> extends Endpoint {
  // Abstract methods are NOT generated as client methods
  Table<T> get table;

  // Concrete methods ARE generated
  Future<T?> find(Session session, {required int id}) async {
    return table.findById(session, id);
  }

  Future<List<T>> list(Session session) async {
    return table.find(session);
  }
}

class UserCrudEndpoint extends CrudEndpoint<User> {
  @override
  Table<User> get table => User.db;
}
```

## Method Visibility

### @doNotGenerate

Exclude specific methods from client generation:

```dart
class UserEndpoint extends Endpoint {
  Future<User> create(Session session, {required String name}) async {
    await _validate(session, name: name);
    return User.db.insertRow(session, User(name: name));
  }

  @doNotGenerate
  Future<void> _validate(Session session, {required String name}) async {
    // Internal helper - not exposed to client
  }
}
```

Private methods (starting with `_`) are automatically excluded. Use `@doNotGenerate` for public helper methods.

### Method Overriding

When overriding a parent method, the child version replaces the parent in the generated client:

```dart
class BaseEndpoint extends Endpoint {
  Future<String> greet(Session session) async => 'Hello';
}

class CustomEndpoint extends BaseEndpoint {
  @override
  Future<String> greet(Session session) async => 'Hi there!';
}
```

Use `@doNotGenerate` on parent methods to hide them while keeping child overrides:

```dart
class BaseEndpoint extends Endpoint {
  @doNotGenerate
  Future<String> greet(Session session) async => 'Hello';
}

class CustomEndpoint extends BaseEndpoint {
  @override
  Future<String> greet(Session session) async => 'Hi there!';
  // Only this version appears in client
}
```

## Size Limits

Default max request size: **512 kB**. Override per-endpoint:

```dart
class FileEndpoint extends Endpoint {
  @override
  int get maxRequestSize => 10 * 1024 * 1024; // 10 MB
}
```

## CRUD Patterns

### Standard CRUD Endpoint

```dart
class ItemEndpoint extends Endpoint {
  Future<Item> create(Session session, {required Item item}) async {
    return Item.db.insertRow(session, item);
  }

  Future<Item?> read(Session session, {required int id}) async {
    return Item.db.findById(session, id);
  }

  Future<Item> update(Session session, {required Item item}) async {
    return Item.db.updateRow(session, item);
  }

  Future<bool> delete(Session session, {required int id}) async {
    final item = await Item.db.findById(session, id);
    if (item == null) return false;
    await Item.db.deleteRow(session, item);
    return true;
  }

  Future<List<Item>> list(Session session, {int? limit, int? offset}) async {
    return Item.db.find(
      session,
      limit: limit,
      offset: offset,
      orderBy: (t) => t.id,
    );
  }
}
```
