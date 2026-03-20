# CMS QA Test Automation

Automated QA testing for dart_desk using Claude Code + Marionette MCP.

## Setup

1. Create a test app that uses `MockCmsDataSource` and `allFieldsDocumentType`:

```dart
import 'package:dart_desk/testing.dart';
import 'package:dart_desk/studio.dart';

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

2. Run the test app in debug mode using dart MCP tools (`mcp__dart__launch_app`).

3. In Claude Code, connect marionette to the app's VM service URI

4. Ask Claude to run the tests:
   - "run the CMS test suite" -- runs all 10 test files
   - "run test 04" -- runs a specific test file
   - "re-discover test 02" -- force re-discovery

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
