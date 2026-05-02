import 'dart:async';

import 'package:dart_desk_client/dart_desk_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:signals/signals.dart';

import '../debug.dart';
import '../extensions/awaitable_future_signal.dart';

/// Owns the top-level auth state for [DartDeskAuth].
///
/// State surfaces:
///   - [currentUser] — an [AwaitableFutureSignal] driven by the session
///     manager. Cold start parks in [AsyncLoading] until [start] resolves;
///     thereafter the factory runs whenever [_authInfo] changes (sign-in,
///     sign-out, token refresh). Yields:
///       - [AsyncData] with `null`: not signed in.
///       - [AsyncData] with a [User]: signed in and authorized.
///       - [AsyncError]: the user fetch itself failed (e.g. 404 — not a
///         project member). An internal effect signs the device out so the
///         auth gate can't let them through.
///       - [AsyncDataReloading]: refreshing without unmounting the app.
///   - [signInError] — transient errors raised outside the fetch lifecycle
///     (form validation, OAuth callback). Display alongside [currentUser]
///     errors via [displayError].
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

    final client = Client(
          serverUrl,
          onFailedCall: (context, error, stackTrace) {
            clientLogger.severe(
              'API call failed: ${context.endpointName}.${context.methodName}',
              error,
              stackTrace,
            );
          },
          onSucceededCall: (context) {
            clientLogger.info(
              'API call succeeded: ${context.endpointName}.${context.methodName}',
            );
          },
        )
        ..connectivityMonitor = FlutterConnectivityMonitor()
        ..authSessionManager = sessionManager
        ..authKeyProvider = DartDeskAuthKeyProvider(
          apiKey: apiKey,
          inner: sessionManager,
        );

    final googleSignInClient = Client(serverUrl)
      ..connectivityMonitor = FlutterConnectivityMonitor()
      ..authSessionManager = sessionManager;

    return DartDeskAuthViewModel(
      client: client,
      googleSignInClient: googleSignInClient,
      sessionManager: sessionManager,
    );
  }

  /// Flips to true after [sessionManager.initialize] resolves. While false,
  /// [currentUser] hangs (returns a never-completing future) so the UI stays
  /// in [AsyncLoading] instead of flashing the sign-in screen.
  final _authReady = signal<bool>(false, debugLabel: 'authReady');

  /// Mirror of [sessionManager.authInfoListenable]'s value. Identity changes
  /// here trigger a [currentUser] re-fetch — covering sign-in, sign-out, and
  /// token refresh after idle.
  final _authInfo = signal<AuthSuccess?>(null, debugLabel: 'authInfo');

  late final AwaitableFutureSignal<User?> currentUser =
      awaitableFutureSignal<User?>(
    () async {
      if (!_authReady.value) {
        // Park in AsyncLoading until start() finishes initialize(). The
        // dependency on _authReady will trigger a re-run once it flips.
        return Completer<User?>().future;
      }
      _authInfo.value; // tracked: any auth change triggers a reload.
      if (!sessionManager.isAuthenticated) return null;
      return client.user.getCurrentUser();
    },
    dependencies: [_authReady, _authInfo],
    debugLabel: 'currentUser',
  );

  /// Transient errors that aren't the result of the user fetch (form
  /// validation, OAuth callback failures, manual [reportError] calls).
  final signInError = signal<Object?>(null, debugLabel: 'signInError');

  /// Combines factory errors and transient errors for the sign-in screen.
  late final Computed<Object?> displayError = computed<Object?>(() {
    final state = currentUser.value;
    if (state is AsyncError<User?>) return state.error;
    return signInError.value;
  }, debugLabel: 'displayError');

  EffectCleanup? _disposeErrorEffect;
  EffectCleanup? _disposeDisplayErrorLog;
  bool _started = false;

  /// Initializes the session manager, wires the auth listener, and unblocks
  /// [currentUser] by flipping [_authReady]. Safe to call more than once.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      await sessionManager.initialize();
    } catch (e) {
      signInError.value = e;
      _authReady.value = true; // unblock the factory so it returns null.
      return;
    }

    sessionManager.authInfoListenable.addListener(_onAuthChanged);

    _disposeErrorEffect = effect(() {
      final state = currentUser.value;
      if (state is! AsyncError<User?>) return;
      untracked(() async {
        if (sessionManager.isAuthenticated) {
          await sessionManager.signOutDevice();
        }
      });
    });

    // Surface any error that the auth UI shows into the console too.
    // Without this, errors are silently rendered as a red banner with no
    // way to diagnose the underlying cause from logs.
    _disposeDisplayErrorLog = effect(() {
      final err = displayError.value;
      if (err == null) return;
      authLogger.severe('auth display error', err);
    });

    // Seed the auth signals to current state and unblock the factory in one
    // batch so we don't trigger two reloads on startup.
    batch(() {
      _authInfo.value = sessionManager.authInfoListenable.value;
      _authReady.value = true;
    });
  }

  void _onAuthChanged() {
    _authInfo.value = sessionManager.authInfoListenable.value;
    // Dependency change → currentUser auto-reloads as AsyncDataReloading,
    // keeping any prior value visible until the new fetch resolves.
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      signInError.value = 'Please enter both email and password.';
      return;
    }
    signInError.value = null;
    try {
      final authSuccess = await client.emailIdp.login(
        email: email,
        password: password,
      );
      await sessionManager.updateSignedInUser(authSuccess);
      // authInfoListenable → _onAuthChanged → currentUser reload.
    } catch (e) {
      signInError.value = e;
    }
  }

  Future<void> signOut() async {
    try {
      await sessionManager.signOutDevice();
    } catch (e) {
      signInError.value = e;
    }
  }

  /// Surface an out-of-band error (e.g. Google sign-in widget callback).
  void reportError(Object error) => signInError.value = error;

  /// Clear any displayed transient error.
  void clearError() => signInError.value = null;

  void dispose() {
    _disposeErrorEffect?.call();
    _disposeDisplayErrorLog?.call();
    sessionManager.authInfoListenable.removeListener(_onAuthChanged);
    currentUser.dispose();
    displayError.dispose();
    _authReady.dispose();
    _authInfo.dispose();
    signInError.dispose();
  }
}
