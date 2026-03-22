import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_desk/src/data/models/image_types.dart';
import 'package:dart_desk/src/inputs/hotspot/image_hotspot_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shadcn_ui/shadcn_ui.dart';

late Uint8List _testPngBytes;

void main() {
  setUpAll(() {
    final image = img.Image(width: 10, height: 10);
    _testPngBytes = Uint8List.fromList(img.encodePng(image));
    HttpOverrides.global = _FakeHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('ImageHotspotEditor', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('hotspot_editor')), findsOneWidget);
      expect(find.text('Edit Hotspot & Crop'), findsOneWidget);
    });

    testWidgets('Done fires callback with defaults', (tester) async {
      Hotspot? resultHotspot;
      CropRect? resultCrop;

      await tester.pumpWidget(_buildApp(
        onChanged: (result) {
          resultHotspot = result.hotspot;
          resultCrop = result.crop;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('done_button')));
      await tester.pumpAndSettle();

      expect(resultHotspot, isNotNull);
      expect(resultHotspot!.x, 0.5);
      expect(resultHotspot!.y, 0.5);
      expect(resultHotspot!.width, 0.3);
      expect(resultHotspot!.height, 0.3);

      expect(resultCrop, isNotNull);
      expect(resultCrop!.top, 0.0);
      expect(resultCrop!.bottom, 0.0);
      expect(resultCrop!.left, 0.0);
      expect(resultCrop!.right, 0.0);
    });

    testWidgets('custom initial values preserved', (tester) async {
      const customHotspot = Hotspot(x: 0.7, y: 0.3, width: 0.4, height: 0.2);
      const customCrop = CropRect(top: 0.1, bottom: 0.2, left: 0.15, right: 0.05);

      Hotspot? resultHotspot;
      CropRect? resultCrop;

      await tester.pumpWidget(_buildApp(
        initialHotspot: customHotspot,
        initialCrop: customCrop,
        onChanged: (result) {
          resultHotspot = result.hotspot;
          resultCrop = result.crop;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('done_button')));
      await tester.pumpAndSettle();

      expect(resultHotspot!.x, 0.7);
      expect(resultHotspot!.y, 0.3);
      expect(resultHotspot!.width, 0.4);
      expect(resultHotspot!.height, 0.2);

      expect(resultCrop!.top, 0.1);
      expect(resultCrop!.bottom, 0.2);
      expect(resultCrop!.left, 0.15);
      expect(resultCrop!.right, 0.05);
    });

    testWidgets('reset restores defaults', (tester) async {
      const customHotspot = Hotspot(x: 0.7, y: 0.3, width: 0.4, height: 0.2);
      const customCrop = CropRect(top: 0.1, bottom: 0.2, left: 0.15, right: 0.05);

      Hotspot? resultHotspot;
      CropRect? resultCrop;

      await tester.pumpWidget(_buildApp(
        initialHotspot: customHotspot,
        initialCrop: customCrop,
        onChanged: (result) {
          resultHotspot = result.hotspot;
          resultCrop = result.crop;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('reset_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('done_button')));
      await tester.pumpAndSettle();

      expect(resultHotspot!.x, 0.5);
      expect(resultHotspot!.y, 0.5);
      expect(resultHotspot!.width, 0.3);
      expect(resultHotspot!.height, 0.3);

      expect(resultCrop!.top, 0.0);
      expect(resultCrop!.bottom, 0.0);
      expect(resultCrop!.left, 0.0);
      expect(resultCrop!.right, 0.0);
    });
  });
}

Widget _buildApp({
  Hotspot? initialHotspot,
  CropRect? initialCrop,
  ValueChanged<({Hotspot? hotspot, CropRect? crop})>? onChanged,
}) {
  return ShadApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: ImageHotspotEditor(
          imageUrl: 'https://test.example.com/image.png',
          initialHotspot: initialHotspot,
          initialCrop: initialCrop,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    ),
  );
}

// ---------- HTTP mock for Image.network ----------

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _FakeHttpClient();
}

class _FakeHttpClient implements HttpClient {
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
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> headUrl(Uri url) async =>
      _FakeHttpClientRequest();

  @override
  void close({bool force = false}) {}

  // Unused stubs
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _testPngBytes.length;

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
    return Stream<List<int>>.fromIterable([_testPngBytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;

  @override
  String? value(String name) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
