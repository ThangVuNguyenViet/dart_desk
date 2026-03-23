import 'package:http/http.dart' as http;

/// HTTP client wrapper that injects x-api-key header on every request.
///
/// Used with `runWithClient` to intercept all HTTP requests from
/// the Serverpod client without modifying generated code.
class ApiKeyHttpClient extends http.BaseClient {
  final http.Client _inner;
  final String _apiKey;

  ApiKeyHttpClient(this._inner, this._apiKey);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['x-api-key'] = _apiKey;
    return _inner.send(request);
  }
}
