import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'CmsFileInput')
Widget preview() => ShadApp(
  home: CmsFileInput(
    field: const CmsFileField(
      name: 'document',
      title: 'Document Upload',
      option: CmsFileOption(),
    ),
  ),
);

class CmsFileInput extends StatefulWidget {
  final CmsFileField field;
  final CmsData? data;
  final ValueChanged<String?>? onChanged;

  const CmsFileInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<CmsFileInput> createState() => _CmsFileInputState();
}

class _CmsFileInputState extends State<CmsFileInput> {
  String? _fileUrl;
  String? _fileName;
  PlatformFile? _pickedFile;
  int? _fileSize;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _fileUrl = widget.data?.value?.toString();
    if (_fileUrl != null) {
      _fileName = _fileUrl!.split('/').last;
    }
    _isEnabled = widget.field.option.optional
        ? widget.data?.value != null
        : true;
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = result.files.first;
          _fileName = _pickedFile!.name;
          _fileSize = _pickedFile!.size;
          _fileUrl = null;
        });
        widget.onChanged?.call(_pickedFile!.path);
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast(description: Text('Failed to pick file: $e')));
      }
    }
  }

  void _removeFile() {
    setState(() {
      _fileUrl = null;
      _fileName = null;
      _pickedFile = null;
      _fileSize = null;
    });
    widget.onChanged?.call(null);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  IconData _getFileIcon(String? fileName) {
    if (fileName == null) return FontAwesomeIcons.solidFile;

    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return FontAwesomeIcons.solidFilePdf;
      case 'doc':
      case 'docx':
        return FontAwesomeIcons.file;
      case 'xls':
      case 'xlsx':
        return FontAwesomeIcons.solidFileExcel;
      case 'ppt':
      case 'pptx':
        return FontAwesomeIcons.solidFilePowerpoint;
      case 'zip':
      case 'rar':
      case '7z':
        return FontAwesomeIcons.solidFileZipper;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return FontAwesomeIcons.solidImage;
      case 'mp4':
      case 'avi':
      case 'mov':
        return FontAwesomeIcons.solidFileVideo;
      case 'mp3':
      case 'wav':
      case 'ogg':
        return FontAwesomeIcons.solidFileAudio;
      case 'txt':
        return FontAwesomeIcons.solidFileLines;
      default:
        return FontAwesomeIcons.solidFile;
    }
  }

  Widget _buildFileContent(ShadThemeData theme) {
    final hasFile = _fileName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasFile) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                FaIcon(
                  _getFileIcon(_fileName),
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fileName!,
                        style: theme.textTheme.small,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_fileSize != null)
                        Text(
                          _formatFileSize(_fileSize!),
                          style: theme.textTheme.small.copyWith(
                            color: theme.colorScheme.mutedForeground,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                ShadIconButton(
                  icon: const FaIcon(FontAwesomeIcons.xmark, size: 18),
                  onPressed: _removeFile,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ShadButton(
            onPressed: _selectFile,
            size: ShadButtonSize.sm,
            child: const Text('Change File'),
          ),
        ] else
          ShadButton(
            onPressed: _selectFile,
            size: ShadButtonSize.sm,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(FontAwesomeIcons.cloudArrowUp, size: 16),
                SizedBox(width: 8),
                Text('Upload File'),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.option.hidden) return const SizedBox.shrink();

    final theme = ShadTheme.of(context);
    final isOptional = widget.field.option.optional;

    if (!isOptional) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.field.title, style: theme.textTheme.small),
          const SizedBox(height: 8),
          _buildFileContent(theme),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.field.title,
          style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        OptionalFieldWrapper(
          isOptional: true,
          isEnabled: _isEnabled,
          onToggle: (value) {
            setState(() => _isEnabled = value);
            if (!value) widget.onChanged?.call(null);
          },
          child: _buildFileContent(theme),
        ),
      ],
    );
  }
}
