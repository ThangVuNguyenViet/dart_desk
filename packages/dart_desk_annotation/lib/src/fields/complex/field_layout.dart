import '../base/field.dart';

/// Base for layout nodes that control how fields are arranged in the UI.
///
/// [RowFields] and [ColumnFields] hold [CmsField] leaves directly.
/// [GroupFields] nests other [CmsFieldLayout] nodes for deeper structure.
sealed class CmsFieldLayout {
  final bool collapsible;
  final bool collapsed;

  const CmsFieldLayout({this.collapsible = false, this.collapsed = false});

  /// Recursively collect all leaf [CmsField] instances from this layout.
  List<CmsField> get flatFields;
}

/// Renders fields horizontally in a row.
class RowFields extends CmsFieldLayout {
  final List<CmsField> children;

  const RowFields({required this.children, super.collapsible, super.collapsed});

  @override
  List<CmsField> get flatFields => children;
}

/// Renders fields vertically in a column.
class ColumnFields extends CmsFieldLayout {
  final List<CmsField> children;

  const ColumnFields({
    required this.children,
    super.collapsible,
    super.collapsed,
  });

  @override
  List<CmsField> get flatFields => children;
}

/// Named group with a title header that nests other layouts.
class GroupFields extends CmsFieldLayout {
  final String title;
  final String? description;
  final List<CmsFieldLayout> children;

  const GroupFields({
    required this.title,
    this.description,
    required this.children,
    super.collapsible,
    super.collapsed,
  });

  @override
  List<CmsField> get flatFields =>
      children.expand((c) => c.flatFields).toList();
}
