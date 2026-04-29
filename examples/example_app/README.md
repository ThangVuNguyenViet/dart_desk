# example_app — runnable consumer-app showcase

A pure consumer Flutter app — no studio widgets — that reads published content from dart_desk and renders one screen per document type.

> ⚠️ **Rapid development.** See the main [dart_desk README](../../packages/dart_desk) and open issues at
> [github.com/ThangVuNguyenViet/dart_desk/issues](https://github.com/ThangVuNguyenViet/dart_desk/issues).

## What it shows

- Reading published content via `client.publicContent.getDefaultContents()`.
- Decoding `PublicDocument.data` (JSON string) into your data models with [`dart_mappable`](https://pub.dev/packages/dart_mappable).
- One screen per document type from [`examples/data_models`](../data_models): home, kiosk, chef, menu, rewards, brand theme.

This is the pattern any production app would follow when consuming content authored in the [studio showcase](../desk_app).

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
| `lib/main.dart` | Entrypoint — builds the `Client` and `CloudPublicContentSource` |
| `lib/bootstrap.dart` | App composition |
| `lib/screens/` | One screen per document type — each fetches + decodes + renders |
