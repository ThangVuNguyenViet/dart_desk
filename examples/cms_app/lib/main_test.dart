import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(CmsMarionetteConfig.configuration);

    // Register custom scroll extension for testing
    registerMarionetteExtension(
      name: 'scrollByKey',
      description: 'Scroll to make a widget with the given key visible',
      callback: (params) async {
        final keyValue = params['key'];
        if (keyValue == null) {
          return const MarionetteExtensionResult.invalidParams(
            'key is required',
          );
        }

        // Find the element with the key
        Element? targetElement;
        void findElement(Element element) {
          if (targetElement != null) return;
          final key = element.widget.key;
          if (key is ValueKey<String> && key.value == keyValue) {
            targetElement = element;
            return;
          }
          element.visitChildren(findElement);
        }

        WidgetsBinding.instance.rootElement?.visitChildren(findElement);

        if (targetElement == null) {
          return MarionetteExtensionResult.error(
            2,
            'Element with key "$keyValue" not found',
          );
        }

        // Use Scrollable.ensureVisible to scroll to the target
        await Scrollable.ensureVisible(
          targetElement!,
          duration: const Duration(milliseconds: 300),
          alignment: 0.5,
        );

        return MarionetteExtensionResult.success({'key': keyValue});
      },
    );
  }
  runApp(
    CmsStudioApp(
      dataSource: MockDataSource(),
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
  );
}
