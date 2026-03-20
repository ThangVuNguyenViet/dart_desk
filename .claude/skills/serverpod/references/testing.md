# Serverpod Testing Reference

## Table of Contents
- [Setup](#setup)
- [Basic Tests](#basic-tests)
- [Authentication in Tests](#authentication-in-tests)
- [Database Seeding](#database-seeding)
- [Configuration Options](#configuration-options)
- [Rollback Options](#rollback-options)
- [Test Exceptions](#test-exceptions)
- [Advanced Examples](#advanced-examples)
- [Best Practices](#best-practices)

## Setup

### 1. generator.yaml

```yaml
server_test_tools_path: test/integration/test_tools
```

### 2. Docker Compose - add test services

```yaml
postgres_test:
  image: postgres:16.3
  ports:
    - '9090:5432'
  environment:
    POSTGRES_USER: postgres
    POSTGRES_DB: <projectname>_test
    POSTGRES_PASSWORD: "<test_db_password>"
  volumes:
    - <projectname>_test_data:/var/lib/postgresql/data

redis_test:
  image: redis:6.2.6
  ports:
    - '9091:6379'
  command: redis-server --requirepass '<test_redis_password>'
  environment:
    - REDIS_REPLICATION_MODE=master

volumes:
  <projectname>_test_data:
```

### 3. config/test.yaml

```yaml
apiServer:
  port: 0
  publicHost: localhost
  publicPort: 0
  publicScheme: http
insightsServer:
  port: 0
  publicHost: localhost
  publicPort: 0
  publicScheme: http
webServer:
  port: 0
  publicHost: localhost
  publicPort: 0
  publicScheme: http
database:
  host: localhost
  port: 9090
  name: <projectname>_test
  user: postgres
redis:
  enabled: false
  host: localhost
  port: 9091
```

### 4. config/passwords.yaml

```yaml
test:
  database: '<test_db_password>'
  redis: '<test_redis_password>'
```

### 5. dart_test.yaml

```yaml
tags:
  integration: {}
```

### 6. pubspec.yaml

```yaml
dev_dependencies:
  serverpod_test: <serverpod version>
  test: ^1.24.2
```

### 7. Generate test tools

```bash
serverpod generate
```

Generates `test/integration/test_tools/serverpod_test_tools.dart`.

## Basic Tests

```dart
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Example endpoint', (sessionBuilder, endpoints) {
    test('when calling hello then should return greeting', () async {
      final greeting = await endpoints.example.hello(sessionBuilder, 'Michael');
      expect(greeting, 'Hello Michael');
    });
  });
}
```

Run: `docker compose up --build --detach && dart test`

## Authentication in Tests

```dart
withServerpod('Given AuthenticatedExample endpoint', (sessionBuilder, endpoints) {
  final userId = '550e8400-e29b-41d4-a716-446655440000';

  group('when authenticated', () {
    var authSession = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        userId,
        {Scope('user')},
      ),
    );

    test('then should return greeting', () async {
      final greeting = await endpoints.authenticatedExample.hello(authSession, 'Michael');
      expect(greeting, 'Hello, Michael!');
    });
  });

  group('when unauthenticated', () {
    var unauthSession = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.unauthenticated(),
    );

    test('then should throw exception', () async {
      final future = endpoints.authenticatedExample.hello(unauthSession, 'Michael');
      await expectLater(future, throwsA(isA<ServerpodUnauthenticatedException>()));
    });
  });
});
```

## Database Seeding

By default, operations execute within transactions that rollback after each test:

```dart
withServerpod('Given Products endpoint', (sessionBuilder, endpoints) {
  var session = sessionBuilder.build();

  setUp(() async {
    await Product.db.insert(session, [
      Product(name: 'Apple', price: 10),
      Product(name: 'Banana', price: 10),
    ]);
  });

  test('then calling all should return all products', () async {
    final products = await endpoints.products.all(sessionBuilder);
    expect(products, hasLength(2));
  });
});
```

## Configuration Options

| Property | Purpose | Default |
|----------|---------|---------|
| `applyMigrations` | Apply pending migrations | `true` |
| `enableSessionLogging` | Enable session logs | `false` |
| `rollbackDatabase` | When to rollback changes | `afterEach` |
| `runMode` | Serverpod execution mode | `test` |
| `serverpodLoggingMode` | Logging verbosity | `normal` |
| `serverpodStartTimeout` | Connection timeout | `30 seconds` |
| `testGroupTagsOverride` | Custom test tags | `['integration']` |

```dart
withServerpod(
  'Given Products endpoint',
  (sessionBuilder, endpoints) { /* tests */ },
  runMode: ServerpodRunMode.development,
  rollbackDatabase: RollbackDatabase.disabled,
);
```

## Rollback Options

```dart
enum RollbackDatabase {
  afterEach,   // Default: rollback after each test
  afterAll,    // Rollback after all tests in group
  disabled,    // No automatic rollback (manual cleanup needed)
}
```

Use `disabled` when endpoints have concurrent `session.db.transaction` calls:

```dart
withServerpod(
  'Given ProductsEndpoint',
  (sessionBuilder, endpoints) {
    tearDownAll(() async {
      var session = sessionBuilder.build();
      await Product.db.deleteWhere(session, where: (_) => Constant.bool(true));
    });

    test('concurrent transactions', () async {
      await endpoints.products.concurrentTransactionCalls(sessionBuilder);
    });
  },
  rollbackDatabase: RollbackDatabase.disabled,
);
```

Run concurrent tests: `dart test -t integration --concurrency=1`

## Test Exceptions

- `ServerpodUnauthenticatedException` - Auth check failed
- `ServerpodInsufficientAccessException` - Missing required scopes
- `ConnectionClosedException` - Stream connection error
- `InvalidConfigurationException` - Invalid test configuration

### flushEventQueue helper

Wait for async events (useful with generators):

```dart
var stream = endpoints.someEndpoint.generatorFunction(session);
await flushEventQueue();
```

## Advanced Examples

### Run unit and integration tests separately

```bash
dart test                    # All tests (unit + integration)
dart test -t integration     # Only integration tests
dart test -x integration     # Only unit tests
```

The tag name can be customized via `testGroupTagsOverride`.

### Testing session-dependent business logic

Use `withServerpod` while ignoring the `endpoints` argument when testing business logic modules that depend on `Session`:

```dart
withServerpod('Given decreasing product quantity when quantity is zero', (
  sessionBuilder,
  _, // ignore endpoints — testing business logic directly
) {
  var session = sessionBuilder.build();

  setUp(() async {
    await Product.db.insertRow(session, [
      Product(id: 123, name: 'Apple', quantity: 0),
    ]);
  });

  test('then should throw InvalidOperationException', () async {
    var future = ProductsBusinessLogic.updateQuantity(
      session,
      id: 123,
      decrease: 1,
    );
    await expectLater(future, throwsA(isA<InvalidOperationException>()));
  });
});
```

### Multi-user stream testing

Create separate sessions with different authentication contexts:

```dart
var userSession1 = sessionBuilder.copyWith(
  authentication: AuthenticationOverride.authenticationInfo(userId1, {}),
);
var userSession2 = sessionBuilder.copyWith(
  authentication: AuthenticationOverride.authenticationInfo(userId2, {}),
);
```

Use `flushEventQueue()` to ensure streams execute to their first `yield` before continuing:

```dart
var stream = endpoints.example.listenForNumbersOnSharedStream(userSession1);
await flushEventQueue(); // ensures the listener is ready
await endpoints.example.postNumberToSharedStream(userSession2, 42);
```

### Database connection optimization

Concurrent tests may exceed database connection limits. Defer `sessionBuilder.build()` to `setUp`/`setUpAll` instead of top-level scope:

```dart
withServerpod('Given Products', (sessionBuilder, endpoints) {
  late Session session;

  setUp(() {
    session = sessionBuilder.build(); // deferred — not top-level
  });

  test('test 1', () async { /* use session */ });
  test('test 2', () async { /* use session */ });
});
```

## Best Practices

### Imports
Import only the generated test tools file, not `serverpod_test` directly:

```dart
// ✅ Good
import 'test_tools/serverpod_test_tools.dart';

// ❌ Bad — redundant, creates clutter
import 'package:serverpod_test/serverpod_test.dart';
import 'test_tools/serverpod_test_tools.dart';
```

### Database cleanup
Omit manual database cleanup — `withServerpod` wraps operations in a transaction that automatically rolls back after each test by default.

### Calling endpoints
Always use the provided `endpoints` parameter rather than instantiating endpoint classes directly. Direct instantiation bypasses lifecycle events and validation.

```dart
// ✅ Good
await endpoints.example.hello(sessionBuilder, 'name');

// ❌ Bad — bypasses test framework
await ExampleEndpoint().hello(session, 'name');
```

### Test organization
Separate unit and integration tests:

```
test/
├── unit/           # Pure unit tests (no withServerpod)
└── integration/    # Tests using withServerpod
    └── test_tools/ # Generated test tools
```
