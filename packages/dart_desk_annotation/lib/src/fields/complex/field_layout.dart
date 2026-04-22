import '../base/field.dart';

/// Base for layout nodes that control how fields are arranged in the UI.
///
/// [RowFields] and [ColumnFields] hold [DeskField] leaves directly.
/// [GroupFields] nests other [DeskFieldLayout] nodes for deeper structure.
sealed class DeskFieldLayout {
  final bool collapsible;
  final bool collapsed;

  const DeskFieldLayout({this.collapsible = false, this.collapsed = false});

  /// Recursively collect all leaf [DeskField] instances from this layout.
  List<DeskField> get flatFields;
}

/// Renders fields horizontally in a row.
class RowFields extends DeskFieldLayout {
  final List<DeskField> children;

  const RowFields({required this.children, super.collapsible, super.collapsed});

  @override
  List<DeskField> get flatFields => children;
}

/// Renders fields vertically in a column.
class ColumnFields extends DeskFieldLayout {
  final List<DeskField> children;

  const ColumnFields({
    required this.children,
    super.collapsible,
    super.collapsed,
  });

  @override
  List<DeskField> get flatFields => children;
}

/// Named group with a title header that nests other layouts.
class GroupFields extends DeskFieldLayout {
  final String title;
  final String? description;
  final List<DeskFieldLayout> children;

  const GroupFields({
    required this.title,
    this.description,
    required this.children,
    super.collapsible,
    super.collapsed,
  });

  @override
  List<DeskField> get flatFields =>
      children.expand((c) => c.flatFields).toList();
}
