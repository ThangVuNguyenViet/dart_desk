// Re-export the unified ImageReference from the annotation package.
export 'package:dart_desk_annotation/src/models/image_ref.dart';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'media_asset.dart';

/// Extension to bridge between [MediaAsset] (CMS-internal) and [ImageReference].
extension ImageReferenceFromAsset on ImageReference {
  /// Creates an [ImageReference] populated with resolved fields from a [MediaAsset].
  static ImageReference fromAsset(
    MediaAsset asset, {
    Hotspot? hotspot,
    CropRect? crop,
    String? altText,
  }) => ImageReference(
    assetId: asset.assetId,
    publicUrl: asset.publicUrl,
    width: asset.width,
    height: asset.height,
    blurHash: asset.blurHash,
    lqip: asset.lqip,
    hotspot: hotspot,
    crop: crop,
    altText: altText,
  );
}
