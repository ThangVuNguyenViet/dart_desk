import 'package:flutter/widgets.dart';

import '../data/cms_data_source.dart';
import 'dart_desk_config.dart';

/// InheritedWidget providing DartDesk context to descendant widgets.
///
/// Access via `DartDesk.of(context)`.
class DartDesk extends InheritedWidget {
  final DataSource dataSource;
  final VoidCallback signOut;
  final DartDeskConfig config;

  const DartDesk({
    super.key,
    required this.dataSource,
    required this.signOut,
    required this.config,
    required super.child,
  });

  static DartDesk of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<DartDesk>();
    assert(result != null, 'No DartDesk found in context');
    return result!;
  }

  static DartDesk? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DartDesk>();
  }

  @override
  bool updateShouldNotify(DartDesk oldWidget) {
    return dataSource != oldWidget.dataSource || config != oldWidget.config;
  }
}
