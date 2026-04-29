# dart_desk monorepo

Monorepo for the dart_desk Flutter CMS. End users: see [`packages/dart_desk`](packages/dart_desk).

> ⚠️ **Rapid development.** APIs may shift between minor versions.
> Bug reports and feature requests are very welcome — please open an issue at
> [github.com/ThangVuNguyenViet/dart_desk/issues](https://github.com/ThangVuNguyenViet/dart_desk/issues).

## Repo layout

| Path | Description |
|------|-------------|
| `packages/dart_desk` | Main Flutter package — the studio (pub.dev landing) |
| `packages/dart_desk_annotation` | Field annotations and core model types |
| `packages/dart_desk_generator` | Code generator that reads `@DeskModel` classes |
| `examples/data_models` | Schema fixtures used by the showcases and tests |
| `examples/desk_app` | Runnable studio showcase |
| `examples/example_app` | Runnable consumer-app showcase |
| `docs/` | Specs and implementation plans |

## Working in the monorepo

This repo uses [melos](https://pub.dev/packages/melos) to manage the workspace.

```bash
# bootstrap all packages
dart pub global activate melos
melos bootstrap

# run analyzers
melos run analyze

# run all tests
melos run test

# regenerate code (build_runner) across the workspace
melos run build_runner
```

See [`melos.yaml`](melos.yaml) for the full script list.

## Running the examples

```bash
# studio showcase
cd examples/desk_app && flutter run

# consumer-app showcase
cd examples/example_app && flutter run
```

Both default to a hosted Dart Desk Cloud project. Override for self-host:

```bash
flutter run \
  --dart-define=SERVER_URL=https://your-host/ \
  --dart-define=API_KEY=your-api-key
```

## Related repos

- [`dart_desk_be`](https://github.com/ThangVuNguyenViet/dart_desk_be) — Serverpod backend
- [`dart_desk_cli`](https://github.com/ThangVuNguyenViet/dart_desk_cli) — CLI for Dart Desk Cloud
- [`dart_desk_cloud`](https://github.com/ThangVuNguyenViet/dart_desk_cloud) — managed hosting infrastructure
- [`dartdesk-landing`](https://github.com/ThangVuNguyenViet/dartdesk-landing) — landing site at [dartdesk.dev](https://dartdesk.dev)

## Contributing

Issues and pull requests welcome. The codebase moves quickly — if you're planning a non-trivial change, open an issue to discuss before sending a PR.

## License

BSD 3-Clause — see [LICENSE](LICENSE).
