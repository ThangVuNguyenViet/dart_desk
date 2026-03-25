import 'package:dart_desk_client/dart_desk_client.dart';
import 'package:test/test.dart';

class FakeAuthProvider implements ClientAuthKeyProvider {
  final String? value;
  FakeAuthProvider(this.value);

  @override
  Future<String?> get authHeaderValue async => value;
}

void main() {
  group('DartDeskAuthKeyProvider', () {
    test('returns apiKey only when inner has no value', () async {
      final provider = DartDeskAuthKeyProvider(
        apiKey: 'cms_r_test1234',
        inner: FakeAuthProvider(null),
      );
      expect(await provider.authHeaderValue, 'DartDesk apiKey=cms_r_test1234');
    });

    test('returns apiKey + inner value when inner has value', () async {
      final provider = DartDeskAuthKeyProvider(
        apiKey: 'cms_r_test1234',
        inner: FakeAuthProvider('Basic dG9rZW4='),
      );
      expect(
        await provider.authHeaderValue,
        'DartDesk apiKey=cms_r_test1234;Basic dG9rZW4=',
      );
    });

    test('returns apiKey only when inner is null', () async {
      final provider = DartDeskAuthKeyProvider(apiKey: 'cms_w_abcd1234');
      expect(await provider.authHeaderValue, 'DartDesk apiKey=cms_w_abcd1234');
    });
  });
}
