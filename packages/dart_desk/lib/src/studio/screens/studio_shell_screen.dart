import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/cms_data_source.dart';
import '../components/common/cms_top_bar.dart';
import '../components/navigation/cms_document_type_sidebar.dart';
import '../config/studio_config.dart';
import '../core/view_models/cms_view_model.dart';
import '../providers/studio_provider.dart';
import '../router/studio_router.dart';
import '../theme/spacing.dart';

@RoutePage()
class StudioShellScreen extends StatefulWidget {
  const StudioShellScreen({super.key});

  @override
  State<StudioShellScreen> createState() => _StudioShellScreenState();
}

class _StudioShellScreenState extends State<StudioShellScreen> {
  late final StackRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // StackRouter is a Listenable — use auto_route's native interface.
    // didChangeDependencies can be called more than once; guard against
    // double-registration by always removing before re-adding.
    _router = context.router;
    _router.removeListener(_onRouteChanged);
    _router.addListener(_onRouteChanged);
    _onRouteChanged();
  }

  @override
  void dispose() {
    _router.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    final params = _router.current.params;
    final vm = GetIt.I<CmsViewModel>();
    final docId = params.optString('documentId');
    final versionId = params.optString('versionId');
    batch(() {
      vm.currentDocumentTypeSlug.value = params.optString('documentTypeSlug');
      vm.currentDocumentId.value = docId;
      vm.selectedDocumentId.value =
          docId != null ? int.tryParse(docId) : null;
      vm.currentVersionId.value = versionId;
      vm.selectedVersionId.value =
          versionId != null ? int.tryParse(versionId) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = GetIt.I<StudioConfig>();

    return StudioProvider(
      dataSource: config.dataSource,
      documentTypes: config.documentTypes,
      child: Builder(
        builder: (context) => Column(
          children: [
            const CmsTopBar(),
            const Divider(height: 1),
            Expanded(
              child: Row(
                children: [
                  CmsDocumentTypeSidebar(
                    documentTypeDecorations: config.documentTypeDecorations,
                    footer: ShadButton.ghost(
                      key: const ValueKey('sidebar_media_button'),
                      onPressed: () =>
                          context.router.navigate(const MediaScreenRoute()),
                      child: const Row(
                        children: [
                          FaIcon(FontAwesomeIcons.images, size: 14),
                          SizedBox(width: CmsSpacing.sm),
                          Text('Media Library'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: AutoRouter()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
