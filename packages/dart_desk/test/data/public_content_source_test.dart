import 'package:dart_desk/dart_desk.dart';
import 'package:flutter_test/flutter_test.dart';

class _Stub implements PublicContentSource {
  @override
  Future<Map<String, List<PublicDeskDocument>>> getAllContents() async => {};
  @override
  Future<Map<String, PublicDeskDocument>> getDefaultContents() async => {};
  @override
  Future<List<PublicDeskDocument>> getContentsByType(String type) async => [];
  @override
  Future<PublicDeskDocument> getDefaultContent(String type) async =>
      throw UnimplementedError();
  @override
  Future<PublicDeskDocument> getContentBySlug(String type, String slug) async =>
      throw UnimplementedError();
  @override
  Future<List<PublicDeskDocument>> getContentsByDataContains(
    String type,
    String dataContainsJson,
  ) async => [];
}

void main() {
  test('PublicContentSource interface is implementable', () {
    final source = _Stub();
    expect(source, isA<PublicContentSource>());
  });
}
