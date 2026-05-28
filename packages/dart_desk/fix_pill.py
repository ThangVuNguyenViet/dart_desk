import re

filepath = 'lib/src/studio/screens/document_list.dart'
with open(filepath, 'r') as f:
    content = f.read()

replacement = """  @override
  Widget build(BuildContext context) {
    // untrack the initialization so we don't accidentally mutate while tracked!
    final versionsState = untracked(() => viewModel.versionsContainer(documentId)).value;
"""

content = content.replace("""  @override
  Widget build(BuildContext context) {
    AsyncState<DocumentVersionList>? versionsState;
    try {
      versionsState = viewModel.versionsContainer(documentId).value;
    } catch (e, stack) {
      print('CAUGHT: $e\\n$stack');
      rethrow;
    }""", replacement)

with open(filepath, 'w') as f:
    f.write(content)

