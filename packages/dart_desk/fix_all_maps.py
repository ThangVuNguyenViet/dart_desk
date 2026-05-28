import re

def replace_file(filepath, replacements):
    with open(filepath, 'r') as f:
        content = f.read()
    
    for old, new in replacements:
        content = content.replace(old, new)
        
    with open(filepath, 'w') as f:
        f.write(content)

replace_file('lib/src/studio/components/version/desk_version_history.dart', [
    ('return versionsState.map(', 'return versionsState.map<Widget>(')
])

replace_file('lib/src/testing/test_document_type_fixtures.dart', [
    ('selectedDocTitles = state.map(', 'selectedDocTitles = state.map<String?>('),
    ('return state.map(', 'return state.map<List<DropdownOption>>(')
])

replace_file('lib/src/studio/internal/get_it_desk_context.dart', [
    ('source.value.map(', 'source.value.map<List<DeskDocument>>(')
])

