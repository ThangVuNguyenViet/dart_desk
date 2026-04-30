import 'package:dart_desk/src/extensions/awaitable_future_signal.dart';
import 'package:dart_desk/src/studio/components/forms/desk_form.dart';
import 'package:dart_desk/src/studio/core/view_models/desk_document_view_model.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// A condition that shows the field only when the document is NOT the default.
class _HideOnDefault extends DeskCondition {
  const _HideOnDefault();

  @override
  bool evaluate(DeskConditionContext ctx) => ctx.document?.isDefault != true;
}

/// A [DeskStringOption] subclass that overrides [condition] to return a
/// fixed [DeskCondition].
///
/// [DeskStringOption] does not expose [condition] in its constructor (it only
/// forwards [optional] and [hidden] to [DeskOption]). We override the getter
/// here so the field carries the gating condition without modifying production
/// code.
class _ConditionStringOption extends DeskStringOption {
  final DeskCondition _cond;
  const _ConditionStringOption(this._cond);

  @override
  DeskCondition? get condition => _cond;
}

/// Fake view model that returns a fixed [DeskDocument] from [selectedDocument].
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

/// Registers a fake [DeskDocumentViewModel] for [doc] in GetIt and waits for
/// [selectedDocument] to resolve so [GetItConditionContext.document] is
/// populated before the widget tree is pumped.
Future<void> _registerVm(DeskDocument? doc) async {
  if (GetIt.I.isRegistered<DeskDocumentViewModel>()) {
    await GetIt.I.unregister<DeskDocumentViewModel>();
  }
  final vm = _FakeViewModel(doc);
  GetIt.I.registerSingleton<DeskDocumentViewModel>(vm);
  await vm.selectedDocument.future;
}

/// The field under test — a string field gated by [_HideOnDefault].
DeskStringField _gatedField() => DeskStringField(
      name: 'deviceOverrideGroups',
      title: 'Device override groups',
      option: _ConditionStringOption(const _HideOnDefault()),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  tearDown(() async {
    if (GetIt.I.isRegistered<DeskDocumentViewModel>()) {
      await GetIt.I.unregister<DeskDocumentViewModel>();
    }
  });

  testWidgets('DeskForm hides field when condition.evaluate returns false',
      (tester) async {
    // isDefault = true → _HideOnDefault returns false → field hidden
    await _registerVm(
      DeskDocument(
        clientId: 'c',
        documentType: 'menuConfig',
        title: 'Default',
        isDefault: true,
      ),
    );

    await tester.pumpWidget(
      ShadApp(
        home: Scaffold(
          body: DeskForm(
            data: const {},
            fields: [_gatedField()],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Device override groups'), findsNothing);
  });

  testWidgets('DeskForm shows field when condition.evaluate returns true',
      (tester) async {
    // isDefault = false → _HideOnDefault returns true → field visible
    await _registerVm(
      DeskDocument(
        clientId: 'c',
        documentType: 'menuConfig',
        title: 'Override',
        isDefault: false,
      ),
    );

    await tester.pumpWidget(
      ShadApp(
        home: Scaffold(
          body: DeskForm(
            data: const {},
            fields: [_gatedField()],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Device override groups'), findsOneWidget);
  });
}
