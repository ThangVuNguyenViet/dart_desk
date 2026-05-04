import 'dart:io';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '_mock_photo.dart';

final _ref = ValueNotifier<ImageReference>(
  const ImageReference(publicUrl: 'fake://demo', width: 800, height: 500),
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
        builder: (_, ref, _) => Container(
          color: const Color(0xFFEEE9DA),
          child: DeskFrame(ref: ref, child: const MockPhoto()),
        ),
      ),
    ),
  ],
);

class _Stage extends StatelessWidget {
  const _Stage();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _frame('1:1', 140, 140),
        const SizedBox(width: 12),
        _frame('16:9', 280, 158),
        const SizedBox(width: 12),
        _frame('9:16', 100, 180),
      ],
    ),
  );
}

void main() {
  testGoldenScene('DeskFrame transform timeline', (tester) async {
    await Timeline(
          'Transform: author scales then offsets the asset',
          directory: Directory('goldens'),
          fileName: 'desk_frame_transform_timeline',
          layout: ColumnSceneLayout(),
        )
        .setupWithBuilder(
          () => const Directionality(
            textDirection: TextDirection.ltr,
            child: _Stage(),
          ),
        )
        .takePhoto('1. raw upload (identity)')
        .modifyScene((tester, _) async {
          _ref.value = ImageReference(
            publicUrl: _ref.value.publicUrl,
            width: _ref.value.width,
            height: _ref.value.height,
            scale: 0.6,
          );
          await tester.pump();
        })
        .takePhoto('2. author scales to 0.6× — transparent edges show')
        .modifyScene((tester, _) async {
          _ref.value = ImageReference(
            publicUrl: _ref.value.publicUrl,
            width: _ref.value.width,
            height: _ref.value.height,
            scale: 0.6,
            offset: const Offset(-0.1, -0.05),
          );
          await tester.pump();
        })
        .takePhoto('3. author offsets to anchor over background')
        .modifyScene((tester, _) async {
          _ref.value = ImageReference(
            publicUrl: _ref.value.publicUrl,
            width: _ref.value.width,
            height: _ref.value.height,
          );
          await tester.pump();
        })
        .takePhoto('4. reset transform → identity')
        .run(tester);
  });
}
