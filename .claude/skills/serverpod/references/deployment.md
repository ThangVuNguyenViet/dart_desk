# Serverpod Deployment Reference

## Table of Contents
- [Server Requirements](#server-requirements)
- [Port Configuration](#port-configuration)
- [Deployment Methods](#deployment-methods)
- [Docker Deployment](#docker-deployment)
- [Nginx Reverse Proxy](#nginx-reverse-proxy)
- [Monitoring](#monitoring)
- [Scaling](#scaling)

## Server Requirements

- Dart SDK (matching project version)
- PostgreSQL 14+
- Redis 6+ (if caching/messaging enabled)
- Minimum 1 GB RAM for small deployments

## Port Configuration

Serverpod runs three servers by default:

| Server | Default Port | Purpose |
|--------|-------------|---------|
| API Server | 8080 | Client API calls |
| Insights Server | 8081 | Serverpod Insights app, monitoring |
| Web Server | 8082 | Web requests, OAuth callbacks |

Configure in `config/production.yaml`:

```yaml
apiServer:
  port: 8080
  publicHost: api.example.com
  publicPort: 443
  publicScheme: https

insightsServer:
  port: 8081
  publicHost: insights.example.com
  publicPort: 443
  publicScheme: https

webServer:
  port: 8082
  publicHost: web.example.com
  publicPort: 443
  publicScheme: https

database:
  host: db.internal
  port: 5432
  name: my_project
  user: my_project_user
  requireSsl: true

redis:
  enabled: true
  host: redis.internal
  port: 6379
```

### Passwords (Production)

```yaml
# config/passwords.yaml
database: 'strong_db_password'
redis: 'strong_redis_password'
serviceSecret: 'shared_secret_for_multi_server'
```

> Use environment variables or secrets management in production.

## Deployment Methods

### 1. Serverpod Cloud (Recommended)

Zero-config deployment (coming soon):
```bash
serverpod deploy
```

### 2. Docker Deployment

Build and deploy with Docker:

```dockerfile
# Dockerfile
FROM dart:stable AS build
WORKDIR /app
COPY . .
RUN dart pub get
RUN dart compile exe bin/main.dart -o bin/server

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/bin/server /app/bin/server
COPY --from=build /app/config/ /app/config/
COPY --from=build /app/migrations/ /app/migrations/
COPY --from=build /app/web/ /app/web/
WORKDIR /app
EXPOSE 8080 8081 8082
CMD ["bin/server", "--mode", "production"]
```

### 3. Docker Compose (Full Stack)

```yaml
# docker-compose.production.yaml
version: '3.8'
services:
  server:
    build: .
    ports:
      - "8080:8080"
      - "8081:8081"
      - "8082:8082"
    depends_on:
      - postgres
      - redis
    environment:
      - SERVERPOD_MODE=production

  postgres:
    image: postgres:16
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: my_project
      POSTGRES_USER: my_project_user
      POSTGRES_PASSWORD: strong_password

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass strong_redis_password
    volumes:
      - redisdata:/data

volumes:
  pgdata:
  redisdata:
```

### 4. Manual Deployment

```bash
# On server
git clone <repo> && cd my_project_server
dart pub get
dart compile exe bin/main.dart -o bin/server
bin/server --mode production
```

### 5. Terraform (AWS/GCP)

Serverpod provides Terraform scripts for cloud providers:
```bash
# AWS
cd deploy/aws/terraform
terraform init
terraform apply

# GCP
cd deploy/gcp/terraform
terraform init
terraform apply
```

## Docker Deployment

### Build

```bash
cd my_project_server
docker build -t my-project-server .
```

### Run

```bash
docker run -d \
  --name my-project \
  -p 8080:8080 -p 8081:8081 -p 8082:8082 \
  -e SERVERPOD_MODE=production \
  my-project-server
```

### Server Mode Flag

```bash
# Development (default)
dart run bin/main.dart

# Production
dart run bin/main.dart --mode production
# or
bin/server --mode production

# Staging
bin/server --mode staging
```

The `--mode` flag selects the corresponding config file (e.g., `config/production.yaml`).

## Nginx Reverse Proxy

```nginx
# /etc/nginx/sites-available/my-project
server {
    listen 443 ssl;
    server_name api.example.com;

    ssl_certificate /etc/letsencrypt/live/api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;

    # API Server
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support (required for streaming)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}

server {
    listen 443 ssl;
    server_name insights.example.com;

    ssl_certificate /etc/letsencrypt/live/insights.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/insights.example.com/privkey.pem;

    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 443 ssl;
    server_name web.example.com;

    ssl_certificate /etc/letsencrypt/live/web.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/web.example.com/privkey.pem;

    location / {
        proxy_pass http://localhost:8082;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Key nginx settings for Serverpod:
- WebSocket upgrade headers for streaming endpoints
- Long `proxy_read_timeout` for persistent connections
- SSL termination at nginx level

## Monitoring

### Serverpod Insights

Desktop companion app for monitoring:
- Real-time server logs
- Database query performance
- Active sessions and connections
- Error tracking

Connect via the Insights Server port (default 8081).

### Health Checks

```dart
// Custom health endpoint
class HealthEndpoint extends Endpoint {
  Future<Map<String, dynamic>> check(Session session) async {
    final dbOk = await checkDatabase(session);
    final redisOk = await checkRedis(session);
    return {
      'status': (dbOk && redisOk) ? 'healthy' : 'degraded',
      'database': dbOk ? 'ok' : 'error',
      'redis': redisOk ? 'ok' : 'error',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
```

### Logging

```dart
// In endpoints
session.log('Processing order', level: LogLevel.info);
session.log('Payment failed', level: LogLevel.error);
session.log('Debug data: $data', level: LogLevel.debug);
```

## Scaling

### Horizontal Scaling

Serverpod supports multi-server deployments:

1. **Shared Database**: All servers connect to same PostgreSQL
2. **Shared Redis**: Required for cross-server caching and messaging
3. **Service Secret**: Configure `serviceSecret` in passwords.yaml for server-to-server auth

```yaml
# Each server instance uses same config but different serviceSecret
serviceSecret: 'shared_secret_across_all_instances'
```

### Load Balancing

Place a load balancer in front of multiple server instances:
- Use sticky sessions or WebSocket-aware balancing for streaming
- Health check endpoint at `/health` (or custom)
- All instances must share PostgreSQL and Redis

### Database Scaling

- **Read replicas**: Configure separate read-only connections
- **Connection pooling**: Use PgBouncer or similar
- **Indexing**: Add indexes for frequently queried fields (see [database.md](database.md#index-types))

### Caching Strategy for Scale

- Use `session.caches.global` (Redis) for shared state
- Use `session.caches.local` for server-specific hot data
- Invalidate via `session.caches.localAndGlobal` to ensure consistency
