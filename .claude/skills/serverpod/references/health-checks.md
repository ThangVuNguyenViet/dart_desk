# Serverpod Health Checks Reference

## Table of Contents
- [Built-in Probes](#built-in-probes)
- [Custom Health Indicators](#custom-health-indicators)
- [Configuration](#configuration)

## Built-in Probes

Three Kubernetes-style HTTP endpoints:

| Probe | Path | Purpose |
|-------|------|---------|
| Liveness | `/livez` | Server process is running (no dependency checks) |
| Readiness | `/readyz` | All dependencies healthy (DB, Redis) |
| Startup | `/startupz` | Initialization complete including migrations |

Returns `200 OK` or `503 Service Unavailable`. Authenticated requests get detailed JSON.

### Built-in Indicators
- `ServerpodStartupIndicator` - startup completion
- `DatabaseHealthIndicator` - database connectivity
- `RedisHealthIndicator` - Redis connectivity

## Custom Health Indicators

```dart
class StripeApiIndicator extends HealthIndicator<double> {
  @override
  String get name => 'stripe:api';

  @override
  Duration get timeout => const Duration(seconds: 3);

  @override
  Future<HealthCheckResult> check() async {
    final stopwatch = Stopwatch()..start();
    try {
      await stripeClient.ping();
      stopwatch.stop();
      return pass(observedValue: stopwatch.elapsedMilliseconds.toDouble());
    } catch (e) {
      return fail(output: 'Stripe API unavailable: $e');
    }
  }
}
```

## Configuration

Register during initialization:

```dart
final pod = Serverpod(
  args,
  Protocol(),
  Endpoints(),
  healthConfig: HealthConfig(
    cacheTtl: Duration(seconds: 2),
    additionalReadinessIndicators: [StripeApiIndicator()],
    additionalStartupIndicators: [CacheWarmupIndicator()],
  ),
);
```

Health metrics (CPU, memory, DB response time) stored minute-by-minute. Custom metrics via `HealthCheckHandler`.
