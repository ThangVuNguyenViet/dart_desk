import re

filepath = 'lib/src/testing/test_document_type_fixtures.dart'
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace('state.map<List<DropdownOption>>(', 'state.map<List<DropdownOption<String>>>(')

with open(filepath, 'w') as f:
    f.write(content)
