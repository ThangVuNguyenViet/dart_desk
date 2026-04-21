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
  late _MockEndpointUser userEndpoint;
  late _MockSessionManager session;
  late ValueNotifier<AuthSuccess?> authNotifier;

  setUp(() {
    client = _MockClient();
    userEndpoint = _MockEndpointUser();
    session = _MockSessionManager();
    authNotifier = ValueNotifier<AuthSuccess?>(null);

    when(() => client.user).thenReturn(userEndpoint);
    when(() => session.initialize()).thenAnswer((_) async => true);
    when(() => session.authInfoListenable).thenReturn(authNotifier);
    when(() => session.signOutDevice()).thenAnswer((_) async => true);
  });

  tearDown(() => authNotifier.dispose());

  DartDeskAuthViewModel build() =>
      DartDeskAuthViewModel(client: client, sessionManager: session);

  test(
    'authenticated + getCurrentUser 404 → AsyncError + signOutDevice called',
    () async {
      when(() => session.isAuthenticated).thenReturn(true);
      when(
        () => userEndpoint.getCurrentUser(),
      ).thenThrow(const ServerpodClientException('not found', 404));

      final vm = build();
      await vm.start();
      // The error-reaction effect dispatches signOutDevice via an untracked
      // async callback — let it settle.
      await Future<void>.delayed(Duration.zero);

      final state = vm.getCurrentUser.value;
      expect(state, isA<AsyncError<User?>>());
      final error = (state as AsyncError<User?>).error;
      expect(error, isA<ServerpodClientException>());
      expect((error as ServerpodClientException).statusCode, 404);
      verify(() => session.signOutDevice()).called(1);

      vm.dispose();
    },
  );

  test('authenticated + getCurrentUser returns user → AsyncData(user)', () async {
    when(() => session.isAuthenticated).thenReturn(true);
    final user = User(email: 't@example.com');
    when(() => userEndpoint.getCurrentUser()).thenAnswer((_) async => user);

    final vm = build();
    await vm.start();

    final state = vm.getCurrentUser.value;
    expect(state, isA<AsyncData<User?>>());
    expect((state as AsyncData<User?>).value, user);
    verifyNever(() => session.signOutDevice());

    vm.dispose();
  });

  test('unauthenticated at start → AsyncData(null)', () async {
    when(() => session.isAuthenticated).thenReturn(false);

    final vm = build();
    await vm.start();

    final state = vm.getCurrentUser.value;
    expect(state, isA<AsyncData<User?>>());
    expect((state as AsyncData<User?>).value, isNull);
    verifyNever(() => userEndpoint.getCurrentUser());

    vm.dispose();
  });

  test('signInWithEmail with empty fields → validation AsyncError', () async {
    when(() => session.isAuthenticated).thenReturn(false);

    final vm = build();
    await vm.start();

    await vm.signInWithEmail(email: '', password: '');
    final state = vm.getCurrentUser.value;
    expect(state, isA<AsyncError<User?>>());
    expect(
      (state as AsyncError<User?>).error,
      'Please enter both email and password.',
    );

    vm.dispose();
  });

  test('auth listener flipping to authenticated triggers loadCurrentUser', () async {
    var authed = false;
    when(() => session.isAuthenticated).thenAnswer((_) => authed);
    final user = User(email: 't@example.com');
    when(() => userEndpoint.getCurrentUser()).thenAnswer((_) async => user);

    final vm = build();
    await vm.start();
    expect((vm.getCurrentUser.value as AsyncData<User?>).value, isNull);

    // Simulate successful sign-in completing: isAuthenticated flips true and
    // the listenable fires.
    authed = true;
    authNotifier.value = _MockAuthSuccess();
    // loadCurrentUser awaits; give the microtask queue a chance to finish.
    await Future<void>.delayed(Duration.zero);

    expect((vm.getCurrentUser.value as AsyncData<User?>).value, user);

    vm.dispose();
  });
}
