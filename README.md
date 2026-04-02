# dart_desk

A Flutter package for building embedded CMS studio interfaces. Define your content types in Dart, drop in the studio widget, and your editors get a fully featured content management UI — complete with rich text editing, media management, document versioning, and live preview.

---

## Features

- **Annotation-driven schema** — annotate plain Dart classes with `@CmsConfig` and field configs; the code generator produces the CMS schema automatically.
- **15+ input widgets** — text, rich text (Markdown), numbers, URLs, booleans, dates, dropdowns (single and multi), colors, images, files, geopoints, nested objects, and repeatable arrays.
- **Image management** — upload from device or URL, drag-and-drop, focal point (hotspot) editor, crop framing, BlurHash placeholder, and a full media browser.
- **Document versioning** — draft/published/archived/scheduled statuses with CRDT-backed partial updates and a version history panel.
- **Live preview** — render any Flutter widget alongside the editor form; updates reactively as the editor types.
- **Responsive layout** — mobile, tablet, and desktop breakpoints via `responsive_framework`.
- **Themeable** — light/dark mode toggle persisted across sessions; full `ShadThemeData` customisation via `shadcn_ui`.
- **BYO auth** — use Dart Desk Cloud (Serverpod IDP, Google + email/password) or supply your own `DataSource` with any auth provider.
- **Testing utilities** — `MockCmsDataSource`, `FakeImagePicker`, and `TestDocumentTypes` for widget tests.

---

## Platform support

| Platform | Support |
|---|---|
| macOS | ✅ |
| Web | ✅ |
| Windows | ✅ |
| Linux | ✅ |
| iOS | ✅ |
| Android | ✅ |

The package is designed primarily as a **desktop/web** CMS authoring tool. Mobile layouts are supported but secondary.

---

## Related packages

| Package | Purpose |
|---|---|
| [`dart_desk_annotation`](https://pub.dev/packages/dart_desk_annotation) | Field annotations and core model types — add to your data model package |
| [`dart_desk_generator`](https://pub.dev/packages/dart_desk_generator) | Code generator that reads `@CmsConfig` classes and emits `DocumentTypeSpec` instances |
| [`dart_desk_client`](https://pub.dev/packages/dart_desk_client) | Generated Serverpod client for Dart Desk Cloud (`CloudDataSource`) |

---

## Installation

```yaml
# pubspec.yaml
dependencies:
  dart_desk: ^0.1.1
  dart_desk_annotation: ^0.1.0

dev_dependencies:
  dart_desk_generator: ^0.1.0
  build_runner: ^2.0.0
```

---

## Quick start (Dart Desk Cloud)

### 1. Annotate your content model

```dart
// lib/src/storefront_config.dart
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'storefront_config.cms.g.dart';
part 'storefront_config.mapper.dart';

@CmsConfig(
  title: 'Storefront Config',
  description: 'Restaurant app home screen branding and display settings',
)
@MappableClass(
  includeCustomMappers: [ImageReferenceMapper()],
)
class StorefrontConfig
    with StorefrontConfigMappable, Serializable<StorefrontConfig> {
  @CmsStringFieldConfig(
    description: 'Name of the restaurant',
    option: CmsStringOption(),
  )
  final String restaurantName;

  @CmsImageFieldConfig(
    description: 'Full-width hero image',
    option: CmsImageOption(hotspot: true),
  )
  final ImageReference? heroImage;

  @CmsColorFieldConfig(
    description: 'Primary brand color',
    option: CmsColorOption(),
  )
  final Color primaryColor;

  const StorefrontConfig({
    required this.restaurantName,
    this.heroImage,
    required this.primaryColor,
  });
}
```

### 2. Run the generator

```bash
dart run build_runner build
```

This produces `storefront_config.cms.g.dart` containing a `storefrontConfigTypeSpec` constant.

### 3. Wire up the studio

```dart
// lib/main.dart
import 'package:dart_desk/studio.dart';
import 'package:flutter/material.dart';
import 'storefront_config.cms.g.dart'; // generated

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Build the DocumentType, attaching a live preview builder
    final storefrontType = storefrontConfigTypeSpec.build(
      builder: (data) {
        final config = StorefrontConfigMapper.fromMap(data);
        return StorefrontPreview(config: config); // your preview widget
      },
    );

    return DartDeskApp(
      serverUrl: 'https://your-project.dartdesk.dev/',
      apiKey: 'your-api-key',
      config: DartDeskConfig(
        documentTypes: [storefrontType],
        documentTypeDecorations: [
          DocumentTypeDecoration(
            documentType: storefrontType,
            icon: Icons.storefront,
          ),
        ],
        title: 'My App Studio',
        subtitle: 'Content Management',
        icon: Icons.edit_note,
      ),
    );
  }
}
```

---

## Custom `DataSource` (BYO backend / auth)

If you use Firebase, Clerk, Auth0, or your own backend, implement the `DataSource` interface and pass it directly:

```dart
class MyDataSource implements DataSource {
  // implement getDocuments, createDocument, uploadImage, etc.
}

return DartDeskApp.withDataSource(
  dataSource: MyDataSource(),
  onSignOut: () async { /* sign out from your auth provider */ },
  config: DartDeskConfig(
    documentTypes: [storefrontType],
    title: 'My Studio',
  ),
);
```

---

## Available field annotations

| Annotation | Input widget | Description |
|---|---|---|
| `@CmsStringFieldConfig` | Single-line text | Plain text, optional validation |
| `@CmsTextFieldConfig` | Multi-line textarea | Configurable row count |
| `@CmsBlockFieldConfig` | Rich text editor | Markdown serialization via `super_editor` |
| `@CmsNumberFieldConfig` | Number input | Integer or decimal |
| `@CmsUrlFieldConfig` | URL input | With URL validation |
| `@CmsBooleanFieldConfig` | Toggle switch | |
| `@CmsCheckboxFieldConfig` | Checkbox | |
| `@CmsDateFieldConfig` | Date picker | |
| `@CmsDateTimeFieldConfig` | Date + time picker | |
| `@CmsDropdownFieldConfig` | Single-select dropdown | |
| `@CmsMultiDropdownFieldConfig` | Multi-select dropdown | |
| `@CmsColorFieldConfig` | Color picker | Optional alpha channel |
| `@CmsImageFieldConfig` | Image upload / browser | Hotspot editor, drag-and-drop, BlurHash |
| `@CmsFileFieldConfig` | File upload | |
| `@CmsGeopointFieldConfig` | Lat/lng coordinate | |
| `@CmsObjectFieldConfig` | Inline nested object | |
| `@CmsArrayFieldConfig` | Repeatable list of items | |

---

## Media browser

The studio includes a full media browser accessible via `MediaBrowser`. It supports grid/list views, type filtering (image/video/all), search, drag-and-drop upload, and an asset detail panel showing usage counts.

Image fields include a **hotspot/crop editor** — editors click to set a focal point and define a crop rectangle so downstream apps can render images correctly regardless of aspect ratio.

---

## Document versioning

Every document supports multiple versions with these statuses:

| Status | Color |
|---|---|
| Draft | Yellow |
| Published | Green |
| Archived | Grey |
| Scheduled | Blue |

Partial data updates use CRDT operations so concurrent edits are conflict-free.

---

## Testing

```dart
import 'package:dart_desk/testing.dart';

final dataSource = MockCmsDataSource();
// pre-populated with TestDocumentTypes fixtures
// use FakeImagePicker to stub image selection in widget tests
```

---

## Example app

The repository includes a complete working example under [`examples/`](https://github.com/ThangVuNguyenViet/dart_desk/tree/main/examples):

- **`data_models/`** — annotated content models and generated type specs
- **`cms_app/`** — the `DartDeskApp` studio wired to 5 document types (Storefront, Menu Highlights, Promo Offers, App Theme, Delivery Settings)
- **`example_app/`** — consumer Flutter app that reads published content via `dart_desk_client`

```bash
cd examples/cms_app
flutter run
```

---

## Cloud deployment

```bash
# Install the CLI
dart pub global activate dart_desk_cli

# Authenticate and deploy
dartdesk login
dartdesk deploy
```

Sign up and create a project at [manage.dartdesk.dev](https://manage.dartdesk.dev).
