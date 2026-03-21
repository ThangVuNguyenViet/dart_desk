import 'package:flutter/material.dart';

import '../../media/browser/media_browser.dart';
import 'studio_coordinator.dart';
import 'studio_layout.dart';
import 'studio_route.dart';

class MediaRoute extends StudioRoute {
  @override
  Type get layout => StudioLayout;

  @override
  Uri toUri() => Uri.parse('/media');

  @override
  List<Object?> get props => ['media'];

  @override
  Widget build(StudioCoordinator coordinator, BuildContext context) =>
      MediaBrowser(
        dataSource: coordinator.dataSource,
        mode: MediaBrowserMode.standalone,
      );
}
