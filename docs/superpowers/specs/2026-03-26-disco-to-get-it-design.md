# Replace disco with get_it for dependency injection

## Goal

Replace the `disco` package with `get_it: ^9.2.1` as a pure service locator. No widget-tree scoping needed.

## Current State

- `disco` is used in a single file: `studio_provider.dart`
- Two providers: `documentViewModelProvider` (CmsDocumentViewModel) and `cmsViewModelProvider` (CmsViewModel)
- `cmsViewModelProvider` depends on `documentViewModelProvider`
- ~15 consumer files access providers via `.of(context)` pattern
- 2 test files reference the providers directly

## Design

### Registration (StudioProvider widget)

`StudioProvider` becomes a `StatefulWidget` that:
- In `initState`: registers `CmsDocumentViewModel` and `CmsViewModel` as singletons in `GetIt.I`
- In `dispose`: unregisters both
- `build` returns `child` directly (no `ProviderScope` wrapping)

```dart
class StudioProvider extends StatefulWidget {
  const StudioProvider({
    super.key,
    required this.child,
    required this.dataSource,
    required this.documentTypes,
  });

  final Widget child;
  final DataSource dataSource;
  final List<DocumentType> documentTypes;

  @override
  State<StudioProvider> createState() => _StudioProviderState();
}

class _StudioProviderState extends State<StudioProvider> {
  @override
  void initState() {
    super.initState();
    final docVM = CmsDocumentViewModel(widget.dataSource);
    GetIt.I.registerSingleton<CmsDocumentViewModel>(docVM);
    GetIt.I.registerSingleton<CmsViewModel>(
      CmsViewModel(
        dataSource: widget.dataSource,
        documentTypes: widget.documentTypes,
        documentViewModel: docVM,
      ),
    );
  }

  @override
  void dispose() {
    GetIt.I.unregister<CmsViewModel>();
    GetIt.I.unregister<CmsDocumentViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
```

### Consumer migration

Mechanical replacement across all consumer files:

| Before | After |
|--------|-------|
| `cmsViewModelProvider.of(context)` | `GetIt.I<CmsViewModel>()` |
| `documentViewModelProvider.of(context)` | `GetIt.I<CmsDocumentViewModel>()` |

Import changes: remove `disco` imports, add `import 'package:get_it/get_it.dart';`

### Removals

- Delete `documentViewModelProvider` and `cmsViewModelProvider` globals from `studio_provider.dart`
- Remove `disco: ^1.0.3+1` from `pubspec.yaml`
- Remove `import 'package:disco/disco.dart';`

### pubspec.yaml changes

- Remove: `disco: ^1.0.3+1`
- Add: `get_it: ^9.2.1`

## Files to modify

1. `packages/dart_desk/pubspec.yaml` — swap dependency
2. `packages/dart_desk/lib/src/studio/providers/studio_provider.dart` — full rewrite
3. Consumer files (mechanical find/replace):
   - `lib/src/studio/routes/studio_layout.dart`
   - `lib/src/studio/screens/document_editor.dart`
   - `lib/src/studio/screens/document_list.dart`
   - `lib/src/studio/screens/cms_studio.dart`
   - `lib/src/studio/components/version/cms_version_history.dart`
   - `lib/src/studio/components/navigation/cms_document_type_sidebar.dart`
   - `lib/src/studio/components/forms/cms_form.dart`
   - `lib/src/testing/test_document_types.dart`
4. Test files:
   - `test/studio/editor_preview_widget_test.dart`
   - `test/studio/context_aware_dropdown_test.dart`

## Test impact

Tests that use `StudioProvider` as a wrapper widget continue working unchanged. Tests that directly call `documentViewModelProvider.of(context)` or `cmsViewModelProvider.of(context)` need the same mechanical replacement to `GetIt.I<T>()`.

After migration, run `dart pub get` and full test suite to verify.
