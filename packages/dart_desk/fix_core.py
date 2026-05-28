import re

filepath = 'lib/src/studio/core/view_models/desk_view_model.dart'
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("import 'package:signals/signals_core.dart' as core;", "")
content = content.replace("final old = core.onSignalRead;", "final old = onSignalRead;")
content = content.replace("core.onSignalRead = null;", "onSignalRead = null;")
content = content.replace("return core.untracked(fn);", "return untracked(fn);")
content = content.replace("core.onSignalRead = old;", "onSignalRead = old;")

with open(filepath, 'w') as f:
    f.write(content)

