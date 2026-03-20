# Serverpod Configuration Reference

## Table of Contents
- [Precedence](#precedence)
- [Server Settings](#server-settings)
- [Database & Redis](#database--redis)
- [Session & Logging](#session--logging)
- [Secrets (passwords.yaml)](#secrets-passwordsyaml)
- [Generator Config](#generator-config-generatoryaml)

## Precedence

Dart config objects > Environment variables > YAML config files

YAML configs in `config/` directory named by run mode: `development.yaml`, `staging.yaml`, `production.yaml`, `test.yaml`.

## Server Settings

| Env Variable | YAML Option | Default |
|---|---|---|
| `SERVERPOD_RUN_MODE` | N/A | development |
| `SERVERPOD_SERVER_ID` | serverId | default |
| `SERVERPOD_SERVER_ROLE` | role | monolith |
| `SERVERPOD_LOGGING_MODE` | logging | normal |
| `SERVERPOD_APPLY_MIGRATIONS` | applyMigrations | false |
| `SERVERPOD_API_SERVER_PORT` | apiServer.port | 8080 |
| `SERVERPOD_API_SERVER_PUBLIC_HOST` | apiServer.publicHost | localhost |
| `SERVERPOD_API_SERVER_PUBLIC_PORT` | apiServer.publicPort | 8080 |
| `SERVERPOD_API_SERVER_PUBLIC_SCHEME` | apiServer.publicScheme | http |
| `SERVERPOD_MAX_REQUEST_SIZE` | maxRequestSize | 524288 |
| `SERVERPOD_WEBSOCKET_PING_INTERVAL` | websocketPingInterval | 30 |

Insights server and web server have analogous options with `SERVERPOD_INSIGHTS_SERVER_*` and `SERVERPOD_WEB_SERVER_*` prefixes.

Server roles: `monolith` (default), `serverless`, `maintenance`

## Database & Redis

```yaml
database:
  host: localhost
  port: 5432
  name: my_project
  user: postgres
  requireSsl: false
  isUnixSocket: false
  maxConnectionCount: 10   # or SERVERPOD_DATABASE_MAX_CONNECTION_COUNT
  searchPaths: [public]

redis:
  enabled: true
  host: localhost
  port: 6379
  user: default
  requireSsl: false
```

## Session & Logging

| Variable | YAML | Default |
|---|---|---|
| `SERVERPOD_SESSION_PERSISTENT_LOG_ENABLED` | sessionLogs.persistentEnabled | conditional |
| `SERVERPOD_SESSION_CONSOLE_LOG_ENABLED` | sessionLogs.consoleEnabled | conditional |
| `SERVERPOD_SESSION_CONSOLE_LOG_FORMAT` | sessionLogs.consoleFormat | text |
| `SERVERPOD_SESSION_LOG_CLEANUP_INTERVAL` | sessionLogs.cleanupInterval | 24h |
| `SERVERPOD_SESSION_LOG_RETENTION_PERIOD` | sessionLogs.retentionPeriod | 90d |
| `SERVERPOD_SESSION_LOG_RETENTION_COUNT` | sessionLogs.retentionCount | 100000 |

## Secrets (passwords.yaml)

```yaml
shared:
  database: 'db_password'
  redis: 'redis_password'
  serviceSecret: 'token_minimum_20_chars'   # For multi-server auth

development:
  # Run-mode specific overrides

production:
  database: 'prod_db_password'
```

### Custom Secrets

Via YAML:
```yaml
shared:
  stripeApiKey: 'sk_test_123...'
```

Via env: `SERVERPOD_PASSWORD_stripeApiKey=sk_test_123...`

Access: `session.passwords['stripeApiKey']`

### Cloud Storage Secrets

- GCP: `HMACAccessKeyId`, `HMACSecretKey`, `gcpServiceAccount`
- AWS: `AWSAccessKeyId`, `AWSSecretKey`
- R2: `R2AccessKeyId`, `R2SecretKey`

## Generator Config (generator.yaml)

```yaml
type: server                          # server, module, or internal
serverPackage: my_project_server
clientPackage: my_project_client
client_package_path: ../my_project_client
server_test_tools_path: test/integration/test_tools

# Shared model packages
shared_packages:
  - package: my_project_shared
    path: ../my_project_shared

# Module dependencies
modules:
  serverpod_auth_idp:
    nickname: auth

# Custom serializable classes
extraClasses:
  - package:my_shared/my_shared.dart:MyClass

# Feature flags
features:
  database: true

# Experimental features
experimental_features:
  - inheritance
```
