import re

filepath = 'lib/src/studio/core/view_models/desk_view_model.dart'
with open(filepath, 'r') as f:
    content = f.read()

# Add import
content = content.replace("import 'package:signals_flutter/signals_flutter.dart';", "import 'package:signals_flutter/signals_flutter.dart';\nimport 'package:signals_core/signals_core.dart' as core;")

# Add _untrackedRead
untracked_read = """
  // ============================================================
  // Signal Containers for Dynamic Data Fetching
  // ============================================================

  /// Reads a container without accidentally subscribing the current widget
  /// to the container's internal map.
  T _untrackedRead<T>(T Function() fn) {
    final old = core.onSignalRead;
    core.onSignalRead = null;
    try {
      return core.untracked(fn);
    } finally {
      core.onSignalRead = old;
    }
  }
"""

content = content.replace("  // ============================================================\n  // Signal Containers for Dynamic Data Fetching\n  // ============================================================", untracked_read)

# Rename containers
content = content.replace("late final SignalContainer<AsyncState<DocumentList>, String, FutureSignal<DocumentList>> documentsContainer = SignalContainer(",
"late final SignalContainer<AsyncState<DocumentList>, String, FutureSignal<DocumentList>> _documentsContainer = SignalContainer(")
content = content.replace("late final SignalContainer<AsyncState<DocumentVersionList>, String, FutureSignal<DocumentVersionList>> versionsContainer = SignalContainer(",
"late final SignalContainer<AsyncState<DocumentVersionList>, String, FutureSignal<DocumentVersionList>> _versionsContainer = SignalContainer(")
content = content.replace("late final SignalContainer<AsyncState<DocumentVersion?>, String, FutureSignal<DocumentVersion?>> documentDataContainer = SignalContainer(",
"late final SignalContainer<AsyncState<DocumentVersion?>, String, FutureSignal<DocumentVersion?>> _documentDataContainer = SignalContainer(")
content = content.replace("late final SignalContainer<AsyncState<DeskDocument?>, String, FutureSignal<DeskDocument?>> selectedDocumentContainer = SignalContainer(",
"late final SignalContainer<AsyncState<DeskDocument?>, String, FutureSignal<DeskDocument?>> _selectedDocumentContainer = SignalContainer(")

# Add getters/methods
getters = """
  FutureSignal<DocumentList> documentsContainer(String documentType) => _untrackedRead(() => _documentsContainer(documentType));
  FutureSignal<DocumentVersionList> versionsContainer(String documentId) => _untrackedRead(() => _versionsContainer(documentId));
  FutureSignal<DocumentVersion?> documentDataContainer(String versionId) => _untrackedRead(() => _documentDataContainer(versionId));
  FutureSignal<DeskDocument?> selectedDocumentContainer(String documentId) => _untrackedRead(() => _selectedDocumentContainer(documentId));

  // ============================================================
  // Constructor
"""

content = content.replace("  // ============================================================\n  // Constructor", getters)

with open(filepath, 'w') as f:
    f.write(content)

