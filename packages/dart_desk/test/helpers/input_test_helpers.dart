import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:irondash_message_channel/irondash_message_channel.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
// ignore: implementation_imports
import 'package:super_native_extensions/src/native/context.dart' as snx_ctx;

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
///
/// ShadApp does not seed a top-level [DefaultTextStyle], so bare `Text`
/// widgets fall through to Flutter's hardcoded default (Ahem in tests). We
/// anchor descendants to the shadcn body style so plain text inherits
/// Geist instead of rectangles.
Widget buildInputApp(Widget child) {
  return ShadApp(
    home: Builder(
      builder: (context) => DefaultTextStyle(
        style: ShadTheme.of(context).textTheme.p,
        child: Scaffold(
          body: ShadToaster(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// ---------- Native plugin stubs for super_drag_and_drop ----------

/// Stubs the platform channels used by `super_drag_and_drop` /
/// `super_native_extensions` so widgets that mount drop targets (e.g.
/// `DeskImageInput`) don't fail in `flutter_test` with
/// `MissingPluginException` and `NoSuchChannelException`.
///
/// Must be called from `setUpAll` before any widget pumps. Registers a
/// `MockMessageChannelContext` override on `super_native_extensions`,
/// supplying no-op handlers for the channels touched by drop/drag/menu
/// initialization.
void installSuperDragAndDropMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.irondash.engine_context'),
    (call) async {
      if (call.method == 'getEngineHandle') return 0;
      return null;
    },
  );

  final ctx = MockMessageChannelContext();
  for (final channel in const [
    'DropManager',
    'DragManager',
    'MenuManager',
    'DataReaderManager',
    'DataProviderManager',
    'ClipboardReader',
    'ClipboardWriter',
    'ClipboardEventManager',
    'HotKeyManager',
    'KeyboardLayoutManager',
  ]) {
    ctx.registerMockMethodCallHandler(channel, (_) async => null);
  }
  snx_ctx.setContextOverride(ctx);
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
