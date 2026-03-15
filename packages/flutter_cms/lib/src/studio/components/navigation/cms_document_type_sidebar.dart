import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../providers/studio_provider.dart';
import '../../routes/document_type_route.dart';
import '../../routes/studio_coordinator.dart';
import '../common/cms_document_type_decoration.dart';
import '../common/cms_document_type_item.dart';

/// A sidebar widget that displays a list of CmsDocumentTypeDecoration navigation items
class CmsDocumentTypeSidebar extends StatelessWidget {
  final List<CmsDocumentTypeDecoration> documentTypeDecorations;
  final StudioCoordinator coordinator;
  final EdgeInsets? padding;
  final Widget? header;
  final Widget? footer;

  const CmsDocumentTypeSidebar({
    super.key,
    required this.documentTypeDecorations,
    required this.coordinator,
    this.padding,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = cmsViewModelProvider.of(context);

    return Watch((context) {
      final currentSlug = viewModel.currentDocumentTypeSlug.value;
      return Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: ListView(
              padding: padding ?? const EdgeInsets.all(8),
              children: [
                ...documentTypeDecorations.map((decoration) {
                  final isSelected =
                      currentSlug == decoration.documentType.name;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: CmsDocumentTypeItem(
                      documentType: decoration.documentType,
                      isSelected: isSelected,
                      icon: decoration.icon,
                      onTap: () {
                        coordinator.pushOrMoveToTop(
                          DocumentTypeRoute(decoration.documentType.name),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          if (footer != null) footer!,
        ],
      );
    });
  }
}
