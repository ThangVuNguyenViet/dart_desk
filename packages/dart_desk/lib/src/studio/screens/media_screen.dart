import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../media/browser/media_browser.dart';
import '../config/studio_config.dart';

@RoutePage()
class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final config = GetIt.I<StudioConfig>();
    return MediaBrowser(
      dataSource: config.dataSource,
      mode: MediaBrowserMode.standalone,
    );
  }
}
