# desk_app — runnable studio showcase

A working Flutter app that boots `DartDeskApp` against a hosted Dart Desk Cloud project, with all 16 field annotations exercised across 6 document types.

> ⚠️ **Rapid development.** See the main [dart_desk README](../../packages/dart_desk) and open issues at
> [github.com/ThangVuNguyenViet/dart_desk/issues](https://github.com/ThangVuNguyenViet/dart_desk/issues).

## What it shows

- 6 wired document types: `Home`, `Kiosk`, `Chef`, `Menu`, `Rewards`, `BrandTheme`.
- All 16 `@Desk*` field annotations covered across those types.
- `DocumentTypeDecoration` icons in the sidebar.
- `CloudDataSource` wiring against a hosted backend (override via env to self-host).

## Run

```bash
flutter run
```

Override the backend for self-hosting:

```bash
flutter run \
  --dart-define=SERVER_URL=https://your-host/ \
  --dart-define=API_KEY=your-api-key
```

## Where to look

| File | What's there |
|------|--------------|
| `lib/main.dart` | Entrypoint — builds `Client`, wraps it in `CloudDataSource`, calls `buildDeskApp` |
| `lib/bootstrap.dart` | `DartDeskConfig` — document types, decorations, title, icon |
| `lib/document_types.dart` | The 6 `DocumentTypeSpec.build(...)` calls with their preview builders |

The schemas themselves live in [`examples/data_models`](../data_models).
