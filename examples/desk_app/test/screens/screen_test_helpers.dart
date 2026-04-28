import 'dart:async';
import 'dart:io';

import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:data_models/example_data.dart';
import 'package:example/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:irondash_message_channel/irondash_message_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: implementation_imports
import 'package:super_native_extensions/src/native/context.dart' as snx_ctx;

/// 10×10 valid PNG — served by [_FakeHttpClient] so `Image.network` calls
/// (e.g. seeded media assets) decode without hitting the network.
final Uint8List _testPng = () {
  final image = img.Image(width: 10, height: 10);
  return Uint8List.fromList(img.encodePng(image));
}();

/// One-shot setUpAll for screen golden tests.
///
/// - Loads SharedPreferences mocks (DartDeskApp persists theme there).
/// - Stubs `super_drag_and_drop` / `irondash` native channels.
/// - Installs an HTTP override returning a tiny PNG for any `Image.network`.
void installScreenGoldenMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.irondash.engine_context'),
    (call) async => call.method == 'getEngineHandle' ? 0 : null,
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

  HttpOverrides.global = _FakeHttpOverrides();
}

/// Tears the GetIt registration that [DeskStudioApp.initState] sets up.
///
/// Each screen golden scenario pumps a fresh `DartDeskApp`. If a previous
/// scenario didn't dispose cleanly, [GetIt] throws on re-registration.
/// Call from `tearDown`.
void resetGetItForScreenGolden() {
  if (GetIt.I.isRegistered<StudioConfig>()) {
    GetIt.I.unregister<StudioConfig>();
  }
}

/// Seeds [source] with one chef profile config document so the studio's
/// document-list view has something to render. Returns the doc id.
Future<String> seedShowcaseChef(MockDataSource source) async {
  final doc = await source.createDocument(
    'chefConfig',
    "Marco's Choice",
    ChefConfigFixtures.showcase().toMap(),
    slug: 'marcos-choice',
  );
  return doc.id!;
}

/// Seeds [source] with [count] chef docs — one default + drafts.
Future<void> seedManyChefDocs(MockDataSource source, {int count = 5}) async {
  const titles = [
    "Marco's Choice",
    "Aria's Spring",
    'Tribeca Tasting',
    "Chef's Late Summer",
    'Harvest Notes',
    'Coastal Catch',
  ];
  for (var i = 0; i < count; i++) {
    await source.createDocument(
      'chefConfig',
      titles[i % titles.length],
      ChefConfigFixtures.showcase().toMap(),
    );
  }
}

/// Seeds a chef doc with [variant] data and returns its id.
Future<String> seedChefWith(
  MockDataSource source,
  ChefConfig variant, {
  String title = "Marco's Choice",
}) async {
  final doc = await source.createDocument(
    'chefConfig',
    title,
    variant.toMap(),
  );
  return doc.id!;
}

/// Seeds a chef doc with three versions (v1 published, v2/v3 draft) for the
/// version-history scene.
Future<String> seedChefWithVersions(MockDataSource source) async {
  final doc = await source.createDocument(
    'chefConfig',
    "Marco's Choice",
    ChefConfigFixtures.showcase().toMap(),
  );
  await source.publishDocumentVersion(
    (await source.getDocumentVersions(doc.id!)).versions.first.id!,
  );
  await source.createDocumentVersion(
    doc.id!,
    status: 'draft',
    changeLog: 'Tweaked pull quote',
  );
  await source.createDocumentVersion(
    doc.id!,
    status: 'draft',
    changeLog: 'Added autumn dishes',
  );
  return doc.id!;
}

/// Convenience: builds the desk app pointed at [source].
Future<Widget> buildScreenApp(MockDataSource source) {
  return buildDeskApp(dataSource: source, onSignOut: () {});
}

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
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
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpRequest();
  @override
  Future<HttpClientRequest> headUrl(Uri url) async => _FakeHttpRequest();
  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeHttpRequest implements HttpClientRequest {
  @override
  HttpHeaders get headers => _FakeHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _FakeHttpResponse();
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeHttpResponse implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;
  @override
  int get contentLength => _testPng.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      Stream<List<int>>.fromIterable([_testPng]).listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
  @override
  HttpHeaders get headers => _FakeHttpHeaders();
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;
  @override
  String? value(String name) => null;
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}
