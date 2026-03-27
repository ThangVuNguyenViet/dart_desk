// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'studio_router.dart';

/// generated route for
/// [DocumentScreen]
class DocumentRoute extends PageRouteInfo<DocumentRouteArgs> {
  DocumentRoute({
    Key? key,
    required String documentTypeSlug,
    required String documentId,
    List<PageRouteInfo>? children,
  }) : super(
         DocumentRoute.name,
         args: DocumentRouteArgs(
           key: key,
           documentTypeSlug: documentTypeSlug,
           documentId: documentId,
         ),
         rawPathParams: {
           'documentTypeSlug': documentTypeSlug,
           'documentId': documentId,
         },
         initialChildren: children,
       );

  static const String name = 'DocumentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DocumentRouteArgs>(
        orElse: () => DocumentRouteArgs(
          documentTypeSlug: pathParams.getString('documentTypeSlug'),
          documentId: pathParams.getString('documentId'),
        ),
      );
      return DocumentScreen(
        key: args.key,
        documentTypeSlug: args.documentTypeSlug,
        documentId: args.documentId,
      );
    },
  );
}

class DocumentRouteArgs {
  const DocumentRouteArgs({
    this.key,
    required this.documentTypeSlug,
    required this.documentId,
  });

  final Key? key;

  final String documentTypeSlug;

  final String documentId;

  @override
  String toString() {
    return 'DocumentRouteArgs{key: $key, documentTypeSlug: $documentTypeSlug, documentId: $documentId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DocumentRouteArgs) return false;
    return key == other.key &&
        documentTypeSlug == other.documentTypeSlug &&
        documentId == other.documentId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ documentTypeSlug.hashCode ^ documentId.hashCode;
}

/// generated route for
/// [DocumentTypeScreen]
class DocumentTypeRoute extends PageRouteInfo<DocumentTypeRouteArgs> {
  DocumentTypeRoute({
    Key? key,
    required String documentTypeSlug,
    List<PageRouteInfo>? children,
  }) : super(
         DocumentTypeRoute.name,
         args: DocumentTypeRouteArgs(
           key: key,
           documentTypeSlug: documentTypeSlug,
         ),
         rawPathParams: {'documentTypeSlug': documentTypeSlug},
         initialChildren: children,
       );

  static const String name = 'DocumentTypeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DocumentTypeRouteArgs>(
        orElse: () => DocumentTypeRouteArgs(
          documentTypeSlug: pathParams.getString('documentTypeSlug'),
        ),
      );
      return DocumentTypeScreen(
        key: args.key,
        documentTypeSlug: args.documentTypeSlug,
      );
    },
  );
}

class DocumentTypeRouteArgs {
  const DocumentTypeRouteArgs({this.key, required this.documentTypeSlug});

  final Key? key;

  final String documentTypeSlug;

  @override
  String toString() {
    return 'DocumentTypeRouteArgs{key: $key, documentTypeSlug: $documentTypeSlug}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DocumentTypeRouteArgs) return false;
    return key == other.key && documentTypeSlug == other.documentTypeSlug;
  }

  @override
  int get hashCode => key.hashCode ^ documentTypeSlug.hashCode;
}

/// generated route for
/// [MediaScreen]
class MediaRoute extends PageRouteInfo<void> {
  const MediaRoute({List<PageRouteInfo>? children})
    : super(MediaRoute.name, initialChildren: children);

  static const String name = 'MediaRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MediaScreen();
    },
  );
}

/// generated route for
/// [StudioShellScreen]
class StudioShellRoute extends PageRouteInfo<void> {
  const StudioShellRoute({List<PageRouteInfo>? children})
    : super(StudioShellRoute.name, initialChildren: children);

  static const String name = 'StudioShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StudioShellScreen();
    },
  );
}

/// generated route for
/// [VersionScreen]
class VersionRoute extends PageRouteInfo<VersionRouteArgs> {
  VersionRoute({
    Key? key,
    required String documentTypeSlug,
    required String documentId,
    required String versionId,
    List<PageRouteInfo>? children,
  }) : super(
         VersionRoute.name,
         args: VersionRouteArgs(
           key: key,
           documentTypeSlug: documentTypeSlug,
           documentId: documentId,
           versionId: versionId,
         ),
         rawPathParams: {
           'documentTypeSlug': documentTypeSlug,
           'documentId': documentId,
           'versionId': versionId,
         },
         initialChildren: children,
       );

  static const String name = 'VersionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<VersionRouteArgs>(
        orElse: () => VersionRouteArgs(
          documentTypeSlug: pathParams.getString('documentTypeSlug'),
          documentId: pathParams.getString('documentId'),
          versionId: pathParams.getString('versionId'),
        ),
      );
      return VersionScreen(
        key: args.key,
        documentTypeSlug: args.documentTypeSlug,
        documentId: args.documentId,
        versionId: args.versionId,
      );
    },
  );
}

class VersionRouteArgs {
  const VersionRouteArgs({
    this.key,
    required this.documentTypeSlug,
    required this.documentId,
    required this.versionId,
  });

  final Key? key;

  final String documentTypeSlug;

  final String documentId;

  final String versionId;

  @override
  String toString() {
    return 'VersionRouteArgs{key: $key, documentTypeSlug: $documentTypeSlug, documentId: $documentId, versionId: $versionId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VersionRouteArgs) return false;
    return key == other.key &&
        documentTypeSlug == other.documentTypeSlug &&
        documentId == other.documentId &&
        versionId == other.versionId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      documentTypeSlug.hashCode ^
      documentId.hashCode ^
      versionId.hashCode;
}
