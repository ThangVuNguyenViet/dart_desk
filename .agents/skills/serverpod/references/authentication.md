# Serverpod Authentication Reference (IDP System - 3.x)

## Table of Contents
- [Setup](#setup)
- [Google Sign-In](#google-sign-in)
- [Endpoint Auth](#endpoint-auth)
- [Token Managers](#token-managers)
- [User Management](#user-management)
- [Custom UI](#custom-ui)
- [Custom Auth](#custom-auth)
- [Legacy System](#legacy-system)

## Setup

### Server Dependencies

```yaml
# my_project_server/pubspec.yaml
dependencies:
  serverpod: ^3.3.0
  serverpod_auth_idp_server: ^3.3.0
  # Do NOT also add serverpod_auth_server - they conflict
```

### Client/Flutter Dependencies

```yaml
# my_project_client/pubspec.yaml (or my_project_flutter/pubspec.yaml)
dependencies:
  serverpod_client: ^3.3.0
  serverpod_auth_idp_client: ^3.3.0
  serverpod_auth_idp_flutter: ^3.3.0
  # Do NOT also add serverpod_auth_client/serverpod_auth_shared_flutter
```

### Server Initialization

```dart
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

void run(List<String> args) async {
  // Do NOT pass authenticationHandler - initializeAuthServices handles it
  final pod = Serverpod(args, Protocol(), Endpoints());

  pod.initializeAuthServices(
    tokenManagerBuilders: [
      JwtConfigFromPasswords(),  // Uses passwords from config
    ],
    identityProviderBuilders: [
      GoogleIdpConfig(
        clientSecret: GoogleClientSecret.fromJsonString(
          pod.getPassword('googleClientSecret')!,
        ),
      ),
    ],
  );

  await pod.start();
}
```

### Required Endpoints

You MUST create these endpoint files for the IDP system to work:

```dart
// lib/src/endpoints/google_idp_endpoint.dart
import 'package:serverpod_auth_idp_server/providers/google.dart';

class GoogleIdpEndpoint extends GoogleIdpBaseEndpoint {}
```

```dart
// lib/src/endpoints/refresh_jwt_tokens_endpoint.dart
import 'package:serverpod_auth_idp_server/core.dart' as core;

class RefreshJwtTokensEndpoint extends core.RefreshJwtTokensEndpoint {}
```

### Flutter Client Initialization

```dart
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

// Create client with IDP auth session manager
client = Client(apiUrl)
  ..connectivityMonitor = FlutterConnectivityMonitor()
  ..authSessionManager = FlutterAuthSessionManager();

// Initialize auth (restores persisted session)
await client.auth.initialize();

// Initialize Google Sign-In (required before using GoogleSignInWidget)
await client.auth.initializeGoogleSignIn();
```

### Password Configuration

Add to `config/passwords.yaml` (never commit this file):
```yaml
shared:
  jwtRefreshTokenHashPepper: <random-string>
  jwtHmacSha512PrivateKey: <random-string>
  googleClientSecret: |
    {
      "web": {
        "client_id": "...",
        "client_secret": "...",
        ...
      }
    }
```

Alternatively use env vars: `SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper`, etc.

**Shortcut**: `JwtConfigFromPasswords()` auto-loads these secrets.

### Generate Migration

After adding IDP dependencies:
```bash
serverpod generate
serverpod create-migration
```

## Google Sign-In

### Server Config

1. Create a Google Cloud project and OAuth 2.0 credentials
2. Download the client secret JSON
3. Store it as `googleClientSecret` in `config/passwords.yaml`
4. Create `GoogleIdpEndpoint extends GoogleIdpBaseEndpoint` (see above)

### Flutter Widget

```dart
GoogleSignInWidget(
  client: client,  // ServerpodClientShared
  onAuthenticated: () {
    // Sign-in successful
  },
  onError: (error) {
    // Handle error
  },
  // Optional parameters:
  attemptLightweightSignIn: false,  // Try auto sign-in
  scopes: ['email', 'profile'],
  type: GSIButtonType.standard,
  theme: GSIButtonTheme.outline,
  size: GSIButtonSize.large,
)
```

### Custom Google Auth Controller

For advanced use cases (custom UI, shared state):

```dart
final controller = GoogleAuthController(
  client: client,
  onAuthenticated: () { /* ... */ },
  onError: (error) { /* ... */ },
);

// Use with widget
GoogleSignInWidget(controller: controller)

// Or call programmatically
await controller.signIn();
```

### Web Setup

Add to `web/index.html` `<head>`:
```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID">
```

### iOS Setup

Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

### Android Setup

Configure OAuth consent screen in Google Cloud Console. No additional app config needed for standard Google Sign-In.

## Endpoint Auth

### Require Login (Entire Endpoint)

```dart
class ProtectedEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<String> secretData(Session session) async {
    // session.authenticated is guaranteed non-null here
    final userIdentifier = session.authenticated!.userIdentifier;
    return 'Secret data for $userIdentifier';
  }
}
```

### Require Scopes

```dart
class AdminEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {Scope('admin')};
}
```

### Per-Method Auth Check

```dart
class DocumentEndpoint extends Endpoint {
  Future<Document> create(Session session, Document doc) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final userIdentifier = authInfo.userIdentifier; // String (UUID)
    final scopes = authInfo.scopes; // Set<Scope>
    // ...
  }
}
```

### AuthenticationInfo Properties

```dart
final authInfo = session.authenticated; // AuthenticationInfo?
authInfo.userIdentifier  // String - UUID of the auth user
authInfo.scopes          // Set<Scope> - user's scopes
authInfo.authId          // String - auth session/key ID
```

**Important**: `userIdentifier` is a UUID string, NOT an integer. If your database models use integer user IDs, you need to look up the corresponding user record.

### Check Auth via Session Helper

```dart
var isSignedIn = session.isUserSignedIn; // bool shortcut
```

### Unauthenticated Client Calls

Mark endpoint methods that should not send auth tokens:
```dart
@unauthenticatedClientCall
Future<PublicData> getPublicData(Session session) async { ... }
```

## Token Managers

### JWT Token Manager (Default)

Uses passwords from config to sign/verify JWTs:

```dart
pod.initializeAuthServices(
  tokenManagerBuilders: [
    JwtConfigFromPasswords(),
  ],
);
```

Config in `passwords.yaml`:
```yaml
shared:
  jwtSecret: your-secret-key-here
```

Advanced JWT config:
```dart
JwtConfig(
  algorithm: JwtAlgorithm.hs256,
  secret: 'your-secret',
  accessTokenLifetime: Duration(minutes: 15),
  refreshTokenLifetime: Duration(days: 30),
)
```

### Server-Side Sessions Token Manager

```dart
pod.initializeAuthServices(
  tokenManagerBuilders: [
    ServerSideSessionsConfig(
      sessionLifetime: Duration(days: 30),
    ),
  ],
);
```

## User Management

### AuthServices (Server-Side)

```dart
import 'package:serverpod_auth_idp_server/core.dart';

// Get auth user
final authUser = await AuthServices.instance.authUsers.getUser(session, userId);

// User profiles (if using profile module)
final profile = await AuthServices.instance.userProfiles.getProfile(session, userId);
```

### Auth State (Flutter Client)

```dart
final auth = client.auth; // FlutterAuthSessionManager

// Check if authenticated
auth.isAuthenticated       // bool
auth.authInfo              // AuthSuccess? (current session)
auth.authInfo?.authUserId  // UuidValue - user's UUID
auth.authInfo?.token       // String - current access token
auth.authInfo?.scopeNames  // Set<String> - scope names

// Listen for changes
auth.authInfoListenable.addListener(() {
  // Rebuild UI when auth state changes
});

// Sign out
await auth.signOutDevice();      // Sign out this device
await auth.signOutAllDevices();   // Sign out everywhere
```

### AuthSuccess Properties

```dart
final authSuccess = client.auth.authInfo; // AuthSuccess?
authSuccess.authStrategy   // String - e.g., 'google', 'email'
authSuccess.token          // String - access token
authSuccess.tokenExpiresAt // DateTime? - expiration
authSuccess.refreshToken   // String? - refresh token
authSuccess.authUserId     // UuidValue - user's UUID
authSuccess.scopeNames     // Set<String> - scope names
```

## Custom UI

### GoogleAuthController

```dart
final controller = GoogleAuthController(
  client: client,
  onAuthenticated: () { /* success */ },
  onError: (error) { /* failure */ },
  scopes: ['email', 'profile'],
);

// Manual sign-in trigger
await controller.signIn();

// State
controller.isInitialized  // bool
controller.isLoading      // bool

// Listen for state changes
controller.addListener(() { /* rebuild */ });

// Cleanup
controller.dispose();
```

### SignInWidget (Auto-detect Providers)

```dart
// Automatically shows buttons for all configured providers
SignInWidget(client: client)
```

## Custom Auth

### Custom authenticationHandler

For non-IDP authentication (e.g., API keys, custom tokens):

```dart
final pod = Serverpod(
  args,
  Protocol(),
  Endpoints(),
  authenticationHandler: (session, token) async {
    // Validate custom token
    // Return AuthenticationInfo or null
    return AuthenticationInfo(
      'user-uuid-string',
      {Scope('user')},
      authId: 'session-id',
    );
  },
);
```

**Note**: If using both custom auth and IDP, the IDP's `initializeAuthServices` will set up its own handler. You may need to compose them.

### ClientAuthKeyProvider

For custom client-side token management:

```dart
class MyAuthKeyProvider extends ClientAuthKeyProvider {
  @override
  Future<String?> get() async {
    // Return stored token
  }

  @override
  Future<void> set(String? token) async {
    // Store token
  }
}
```

## Legacy System

**Do NOT mix old and new auth systems.** They are incompatible:

| Old System | New IDP System |
|---|---|
| `serverpod_auth_server` | `serverpod_auth_idp_server` |
| `serverpod_auth_client` | `serverpod_auth_idp_client` |
| `serverpod_auth_shared_flutter` | `serverpod_auth_idp_flutter` |
| `serverpod_auth_google_flutter` | (included in idp_flutter) |
| `authenticationHandler: auth.authenticationHandler` | `pod.initializeAuthServices(...)` |
| `FlutterAuthenticationKeyManager()` | `FlutterAuthSessionManager()` |
| `SessionManager(caller: client.modules.auth)` | `client.auth` (via extension) |
| `sessionManager.signedInUser` (UserInfo) | `client.auth.authInfo` (AuthSuccess) |
| `authInfo.userId` (int) | `authInfo.userIdentifier` (String/UUID) |
| `SignInWithGoogleButton(caller:, serverClientId:, redirectUri:)` | `GoogleSignInWidget(client:)` |
| `RouteGoogleSignIn()` web route | `GoogleIdpBaseEndpoint` endpoint |

**Migration checklist:**
1. Remove old packages, add new IDP packages
2. Remove `authenticationHandler` from `Serverpod()` constructor
3. Remove `RouteGoogleSignIn` web route
4. Add `initializeAuthServices(...)` call
5. Create `GoogleIdpEndpoint` and `RefreshJwtTokensEndpoint` files
6. Replace `FlutterAuthenticationKeyManager` with `FlutterAuthSessionManager`
7. Replace `SessionManager` usage with `client.auth`
8. Update `SignInWithGoogleButton` to `GoogleSignInWidget`
9. Change `authInfo.userId` (int) to `authInfo.userIdentifier` (String)
10. Run `serverpod generate` and `serverpod create-migration`
