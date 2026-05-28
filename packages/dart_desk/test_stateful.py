import re

filepath = 'lib/src/studio/screens/document_list.dart'
with open(filepath, 'r') as f:
    content = f.read()

# Replace class _DocumentStatusPill extends StatelessWidget {
# with StatefulWidget and State

old_class = """class _DocumentStatusPill extends StatelessWidget {
  final String documentId;
  final DeskViewModel viewModel;

  const _DocumentStatusPill({
    required this.documentId,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final versionsState = viewModel.versionsContainer(documentId).value;"""

new_class = """class _DocumentStatusPill extends StatefulWidget {
  final String documentId;
  final DeskViewModel viewModel;

  const _DocumentStatusPill({
    required this.documentId,
    required this.viewModel,
  });

  @override
  State<_DocumentStatusPill> createState() => _DocumentStatusPillState();
}

class _DocumentStatusPillState extends State<_DocumentStatusPill> {
  late final FutureSignal<DocumentList> _versionsSignal;

  @override
  void initState() {
    super.initState();
    _versionsSignal = widget.viewModel.versionsContainer(widget.documentId);
  }

  @override
  Widget build(BuildContext context) {
    final versionsState = _versionsSignal.value;"""

content = content.replace(old_class, new_class)

with open(filepath, 'w') as f:
    f.write(content)

