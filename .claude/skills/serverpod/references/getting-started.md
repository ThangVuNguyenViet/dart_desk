# Getting Started with Serverpod

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Creating a Project](#creating-a-project)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Configuration](#configuration)

## Prerequisites

- Flutter SDK installed
- Docker (for PostgreSQL and Redis in development)
- Dart SDK (comes with Flutter)

## Installation

```bash
dart pub global activate serverpod_cli
```

Verify: `serverpod version`

## Creating a Project

```bash
serverpod create my_project
cd my_project
```

This creates a Dart pub workspace with three packages:
- `my_project_server` - Backend server
- `my_project_client` - Auto-generated client library
- `my_project_flutter` - Pre-configured Flutter app

## Project Structure

```
my_project/
├── pubspec.yaml              # Workspace root
├── my_project_server/
│   ├── lib/
│   │   └── src/
│   │       ├── endpoints/    # API endpoint classes
│   │       │   └── example_endpoint.dart
│   │       └── models/       # YAML model definitions
│   │           └── example.yaml
│   ├── bin/
│   │   └── main.dart         # Server entry point
│   ├── config/
│   │   ├── development.yaml  # Dev config
│   │   ├── staging.yaml      # Staging config
│   │   ├── production.yaml   # Production config
│   │   ├── passwords.yaml    # Database/Redis passwords
│   │   └── generator.yaml    # Code generation config
│   ├── migrations/           # Database migration files
│   ├── test/                 # Server tests
│   └── docker-compose.yaml   # PostgreSQL + Redis
├── my_project_client/
│   └── lib/
│       └── src/
│           └── protocol/     # Auto-generated client code
└── my_project_flutter/
    └── lib/
        └── main.dart         # Flutter app entry point
```

## Development Workflow

```bash
# 1. Start Docker services (PostgreSQL + Redis)
cd my_project_server
docker compose up --build --detach

# 2. After creating/modifying models or endpoints
serverpod generate

# 3. After model changes that affect database schema
serverpod create-migration

# 4. Start the server
dart run bin/main.dart

# 5. Run the Flutter app (from my_project_flutter)
flutter run
```

### Code Generation

Run `serverpod generate` whenever you:
- Add, modify, or delete a model YAML file
- Add, modify, or delete an endpoint class
- Change method signatures in endpoints

The generator updates:
- `my_project_client/lib/src/protocol/` - Client-side protocol
- `my_project_server/lib/src/generated/` - Server-side generated code

### Migrations

Run `serverpod create-migration` whenever you:
- Add a `table` field to a model
- Change fields in a database-backed model
- Add or modify indexes

Migrations are stored in `migrations/` and applied automatically on server start.

To repair migrations after conflicts:
```bash
serverpod create-migration --repair
```

## Configuration

### Server Config (`config/development.yaml`)

```yaml
apiServer:
  port: 8080
  publicHost: localhost
  publicPort: 8080
  publicScheme: http

insightsServer:
  port: 8081
  publicHost: localhost
  publicPort: 8081
  publicScheme: http

webServer:
  port: 8082
  publicHost: localhost
  publicPort: 8082
  publicScheme: http

database:
  host: localhost
  port: 5432
  name: my_project
  user: postgres

redis:
  enabled: true
  host: localhost
  port: 6379
```

### Passwords (`config/passwords.yaml`)

```yaml
database: '<your_password>'
redis: ''
```

> This file should not be committed to version control in production.

### Generator Config (`config/generator.yaml`)

```yaml
type: server
serverPackage: my_project_server
clientPackage: my_project_client
clientPackagePath: ../my_project_client
```
