# Version History Component

A comprehensive version history UI component for the Dart Desk system, built with shadcn/ui components.

## Features

- Displays document versions in a clean, timeline-style list
- Reactive state management using Solidart
- Status badges with color coding (draft, published, archived, scheduled)
- Version selection with visual indicators
- Change log display for each version
- Published/scheduled date information
- Loading, error, and empty states
- Responsive layout with shadcn/ui styling

## Usage

### Basic Usage

```dart
import 'package:dart_desk/dart_desk.dart';

class DocumentVersionPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = CmsProvider.of(context);

    return CmsVersionHistory(
      viewModel: viewModel,
    );
  }
}
```

### With Custom Height

```dart
CmsVersionHistory(
  viewModel: viewModel,
  height: 600, // Fixed height in pixels
)
```

### Without Header

```dart
CmsVersionHistory(
  viewModel: viewModel,
  showHeader: false, // Hide the header section
)
```

## Component Behavior

### Automatic Updates

The component automatically refetches versions when:
- `selectedDocumentId` changes in the view model
- `refreshVersions()` is called on the view model

### Version Selection

When a user clicks on a version:
1. The version's ID is passed to `viewModel.selectVersion(versionId)`
2. The `selectedVersionId` signal is updated
3. The UI updates to highlight the selected version
4. The `selectedDocumentData` resource automatically fetches the version details

### Status Badge Colors

- **Draft** (Yellow): Version is in draft status
  - Background: `#FEF3C7`
  - Text: `#92400E`
  - Icon: `edit_outlined`

- **Published** (Green): Version is published
  - Background: `#D1FAE5`
  - Text: `#065F46`
  - Icon: `check_circle_outline`

- **Archived** (Gray): Version is archived
  - Background: `muted` color from theme
  - Text: `mutedForeground` color from theme
  - Icon: `archive_outlined`

- **Scheduled** (Blue): Version is scheduled for future publishing
  - Background: `#DBEAFE`
  - Text: `#1E40AF`
  - Icon: `schedule`

## Integration with Document Editor

```dart
class DocumentEditorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = CmsProvider.of(context);

    return Row(
      children: [
        // Main editor area
        Expanded(
          flex: 2,
          child: CmsDocumentEditor(),
        ),

        // Version history sidebar
        SizedBox(
          width: 320,
          child: CmsVersionHistory(
            viewModel: viewModel,
          ),
        ),
      ],
    );
  }
}
```

## Responsive Design Example

```dart
ShadResponsiveBuilder(
  builder: (context, breakpoint) {
    final theme = ShadTheme.of(context);
    final isDesktop = breakpoint >= theme.breakpoints.lg;

    if (isDesktop) {
      // Desktop: Side-by-side layout
      return Row(
        children: [
          Expanded(child: CmsDocumentEditor()),
          SizedBox(
            width: 320,
            child: CmsVersionHistory(viewModel: viewModel),
          ),
        ],
      );
    } else {
      // Mobile: Tabbed layout
      return ShadTabs(
        tabs: [
          ShadTab(
            value: 'editor',
            child: Text('Editor'),
            content: CmsDocumentEditor(),
          ),
          ShadTab(
            value: 'history',
            child: Text('History'),
            content: CmsVersionHistory(viewModel: viewModel),
          ),
        ],
      );
    }
  },
)
```

## State Management

The component uses Solidart's Resource system:

```dart
// The versionsResource automatically:
// 1. Fetches when selectedDocumentId changes
// 2. Provides loading/error/ready states
// 3. Handles debouncing (100ms)
late final Resource<DocumentVersionList> versionsResource =
    Resource<DocumentVersionList>(
      _fetchVersions,
      source: selectedDocumentId,
      debounceDelay: const Duration(milliseconds: 100),
    );
```

## Date Formatting

The component provides smart date formatting:
- Just now (< 1 minute ago)
- "Xm ago" (minutes)
- "Xh ago" (hours)
- "Yesterday at HH:mm" (1 day ago)
- "Xd ago" (< 7 days)
- "MMM d, y" (> 7 days)

## Theme Integration

All colors and typography use `ShadTheme.of(context)`:

```dart
final theme = ShadTheme.of(context);

// Access theme values
theme.colorScheme.primary
theme.colorScheme.foreground
theme.textTheme.large
theme.textTheme.muted
```

## Error Handling

The component includes built-in error handling:
- Error state with retry button
- Error message display
- Automatic refresh on retry

## Empty State

When no versions exist:
- Shows empty state icon
- Displays helpful message
- Maintains clean UI

## Performance

- Uses `ListView.separated` for efficient scrolling
- Debounced resource fetching (100ms)
- Minimal rebuilds with Solidart signals
- Optimized animations (200ms duration)
