import 'dart:developer';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/services.dart';
import 'package:signals/signals.dart';

import '../data/desk_data_source.dart';
import '../data/models/image_reference.dart';
import '../data/models/media_asset.dart';
import '../studio/core/signals/mutation_signal.dart';
import 'hotspot/framing_controller.dart';

/// Owns the reactive state for [DeskImageInput].
///
/// Groups the previously scattered signals (image ref, asset, upload state,
/// transient preview bytes, UI affordances) and exposes a [mutationSignal] for
/// the upload action so loading/error are derived from one source.
class ImageInputViewModel {
  final DataSource dataSource;
  final String fieldName;

  /// The resolved image reference shown to the user.
  late final imageRef = Signal<ImageReference?>(
    null,
    debugLabel: '$fieldName.imageRef',
  );

  /// The backing media asset (when [imageRef] points at one).
  late final asset = Signal<MediaAsset?>(
    null,
    debugLabel: '$fieldName.asset',
  );

  /// External URL value when the user types one in instead of uploading.
  late final externalUrl = Signal<String?>(
    null,
    debugLabel: '$fieldName.externalUrl',
  );

  /// Raw bytes of the in-flight upload, used for local preview.
  late final pickedBytes = Signal<Uint8List?>(
    null,
    debugLabel: '$fieldName.pickedBytes',
  );

  late final isDragOver = Signal<bool>(
    false,
    debugLabel: '$fieldName.isDragOver',
  );

  late final lastFramingMode = Signal<FramingMode>(
    FramingMode.focus,
    debugLabel: '$fieldName.lastFramingMode',
  );

  /// Upload mutation. Loading/error states are read from this signal directly
  /// (`upload.value.isLoading`, `upload.value.error`).
  late final upload =
      mutationSignal<MediaAsset, ({String fileName, Uint8List bytes})>((
        args,
      ) async {
        pickedBytes.value = args.bytes;
        try {
          final newAsset = await dataSource.uploadImage(
            args.fileName,
            args.bytes,
          );
          asset.value = newAsset;
          imageRef.value = ImageReferenceFromAsset.fromAsset(newAsset);
          externalUrl.value = null;
          return newAsset;
        } finally {
          pickedBytes.value = null;
        }
      }, debugLabel: '$fieldName.upload');

  ImageInputViewModel({required this.dataSource, required this.fieldName});

  /// Initializes state from a serialized [ImageReference] map (the form data).
  Future<void> initFromData(Object? value) async {
    if (value is! Map<String, dynamic>) return;
    if (!ImageReference.isImageReference(value)) return;

    if (value['externalUrl'] != null) {
      externalUrl.value = value['externalUrl'] as String;
      return;
    }

    final assetId = value['assetId'] as String?;
    if (assetId == null) return;

    try {
      final loadedAsset = await dataSource.getMediaAsset(assetId);
      if (loadedAsset == null) {
        log('ImageInput: getMediaAsset($assetId) returned null');
        return;
      }
      final hotspot = value['hotspot'] != null
          ? Hotspot.fromJson(value['hotspot'] as Map<String, dynamic>)
          : null;
      final crop = value['crop'] != null
          ? CropRect.fromJson(value['crop'] as Map<String, dynamic>)
          : null;
      final altText = value['altText'] as String?;
      asset.value = loadedAsset;
      imageRef.value = ImageReferenceFromAsset.fromAsset(
        loadedAsset,
        hotspot: hotspot,
        crop: crop,
        altText: altText,
      );
    } catch (e) {
      log('ImageInput: getMediaAsset($assetId) threw: $e');
    }
  }

  /// User picked an existing asset (e.g. from the media browser).
  void selectAsset(MediaAsset newAsset) {
    asset.value = newAsset;
    imageRef.value = ImageReferenceFromAsset.fromAsset(newAsset);
    externalUrl.value = null;
    upload.reset();
  }

  /// User edited the [ImageReference] (e.g. hotspot/crop changes).
  void updateImageRef(ImageReference newRef) {
    imageRef.value = newRef;
  }

  /// User typed an external URL. Clears any asset selection when non-empty.
  void setExternalUrl(String? url) {
    externalUrl.value = (url == null || url.isEmpty) ? null : url;
    if (url != null && url.isNotEmpty) {
      imageRef.value = null;
      asset.value = null;
      upload.reset();
    }
  }

  /// Clears the value entirely (remove button).
  void clear() {
    imageRef.value = null;
    asset.value = null;
    externalUrl.value = null;
    pickedBytes.value = null;
    upload.reset();
  }

  /// Resets state when the parent passes new [data] (e.g. document switched).
  void resetForNewData() {
    clear();
  }

  void dispose() {
    imageRef.dispose();
    asset.dispose();
    externalUrl.dispose();
    pickedBytes.dispose();
    isDragOver.dispose();
    lastFramingMode.dispose();
    upload.dispose();
  }
}
