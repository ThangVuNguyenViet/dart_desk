# Serverpod Exceptions Reference

## Table of Contents
- [Default Behavior](#default-behavior)
- [Serializable Exceptions](#serializable-exceptions)
- [Default Values](#default-values)

## Default Behavior

Uncaught exceptions in endpoints:
- Logged with stack trace in `serverpod_session_log` table (NOT `serverpod_log`)
- Return 500 HTTP status to client
- Client receives generic `ServerpodException` with session ID only

## Serializable Exceptions

Define in YAML (like models but with `exception:` keyword):

```yaml
# not_found_exception.spy.yaml
exception: NotFoundException
fields:
  message: String
  resourceType: String
```

Throw from endpoints:

```dart
class ExampleEndpoint extends Endpoint {
  Future<void> doThingy(Session session) async {
    if (failure) {
      throw NotFoundException(
        message: 'User not found',
        resourceType: 'User',
      );
    }
  }
}
```

Catch on client:

```dart
try {
  await client.example.doThingy();
} on NotFoundException catch (e) {
  print('${e.resourceType}: ${e.message}');
} catch (e) {
  print('Something else went wrong.');
}
```

## Default Values

```yaml
exception: MyException
fields:
  message: String, default="An error occurred"
  errorCode: int, default=1001
```

Supports `default` and `defaultModel`. Does NOT support `defaultPersist` (exceptions are not database-persisted).
