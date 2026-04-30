import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widget_previews.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:super_editor/super_editor.dart';

import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'DeskBlockInput')
Widget preview() => ShadApp(
  home: DeskBlockInput(
    field: const DeskBlockField(
      name: 'content',
      title: 'Content',
      option: DeskBlockOption(),
    ),
  ),
);

class DeskBlockInput extends StatefulWidget {
  final DeskBlockField field;
  final DeskData? data;
  final ValueChanged<dynamic>? onChanged;

  const DeskBlockInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<DeskBlockInput> createState() => _DeskBlockInputState();
}

class _DeskBlockInputState extends State<DeskBlockInput> {
  late final MutableDocument _document;
  late final MutableDocumentComposer _composer;
  late final Editor _editor;
  late final FocusNode _editorFocusNode;
  late bool _isEnabled;
  String? _lastValue;
  bool _suppressEmit = false;

  bool get _isOptional => widget.field.option.optional;

  @override
  void initState() {
    super.initState();

    _editorFocusNode = FocusNode();
    _document = _createDocumentFromData()..addListener(_onDocumentChange);
    _composer = MutableDocumentComposer();

    _editor = createDefaultDocumentEditor(
      document: _document,
      composer: _composer,
      isHistoryEnabled: true,
    );

    final initial = widget.data?.value;
    _isEnabled = _isOptional ? initial != null : true;
    _lastValue = initial?.toString();
  }

  void _onDocumentChange(_) {
    if (_suppressEmit || !_isEnabled) return;
    final markdown = serializeDocumentToMarkdown(_document);
    _lastValue = markdown;
    widget.onChanged?.call(markdown);
  }

  void _handleToggle(bool enabled) {
    setState(() {
      if (!enabled) {
        _lastValue = serializeDocumentToMarkdown(_document);
        _isEnabled = false;
      } else {
        _isEnabled = true;
        _replaceDocumentText(_lastValue);
      }
    });
    widget.onChanged?.call(enabled ? (_lastValue ?? '') : null);
  }

  void _replaceDocumentText(String? text) {
    _suppressEmit = true;
    final ids = _document.map((n) => n.id).toList();
    for (final id in ids) {
      _document.deleteNode(id);
    }
    if (text == null || text.isEmpty) {
      _document.add(
        ParagraphNode(id: Editor.createNodeId(), text: AttributedText()),
      );
    } else {
      _document.add(
        ParagraphNode(id: Editor.createNodeId(), text: AttributedText(text)),
      );
    }
    _suppressEmit = false;
  }

  MutableDocument _createDocumentFromData() {
    final dataValue = widget.data?.value;

    if (dataValue == null || (dataValue is String && dataValue.isEmpty)) {
      return MutableDocument(
        nodes: [
          ParagraphNode(id: Editor.createNodeId(), text: AttributedText()),
        ],
      );
    }

    final text = dataValue.toString();
    return MutableDocument(
      nodes: [
        ParagraphNode(id: Editor.createNodeId(), text: AttributedText(text)),
      ],
    );
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    _composer.dispose();
    _editor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.option.hidden) {
      return const SizedBox.shrink();
    }

    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionalFieldHeader(
          title: widget.field.title,
          isOptional: _isOptional,
          isEnabled: _isEnabled,
          onToggle: _handleToggle,
        ),
        SizedBox(height: 12),
        OptionalFieldWrapper(
          isEnabled: !_isOptional || _isEnabled,
          child: ShadCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BlockEditorToolbar(
                  editor: _editor,
                  document: _document,
                  composer: _composer,
                  editorFocusNode: _editorFocusNode,
                ),
                const Divider(height: 1),
                _FakeViewport(
                  child: SuperEditor(
                    editor: _editor,
                    focusNode: _editorFocusNode,
                    stylesheet: _buildStylesheet(theme),
                    documentOverlayBuilders: [
                      DefaultCaretOverlayBuilder(
                        caretStyle: const CaretStyle().copyWith(
                          color: theme.colorScheme.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Stylesheet _buildStylesheet(ShadThemeData theme) {
    return defaultStylesheet.copyWith(
      addRulesAfter: [
        StyleRule(BlockSelector.all, (doc, docNode) {
          return {
            Styles.textStyle: TextStyle(
              color: theme.colorScheme.foreground,
              fontSize: 14,
              height: 1.5,
            ),
          };
        }),
        StyleRule(const BlockSelector('header1'), (doc, docNode) {
          return {
            Styles.textStyle: theme.textTheme.h1.copyWith(
              color: theme.colorScheme.foreground,
            ),
          };
        }),
        StyleRule(const BlockSelector('header2'), (doc, docNode) {
          return {
            Styles.textStyle: theme.textTheme.h2.copyWith(
              color: theme.colorScheme.foreground,
            ),
          };
        }),
        StyleRule(const BlockSelector('header3'), (doc, docNode) {
          return {
            Styles.textStyle: theme.textTheme.h3.copyWith(
              color: theme.colorScheme.foreground,
            ),
          };
        }),
      ],
    );
  }
}

class _BlockEditorToolbar extends StatefulWidget {
  const _BlockEditorToolbar({
    required this.editor,
    required this.document,
    required this.composer,
    required this.editorFocusNode,
  });

  final Editor editor;
  final MutableDocument document;
  final MutableDocumentComposer composer;
  final FocusNode editorFocusNode;

  @override
  State<_BlockEditorToolbar> createState() => _BlockEditorToolbarState();
}

class _BlockEditorToolbarState extends State<_BlockEditorToolbar> {
  Editor get editor => widget.editor;
  MutableDocument get document => widget.document;
  MutableDocumentComposer get composer => widget.composer;
  FocusNode get editorFocusNode => widget.editorFocusNode;

  @override
  void initState() {
    super.initState();
    document.addListener(_onDocumentChange);
  }

  @override
  void dispose() {
    document.removeListener(_onDocumentChange);
    super.dispose();
  }

  void _onDocumentChange(DocumentChangeLog changeLog) {
    // Rebuild toolbar to reflect attribution changes
    setState(() {});
  }

  void _toggle(Set<Attribution> attributions) {
    final selection = composer.selection;
    if (selection == null) return;

    editor.execute([
      ToggleTextAttributionsRequest(
        documentRange: selection,
        attributions: attributions,
      ),
    ]);
    editorFocusNode.requestFocus();
  }

  void _setBlockType(Attribution? blockType) {
    final selection = composer.selection;
    if (selection == null) return;

    final node = document.getNodeById(selection.extent.nodeId);
    if (node is ListItemNode) {
      editor.execute([
        ConvertListItemToParagraphRequest(
          nodeId: node.id,
          paragraphMetadata: {'blockType': ?blockType},
        ),
      ]);
    } else if (node is ParagraphNode) {
      editor.execute([
        ChangeParagraphBlockTypeRequest(nodeId: node.id, blockType: blockType),
      ]);
    }
    editorFocusNode.requestFocus();
  }

  void _convertToListItem(ListItemType type) {
    final selection = composer.selection;
    if (selection == null) return;

    final node = document.getNodeById(selection.extent.nodeId);
    if (node is ListItemNode) {
      editor.execute([
        ChangeListItemTypeRequest(nodeId: node.id, newType: type),
      ]);
    } else {
      editor.execute([
        ConvertParagraphToListItemRequest(
          nodeId: selection.extent.nodeId,
          type: type,
        ),
      ]);
    }
    editorFocusNode.requestFocus();
  }

  /// Returns the set of inline attributions active in the current selection.
  Set<Attribution> _activeInlineAttributions() {
    final selection = composer.selection;
    if (selection == null) return {};
    return document.getAllAttributions(selection);
  }

  /// Returns the block-level attribution of the node at the current selection.
  Attribution? _activeBlockAttribution() {
    final selection = composer.selection;
    if (selection == null) return null;

    final node = document.getNodeById(selection.extent.nodeId);
    if (node is ListItemNode) return null;
    if (node is ParagraphNode) {
      return node.getMetadataValue('blockType') as Attribution?;
    }
    return null;
  }

  /// Returns the list item type if the current node is a list item.
  ListItemType? _activeListItemType() {
    final selection = composer.selection;
    if (selection == null) return null;

    final node = document.getNodeById(selection.extent.nodeId);
    if (node is ListItemNode) return node.type;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final iconColor = theme.colorScheme.foreground;

    return ListenableBuilder(
      listenable: composer.selectionNotifier,
      builder: (context, _) {
        final inlineAttrs = _activeInlineAttributions();
        final blockAttr = _activeBlockAttribution();
        final listType = _activeListItemType();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Wrap(
            alignment: WrapAlignment.start,
            children: [
              _ToolbarButton(
                icon: FontAwesomeIcons.bold,
                tooltip: 'Bold',
                iconColor: iconColor,
                isActive: inlineAttrs.contains(boldAttribution),
                onPressed: () => _toggle({boldAttribution}),
              ),
              _ToolbarButton(
                icon: FontAwesomeIcons.italic,
                tooltip: 'Italic',
                iconColor: iconColor,
                isActive: inlineAttrs.contains(italicsAttribution),
                onPressed: () => _toggle({italicsAttribution}),
              ),
              _ToolbarButton(
                icon: FontAwesomeIcons.underline,
                tooltip: 'Underline',
                iconColor: iconColor,
                isActive: inlineAttrs.contains(underlineAttribution),
                onPressed: () => _toggle({underlineAttribution}),
              ),
              _ToolbarButton(
                icon: FontAwesomeIcons.strikethrough,
                tooltip: 'Strikethrough',
                iconColor: iconColor,
                isActive: inlineAttrs.contains(strikethroughAttribution),
                onPressed: () => _toggle({strikethroughAttribution}),
              ),
              SizedBox(
                height: 24,
                child: VerticalDivider(
                  width: 16,
                  color: theme.colorScheme.border,
                ),
              ),
              _ToolbarButton(
                icon: FontAwesomeIcons.heading,
                tooltip: 'Header 1',
                iconColor: iconColor,
                isActive: blockAttr == header1Attribution,
                onPressed: () => _setBlockType(header1Attribution),
              ),
              _ToolbarButton(
                icon: FontAwesomeIcons.font,
                tooltip: 'Header 2',
                iconColor: iconColor,
                isActive: blockAttr == header2Attribution,
                onPressed: () => _setBlockType(header2Attribution),
              ),
              _ToolbarButton(
                icon: FontAwesomeIcons.textHeight,
                tooltip: 'Paragraph',
                iconColor: iconColor,
                isActive:
                    blockAttr == paragraphAttribution ||
                    blockAttr == null && listType == null,
                onPressed: () => _setBlockType(null),
              ),
              SizedBox(
                height: 24,
                child: VerticalDivider(
                  width: 16,
                  color: theme.colorScheme.border,
                ),
              ),
              _ToolbarButton(
                icon: FontAwesomeIcons.listUl,
                tooltip: 'Bullet list',
                iconColor: iconColor,
                isActive: listType == ListItemType.unordered,
                onPressed: () => _convertToListItem(ListItemType.unordered),
              ),
              _ToolbarButton(
                icon: FontAwesomeIcons.listOl,
                tooltip: 'Numbered list',
                iconColor: iconColor,
                isActive: listType == ListItemType.ordered,
                onPressed: () => _convertToListItem(ListItemType.ordered),
              ),
              _ToolbarButton(
                icon: FontAwesomeIcons.quoteLeft,
                tooltip: 'Blockquote',
                iconColor: iconColor,
                isActive: blockAttr == blockquoteAttribution,
                onPressed: () => _setBlockType(blockquoteAttribution),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return SizedBox(
      width: 32,
      height: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: FaIcon(
            icon,
            size: 18,
            color: isActive ? theme.colorScheme.primary : iconColor,
          ),
          splashRadius: 16,
          padding: EdgeInsets.zero,
          tooltip: tooltip,
        ),
      ),
    );
  }
}

class _FakeViewport extends SingleChildRenderObjectWidget {
  const _FakeViewport({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderFakeViewport();
  }
}

class _RenderFakeViewport extends RenderBox
    with RenderObjectWithChildMixin<RenderSliver>
    implements RenderAbstractViewport {
  @override
  void debugAssertDoesMeetConstraints() {}

  @override
  RevealedOffset getOffsetToReveal(
    RenderObject target,
    double alignment, {
    Rect? rect,
    Axis? axis,
  }) {
    return const RevealedOffset(offset: 0, rect: Rect.zero);
  }

  @override
  void setupParentData(RenderObject child) {}

  @override
  Rect get paintBounds => Offset.zero & size;

  @override
  void performLayout() {
    final childConstraints = SliverConstraints(
      axisDirection: AxisDirection.down,
      growthDirection: GrowthDirection.forward,
      userScrollDirection: ScrollDirection.forward,
      scrollOffset: 0,
      precedingScrollExtent: 0,
      overlap: 0,
      remainingPaintExtent: constraints.maxHeight,
      crossAxisExtent: constraints.maxWidth,
      crossAxisDirection: AxisDirection.right,
      viewportMainAxisExtent: constraints.maxHeight,
      remainingCacheExtent: double.infinity,
      cacheOrigin: 0,
    );
    child!.layout(childConstraints, parentUsesSize: true);
    final geometry = child!.geometry;
    size = Size(constraints.maxWidth, geometry!.scrollExtent);
  }

  RenderBox _getBox(RenderSliver sliver) {
    RenderSliver? firstSliver;
    RenderBox? firstBox;
    sliver.visitChildren((child) {
      if (child is RenderSliver && firstSliver == null) {
        firstSliver = child;
      }
      if (child is RenderBox && firstBox == null) {
        firstBox = child;
      }
    });
    return firstSliver != null ? _getBox(firstSliver!) : firstBox!;
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final layoutBox = _getBox(child!);
    return layoutBox.computeDryLayout(constraints);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final layoutBox = _getBox(child!);
    return layoutBox.computeMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final layoutBox = _getBox(child!);
    return layoutBox.computeMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final layoutBox = _getBox(child!);
    return layoutBox.computeMaxIntrinsicHeight(width);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final layoutBox = _getBox(child!);
    return layoutBox.computeMinIntrinsicHeight(width);
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return child!.hitTest(
      SliverHitTestResult.wrap(result),
      mainAxisPosition: position.dy,
      crossAxisPosition: position.dx,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);
  }

  @override
  void performResize() {}

  @override
  Rect get semanticBounds => Offset.zero & size;
}
