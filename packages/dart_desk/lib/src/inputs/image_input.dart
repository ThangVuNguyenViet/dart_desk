import 'dart:async';
import 'dart:developer';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../../studio.dart';
import '../data/desk_data_source.dart';
import '../data/models/image_types.dart';
import 'hotspot/framing_status.dart';
import 'image_input_view_model.dart';
import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

class DeskImageInput extends StatefulWidget {
  final DeskImageField field;
  final DeskData? data;
  final ValueChanged<Map<String, dynamic>?>? onChanged;
  final DataSource dataSource;
  final TransformUrlBuilder? transformUrl;

  const DeskImageInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
    required this.dataSource,
    this.transformUrl,
  });

  @override
  State<DeskImageInput> createState() => _DeskImageInputState();
}

class _DeskImageInputState extends State<DeskImageInput>
    with AutomaticKeepAliveClientMixin<DeskImageInput> {
  @override
  bool get wantKeepAlive => true;

  late final ImageInputViewModel _viewModel = ImageInputViewModel(
    dataSource: widget.dataSource,
    fieldName: widget.field.name,
  );
  late bool _isEnabled;
  Map<String, dynamic>? _lastValue;

  bool get _isOptional => widget.field.option?.optional ?? false;

  @override
  void initState() {
    super.initState();
    _viewModel.initFromData(widget.data?.value);
    final initial = widget.data?.value;
    _isEnabled = _isOptional ? initial != null : true;
    if (initial is Map) {
      _lastValue = Map<String, dynamic>.from(initial);
    }
  }

  @override
  void didUpdateWidget(DeskImageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the data prop changes, re-initialize from the new data.
    // Handles initial empty render → loaded data, and document switches.
    if (oldWidget.data != widget.data) {
      _viewModel.resetForNewData();
      _viewModel.initFromData(widget.data?.value);
      if (_isOptional) {
        setState(() => _isEnabled = widget.data?.value != null);
      }
    }
  }

  void _handleToggle(bool enabled) {
    setState(() {
      if (!enabled) {
        final ref = _viewModel.imageRef.value;
        final ext = _viewModel.externalUrl.value;
        if (ref != null) {
          _lastValue = ref.toMap();
        } else if (ext != null && ext.isNotEmpty) {
          _lastValue = ImageReference(externalUrl: ext).toMap();
        }
        _viewModel.clear();
        _isEnabled = false;
      } else {
        _isEnabled = true;
        _viewModel.resetForNewData();
        _viewModel.initFromData(_lastValue);
      }
    });
    widget.onChanged?.call(enabled ? _lastValue : null);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  List<String> get _allowedExtensions {
    final types = widget.field.option?.acceptedTypes;
    if (types == null) {
      return [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'bmp',
        'heic',
        'avif',
        'svg',
        'json',
        'mp4',
        'mov',
        'webm',
        'avi',
      ];
    }
    final exts = <String>[];
    for (final t in types) {
      switch (t) {
        case DeskMediaType.image:
          exts.addAll([
            'jpg',
            'jpeg',
            'png',
            'gif',
            'webp',
            'bmp',
            'heic',
            'avif',
          ]);
        case DeskMediaType.svg:
          exts.add('svg');
        case DeskMediaType.lottie:
          exts.add('json');
        case DeskMediaType.video:
          exts.addAll(['mp4', 'mov', 'webm', 'avi']);
      }
    }
    return exts;
  }

  String get _dropHint {
    final types = widget.field.option?.acceptedTypes;
    if (types == null) return 'Drop file or click to upload';
    final hasImage = types.any(
      (t) => t == DeskMediaType.image || t == DeskMediaType.svg,
    );
    final hasVideo = types.any((t) => t == DeskMediaType.video);
    final hasLottie = types.any((t) => t == DeskMediaType.lottie);
    if (hasVideo && !hasImage && !hasLottie) {
      return 'Drop video or click to upload';
    }
    if (hasLottie && !hasImage && !hasVideo) {
      return 'Drop JSON (Lottie) or click to upload';
    }
    if (hasImage && !hasVideo && !hasLottie) {
      return 'Drop image or click to upload';
    }
    return 'Drop file or click to upload';
  }

  MediaTypeFilter _mediaTypeFilter() {
    final types = widget.field.option?.acceptedTypes;
    if (types == null) return MediaTypeFilter.all;
    if (types.every((t) => t == DeskMediaType.video)) {
      return MediaTypeFilter.video;
    }
    if (types.every((t) => t == DeskMediaType.image || t == DeskMediaType.svg)) {
      return MediaTypeFilter.image;
    }
    return MediaTypeFilter.all;
  }

  Future<void> _handlePickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;
      await _runUpload(file.name, bytes);
    } catch (e) {
      log('Error occurred while picking file: $e');
    }
  }

  Future<void> _runUpload(String fileName, Uint8List bytes) async {
    final result = await _viewModel.upload.run((
      fileName: fileName,
      bytes: bytes,
    ));
    if (result != null && mounted) {
      widget.onChanged?.call(_viewModel.imageRef.value?.toMap());
    }
  }

  Future<void> _handleDrop(PerformDropEvent event) async {
    _viewModel.isDragOver.value = false;

    final items = event.session.items;
    if (items.isEmpty) return;

    final item = items.first;
    final reader = item.dataReader;
    if (reader == null) return;

    final completer = Completer<void>();
    reader.getFile(
      null,
      (file) async {
        try {
          final bytes = await file.readAll();
          final name = file.fileName ?? 'dropped_file';
          final ext = name.split('.').last.toLowerCase();
          if (!_allowedExtensions.contains(ext)) {
            log(
              'ImageInput: rejected drop — .$ext not in $_allowedExtensions',
            );
            completer.complete();
            return;
          }
          await _runUpload(name, bytes);
        } catch (e) {
          log('ImageInput: failed to read dropped file: $e');
        }
        completer.complete();
      },
      onError: (error) {
        log('ImageInput: drop error: $error');
        completer.complete();
      },
    );
    await completer.future;
  }

  void _removeImage() {
    _viewModel.clear();
    widget.onChanged?.call(null);
  }

  void _editCrop() {
    final ref = _viewModel.imageRef.value;
    if (ref == null) return;

    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ImageHotspotEditor(
          imageUrl: ref.publicUrl!,
          initialHotspot: ref.hotspot,
          initialCrop: ref.crop,
          initialMode: _viewModel.lastFramingMode.value,
          onModeChanged: (mode) => _viewModel.lastFramingMode.value = mode,
          onChanged: (result) {
            final updated = ref.copyWith(
              hotspot: result.hotspot,
              crop: result.crop,
            );
            _viewModel.updateImageRef(updated);
            widget.onChanged?.call(updated.toMap());
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _browseMedia() {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        scrollable: false,
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 600),
        child: MediaBrowser(
          dataSource: widget.dataSource,
          mode: MediaBrowserMode.picker,
          initialTypeFilter: _mediaTypeFilter(),
          onAssetSelected: (asset) {
            _viewModel.selectAsset(asset);
            widget.onChanged?.call(_viewModel.imageRef.value?.toMap());
            Navigator.of(context).pop();
          },
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildImagePreviewArea(ShadThemeData theme) {
    final ref = _viewModel.imageRef.watch(context);
    final uploadState = _viewModel.upload.watch(context);
    final dragOver = _viewModel.isDragOver.watch(context);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: dragOver
              ? theme.colorScheme.primary
              : theme.colorScheme.border,
          width: dragOver ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: _buildPreviewContent(theme, ref, uploadState.isLoading),
      ),
    );
  }

  Widget _buildFramingStatusChip(ShadThemeData theme, ImageReference ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(FramingStatus.labelFor(ref), style: theme.textTheme.small),
    );
  }

  Widget _buildPreviewContent(
    ShadThemeData theme,
    ImageReference? ref,
    bool isUploading,
  ) {
    if (isUploading) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildLocalBytesPreview(theme),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  'Uploading...',
                  style: theme.textTheme.small.copyWith(
                    color: Colors.white,
                    shadows: [
                      const Shadow(blurRadius: 4, color: Colors.black54),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (ref != null) {
      final mimeType = _viewModel.asset.value?.mimeType ?? '';
      final fileName = _viewModel.asset.value?.fileName ?? '';

      if (mimeType.startsWith('video/')) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.film,
                size: 48,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(height: 8),
              Text(
                fileName,
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }

      if (mimeType == 'application/json') {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.fileCode,
                size: 48,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(height: 8),
              Text(
                fileName,
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }

      final url = widget.transformUrl != null
          ? widget.transformUrl!(
              ref.publicUrl!,
              const ImageTransformParams(width: 600, fit: FitMode.clip),
            )
          : ref.publicUrl!;

      return Image.network(
        url,
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
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(color: theme.colorScheme.muted),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      );
    }

    final extUrl = _viewModel.externalUrl.value;
    if (extUrl != null && extUrl.isNotEmpty) {
      return Image.network(
        extUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.imagePortrait,
                  size: 48,
                  color: theme.colorScheme.mutedForeground,
                ),
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
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.cloudArrowUp,
            size: 32,
            color: theme.colorScheme.mutedForeground,
          ),
          const SizedBox(height: 8),
          Text(
            _dropHint,
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalBytesPreview(ShadThemeData theme) {
    final bytes = _viewModel.pickedBytes.watch(context);
    if (bytes == null) {
      return Container(color: theme.colorScheme.muted);
    }
    return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    if (widget.field.option?.hidden ?? false) {
      return const SizedBox.shrink();
    }

    final theme = ShadTheme.of(context);
    final ref = _viewModel.imageRef.watch(context);
    final uploadState = _viewModel.upload.watch(context);
    final externalUrl = _viewModel.externalUrl.watch(context);
    final hasImage = ref != null;
    final hasExternalUrl = externalUrl != null && externalUrl.isNotEmpty;
    final hasAnyValue = hasImage || hasExternalUrl;
    final hotspotEnabled = widget.field.option?.hotspot ?? false;
    final isUploading = uploadState.isLoading;
    final errorText = uploadState.hasError
        ? 'Upload failed: ${uploadState.error}'
        : null;
    final isAssetMode = hasImage && ref.publicUrl != null;

    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) {
        _viewModel.isDragOver.value = true;
        return DropOperation.copy;
      },
      onDropLeave: (_) {
        _viewModel.isDragOver.value = false;
      },
      onDropEnded: (_) {
        _viewModel.isDragOver.value = false;
      },
      onPerformDrop: _handleDrop,
      child: Column(
        key: ValueKey('image_input_${widget.field.name}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OptionalFieldHeader(
            title: widget.field.title,
            isOptional: _isOptional,
            isEnabled: _isEnabled,
            onToggle: _handleToggle,
          ),
          SizedBox(height: DeskSpacing.md),

          OptionalFieldWrapper(
            isEnabled: !_isOptional || _isEnabled,
            child: GestureDetector(
              onTap: isUploading ? null : _handlePickFile,
              child: _buildImagePreviewArea(theme),
            ),
          ),

          if (ref != null && hotspotEnabled) ...[
            const SizedBox(height: 8),
            _buildFramingStatusChip(theme, ref),
          ],

          if (errorText != null) ...[
            const SizedBox(height: 4),
            Text(
              errorText,
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.destructive,
              ),
            ),
          ],

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ShadButton.outline(
                key: const ValueKey('upload_button'),
                onPressed: isUploading ? null : _handlePickFile,
                size: ShadButtonSize.sm,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(FontAwesomeIcons.cloudArrowUp, size: 14),
                    SizedBox(width: 4),
                    Text('Upload'),
                  ],
                ),
              ),
              ShadButton.outline(
                key: const ValueKey('browse_media_button'),
                onPressed: isUploading ? null : _browseMedia,
                size: ShadButtonSize.sm,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(FontAwesomeIcons.images, size: 14),
                    SizedBox(width: 4),
                    Text('Browse media'),
                  ],
                ),
              ),
              if (hotspotEnabled && hasImage)
                ShadButton.outline(
                  key: const ValueKey('edit_framing_button'),
                  onPressed: _editCrop,
                  size: ShadButtonSize.sm,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(FontAwesomeIcons.cropSimple, size: 14),
                      SizedBox(width: 4),
                      Text('Edit framing'),
                    ],
                  ),
                ),
              if (hasAnyValue)
                ShadButton.destructive(
                  key: const ValueKey('remove_button'),
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

          const SizedBox(height: 8),

          if (isAssetMode)
            ShadInput(
              key: const ValueKey('url_display'),
              initialValue: ref.publicUrl!,
              readOnly: true,
              trailing: ShadButton.ghost(
                size: ShadButtonSize.sm,
                width: 32,
                padding: EdgeInsets.zero,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: ref.publicUrl!));
                  ShadToaster.of(context).show(
                    const ShadToast(
                      description: Text('URL copied to clipboard'),
                    ),
                  );
                },
                child: const FaIcon(FontAwesomeIcons.copy, size: 14),
              ),
            )
          else
            ShadInputFormField(
              key: const ValueKey('url_input'),
              placeholder: const Text('https://example.com/image.png'),
              initialValue: externalUrl ?? '',
              onChanged: (value) {
                _viewModel.setExternalUrl(value);
                if (value.isNotEmpty) {
                  widget.onChanged?.call(
                    ImageReference(externalUrl: value).toMap(),
                  );
                } else {
                  widget.onChanged?.call(null);
                }
              },
            ),
        ],
      ),
    );
  }
}
