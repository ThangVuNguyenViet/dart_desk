import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cms/studio.dart';
import 'package:flutter_cms/testing.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(CmsMarionetteConfig.configuration);
  }
  runApp(CmsStudioApp(
    dataSource: MockCmsDataSource(),
    documentTypes: [allFieldsDocumentType],
    documentTypeDecorations: [
      CmsDocumentTypeDecoration(
        documentType: allFieldsDocumentType,
        icon: Icons.science,
      ),
    ],
    title: 'CMS QA Test',
    subtitle: 'Test Automation',
    icon: Icons.bug_report,
  ));
}
