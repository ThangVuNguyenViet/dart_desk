import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _ref200x200 = ImageReference(
  publicUrl: 'https://example.com/img.png',
  width: 200,
  height: 200,
);

class _ProbeChild extends StatelessWidget {
  const _ProbeChild();
  @override
  Widget build(BuildContext context) =>
      const SizedBox.expand(child: ColoredBox(color: Color(0xFF00FF00)));
}

void main() {
  group('DeskFrame', () {
    testWidgets('contain, no crop, no hotspot: child fills box', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: DeskFrame(
                ref: _ref200x200,
                fit: BoxFit.contain,
                child: const _ProbeChild(),
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(_ProbeChild));
      expect(size, const Size(100, 100));
    });

    testWidgets('cover with wider source: child wider than box', (tester) async {
      const wideRef = ImageReference(
        publicUrl: 'https://example.com/wide.png',
        width: 200,
        height: 100,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: DeskFrame(
                ref: wideRef,
                fit: BoxFit.cover,
                child: const _ProbeChild(),
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(_ProbeChild));
      expect(size.width, 200);
      expect(size.height, 100);
    });

    testWidgets('frame is clipped to box bounds', (tester) async {
      const wideRef = ImageReference(
        publicUrl: 'https://example.com/wide.png',
        width: 200,
        height: 100,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: DeskFrame(
                ref: wideRef,
                fit: BoxFit.cover,
                child: const _ProbeChild(),
              ),
            ),
          ),
        ),
      );

      final clipSize = tester.getSize(find.byType(DeskFrame));
      expect(clipSize, const Size(100, 100));
    });

    testWidgets('handles missing image dimensions without crashing', (tester) async {
      const noDimRef = ImageReference(publicUrl: 'https://example.com/x.png');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: DeskFrame(
                ref: noDimRef,
                child: const _ProbeChild(),
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(_ProbeChild));
      expect(size, const Size(100, 100));
    });
  });
}
