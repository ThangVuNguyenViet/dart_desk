import 'package:flutter/widgets.dart';

/// A generic container for CMS data with metadata.
///
/// [CmsData] wraps a value of type [T] along with its path
/// in the CMS data structure.
class CmsData<T> {
  /// The actual data value.
  final T value;

  /// The path to this data in the CMS structure.
  final String path;

  const CmsData({required this.value, required this.path});
}

/// A Flutter widget builder for CMS data.
///
/// [CmsDataBuilder] provides a convenient way to build widgets
/// from [CmsData] values.
class CmsDataBuilder<T> extends StatelessWidget {
  const CmsDataBuilder({super.key, required this.builder, required this.data});
  final Widget Function(T value) builder;
  final CmsData<T> data;
  @override
  Widget build(BuildContext context) {
    return builder(data.value);
  }
}
