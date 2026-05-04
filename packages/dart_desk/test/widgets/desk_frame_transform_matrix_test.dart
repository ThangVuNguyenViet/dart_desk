import 'dart:io';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '_mock_photo.dart';
import 'package:dart_desk/testing.dart';

const _ref = ImageReference(publicUrl: 'fake://demo', width: 800, height: 500);

ImageReference _with({
  double? scale,
  Offset? offset,
  Hotspot? hotspot,
  CropRect? crop,
}) => ImageReference(
  publicUrl: _ref.publicUrl,
  width: _ref.width,
  height: _ref.height,
  scale: scale,
  offset: offset == null ? null : ImageOffset(dx: offset.dx, dy: offset.dy),
  hotspot: hotspot,
  crop: crop,
);

Widget _cell(ImageReference r) => Center(
  child: SizedBox(
    width: 220,
    height: 160,
    child: DeskFrame(ref: r, child: const MockPhoto()),
  ),
);

void main() {
  testGoldenScene('DeskFrame transform matrix', (tester) async {
    await Gallery(
          'DeskFrame — scale × offset × hotspot',
          directory: Directory('goldens'),
          fileName: 'desk_frame_transform_matrix',
          layout: ColumnSceneLayout(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'identity (control — must match today)',
          builder: (_) => _cell(_ref),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'scale 0.6 — transparent edges visible',
          builder: (_) => _cell(_with(scale: 0.6)),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'offset (0.2, 0) — shifted right, exposed left edge',
          builder: (_) => _cell(_with(offset: const Offset(0.2, 0))),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'scale 1.4 — zoomed, no edges',
          builder: (_) => _cell(_with(scale: 1.4)),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'scale 0.8 + offset (-0.15, 0.1) + hotspot top-right',
          builder: (_) => _cell(
            _with(
              scale: 0.8,
              offset: const Offset(-0.15, 0.1),
              hotspot: const Hotspot(x: 0.85, y: 0.2, width: 0.2, height: 0.2),
            ),
          ),
        )
        .run(tester);
  });
}
