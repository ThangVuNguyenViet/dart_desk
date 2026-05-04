class Hotspot {
  final double x, y, width, height;
  const Hotspot({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
  factory Hotspot.fromJson(Map<String, dynamic> json) => Hotspot(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    width: (json['width'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
  );
  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };
  Hotspot copyWith({double? x, double? y, double? width, double? height}) =>
      Hotspot(
        x: x ?? this.x,
        y: y ?? this.y,
        width: width ?? this.width,
        height: height ?? this.height,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hotspot &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(x, y, width, height);
}

/// Flutter-free 2D offset for image transforms. Mirrors `dart:ui` `Offset`
/// but lives in the annotation package so generators (which run without
/// `dart:ui`) can compile against [ImageReference].
class ImageOffset {
  final double dx, dy;
  const ImageOffset({required this.dx, required this.dy});

  static const ImageOffset zero = ImageOffset(dx: 0, dy: 0);

  factory ImageOffset.fromJson(Map<String, dynamic> json) => ImageOffset(
    dx: (json['dx'] as num).toDouble(),
    dy: (json['dy'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'dx': dx, 'dy': dy};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageOffset && dx == other.dx && dy == other.dy;

  @override
  int get hashCode => Object.hash(dx, dy);
}

class CropRect {
  final double top, bottom, left, right;
  const CropRect({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });
  factory CropRect.fromJson(Map<String, dynamic> json) => CropRect(
    top: (json['top'] as num).toDouble(),
    bottom: (json['bottom'] as num).toDouble(),
    left: (json['left'] as num).toDouble(),
    right: (json['right'] as num).toDouble(),
  );
  Map<String, dynamic> toJson() => {
    'top': top,
    'bottom': bottom,
    'left': left,
    'right': right,
  };
}
