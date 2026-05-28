# Serverpod Web Server Reference (Relic)

## Table of Contents
- [Routes](#routes)
- [Response Types](#response-types)
- [Middleware](#middleware)
- [Static Files](#static-files)

## Routes

Built on the Relic framework. Routes extend `Route` and implement `handleCall()`:

```dart
class HelloRoute extends Route {
  @override
  Future<Result> handleCall(Session session, Request request) async {
    return Response.ok(body: Body.fromString('Hello'));
  }
}
```

Register in `server.dart`:

```dart
pod.webServer.addRoute(HelloRoute(), '/api/hello');
```

## Response Types

### Success
```dart
Response.ok(body: Body.fromString('OK'))
Response.created(body: Body.fromString('Created'))
Response.noContent()
```

### Error
```dart
Response.badRequest(body: Body.fromString('Bad request'))
Response.unauthorized(body: Body.fromString('Unauthorized'))
Response.notFound(body: Body.fromString('Not found'))
Response.internalServerError(body: Body.fromString('Error'))
```

## Middleware

```dart
// Add middleware
pod.webServer.addMiddleware(myMiddleware, '/path');

// Host-specific middleware
pod.webServer.addMiddleware(apiKeyMiddleware, '/api', host: 'api.example.com');
```

Execution order: based on path hierarchy, more specific paths take precedence. Same-path middleware runs in registration order.

### ContextProperty (Request-Scoped Data)

```dart
// Define a context property
final tenantId = ContextProperty<String>();

// Set in middleware
Middleware tenantMiddleware(Handler innerHandler) {
  return (session, request) async {
    tenantId.set(request, extractTenantId(request));
    return innerHandler(session, request);
  };
}

// Read in route handler
class MyRoute extends Route {
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final id = tenantId.get(request);
    return Response.ok(body: Body.fromString('Tenant: $id'));
  }
}
```

Automatically cleaned up after request completion.

## Routing

### HTTP Methods

```dart
class UserRoute extends Route {
  UserRoute() : super(methods: {Method.get, Method.post, Method.delete});
}
```

### Path Parameters

```dart
pod.webServer.addRoute(UserRoute(), '/api/users/:id');
// Matches: /api/users/123

pod.webServer.addRoute(route, '/:userId/posts/:postId');
```

Access via `request.remainingPath` or `request.url.queryParameters['query']`.

Typed params: `IntPathParam(#id)`, then `request.pathParameters.get(param)`.

### Wildcards

```dart
pod.webServer.addRoute(route, '/item/*');    // Single-level
pod.webServer.addRoute(route, '/item/**');   // Tail-match (recursive)
```

### Fallback Routes

```dart
pod.webServer.fallbackRoute = NotFoundRoute();
```

### Route Modules

Group related endpoints with `injectIn()`:

```dart
class UserCrudModule extends Route {
  @override
  void injectIn(RelicRouter router) {
    router
      ..get('/', _list)
      ..get('/:id', _get);
  }
}

pod.webServer.addRoute(UserCrudModule(), '/api/users');
```

### Virtual Host Routing

```dart
pod.webServer.addRoute(ApiRoute(), '/v1');  // host set in Route constructor
pod.webServer.addRoute(
  SpaRoute(webDir, fallback: index, host: 'www.example.com'),
  '/',
);
```

## Static Files

```dart
pod.webServer.addRoute(StaticRoute.directory('/public'), '/static');
```

### SPA (Single Page Apps)

```dart
pod.webServer.addRoute(SpaRoute(webDir, fallback: indexHtml), '/');
```

### Flutter Web

```dart
pod.webServer.addRoute(FlutterRoute(webDir), '/');
// Auto-adds WASM multi-threading headers
```
