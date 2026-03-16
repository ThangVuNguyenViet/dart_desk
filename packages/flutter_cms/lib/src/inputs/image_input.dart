import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

@Preview(name: 'CmsImageInput')
Widget preview() => ShadApp(
  home: CmsImageInput(
    field: const CmsImageField(
      name: 'avatar',
      title: 'Profile Image',
      option: CmsImageOption(hotspot: false),
    ),
  ),
);

class CmsImageInput extends StatefulWidget {
  final CmsImageField field;
  final CmsData? data;
  final ValueChanged<String?>? onChanged;

  const CmsImageInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<CmsImageInput> createState() => _CmsImageInputState();
}

class _CmsImageInputState extends State<CmsImageInput> {
  late final TextEditingController _urlController;
  late final UndoHistoryController _undoController;
  String? _imageUrl;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.data?.value?.toString();
    _urlController = TextEditingController(text: _imageUrl ?? '');
    _undoController = UndoHistoryController();

    // Listen to text changes
    _urlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    final value = _urlController.text;
    setState(() {
      _imageUrl = value.trim().isEmpty ? null : value.trim();
      _pickedImage = null; // Clear picked image when URL is entered
    });
    widget.onChanged?.call(_imageUrl);
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    _undoController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Remove listener temporarily to avoid triggering onChange
        _urlController.removeListener(_onUrlChanged);
        setState(() {
          _pickedImage = image;
          _imageUrl = image.path;
          _urlController.text = image.path;
        });
        _urlController.addListener(_onUrlChanged);
        widget.onChanged?.call(image.path);
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast(description: Text('Failed to pick image: $e')));
      }
      rethrow;
    }
  }

  void _removeImage() {
    // Remove listener temporarily to avoid triggering onChange
    _urlController.removeListener(_onUrlChanged);
    setState(() {
      _imageUrl = null;
      _pickedImage = null;
      _urlController.clear();
    });
    _urlController.addListener(_onUrlChanged);
    widget.onChanged?.call(null);
  }

  Widget _buildImagePreview(ShadThemeData theme) {
    if (_imageUrl == null && _pickedImage == null) {
      return const SizedBox.shrink();
    }

    Widget imageWidget;

    if (_pickedImage != null && !_imageUrl!.startsWith('http')) {
      // Show local file preview
      imageWidget =
          kIsWeb
              ? Image.network(
                _pickedImage!.path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: FaIcon(FontAwesomeIcons.imagePortrait, size: 48),
                  );
                },
              )
              : Image.file(
                File(_pickedImage!.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: FaIcon(FontAwesomeIcons.imagePortrait, size: 48),
                  );
                },
              );
    } else if (_imageUrl != null) {
      // Show URL-based image
      imageWidget = Image.network(
        _imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.imagePortrait, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.option?.hidden ?? false) {
      return const SizedBox.shrink();
    }

    final theme = ShadTheme.of(context);
    final hasImage = _imageUrl != null || _pickedImage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.field.title,
          style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // URL Input field with upload button
        Row(
          children: [
            Expanded(
              child: ShadInputFormField(
                controller: _urlController,
                undoController: _undoController,
                placeholder: const Text('Enter image URL or upload...'),
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            ShadButton.outline(
              onPressed: _selectImage,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.cloudArrowUp, size: 16),
                  SizedBox(width: 4),
                  Text('Upload'),
                ],
              ),
            ),
          ],
        ),

        // Image preview
        if (hasImage) ...[
          const SizedBox(height: 16),
          _buildImagePreview(theme),
          const SizedBox(height: 8),
          Row(
            children: [
              if (_pickedImage != null)
                Expanded(
                  child: Text(
                    'File: ${_pickedImage!.name}',
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (_pickedImage == null) const Spacer(),
              ShadButton.destructive(
                onPressed: _removeImage,
                size: ShadButtonSize.sm,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(FontAwesomeIcons.trash, size: 14),
                    SizedBox(width: 4),
                    Text('Remove'),
                  ],
                ),
              ),
            ],
          ),
        ],

        // Hotspot indicator
        if (widget.field.option?.hotspot ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.cropSimple,
                  size: 14,
                  color: theme.colorScheme.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  'Hotspot enabled',
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
