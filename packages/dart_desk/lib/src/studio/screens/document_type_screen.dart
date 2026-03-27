import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class DocumentTypeScreen extends StatelessWidget {
  const DocumentTypeScreen({
    super.key,
    @PathParam('documentTypeSlug') required this.documentTypeSlug,
  });

  final String documentTypeSlug;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
