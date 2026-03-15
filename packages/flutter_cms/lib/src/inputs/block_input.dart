import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:super_editor/super_editor.dart';

@Preview(name: 'CmsBlockInput')
Widget preview() => ShadApp(
  home: CmsBlockInput(
    field: const CmsBlockField(
      name: 'content',
      title: 'Content',
      option: CmsBlockOption(),
    ),
  ),
);

class CmsBlockInput extends StatefulWidget {
  final CmsBlockField field;
  final CmsData? data;
  final ValueChanged<dynamic>? onChanged;

  const CmsBlockInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<CmsBlockInput> createState() => _CmsBlockInputState();
}

class _CmsBlockInputState extends State<CmsBlockInput> {
  late final MutableDocument _document;
  late final MutableDocumentComposer _composer;
  late final Editor _editor;
  late final FocusNode _editorFocusNode;

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
  }

  void _onDocumentChange(_) {
    final markdown = serializeDocumentToMarkdown(_document);
    widget.onChanged?.call(markdown);
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
        Text(widget.field.title, style: theme.textTheme.large),
        SizedBox(height: 12),
        ShadCard(
          padding: EdgeInsets.zero,
          child: Column(
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

class _BlockEditorToolbar extends StatelessWidget {
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
          paragraphMetadata: {if (blockType != null) 'blockType': blockType},
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

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final iconColor = theme.colorScheme.foreground;

    return ListenableBuilder(
      listenable: composer.selectionNotifier,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Wrap(
            children: [
              _ToolbarButton(
                icon: Icons.format_bold,
                tooltip: 'Bold',
                iconColor: iconColor,
                onPressed: () => _toggle({boldAttribution}),
              ),
              _ToolbarButton(
                icon: Icons.format_italic,
                tooltip: 'Italic',
                iconColor: iconColor,
                onPressed: () => _toggle({italicsAttribution}),
              ),
              _ToolbarButton(
                icon: Icons.format_underlined,
                tooltip: 'Underline',
                iconColor: iconColor,
                onPressed: () => _toggle({underlineAttribution}),
              ),
              _ToolbarButton(
                icon: Icons.strikethrough_s,
                tooltip: 'Strikethrough',
                iconColor: iconColor,
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
                icon: Icons.title,
                tooltip: 'Header 1',
                iconColor: iconColor,
                onPressed: () => _setBlockType(header1Attribution),
              ),
              _ToolbarButton(
                icon: Icons.text_fields,
                tooltip: 'Header 2',
                iconColor: iconColor,
                onPressed: () => _setBlockType(header2Attribution),
              ),
              _ToolbarButton(
                icon: Icons.text_format,
                tooltip: 'Paragraph',
                iconColor: iconColor,
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
                icon: Icons.format_list_bulleted,
                tooltip: 'Bullet list',
                iconColor: iconColor,
                onPressed: () => _convertToListItem(ListItemType.unordered),
              ),
              _ToolbarButton(
                icon: Icons.format_list_numbered,
                tooltip: 'Numbered list',
                iconColor: iconColor,
                onPressed: () => _convertToListItem(ListItemType.ordered),
              ),
              _ToolbarButton(
                icon: Icons.format_quote,
                tooltip: 'Blockquote',
                iconColor: iconColor,
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
  });

  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: iconColor),
        splashRadius: 16,
        padding: EdgeInsets.zero,
        tooltip: tooltip,
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
