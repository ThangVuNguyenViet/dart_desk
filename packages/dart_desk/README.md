# dart_desk

A Flutter widget library for building CMS studio interfaces. Provides a complete content management studio UI with document management, input widgets for all field types, and reactive state management.

## Features

- Complete CMS studio layout with sidebar navigation and document management screens
- Input widgets for all common CMS field types: string, text, number, boolean, date, datetime, image, file, URL, color, dropdown, checkbox, geopoint, array, object, and block
- Reactive state management powered by [signals](https://pub.dev/packages/signals)
- Professional rich-text editing via [super_editor](https://pub.dev/packages/super_editor)
- UI components from [shadcn_ui](https://pub.dev/packages/shadcn_ui)
- Authentication flow and cloud data source integration
- Version history support for documents
- Theme toggle and customizable branding

## Installation

Add `dart_desk` to your `pubspec.yaml`:

```yaml
dependencies:
  dart_desk: ^0.1.0
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:dart_desk/studio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      theme: cmsStudioTheme,
      home: CmsStudioApp(
        dataSource: myDataSource,
        documentTypes: [myDocumentType],
        documentTypeDecorations: [
          CmsDocumentTypeDecoration(
            documentType: myDocumentType,
            icon: Icons.article,
          ),
        ],
        title: 'My CMS',
        subtitle: 'Content Management',
        icon: Icons.dashboard,
      ),
    );
  }
}
```

## Related Packages

- [dart_desk_annotation](https://pub.dev/packages/dart_desk_annotation) — Annotations for defining CMS document types and fields
- [dart_desk_generator](https://pub.dev/packages/dart_desk_generator) — Code generator that produces `DocumentType` definitions from annotated classes

## License

MIT — see [LICENSE](LICENSE)
