import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:shadcn_ui/shadcn_ui.dart';

/// 10×10 valid PNG bytes for tests that need an image (e.g. Image.network).
late Uint8List testPngBytes;

/// Call in `setUpAll` to initialise shared test resources.
void initTestPngBytes() {
  final image = img.Image(width: 10, height: 10);
  testPngBytes = Uint8List.fromList(img.encodePng(image));
}

/// Wraps [child] in the widget tree required by most CMS input tests.
///
/// `ShadApp` > `Scaffold` > `ShadToaster` > `SingleChildScrollView` > `Padding`
Widget buildInputApp(Widget child) {
  return ShadApp(
    home: Scaffold(
      body: ShadToaster(
        child: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  );
}

// ---------- HTTP mock for Image.network ----------

class FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => FakeHttpClient();
}

class FakeHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> headUrl(Uri url) async => FakeHttpClientRequest();

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientRequest implements HttpClientRequest {
  @override
  HttpHeaders get headers => FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => FakeHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => testPngBytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([testPngBytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  HttpHeaders get headers => FakeHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;

  @override
  String? value(String name) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
