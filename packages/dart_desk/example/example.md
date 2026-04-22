# dart_desk Example

## Cloud-First Setup

The quickest path from zero to a running CMS:

### 1. Sign up

Create an account at [manage.dartdesk.dev](https://manage.dartdesk.dev). You'll get a `project_id` after creating your first project.

### 2. Install the CLI

```bash
dart pub global activate dart_desk_cli
```

### 3. Add your project config

Create `dart_desk.yaml` in your repository root:

```yaml
project_id: your-project-id
```

### 4. Deploy

```bash
dartdesk login
dartdesk deploy
```

Your studio is live at your project URL. Editors can sign in immediately.

---

## Example App

The repository includes a complete working example split across three packages:

- [data_models](https://github.com/ThangVuNguyenViet/dart_desk/tree/main/examples/data_models) — annotated content models and generated `DeskDocumentType` definitions
- [desk_app](https://github.com/ThangVuNguyenViet/dart_desk/tree/main/examples/desk_app) — the DartDeskApp studio wired to the example document types
- [example_app](https://github.com/ThangVuNguyenViet/dart_desk/tree/main/examples/example_app) — a consumer Flutter app that reads published content via `dart_desk_client`

### Document Types in the Example

| Document Type | Description |
|---|---|
| Home Screen | Hero section, featured items, promo banner, layout config |
| App Navigation | Nested nav items array, nav style dropdown, colors |
| Content Page | Title, slug, body, SEO fields, publish status, scheduling |
| Announcement Banner | Time-bounded banner with priority, colors, CTA |
| App Branding | 4 brand colors, 3 logo variants, theme mode |

See [document_types.dart](https://github.com/ThangVuNguyenViet/dart_desk/blob/main/examples/desk_app/lib/document_types.dart) for how each type is wired into the studio, and [data_models/lib/src/configs](https://github.com/ThangVuNguyenViet/dart_desk/tree/main/examples/data_models/lib/src/configs) for the annotated schema classes.

### Running the Example Locally

```bash
cd examples/desk_app
flutter run
```

Or deploy it to Dart Desk Cloud:

```bash
dartdesk deploy --project examples/desk_app
```
