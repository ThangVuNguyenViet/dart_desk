import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../dart_desk.dart';
import '../../../studio.dart';
import '../core/view_models/cms_document_view_model.dart';

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
    final docVM = CmsDocumentViewModel(widget.dataSource);
    final cmsVM = CmsViewModel(
      dataSource: widget.dataSource,
      documentTypes: widget.documentTypes,
    );
    GetIt.I.registerSingleton<CmsDocumentViewModel>(docVM);
    GetIt.I.registerSingleton<CmsViewModel>(cmsVM);
    docVM.listenTo(cmsVM);
  }

  @override
  void dispose() {
    GetIt.I<CmsViewModel>().dispose();
    GetIt.I<CmsDocumentViewModel>().dispose();

    GetIt.I.unregister<CmsViewModel>();
    GetIt.I.unregister<CmsDocumentViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
