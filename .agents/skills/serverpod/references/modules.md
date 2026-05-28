# Serverpod Modules Reference

## Table of Contents
- [Overview](#overview)
- [Adding Modules](#adding-modules)
- [Referencing Module Objects](#referencing-module-objects)
- [Creating Custom Modules](#creating-custom-modules)

## Overview

A Serverpod module is like a Dart package but contains server, client, and Flutter code. Modules have their own namespace to prevent naming conflicts. Official modules include `serverpod_auth_core` and `serverpod_auth_idp`.

## Adding Modules

### Server

```yaml
# pubspec.yaml
dependencies:
  serverpod_auth_idp_server: ^3.x.x
```

Optional nickname in `config/generator.yaml`:

```yaml
modules:
  serverpod_auth_idp:
    nickname: auth
```

Then:

```bash
dart pub get
serverpod generate
serverpod create-migration
dart bin/main.dart --apply-migrations
```

### Client

```yaml
dependencies:
  serverpod_auth_idp_client: ^3.x.x
```

### Flutter

```yaml
dependencies:
  serverpod_auth_idp_flutter: ^3.x.x
```

## Referencing Module Objects

Use module prefix in YAML model files:

```yaml
class: MyClass
fields:
  userInfo: module:serverpod_auth_idp:AuthUser
  # Or with nickname
  userInfo: module:auth:AuthUser
```

## Creating Custom Modules

```bash
serverpod create --template module my_module
```

Creates server and client packages. For Flutter:

```bash
flutter create --template package my_module_flutter
```

Prefix database table names with your module name to avoid conflicts.
