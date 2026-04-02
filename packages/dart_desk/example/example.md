# dart_desk Example

See the full example CMS app in the repository:

- [CMS App Example](https://github.com/ThangVuNguyenViet/dart_desk/tree/main/examples/cms_app) — A complete CMS studio built with dart_desk
- [Data Models Example](https://github.com/ThangVuNguyenViet/dart_desk/tree/main/examples/data_models) — Annotated content models with code generation

## Quick Start

```dart
import 'package:dart_desk/dart_desk.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  CmsStudioApp(
    dataSource: myDataSource,
    documentTypes: [blogPost, product],
    documentTypeDecorations: [
      CmsDocumentTypeDecoration(documentType: blogPost, icon: Icons.article),
      CmsDocumentTypeDecoration(documentType: product, icon: Icons.shopping_bag),
    ],
    title: 'My CMS',
  ),
);
```
