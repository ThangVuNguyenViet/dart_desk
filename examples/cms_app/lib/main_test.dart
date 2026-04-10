import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:marionette_flutter/marionette_flutter.dart';

void main() {
  if (kDebugMode) {
    // MarionetteBinding.ensureInitialized(CmsMarionetteConfig.configuration);
    FakeImagePickerPlatform.install();
    FakeFilePickerPlatform.install();
  }

  runApp(
    DartDeskApp.withDataSource(
      dataSource: MockDataSource(),
      onSignOut: () {},
      config: DartDeskConfig(
        documentTypes: [allFieldsDocumentType],
        documentTypeDecorations: [
          DocumentTypeDecoration(
            documentType: allFieldsDocumentType,
            icon: Icons.science,
          ),
        ],
        title: 'CMS QA Test',
        subtitle: 'Test Automation',
        icon: Icons.bug_report,
      ),
    ),
  );
}
