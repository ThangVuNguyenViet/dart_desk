import re

filepath = 'lib/src/studio/core/view_models/desk_view_model.dart'
with open(filepath, 'r') as f:
    content = f.read()

# Fix documentDataContainer
content = content.replace('SignalContainer<AsyncState<Map<String, dynamic>?>, String, FutureSignal<Map<String, dynamic>?>> documentDataContainer', 'SignalContainer<AsyncState<DocumentVersion?>, String, FutureSignal<DocumentVersion?>> documentDataContainer')

# Add collection import
if 'package:collection/collection.dart' not in content:
    content = content.replace("import 'package:signals/signals.dart';", "import 'package:signals/signals.dart';\nimport 'package:collection/collection.dart';")

with open(filepath, 'w') as f:
    f.write(content)
