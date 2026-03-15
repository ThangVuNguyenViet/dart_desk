# CMS QA Automation Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a comprehensive QA automation system for flutter_cms using Claude Code skill + Marionette MCP, with modular test cases covering all 16 field types and CMS framework components.

**Architecture:** A Claude Code skill reads structured markdown test case files and executes them via Marionette MCP tools against a running Flutter app. The app uses a mock in-memory data source and a test document type fixture with all 16 field types. Successful discovery runs produce replay JSON files for fast re-execution.

**Tech Stack:** Flutter, Dart, Marionette MCP, Claude Code Skills, shadcn_ui, Signals

**Spec:** `docs/superpowers/specs/2026-03-16-cms-qa-automation-design.md`

---

## Chunk 1: Test Fixtures

### Task 1: Create the all-fields test document type fixture

**Files:**
- Create: `packages/flutter_cms/lib/src/testing/test_document_types.dart`

- [ ] **Step 1: Create the test_document_types.dart file**

This file defines a `CmsDocumentType` exercising all 16 field types. It also provides a test app entry point configuration.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';

/// Test document type that exercises all 16 CMS field types.
/// Use this in test apps to get full field coverage.
final allFieldsDocumentType = CmsDocumentType(
  name: 'test_all_fields',
  title: 'Test All Fields',
  description: 'Document type with all 16 field types for QA testing',
  fields: [
    // Primitive fields (8)
    const CmsStringField(
      name: 'string_field',
      title: 'String Field',
      description: 'A single-line string input',
      option: CmsStringOption(),
    ),
    const CmsTextField(
      name: 'text_field',
      title: 'Text Field',
      description: 'A multi-line text area',
      option: CmsTextOption(rows: 3),
    ),
    const CmsNumberField(
      name: 'number_field',
      title: 'Number Field',
      description: 'A numeric input',
      option: CmsNumberOption(),
    ),
    const CmsBooleanField(
      name: 'boolean_field',
      title: 'Boolean Field',
      description: 'A toggle switch',
      option: CmsBooleanOption(),
    ),
    const CmsCheckboxField(
      name: 'checkbox_field',
      title: 'Checkbox Field',
      description: 'A checkbox control',
      option: CmsCheckboxOption(label: 'Enable this feature'),
    ),
    const CmsUrlField(
      name: 'url_field',
      title: 'URL Field',
      description: 'A URL input',
      option: CmsUrlOption(),
    ),
    const CmsDateField(
      name: 'date_field',
      title: 'Date Field',
      description: 'A date picker',
      option: CmsDateOption(),
    ),
    const CmsDateTimeField(
      name: 'datetime_field',
      title: 'DateTime Field',
      description: 'A date and time picker',
      option: CmsDateTimeOption(),
    ),
    // Media fields (3)
    const CmsColorField(
      name: 'color_field',
      title: 'Color Field',
      description: 'A color picker',
      option: CmsColorOption(showAlpha: true),
    ),
    const CmsImageField(
      name: 'image_field',
      title: 'Image Field',
      description: 'An image upload/URL field',
      option: CmsImageOption(hotspot: false),
    ),
    const CmsFileField(
      name: 'file_field',
      title: 'File Field',
      description: 'A file upload field',
      option: CmsFileOption(),
    ),
    // Complex fields (5)
    const CmsDropdownField<String>(
      name: 'dropdown_field',
      title: 'Dropdown Field',
      description: 'A dropdown select',
      option: CmsDropdownSimpleOption(
        options: [
          DropdownOption(value: 'option_a', label: 'Option A'),
          DropdownOption(value: 'option_b', label: 'Option B'),
          DropdownOption(value: 'option_c', label: 'Option C'),
        ],
        placeholder: 'Select an option',
      ),
    ),
    // NOTE: CmsArrayField requires a concrete CmsArrayOption subclass with
    // itemBuilder and itemEditor. Create a simple TestArrayOption class
    // in this file that renders basic text items.
    CmsArrayField(
      name: 'array_field',
      title: 'Array Field',
      description: 'A list of string items',
      option: TestStringArrayOption(),
    ),
    const CmsObjectField(
      name: 'object_field',
      title: 'Object Field',
      description: 'A nested object with sub-fields',
      option: CmsObjectOption(fields: [
        CmsStringField(
          name: 'nested_title',
          title: 'Nested Title',
          option: CmsStringOption(),
        ),
        CmsNumberField(
          name: 'nested_count',
          title: 'Nested Count',
          option: CmsNumberOption(),
        ),
      ]),
    ),
    const CmsBlockField(
      name: 'block_field',
      title: 'Block Field',
      option: CmsBlockOption(),
    ),
    const CmsGeopointField(
      name: 'geopoint_field',
      title: 'Geopoint Field',
      option: CmsGeopointOption(),
    ),
  ],
  builder: _testAllFieldsBuilder,
);

Widget _testAllFieldsBuilder(Map<String, dynamic> data) {
  return const Center(
    child: Text('Test All Fields Preview'),
  );
}

/// Concrete CmsArrayOption for testing string arrays.
class TestStringArrayOption extends CmsArrayOption {
  const TestStringArrayOption();

  @override
  CmsArrayFieldItemBuilder get itemBuilder =>
      (context, value) => Text(value?.toString() ?? '');

  @override
  CmsArrayFieldItemEditor get itemEditor =>
      (context, value, onChanged) => TextField(
            controller: TextEditingController(text: value?.toString() ?? ''),
            onChanged: onChanged,
          );
}

/// Seed data for 3 test documents with known values.
const testDocumentSeedData = [
  {
    'title': 'Test Document Alpha',
    'slug': 'test-document-alpha',
    'data': {
      'string_field': 'Hello World',
      'text_field': 'This is a multi-line\ntext field value.',
      'number_field': 42,
      'boolean_field': true,
      'checkbox_field': false,
      'url_field': 'https://example.com',
      'date_field': '2026-03-01',
      'datetime_field': '2026-03-01T10:30:00',
      'color_field': '#FF5733',
      'image_field': 'https://picsum.photos/200',
      'file_field': null,
      'dropdown_field': 'Option A',
      'array_field': ['Item 1', 'Item 2', 'Item 3'],
      'object_field': {'nested_title': 'Nested Value', 'nested_count': 10},
      'block_field': null,
      'geopoint_field': {'lat': 37.7749, 'lng': -122.4194},
    },
  },
  {
    'title': 'Test Document Beta',
    'slug': 'test-document-beta',
    'data': {
      'string_field': 'Second Document',
      'text_field': 'Beta text content.',
      'number_field': 100,
      'boolean_field': false,
      'checkbox_field': true,
      'url_field': 'https://flutter.dev',
      'date_field': '2026-01-15',
      'datetime_field': '2026-01-15T14:00:00',
      'color_field': '#2196F3',
      'image_field': null,
      'file_field': null,
      'dropdown_field': 'Option B',
      'array_field': ['Alpha', 'Beta'],
      'object_field': {'nested_title': 'Beta Nested', 'nested_count': 5},
      'block_field': null,
      'geopoint_field': {'lat': 40.7128, 'lng': -74.0060},
    },
  },
  {
    'title': 'Test Document Gamma',
    'slug': 'test-document-gamma',
    'data': {
      'string_field': 'Third Document',
      'text_field': 'Gamma text.',
      'number_field': 0,
      'boolean_field': true,
      'checkbox_field': true,
      'url_field': '',
      'date_field': null,
      'datetime_field': null,
      'color_field': '#4CAF50',
      'image_field': 'https://picsum.photos/300',
      'file_field': null,
      'dropdown_field': null,
      'array_field': [],
      'object_field': {'nested_title': '', 'nested_count': 0},
      'block_field': null,
      'geopoint_field': null,
    },
  },
];
```

- [ ] **Step 2: Verify the file compiles**

Run: `cd packages/flutter_cms && flutter analyze lib/src/testing/test_document_types.dart`
Expected: No errors. Warnings about unused imports are OK.

- [ ] **Step 3: Commit**

```bash
git add packages/flutter_cms/lib/src/testing/test_document_types.dart
git commit -m "feat: add all-fields test document type fixture for QA automation"
```

---

### Task 2: Create the mock CmsDataSource

**Files:**
- Create: `packages/flutter_cms/lib/src/testing/mock_cms_data_source.dart`

- [ ] **Step 1: Create the mock_cms_data_source.dart file**

Implements `CmsDataSource` with in-memory storage, pre-seeded with 3 test documents.

```dart
import 'dart:typed_data';

import '../data/cms_data_source.dart';
import '../data/models/cms_document.dart';
import '../data/models/document_list.dart';
import '../data/models/document_version.dart';
import '../data/models/media_file.dart';
import '../data/models/media_upload_result.dart';
import 'test_document_types.dart';

/// In-memory mock implementation of [CmsDataSource] for testing.
///
/// Pre-seeded with 3 documents from [testDocumentSeedData].
/// All operations are synchronous in-memory. No network calls.
class MockCmsDataSource implements CmsDataSource {
  final Map<int, CmsDocument> _documents = {};
  final Map<int, Map<int, DocumentVersion>> _versions = {}; // docId -> {versionId -> version}
  final Map<int, Map<String, dynamic>> _versionData = {}; // versionId -> data
  final Map<int, MediaFile> _media = {};
  int _nextDocId = 1;
  int _nextVersionId = 1;
  int _nextMediaId = 1;

  MockCmsDataSource() {
    _seed();
  }

  void _seed() {
    for (final seed in testDocumentSeedData) {
      final docId = _nextDocId++;
      final versionId = _nextVersionId++;
      final now = DateTime.now();

      _documents[docId] = CmsDocument(
        id: docId,
        clientId: 1,
        documentType: 'test_all_fields',
        title: seed['title'] as String,
        slug: seed['slug'] as String,
        isDefault: docId == 1,
        activeVersionData: seed['data'] as Map<String, dynamic>,
        createdAt: now,
        updatedAt: now,
      );

      _versions[docId] = {
        versionId: DocumentVersion(
          id: versionId,
          documentId: docId,
          versionNumber: 1,
          status: docId == 1
              ? DocumentVersionStatus.published
              : DocumentVersionStatus.draft,
          changeLog: 'Initial version',
          createdAt: now,
          publishedAt: docId == 1 ? now : null,
        ),
      };

      _versionData[versionId] = Map<String, dynamic>.from(
        seed['data'] as Map<String, dynamic>,
      );
    }

    // Add a second version to document 1 (draft on top of published)
    final secondVersionId = _nextVersionId++;
    _versions[1]![secondVersionId] = DocumentVersion(
      id: secondVersionId,
      documentId: 1,
      versionNumber: 2,
      status: DocumentVersionStatus.draft,
      changeLog: 'Updated string field',
      createdAt: DateTime.now(),
    );
    _versionData[secondVersionId] = {
      ...testDocumentSeedData[0]['data'] as Map<String, dynamic>,
      'string_field': 'Hello World (v2)',
    };
  }

  /// Reset to initial seed state. Called between test files via hot restart.
  void reset() {
    _documents.clear();
    _versions.clear();
    _versionData.clear();
    _media.clear();
    _nextDocId = 1;
    _nextVersionId = 1;
    _nextMediaId = 1;
    _seed();
  }

  // ============================================================
  // Document Operations
  // ============================================================

  @override
  Future<DocumentList> getDocuments(
    String documentType, {
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    var docs = _documents.values
        .where((d) => d.documentType == documentType)
        .toList();

    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      docs = docs.where((d) => d.title.toLowerCase().contains(query)).toList();
    }

    final total = docs.length;
    final paged = docs.skip(offset).take(limit).toList();

    return DocumentList(
      documents: paged,
      total: total,
      page: (offset ~/ limit) + 1,
      pageSize: limit,
    );
  }

  @override
  Future<CmsDocument?> getDocument(int documentId) async {
    return _documents[documentId];
  }

  @override
  Future<CmsDocument> createDocument(
    String documentType,
    String title,
    Map<String, dynamic> data, {
    String? slug,
    bool isDefault = false,
  }) async {
    final docId = _nextDocId++;
    final versionId = _nextVersionId++;
    final now = DateTime.now();

    final doc = CmsDocument(
      id: docId,
      clientId: 1,
      documentType: documentType,
      title: title,
      slug: slug ?? _generateSlug(title),
      isDefault: isDefault,
      activeVersionData: data,
      createdAt: now,
      updatedAt: now,
    );

    _documents[docId] = doc;
    _versions[docId] = {
      versionId: DocumentVersion(
        id: versionId,
        documentId: docId,
        versionNumber: 1,
        status: DocumentVersionStatus.draft,
        changeLog: 'Initial version',
        createdAt: now,
      ),
    };
    _versionData[versionId] = Map<String, dynamic>.from(data);

    return doc;
  }

  @override
  Future<CmsDocument?> updateDocument(
    int documentId, {
    String? title,
    String? slug,
    bool? isDefault,
  }) async {
    final doc = _documents[documentId];
    if (doc == null) return null;

    _documents[documentId] = doc.copyWith(
      title: title ?? doc.title,
      slug: slug ?? doc.slug,
      isDefault: isDefault ?? doc.isDefault,
      updatedAt: DateTime.now(),
    );

    return _documents[documentId];
  }

  @override
  Future<bool> deleteDocument(int documentId) async {
    if (!_documents.containsKey(documentId)) return false;
    _documents.remove(documentId);
    final versionIds = _versions.remove(documentId)?.keys ?? [];
    for (final vid in versionIds) {
      _versionData.remove(vid);
    }
    return true;
  }

  @override
  Future<String> suggestSlug(String title, String documentType) async {
    return _generateSlug(title);
  }

  @override
  Future<List<String>> getDocumentTypes() async {
    return _documents.values.map((d) => d.documentType).toSet().toList();
  }

  // ============================================================
  // Version Operations
  // ============================================================

  @override
  Future<DocumentVersionList> getDocumentVersions(
    int documentId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final versions = (_versions[documentId]?.values ?? []).toList()
      ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber));

    return DocumentVersionList(
      versions: versions.skip(offset).take(limit).toList(),
      total: versions.length,
      page: (offset ~/ limit) + 1,
      pageSize: limit,
    );
  }

  @override
  Future<DocumentVersion?> getDocumentVersion(int versionId) async {
    for (final docVersions in _versions.values) {
      if (docVersions.containsKey(versionId)) {
        return docVersions[versionId];
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getDocumentVersionData(int versionId) async {
    return _versionData[versionId];
  }

  @override
  Future<DocumentVersion> createDocumentVersion(
    int documentId, {
    String status = 'draft',
    String? changeLog,
  }) async {
    final versionId = _nextVersionId++;
    final existingVersions = _versions[documentId]?.values ?? [];
    final maxVersion = existingVersions.isEmpty
        ? 0
        : existingVersions
            .map((v) => v.versionNumber)
            .reduce((a, b) => a > b ? a : b);

    final parsedStatus = DocumentVersionStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => DocumentVersionStatus.draft,
    );

    final version = DocumentVersion(
      id: versionId,
      documentId: documentId,
      versionNumber: maxVersion + 1,
      status: parsedStatus,
      changeLog: changeLog,
      createdAt: DateTime.now(),
    );

    _versions.putIfAbsent(documentId, () => {});
    _versions[documentId]![versionId] = version;
    _versionData[versionId] = {};

    return version;
  }

  @override
  Future<CmsDocument> updateDocumentData(
    int documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  }) async {
    // Find latest version for this document
    final docVersions = _versions[documentId]?.values.toList() ?? [];
    docVersions.sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
    if (docVersions.isNotEmpty) {
      final latestVersionId = docVersions.first.id;
      final existingData = _versionData[latestVersionId] ?? {};
      existingData.addAll(updates);
      _versionData[latestVersionId] = existingData;
    }

    // Update activeVersionData on the document
    final doc = _documents[documentId]!;
    final updatedData = Map<String, dynamic>.from(doc.activeVersionData ?? {});
    updatedData.addAll(updates);
    _documents[documentId] = doc.copyWith(
      activeVersionData: updatedData,
      updatedAt: DateTime.now(),
    );

    return _documents[documentId]!;
  }

  @override
  Future<DocumentVersion?> publishDocumentVersion(int versionId) async {
    return _updateVersionStatus(versionId, DocumentVersionStatus.published);
  }

  @override
  Future<DocumentVersion?> archiveDocumentVersion(int versionId) async {
    return _updateVersionStatus(versionId, DocumentVersionStatus.archived);
  }

  @override
  Future<bool> deleteDocumentVersion(int versionId) async {
    for (final docVersions in _versions.values) {
      if (docVersions.containsKey(versionId)) {
        docVersions.remove(versionId);
        _versionData.remove(versionId);
        return true;
      }
    }
    return false;
  }

  // ============================================================
  // Media Operations
  // ============================================================

  @override
  Future<MediaUploadResult> uploadImage(
    String fileName,
    Uint8List fileData,
  ) async {
    return _uploadMedia(fileName, fileData, isImage: true);
  }

  @override
  Future<MediaUploadResult> uploadFile(
    String fileName,
    Uint8List fileData,
  ) async {
    return _uploadMedia(fileName, fileData, isImage: false);
  }

  @override
  Future<bool> deleteMedia(int fileId) async {
    return _media.remove(fileId) != null;
  }

  @override
  Future<MediaFile?> getMedia(int fileId) async {
    return _media[fileId];
  }

  @override
  Future<List<MediaFile>> listMedia({int limit = 50, int offset = 0}) async {
    return _media.values.skip(offset).take(limit).toList();
  }

  // ============================================================
  // Helpers
  // ============================================================

  String _generateSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  DocumentVersion? _updateVersionStatus(
    int versionId,
    DocumentVersionStatus status,
  ) {
    for (final docVersions in _versions.values) {
      if (docVersions.containsKey(versionId)) {
        final version = docVersions[versionId]!;
        final updated = DocumentVersion(
          id: version.id,
          documentId: version.documentId,
          versionNumber: version.versionNumber,
          status: status,
          changeLog: version.changeLog,
          createdAt: version.createdAt,
          publishedAt: status == DocumentVersionStatus.published
              ? DateTime.now()
              : version.publishedAt,
          archivedAt: status == DocumentVersionStatus.archived
              ? DateTime.now()
              : version.archivedAt,
        );
        docVersions[versionId] = updated;
        return updated;
      }
    }
    return null;
  }

  MediaUploadResult _uploadMedia(
    String fileName,
    Uint8List fileData, {
    required bool isImage,
  }) {
    final id = _nextMediaId++;
    final file = MediaFile(
      id: id,
      fileName: fileName,
      publicUrl: 'https://mock-cdn.test/$fileName',
      fileSize: fileData.length,
      fileType: isImage ? 'image/png' : 'application/octet-stream',
      createdAt: DateTime.now(),
    );
    _media[id] = file;
    return MediaUploadResult(
      id: id.toString(),
      url: 'https://mock-cdn.test/$fileName',
      fileName: fileName,
    );
  }
}
```

- [ ] **Step 2: Verify the file compiles**

Run: `cd packages/flutter_cms && flutter analyze lib/src/testing/mock_cms_data_source.dart`
Expected: No errors. Fix any import path issues or missing model properties (the `copyWith`, `MediaFile`, and `MediaUploadResult` constructors may need adjustment to match exact model signatures).

- [ ] **Step 3: Export the testing module**

Add exports to the package's public API so consumers can use these test fixtures. Create `packages/flutter_cms/lib/testing.dart`:

```dart
export 'src/testing/test_document_types.dart';
export 'src/testing/mock_cms_data_source.dart';
```

- [ ] **Step 4: Commit**

```bash
git add packages/flutter_cms/lib/src/testing/mock_cms_data_source.dart packages/flutter_cms/lib/testing.dart
git commit -m "feat: add mock CmsDataSource and testing exports for QA automation"
```

---

## Chunk 2: Test Automation Infrastructure

### Task 3: Create directory structure and gitignore

**Files:**
- Create: `packages/flutter_cms/test_automation/replays/.gitkeep`
- Create: `packages/flutter_cms/test_automation/results/.gitignore`

- [ ] **Step 1: Create directories and gitignore**

```bash
mkdir -p packages/flutter_cms/test_automation/{skill,tests,replays,results/screenshots,results/reports}
touch packages/flutter_cms/test_automation/replays/.gitkeep
```

Create `packages/flutter_cms/test_automation/results/.gitignore`:

```
*
!.gitignore
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/
git commit -m "chore: create test_automation directory structure"
```

---

### Task 4: Write the Claude Code skill

**Files:**
- Create: `packages/flutter_cms/test_automation/skill/SKILL.md`

- [ ] **Step 1: Write the SKILL.md file**

```markdown
---
name: cms-qa-testing
description: Comprehensive QA automation for flutter_cms using Marionette MCP. Run test suites or individual test files against a running Flutter app.
---

# CMS QA Testing Skill

Executes structured QA test cases against a running flutter_cms app via Marionette MCP.

## Prerequisites

- Flutter CMS app running in debug mode with the mock data source and test document types
- Marionette MCP server connected to the app's VM service URI
- The app should be on the studio screen with at least one document type visible in the sidebar

## Invocation

User says one of:
- "run the CMS test suite" → run all test files 01-10
- "run test 04" or "run field types basic" → run a specific test file
- "re-discover test 02" → force re-run discovery even if replay exists

## Execution Flow

### Phase 1: Discovery Run

For each test file to execute:

1. **Read** the test file from `packages/flutter_cms/test_automation/tests/`
2. **Check** if a replay file exists in `packages/flutter_cms/test_automation/replays/` and is newer than the test file. If so, use Phase 2 instead.
3. **For each test case in the file:**
   a. Log the test case ID and title
   b. Execute each step using marionette tools:
      - `tap` for button/element interactions
      - `enter_text` for text input
      - `scroll_to` for scrolling to elements
   c. After each action, call `get_interactive_elements` to verify expected state
   d. Compare actual elements against the **Expected** section
   e. Take a screenshot and save to `results/screenshots/{test_case_id}.png`
   f. Record PASS if all expectations met, FAIL with notes if not
   g. Record the marionette commands (tap, enter_text, scroll_to only — NOT get_interactive_elements or take_screenshots) into the replay action list
4. **After all test cases in a file pass**, write the replay JSON to `replays/{test_file_name}.json`
5. **Reset app state** by calling `mcp__dart__hot_restart` (requires DTD connection)
6. **Wait** 3 seconds after hot restart for the app to stabilize, then reconnect marionette

### Phase 2: Replay Run

1. **Read** the replay JSON from `packages/flutter_cms/test_automation/replays/{test_file_name}.json`
2. **For each test case:**
   a. Execute the stored `actions` sequentially (tap, enter_text, scroll_to)
   b. At each `verify` checkpoint, call `get_interactive_elements` and check `expect_text`
   c. Take a screenshot at each verify point
   d. Record PASS/FAIL
3. If any verification fails, mark as FAIL and suggest re-running discovery

### Replay JSON Format

```json
{
  "test_file": "02_document_crud.md",
  "recorded": "2026-03-16T10:30:00",
  "test_cases": [
    {
      "id": "TC-02-01",
      "title": "Create a new document",
      "actions": [
        {"action": "tap", "params": {"text": "+"}}
      ],
      "verify": [
        {"action": "get_interactive_elements", "expect_text": ["My Test Document"]}
      ]
    }
  ]
}
```

### Results Report

After all test files complete, write a markdown report to `results/reports/YYYY-MM-DD-HHmm.md`:

```markdown
# CMS QA Test Report - {date}

## Summary
- **Total:** X test cases
- **Passed:** Y
- **Failed:** Z
- **Skipped:** W

## Results

### 01 - Sidebar Navigation
| ID | Title | Result | Notes |
|---|---|---|---|
| TC-01-01 | Select document type | PASS | |
| TC-01-02 | Selection indicator | PASS | |

### 02 - Document CRUD
...
```

## Interaction Rules

- **Always use `get_interactive_elements` after every action** to verify state
- **Use `text` parameter for tapping** — never coordinates
- **Take screenshots** only at verification checkpoints, not after every action
- If an element cannot be found by text, check if it has a `Key` and use that
- If neither text nor key works, report the element as untestable and SKIP the test case
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/skill/SKILL.md
git commit -m "feat: add Claude Code skill for CMS QA test execution"
```

---

### Task 5: Write the README

**Files:**
- Create: `packages/flutter_cms/test_automation/README.md`

- [ ] **Step 1: Write README.md**

```markdown
# CMS QA Test Automation

Automated QA testing for flutter_cms using Claude Code + Marionette MCP.

## Setup

1. Create a test app that uses `MockCmsDataSource` and `allFieldsDocumentType`:

```dart
import 'package:flutter_cms/testing.dart';
import 'package:flutter_cms/studio.dart';

void main() {
  runApp(CmsStudioApp(
    dataSource: MockCmsDataSource(),
    documentTypes: [allFieldsDocumentType],
    documentTypeDecorations: [
      CmsDocumentTypeDecoration(
        documentType: allFieldsDocumentType,
        icon: Icons.science,
      ),
    ],
    title: 'CMS QA Test',
  ));
}
```

2. Run the test app in debug mode:
```bash
flutter run -d chrome --web-port=60366
```

3. In Claude Code, connect marionette to the app's VM service URI

4. Ask Claude to run the tests:
   - "run the CMS test suite" — runs all 10 test files
   - "run test 04" — runs a specific test file
   - "re-discover test 02" — force re-discovery

## Directory Structure

```
test_automation/
├── skill/SKILL.md          # Claude Code skill definition
├── tests/                  # Test case specs (markdown)
│   ├── 01_sidebar_navigation.md
│   ├── ...
│   └── 10_error_states.md
├── replays/                # Auto-generated replay JSONs
├── results/                # Test run outputs (gitignored)
│   ├── screenshots/
│   └── reports/
└── README.md
```

## Adding New Tests

Create a new `.md` file in `tests/` following the format in existing files. Use test case IDs like `TC-{file_number}-{case_number}`.
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/README.md
git commit -m "docs: add README for CMS QA test automation"
```

---

## Chunk 3: Test Case Files 01-05

### Task 6: Write test file 01 - Sidebar Navigation

**Files:**
- Create: `packages/flutter_cms/test_automation/tests/01_sidebar_navigation.md`

- [ ] **Step 1: Write 01_sidebar_navigation.md**

```markdown
# 01 - Sidebar Navigation

## Prerequisites
- App is on the studio screen
- At least one document type is registered ("Test All Fields")

## TC-01-01: Document type is visible in sidebar
**Steps:**
1. Call get_interactive_elements
2. Verify a Text element with "Test All Fields" exists in the sidebar area (x < 300)

**Expected:**
- Text "Test All Fields" is visible
- An icon is displayed next to it

## TC-01-02: Tap document type selects it
**Steps:**
1. Tap "Test All Fields" in the sidebar
2. Call get_interactive_elements

**Expected:**
- "Test All Fields" text color changes to primary (selected state)
- Selection indicator (dot) appears on the sidebar item
- Document list panel shows the "Test All Fields" header

## TC-01-03: Selected type shows document list
**Steps:**
1. Tap "Test All Fields" if not already selected
2. Call get_interactive_elements

**Expected:**
- Document list header shows "Test All Fields"
- Search field with placeholder "Search documents..." is visible
- "+" button is visible in the header
- Pre-seeded documents are listed: "Test Document Alpha", "Test Document Beta", "Test Document Gamma"

## TC-01-04: Re-tapping selected type does not deselect
**Steps:**
1. Tap "Test All Fields" (already selected)
2. Call get_interactive_elements

**Expected:**
- "Test All Fields" remains selected (highlight unchanged)
- Document list still shows the documents
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/tests/01_sidebar_navigation.md
git commit -m "test: add sidebar navigation test cases"
```

---

### Task 7: Write test file 02 - Document CRUD

**Files:**
- Create: `packages/flutter_cms/test_automation/tests/02_document_crud.md`

- [ ] **Step 1: Write 02_document_crud.md**

```markdown
# 02 - Document CRUD

## Prerequisites
- "Test All Fields" document type is selected in the sidebar
- Document list is visible with 3 pre-seeded documents

## TC-02-01: Open create document form
**Steps:**
1. Tap the "+" button (ShadIconButton in document list header)
2. Call get_interactive_elements

**Expected:**
- Inline create form appears at the top of the document list
- "Create New Document" title is visible
- "Document title" placeholder input is visible
- "slug (auto-generated)" placeholder input is visible
- "Cancel" and "Create" buttons are visible

## TC-02-02: Cancel create form
**Steps:**
1. Tap "+" to open create form (if not open)
2. Tap "Cancel"
3. Call get_interactive_elements

**Expected:**
- Create form disappears
- Document list shows the original 3 documents

## TC-02-03: Create a new document
**Steps:**
1. Tap "+" to open create form
2. Enter "New QA Document" in the "Document title" field
3. Wait 1 second for slug auto-generation
4. Call get_interactive_elements to verify slug field populated
5. Tap "Create"
6. Call get_interactive_elements

**Expected:**
- After step 4: slug field shows "new-qa-document" (or similar auto-generated value)
- After step 6: Create form disappears
- "New QA Document" appears in the document list
- Document list now has 4 documents

## TC-02-04: Search documents
**Steps:**
1. Enter "Alpha" in the "Search documents..." field
2. Call get_interactive_elements

**Expected:**
- Only "Test Document Alpha" is visible in the document list
- "Test Document Beta" and "Test Document Gamma" are NOT visible

## TC-02-05: Clear search shows all documents
**Steps:**
1. Clear the search field (enter empty text in "Search documents..." or the current search text)
2. Call get_interactive_elements

**Expected:**
- All documents are visible again (3 or 4 depending on whether TC-02-03 ran)

## TC-02-06: Delete a document
**Steps:**
1. Select "Test Document Gamma" by tapping it
2. Look for a delete action (button or menu item)
3. If delete is available, tap it
4. Call get_interactive_elements

**Expected:**
- "Test Document Gamma" is removed from the document list
- If the deleted document was selected, the editor panel shows empty/no selection state

**Note:** If delete is not exposed in the UI, mark this test as SKIPPED with note "Delete not available in document list UI"
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/tests/02_document_crud.md
git commit -m "test: add document CRUD test cases"
```

---

### Task 8: Write test file 03 - Document Selection

**Files:**
- Create: `packages/flutter_cms/test_automation/tests/03_document_selection.md`

- [ ] **Step 1: Write 03_document_selection.md**

```markdown
# 03 - Document Selection

## Prerequisites
- "Test All Fields" document type is selected
- Document list shows pre-seeded documents
- No document is currently selected

## TC-03-01: Tap document selects it
**Steps:**
1. Tap "Test Document Alpha"
2. Call get_interactive_elements

**Expected:**
- "Test Document Alpha" tile shows selection styling:
  - Check circle icon (Icons.check_circle) visible next to title
  - Title text color changes to primary color
- Editor panel on the right loads with document fields
- "String Field" label is visible in the editor

## TC-03-02: Switch to different document
**Steps:**
1. Tap "Test Document Beta"
2. Call get_interactive_elements

**Expected:**
- "Test Document Beta" now has check circle icon
- "Test Document Alpha" no longer has check circle icon (back to default styling)
- Editor panel updates to show Beta's data
- String field value changes to "Second Document"

## TC-03-03: Re-tap selected document does nothing
**Steps:**
1. Tap "Test Document Beta" again (already selected)
2. Call get_interactive_elements

**Expected:**
- "Test Document Beta" remains selected (no change)
- Editor panel still shows Beta's data

## TC-03-04: Selection persists after switching back
**Steps:**
1. Tap "Test Document Alpha"
2. Call get_interactive_elements
3. Tap "Test Document Beta"
4. Call get_interactive_elements

**Expected:**
- After step 2: Alpha is selected, shows Alpha's data
- After step 4: Beta is selected, shows Beta's data
- Each switch properly updates both the list indicator and editor content
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/tests/03_document_selection.md
git commit -m "test: add document selection test cases"
```

---

### Task 9: Write test file 04 - Field Types Basic

**Files:**
- Create: `packages/flutter_cms/test_automation/tests/04_field_types_basic.md`

- [ ] **Step 1: Write 04_field_types_basic.md**

```markdown
# 04 - Field Types Basic

## Prerequisites
- "Test All Fields" document type is selected
- "Test Document Alpha" is selected (has known seed data)
- Editor panel is visible on the right

## TC-04-01: String field displays and edits
**Steps:**
1. Verify "String Field" label is visible in the editor
2. Verify the string input shows "Hello World" (seed value)
3. Clear the field and enter "Updated String"
4. Call get_interactive_elements

**Expected:**
- String field label "String Field" is visible
- Input contains "Updated String" after editing

## TC-04-02: Text field displays and edits
**Steps:**
1. Scroll to "Text Field" if not visible
2. Verify multi-line text area shows seed value
3. Clear and enter "New multi-line\ntext content"
4. Call get_interactive_elements

**Expected:**
- Text field label "Text Field" is visible
- Text area is multi-line (rows > 1)

## TC-04-03: Number field displays and edits
**Steps:**
1. Scroll to "Number Field"
2. Verify it shows "42" (seed value)
3. Clear and enter "99"
4. Call get_interactive_elements

**Expected:**
- Number field shows "99" after editing

## TC-04-04: Boolean field displays and toggles
**Steps:**
1. Scroll to "Boolean Field"
2. Verify toggle is ON (seed value is true)
3. Tap the toggle/switch
4. Call get_interactive_elements

**Expected:**
- Toggle switches to OFF state
- The GestureDetector or ShadSwitch element reflects the new state

## TC-04-05: Checkbox field displays and toggles
**Steps:**
1. Scroll to "Checkbox Field"
2. Verify checkbox is unchecked (seed value is false)
3. Verify label "Enable this feature" is visible
4. Tap the checkbox
5. Call get_interactive_elements

**Expected:**
- Checkbox toggles to checked state

## TC-04-06: URL field displays and edits
**Steps:**
1. Scroll to "URL Field"
2. Verify it shows "https://example.com" (seed value)
3. Clear and enter "https://flutter.dev"
4. Call get_interactive_elements

**Expected:**
- URL field shows "https://flutter.dev" after editing
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/tests/04_field_types_basic.md
git commit -m "test: add basic field types test cases"
```

---

### Task 10: Write test file 05 - Field Types Advanced

**Files:**
- Create: `packages/flutter_cms/test_automation/tests/05_field_types_advanced.md`

- [ ] **Step 1: Write 05_field_types_advanced.md**

```markdown
# 05 - Field Types Advanced

## Prerequisites
- "Test All Fields" document type is selected
- "Test Document Alpha" is selected
- Editor panel is visible

## TC-05-01: Color field displays color value
**Steps:**
1. Scroll to "Color Field"
2. Call get_interactive_elements

**Expected:**
- "Color Field" label is visible
- A color swatch/preview is displayed
- Hex value "#FF5733" (seed value) or color input is visible

## TC-05-02: Color field opens picker
**Steps:**
1. Tap the color swatch or color input area
2. Call get_interactive_elements

**Expected:**
- Color picker UI appears (HSV wheel, sliders, or hex input)
- Current color value is reflected in the picker

## TC-05-03: Date field displays and opens picker
**Steps:**
1. Scroll to "Date Field"
2. Verify the date value is displayed (seed: "2026-03-01")
3. Tap the date field/button
4. Call get_interactive_elements

**Expected:**
- Date picker dialog or popover appears
- Current date is highlighted/selected

## TC-05-04: DateTime field displays value
**Steps:**
1. Scroll to "DateTime Field"
2. Call get_interactive_elements

**Expected:**
- "DateTime Field" label is visible
- DateTime value from seed data is displayed

## TC-05-05: Dropdown field displays and selects
**Steps:**
1. Scroll to "Dropdown Field"
2. Verify current value shows "Option A" (seed value)
3. Tap the dropdown to open it
4. Call get_interactive_elements
5. Tap "Option B"
6. Call get_interactive_elements

**Expected:**
- After step 4: Dropdown options visible ("Option A", "Option B", "Option C")
- After step 6: Dropdown shows "Option B" as selected value

## TC-05-06: Image field displays URL and allows removal
**Steps:**
1. Scroll to "Image Field"
2. Verify the image URL "https://picsum.photos/200" is displayed (seed value) or an image preview is shown
3. If a URL input is visible, clear it and enter "https://picsum.photos/400"
4. If a "Remove" button is visible, tap it
5. Call get_interactive_elements

**Expected:**
- Image field label "Image Field" is visible
- After URL change or removal, the field state updates accordingly

**Note:** If the image field only shows a native file picker button with no URL input, mark as SKIPPED with note "No URL input available, native picker only"

## TC-05-07: File field displays state
**Steps:**
1. Scroll to "File Field"
2. Call get_interactive_elements

**Expected:**
- "File Field" label is visible
- Field shows empty/no-file state (seed value is null)

**Note:** File upload via native picker cannot be tested. Only verify the field renders correctly.
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/tests/05_field_types_advanced.md
git commit -m "test: add advanced field types test cases (7 cases incl. image/file)"
```

---

## Chunk 4: Test Case Files 06-10

### Task 11: Write test file 06 - Field Types Complex

**Files:**
- Create: `packages/flutter_cms/test_automation/tests/06_field_types_complex.md`

- [ ] **Step 1: Write 06_field_types_complex.md**

```markdown
# 06 - Field Types Complex

## Prerequisites
- "Test All Fields" document type is selected
- "Test Document Alpha" is selected
- Editor panel is visible

## TC-06-01: Array field displays items
**Steps:**
1. Scroll to "Array Field"
2. Call get_interactive_elements

**Expected:**
- "Array Field" label is visible
- 3 items are listed: "Item 1", "Item 2", "Item 3" (seed data)
- Each item has a delete button
- "Add" button is visible

## TC-06-02: Array field add item
**Steps:**
1. Scroll to "Array Field"
2. Tap the "Add" button
3. Call get_interactive_elements
4. Enter "Item 4" in the new item's input field
5. Call get_interactive_elements

**Expected:**
- A new empty item input appears after tapping Add
- After entering text, 4 items are in the list

## TC-06-03: Array field remove item
**Steps:**
1. Find the delete button for "Item 3"
2. Tap the delete button
3. Call get_interactive_elements

**Expected:**
- "Item 3" is removed from the list
- Remaining items are still visible

## TC-06-04: Object field displays nested fields
**Steps:**
1. Scroll to "Object Field"
2. Call get_interactive_elements

**Expected:**
- "Object Field" label is visible
- Nested fields are visible:
  - "Nested Title" with value "Nested Value"
  - "Nested Count" with value "10"

## TC-06-05: Geopoint field displays coordinates
**Steps:**
1. Scroll to "Geopoint Field"
2. Call get_interactive_elements

**Expected:**
- "Geopoint Field" label is visible
- Latitude input shows "37.7749" (seed value)
- Longitude input shows "-122.4194" (seed value)
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/tests/06_field_types_complex.md
git commit -m "test: add complex field types test cases"
```

---

### Task 12: Write test file 07 - Form Save/Discard

**Files:**
- Create: `packages/flutter_cms/test_automation/tests/07_form_save_discard.md`

- [ ] **Step 1: Write 07_form_save_discard.md**

```markdown
# 07 - Form Save/Discard

## Prerequisites
- "Test All Fields" document type is selected
- "Test Document Alpha" is selected
- Editor panel shows the document's fields

## TC-07-01: Save and Discard buttons are visible
**Steps:**
1. Call get_interactive_elements

**Expected:**
- "Save" button is visible at the bottom of the editor
- "Discard" button is visible at the bottom of the editor

## TC-07-02: Edit field then save
**Steps:**
1. Find the string field and clear it
2. Enter "Saved Value" in the string field
3. Tap "Save"
4. Call get_interactive_elements

**Expected:**
- After save, no error messages appear
- String field still shows "Saved Value" (persisted)

## TC-07-03: Edit field then discard
**Steps:**
1. Find the string field
2. Clear it and enter "Temporary Value"
3. Tap "Discard"
4. Call get_interactive_elements

**Expected:**
- String field reverts to its previous value (before the edit)
- "Temporary Value" is gone

## TC-07-04: Multiple edits then discard reverts all
**Steps:**
1. Edit the string field to "Change 1"
2. Toggle the boolean field
3. Tap "Discard"
4. Call get_interactive_elements

**Expected:**
- String field reverts to original value
- Boolean field reverts to original state
- All changes are discarded

## TC-07-05: Save shows loading state
**Steps:**
1. Edit any field
2. Tap "Save"
3. Immediately call get_interactive_elements

**Expected:**
- During save, a loading indicator may be visible
- Save button may be disabled during the operation
- After save completes, buttons return to normal state

**Note:** The mock data source is instant, so the loading state may be too brief to capture. If not observable, mark as SKIPPED with note "Mock too fast to observe loading state"
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/tests/07_form_save_discard.md
git commit -m "test: add form save/discard test cases"
```

---

### Task 13: Write test file 08 - Version History

**Files:**
- Create: `packages/flutter_cms/test_automation/tests/08_version_history.md`

- [ ] **Step 1: Write 08_version_history.md**

```markdown
# 08 - Version History

## Prerequisites
- "Test All Fields" document type is selected
- "Test Document Alpha" is selected (has 2 versions: v1 published, v2 draft)

## TC-08-01: Version dropdown is visible
**Steps:**
1. Call get_interactive_elements
2. Look for version indicator or dropdown in the editor panel

**Expected:**
- A version indicator or dropdown is visible
- Current version number or status is displayed

## TC-08-02: Open version dropdown
**Steps:**
1. Tap the version dropdown/popover trigger
2. Call get_interactive_elements

**Expected:**
- Version list appears showing:
  - Version 2 (draft) — most recent
  - Version 1 (published)
- Each version shows version number and status badge

## TC-08-03: Switch to older version
**Steps:**
1. Open version dropdown
2. Tap Version 1
3. Call get_interactive_elements

**Expected:**
- Editor loads Version 1's data
- String field shows "Hello World" (v1 seed value, not "Hello World (v2)")
- Version indicator updates to show v1 is selected

## TC-08-04: Switch back to latest version
**Steps:**
1. Open version dropdown
2. Tap Version 2
3. Call get_interactive_elements

**Expected:**
- Editor loads Version 2's data
- String field shows "Hello World (v2)"
- Version indicator shows v2 is selected
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/tests/08_version_history.md
git commit -m "test: add version history test cases"
```

---

### Task 14: Write test file 09 - Panel Layout

**Files:**
- Create: `packages/flutter_cms/test_automation/tests/09_panel_layout.md`

- [ ] **Step 1: Write 09_panel_layout.md**

```markdown
# 09 - Panel Layout

## Prerequisites
- App is on the studio screen
- A document type is registered

## TC-09-01: All panels are present
**Steps:**
1. Call get_interactive_elements

**Expected:**
- Sidebar panel exists (contains document type items, x < 310)
- Document list panel exists (contains "Search documents..." or document type header)
- Editor panel exists (rightmost, contains form fields or empty state)
- GestureDetector separators exist between panels (the draggable dividers)

## TC-09-02: Sidebar empty state when no type selected
**Steps:**
1. If possible, navigate to a state with no document type selected
2. Call get_interactive_elements

**Expected:**
- Document list shows "Select a document type" message
- Or document list shows the first type auto-selected

**Note:** If the app auto-selects the first document type on load, this empty state may not be reachable. Mark as SKIPPED if so.

## TC-09-03: Editor empty state when no document selected
**Steps:**
1. Ensure a document type is selected but no document is selected
2. Call get_interactive_elements

**Expected:**
- Editor panel shows empty state message (e.g., "Select a document" or similar)
- No form fields are visible in the editor
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/tests/09_panel_layout.md
git commit -m "test: add panel layout test cases"
```

---

### Task 15: Write test file 10 - Error States

**Files:**
- Create: `packages/flutter_cms/test_automation/tests/10_error_states.md`

- [ ] **Step 1: Write 10_error_states.md**

```markdown
# 10 - Error States

## Prerequisites
- App is on the studio screen
- Mock data source is active

## TC-10-01: Empty document list shows message
**Steps:**
1. Select "Test All Fields" document type
2. Enter a search query that matches nothing: "xyznonexistent"
3. Call get_interactive_elements

**Expected:**
- "No documents match your search" message is visible
- Inbox icon is displayed
- No document tiles are shown

## TC-10-02: Create document with empty title fails
**Steps:**
1. Tap "+" to open create form
2. Leave title empty
3. Tap "Create"
4. Call get_interactive_elements

**Expected:**
- Document is NOT created (validation prevents it)
- Create form remains open
- The create button should not trigger if title is empty

## TC-10-03: Create document with empty slug fails
**Steps:**
1. Tap "+" to open create form
2. Enter "Test Title" in the title field
3. Clear the slug field (if auto-generated, clear it manually)
4. Tap "Create"
5. Call get_interactive_elements

**Expected:**
- Document is NOT created
- Create form remains open

## TC-10-04: Search with no results then clear
**Steps:**
1. Enter "nomatch" in search field
2. Call get_interactive_elements
3. Verify "No documents match your search" is shown
4. Clear the search field
5. Call get_interactive_elements

**Expected:**
- After step 3: Empty state message visible
- After step 5: All documents are visible again
```

- [ ] **Step 2: Commit**

```bash
git add packages/flutter_cms/test_automation/tests/10_error_states.md
git commit -m "test: add error states test cases"
```

---

### Task 16: Final integration commit

- [ ] **Step 1: Verify all files exist**

Run:
```bash
find packages/flutter_cms/test_automation -type f | sort
find packages/flutter_cms/lib/src/testing -type f | sort
```

Expected output includes:
- `lib/src/testing/test_document_types.dart`
- `lib/src/testing/mock_cms_data_source.dart`
- `lib/testing.dart`
- `test_automation/skill/SKILL.md`
- `test_automation/README.md`
- `test_automation/tests/01_sidebar_navigation.md` through `10_error_states.md`
- `test_automation/results/.gitignore`
- `test_automation/replays/.gitkeep`

- [ ] **Step 2: Run flutter analyze on the package**

Run: `cd packages/flutter_cms && flutter analyze`
Expected: No errors in the testing files.

- [ ] **Step 3: Commit any remaining changes**

```bash
git add -A packages/flutter_cms/test_automation/ packages/flutter_cms/lib/src/testing/ packages/flutter_cms/lib/testing.dart
git commit -m "feat: complete CMS QA automation system with test fixtures, skill, and 46 test cases"
```
