# desk_app — runnable studio showcase

A working Flutter app that boots `DartDeskApp` against a hosted Dart Desk Cloud project, with all 16 field annotations exercised across 6 document types.

> ⚠️ **Rapid development.** See the main [dart_desk README](../../packages/dart_desk) and open issues at
> [github.com/ThangVuNguyenViet/dart_desk/issues](https://github.com/ThangVuNguyenViet/dart_desk/issues).

## What it shows

- 6 wired document types: `Home`, `Kiosk`, `Chef`, `Menu`, `Rewards`, `BrandTheme`.
- All 16 `@Desk*` field annotations covered across those types.
- `DocumentTypeDecoration` icons in the sidebar.
- `CloudDataSource` wiring against a hosted backend (override via env to self-host).

## Entrypoints

| File | Purpose | Deployed URL |
|------|---------|-------------|
| `lib/main_memory.dart` | In-memory `MockDataSource`, no auth, fully sandboxed per visitor | `https://dartdesk-demo.app.dartdesk.dev` |
| `lib/main_cloud.dart` | Serverpod IDP auth + cloud backend, requires `--dart-define SERVER_URL=...` and `--dart-define API_KEY=...` | `https://dartdesk-demo-cloud.app.dartdesk.dev` |

## Run

```bash
flutter run --target lib/main_memory.dart
```

Run the cloud variant against a self-hosted backend:

```bash
flutter run \
  --target lib/main_cloud.dart \
  --dart-define=SERVER_URL=https://your-host/ \
  --dart-define=API_KEY=your-api-key
```

## Where to look

| File | What's there |
|------|--------------|
| `lib/main_memory.dart` | In-memory entrypoint — `MockDataSource`, no auth |
| `lib/main_cloud.dart` | Cloud entrypoint — builds `Client`, wraps it in `CloudDataSource`, calls `buildDeskApp` |
| `lib/bootstrap.dart` | `DartDeskConfig` — document types, decorations, title, icon |
| `lib/document_types.dart` | The 6 `DocumentTypeSpec.build(...)` calls with their preview builders |

The schemas themselves live in [`examples/data_models`](../data_models).
