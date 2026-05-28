import re

filepath = 'lib/src/studio/core/view_models/desk_view_model.dart'
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("FutureSignal<DocumentList> documentsContainer(String documentType) => _untrackedRead(() => _documentsContainer(documentType));", "FutureSignal<DocumentList> documentsContainer(String documentType) => _documentsContainer(documentType);")

with open(filepath, 'w') as f:
    f.write(content)

