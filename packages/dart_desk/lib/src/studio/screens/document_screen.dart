import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class DocumentScreen extends StatelessWidget {
  const DocumentScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
    @PathParam('documentId') required this.documentId,
  });

  final String documentTypeSlug;
  final String documentId;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
