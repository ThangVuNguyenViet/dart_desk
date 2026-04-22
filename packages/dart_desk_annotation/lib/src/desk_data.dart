import 'package:flutter/widgets.dart';

/// A generic container for CMS data with metadata.
///
/// [DeskData] wraps a value of type [T] along with its path
/// in the CMS data structure.
class DeskData<T> {
  /// The actual data value.
  final T value;

  /// The path to this data in the CMS structure.
  final String path;

  const DeskData({required this.value, required this.path});
}

/// A Flutter widget builder for CMS data.
///
/// [DeskDataBuilder] provides a convenient way to build widgets
/// from [DeskData] values.
class DeskDataBuilder<T> extends StatelessWidget {
  const DeskDataBuilder({super.key, required this.builder, required this.data});
  final Widget Function(T value) builder;
  final DeskData<T> data;
  @override
  Widget build(BuildContext context) {
    return builder(data.value);
  }
}
