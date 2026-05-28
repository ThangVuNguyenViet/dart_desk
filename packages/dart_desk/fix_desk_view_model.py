import re
with open('lib/src/studio/core/view_models/desk_view_model.dart', 'r') as f:
    content = f.read()

content = content.replace("  late final hasUnpublishedChanges = Computed<bool>(() {", "  late final hasUnpublishedChanges = Computed<bool>(() { try {")
content = content.replace("  }, options: ComputedOptions(name: 'hasUnpublishedChanges'));", "  } catch (e, s) { print('hasUnpublishedChanges ERROR: $e\\n$s'); throw e; } }, options: ComputedOptions(name: 'hasUnpublishedChanges'));")

with open('lib/src/studio/core/view_models/desk_view_model.dart', 'w') as f:
    f.write(content)
