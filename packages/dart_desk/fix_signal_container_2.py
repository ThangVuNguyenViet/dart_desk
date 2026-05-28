import re

def replace_file(filepath, replacements):
    with open(filepath, 'r') as f:
        content = f.read()
    
    for old, new in replacements:
        content = content.replace(old, new)
        
    with open(filepath, 'w') as f:
        f.write(content)

replace_file('lib/src/studio/core/view_models/desk_view_model.dart', [
    ('late final SignalContainer<AsyncState<DeskDocumentVersions>, String, FutureSignal<DeskDocumentVersions>> versionsContainer = SignalContainer(', 'late final SignalContainer<AsyncState<DocumentVersionList>, String, FutureSignal<DocumentVersionList>> versionsContainer = SignalContainer('),
    ('import \'package:signals/signals_flutter.dart\';', 'import \'package:signals/signals_flutter.dart\';\nimport \'package:dart_desk_client/dart_desk_client.dart\';\nimport \'../../../data/models/document_list.dart\';'),
])

