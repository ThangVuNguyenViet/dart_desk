import 'dart:convert';

import 'image_types.dart';

class MediaAsset {
  final int id;
  final String assetId;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final String publicUrl;
  final int width;
  final int height;
  final bool hasAlpha;
  final String blurHash;
  final String? lqip;
  final MediaPalette? palette;
  final Map<String, dynamic>? exif;
  final MediaGeoLocation? location;
  final int? uploadedByUserId;
  final DateTime createdAt;
  final MediaAssetMetadataStatus metadataStatus;

  const MediaAsset({
    required this.id,
    required this.assetId,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.publicUrl,
    required this.width,
    required this.height,
    required this.hasAlpha,
    required this.blurHash,
    this.lqip,
    this.palette,
    this.exif,
    this.location,
    this.uploadedByUserId,
    required this.createdAt,
    required this.metadataStatus,
  });

  bool get isImage => mimeType.startsWith('image/');

  String get fileSizeFormatted {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  factory MediaAsset.fromJson(Map<String, dynamic> json) {
    MediaPalette? palette;
    if (json['paletteJson'] != null) {
      final paletteJson = json['paletteJson'] as String;
      palette = MediaPalette.fromJson(jsonDecode(paletteJson) as Map<String, dynamic>);
    }

    Map<String, dynamic>? exif;
    if (json['exifJson'] != null) {
      final exifJson = json['exifJson'] as String;
      exif = jsonDecode(exifJson) as Map<String, dynamic>;
    }

    MediaGeoLocation? location;
    if (json['locationLat'] != null && json['locationLng'] != null) {
      location = MediaGeoLocation(
        lat: (json['locationLat'] as num).toDouble(),
        lng: (json['locationLng'] as num).toDouble(),
      );
    }

    return MediaAsset(
      id: json['id'] as int,
      assetId: json['assetId'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      fileSize: json['fileSize'] as int,
      publicUrl: json['publicUrl'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      hasAlpha: json['hasAlpha'] as bool,
      blurHash: json['blurHash'] as String,
      lqip: json['lqip'] as String?,
      palette: palette,
      exif: exif,
      location: location,
      uploadedByUserId: json['uploadedByUserId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadataStatus: MediaAssetMetadataStatus.values.byName(json['metadataStatus'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'assetId': assetId,
    'fileName': fileName,
    'mimeType': mimeType,
    'fileSize': fileSize,
    'publicUrl': publicUrl,
    'width': width,
    'height': height,
    'hasAlpha': hasAlpha,
    'blurHash': blurHash,
    if (lqip != null) 'lqip': lqip,
    if (palette != null) 'paletteJson': jsonEncode(palette!.toJson()),
    if (exif != null) 'exifJson': jsonEncode(exif),
    if (location != null) 'locationLat': location!.lat,
    if (location != null) 'locationLng': location!.lng,
    if (uploadedByUserId != null) 'uploadedByUserId': uploadedByUserId,
    'createdAt': createdAt.toIso8601String(),
    'metadataStatus': metadataStatus.name,
  };
}
