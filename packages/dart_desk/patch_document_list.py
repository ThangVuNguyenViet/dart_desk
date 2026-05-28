import re

filepath = 'lib/src/studio/screens/document_list.dart'
with open(filepath, 'r') as f:
    content = f.read()

replacement = """  @override
  Widget build(BuildContext context) {
    AsyncState<DocumentVersionList>? versionsState;
    try {
      versionsState = viewModel.versionsContainer(documentId).value;
    } catch (e, stack) {
      print('CAUGHT: $e\\n$stack');
      rethrow;
    }
"""

content = content.replace("  @override\n  Widget build(BuildContext context) {\n    final versionsState = viewModel\n        .versionsContainer(documentId)\n        .value;", replacement)

with open(filepath, 'w') as f:
    f.write(content)

