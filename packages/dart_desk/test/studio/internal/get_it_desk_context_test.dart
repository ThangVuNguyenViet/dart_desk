import 'package:dart_desk/src/data/desk_data_source.dart';
import 'package:dart_desk/src/data/models/document_list.dart';
import 'package:dart_desk/src/extensions/awaitable_future_signal.dart';
import 'package:dart_desk/src/studio/core/view_models/desk_document_view_model.dart';
import 'package:dart_desk/src/studio/core/view_models/desk_view_model.dart';
import 'package:dart_desk/src/studio/internal/get_it_desk_context.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _FakeService {
  final String tag;
  _FakeService(this.tag);
}

class _FakeViewModel implements DeskDocumentViewModel {
  _FakeViewModel(this._doc);
  final DeskDocument? _doc;

  @override
  late final selectedDocument = AwaitableFutureSignal<DeskDocument?>(
    () async => _doc,
  );

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Only selectedDocument is stubbed');
}

class _FakeDataSource implements DataSource {
  _FakeDataSource(this._docsByType);
  final Map<String, List<DeskDocument>> _docsByType;

  @override
  Future<DocumentList> getDocuments(
    String documentType, {
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final docs = _docsByType[documentType] ?? const [];
    return DocumentList(
      documents: docs,
      total: docs.length,
      page: 1,
      pageSize: limit,
    );
  }

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Only getDocuments is stubbed');
}

Future<void> _resetGetIt() async {
  if (GetIt.I.isRegistered<DeskDocumentViewModel>()) {
    await GetIt.I.unregister<DeskDocumentViewModel>();
  }
  if (GetIt.I.isRegistered<DeskViewModel>()) {
    await GetIt.I.unregister<DeskViewModel>();
  }
  if (GetIt.I.isRegistered<_FakeService>()) {
    await GetIt.I.unregister<_FakeService>();
  }
}

void main() {
  setUp(_resetGetIt);

  test('document returns the selected document from DeskDocumentViewModel',
      () async {
    final doc = DeskDocument(
      clientId: 'c',
      documentType: 'menuConfig',
      title: 'T',
      isDefault: true,
    );
    final vm = _FakeViewModel(doc);
    GetIt.I.registerSingleton<DeskDocumentViewModel>(vm);
    await vm.selectedDocument.future;

    final ctx = GetItDeskContext();
    expect(ctx.document, equals(doc));
    expect(ctx.document?.isDefault, isTrue);
  });

  test('document is null when no document is selected', () async {
    final vm = _FakeViewModel(null);
    GetIt.I.registerSingleton<DeskDocumentViewModel>(vm);
    await vm.selectedDocument.future;

    final ctx = GetItDeskContext();
    expect(ctx.document, isNull);
  });

  test('read<T>() resolves a registered service', () {
    GetIt.I.registerSingleton<_FakeService>(_FakeService('hello'));
    final ctx = GetItDeskContext();
    expect(ctx.read<_FakeService>().tag, 'hello');
  });

  test('read<T>() throws when service is not registered', () {
    final ctx = GetItDeskContext();
    expect(() => ctx.read<_FakeService>(), throwsA(anything));
  });

  test('documents() returns the loaded list for the requested document type',
      () async {
    final docs = [
      DeskDocument(
        clientId: 'c',
        documentType: 'menuConfig',
        title: 'A',
      ),
      DeskDocument(
        clientId: 'c',
        documentType: 'menuConfig',
        title: 'B',
      ),
    ];
    final dataSource = _FakeDataSource({'menuConfig': docs});
    final deskVM = DeskViewModel(
      dataSource: dataSource,
      documentTypes: const [],
    );
    GetIt.I.registerSingleton<DeskViewModel>(deskVM);

    await deskVM.documentsContainer('menuConfig').future;

    final ctx = GetItDeskContext();
    expect(ctx.documents('menuConfig').value, equals(docs));
  });

  test('documents() flattens loading/error states to an empty list', () {
    final dataSource = _FakeDataSource(const {});
    final deskVM = DeskViewModel(
      dataSource: dataSource,
      documentTypes: const [],
    );
    GetIt.I.registerSingleton<DeskViewModel>(deskVM);

    final ctx = GetItDeskContext();
    expect(ctx.documents('menuConfig').value, isEmpty);
  });
}
