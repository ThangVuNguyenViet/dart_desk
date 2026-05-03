import 'dart:io';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '_framing_pattern.dart';

const _wide = ImageReference(
  publicUrl: 'fake://wide',
  width: 800,
  height: 400,
);

const _tall = ImageReference(
  publicUrl: 'fake://tall',
  width: 400,
  height: 800,
);

ImageReference _withHotspot(ImageReference r, double x, double y) =>
    ImageReference(
      publicUrl: r.publicUrl,
      width: r.width,
      height: r.height,
      hotspot: Hotspot(x: x, y: y, width: 0.3, height: 0.3),
      crop: r.crop,
    );

ImageReference _withCrop(
  ImageReference r, {
  double top = 0,
  double bottom = 0,
  double left = 0,
  double right = 0,
}) => ImageReference(
  publicUrl: r.publicUrl,
  width: r.width,
  height: r.height,
  hotspot: r.hotspot,
  crop: CropRect(top: top, bottom: bottom, left: left, right: right),
);

Widget _cell(ImageReference ref, BoxFit fit) => Center(
  child: SizedBox(
    width: 220,
    height: 160,
    child: DeskFrame(
      ref: ref,
      fit: fit,
      child: const FramingPattern(),
    ),
  ),
);

void main() {
  testGoldenScene('DeskFrame framing matrix', (tester) async {
    await Gallery(
          'DeskFrame — fit × source × ref state',
          directory: Directory('goldens'),
          fileName: 'desk_frame_matrix',
          layout: ColumnSceneLayout(),
        )
        .itemFromBuilder(
          description: 'cover • wide • default',
          builder: (_) => _cell(_wide, BoxFit.cover),
        )
        .itemFromBuilder(
          description: 'cover • wide • hotspot right',
          builder: (_) => _cell(_withHotspot(_wide, 0.85, 0.5), BoxFit.cover),
        )
        .itemFromBuilder(
          description: 'cover • wide • crop right half',
          builder: (_) => _cell(_withCrop(_wide, right: 0.5), BoxFit.cover),
        )
        .itemFromBuilder(
          description: 'cover • wide • crop + hotspot',
          builder: (_) => _cell(
            _withHotspot(
              _withCrop(_wide, top: 0.1, bottom: 0.1, left: 0.1, right: 0.1),
              0.2,
              0.5,
            ),
            BoxFit.cover,
          ),
        )
        .itemFromBuilder(
          description: 'contain • wide • default',
          builder: (_) => _cell(_wide, BoxFit.contain),
        )
        .itemFromBuilder(
          description: 'cover • tall • hotspot top',
          builder: (_) => _cell(_withHotspot(_tall, 0.5, 0.15), BoxFit.cover),
        )
        .run(tester);
  });
}
