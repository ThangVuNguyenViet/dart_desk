import 'package:disco/disco.dart';
import 'package:flutter/material.dart';

import '../../../flutter_cms.dart';
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
  final CmsDataSource dataSource;
  final List<CmsDocumentType> documentTypes;

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
  (context, CmsDataSource dataSource) => CmsDocumentViewModel(dataSource),
);

final cmsViewModelProvider = Provider.withArgument(
  (context, (CmsDataSource, List<CmsDocumentType>) args) => CmsViewModel(
    dataSource: args.$1,
    documentViewModel: documentViewModelProvider.of(context),
    documentTypes: args.$2,
  ),
);
