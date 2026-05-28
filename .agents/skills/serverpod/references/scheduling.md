# Serverpod Scheduling / Future Calls Reference

## Table of Contents
- [Overview](#overview)
- [Creating Future Calls](#creating-future-calls)
- [Scheduling](#scheduling)
- [Cancellation](#cancellation)

## Overview

Future calls schedule work for later execution. They persist in the database and survive server restarts. Execution is guaranteed only once across all running instances. Handle failures by scheduling new calls. **Not available in serverless mode.**

## Creating Future Calls

Extend `FutureCall` and define methods:

```dart
import 'package:serverpod/serverpod.dart';

class ExampleFutureCall extends FutureCall {
  Future<void> doWork(Session session) async {
    // Do something interesting in the future
  }

  Future<void> doOtherWork(Session session, String data) async {
    // Methods can accept serializable parameters
  }
}
```

**Method requirements:**
- Must return `Future<void>`
- First positional parameter must be `Session`
- Can accept serializable types: `List`, `Map`, `Set`, Dart records
- Cannot use `Stream` parameters

After creating, run `serverpod generate` to create `generated/future_calls.dart`.

## Scheduling

### Schedule with delay

```dart
await pod.futureCalls
    .callWithDelay(const Duration(hours: 1))
    .example
    .doWork();
```

### Schedule at specific time

```dart
await pod.futureCalls
    .callAtTime(DateTime(2026, 1, 1))
    .example
    .doOtherWork('some-data');
```

## Cancellation

Assign identifiers when scheduling:

```dart
await pod.futureCalls
    .callWithDelay(
      const Duration(hours: 1),
      identifier: 'an-identifying-string',
    )
    .example
    .doWork();
```

Cancel by identifier:

```dart
await pod.futureCalls.cancel('an-identifying-string');
```
