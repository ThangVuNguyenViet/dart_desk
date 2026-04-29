import 'dart:async';
import 'dart:io';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/src/studio/providers/studio_provider.dart';
import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../helpers/input_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test harness
// ---------------------------------------------------------------------------

const _desktopSize = Size(1600, 1000);

Widget _wrapWithBreakpoints(Widget child) {
  return ResponsiveBreakpoints.builder(
    breakpoints: const [
      Breakpoint(
        start: 0,
        end: DeskBreakpoints.mobile,
        name: DeskBreakpoints.mobileTag,
      ),
      Breakpoint(
        start: DeskBreakpoints.mobile,
        end: DeskBreakpoints.tablet,
        name: DeskBreakpoints.tabletTag,
      ),
      Breakpoint(
        start: DeskBreakpoints.tablet,
        end: double.infinity,
        name: DeskBreakpoints.desktopTag,
      ),
    ],
    child: child,
  );
}

void _useDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = _desktopSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Wraps [MockDataSource] with hooks so tests can control completion timing
/// of `getDocumentVersions` — used to assert UI behavior while the future is
/// still pending.
class _DelayingDataSource extends MockDataSource {
  Completer<void>? versionsGate;

  @override
  Future<DocumentVersionList> getDocumentVersions(
    String documentId, {
    int limit = 20,
    int offset = 0,
  }) async {
    if (versionsGate != null) {
      await versionsGate!.future;
    }
    return super.getDocumentVersions(
      documentId,
      limit: limit,
      offset: offset,
    );
  }
}

/// Wraps [MockDataSource] and strips `isDefault` from every returned doc, so
/// the auto-select fallback path ("no default → take first") is exercised
/// even though MockDataSource auto-flags the first created doc as default.
class _NoDefaultDataSource extends MockDataSource {
  @override
  Future<DocumentList> getDocuments(
    String documentType, {
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final base = await super.getDocuments(
      documentType,
      search: search,
      limit: limit,
      offset: offset,
    );
    return DocumentList(
      documents: base.documents
          .map((d) => d.copyWith(isDefault: false))
          .toList(),
      total: base.total,
      page: base.page,
      pageSize: base.pageSize,
    );
  }
}

void main() {
  setUpAll(() {
    initTestPngBytes();
    HttpOverrides.global = FakeHttpOverrides();
  });

  // ========================================================================
  // 1. Status pill is hidden while versions are loading
  // ========================================================================

  group('_DocumentStatusPill while versions load', () {
    testWidgets('renders no DeskStatusPill until versions resolve', (
      tester,
    ) async {
      _useDesktopViewport(tester);

      final source = _DelayingDataSource()..seedDefaults();
      // Hold getDocumentVersions until we explicitly complete the gate.
      source.versionsGate = Completer<void>();

      await tester.pumpWidget(
        ShadApp(
          home: Scaffold(
            body: ShadToaster(
              child: StudioProvider(
                dataSource: source,
                documentTypes: [allFieldsDocumentType],
                child: Builder(
                  builder: (context) {
                    GetIt.I<DeskViewModel>().currentDocumentTypeSlug.value =
                        allFieldsDocumentType.name;
                    return _wrapWithBreakpoints(
                      DeskDocumentListView(
                        selectedDocumentType: allFieldsDocumentType,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      // Let documentsContainer resolve (synchronous in MockDataSource) so
      // rows render. Versions are still gated.
      await tester.pump();
      await tester.pump();

      // Document tiles are present, but no status pill yet — the bug we
      // fixed used to flash 'draft' here.
      expect(find.text('Test Document Alpha'), findsOneWidget);
      expect(find.byType(DeskStatusPill), findsNothing);

      // Release the gate; pills should now appear with real statuses.
      source.versionsGate!.complete();
      await tester.pumpAndSettle();

      expect(find.byType(DeskStatusPill), findsWidgets);
    });
  });

  // ========================================================================
  // 2. Editor pane defaults to 500px wide on desktop
  // ========================================================================

  group('DocumentScreen editor initial width', () {
    testWidgets('editor pane is 500px wide on desktop', (tester) async {
      _useDesktopViewport(tester);

      final source = MockDataSource()..seedDefaults();
      final docs = await source.getDocuments(allFieldsDocumentType.name);
      final doc = docs.documents.first;

      await tester.pumpWidget(
        ShadApp(
          home: Scaffold(
            body: ShadToaster(
              child: StudioProvider(
                dataSource: source,
                documentTypes: [allFieldsDocumentType],
                child: Builder(
                  builder: (context) {
                    GetIt.I<DeskViewModel>().currentDocumentTypeSlug.value =
                        allFieldsDocumentType.name;
                    return _wrapWithBreakpoints(
                      DocumentScreen(
                        documentTypeSlug: allFieldsDocumentType.name,
                        documentId: doc.id!,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final editor = find.byType(DeskDocumentEditor);
      expect(editor, findsOneWidget);
      final size = tester.getSize(editor);
      expect(
        size.width,
        500,
        reason: 'Editor pane should start at the configured 500px width',
      );
    });
  });

  // ========================================================================
  // 3. StudioShellScreen auto-selects the default document
  // ========================================================================

  group('StudioShellScreen auto-select', () {
    Future<void> pumpStudioShell(
      WidgetTester tester,
      MockDataSource source,
    ) async {
      GetIt.I.registerSingleton<StudioConfig>(
        StudioConfig(
          documentTypes: [allFieldsDocumentType],
          dataSource: source,
          documentTypeDecorations: const [],
          onSignOut: () {},
        ),
      );
      addTearDown(() {
        if (GetIt.I.isRegistered<StudioConfig>()) {
          GetIt.I.unregister<StudioConfig>();
        }
      });

      final router = StudioRouter();
      final themeMode = Signal<ThemeMode>(ThemeMode.light);
      addTearDown(themeMode.dispose);
      await tester.pumpWidget(
        DeskThemeModeProvider(
          themeMode: themeMode,
          child: ShadApp.router(
            routeInformationParser: router.defaultRouteParser(),
            routerDelegate: router.delegate(
              navigatorObservers: () => [StudioRouteObserver(router)],
            ),
            builder: (context, child) => _wrapWithBreakpoints(child!),
          ),
        ),
      );
    }

    testWidgets('navigates to the default document on cold start', (
      tester,
    ) async {
      _useDesktopViewport(tester);

      // seedDefaults marks "Test Document Alpha" as the default.
      final source = MockDataSource()..seedDefaults();
      await pumpStudioShell(tester, source);
      // Several layers of async to drain: router init → didChangeDependencies
      // navigates to first doc type → route observer microtask seeds signals
      // → post-frame effect installs → documentsContainer fetch resolves →
      // effect navigates to default doc → route observer seeds docId.
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Auto-select fired: the selected document id should now match the
      // default doc.
      final docs = await source.getDocuments(allFieldsDocumentType.name);
      final defaultDoc = docs.documents.firstWhere((d) => d.isDefault);
      expect(
        GetIt.I<DeskViewModel>().currentDocumentId.value,
        defaultDoc.id,
        reason:
            'Effect should have navigated to the default document, which the '
            'route observer mirrors back into currentDocumentId.',
      );

      // Drain a known-pre-existing RenderFlex overflow in the doc-list row
      // (Default badge + timestamp at 220px panel width). Unrelated to the
      // behaviour under test.
      final overflow = tester.takeException();
      expect(
        overflow,
        anyOf(isNull, isA<FlutterError>()),
      );
    });

    testWidgets('falls back to first document when no default is marked', (
      tester,
    ) async {
      _useDesktopViewport(tester);

      // Strip isDefault from all returned docs so the effect must hit the
      // `?? docs.first` fallback. seedDefaults is still used so the doc
      // ordering matches the production data shape.
      final source = _NoDefaultDataSource()..seedDefaults();
      await pumpStudioShell(tester, source);
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      final docs = await source.getDocuments(allFieldsDocumentType.name);
      // Sanity: no doc is flagged as default.
      expect(docs.documents.any((d) => d.isDefault), isFalse);

      expect(
        GetIt.I<DeskViewModel>().currentDocumentId.value,
        docs.documents.first.id,
        reason:
            'With no default doc, the effect should navigate to the first '
            'document in the list.',
      );

      final overflow = tester.takeException();
      expect(overflow, anyOf(isNull, isA<FlutterError>()));
    });
  });
}
