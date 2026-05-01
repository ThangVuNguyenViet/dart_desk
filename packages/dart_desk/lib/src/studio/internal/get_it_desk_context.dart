import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';

import '../core/view_models/desk_document_view_model.dart';
import '../core/view_models/desk_view_model.dart';

/// Default [DeskContext] used by [DeskForm] when evaluating field
/// conditions and by document preview builders. Resolves [document] from
/// the registered [DeskDocumentViewModel], [documents] from
/// [DeskViewModel.documentsContainer] (flattened to a plain list), and
/// [read] from the global GetIt container.
///
/// Internal to dart_desk: not exported from `package:dart_desk/dart_desk.dart`.
/// Consumers should depend only on the abstract [DeskContext].
class GetItDeskContext extends DeskContext {
  GetItDeskContext();

  /// Per–document-type [Computed] signal exposing the loaded documents as a
  /// plain `List<DeskDocument>`. Loading and error states flatten to an
  /// empty list. Memoized so repeated calls return the same listenable.
  late final _documents =
      SignalContainer<
        List<DeskDocument>,
        String,
        FlutterComputed<List<DeskDocument>>
      >((documentType) {
        final source = GetIt.I<DeskViewModel>().documentsContainer(
          documentType,
        );
        return computed<List<DeskDocument>>(
          () => source.value.map(
            data: (list) => list.documents,
            loading: () => const <DeskDocument>[],
            error: (_, _) => const <DeskDocument>[],
          ),
          debugLabel: 'documents($documentType)',
        );
      }, cache: true);

  @override
  DeskDocument? get document =>
      GetIt.I<DeskDocumentViewModel>().selectedDocument.value.value;

  @override
  ValueListenable<List<DeskDocument>> documents(String documentType) =>
      _documents(documentType);

  @override
  T read<T extends Object>() => GetIt.I<T>();
}
