import 'dart:developer' as developer;

import 'package:dart_desk_client/dart_desk_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:signals/signals.dart';

/// Owns the top-level auth state for [DartDeskAuth].
///
/// All loading/error/data state is expressed through a single
/// [AsyncSignal<User?>]:
///   - [AsyncLoading]: bootstrapping or loading the current user.
///   - [AsyncData] with null: no user — show sign-in.
///   - [AsyncData] with a [User]: signed in and authorized — show the app.
///   - [AsyncError]: any failure (init, sign-in, getCurrentUser). The error is
///     rendered on the sign-in screen; an internal [effect] signs the device
///     out so the auth gate can't let the user through.
class DartDeskAuthViewModel {
  final Client client;

  /// A separate client used exclusively for social sign-in widgets (e.g.
  /// [GoogleSignInWidget]). Serverpod's sign-in widgets access `client.auth`
  /// which requires `authKeyProvider is FlutterAuthSessionManager`. The main
  /// [client] sets a [DartDeskAuthKeyProvider] as `authKeyProvider` (to inject
  /// the API key), which breaks that check. This client satisfies the type
  /// check while sharing the same [sessionManager] so that both clients always
  /// see the same auth state.
  final Client googleSignInClient;

  final FlutterAuthSessionManager sessionManager;

  DartDeskAuthViewModel({
    required this.client,
    required this.googleSignInClient,
    required this.sessionManager,
  });

  /// Convenience factory — builds a [Client] + [FlutterAuthSessionManager]
  /// wired to the given [serverUrl]/[apiKey], then a VM around them. The
  /// returned VM still needs [start] to be called (which also calls
  /// `initialize()` on the session manager).
  factory DartDeskAuthViewModel.fromConfig({
    required String serverUrl,
    required String apiKey,
  }) {
    final sessionManager = FlutterAuthSessionManager();

    // Main API client — injects the API key on every request via
    // DartDeskAuthKeyProvider, which wraps the session manager so user JWT is
    // included after sign-in.
    final client = Client(
          serverUrl,
          onFailedCall: (context, error, stackTrace) {
            developer.log(
              'API call failed: ${context.endpointName}.${context.methodName}',
              name: 'ServerpodClient',
              error: error,
              stackTrace: stackTrace,
            );
          },
          onSucceededCall: (context) {
            developer.log(
              'API call succeeded: ${context.endpointName}.${context.methodName}',
              name: 'ServerpodClient',
            );
          },
        )
        ..connectivityMonitor = FlutterConnectivityMonitor()
        ..authSessionManager = sessionManager
        ..authKeyProvider = DartDeskAuthKeyProvider(
          apiKey: apiKey,
          inner: sessionManager,
        );

    // Auth-only client — used by GoogleSignInWidget. Must have
    // authKeyProvider = sessionManager (a FlutterAuthSessionManager) to
    // satisfy the type check in client.auth getter. Shares the same
    // sessionManager so sign-in state is visible to the main client too.
    final googleSignInClient = Client(serverUrl)
      ..connectivityMonitor = FlutterConnectivityMonitor()
      ..authSessionManager = sessionManager;

    return DartDeskAuthViewModel(
      client: client,
      googleSignInClient: googleSignInClient,
      sessionManager: sessionManager,
    );
  }

  final AsyncSignal<User?> getCurrentUser = asyncSignal<User?>(
    AsyncState.loading(),
    debugLabel: 'getCurrentUser',
  );

  EffectCleanup? _disposeErrorEffect;
  bool _started = false;

  /// Initializes the session manager, wires listeners, and triggers the
  /// initial load. Safe to call more than once — subsequent calls are no-ops.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      await sessionManager.initialize();
    } catch (e, st) {
      getCurrentUser.setError(e, st);
      return;
    }

    sessionManager.authInfoListenable.addListener(_onAuthChanged);

    _disposeErrorEffect = effect(() {
      final state = getCurrentUser.value;
      if (state is! AsyncError) return;
      untracked(() async {
        if (sessionManager.isAuthenticated) {
          await sessionManager.signOutDevice();
        }
      });
    });

    if (sessionManager.isAuthenticated) {
      await loadCurrentUser();
    } else {
      getCurrentUser.setValue(null);
    }
  }

  Future<void> loadCurrentUser() async {
    getCurrentUser.setLoading();
    try {
      final user = await client.user.getCurrentUser();
      getCurrentUser.setValue(user);
    } catch (e, st) {
      getCurrentUser.setError(e, st);
    }
  }

  void _onAuthChanged() {
    if (sessionManager.isAuthenticated) {
      if (getCurrentUser.value is! AsyncLoading) {
        loadCurrentUser();
      }
    } else {
      // Signed out. Drop any stored user but preserve an AsyncError so the
      // reason (e.g. "not a member of this project") stays on the sign-in
      // screen.
      final state = getCurrentUser.value;
      if (state is AsyncData<User?> && state.value != null) {
        getCurrentUser.setValue(null);
      }
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      getCurrentUser.setError('Please enter both email and password.');
      return;
    }
    // Clear any prior error while the request is in flight.
    getCurrentUser.setValue(null);
    try {
      final authSuccess = await client.emailIdp.login(
        email: email,
        password: password,
      );
      await sessionManager.updateSignedInUser(authSuccess);
      // authInfoListenable → _onAuthChanged → loadCurrentUser.
    } catch (e, st) {
      getCurrentUser.setError(e, st);
    }
  }

  Future<void> signOut() async {
    try {
      await sessionManager.signOutDevice();
    } catch (e, st) {
      getCurrentUser.setError(e, st);
    }
  }

  /// Surface an out-of-band error (e.g. Google sign-in widget callback).
  void reportError(Object error) => getCurrentUser.setError(error);

  /// Clear any displayed error without changing auth state.
  void clearError() {
    if (getCurrentUser.value is AsyncError) {
      getCurrentUser.setValue(null);
    }
  }

  void dispose() {
    _disposeErrorEffect?.call();
    sessionManager.authInfoListenable.removeListener(_onAuthChanged);
    getCurrentUser.dispose();
  }
}
