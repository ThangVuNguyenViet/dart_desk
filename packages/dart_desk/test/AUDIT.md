# Phase 4 Audit
Generated: 2026-04-28-1200. Categorizes each test file for the presence→golden migration in Phase 4b.

## Presence-only (migrate to flutter_test_goldens galleries)
- `inputs/file_input_test.dart` — 2 blocks; renders upload button label and title label (find.text only)
- `inputs/datetime_input_test.dart` — 5 blocks; renders formatted datetime, placeholder, dialog open/close — 2 presence blocks + 3 behavior; RECLASSIFY → mixed (see notes)
- `studio/document_screen_empty_state_test.dart` — 2 blocks; desktop renders empty state / editor via find.byType and find.text, no callbacks fired

## Behavior (keep as testWidgets, rebase fixtures onto data_models *Fixtures)
- `data/public_content_source_test.dart` — 1 block (unit test); interface implementability — pure `test()`, no widgets
- `data/models/media_asset_inline_json_test.dart` — 2 blocks (unit tests); JSON decode assertions — pure `test()`, no widgets
- `data/models/public_desk_document_test.dart` — 3 blocks (unit tests); equality, hashCode, value semantics — pure `test()`
- `extensions/object_extensions_test.dart` — 4 blocks (unit tests); `let`/`letOrNull` extension logic — pure `test()`
- `media/image_url_test.dart` — 7 blocks (unit tests); `ImageUrl.fromMap` and `.withTransform` — pure `test()`
- `inputs/hotspot/framing_math_test.dart` — 4 blocks (unit tests); `FramingMath` pure functions — pure `test()`
- `inputs/string_input_test.dart` — 4 blocks; onChanged callback assertion fires through text entry
- `inputs/checkbox_input_test.dart` — 4 blocks; onChanged fires on tap/label tap; hidden field
- `inputs/text_input_test.dart` — 4 blocks; onChanged fires on text entry; deprecated banner
- `inputs/number_input_test.dart` — 4 blocks; onChanged fires with parsed num/null
- `inputs/url_input_test.dart` — 4 blocks; onChanged fires for valid and invalid URLs
- `inputs/dropdown_input_test.dart` — 4 blocks; onChanged fires with selected value; dropdown opens on tap
- `inputs/geopoint_input_test.dart` — 4 blocks; onChanged fires with lat/lng or null when incomplete
- `inputs/boolean_input_test.dart` — 4 blocks; onChanged fires true→false and false→true
- `inputs/color_input_test.dart` — 5 blocks; onChanged fires on hex entry and dialog Select; dialog Cancel no-ops
- `inputs/date_input_test.dart` — 4 blocks; calendar popup opens; onChanged fires when date selected
- `inputs/multi_dropdown_input_test.dart` — 5 blocks; multi-select fires onChanged; deselection works; didUpdateWidget
- `inputs/array_input_test.dart` — 8+ blocks; Add+Save fires onChanged; drag-reorder, delete callbacks
- `inputs/object_input_test.dart` — 15+ blocks; nested onChanged propagation through column/row/tab layouts
- `inputs/image_input_test.dart` — 10+ blocks; upload, clear, hotspot, browse callbacks; mocktail MockDataSource
- `inputs/image_input_rebuild_test.dart` — 5 blocks; rebuild efficiency using ValueNotifier counter; mocktail
- `inputs/image_hotspot_editor_test.dart` — 4 blocks; cancel no callback; reset preserves crop; mode change callback
- `media/asset_delete_confirm_dialog_test.dart` — 4 blocks; Delete/Cancel pop true/false; in-use branch
- `media/media_browser_state_test.dart` — 10 blocks (unit tests); signal/async state machine, deleteAsset, confirmAndDelete
- `media/media_browser_sheet_test.dart` — 1 block; tap tile → AssetDetailPanel rendered; tile width unchanged
- `media/media_grid_hover_delete_test.dart` — 1 block; AnimatedOpacity transitions on mouse hover
- `cloud/dart_desk_auth_view_model_test.dart` — 5 blocks (unit tests); mocktail; auth state machine signals
- `cloud/cloud_public_content_source_test.dart` — 6+ blocks (unit tests); mocktail; `_toPublic` conversion
- `testing/fake_public_content_source_test.dart` — 8 blocks (unit tests); seed/seedDraft/CRUD behavior
- `testing/mock_data_source_test.dart` — 25+ blocks (unit tests); full CRUD, media, references
- `studio/document_save_publish_test.dart` — 15+ blocks; save/publish state machine; _HangingDataSource; toast assertions
- `studio/editor_preview_widget_test.dart` — 12+ blocks; editedData signal flows to preview builder; navigation
- `studio/context_aware_dropdown_test.dart` — 8+ blocks; context-aware options from DeskViewModel; multi-dropdown integration

## Mixed (block-level split required)
- `inputs/datetime_input_test.dart` — 5 blocks; first 2 are presence (renders formatted string, renders placeholder), last 3 are behavior (dialog open, Select fires callback, Cancel no callback) — split in Phase 4b
- `inputs/image_hotspot_editor_golden_test.dart` — 6 blocks; all blocks already use `matchesGoldenFile` (pre-existing golden test using raw `expectLater`); migrate to Gallery style in Phase 4b

## Summary
- Presence: 2 files (clean) / ~4 blocks; 1 file reclassified to Mixed
- Behavior: 30 files / ~180+ blocks
- Mixed: 2 files / 11 blocks total
- Total: 36 files (find returns 36 `*_test.dart` paths including subdirs)

## Notes
- **No file imports `test_document_types.dart`** — that fixture is gone/not used.
- **Pre-existing goldens**: `inputs/image_hotspot_editor_golden_test.dart` already uses raw `matchesGoldenFile`; it has a `goldens/` subdirectory with 6 baseline PNGs. Classified as Mixed since it needs Gallery-style migration in Phase 4b.
- **mocktail** usage: `cloud/dart_desk_auth_view_model_test.dart`, `cloud/cloud_public_content_source_test.dart`, `inputs/image_input_test.dart`, `inputs/image_input_rebuild_test.dart` — all behavior.
- **`datetime_input_test.dart`** was initially considered presence-only but has 3 blocks with callback assertions — split needed.
- Pilot chosen: `inputs/file_input_test.dart` — 2 presence-only blocks, zero callbacks, zero mocks, single simple widget.
