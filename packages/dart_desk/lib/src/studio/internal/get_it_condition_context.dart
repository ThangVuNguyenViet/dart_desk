import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:get_it/get_it.dart';

import '../core/view_models/desk_document_view_model.dart';

/// Default [DeskConditionContext] used by [DeskForm] when evaluating field
/// conditions. Resolves [document] from the registered
/// [DeskDocumentViewModel] and [read] from the global GetIt container.
///
/// Internal to dart_desk: not exported from `package:dart_desk/dart_desk.dart`.
/// Consumers should depend only on the abstract [DeskConditionContext].
class GetItConditionContext extends DeskConditionContext {
  const GetItConditionContext();

  @override
  DeskDocument? get document =>
      GetIt.I<DeskDocumentViewModel>().selectedDocument.value.value;

  @override
  T read<T extends Object>() => GetIt.I<T>();
}
