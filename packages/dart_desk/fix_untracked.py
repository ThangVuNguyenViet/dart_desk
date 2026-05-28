import re

filepath = 'lib/src/studio/core/view_models/desk_view_model.dart'
with open(filepath, 'r') as f:
    content = f.read()

# Remove _untrackedRead definition
content = re.sub(r"  T _untrackedRead<T>\(T Function\(\) fn\) \{.*?\n  \}\n\n", "", content, flags=re.DOTALL)

# Replace _untrackedRead with untracked
content = content.replace("_untrackedRead(() => ", "untracked(() => ")

with open(filepath, 'w') as f:
    f.write(content)

