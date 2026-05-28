import re

def replace_file(filepath, replacements):
    with open(filepath, 'r') as f:
        content = f.read()
    
    for old, new in replacements:
        content = content.replace(old, new)
        
    with open(filepath, 'w') as f:
        f.write(content)

replace_file('lib/src/studio/core/view_models/desk_view_model.dart', [
    ('late final versionsContainer = SignalContainer(', 'late final SignalContainer<AsyncState<DeskDocumentVersions>, String, FutureSignal<DeskDocumentVersions>> versionsContainer = SignalContainer('),
    ('late final selectedDocumentContainer = SignalContainer(', 'late final SignalContainer<AsyncState<DeskDocument?>, String, FutureSignal<DeskDocument?>> selectedDocumentContainer = SignalContainer('),
    ('late final documentDataContainer = SignalContainer(', 'late final SignalContainer<AsyncState<Map<String, dynamic>?>, String, FutureSignal<Map<String, dynamic>?>> documentDataContainer = SignalContainer('),
    ('late final documentsContainer = SignalContainer(', 'late final SignalContainer<AsyncState<DocumentList>, String, FutureSignal<DocumentList>> documentsContainer = SignalContainer('),
])

