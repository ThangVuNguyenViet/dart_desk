import 'package:dart_desk/src/extensions/awaitable_future_signal.dart';
import 'package:dart_desk/src/studio/core/view_models/desk_document_view_model.dart';
import 'package:dart_desk/src/studio/internal/get_it_condition_context.dart';
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

void main() {
  setUp(() async {
    if (GetIt.I.isRegistered<DeskDocumentViewModel>()) {
      await GetIt.I.unregister<DeskDocumentViewModel>();
    }
    if (GetIt.I.isRegistered<_FakeService>()) {
      await GetIt.I.unregister<_FakeService>();
    }
  });

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
    // Drain the signal so .value.value is populated.
    await vm.selectedDocument.future;

    const ctx = GetItConditionContext();
    expect(ctx.document, equals(doc));
    expect(ctx.document?.isDefault, isTrue);
  });

  test('document is null when no document is selected', () async {
    final vm = _FakeViewModel(null);
    GetIt.I.registerSingleton<DeskDocumentViewModel>(vm);
    await vm.selectedDocument.future;

    const ctx = GetItConditionContext();
    expect(ctx.document, isNull);
  });

  test('read<T>() resolves a registered service', () {
    GetIt.I.registerSingleton<_FakeService>(_FakeService('hello'));
    // No DeskDocumentViewModel needed for this assertion.
    const ctx = GetItConditionContext();
    expect(ctx.read<_FakeService>().tag, 'hello');
  });

  test('read<T>() throws when service is not registered', () {
    const ctx = GetItConditionContext();
    expect(() => ctx.read<_FakeService>(), throwsA(anything));
  });
}
