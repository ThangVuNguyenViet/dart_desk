import 'dart:io';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '_framing_pattern.dart';

final _ref = ValueNotifier<ImageReference>(
  const ImageReference(publicUrl: 'fake://wide', width: 800, height: 400),
);

class _Stage extends StatelessWidget {
  const _Stage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 180,
        child: ValueListenableBuilder<ImageReference>(
          valueListenable: _ref,
          builder: (_, ref, _) =>
              DeskFrame(ref: ref, child: const FramingPattern()),
        ),
      ),
    );
  }
}

void main() {
  testGoldenScene('DeskFrame live-edit timeline', (tester) async {
    await Timeline(
          'DeskFrame — propagates ref edits',
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
        .takePhoto('default')
        .modifyScene((tester, _) async {
          _ref.value = ImageReference(
            publicUrl: _ref.value.publicUrl,
            width: _ref.value.width,
            height: _ref.value.height,
            hotspot: const Hotspot(x: 0.85, y: 0.5, width: 0.3, height: 0.3),
          );
          await tester.pump();
        })
        .takePhoto('hotspot moved right')
        .modifyScene((tester, _) async {
          _ref.value = ImageReference(
            publicUrl: _ref.value.publicUrl,
            width: _ref.value.width,
            height: _ref.value.height,
            crop: const CropRect(top: 0, bottom: 0, left: 0, right: 0.5),
            hotspot: _ref.value.hotspot,
          );
          await tester.pump();
        })
        .takePhoto('crop applied')
        .modifyScene((tester, _) async {
          _ref.value = ImageReference(
            publicUrl: _ref.value.publicUrl,
            width: _ref.value.width,
            height: _ref.value.height,
            crop: const CropRect(top: 0.1, bottom: 0.1, left: 0.1, right: 0.1),
            hotspot: const Hotspot(x: 0.2, y: 0.5, width: 0.3, height: 0.3),
          );
          await tester.pump();
        })
        .takePhoto('crop + hotspot')
        .run(tester);
  });
}
