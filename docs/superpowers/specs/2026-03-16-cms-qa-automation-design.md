# CMS QA Automation Test Plan - Design Spec

## Overview

Comprehensive QA automation for flutter_cms using Claude Code + Marionette MCP. Tests cover all CMS framework components: sidebar navigation, document CRUD, all 16 field input types, form save/discard, version history, panel layout, and error states.

## Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Goal | Comprehensive QA | Full coverage of all CMS components and field types |
| Field coverage | All 16 types via test fixture | Test document type in package exercises every input |
| Text input | Marionette `enter_text` | Custom fork already triggers `onChanged` |
| Data source | Mock `CmsDataSource` | Self-contained, no backend dependency |
| Test runner | Claude Code skill + Marionette MCP | AI-driven execution with structured specs |
| Artifacts location | `packages/flutter_cms/test_automation/` | Inside the package |
| Preview panel | Out of scope | Consumer-specific, not part of CMS framework |
| Approach | Modular skill + test case files | Run individual suites or full suite |
| Execution | Two-phase: discovery + replay | First run learns, subsequent runs replay JSON |

## Architecture

### File Structure

```
packages/flutter_cms/
├── lib/src/
│   └── testing/
│       ├── test_document_types.dart       # All-16-fields document type fixture
│       └── mock_cms_data_source.dart      # In-memory fake data source
│
├── test_automation/
│   ├── skill/
│   │   └── SKILL.md                       # Claude Code skill definition
│   ├── tests/
│   │   ├── 01_sidebar_navigation.md
│   │   ├── 02_document_crud.md
│   │   ├── 03_document_selection.md
│   │   ├── 04_field_types_basic.md
│   │   ├── 05_field_types_advanced.md
│   │   ├── 06_field_types_complex.md
│   │   ├── 07_form_save_discard.md
│   │   ├── 08_version_history.md
│   │   ├── 09_panel_layout.md
│   │   └── 10_error_states.md
│   ├── replays/                           # Auto-generated replay JSONs
│   ├── results/                           # gitignored
│   │   ├── screenshots/
│   │   └── reports/
│   └── README.md
```

### Components

#### 1. Test Document Type Fixture (`test_document_types.dart`)

A `CmsDocumentType` with all 16 field types for full coverage:

- **Primitive (8):** string, text, number, boolean, checkbox, URL, date, datetime
- **Media (3):** color, image, file
- **Complex (5):** dropdown, array, object, block, geopoint

Lives in `lib/src/testing/` so any package consumer can use it for their own testing.

#### 2. Mock CmsDataSource (`mock_cms_data_source.dart`)

In-memory implementation of `CmsDataSource`:

- Pre-seeded with 3 documents for the test document type
- Each document has 1-2 versions (draft + published)
- Known field values for deterministic assertions
- Supports all CRUD operations in memory
- Local slug generation (no network)
- Predictable auto-incrementing IDs
- CRDT-aware methods simplified: stores data directly per version (ignores HLC snapshots and CRDT merge semantics). `updateDocumentData()` replaces the version data map directly. `getDocumentVersionData()` returns the stored map without CRDT reconstruction.

#### 3. Claude Code Skill (`skill/SKILL.md`)

Defines the test execution workflow:

**Phase 1: Discovery Run**
1. Connect marionette to the running app's VM service URI
2. Read the requested test file(s) from `tests/`
3. Execute each test case step by step using marionette tools (tap, enter_text, scroll_to)
4. Use `get_interactive_elements` to verify expected state after each action
5. Take screenshots as evidence
6. Record PASS/FAIL with notes
7. On success, save the action sequence to a `.json` replay file in `replays/`
8. Reset app state between test files via hot restart (resets in-memory mock to initial seed state)
9. Write results report to `results/reports/`

**Phase 2: Replay Run**
1. Read the `.json` replay file
2. Execute marionette commands sequentially (tap, enter_text, scroll_to only)
3. Verify at checkpoints using `get_interactive_elements`
4. Faster, deterministic, no AI interpretation needed

**Replay invalidation:**
- If `.md` test file is newer than replay `.json` → re-run discovery
- User can force re-discovery with "re-discover test {number}"

#### 4. Test Case Files (`tests/*.md`)

Structured markdown specs with this format:

```markdown
# {Number} - {Feature Area}

## Prerequisites
- Required app state before tests run

## TC-{file}-{case}: {Title}
**Steps:**
1. Action using marionette tool language
2. Verify expected state

**Expected:**
- What get_interactive_elements should find
- UI state assertions
```

**Conventions:**
- Test case IDs: `TC-{file number}-{case number}` (e.g., TC-04-03)
- Each test case is independent where possible
- Steps use marionette action language (tap, enter_text, scroll_to)
- Expected results describe element text, types, and visibility

#### 5. Replay Files (`replays/*.json`)

Auto-generated during discovery runs:

```json
{
  "test_file": "02_document_crud.md",
  "recorded": "2026-03-16T10:30:00",
  "test_cases": [
    {
      "id": "TC-02-01",
      "title": "Create a new document",
      "actions": [
        {"action": "tap", "params": {"text": "+"}},
        {"action": "enter_text", "params": {"text": "Document title", "input": "My Test Document"}},
        {"action": "tap", "params": {"text": "Create"}}
      ],
      "verify": [
        {"action": "get_interactive_elements", "expect_text": ["My Test Document"]},
        {"action": "take_screenshots"}
      ]
    }
  ]
}
```

Only interaction commands are stored (tap, enter_text, scroll_to). Discovery commands (get_interactive_elements, take_screenshots) are excluded from actions but included in verify checkpoints.

## Test Coverage

| # | File | Scope | Est. Cases | Key Interactions |
|---|---|---|---|---|
| 01 | sidebar_navigation | Document type sidebar | 4 | Tap items, verify selection highlight/indicator |
| 02 | document_crud | Create, search, select, delete | 6 | Tap +, enter title/slug, Create, delete, search field |
| 03 | document_selection | Selection indicator, switching | 4 | Tap docs, verify check icon + highlight |
| 04 | field_types_basic | String, text, number, boolean, checkbox, URL | 6 | enter_text, tap toggles, verify values |
| 05 | field_types_advanced | Color, date, datetime, dropdown | 5 | Tap pickers, select options, verify values |
| 06 | field_types_complex | Array, object, block, geopoint | 5 | Tap Add, enter_text, nested forms |
| 07 | form_save_discard | Save, discard, unsaved changes, loading | 5 | Modify fields, tap Save/Discard, verify reset |
| 08 | version_history | Version list, switching, status display | 4 | Tap dropdown, select version, verify data loads |
| 09 | panel_layout | Panel separators, empty states, initial proportions | 3 | Verify panel presence and empty state messages |
| 10 | error_states | Empty doc list, no doc type selected, validation | 4 | Verify error/empty messages, trigger validation |

**Total: ~46 test cases across 10 files.**

## Marionette Limitations & Workarounds

| Limitation | Affected Tests | Workaround |
|---|---|---|
| No drag gesture support | Panel resize (09) | Descoped: verify panel presence and empty states only, skip drag-resize |
| Cannot interact with native OS dialogs | Image/file upload (05) | Test URL input and display/clear behavior only. Mock pre-populates image URLs. Skip native file picker flow. |
| Version status changes are programmatic | Version history (08) | Mock pre-seeds versions with different statuses. Test display and switching, not publish/archive actions. |

## State Reset Strategy

Between test files, the app is **hot-restarted** via `mcp__dart__hot_restart`. This:
- Resets all in-memory state in the mock data source back to initial seed
- Clears all ViewModel signals
- Returns the app to its initial route
- Ensures each test file starts from a clean, known state

## Out of Scope

- Content preview panel (consumer-specific rendering)
- Authentication flow (handled by `flutter_cms_be_client`, separate concern)
- Native file picker / image picker dialogs (OS-level, outside Flutter widget tree)
- Panel drag-resize interactions (Marionette lacks drag gesture support)
- Pagination (mock seeds only 3 documents; can be added later with more seed data)
- Performance testing
- Cross-browser testing
- Accessibility testing
