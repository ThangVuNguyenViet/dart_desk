# dart_desk

A structured content studio for Flutter. Define your content model as code, connect a data source, and get a real-time editing environment — schema-driven forms, document versioning, media management, and a full admin UI out of the box.

## Why dart_desk

Most CMS admin panels are web-only. dart_desk is a native Flutter widget library — embed it in your existing app, deploy to desktop, mobile, or web, and keep your entire stack in Dart.

You define content types with annotations. dart_desk generates the editing UI from your schema: the right input for every field type, validation rules enforced in the form, and a studio layout that organizes everything by document type.

```dart
CmsStudioApp(
  dataSource: myDataSource,
  documentTypes: [blogPost, product, page],
  documentTypeDecorations: [
    CmsDocumentTypeDecoration(documentType: blogPost, icon: Icons.article),
    CmsDocumentTypeDecoration(documentType: product, icon: Icons.shopping_bag),
    CmsDocumentTypeDecoration(documentType: page, icon: Icons.web),
  ],
  title: 'My CMS',
)
```

## Features

### Schema-Driven Content Modeling

Define your content structure as annotated Dart classes. Schemas live in your codebase — version controlled, type-safe, and deployed with your CI.

```dart
@CmsConfig(title: 'Blog Post', description: 'A blog article')
class BlogPost {
  @CmsStringField(label: 'Title', validators: [RequiredValidator()])
  final String title;

  @CmsTextField(label: 'Body', options: CmsTextOption(rows: 10))
  final String body;

  @CmsImageField(label: 'Cover', options: CmsImageOption(hotspot: true))
  final String? coverImage;

  @CmsDropdownField(label: 'Status', options: CmsDropdownOption(choices: ['draft', 'review', 'published']))
  final String status;
}
```

Run `dart run build_runner build` to generate `CmsDocumentType` definitions from your schema.

### 16 Built-In Field Types

Every field type gets a purpose-built input widget with validation, labels, and error states:

| Primitives | Complex | Media |
|---|---|---|
| String | Array | Image (with hotspot/crop) |
| Text (multiline) | Object (nested fields) | File upload |
| Number | Block (portable content) | Color picker |
| Boolean | Dropdown (select) | |
| Checkbox | Geopoint | |
| Date | | |
| Datetime | | |
| URL | | |

### Rich Text as Structured Data

Rich text content is stored as structured data — not opaque HTML blobs — so you can query, transform, and render it in any format.

### Document Management

- **Create, edit, delete** documents with search and pagination
- **Sidebar navigation** organized by document type with icons and labels
- **Deep-linkable routes** — every document type, document, and version has its own URL
- **Slug generation** with automatic uniqueness enforcement

### Version History & Publishing

Track every change to a document over time. Snapshot versions, compare states, publish or archive — all from the editing interface.

- **Version snapshots** — capture the document state at any point
- **Publish/archive workflow** — move versions through draft → published → archived

### Media Management

Upload, preview, and manage images and files directly from the studio. Image fields support hotspot selection for art-directed cropping.

### Backend-Agnostic

dart_desk doesn't prescribe your backend. Implement the `CmsDataSource` interface to connect any data layer:

```dart
abstract class CmsDataSource {
  Future<DocumentList> getDocuments(String documentType, { ... });
  Future<CmsDocument> createDocument(String documentType, String title, Map<String, dynamic> data, { ... });
  Future<CmsDocument> updateDocumentData(int documentId, Map<String, dynamic> updates, { ... });
  Future<MediaUploadResult> uploadImage(String fileName, Uint8List fileData);
  // ... documents, versions, and media operations
}
```

Works with REST APIs, GraphQL, Serverpod, local databases, or anything else you can call from Dart.

### Studio Layout & Theming

A complete admin interface with:

- **Document type sidebar** — navigate between content types
- **Breadcrumb navigation** — always know where you are
- **Dark/light theme toggle** — built-in CMS themes, or bring your own `ShadThemeData`
- **Responsive layout** with resizable panels

Built on [shadcn_ui](https://pub.dev/packages/shadcn_ui) for a polished, consistent look.

### Reactive State

All UI state is powered by [signals](https://pub.dev/packages/signals) — fine-grained reactivity with no unnecessary rebuilds. Form state, document data, and navigation all update efficiently.

## Installation

```yaml
dependencies:
  dart_desk: ^0.1.0
  dart_desk_annotation: ^0.1.0

dev_dependencies:
  dart_desk_generator: ^0.1.0
  build_runner: ^2.13.1
```

## Quick Start

### 1. Define your schema

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

@CmsConfig(title: 'Page', description: 'A website page')
class Page {
  @CmsStringField(label: 'Title', validators: [RequiredValidator()])
  final String title;

  @CmsTextField(label: 'Content')
  final String content;

  @CmsBooleanField(label: 'Published')
  final bool published;
}
```

### 2. Generate document types

```bash
dart run build_runner build
```

### 3. Implement your data source

```dart
class MyDataSource implements CmsDataSource {
  // Connect to your API, database, or backend of choice
  // See CmsDataSource for the full interface
}
```

### 4. Launch the studio

```dart
void main() => runApp(
  CmsStudioApp(
    dataSource: MyDataSource(),
    documentTypes: [pageDocumentType],
    documentTypeDecorations: [
      CmsDocumentTypeDecoration(documentType: pageDocumentType, icon: Icons.web),
    ],
    title: 'My CMS',
  ),
);
```

## Architecture

```
dart_desk
├── dart_desk.dart       # Annotations, data layer, input widgets, CmsStudioApp
├── studio.dart          # Studio internals — screens, routes, components, theme, view models
└── testing.dart         # Test utilities and mock data sources
```

- `import 'package:dart_desk/dart_desk.dart'` — Standard usage
- `import 'package:dart_desk/studio.dart'` — Lower-level access for customizing screens, routes, or theme

## Related Packages

| Package | Description |
|---------|-------------|
| [dart_desk_annotation](https://pub.dev/packages/dart_desk_annotation) | Schema annotations for defining document types and fields |
| [dart_desk_generator](https://pub.dev/packages/dart_desk_generator) | Code generator that produces `CmsDocumentType` definitions from annotated classes |

## License

MIT — see [LICENSE](LICENSE)
