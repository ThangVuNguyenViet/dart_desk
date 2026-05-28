import re

filepath = 'lib/src/studio/screens/document_list.dart'
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("""    // untrack the initialization so we don't accidentally mutate while tracked!
    final versionsState = untracked(() => viewModel.versionsContainer(documentId)).value;""",
"""    final versionsState = viewModel.versionsContainer(documentId).value;""")

with open(filepath, 'w') as f:
    f.write(content)

