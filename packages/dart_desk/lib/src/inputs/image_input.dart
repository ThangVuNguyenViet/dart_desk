import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../data/cms_data_source.dart';
import '../data/models/image_reference.dart';
import '../data/models/image_types.dart';
import '../media/browser/media_browser.dart';
import '../media/image_transform_params.dart';
import '../media/image_url.dart';
import '../media/quick_metadata_extractor.dart';
import 'hotspot/framing_controller.dart';
import 'hotspot/framing_status.dart';
import 'hotspot/image_hotspot_editor.dart';

enum _UploadState { idle, extractingMetadata, uploading, done, error }

enum _InputTab { upload, url }

class CmsImageInput extends StatefulWidget {
  final CmsImageField field;
  final CmsData? data;
  final ValueChanged<Map<String, dynamic>?>? onChanged;
  final DataSource dataSource;
  final TransformUrlBuilder? transformUrl;

  const CmsImageInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
    required this.dataSource,
    this.transformUrl,
  });

  @override
  State<CmsImageInput> createState() => _CmsImageInputState();
}

class _CmsImageInputState extends State<CmsImageInput> with SignalsMixin {
  late final _imageRef = createSignal<ImageReference?>(null);
  late final _uploadState = createSignal<_UploadState>(_UploadState.idle);
  late final _errorMessage = createSignal<String?>(null);
  late final _isDragOver = createSignal<bool>(false);
  late final _lastFramingMode = createSignal<FramingMode>(FramingMode.focus);
  late final _activeTab = createSignal<_InputTab>(_InputTab.upload);
  late final _externalUrl = createSignal<String?>(null);

  /// Temporary blurHash from the quick metadata extraction, used during upload.
  late final _uploadBlurHash = createSignal<String?>(null);

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initFromData();
  }

  @override
  void didUpdateWidget(CmsImageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the data prop changes, re-initialize from the new data.
    // This handles the case where the widget is first rendered with empty data
    // (editedData = {}), then the document loads and the field data is
    // populated — without a full widget recreation. Also handles navigating
    // to a different document (same widget, new data).
    if (oldWidget.data != widget.data) {
      _imageRef.value = null;
      _uploadState.value = _UploadState.idle;
      _errorMessage.value = null;
      _uploadBlurHash.value = null;
      _activeTab.value = _InputTab.upload;
      _externalUrl.value = null;
      _initFromData();
    }
  }

  void _initFromData() {
    final value = widget.data?.value;
    if (value is Map<String, dynamic> &&
        ImageReference.isImageReference(value)) {
      // Check for externalUrl first
      if (value['externalUrl'] != null) {
        _activeTab.value = _InputTab.url;
        _externalUrl.value = value['externalUrl'] as String;
        // Do NOT call _tryLoadImageReferenceFromData for externalUrl mode
      } else {
        // New format: ImageReference map with assetId. We have the assetId but
        // need the full MediaAsset to reconstruct. If dataSource is available,
        // fetch it. For now, we cannot fully reconstruct without the asset, so
        // we store what we can and leave the asset fetch for when dataSource
        // is present.
        _tryLoadImageReferenceFromData(value);
      }
    }
    // Legacy string URL is no longer supported in the new format,
    // but we handle it gracefully by ignoring it.
  }

  Future<void> _tryLoadImageReferenceFromData(Map<String, dynamic> json) async {
    final assetId = json['assetId'] as String?;
    if (assetId == null) return;

    try {
      final asset = await widget.dataSource.getMediaAsset(assetId);
      if (asset != null && mounted) {
        _imageRef.value = ImageReference.fromDocumentJson(json, asset);
      } else if (mounted) {
        log('ImageInput: getMediaAsset($assetId) returned null');
      }
    } catch (e) {
      log('ImageInput: getMediaAsset($assetId) threw: $e');
    }
  }

  Future<void> _handlePickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final fileName = image.name;
      await _uploadBytes(fileName, bytes);
    } catch (e) {
      _uploadState.value = _UploadState.error;
      _errorMessage.value = 'Failed to pick image: $e';
      log('Error occurred while picking image: $e');
    }
  }

  Future<void> _uploadBytes(String fileName, Uint8List bytes) async {
    _errorMessage.value = null;

    try {
      // Step 1: Extract quick metadata
      _uploadState.value = _UploadState.extractingMetadata;
      final metadata = await QuickMetadataExtractor.extract(bytes);
      _uploadBlurHash.value = metadata.blurHash;

      if (!mounted) return;

      // Step 2: Upload
      _uploadState.value = _UploadState.uploading;
      final asset = await widget.dataSource.uploadImage(
        fileName,
        bytes,
        metadata,
      );

      if (!mounted) return;

      // Step 3: Create ImageReference
      final imageRef = ImageReference(asset: asset);
      _imageRef.value = imageRef;
      _uploadState.value = _UploadState.done;
      _uploadBlurHash.value = null;

      widget.onChanged?.call(imageRef.toDocumentJson());
    } catch (e) {
      if (!mounted) return;
      _uploadState.value = _UploadState.error;
      _errorMessage.value = 'Upload failed: $e';
    }
  }

  Future<void> _handleDrop(PerformDropEvent event) async {
    _isDragOver.value = false;

    final items = event.session.items;
    if (items.isEmpty) return;

    final item = items.first;
    final reader = item.dataReader;
    if (reader == null) return;

    // Try to read as an image file
    final completer = Completer<void>();
    reader.getFile(
      null,
      (file) async {
        try {
          final bytes = await file.readAll();
          final name = file.fileName ?? 'dropped_image';
          await _uploadBytes(name, bytes);
        } catch (e) {
          _uploadState.value = _UploadState.error;
          _errorMessage.value = 'Failed to read dropped file: $e';
        }
        completer.complete();
      },
      onError: (error) {
        _uploadState.value = _UploadState.error;
        _errorMessage.value = 'Failed to read dropped file: $error';
        completer.complete();
      },
    );
    await completer.future;
  }

  void _removeImage() {
    _imageRef.value = null;
    _uploadState.value = _UploadState.idle;
    _errorMessage.value = null;
    _uploadBlurHash.value = null;
    widget.onChanged?.call(null);
  }

  void _removeExternalUrl() {
    _externalUrl.value = null;
    widget.onChanged?.call(null);
  }

  void _editCrop() {
    final ref = _imageRef.value;
    if (ref == null) return;

    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ImageHotspotEditor(
          imageUrl: ref.asset.publicUrl,
          initialHotspot: ref.hotspot,
          initialCrop: ref.crop,
          initialMode: _lastFramingMode.value,
          onModeChanged: (mode) => _lastFramingMode.value = mode,
          onChanged: (result) {
            final updated = ref.copyWith(
              hotspot: result.hotspot,
              crop: result.crop,
            );
            _imageRef.value = updated;
            widget.onChanged?.call(updated.toDocumentJson());
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
          onAssetSelected: (asset) {
            final imageRef = ImageReference(asset: asset);
            _imageRef.value = imageRef;
            _uploadState.value = _UploadState.done;
            widget.onChanged?.call(imageRef.toDocumentJson());
            Navigator.of(context).pop();
          },
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildImagePreviewArea(ShadThemeData theme) {
    final ref = _imageRef.value;
    final state = _uploadState.value;
    final blurHash = _uploadBlurHash.value;
    final dragOver = _isDragOver.value;

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
        child: _buildPreviewContent(theme, ref, state, blurHash),
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
    _UploadState state,
    String? blurHash,
  ) {
    // Uploading state: show blurHash placeholder with spinner
    if (state == _UploadState.extractingMetadata ||
        state == _UploadState.uploading) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (blurHash != null)
            _buildBlurHashPlaceholder(blurHash)
          else
            Container(color: theme.colorScheme.muted),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  state == _UploadState.extractingMetadata
                      ? 'Extracting metadata...'
                      : 'Uploading...',
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

    // Loaded state: show actual image
    if (ref != null) {
      final url = widget.transformUrl != null
          ? widget.transformUrl!(
              ref.asset.publicUrl,
              const ImageTransformParams(width: 600, fit: FitMode.clip),
            )
          : ref.asset.publicUrl;

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
              _buildBlurHashPlaceholder(ref.asset.blurHash),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      );
    }

    // Empty state: placeholder
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
            'Drop image or click to upload',
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlPreviewArea(ShadThemeData theme, String? url) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
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
              )
            : Center(
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
                      'Enter a URL above to preview',
                      style: theme.textTheme.small.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBlurHashPlaceholder(String hash) {
    // Decode blurHash to a small image for display as placeholder.
    // For simplicity, use a colored container based on the hash.
    // A full blurHash decode would require the blurhash_dart package at
    // render time. We use a simple solid color derived from the hash instead
    // to keep widget rendering synchronous.
    final color = _colorFromBlurHash(hash);
    return Container(color: color);
  }

  /// Derive a rough dominant color from a blurHash string.
  /// The first 4 characters of a blurHash encode the DC component (average color).
  Color _colorFromBlurHash(String hash) {
    if (hash.length < 6) return Colors.grey;
    try {
      // The DC value is encoded in characters 2..5 (base-83, 4 chars = up to 83^4)
      final dcValue = _decode83(hash.substring(2, 6));
      final r = (dcValue >> 16) & 0xFF;
      final g = (dcValue >> 8) & 0xFF;
      final b = dcValue & 0xFF;
      return Color.fromARGB(255, r, g, b);
    } catch (_) {
      return Colors.grey;
    }
  }

  static const _base83Chars =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#\$%*+,-.:;=?@[]^_{|}~';

  int _decode83(String str) {
    var value = 0;
    for (final c in str.codeUnits) {
      final idx = _base83Chars.indexOf(String.fromCharCode(c));
      if (idx == -1) return 0;
      value = value * 83 + idx;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.option?.hidden ?? false) {
      return const SizedBox.shrink();
    }

    final theme = ShadTheme.of(context);
    final ref = _imageRef.watch(context);
    final state = _uploadState.watch(context);
    final error = _errorMessage.watch(context);
    final activeTab = _activeTab.watch(context);
    final externalUrl = _externalUrl.watch(context);
    final hasImage = ref != null;
    final hotspotEnabled = widget.field.option?.hotspot ?? false;
    final isUploading =
        state == _UploadState.extractingMetadata ||
        state == _UploadState.uploading;

    // Build the upload tab content
    final uploadTabContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Image preview area
        GestureDetector(
          onTap: isUploading ? null : _handlePickImage,
          child: _buildImagePreviewArea(theme),
        ),

        if (ref != null && hotspotEnabled) ...[
          const SizedBox(height: 8),
          _buildFramingStatusChip(theme, ref),
        ],

        // Error message
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error,
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.destructive,
            ),
          ),
        ],

        const SizedBox(height: 8),

        // Action buttons row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Upload button
            ShadButton.outline(
              key: const ValueKey('upload_button'),
              onPressed: isUploading ? null : _handlePickImage,
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

            // Browse media button
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

            // Edit framing button (only if hotspot enabled and image loaded)
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

            // Remove button (only if image loaded)
            if (hasImage)
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
      ],
    );

    // Build the URL tab content
    final urlTabContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ShadInputFormField(
          key: const ValueKey('url_input'),
          placeholder: const Text('https://example.com/image.lottie'),
          initialValue: externalUrl ?? '',
          onChanged: (value) {
            _externalUrl.value = value.isEmpty ? null : value;
            if (value.isNotEmpty) {
              widget.onChanged?.call(ImageRef(externalUrl: value).toMap());
            } else {
              widget.onChanged?.call(null);
            }
          },
        ),
        const SizedBox(height: 8),
        _buildUrlPreviewArea(theme, externalUrl),
        if (externalUrl != null) ...[
          const SizedBox(height: 8),
          ShadButton.destructive(
            key: const ValueKey('remove_url_button'),
            onPressed: _removeExternalUrl,
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
      ],
    );

    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) {
        _isDragOver.value = true;
        return DropOperation.copy;
      },
      onDropLeave: (_) {
        _isDragOver.value = false;
      },
      onDropEnded: (_) {
        _isDragOver.value = false;
      },
      onPerformDrop: _handleDrop,
      child: Column(
        key: ValueKey('image_input_${widget.field.name}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title label
          Text(
            widget.field.title,
            style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
          ),

          // Tabs
          ShadTabs<String>(
            value: activeTab == _InputTab.upload ? 'upload' : 'url',
            onChanged: (value) {
              if (value == 'upload' && activeTab == _InputTab.url) {
                // Switching from url to upload: clear external URL
                _externalUrl.value = null;
                _activeTab.value = _InputTab.upload;
                widget.onChanged?.call(null);
              } else if (value == 'url' && activeTab == _InputTab.upload) {
                // Switching from upload to url: clear image ref
                _imageRef.value = null;
                _uploadState.value = _UploadState.idle;
                _errorMessage.value = null;
                _activeTab.value = _InputTab.url;
                widget.onChanged?.call(null);
              }
            },
            tabs: [
              ShadTab(
                value: 'upload',
                content: uploadTabContent,
                child: const Text('Upload'),
              ),
              ShadTab(
                value: 'url',
                content: urlTabContent,
                child: const Text('URL'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
