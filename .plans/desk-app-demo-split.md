# Split deployed `desk_app` demo into in-memory and cloud variants

## Goal

The current production demo at `https://dartdesk-demo.app.dartdesk.dev` is gated by a Serverpod IDP sign-in screen, which makes it useless as a public showcase. We want **two** deployed demos from the same `examples/desk_app` source:

1. **In-memory demo** — no auth, no backend, fully sandboxed per visitor. Becomes the new face of `dartdesk-demo`.
2. **Cloud demo** — keeps the existing Serverpod IDP auth gate and real cloud backend, deployed under a new project slug (assume `demo-cloud` — confirm with the user).

The two builds differ only in the entrypoint (`main_memory.dart` vs `main_cloud.dart`) and the `dart_desk.yaml` slug used at deploy time. Source is otherwise shared.

## Assumptions to verify before deploy succeeds

1. **Backend project `dart-desk/demo-cloud` is provisioned** on `api.dartdesk.dev` and the existing `DARTDESK_DEPLOY_TOKEN` has permission to deploy to it. **If not yet provisioned, the cloud-demo CI job will fail at the `dartdesk deploy` step** — that's expected and the in-memory job should still succeed independently. Don't gate the in-memory rollout on this.
2. The existing `DARTDESK_DEMO_API_KEY` secret can be reused for the cloud demo (it's the same auth backend, just a different deployment target). If the user wants a separate API key per demo, they'll add a `DARTDESK_DEMO_CLOUD_API_KEY` secret and we'll wire it in.

Do not attempt to provision the backend project or rotate secrets from this plan — surface those as TODOs for the user.

## Files to change

### 1. `examples/desk_app/lib/main_memory.dart` (NEW)

New entrypoint for the in-memory demo. Replaces the API-key gated `main.dart` for the `dartdesk-demo` deployment.

```dart
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:example/bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

Future<void> main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(DeskMarionetteConfig.configuration);
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  final dataSource = MockDataSource()..seedDefaults();
  runApp(
    DartDeskApp.withDataSource(
      dataSource: dataSource,
      onSignOut: () {},
      config: deskAppConfig,
    ),
  );
}
```

**Verify** that `package:dart_desk/testing.dart` exports `MockDataSource`. Grep:
```
grep -n "MockDataSource\|mock_desk_data_source" packages/dart_desk/lib/testing.dart
```
If it isn't exported, export it from `packages/dart_desk/lib/testing.dart` (add `export 'src/testing/mock_desk_data_source.dart';`). Do **not** import from `src/` in the example app.

### 2. `examples/desk_app/lib/main_cloud.dart` (NEW)

Move the **current** contents of `examples/desk_app/lib/main.dart` to `main_cloud.dart` verbatim. This becomes the entrypoint for the auth-gated cloud demo.

### 3. `examples/desk_app/lib/main.dart` (DELETE)

Delete after the two new entrypoints exist. Both CI jobs will reference an explicit `--target` so there's no ambiguity, and keeping `main.dart` around invites confusion about which is "the" entrypoint.

### 4. `examples/desk_app/dart_desk.yaml` (KEEP, in-memory keeps the `demo` slug)

No change — this file already declares `client_slug: dart-desk`, `project_slug: demo`. The in-memory build will deploy to the existing `dartdesk-demo` URL.

### 5. `examples/desk_app/dart_desk.cloud.yaml` (NEW)

```yaml
client_slug: dart-desk
project_slug: demo-cloud
server: https://api.dartdesk.dev
```

The cloud CI job will copy this over `dart_desk.yaml` immediately before invoking `dartdesk deploy`.

### 6. `.github/workflows/deploy-desk-app.yml` (REPLACE WITH TWO JOBS)

Split the single `deploy` job into two independent jobs (`deploy-memory` and `deploy-cloud`) running in parallel, both gated by the same trigger conditions. Use a single workflow file with two jobs (not two files) so they share the checkout matrix mentally.

Diff intent (write the actual file):

```yaml
name: deploy-desk-app

on:
  push:
    branches: [main]
    paths:
      - examples/desk_app/**
      - packages/dart_desk/**
  workflow_dispatch:

jobs:
  deploy-memory:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/cirruslabs/flutter:3.41.6
    steps:
      - uses: actions/checkout@v4
      - name: flutter pub get
        run: flutter --suppress-analytics pub get
        working-directory: packages/dart_desk
      - name: codegen (data_models)
        run: dart run build_runner build
        working-directory: examples/data_models
      - name: build web (in-memory)
        run: flutter build web --release --target lib/main_memory.dart
        working-directory: examples/desk_app
      - name: install dart_desk_cli
        run: |
          dart pub global activate --source git https://github.com/ThangVuNguyenViet/dart_desk_cli --git-ref main
          echo "$HOME/.pub-cache/bin" >> $GITHUB_PATH
      - name: deploy
        run: |
          dartdesk deploy \
            --skip-build \
            --token ${{ secrets.DARTDESK_DEPLOY_TOKEN }} \
            --commit ${{ github.sha }}
        working-directory: examples/desk_app
      - name: print live url
        run: echo "Deployed in-memory demo to https://dartdesk-demo.app.dartdesk.dev"

  deploy-cloud:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/cirruslabs/flutter:3.41.6
    steps:
      - uses: actions/checkout@v4
      - name: flutter pub get
        run: flutter --suppress-analytics pub get
        working-directory: packages/dart_desk
      - name: codegen (data_models)
        run: dart run build_runner build
        working-directory: examples/data_models
      - name: build web (cloud)
        run: |
          flutter build web --release \
            --target lib/main_cloud.dart \
            --dart-define SERVER_URL=https://api.dartdesk.dev \
            --dart-define API_KEY=${{ secrets.DARTDESK_DEMO_API_KEY }}
        working-directory: examples/desk_app
      - name: swap dart_desk.yaml to cloud variant
        run: cp dart_desk.cloud.yaml dart_desk.yaml
        working-directory: examples/desk_app
      - name: install dart_desk_cli
        run: |
          dart pub global activate --source git https://github.com/ThangVuNguyenViet/dart_desk_cli --git-ref main
          echo "$HOME/.pub-cache/bin" >> $GITHUB_PATH
      - name: deploy
        run: |
          dartdesk deploy \
            --skip-build \
            --token ${{ secrets.DARTDESK_DEPLOY_TOKEN }} \
            --commit ${{ github.sha }}
        working-directory: examples/desk_app
      - name: print live url
        run: echo "Deployed cloud demo to https://dartdesk-demo-cloud.app.dartdesk.dev"
```

Notes:
- `continue-on-error` is **not** set on `deploy-cloud` — if the backend project isn't provisioned yet, that job fails loudly. The in-memory job remains independent.
- The `swap dart_desk.yaml` step mutates the working tree inside the runner only. Do not `git commit` the swap.
- The exact cloud demo URL (`dartdesk-demo-cloud.app.dartdesk.dev`) is a guess based on the existing pattern (`<client_slug>-<project_slug>.app.dartdesk.dev` collapsed to `dartdesk-demo`). The actual URL will come from the `dartdesk deploy` response — adjust the echo line afterward if it differs.

### 7. `examples/desk_app/README.md` (UPDATE)

Add a short section documenting the two entrypoints:

- `lib/main_memory.dart` — in-memory `MockDataSource`, no auth, what `dartdesk-demo.app.dartdesk.dev` runs.
- `lib/main_cloud.dart` — Serverpod IDP auth + cloud backend, what `dartdesk-demo-cloud.app.dartdesk.dev` runs. Requires `--dart-define SERVER_URL=...` and `--dart-define API_KEY=...`.

Update the existing "Override the backend for self-hosting" snippet to point at `main_cloud.dart` via `--target`.

### 8. `examples/desk_app/integration_test/` (CHECK, ADJUST IF NEEDED)

Run:
```
grep -rn "main\.dart\|lib/main" examples/desk_app/integration_test examples/desk_app/test
```
If anything imports `package:example/main.dart` or references `lib/main.dart` as a target, point it at `main_cloud.dart` (the integration tests use the pre-authenticated client, per the existing `serverpod_auth_idp_flutter` dev_dependency comment in `pubspec.yaml`). If nothing references it, no change needed.

## Verify commands

Run from `examples/desk_app/`:

```bash
# 1. Both entrypoints compile.
flutter analyze
flutter build web --release --target lib/main_memory.dart
flutter build web --release \
  --target lib/main_cloud.dart \
  --dart-define SERVER_URL=https://api.dartdesk.dev \
  --dart-define API_KEY=dummy_key_for_build_only

# 2. Existing tests still pass.
flutter test

# 3. Workflow syntax is valid.
# (from repo root)
cd ../.. && yamllint .github/workflows/deploy-desk-app.yml || true
```

The two `flutter build web` commands MUST both succeed locally before this is merged. The build with the dummy API_KEY only validates compilation — the runtime auth flow is exercised via the existing integration tests, not here.

## Out of scope

- Provisioning `dart-desk/demo-cloud` on the backend (user's job).
- Rotating or splitting the `DARTDESK_DEMO_API_KEY` secret.
- Any change to the `MockDataSource` itself or its seed data — if the in-memory demo reveals gaps in `seedDefaults()`, that's a follow-up.
- Touching `examples/example_app` — the question was specifically about `desk_app` (the studio).

## Report back

After running verify commands, report:
- Both `flutter build web` invocations succeeded (yes/no, with stderr if no).
- Whether `MockDataSource` was already exported from `package:dart_desk/testing.dart` or had to be added.
- Whether anything in `integration_test/` had to be retargeted.
- The final list of files touched.
