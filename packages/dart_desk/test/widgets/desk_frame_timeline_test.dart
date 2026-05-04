import 'dart:io';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '_mock_photo.dart';

// Source dims of the mock photo. Matches MockPhoto's normalized layout
// (sky/ground split at 0.65, sun at (0.82, 0.22), person at (0.22, 0.62),
// watermark band y >= 0.88).
const _sourceW = 800;
const _sourceH = 500;

final _ref = ValueNotifier<ImageReference>(
  const ImageReference(
    publicUrl: 'fake://demo',
    width: _sourceW,
    height: _sourceH,
  ),
);

Widget _frame(String label, double w, double h) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF333333),
          fontFamily: 'Roboto',
        ),
      ),
    ),
    SizedBox(
      width: w,
      height: h,
      child: ValueListenableBuilder<ImageReference>(
        valueListenable: _ref,
        builder: (_, ref, _) => DeskFrame(ref: ref, child: const MockPhoto()),
      ),
    ),
  ],
);

class _Stage extends StatelessWidget {
  const _Stage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _frame('1:1 avatar', 140, 140),
          const SizedBox(width: 12),
          _frame('16:9 hero', 280, 158),
          const SizedBox(width: 12),
          _frame('9:16 mobile', 100, 180),
        ],
      ),
    );
  }
}

void main() {
  testGoldenScene('DeskFrame live-edit timeline', (tester) async {
    await Timeline(
          'DeskFrame — same image, three aspect ratios, edits propagate live',
          directory: Directory('goldens'),
          fileName: 'desk_frame_timeline',
          layout: ColumnSceneLayout(),
        )
        .setupWithBuilder(
          () => const Directionality(
            textDirection: TextDirection.ltr,
            child: _Stage(),
          ),
        )
        .takePhoto(
          '1. raw upload — cover centers, sun almost lost in 1:1 / 9:16',
        )
        .modifyScene((tester, _) async {
          _ref.value = ImageReference(
            publicUrl: _ref.value.publicUrl,
            width: _ref.value.width,
            height: _ref.value.height,
            hotspot: const Hotspot(x: 0.82, y: 0.22, width: 0.2, height: 0.2),
          );
          await tester.pump();
        })
        .takePhoto(
          '2. editor pins hotspot on the sun → sun stays centered in every frame',
        )
        .modifyScene((tester, _) async {
          _ref.value = ImageReference(
            publicUrl: _ref.value.publicUrl,
            width: _ref.value.width,
            height: _ref.value.height,
            hotspot: _ref.value.hotspot,
            crop: const CropRect(top: 0, bottom: 0.12, left: 0, right: 0),
          );
          await tester.pump();
        })
        .takePhoto(
          '3. editor crops out the watermark band → cleaner composition',
        )
        .modifyScene((tester, _) async {
          _ref.value = ImageReference(
            publicUrl: _ref.value.publicUrl,
            width: _ref.value.width,
            height: _ref.value.height,
            crop: _ref.value.crop,
            hotspot: const Hotspot(x: 0.22, y: 0.62, width: 0.2, height: 0.2),
          );
          await tester.pump();
        })
        .takePhoto(
          '4. editor moves hotspot to the person → all frames re-center on them',
        )
        .run(tester);
  });
}
