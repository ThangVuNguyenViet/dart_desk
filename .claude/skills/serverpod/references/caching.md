# Serverpod Caching Reference

## Table of Contents
- [Cache Types](#cache-types)
- [Basic Operations](#basic-operations)
- [TTL (Time to Live)](#ttl-time-to-live)
- [Cache Groups](#cache-groups)
- [Cache Patterns](#cache-patterns)
- [Redis Configuration](#redis-configuration)
- [Performance Tips](#performance-tips)

## Cache Types

Serverpod provides two cache layers:

| Cache | Storage | Scope | Use Case |
|-------|---------|-------|----------|
| `session.caches.local` | In-memory | Single server | Frequently accessed data, low latency |
| `session.caches.global` | Redis | All servers | Shared state, distributed systems |
| `session.caches.localAndGlobal` | Both | Both | Operations on both caches simultaneously |

## Basic Operations

### Put (Store)

```dart
// Local cache
await session.caches.local.put('user:42', userObject);

// Global (Redis) cache
await session.caches.global.put('config:theme', themeConfig);

// Both caches
await session.caches.localAndGlobal.put('settings', settings);
```

### Get (Retrieve)

```dart
// Returns null if not found or expired
final user = await session.caches.local.get<User>('user:42');
final config = await session.caches.global.get<ThemeConfig>('config:theme');
```

### Invalidate (Remove)

```dart
// Remove specific key
await session.caches.local.invalidateKey('user:42');

// Remove from both caches
await session.caches.localAndGlobal.invalidateKey('user:42');
```

## TTL (Time to Live)

```dart
// Cache with expiration
await session.caches.local.put(
  'token:abc',
  tokenData,
  lifetime: Duration(minutes: 15),
);

await session.caches.global.put(
  'rate_limit:user:42',
  counter,
  lifetime: Duration(hours: 1),
);
```

Without `lifetime`, entries persist until manually invalidated or server restart (local) / Redis eviction (global).

## Cache Groups

Group related cache entries for bulk invalidation:

```dart
// Store with group
await session.caches.local.put(
  'user:42:profile',
  profile,
  group: 'user:42',
);

await session.caches.local.put(
  'user:42:settings',
  settings,
  group: 'user:42',
);

await session.caches.local.put(
  'user:42:permissions',
  permissions,
  group: 'user:42',
);

// Invalidate entire group (removes all three entries)
await session.caches.local.invalidateGroup('user:42');
```

## Cache Patterns

### Cache-Aside (Lazy Loading)

Most common pattern. Check cache first, load from DB on miss:

```dart
Future<User> getUser(Session session, {required int id}) async {
  final cacheKey = 'user:$id';

  // Try cache first
  var user = await session.caches.local.get<User>(cacheKey);
  if (user != null) return user;

  // Cache miss - load from database
  user = await User.db.findById(session, id);
  if (user == null) throw NotFoundException(message: 'User not found');

  // Store in cache
  await session.caches.local.put(cacheKey, user, lifetime: Duration(minutes: 10));

  return user;
}
```

### Write-Through

Update cache and database together:

```dart
Future<User> updateUser(Session session, {required User user}) async {
  // Update database
  final updated = await User.db.updateRow(session, user);

  // Update cache
  await session.caches.localAndGlobal.put(
    'user:${updated.id}',
    updated,
    lifetime: Duration(minutes: 10),
    group: 'user:${updated.id}',
  );

  return updated;
}
```

### Cache Invalidation on Write

Simpler alternative to write-through:

```dart
Future<User> updateUser(Session session, {required User user}) async {
  final updated = await User.db.updateRow(session, user);

  // Just invalidate - next read will repopulate
  await session.caches.localAndGlobal.invalidateGroup('user:${updated.id}');

  return updated;
}
```

### Read-Through with Fallback

```dart
Future<AppConfig> getConfig(Session session) async {
  final key = 'app:config';

  var config = await session.caches.global.get<AppConfig>(key);
  if (config != null) return config;

  // Load from database or external source
  config = await loadConfigFromDatabase(session);

  // Cache for longer since config changes rarely
  await session.caches.global.put(key, config, lifetime: Duration(hours: 1));

  return config;
}
```

## Redis Configuration

### Server Config

```yaml
# config/development.yaml
redis:
  enabled: true
  host: localhost
  port: 6379

# config/production.yaml
redis:
  enabled: true
  host: redis.internal
  port: 6379
```

### Passwords

```yaml
# config/passwords.yaml
redis: 'your_redis_password'  # Empty string for no password
```

## Performance Tips

- **Use local cache** for hot data that doesn't need cross-server consistency
- **Use global cache** for shared state in multi-server deployments
- **Set appropriate TTLs** - shorter for volatile data, longer for stable data
- **Use cache groups** to simplify invalidation of related entries
- **Cache serialized objects** - Serverpod handles serialization automatically
- **Avoid caching large objects** - Keep cache entries small for memory efficiency
- **Key naming convention** - Use structured keys like `entity:id:aspect` (e.g., `user:42:profile`)
