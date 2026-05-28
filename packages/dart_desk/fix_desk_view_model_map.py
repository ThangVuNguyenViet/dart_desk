import re
with open('lib/src/studio/core/view_models/desk_view_model.dart', 'r') as f:
    content = f.read()

content = content.replace("    final versions = versionsState.map(", "    final List<DocumentVersion> versions = versionsState.map(")
content = content.replace("    final crdtHlc = docState.map(", "    final String? crdtHlc = docState.map(")
# also remove the try/catch I added
content = content.replace("  late final hasUnpublishedChanges = Computed<bool>(() { try {", "  late final hasUnpublishedChanges = Computed<bool>(() {")
content = content.replace("  } catch (e, s) { print('hasUnpublishedChanges ERROR: $e\\n$s'); throw e; } }, options: ComputedOptions(name: 'hasUnpublishedChanges'));", "  }, options: ComputedOptions(name: 'hasUnpublishedChanges'));")

with open('lib/src/studio/core/view_models/desk_view_model.dart', 'w') as f:
    f.write(content)
