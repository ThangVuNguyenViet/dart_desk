import re

filepath = 'lib/src/studio/core/view_models/desk_view_model.dart'
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("import 'package:signals_core/signals_core.dart' as core;", "import 'package:signals/signals_core.dart' as core;")

with open(filepath, 'w') as f:
    f.write(content)

