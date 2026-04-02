# dart_desk

A structured content studio for Flutter.

## Cloud Quick Start

The fastest way to get a CMS running:

1. Sign up at [manage.dartdesk.dev](https://manage.dartdesk.dev)
2. Install the CLI:
   ```bash
   dart pub global activate dart_desk_cli
   ```
3. Create `dart_desk.yaml` in your project root:
   ```yaml
   project_id: your-project-id
   ```
4. Authenticate and deploy:
   ```bash
   dartdesk login && dartdesk deploy
   ```

Your studio is live. Editors can log in at your project URL immediately.

## Why dart_desk

dart_desk is a native Flutter widget library — deploy your CMS to desktop, mobile, or web and keep your entire stack in Dart. You define content types with annotations and dart_desk generates the editing UI from your schema. Deploy to Dart Desk Cloud in one command, or self-host with any backend you control.

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

## Architecture: Three-Package Pattern

Most dart_desk projects follow this structure:

```
data_models/    — annotated Dart classes, shared by CMS + consumer app
cms_app/        — DartDeskApp studio for editors
consumer_app/   — your production app, reads content via dart_desk_client
```

`data_models` is a plain Dart package with no Flutter dependency. Both `cms_app` and `consumer_app` depend on it, keeping your content schema the single source of truth.

## Installation

```yaml
dependencies:
  dart_desk: ^0.1.0
  dart_desk_annotation: ^0.1.0
  dart_desk_client: ^0.1.0  # for consumer apps

dev_dependencies:
  dart_desk_generator: ^0.1.0
  build_runner: ^2.13.1
```

## Self-Hosting

To run your own backend, pass `serverUrl` and `apiKey` to `DartDeskApp` and point it at a [dart_desk_be](https://github.com/ThangVuNguyenViet/dart_desk) Serverpod instance:

```dart
void main() => runApp(
  DartDeskApp(
    serverUrl: 'https://cms.example.com',
    apiKey: 'your-api-key',
    documentTypes: [blogPost, product, page],
    title: 'My CMS',
  ),
);
```

## Advanced Patterns

### DocumentTypeSpec.build with Default Merging

Use `DocumentTypeSpec.build` to supply a preview builder that merges incoming editor data with your type's default values. This ensures the preview never crashes on missing fields:

```dart
final docType = myTypeSpec.build(builder: (data) {
  final merged = {...MyType.defaultValue.toMap(), ...data};
  return MyPreview(config: MyTypeMapper.fromMap(merged));
});
```

### Custom Array Item Editors

For arrays whose items need a bespoke editing UI, subclass the array option and provide an `itemEditor` builder. See the `FeaturedItemsArrayOption` pattern in the example app for a reference implementation.

### Async Dropdown Options

When dropdown choices must be loaded from an API or database, subclass `CmsDropdownOption` and override the async variant:

```dart
class StatusDropdownOption extends CmsDropdownOption {
  @override
  Future<List<String>> loadChoices() => myApi.fetchStatuses();
}
```

### Consumer Runtime Fetching

In your production app, use `dart_desk_client` to fetch published content at runtime:

```dart
final client = DartDeskClient(projectId: 'your-project-id');
final posts = await client.getDocuments<BlogPost>(
  documentType: 'blog_post',
  mapper: BlogPostMapper.fromMap,
);
```

## Related Packages

| Package | Description |
|---------|-------------|
| [dart_desk_annotation](https://pub.dev/packages/dart_desk_annotation) | Schema annotations for defining document types and fields |
| [dart_desk_generator](https://pub.dev/packages/dart_desk_generator) | Code generator that produces `CmsDocumentType` definitions from annotated classes |
| [dart_desk_cli](https://pub.dev/packages/dart_desk_cli) | CLI for deploying CMS studios to Dart Desk Cloud |
| [dart_desk_client](https://pub.dev/packages/dart_desk_client) | Runtime client for fetching published content |

## License

BSD 3-Clause — see [LICENSE](LICENSE)
