import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DeskImageView wraps an Image in a DeskFrame', (tester) async {
    const ref = ImageReference(
      publicUrl: 'https://example.com/img.png',
      width: 100,
      height: 100,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: DeskImageView(ref),
          ),
        ),
      ),
    );

    tester.takeException();

    expect(find.byType(DeskFrame), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  test('DeskImageView assert fires when both publicUrl and externalUrl are null', () {
    const ref = ImageReference(width: 10, height: 10);
    expect(() => DeskImageView(ref), throwsAssertionError);
  });
}
