import 'package:disco/disco.dart';
import 'package:flutter/material.dart';

import '../../../dart_desk.dart';
import '../../../studio.dart';
import '../core/view_models/cms_document_view_model.dart';

class StudioProvider extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ProviderScope(
      providers: [documentViewModelProvider(dataSource)],
      child: ProviderScope(
        providers: [cmsViewModelProvider((dataSource, documentTypes))],
        child: child,
      ),
    );
  }
}

final documentViewModelProvider = Provider.withArgument(
  (context, DataSource dataSource) => CmsDocumentViewModel(dataSource),
);

final cmsViewModelProvider = Provider.withArgument(
  (context, (DataSource, List<DocumentType>) args) => CmsViewModel(
    dataSource: args.$1,
    documentViewModel: documentViewModelProvider.of(context),
    documentTypes: args.$2,
  ),
);
