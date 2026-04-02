export 'package:dart_desk_annotation/src/models/image_types.dart';

enum FitMode { clip, crop, fill, max, scale }

enum MediaAssetMetadataStatus { pending, complete, failed }

enum MediaTypeFilter { image, video, file, all }

enum MediaSort { dateDesc, dateAsc, nameAsc, nameDesc, sizeDesc, sizeAsc }

class PaletteColor {
  final int r, g, b;
  final String hex;
  const PaletteColor({required this.r, required this.g, required this.b, required this.hex});
  factory PaletteColor.fromJson(Map<String, dynamic> json) => PaletteColor(
    r: json['r'] as int,
    g: json['g'] as int,
    b: json['b'] as int,
    hex: json['hex'] as String,
  );
  Map<String, dynamic> toJson() => {'r': r, 'g': g, 'b': b, 'hex': hex};
}

class MediaPalette {
  final PaletteColor dominant;
  final PaletteColor? vibrant, muted, darkMuted;
  const MediaPalette({required this.dominant, this.vibrant, this.muted, this.darkMuted});
  factory MediaPalette.fromJson(Map<String, dynamic> json) => MediaPalette(
    dominant: PaletteColor.fromJson(json['dominant']),
    vibrant: json['vibrant'] != null ? PaletteColor.fromJson(json['vibrant']) : null,
    muted: json['muted'] != null ? PaletteColor.fromJson(json['muted']) : null,
    darkMuted: json['darkMuted'] != null ? PaletteColor.fromJson(json['darkMuted']) : null,
  );
  Map<String, dynamic> toJson() => {
    'dominant': dominant.toJson(),
    if (vibrant != null) 'vibrant': vibrant!.toJson(),
    if (muted != null) 'muted': muted!.toJson(),
    if (darkMuted != null) 'darkMuted': darkMuted!.toJson(),
  };
}

class MediaGeoLocation {
  final double lat, lng;
  const MediaGeoLocation({required this.lat, required this.lng});
  factory MediaGeoLocation.fromJson(Map<String, dynamic> json) => MediaGeoLocation(
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );
  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class QuickImageMetadata {
  final int width, height;
  final bool hasAlpha;
  final String blurHash, contentHash;
  const QuickImageMetadata({
    required this.width,
    required this.height,
    required this.hasAlpha,
    required this.blurHash,
    required this.contentHash,
  });
}
