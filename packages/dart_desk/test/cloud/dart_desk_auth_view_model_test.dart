import 'package:dart_desk/src/cloud/dart_desk_auth_view_model.dart';
import 'package:dart_desk_client/dart_desk_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:signals/signals.dart';

class _MockClient extends Mock implements Client {}

class _MockEndpointUser extends Mock implements EndpointUser {}

class _MockSessionManager extends Mock implements FlutterAuthSessionManager {}

class _MockAuthSuccess extends Mock implements AuthSuccess {}

void main() {
  late _MockClient client;
  late _MockClient googleSignInClient;
  late _MockEndpointUser userEndpoint;
  late _MockSessionManager session;
  late ValueNotifier<AuthSuccess?> authNotifier;

  setUp(() {
    client = _MockClient();
    googleSignInClient = _MockClient();
    userEndpoint = _MockEndpointUser();
    session = _MockSessionManager();
    authNotifier = ValueNotifier<AuthSuccess?>(null);

    when(() => client.user).thenReturn(userEndpoint);
    when(() => session.initialize()).thenAnswer((_) async => true);
    when(() => session.authInfoListenable).thenReturn(authNotifier);
    when(() => session.signOutDevice()).thenAnswer((_) async => true);
  });

  tearDown(() => authNotifier.dispose());

  DartDeskAuthViewModel build() => DartDeskAuthViewModel(
    client: client,
    googleSignInClient: googleSignInClient,
    sessionManager: session,
  );

  // Resolves microtasks queued by the awaitable future signal so its
  // factory runs to completion before assertions.
  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test(
    'authenticated + getCurrentUser 404 → AsyncError + signOutDevice called',
    () async {
      when(() => session.isAuthenticated).thenReturn(true);
      when(
        () => userEndpoint.getCurrentUser(),
      ).thenThrow(const ServerpodClientException('not found', 404));

      final vm = build();
      vm.currentUser.value; // force lazy factory to run.
      await vm.start();
      await settle();

      final state = vm.currentUser.value;
      expect(state, isA<AsyncError<User?>>());
      final error = (state as AsyncError<User?>).error;
      expect(error, isA<ServerpodClientException>());
      expect((error as ServerpodClientException).statusCode, 404);
      verify(() => session.signOutDevice()).called(1);

      vm.dispose();
    },
  );

  test(
    'authenticated + getCurrentUser returns user → AsyncData(user)',
    () async {
      when(() => session.isAuthenticated).thenReturn(true);
      final user = User(email: 't@example.com');
      when(() => userEndpoint.getCurrentUser()).thenAnswer((_) async => user);

      final vm = build();
      vm.currentUser.value;
      await vm.start();
      await settle();

      final state = vm.currentUser.value;
      expect(state, isA<AsyncData<User?>>());
      expect((state as AsyncData<User?>).value, user);
      verifyNever(() => session.signOutDevice());

      vm.dispose();
    },
  );

  test('unauthenticated at start → AsyncData(null)', () async {
    when(() => session.isAuthenticated).thenReturn(false);

    final vm = build();
    vm.currentUser.value;
    await vm.start();
    await settle();

    final state = vm.currentUser.value;
    expect(state, isA<AsyncData<User?>>());
    expect((state as AsyncData<User?>).value, isNull);
    verifyNever(() => userEndpoint.getCurrentUser());

    vm.dispose();
  });

  test('signInWithEmail with empty fields → signInError set', () async {
    when(() => session.isAuthenticated).thenReturn(false);

    final vm = build();
    vm.currentUser.value;
    await vm.start();
    await settle();

    await vm.signInWithEmail(email: '', password: '');
    expect(vm.signInError.value, 'Please enter both email and password.');
    expect(vm.displayError.value, 'Please enter both email and password.');
    // currentUser stays as AsyncData(null) — sign-in errors don't taint
    // the user state.
    expect(vm.currentUser.value, isA<AsyncData<User?>>());
    expect((vm.currentUser.value as AsyncData<User?>).value, isNull);

    vm.dispose();
  });

  test(
    'silent token refresh (same authUserId) does not refetch currentUser',
    () async {
      when(() => session.isAuthenticated).thenReturn(true);
      final user = User(email: 't@example.com');
      var callCount = 0;
      when(() => userEndpoint.getCurrentUser()).thenAnswer((_) async {
        callCount++;
        return user;
      });

      final userId = UuidValue.fromString(
        '00000000-0000-4000-8000-000000000001',
      );
      final first = _MockAuthSuccess();
      when(() => first.authUserId).thenReturn(userId);
      authNotifier.value = first;

      final vm = build();
      vm.currentUser.value;
      await vm.start();
      await settle();
      expect(callCount, 1);

      // Simulate a silent token refresh: SessionManager emits a new
      // AuthSuccess instance with the same authUserId (rotated tokens).
      final refreshed = _MockAuthSuccess();
      when(() => refreshed.authUserId).thenReturn(userId);
      authNotifier.value = refreshed;
      await settle();

      expect(callCount, 1, reason: 'silent refresh should not refetch user');
      expect((vm.currentUser.value as AsyncData<User?>).value, user);

      vm.dispose();
    },
  );

  test('identity change (different authUserId) triggers refetch', () async {
    when(() => session.isAuthenticated).thenReturn(true);
    final userA = User(email: 'a@example.com');
    final userB = User(email: 'b@example.com');
    var callCount = 0;
    when(() => userEndpoint.getCurrentUser()).thenAnswer((_) async {
      callCount++;
      return callCount == 1 ? userA : userB;
    });

    final idA = UuidValue.fromString('00000000-0000-4000-8000-00000000000a');
    final idB = UuidValue.fromString('00000000-0000-4000-8000-00000000000b');
    final first = _MockAuthSuccess();
    when(() => first.authUserId).thenReturn(idA);
    authNotifier.value = first;

    final vm = build();
    vm.currentUser.value;
    await vm.start();
    await settle();
    expect((vm.currentUser.value as AsyncData<User?>).value, userA);

    // Account switch: different authUserId.
    final second = _MockAuthSuccess();
    when(() => second.authUserId).thenReturn(idB);
    authNotifier.value = second;
    await settle();

    expect(callCount, 2);
    expect((vm.currentUser.value as AsyncData<User?>).value, userB);

    vm.dispose();
  });

  test('auth listener flipping to authenticated triggers reload', () async {
    var authed = false;
    when(() => session.isAuthenticated).thenAnswer((_) => authed);
    final user = User(email: 't@example.com');
    when(() => userEndpoint.getCurrentUser()).thenAnswer((_) async => user);

    final vm = build();
    vm.currentUser.value;
    await vm.start();
    await settle();
    expect((vm.currentUser.value as AsyncData<User?>).value, isNull);

    // Simulate successful sign-in completing: isAuthenticated flips true and
    // the listenable fires with a fresh AuthSuccess.
    authed = true;
    final auth = _MockAuthSuccess();
    when(
      () => auth.authUserId,
    ).thenReturn(UuidValue.fromString('00000000-0000-4000-8000-000000000099'));
    authNotifier.value = auth;
    await settle();

    expect((vm.currentUser.value as AsyncData<User?>).value, user);

    vm.dispose();
  });
}
