import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../dart_desk.dart';
import '../../../studio.dart';
import '../core/view_models/desk_document_view_model.dart';

class StudioProvider extends StatefulWidget {
  const StudioProvider({
    super.key,
    required this.child,
    required this.dataSource,
    required this.documentTypes,
  });

  final Widget child;
  final DataSource dataSource;
  final List<DocumentType> documentTypes;

  @override
  State<StudioProvider> createState() => _StudioProviderState();
}

class _StudioProviderState extends State<StudioProvider> {
  @override
  void initState() {
    super.initState();
    final docVM = DeskDocumentViewModel(widget.dataSource);
    final deskVM = DeskViewModel(
      dataSource: widget.dataSource,
      documentTypes: widget.documentTypes,
    );
    GetIt.I.registerSingleton<DeskDocumentViewModel>(docVM);
    GetIt.I.registerSingleton<DeskViewModel>(deskVM);
    docVM.listenTo(deskVM);
  }

  @override
  void dispose() {
    GetIt.I<DeskViewModel>().dispose();
    GetIt.I<DeskDocumentViewModel>().dispose();

    GetIt.I.unregister<DeskViewModel>();
    GetIt.I.unregister<DeskDocumentViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
